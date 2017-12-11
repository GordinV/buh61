-- Function: sp_calc_arv(integer, integer, date, numeric, date)

DROP FUNCTION IF EXISTS sp_calc_arv( INTEGER, INTEGER, DATE, NUMERIC, DATE );
DROP FUNCTION IF EXISTS sp_calc_arv( INTEGER, INTEGER, DATE, NUMERIC, DATE, INTEGER );

CREATE OR REPLACE FUNCTION sp_calc_arv(tnLepingid INTEGER, tnLibId INTEGER, tdKpv DATE, tnSumma NUMERIC,
                                       tdPeriod   DATE, tnUmardamine INTEGER)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  lnSumma              NUMERIC(18, 8);
  v_palk_kaart         RECORD;
  qrytooleping         RECORD;
  qryPalkLib           RECORD;
  qryTaabel1           RECORD;
  npalk                NUMERIC(20, 10);
  nHours               NUMERIC(20, 10);
  lnRate               NUMERIC(20, 10);
  nSumma               NUMERIC(20, 10);
  lnKuuSumma           NUMERIC(20, 10) = 0;
  lnBaas               NUMERIC(20, 10);
  lnKuurs              NUMERIC(12, 4);

  ltSelgitus           TEXT;
  ltEnter              CHARACTER(20);
  lcTimestamp          VARCHAR(20);

  lTKA                 NUMERIC(14, 4) = 0;
  lTKI                 NUMERIC(14, 4) = 0;
  lTM                  NUMERIC(14, 4) = 0;
  lSM                  NUMERIC(14, 4) = 0;
  lPM                  NUMERIC(14, 4) = 0;

  v_kaart              RECORD;
  l_tulubaas_kokku     NUMERIC(14, 4) = 0;
  l_tulubaas           NUMERIC(14, 4) = 0;
  l_kasutatud_tulubaas NUMERIC(14, 4) = 0;
  l_PM_maar            NUMERIC(8, 2) = 2;
  l_TKI_maar           NUMERIC(8, 2) = 1.6;
  l_TKA_maar           NUMERIC(8, 2) = 0.8;
  l_SM_maar            NUMERIC(8, 2) = 33;
  l_TM_maar            NUMERIC(8, 2) = 20;
  l_min_sots           NUMERIC(14, 4) = 0;
  v_maksud             RECORD;
  l_aasta_alg          DATE = date(year(tdKpv), 01, 01);
BEGIN

  nHours :=0;
  lnSumma := 0;
  nPalk:=0;
  lnBaas :=0;
  lnKuurs = fnc_currentkuurs(tdKpv);

  ltSelgitus = '';
  ltEnter = '
';
  lcTimestamp = left(
      'ARV' + LTRIM(RTRIM(str(tnLepingId))) + LTRIM(RTRIM(str(tnLibId))) + ltrim(rtrim(str(dateasint(tdKpv)))), 20);

  --v_palk_kaart init
  SELECT
    palk_kaart.*,
    ifnull(dokvaluuta1.kuurs, 1) :: NUMERIC AS kuurs
  INTO v_palk_kaart
  FROM palk_kaart
    LEFT OUTER JOIN dokvaluuta1 ON (palk_kaart.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 20)
  WHERE lepingid = tnLepingid AND libId = tnLibId;

  --qryPalkLib init
  SELECT
    pl.*,
    l.muud AS lisa,
    l.tun1,
    l.tun2,
    l.tun3,
    l.tun4,
    l.tun5
  INTO qryPalkLib
  FROM palk_lib pl
    LEFT OUTER JOIN library l ON l.kood = pl.tululiik AND library = 'MAKSUKOOD'
  WHERE pl.parentId = tnLibId;

  --v_leping init
  SELECT
    tooleping.*,
    ifnull(dokvaluuta1.kuurs, 1) :: NUMERIC AS kuurs,
    pc.minpalk
  INTO qryTooleping
  FROM tooleping
    LEFT OUTER JOIN dokvaluuta1 ON (tooleping.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 19)
    LEFT OUTER JOIN palk_config pc ON pc.rekvid = tooleping.rekvid
  WHERE tooleping.id = tnLepingId;

  IF qryTooleping.algab > l_aasta_alg
  THEN
    l_aasta_alg = qryTooleping.algab;
  END IF;

  --check for "umardamine"
  IF tnSumma IS NULL
  THEN
    IF v_palk_kaart.percent_ = 1
    THEN
      -- calc based on taabel
      --		raise notice 'calc based on taabel';
      IF v_palk_kaart.alimentid = 0
      THEN
        --raise notice 'alimentid = 0';

        SELECT *
        INTO qryTaabel1
        FROM palk_taabel1
        WHERE toolepingId = tnlepingId
              AND kuu = month(tdKpv) AND aasta = year(tdKpv);

        IF NOT found
        THEN
          --raise notice 'TAABEL1 NOT FOUND';
          RETURN lnSumma;
        END IF;

        SELECT tund
        INTO nHours
        FROM Toograf
        WHERE lepingid = tnLepingId AND kuu = month(tdKpv) AND aasta = year(tdKpv);
        IF ifnull(nHours, 0) = 0
        THEN
          nHours := (sp_workdays(1, month(tdKpv), year(tdKpv), 31, v_palk_kaart.lepingId) :: NUMERIC(6, 4) *
                     qryTooleping.toopaev) :: INT4;
          ltSelgitus = ltSelgitus + 'Kokku tunnid kuues,:' + ltrim(rtrim(round(nHours, 2) :: VARCHAR)) + ltEnter;

          nHours := nHours - sp_calc_tahtpaevad(qryTooleping.rekvId, month(tdKpv));
          ltSelgitus = ltSelgitus + 'Kokku tunnid kuues, parandatud:' + ltrim(rtrim(round(nHours, 2) :: VARCHAR)) +
                       ltEnter;

        END IF;

        --raise notice 'hOUR %',nHours;
        IF qryTooleping.tasuliik = 1
        THEN
          lnRate := (qryTooleping.palk * qryTooleping.kuurs) / nHours * 0.01 * qryTooleping.koormus;
          --raise notice 'Rate %',lnrate;
          ltSelgitus = ltSelgitus + 'Tunni hind:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + ltEnter;

        END IF;

        IF qryTooleping.tasuliik = 2
        THEN
          lnSumma := f_round((qryTooleping.palk * qryTooleping.kuurs) * qryTaabel1.kokku / lnKuurs, qryPalkLib.round);
          lnRate := qryTooleping.palk * qryTooleping.kuurs;
          ltSelgitus = ltSelgitus + 'arvestus:' + ltrim(rtrim(qryTooleping.palk :: VARCHAR)) + '*' +
                       ltrim(rtrim(qryTooleping.kuurs :: VARCHAR)) + '*' +
                       ltrim(rtrim(round(qryTaabel1.kokku, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR)) +
                       ltEnter;

          -- muudetud 01/02/2005
          IF qryPalkLib.tund = 5
          THEN
            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev / lnKuurs, qryPalkLib.round);
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.tahtpaev, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR))
                         + ltEnter;

          END IF;
          IF qryPalkLib.tund = 6
          THEN
            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev / lnKuurs, qryPalkLib.round);
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.puhapaev, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR))
                         + ltEnter;

          END IF;
          IF qryPalkLib.tund = 7
          THEN
            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo / lnKuurs, qryPalkLib.round);
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.uleajatoo, 3) :: VARCHAR)) + '/' +
                         ltrim(rtrim(lnKuurs :: VARCHAR)) + ltEnter;

          END IF;
          IF qryPalkLib.tund = 3
          THEN
            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu / lnKuurs, qryPalkLib.round);
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(qryTaabel1.ohtu :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR)) + ltEnter;

          END IF;
          IF qryPalkLib.tund = 4
          THEN
            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo / lnKuurs, qryPalkLib.round);
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.oo, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR)) +
                         ltEnter;

          END IF;
          IF qryPalkLib.tund = 2
          THEN
            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev / lnKuurs, qryPalkLib.round);
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.paev, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR)) +
                         ltEnter;

          END IF;

        ELSE

          IF qryPalkLib.tund = 5
          THEN

            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev / lnKuurs, qryPalkLib.round);
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.tahtpaev, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR))
                         + ltEnter;

            lnBaas := qryTaabel1.tahtpaev;

          END IF;

          IF qryPalkLib.tund = 6
          THEN

            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev / lnKuurs, qryPalkLib.round);
            lnBaas := qryTaabel1.puhapaev;
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.puhapaev, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR))
                         + ltEnter;

          END IF;

          IF qryPalkLib.tund = 7
          THEN

            lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo / lnKuurs, qryPalkLib.round);

            lnBaas := qryTaabel1.uleajatoo;
            ltSelgitus = ltSelgitus + 'parandamine:' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                         ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                         ltrim(rtrim(round(qryTaabel1.uleajatoo, 3) :: VARCHAR)) + '/' +
                         ltrim(rtrim(lnKuurs :: VARCHAR)) + ltEnter;


          END IF;

          IF qryPalkLib.tund < 5
          THEN

            IF qryPalkLib.tund = 3
            THEN

              nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu;

              ltSelgitus = ltSelgitus + 'parandamine(nSumma):' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                           ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                           ltrim(rtrim(round(qryTaabel1.ohtu, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR)) +
                           ltEnter;


            END IF;

            IF qryPalkLib.tund = 4
            THEN

              nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo;
              ltSelgitus = ltSelgitus + 'parandamine(nSumma):' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                           ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                           ltrim(rtrim(round(qryTaabel1.oo, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR)) +
                           ltEnter;

            END IF;

            IF qryPalkLib.tund = 2
            THEN

              nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev;
              ltSelgitus = ltSelgitus + 'parandamine(nSumma):' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                           ltrim(rtrim(v_palk_kaart.Summa :: VARCHAR)) + '*0.01*' +
                           ltrim(rtrim(round(qryTaabel1.paev, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR)) +
                           ltEnter;

            END IF;

            IF qryPalkLib.tund = 1
            THEN

              nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.kokku;
              ltSelgitus = ltSelgitus + 'parandamine(nSumma):' + ltrim(rtrim(round(lnRate, 2) :: VARCHAR)) + '*' +
                           ltrim(rtrim(round(v_palk_kaart.Summa, 2) :: VARCHAR)) + '*0.01*' +
                           ltrim(rtrim(round(qryTaabel1.kokku, 3) :: VARCHAR)) + '/' + ltrim(rtrim(lnKuurs :: VARCHAR))
                           + ltEnter;

            END IF;
            lnSumma := lnSumma + f_round(nSumma / lnKuurs, qryPalkLib.round);
            lnBaas := lnBaas + CASE WHEN qryPalkLib.tund = 3
              THEN qryTaabel1.ohtu
                               ELSE
                                 CASE WHEN qryPalkLib.tund = 4
                                   THEN qryTaabel1.oo
                                 ELSE qryTaabel1.paev END END;

          END IF;
        END IF;
      END IF;
    ELSE

      lnSumma := f_round(v_palk_kaart.Summa * v_palk_kaart.kuurs / lnKuurs, qryPalkLib.round);
      ltSelgitus =
      ltSelgitus + ltrim(rtrim(v_palk_kaart.Summa :: VARCHAR)) + '*' + ltrim(rtrim(v_palk_kaart.kuurs :: VARCHAR)) + '/'
      + ltrim(rtrim(lnKuurs :: VARCHAR)) + ltEnter;
      lnBaas := 0;
    END IF;
  ELSE
    ltSelgitus = ltSelgitus + ' Käsi arvestus või ümardamine ' + ltEnter;
    lnSumma = tnSumma;
  END IF;

  -- salvestame arvetuse analuus
  DELETE FROM tmp_viivis
  WHERE alltrim(timestamp) = alltrim(lcTimestamp);
  INSERT INTO tmp_viivis (rekvid, dkpv, timestamp, muud) VALUES (qryTooleping.rekvid, tdKpv, lcTimestamp, ltSelgitus);

  -- TSD 2015
  IF qryPalkLib.tululiik IS NOT NULL
  THEN
    --Tootuskind-lustusmakse-> tun4, Kogumispension -> tun5
    --selecting tax numbers
    SELECT
      sum(sm)  AS sm,
      sum(tki) AS tki,
      sum(tka) AS tka,
      sum(pm)  AS pm
    INTO v_kaart
    FROM (
           SELECT
             CASE WHEN pl.liik = 5
               THEN status
             ELSE 0 END AS sm,
             CASE WHEN pl.liik = 7 AND asutusest = 0
               THEN status
             ELSE 0 END AS tki,
             CASE WHEN pl.liik = 7 AND asutusest = 1
               THEN status
             ELSE 0 END AS tka,
             CASE WHEN pl.liik = 8
               THEN status
             ELSE 0 END AS pm
           FROM palk_kaart pk
             INNER JOIN palk_lib pl ON pl.parentid = pk.libid
           WHERE pk.lepingid = qryTooleping.id
         ) qry;

    --calculating all taxis
    FOR v_maksud IN
    SELECT
      pk.summa,
      pk.tulumaks,
      pl.liik,
      pl.asutusest,
      pk.minsots
    FROM palk_kaart pk
      INNER JOIN palk_lib pl ON pl.parentId = pk.libid
    WHERE pk.status = 1
          AND pk.lepingId = qryTooleping.id
          AND pl.liik IN (5, 7, 8)
    LOOP
      IF v_maksud.liik = 5
      THEN
        -- SM
        l_SM_maar = v_maksud.summa;
        l_min_sots = coalesce(v_maksud.minsots, 0);
      ELSIF v_maksud.liik = 7 AND v_maksud.asutusest = 0
        THEN
          -- TKI
          l_TKI_maar = v_maksud.summa;
      ELSIF v_maksud.liik = 7 AND v_maksud.asutusest = 1
        THEN
          -- TKA
          l_TKA_maar = v_maksud.summa;
      ELSIF v_maksud.liik = 8
        THEN
          -- PM
          l_PM_maar = v_maksud.summa;
      ELSE
      -- null
      END IF;
    END LOOP;
    l_TM_maar = qryPalkLib.tun1;

    -- kui period on eelmine aasta siis kasutame eelmise aasta maksumaarad
    IF tdPeriod IS NOT NULL AND year(tdPeriod) < year(tdKpv)
    THEN
      l_TKI_maar = 2;
      l_TKA_maar = 1;
      l_TM_maar = 21;
    END IF;

    lTKI = round(lnSumma * 0.01 * l_TKI_maar * qryPalkLib.tun4 * coalesce(CASE WHEN v_kaart.tki > 0
      THEN 1
                                                                          ELSE 0 END, 0), 2);

    ltSelgitus = ltSelgitus + 'TKI arvestus:' + round(lnSumma, 2) :: TEXT + '*' + (0.01 * l_TKI_maar) :: TEXT + '*' +
                 qryPalkLib.tun4 :: TEXT + ltEnter;

    lPM = round(lnSumma * 0.01 * l_PM_maar * qryPalkLib.tun5 * coalesce(CASE WHEN v_kaart.pm > 0
      THEN 1
                                                                        ELSE 0 END, 0), 2);
    ltSelgitus = ltSelgitus + 'PM arvestus:' + round(lnSumma, 2) :: TEXT + '*' + (0.01 * l_PM_maar) :: TEXT + '*' +
                 qryPalkLib.tun5 :: TEXT + ltEnter;
    /*
      if lnSumma < qryTooleping.minpalk * l_min_sots then
        ltSelgitus = ltSelgitus + 'SM kasutame min.palk ' + qryTooleping.minpalk::text + ltEnter;
      end if;
    */
    --	raise notice 'lnSumma %, l_SM_maar %, qryPalkLib.tun2 %, v_kaart.sm %', lnSumma, l_SM_maar, qryPalkLib.tun2, v_kaart.sm ;
    lSM = round(lnSumma * 0.01 * l_SM_maar * qryPalkLib.tun2 * coalesce(CASE WHEN v_kaart.sm > 0
      THEN 1
                                                                        ELSE 0 END, 0), 2);

    --lSM = (case when lnSumma < qryTooleping.minpalk * l_min_sots then qryTooleping.minpalk else lnSumma end) * 0.01 * l_SM_maar * qryPalkLib.tun2 * coalesce(case when v_kaart.sm > 0 then 1 else 0 end,0);

    ltSelgitus = ltSelgitus + 'SM arvestus: ' + (CASE WHEN lnSumma < qryTooleping.minpalk * l_min_sots
      THEN qryTooleping.minpalk
                                                 ELSE round(lnSumma, 2) END) :: TEXT +
                 '*' + (0.01 * l_SM_maar) :: TEXT + '*' + qryPalkLib.tun2 :: TEXT + ltEnter;


    lTKA = round(lnSumma * 0.01 * l_TKA_maar * qryPalkLib.tun4 * coalesce(CASE WHEN v_kaart.tka > 0
      THEN 1
                                                                          ELSE 0 END, 0), 2);
    --	lSM = (case when lnSumma < qryTooleping.minpalk * l_min_sots then qryTooleping.minpalk else lnSumma end) * 0.01 * l_SM_maar * qryPalkLib.tun2 * coalesce(case when v_kaart.sm > 0 then 1 else 0 end,0);

    ltSelgitus = ltSelgitus + 'TKA arvestus:' + round(lnSumma, 2) :: TEXT +
                 '*' + (0.01 * l_TKA_maar) :: TEXT + '*' + qryPalkLib.tun4 :: TEXT + ltEnter;


    IF year(tdKpv) < 2018
    THEN
      RAISE NOTICE '2017 arvestus';
      IF qryTooleping.pohikoht = 1
      THEN

        IF year(tdKpv) >= 2015
        THEN
          l_tulubaas_kokku = (SELECT month(tdKpv) - month(l_aasta_alg) + 1) *
                             (SELECT coalesce(tulubaas, 154)
                              FROM palk_config
                              WHERE rekvid = qryTooleping.rekvid
                              LIMIT 1);
        ELSE
          l_tulubaas_kokku = (144 * 11) + (SELECT coalesce(tulubaas, 154)
                                           FROM palk_config
                                           WHERE rekvid = qryTooleping.rekvid
                                           LIMIT 1);
        END IF;

        -- kasutatud tulubaas
        -- should be only for tululiik we calculate (if umardamine)
        SELECT sum(tulubaas) AS tulubaas
        INTO l_kasutatud_tulubaas
        FROM palk_oper po
          INNER JOIN tooleping t ON po.lepingid = t.id
        WHERE tulubaas IS NOT NULL
              AND tulubaas > 0
              AND kpv >= date(year(tdKpv), month(l_aasta_alg), 01) AND kpv <= tdKpv
              AND po.id NOT IN (SELECT id
                                FROM palk_oper
                                WHERE libId = tnLibId AND lepingId = tnLepingId AND kpv = tdKpv)
              AND po.libId IN (SELECT l.Id
                               FROM library l INNER JOIN palk_lib pl ON l.id = pl.parentId
                               WHERE rekvId = qryTooleping.rekvId AND pl.liik = 1)
              AND t.parentid = qryTooleping.parentid;

        IF year(tdKpv) < 2015
        THEN
          SELECT sum(g31)
          INTO l_tulubaas
          FROM palk_jaak
          WHERE lepingid IN (SELECT id
                             FROM tooleping
                             WHERE rekvid = qryTooleping.rekvid AND parentId = qryTooleping.parentId)
                AND kuu >= 1 AND kuu < month(tdKpv) AND aasta = year(tdKpv);

          l_kasutatud_tulubaas = coalesce(l_kasutatud_tulubaas, 0) + coalesce(l_tulubaas, 0);
        END IF;

        --			raise notice 'l_tulubaas_kokku %, l_kasutatud_tulubaas %, l_aasta_alg %', l_tulubaas_kokku, l_kasutatud_tulubaas, l_aasta_alg;

        -- periodi kogus
        --			raise notice 'tulubaasi kasutamine lnSumma %, tnSumma %', lnSumma, tnSumma;
        IF tnSumma IS NULL OR lnSumma != tnSumma
        THEN
          l_tulubaas = coalesce(l_tulubaas_kokku, 0) - coalesce(l_kasutatud_tulubaas, 0);
        ELSE
          SELECT sum(tulubaas)
          INTO l_tulubaas
          FROM palk_oper po
          WHERE po.lepingid IN (SELECT id
                                FROM tooleping
                                WHERE parentId = qryTooleping.parentid AND rekvId = qryTooleping.rekvId)
                AND kpv = tdKpv
                AND libId IN
                    (
                      SELECT l.id
                      FROM library l
                        INNER JOIN palk_lib pl ON l.id = pl.parentId
                      WHERE l.rekvId = qryTooleping.rekvId
                            AND pl.tululiik = qryPalkLib.tululiik
                            AND pl.liik = qryPalkLib.liik
                    );

          l_tulubaas = coalesce(l_tulubaas, 0);
          ltSelgitus = ltSelgitus + ' kasutame enne arvestatud kasutatud tulubaas ' + ltEnter;
        END IF;
      END IF;
    ELSE
      --	raise notice 'Tulubaas 2018 arvestus';
      -- TM 2018 arvestus
      l_tulubaas_kokku = coalesce((SELECT sum(summa)
                                   FROM taotlus_mvt mvt
                                     INNER JOIN tooleping t ON t.id = mvt.lepingId
                                   WHERE t.parentId = qryTooleping.parentId
                                         AND alg_kpv <= tdKpv
                                         AND lopp_kpv >= tdKpv), 0);
      -- 1.  arvestus
      -- arvestame kasutatud MVT

      l_kasutatud_tulubaas = (SELECT sum(po.tulubaas)
                              FROM palk_oper po
                                INNER JOIN tooleping t ON t.id = po.lepingId
                                INNER JOIN palk_lib pl ON pl.parentId = po.libId
                              WHERE t.parentid = qryTooleping.parentId
                                    AND pl.liik = 1
                                    AND (tnSumma IS NULL OR pl.tululiik = qryPalkLib.tululiik)
                                    -- calculate only 1 tululiik
                                    AND year(po.kpv) = year(tdKpv) AND month(po.kpv) = month(tdKpv)
                                    AND (tnSumma IS NOT NULL OR po.id NOT IN (SELECT id
                                                                              FROM palk_oper
                                                                              WHERE
                                                                                kpv = tdKpv
                                                                                AND lepingid = tnLepingid
                                                                                AND libid = tnLibId))
      );

      RAISE NOTICE 'l_kasutatud_tulubaas -> %', l_kasutatud_tulubaas;

      -- arvestame kuu tulud

      IF coalesce(tnSumma, 0) = 0
      THEN
        SELECT sum(po.summa)
        INTO lnKuuSumma
        FROM palk_oper po
          INNER JOIN tooleping t ON t.id = po.lepingId
          INNER JOIN palk_lib pl ON pl.parentId = po.libId
        WHERE t.parentid = qryTooleping.parentId
              AND pl.liik = 1
              AND year(po.kpv) = year(tdKpv) AND month(po.kpv) = month(tdKpv)
              --            AND po.rekvId = qryTooleping.rekvId --Arvestame koik tulud seles kuu
              AND (tnSumma IS NOT NULL OR po.id NOT IN (SELECT id
                                                        FROM palk_oper
                                                        WHERE kpv = tdKpv AND lepingid = tnLepingid AND
                                                              libid =
                                                              tnLibId)); -- kui parandus siis v]ttame koik summad

        lnKuuSumma = coalesce(lnKuuSumma, 0) + (lnSumma - coalesce(tnSumma, 0));
      ELSE
        lnKuuSumma = tnSumma; --if umardamine then do not neccessory calculate kuu summa
      END IF;
      -- 2 kasutatud mvt


      l_tulubaas = calc_mvt(lnKuuSumma, l_tulubaas_kokku, tdkpv);

      RAISE NOTICE 'Tulubaas arvestus l_tulubaas ->>> %, lnKuuSumma %, l_tulubaas_kokku % ', l_tulubaas, lnKuuSumma, l_tulubaas_kokku;

      -- 3. parandus

      IF coalesce(tnUmardamine, 0) = 0
      THEN
        -- ei ole umardamine
        l_tulubaas = coalesce(l_tulubaas, 0) - coalesce(l_kasutatud_tulubaas, 0);
      END IF;

      IF l_tulubaas > lnSumma
      THEN
        l_tulubaas = lnSumma - lTKI - lPM;
      END IF;

      IF coalesce(tnUmardamine, 0) = 0 AND (l_kasutatud_tulubaas + l_tulubaas) > lnKuuSumma
      THEN
        -- liga palju
        l_tulubaas = (l_kasutatud_tulubaas + l_tulubaas) - lnKuuSumma;
      END IF;

    END IF;

    IF l_tulubaas < 0 AND (qryPalkLib.lisa IS NULL AND year(tdKpv) < 2018)
    THEN
      l_tulubaas = 0;
    END IF;

    IF lnSumma > 0
    THEN
      lTM = (lnSumma - lTKI - lPM);
    ELSE
      lTM = lnSumma;
    END IF;

    IF lTM > l_Tulubaas AND lTM > 0
    THEN
      lTM = lTM - l_tulubaas;
    ELSE
      l_tulubaas = CASE WHEN lTM > 0
        THEN lTM
                   ELSE 0 END;
      lTM = 0; -- parandus 28.10.2015 sest votab arvestus 1 euriost
    END IF;
    lTM = round(lTM * 0.01 * l_TM_maar, 2);

    ltSelgitus = ltSelgitus + 'TM arvestus:(' + round(lnSumma, 2) :: TEXT +
                 '-' + (CASE WHEN lTKI > 0
      THEN lTKI
                        ELSE 0 END) :: TEXT +
                 '-' + (CASE WHEN lPM > 0
      THEN lPM
                        ELSE 0 END) :: TEXT +
                 '-' + l_tulubaas :: TEXT + ') * ' + (0.01 * l_TM_maar) :: TEXT + ltEnter;

    -- tulumaks (tmp_viivis.volg1)
    --	if qryPalkLib.tun1 > 0 then
    UPDATE tmp_viivis
    SET volg1 = lTM,
      paev1   = CASE WHEN qryPalkLib.tululiik = ''
        THEN '0'
                ELSE qryPalkLib.tululiik END :: INTEGER,
      tasun1  = coalesce(l_Tulubaas, 0),
      volg2   = lSM,
      volg4   = lTKI,
      volg5   = lPM,
      volg6   = lTKA,
      muud    = ltSelgitus
    WHERE alltrim(timestamp) = alltrim(lcTimestamp);
    --	end if;
  END IF;

  RETURN lnSumma;

END;

$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
GRANT EXECUTE ON FUNCTION sp_calc_arv(INTEGER, INTEGER, DATE, NUMERIC, DATE, INTEGER) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_arv(INTEGER, INTEGER, DATE, NUMERIC, DATE, INTEGER) TO dbpeakasutaja;
COMMENT ON FUNCTION sp_calc_arv(INTEGER, INTEGER, DATE, NUMERIC, DATE,
                                INTEGER) IS 'Muudetud 01/02/2005 lisatud ohtu-uletoo tunni alusel tootajad';


/*
SELECT sp_calc_umardamine(27011, date(2018, 01, 31), 106);

select sp_calc_arv(136328, 585436, date(2018,01,31), null, null, 1);


select * from asutus where regkood = '37808283716'
-- 17892

select * from rekv where regkood = '75024283';

select * from tooleping where parentid = 31444
and rekvid = 72

select * from palk_oper where lepingid = 136328 and year(kpv) = 2018 and rekvid = 125


delete from palk_jaak WHERE lepingid in (select id FROM tooleping WHERE rekvid = 106 AND parentid = 25515) and aasta = 2018 and kuu = 10

DELETE FROM palk_oper WHERE lepingid in (select id FROM tooleping WHERE rekvid = 106 AND parentid = 25515) AND kpv = date(2018,10,05)

select sum(po.summa) from palk_oper po where lepingid in (select id from tooleping where parentId = 25515 and id = 134258) and kpv = date(2018,02,28) and tka > 0 

delete from palk_oper where lepingid in (select id from tooleping where parentId = 25515) and kpv = date(2018,02,28) 

select * from palk_jaak where lepingid in (select id from tooleping where parentId = 22013)  and aasta = 2018

select * from curpalkjaak where regkood = '38403123743' and aasta = 2018 and kuu = 1

				select pk.id, pk.parentid, pk.lepingid, pk.libid, pk.summa
							 FROM Library l
							 inner join Palk_kaart  pk on pk.libId = l.id
							 inner join   Palk_lib pl on pl.parentId = l.id
							 inner join tooleping t on pk.lepingId = t.id
							 left outer join dokvaluuta1 on (pk.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20)
							 where pk.parentid = ?tnId
							 and t.rekvid = ?gRekv
							 and pk.status = 1
							 and not EMPTY(pk.summa)
							 and t.algab <= ?gdKpv
							 and (t.lopp is null or t.lopp >= ?gdKpv)
							 and (?lcOsakonnad = ''  or and t.osakondid  in ?lcOsakonnad)
							 order by liik, case when empty(pl.tululiik) then 99::text else tululiik end, Pk.percent_ desc, pk.summa desc

*/