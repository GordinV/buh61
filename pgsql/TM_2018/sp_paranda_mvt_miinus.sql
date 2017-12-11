DROP AGGREGATE IF EXISTS array_agg( ANYELEMENT );

CREATE AGGREGATE array_agg( ANYELEMENT ) (
SFUNC = array_append,
STYPE = ANYARRAY,
INITCOND = '{}'
);

CREATE OR REPLACE FUNCTION sp_paranda_mvt_miinus(tnIsikId INTEGER, tnRekvId INTEGER, tdKpv DATE)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  qrypalklib         RECORD;
  v_miinus_mvt       RECORD;
  v_leping           RECORD;
  v_palk_oper        RECORD;
  l_uus_tm           NUMERIC(14, 4);
  l_tm_miinus_kokku  NUMERIC(14, 4) = 0;
  l_mvt_miinus_kokku NUMERIC(14, 4) = 0;
  l_id               INTEGER;

BEGIN
  --v_leping init
  SELECT *
  INTO v_leping
  FROM tooleping t
  WHERE parentid = tnIsikId AND rekvid = tnRekvId AND (t.lopp IS NULL OR t.lopp <= tdKpv)
  ORDER BY pohikoht DESC
  LIMIT 1;

  --kustutame eelmine arvestus
  DELETE FROM palk_oper
  WHERE summa = 0 AND lepingid IN (SELECT id
                                   FROM tooleping
                                   WHERE parentId = tnIsikId)
        AND kpv = tdKpv
        AND rekvId = tnRekvId
        AND muud LIKE 'MVT miinus parandus%';

  -- SQL looking for MVT < 0
  FOR v_miinus_mvt IN
  SELECT
    sum(po.summa)          AS tulu,
    sum(po.tootumaks)      AS tki,
    sum(po.pensmaks)       AS pm,
    sum(po.tulubaas)       AS mvt,
    sum(po.tulumaks)       AS tm,
    array_agg(po.libid)    AS libs,
    array_agg(po.lepingid) AS lepings,
    pl.tululiik
  FROM palk_oper po
    INNER JOIN palk_lib pl ON pl.parentid = po.libid AND NOT empty(pl.tululiik)
  WHERE lepingId IN (SELECT id
                     FROM tooleping
                     WHERE parentid = tnIsikId AND rekvId = tnRekvId)
        AND month(kpv) = month(tdKpv)
        AND year(kpv) = year(tdKpv)
        AND po.tulubaas IS NOT NULL
  GROUP BY kpv, tululiik
  ORDER BY pl.tululiik DESC

  LOOP
    IF (v_miinus_mvt.mvt) < 0
    THEN
      -- found mvt < 0, shoul create po with miinus

      -- find po with miinus MVT
      SELECT po.*
      INTO v_palk_oper
      FROM palk_oper po
      WHERE lepingid = v_miinus_mvt.lepings [1]
            AND libid = v_miinus_mvt.libs [1]
            AND month(kpv) = month(tdKpv)
            AND year(kpv) = year(tdKpv)
            AND tulubaas < 0
      ORDER BY kpv DESC
      LIMIT 1;

      -- calculate new TM
      -- arvestame tm diff
      l_uus_tm = ((v_miinus_mvt.tulu - v_miinus_mvt.tki - v_miinus_mvt.pm) * 0.20) - v_miinus_mvt.tm;

      --save new PO with miinus
      l_id = sp_salvesta_palk_oper(0, tnRekvId, v_miinus_mvt.libs [1], v_miinus_mvt.lepings [1], tdKpv, 0,
                                   0,
                                   'MVT miinus parandus, tululiik ' + v_miinus_mvt.tululiik,
                                   space(1), 'LE-P', space(1), space(1), space(1), space(1), space(1), space(1), 'EUR',
                                   1, space(1),
                                   v_miinus_mvt.tululiik :: INTEGER, l_uus_tm, 0, 0, 0,
                                   -1 * v_miinus_mvt.mvt, 0, NULL :: DATE);

      --store summa into vars
      l_mvt_miinus_kokku = l_mvt_miinus_kokku + v_miinus_mvt.mvt;
      l_tm_miinus_kokku = l_tm_miinus_kokku + l_uus_tm;

    END IF;

  END LOOP;

  IF (l_mvt_miinus_kokku <> 0)
  THEN
    -- find max + tululiik summa
    SELECT po.*
    INTO v_palk_oper
    FROM palk_oper po
      INNER JOIN palk_lib pl ON pl.parentid = po.libid AND NOT empty(pl.tululiik)
    WHERE lepingId IN (SELECT id
                       FROM tooleping
                       WHERE parentid = tnIsikId AND rekvId = tnRekvId)
          AND month(kpv) = month(tdKpv)
          AND year(kpv) = year(tdKpv)
          AND po.tulubaas > 0
    ORDER BY po.tulubaas DESC;

    --save new PO with max tululiik
    l_id = sp_salvesta_palk_oper(0, tnRekvId, v_miinus_mvt.libs [1], v_miinus_mvt.lepings [1], tdKpv, 0,
                                 0,
                                 'MVT miinus parandus, tululiik ' + v_miinus_mvt.tululiik,
                                 space(1), 'LE-P', space(1), space(1), space(1), space(1), space(1), space(1), 'EUR',
                                 1, space(1),
                                 v_miinus_mvt.tululiik :: INTEGER, -1 * l_tm_miinus_kokku, 0, 0, 0,
                                 l_mvt_miinus_kokku, 0, NULL :: DATE);


  END IF;

  RETURN 0;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;

GRANT EXECUTE ON FUNCTION gen_palkoper(INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_palkoper(INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER) TO dbpeakasutaja;
