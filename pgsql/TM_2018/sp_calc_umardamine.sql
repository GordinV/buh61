-- Function: sp_calc_umardamine(integer, date, integer)

-- DROP FUNCTION sp_calc_umardamine(integer, date, integer);

CREATE OR REPLACE FUNCTION sp_calc_umardamine(tnisikid integer, tdkpv date, tnrekvid integer)
  RETURNS numeric AS
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
  l_mvt_fakt numeric(14,2) = 0;
  l_pm_kokku       NUMERIC(14, 4) = 0;
  l_tk_kokku       NUMERIC(14, 4) = 0;
  l_tm_kokku       NUMERIC(14, 4) = 0;
  l_tulu_kokku     NUMERIC(14, 4) = 0;
  l_mvt_diff       NUMERIC(14, 4) = 0;
  l_id             INTEGER;

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
        AND po.kpv = tdKpv
        AND po.rekvId = tnRekvId
        AND po.summa = 0;

  -- arvestame, loop for each tululiik
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

        lcTimestamp = left('ARV' + LTRIM(RTRIM(str(v_leping.LepingId))) + LTRIM(RTRIM(str(v_leping.LibId))) +
                           ltrim(rtrim(str(dateasint(tdKpv)))), 20);

      IF v_leping.lepingId IS NULL
      THEN
        RETURN 0;
      END IF;

      -- 

      --calculate full summa for this tululiik
      --raise notice 'start arv for summa-> %, lcTimestamp -> %, v_leping.LepingId -> %, v_leping.libId %',v_tululiik.summa, lcTimestamp, v_leping.LepingId, v_leping.libId;
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

      raise notice 'got arvestus -> %',v_arv.tm;

-- get fact summa done before
      SELECT
        sum(tulubaas)  AS mvt
      INTO l_mvt_fakt
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
            AND pl.liik = 1;
--            AND pl.tululiik = v_tululiik.tululiik;


      SELECT
        sum(summa)     AS arv,
        sum(tulumaks)  AS tm,
        sum(sotsmaks)  AS sm,
        sum(tootumaks) AS tki,
        sum(pensmaks)  AS pm,
        sum(tka)       AS tka,
        sum(tulumaks)  AS tm
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


      -- check if we need to round taxes
      IF v_arv.tm - round(v_fakt_arv.tm, 2) <> 0 OR
         v_arv.sm - round(v_fakt_arv.sm, 2) <> 0 OR
         v_arv.tki - round(v_fakt_arv.tki, 2) <> 0 OR
         v_arv.tka - round(v_fakt_arv.tka, 2) <> 0 OR
         v_arv.pm - round(v_fakt_arv.pm, 2) <> 0
      THEN
        --saving diff

        l_id = sp_salvesta_palk_oper(0, tnRekvId, v_leping.libId, v_leping.lepingId, tdKpv, 0, v_leping.Doklausid,
                                     'Ćmardamine' + v_arv.muud,
                                     ifnull(v_leping.kood1, space(1)), ifnull(v_leping.kood2, 'LE-P'),
                                     ifnull(v_leping.kood3, space(1)),
                                     ifnull(v_leping.kood4, space(1)), ifnull(v_leping.kood5, space(1)),
                                     ifnull(v_leping.konto, space(1)),
                                     v_leping.tp, v_leping.tunnus, 'EUR', 1, v_leping.proj,
                                     v_tululiik.tululiik :: INTEGER, ifnull(v_arv.tm - round(v_fakt_arv.tm, 2), 0),
                                     ifnull(v_arv.sm - round(v_fakt_arv.sm, 2), 0),
                                     ifnull(v_arv.tki - round(v_fakt_arv.tki, 2), 0),
                                     ifnull(v_arv.pm - round(v_fakt_arv.pm, 2), 0),
                                     v_arv.mvt, coalesce(v_arv.tka - round(v_fakt_arv.tka, 2), 0), NULL :: DATE);
/*
        -- if mvt was not used in full permited
        IF l_mvt_fakt > 0 and l_mvt_fakt < l_tulubaas and v_fakt_arv.arv <  l_tulubaas
        THEN
         --raise notice 'select used MVT in period for isik in all departments';
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

          -- get mvt diff from palk_oper
          l_mvt_diff = coalesce(l_mvt_kokku, 0) - (coalesce(l_tulu_kokku, 0) -
                                                   (coalesce(l_tm_kokku, 0) + coalesce(l_tk_kokku, 0) +
                                                    coalesce(l_pm_kokku, 0)));
                                                    
                                                    
	--raise notice 'l_mvt_diff %, l_mvt_kokku -> %, l_tulu_kokku -> %, l_tm_kokku -> %, l_tk_kokku -> %, l_pm_kokku -> %, l_mvt_fakt -> %',l_mvt_diff, l_mvt_kokku, l_tulu_kokku, l_tm_kokku, l_tk_kokku, l_pm_kokku, l_mvt_fakt;
          -- if diff is bigger than 0< then saving mvt diff
          IF l_mvt_diff <> 0 and (l_mvt_diff < l_tulubaas - l_mvt_fakt)
          THEN
            UPDATE palk_oper
            SET Tulubaas = Tulubaas - l_mvt_diff
            WHERE id = l_id;
          END IF;
        END IF;
        */
      END IF;

    END IF; -- arv count peaks rohkem kui 1

  END LOOP;

  RETURN 0;
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_umardamine(integer, date, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_umardamine(integer, date, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_umardamine(integer, date, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_umardamine(integer, date, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_umardamine(integer, date, integer) TO dbpeakasutaja;

--	select sp_calc_umardamine_(37118, '2018-02-28', 121)


/*
select * from asutus where regkood  = '48607053730'

select sp_calc_umardamine_(33302, date(2018,02,27), 64)
*/


