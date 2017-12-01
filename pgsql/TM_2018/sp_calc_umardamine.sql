-- Function: sp_calc_umardamine(integer, date, integer)

DROP FUNCTION IF EXISTS sp_calc_umardamine( INTEGER, DATE, INTEGER );

CREATE OR REPLACE FUNCTION sp_calc_umardamine(tnisikid INTEGER, tdkpv DATE, tnrekvid INTEGER)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  v_tululiik       RECORD;
  lnSumma          NUMERIC(14, 4);
  v_leping         RECORD;
  lcTimestamp      VARCHAR(20);
  v_arv            RECORD;
  v_fakt_arv       RECORD;
  ldKpv            DATE = gomonth(DATE(year(tdKpv), month(tdKpv), 1), 1) - 1;
  l_tulubaas       NUMERIC(14, 4); --mvt
  l_tulubaas_kokku NUMERIC(14, 4);

  l_mvt_kokku      NUMERIC(14, 4) = 0;
  l_pm_kokku       NUMERIC(14, 4) = 0;
  l_tk_kokku       NUMERIC(14, 4) = 0;
  l_tm_kokku       NUMERIC(14, 4) = 0;
  l_tulu_kokku     NUMERIC(14, 4) = 0;
  l_mvt_diff       NUMERIC(14, 4) = 0;
  l_id             INTEGER;

  v_max_mvt        RECORD;
  v_miinus_mvt     RECORD;
  l_lepingId       INTEGER;
  l_libId          INTEGER;
  l_uus_tm         NUMERIC(14, 4) = 0;

BEGIN
  --assign default value to v_leping
  v_leping = ROW (NULL);

  -- kustutame eelamise arvestus
  DELETE FROM palk_oper po
  WHERE po.lepingId IN (
    SELECT id
    FROM tooleping
    WHERE parentId = tnIsikId
  )
        AND po.kpv >= date(year(tdKpv), month(tdKpv), 1) AND kpv <= ldKpv
        AND po.rekvId = tnRekvId
        AND po.summa = 0;


  SELECT
    0 :: NUMERIC(14, 4) AS summa,
    0 :: NUMERIC(14, 4) AS mvt,
    0 :: NUMERIC(14, 4) AS tm,
    0 :: NUMERIC(14, 4) AS tki,
    0 :: NUMERIC(14, 4) AS pm,
    '' :: TEXT          AS tululiik,
    NULL :: INTEGER     AS lepingId,
    NULL :: INTEGER     AS libId
  INTO v_max_mvt;
  SELECT
    0 :: NUMERIC(14, 4) AS summa,
    0 :: NUMERIC(14, 4) AS mvt,
    0 :: NUMERIC(14, 4) AS tm,
    0 :: NUMERIC(14, 4) AS tki,
    0 :: NUMERIC(14, 4) AS pm,
    '' :: TEXT          AS tululiik,
    NULL :: INTEGER     AS lepingId,
    NULL :: INTEGER     AS libId
  INTO v_miinus_mvt;

  -- arvestame

  FOR v_tululiik IN
  SELECT
    pl.tululiik,
    sum(po.summa)     AS summa,
    count(po.id)      AS arv_count,
    sum(po.tulubaas)  AS mvt,
    sum(po.tootumaks) AS tki,
    sum(po.pensmaks)  AS pm,
    sum(tulumaks)     AS tm
  FROM palk_oper po
    INNER JOIN library l ON l.id = po.libid
    INNER JOIN palk_lib pl ON pl.parentid = l.id
  WHERE po.lepingId IN (
    SELECT id
    FROM tooleping
    WHERE parentId = tnIsikId
  )
        AND po.kpv >= date(year(tdKpv), month(tdKpv), 1) AND kpv <= ldKpv
        --and po.kpv = tdKpv
        AND po.rekvId = tnRekvId
        AND pl.liik = 1
  GROUP BY pl.tululiik, pl.liik
  ORDER BY pl.liik
  LOOP

    -- salvestame max tululiige summa
    IF (v_tululiik.summa > v_max_mvt.summa)
    THEN
      v_max_mvt.summa = v_tululiik.summa;
      v_max_mvt.mvt = v_tululiik.mvt;
      v_max_mvt.tm = v_tululiik.tm;
      v_max_mvt.tki = v_tululiik.tki;
      v_max_mvt.pm = v_tululiik.pm;
      v_max_mvt.tululiik = v_tululiik.tululiik;
    END IF;

    -- salvestame miinus tululiige summa
    IF (v_tululiik.mvt < 0)
    THEN
      v_miinus_mvt.summa = v_tululiik.summa;
      v_miinus_mvt.mvt = v_tululiik.mvt;
      v_miinus_mvt.tm = v_tululiik.tm;
      v_miinus_mvt.tki = v_tululiik.tki;
      v_miinus_mvt.pm = v_tululiik.pm;
      v_miinus_mvt.tululiik = v_tululiik.tululiik;
    END IF;

    IF v_tululiik.arv_count > 1
    THEN
      SELECT
        po.*,
        pl.tululiik
      INTO v_leping
      FROM palk_oper po
        INNER JOIN library l ON l.id = po.libid
        INNER JOIN palk_lib pl ON pl.parentid = l.id
        INNER JOIN tooleping t ON t.id = po.lepingId
      WHERE t.parentId = tnIsikId
            AND po.kpv = tdKpv
            AND po.rekvId = tnRekvId
            AND pl.liik = 1
            AND pl.tululiik = v_tululiik.tululiik
      ORDER BY t.pohikoht DESC, po.summa DESC
      LIMIT 1;

      --salvestame max mvt lepingid ja libId
      IF v_max_mvt.tululiik = v_leping.tululiik AND v_max_mvt.lepingId IS NULL
      THEN
        v_max_mvt.lepingId = v_leping.lepingId;
        v_max_mvt.libId = v_leping.libId;
      END IF;

      IF lcTimestamp IS NULL
      THEN
        lcTimestamp = left('ARV' + LTRIM(RTRIM(str(v_leping.LepingId))) + LTRIM(RTRIM(str(v_leping.LibId))) +
                           ltrim(rtrim(str(dateasint(tdKpv)))), 20);
      END IF;

      IF v_leping.lepingId IS NULL
      THEN
        RETURN 0;
      END IF;

      lnSumma = sp_calc_arv(v_leping.lepingId, v_leping.libId, v_leping.kpv, v_tululiik.summa, NULL, 1);

      SELECT
        round(tasun1, 2)    AS tulubaas,
        round(volg1, 2)     AS tm,
        round(volg2, 2)     AS sm,
        round(volg4, 2)     AS tki,
        round(volg5, 2)     AS pm,
        round(volg6, 2)     AS tka,
        muud,
        0 :: NUMERIC(14, 4) AS mvt
      INTO v_arv
      FROM tmp_viivis
      WHERE alltrim(timestamp) = alltrim(lcTimestamp);


      SELECT
        sum(summa)     AS arv,
        sum(tulumaks)  AS tm,
        sum(sotsmaks)  AS sm,
        sum(tootumaks) AS tki,
        sum(pensmaks)  AS pm,
        sum(tka)       AS tka,
        sum(tulubaas)  AS mvt
      INTO v_fakt_arv
      FROM palk_oper po
        INNER JOIN library l ON l.id = po.libid
        INNER JOIN palk_lib pl ON pl.parentid = l.id
      WHERE po.lepingId IN (
        SELECT id
        FROM tooleping
        WHERE parentId = tnIsikId
      )
            --	and po.kpv = tdKpv
            AND po.kpv >= date(year(tdKpv), month(tdKpv), 1) AND kpv <= ldKpv
            AND po.rekvId = tnRekvId
            AND pl.liik = 1
            AND pl.tululiik = v_tululiik.tululiik;

      -- kontrollime MVT
      l_tulubaas_kokku = coalesce((SELECT sum(mvt.summa)
                                   FROM taotlus_mvt mvt
                                     INNER JOIN tooleping t ON t.id = mvt.lepingId
                                   WHERE t.parentId = tnIsikId AND alg_kpv <= tdKpv AND lopp_kpv >= tdKpv), 0);

      l_tulubaas = calc_mvt(v_fakt_arv.arv, l_tulubaas_kokku, tdKpv);


      IF v_fakt_arv.mvt - (v_arv.tm - round(v_fakt_arv.tm, 2) - (v_arv.pm - round(v_fakt_arv.pm, 2)) - v_arv.tki -
                           round(v_fakt_arv.tki, 2)) > l_tulubaas
      THEN
        v_arv.mvt = l_tulubaas - v_fakt_arv.mvt;
      END IF;

      IF v_arv.tm - round(v_fakt_arv.tm, 2) <> 0 OR
         v_arv.sm - round(v_fakt_arv.sm, 2) <> 0 OR
         v_arv.tki - round(v_fakt_arv.tki, 2) <> 0 OR
         v_arv.tka - round(v_fakt_arv.tka, 2) <> 0 OR
         v_arv.pm - round(v_fakt_arv.pm, 2) <> 0
      THEN

        l_id = sp_salvesta_palk_oper(0, tnRekvId, v_leping.libId, v_leping.lepingId, ldKpv, 0, v_leping.Doklausid,
                                     'Ümardamine' + v_arv.muud,
                                     ifnull(v_leping.kood1, space(1)), ifnull(v_leping.kood2, 'LE-P'),
                                     ifnull(v_leping.kood3, space(1)),
                                     ifnull(v_leping.kood4, space(1)), ifnull(v_leping.kood5, space(1)),
                                     ifnull(v_leping.konto, space(1)),
                                     v_leping.tp, v_leping.tunnus, 'EUR', 1, v_leping.proj,
                                     v_tululiik.tululiik :: INTEGER, ifnull(v_arv.tm - round(v_fakt_arv.tm, 2), 0),
                                     ifnull(v_arv.sm - round(v_fakt_arv.sm, 2), 0),
                                     ifnull(v_arv.tki - round(v_fakt_arv.tki, 2), 0),
                                     ifnull(v_arv.pm - round(v_fakt_arv.pm, 2), 0),
                                     l_mvt_diff, coalesce(v_arv.tka - round(v_fakt_arv.tka, 2), 0), NULL :: DATE);

        IF v_fakt_arv.mvt < 500
        THEN
          -- arvestame kasutatud MVT
          SELECT
            sum(summa)     AS arv,
            sum(tulumaks)  AS tm,
            sum(tootumaks) AS tki,
            sum(pensmaks)  AS pm,
            sum(tulubaas)  AS mvt
          INTO l_tulu_kokku, l_tm_kokku, l_tk_kokku, l_pm_kokku, l_mvt_kokku
          FROM palk_oper po
            INNER JOIN library l ON l.id = po.libid
            INNER JOIN palk_lib pl ON pl.parentid = l.id
          WHERE po.lepingId IN (
            SELECT id
            FROM tooleping
            WHERE parentId = tnIsikId
          )
                AND po.kpv >= date(year(tdKpv), month(tdKpv), 1) AND kpv <= ldKpv
                AND po.rekvId = tnRekvId
                AND pl.liik = 1;

          l_mvt_diff = coalesce(l_mvt_kokku, 0) - (coalesce(l_tulu_kokku, 0) -
                                                   (coalesce(l_tm_kokku, 0) + coalesce(l_tk_kokku, 0) +
                                                    coalesce(l_pm_kokku, 0)));

          IF l_mvt_diff > 0
          THEN
            UPDATE palk_oper
            SET Tulubaas = Tulubaas - l_mvt_diff
            WHERE id = l_id;
          END IF;
        END IF;
      END IF;

    END IF; -- arv count peaks rohkem kui 1

  END LOOP;
  -- kontrollime kas on periodis -mvt
  IF (v_miinus_mvt.mvt < 0)
  THEN

    -- arvestame tm diff
    l_uus_tm = ((v_miinus_mvt.summa - v_miinus_mvt.tki - v_miinus_mvt.pm) * 0.20) - v_miinus_mvt.tm;

    IF v_miinus_mvt.lepingId IS NULL
    THEN
      -- otsime miinus lepingId ja libId
      SELECT
        po.lepingId,
        po.libId
      INTO l_lepingId, l_libId
      FROM palk_oper po
        INNER JOIN library l ON l.id = po.libid
        INNER JOIN palk_lib pl ON pl.parentid = l.id
        INNER JOIN tooleping t ON t.id = po.lepingId
      WHERE t.parentId = tnIsikId
            AND month(po.kpv) = month(tdKpv)
            AND year(po.kpv) = year(tdKpv)
            AND po.rekvId = tnRekvId
            AND pl.liik = 1
            AND pl.tululiik = v_miinus_mvt.tululiik
            AND po.tulubaas < 0
      ORDER BY t.pohikoht DESC, po.summa DESC, po.kpv DESC
      LIMIT 1;

      v_miinus_mvt.lepingId = l_lepingId;
      v_miinus_mvt.libId = l_libId;

    END IF;

    IF v_leping IS NULL
    THEN
      --paring
      SELECT
        po.*,
        pl.tululiik
      INTO v_leping
      FROM palk_oper po
        INNER JOIN library l ON l.id = po.libid
        INNER JOIN palk_lib pl ON pl.parentid = l.id
        INNER JOIN tooleping t ON t.id = po.lepingId
      WHERE t.parentId = tnIsikId
            AND po.kpv = tdKpv
            AND po.rekvId = tnRekvId
            AND pl.liik = 1
            AND pl.tululiik = v_miinus_mvt.tululiik
      ORDER BY t.pohikoht DESC, po.summa DESC
      LIMIT 1;

    END IF;

    -- parandame miinus mvt ja tm
    --    RAISE NOTICE 'Salvestame MVT parandus, tululiik-> %, summa-> % ', v_miinus_mvt.tululiik, -1 * v_miinus_mvt.mvt;
    l_id = sp_salvesta_palk_oper(0, tnRekvId, v_miinus_mvt.libId, v_miinus_mvt.lepingId, ldKpv, 0, v_leping.Doklausid,
                                 'MVT miinus parandus, tululiik ' + v_miinus_mvt.tululiik,
                                 ifnull(v_leping.kood1, space(1)), ifnull(v_leping.kood2, 'LE-P'),
                                 ifnull(v_leping.kood3, space(1)),
                                 ifnull(v_leping.kood4, space(1)), ifnull(v_leping.kood5, space(1)),
                                 ifnull(v_leping.konto, space(1)),
                                 v_leping.tp, v_leping.tunnus, 'EUR', 1, v_leping.proj,
                                 v_miinus_mvt.tululiik :: INTEGER, l_uus_tm, 0, 0, 0,
                                 -1 * v_miinus_mvt.mvt, 0, NULL :: DATE);

    --    RAISE NOTICE 'Salvestatud MVT parandus, Id-> %', l_id;
    -- arvestame mvt diff

    l_uus_tm = (v_max_mvt.summa - (v_max_mvt.mvt + v_miinus_mvt.mvt + v_max_mvt.tki + v_max_mvt.pm)) * 0.20;

    l_uus_tm = v_max_mvt.tm - l_uus_tm;

    -- parandame max mvt ja tm
    -- if v_max_mvt.libId = v_miinus_mvt lepingId, siis otsime v_max_mvt.libId

    IF v_max_mvt.libId IS NULL
    THEN
      SELECT
        po.lepingId,
        po.libId
      INTO l_lepingId, l_libId
      FROM palk_oper po
        INNER JOIN library l ON l.id = po.libid
        INNER JOIN palk_lib pl ON pl.parentid = l.id
        INNER JOIN tooleping t ON t.id = po.lepingId
      WHERE t.parentId = tnisikid
            AND month(po.kpv) = month(tdkpv)
            AND year(po.kpv) = year(tdKpv)
            AND po.rekvId = tnrekvid
            AND pl.liik = 1
            AND pl.tululiik <> v_miinus_mvt.tululiik
            AND po.tulubaas > 0
      ORDER BY t.pohikoht DESC, po.summa DESC, po.kpv DESC
      LIMIT 1;
    END IF;


    IF l_lepingId IS NOT NULL
    THEN
      v_max_mvt.lepingId = l_lepingId;
      v_max_mvt.libId = l_libId;
    END IF;

--    RAISE NOTICE 'Salvestame parandus, (miinus) tululiik-> %, summa -> %', v_max_mvt.tululiik, v_miinus_mvt.mvt;
    l_id = sp_salvesta_palk_oper(0, tnRekvId, v_max_mvt.libId,
                                 v_max_mvt.lepingId, ldKpv, 0, v_leping.Doklausid,
                                 'MVT miinus parandus ' + v_max_mvt.tululiik,
                                 ifnull(v_leping.kood1, space(1)), ifnull(v_leping.kood2, 'LE-P'),
                                 ifnull(v_leping.kood3, space(1)),
                                 ifnull(v_leping.kood4, space(1)), ifnull(v_leping.kood5, space(1)),
                                 ifnull(v_leping.konto, space(1)),
                                 v_leping.tp, v_leping.tunnus, 'EUR', 1, v_leping.proj,
                                 v_max_mvt.tululiik :: INTEGER, -1 * l_uus_tm, 0, 0, 0,
                                 v_miinus_mvt.mvt, 0, NULL :: DATE);

 --   RAISE NOTICE 'Salvestatud parandus, (miinus) tululiik-> %, summa -> %, id -> %', v_max_mvt.tululiik, v_miinus_mvt.mvt, l_id;

  END IF;


  RETURN 0;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
ALTER FUNCTION sp_calc_umardamine( INTEGER, DATE, INTEGER )
OWNER TO vlad;


/*
SELECT sp_calc_umardamine(16159, date(2018, 03, 02), 94);

select gen_palkoper(133396, 289108, 1455, date(2018,05,31), 0, 0)

select * from palk_oper where rekvid = 94 and kpv = date(2018,05,30) and lepingid in (select id from tooleping where parentId = 31259)

select * from asutus where regkood = '46804103710 '
--16159

select * from tooleping where id = 137542
select * from palk_oper where lepingid in (128141) and year(kpv) = 2018 and month(kpv) = 8 and summa = 0
--1184

select * from rekv where regkood = '75024403'

select * from palk_oper where id = 4858367


select * from palk_oper where tulubaas < 0 and year(kpv) = 2018 order by id desc limit 10

select * from palk_oper where id in (4858835, 4858834)

select * from tooleping where id = 133396

select * from asutus where id = 31259
*/