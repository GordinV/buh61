-- Function: gen_palkoper(integer, integer, integer, date, integer, integer)

DROP FUNCTION IF EXISTS gen_palkoper( INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER );

CREATE OR REPLACE FUNCTION gen_palkoper(tnlepingid INTEGER, tnlibid INTEGER, tndoklausid INTEGER, tdkpv DATE,
                                        tnavans    INTEGER, tnminpalk INTEGER)
  RETURNS INTEGER AS
$BODY$
DECLARE
  l_sotsmaks_min_palk NUMERIC [];
  qrypalklib          RECORD;
  v_klassiflib        RECORD;
  v_palk_kaart        RECORD;
  v_dokprop           RECORD;
  lnAsutusest         INT;
  lnSumma             NUMERIC(12, 4) = 0;
  lcTunnus            VARCHAR = space(1);
  lnPalkOperId        INT;
  lcTp                VARCHAR = '800699';
  v_valuuta           RECORD;
  lnRekvId            INTEGER;
  lnParentId          INTEGER;
  l_pohikoht          INTEGER = 0;

  lcPref              VARCHAR;
  lcTimestamp         VARCHAR;
  v_palk_selg         RECORD;
  l_last_paev         DATE = (date(year(tdKpv), month(tdKpv), 1) + INTERVAL '1 month') :: DATE - 1;

  l_sotsmaks_min_id   INTEGER = 0;
  l_lepingId_min_sots INTEGER;
  l_libId_min_sots    INTEGER;


BEGIN
  lcPref = '';

  SELECT
    rekvid,
    parentId,
    pohikoht
  INTO lnrekvid, lnParentId, l_pohikoht
  FROM tooleping
  WHERE id = tnLepingId;

  SELECT
    Library.kood,
    ifnull((SELECT valuuta1.kuurs
            FROM valuuta1
            WHERE parentid = library.id
            ORDER BY Library.id DESC
            LIMIT 1), 0) AS kuurs
  INTO v_valuuta
  FROM Library
  WHERE library = 'VALUUTA' AND library.tun1 = 1;

  -- v_klassiflib init
  SELECT *
  INTO v_klassiflib
  FROM klassiflib
  WHERE libId = tnLibId
  ORDER BY id DESC
  LIMIT 1;

  -- v_palk_kaart init
  SELECT *
  INTO v_palk_kaart
  FROM palk_kaart
  WHERE libId = tnLibId AND lepingId = tnLepingId;

  -- qrypalklib init
  SELECT
    palk_lib.*,
    library.rekvId
  INTO qrypalklib
  FROM palk_lib
    INNER JOIN library ON library.id = palk_lib.parentid
  WHERE palk_lib.parentid = tnLibId;

  --v_dokprop init
  SELECT *
  INTO v_dokprop
  FROM dokprop
  WHERE id = tnDokLausId;

  --delete old calculations
  IF qryPalkLib.liik = 1 AND (SELECT count(id)
                              FROM palk_oper
                              WHERE kpv = tdKpv AND lepingId = tnLepingid AND libId = tnLibId AND period IS NOT NULL AND
                                    period <> tdKpv) > 0
  THEN
    --ei saa arvestada sest on parandusi
    RETURN 0;
  ELSE
    DELETE FROM journal
    WHERE id IN (SELECT journalId
                 FROM palk_oper
                 WHERE lepingid = tnLepingId AND libId = tnLibId AND kpv = tdKpv);
    DELETE FROM palk_oper
    WHERE lepingid = tnLepingId AND libId = tnLibId AND kpv = tdKpv AND summa <> 0;

  END IF;

  --calculation

  IF qryPalkLib.liik = 1
  THEN
    lnSumma = sp_calc_arv(tnLepingId, tnLibId, tdKpv, NULL, NULL, 0);
    lcPref = 'ARV';
  ELSEIF qryPalkLib.liik = 2
    THEN
      lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
  ELSEIF qryPalkLib.liik = 3
    THEN
      lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
  ELSEIF qryPalkLib.liik = 4
    THEN
      lnSumma := sp_calc_tulumaks(tnLepingId, tnLibId, tdKpv);
      lcTp := '014001';
      IF v_dokprop.asutusid > 0
      THEN
        SELECT tp
        INTO lcTp
        FROM asutus
        WHERE id = v_dokprop.asutusId;
      END IF;
      lcPref = 'TM';
  ELSEIF qryPalkLib.liik = 5
    THEN
      lcPref = 'SOTS';
      lnSumma := sp_calc_sots(tnLepingId, tnLibId, tdKpv);
      lcTp := '014001';
      IF v_dokprop.asutusid > 0
      THEN
        SELECT tp
        INTO lcTp
        FROM asutus
        WHERE id = v_dokprop.asutusId;
      END IF;
  ELSEIF qryPalkLib.liik = 6
    THEN
      lnSumma := sp_calc_tasu(tnLepingId, tnLibId, tdKpv);
  ELSEIF qryPalkLib.liik = 7
    THEN
      lcPref = 'TK';
      IF lnAsutusest < 1
      THEN
        lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
      ELSE
        lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
      END IF;
      lcTp := '014001';
      IF v_dokprop.asutusid > 0
      THEN
        SELECT tp
        INTO lcTp
        FROM asutus
        WHERE id = v_dokprop.asutusId;
      END IF;
  ELSEIF qryPalkLib.liik = 8
    THEN
      lcPref = 'PM';
      lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
  ELSE
    lnSumma = 0;
  END IF;


  IF coalesce(lnSumma, 0) <> 0 OR qryPalkLib.liik = 5
  THEN

    lnSumma = coalesce(lnSumma, 0);

    --find tunnus
    IF v_klassiflib.tunnusid > 0 AND empty(v_palk_kaart.tunnusid)
    THEN
      SELECT kood
      INTO lcTunnus
      FROM library
      WHERE id = v_klassiflib.tunnusId;
    END IF;

    IF v_palk_kaart.tunnusid > 0
    THEN
      SELECT kood
      INTO lcTunnus
      FROM library
      WHERE id = v_palk_kaart.tunnusId;
    END IF;

    lcTunnus = coalesce(lcTunnus, space(1));

    lcTimestamp = left(
        lcPref + LTRIM(RTRIM(str(tnLepingId))) + LTRIM(RTRIM(str(tnLibId))) + ltrim(rtrim(str(dateasint(tdKpv)))), 20);

    --get calculation details
    SELECT
      muud :: VARCHAR AS selg,
      volg1           AS tm,
      tasun1          AS tulubaas,
      volg2           AS sm,
      volg4           AS tki,
      volg5           AS pm,
      volg6           AS tka
    INTO v_palk_selg
    FROM tmp_viivis
    WHERE timestamp = lcTimestamp
    ORDER BY oid DESC
    LIMIT 1;


    IF qrypalklib.tululiik = ''
    THEN
      qrypalklib.tululiik = '0';
    END IF;

    --save palk_oper
    IF lnSumma <> 0
    THEN
      lnPalkOperId = sp_salvesta_palk_oper(0, lnRekvid, tnLibId, tnlepingid, tdKpv, lnSumma, tnDoklausid,
                                           v_palk_selg.selg,
                                           ifnull(v_klassiflib.kood1, space(1)), ifnull(v_klassiflib.kood2, 'LE-P'),
                                           ifnull(v_klassiflib.kood3, space(1)),
                                           ifnull(v_klassiflib.kood4, space(1)), ifnull(v_klassiflib.kood5, space(1)),
                                           ifnull(v_klassiflib.konto, space(1)),
                                           lcTp, lcTunnus, v_valuuta.kood, v_valuuta.kuurs, v_klassiflib.proj,
                                           qrypalklib.tululiik :: INTEGER, ifnull(v_palk_selg.tm, 0),
                                           ifnull(v_palk_selg.sm, 0), ifnull(v_palk_selg.tki, 0),
                                           ifnull(v_palk_selg.pm, 0),
                                           ifnull(v_palk_selg.tulubaas, 0), coalesce(v_palk_selg.tka, 0), NULL :: DATE);

      --clean calc details
      DELETE FROM tmp_viivis
      WHERE rekvid = lnRekvid AND timestamp = lcTimestamp;


    END IF;

    --if calculation of sots.maks, will check sor min.sotsmaks
    IF qryPalkLib.liik = 5 AND NOT empty(tnMinPalk) AND (SELECT count(pk.id)
                                                         FROM palk_kaart pk
                                                           INNER JOIN palk_lib pl ON pl.parentid = pk.libId
                                                         WHERE pk.lepingid IN (SELECT id
                                                                               FROM tooleping
                                                                               WHERE
                                                                                 parentid = lnParentId AND pohikoht = 1
                                                                                 OR id = tnLepingid)
                                                               AND pl.liik = 5
                                                               AND coalesce(pk.minsots, 0) = 1) > 0 AND l_pohikoht = 1
    THEN

      SELECT
        po.id,
        po.libid,
        po.lepingId
      INTO l_sotsmaks_min_id, l_lepingId_min_sots, l_libId_min_sots
      FROM palk_oper po
      WHERE lepingid IN (SELECT id
                         FROM tooleping
                         WHERE parentid = lnParentId AND pohikoht = 1 AND rekvid = lnrekvid)
            AND kpv = l_last_paev
            AND libId = tnLibId
            AND id <> lnPalkOperId
            AND po.sotsmaks <> 0
      LIMIT 1;

      -- arvestame sotsmaks minpalgast
      l_sotsmaks_min_palk = sp_calc_min_sots(tnLepingid, l_last_paev);

      -- if min.sotsmaks, then save
      IF l_sotsmaks_min_palk IS NOT NULL
      THEN

        l_sotsmaks_min_id = sp_salvesta_palk_oper(coalesce(l_sotsmaks_min_id, 0), lnRekvid,
                                                  coalesce(l_libId_min_sots, tnLibId),
                                                  coalesce(l_lepingId_min_sots, tnlepingid), l_last_paev,
                                                  l_sotsmaks_min_palk [1], tnDoklausid,
                                                  ('SM min. palgast -> ' + ifnull(l_sotsmaks_min_palk [1], 0) :: TEXT +
                                                   ' SM summast -> ' + ifnull(l_sotsmaks_min_palk [2], 0) :: TEXT),
                                                  ifnull(v_klassiflib.kood1, space(1)),
                                                  ifnull(v_klassiflib.kood2, 'LE-P'),
                                                  ifnull(v_klassiflib.kood3, space(1)),
                                                  ifnull(v_klassiflib.kood4, space(1)),
                                                  ifnull(v_klassiflib.kood5, space(1)),
                                                  ifnull(v_klassiflib.konto, space(1)),
                                                  lcTp, lcTunnus, v_valuuta.kood, v_valuuta.kuurs, v_klassiflib.proj,
                                                  qrypalklib.tululiik :: INTEGER, 0, ifnull(l_sotsmaks_min_palk [2], 0),
                                                  0, 0,
                                                  0, 0, NULL :: DATE);
      ELSE
        IF coalesce(l_sotsmaks_min_id, 0) > 0
        THEN
          -- kustuta vana arvestus
          PERFORM sp_del_palk_oper(l_sotsmaks_min_id, 1);
        END IF;

      END IF;
    END IF;

    --		lisatud 31/12/2004
    IF tnAvans > 0 AND qryPalkLib.liik = 6
    THEN
      PERFORM sp_calc_avansimaksed(lnpalkOperId);
    END IF;

    -- umardamine
    IF qryPalkLib.liik = 1 AND lnSumma <> 0
       AND -- tulud rohkem kui 1
       (
         SELECT count(palk_oper.id)
         FROM palk_oper
         WHERE lepingId IN (SELECT id
                            FROM tooleping
                            WHERE parentId = lnParentId
         )
               AND rekvId = lnrekvid
               AND summa <> 0
               AND libId IN (SELECT l.id
                             FROM library l
                               INNER JOIN palk_lib pl
                                 ON pl.parentId = l.id AND pl.liik = 1)
               AND year(kpv) = year(tdKpv) AND month(kpv) = month(tdKpv)
       ) > 1


    THEN
      -- umardamine
      PERFORM sp_calc_umardamine(lnParentId, tdKpv, lnrekvid);
    END IF;

    /*-- miinus mvt check
    IF qryPalkLib.liik = 1 AND lnSumma <> 0 AND (SELECT count(id)
                                                 FROM palk_oper
                                                 WHERE lepingId IN (SELECT id
                                                                    FROM tooleping
                                                                    WHERE parentId = lnParentId
                                                 )
                                                       AND rekvId = lnrekvid
                                                       AND summa <> 0
                                                       AND year(kpv) = year(tdKpv) AND month(kpv) = month(tdKpv)
                                                       AND tulubaas < 0) > 0
    THEN
      PERFORM sp_paranda_mvt_miinus(lnParentId, lnrekvid, tdKpv);
    END IF;
*/

  END IF;
  RETURN lnpalkOperId;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;

GRANT EXECUTE ON FUNCTION gen_palkoper(INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_palkoper(INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER) TO dbpeakasutaja;


/*

SELECT gen_palkoper(128178, pk.libid, 1530, DATE(2018, 1, 31), 0, 1)
  from palk_kaart pk
  inner join palk_lib pl on pl.parentid = pk.libid
   where lepingid = 128178 and status = 1
  order by pl.liik, case when empty(pl.tululiik) then 99::text else tululiik end



* from palk_kaart where lepingid = 128178 and status = 1

select * from library where id = 569970

select * from palk_oper where tulubaas > 0 order by id desc limit 10

tnlepingid INTEGER, tnlibid INTEGER, tndoklausid INTEGER, tdkpv DATE,
                                        tnavans    INTEGER, tnminpalk INTEGER

 */