
CREATE OR REPLACE FUNCTION sp_calc_arv(tnlepingid integer, tnlibid integer, tdkpv date, tnsumma numeric, tdperiod date, tnumardamine integer)
  RETURNS numeric AS
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
  l_tulubaas_lisa	numeric(14,4) = 0;
  l_kasutatud_tulubaas NUMERIC(14, 4) = 0; --tululiigi kasutatud mvt kuues
  l_isiku_tulubaas     NUMERIC(14, 4) = 0; --isik kasutatud mvt kuues
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
    IF tdPeriod IS NOT NULL AND year(tdPeriod) < 2017
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

	--raise notice ' SM arvestus lnSumma %, lnSumma * 0.01 * l_SM_maar * qryPalkLib.tun2 %, round -> %',lnSumma, (lnSumma * 0.01 * l_SM_maar * qryPalkLib.tun2), round(lnSumma * 0.01 * l_SM_maar * qryPalkLib.tun2, 2);

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


      --	raise notice 'Tulubaas 2018 arvestus';
      -- TM 2018 arvestus
      l_tulubaas_kokku = coalesce((SELECT sum(summa)
                                   FROM taotlus_mvt mvt
                                     INNER JOIN tooleping t ON t.id = mvt.lepingId
                                   WHERE t.parentId = qryTooleping.parentId
                                   and t.rekvid = qryTooleping.rekvid
                                         AND alg_kpv <= tdKpv
                                         AND lopp_kpv >= tdKpv), 0);
      -- 1.  arvestus
      -- arvestame kasutatud MVT

      l_kasutatud_tulubaas = (SELECT sum(po.tulubaas)
                              FROM palk_oper po
                                INNER JOIN tooleping t ON t.id = po.lepingId
                                INNER JOIN palk_lib pl ON pl.parentId = po.libId
                              WHERE t.parentid = qryTooleping.parentId
				    and t.rekvid = qryTooleping.rekvid
                                    AND po.period IS NULL
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

-- isiku kokku kasutatud mvt
      l_isiku_tulubaas = (SELECT sum(po.tulubaas)
                              FROM palk_oper po
                                INNER JOIN tooleping t ON t.id = po.lepingId
                                INNER JOIN palk_lib pl ON pl.parentId = po.libId
                              WHERE t.parentid = qryTooleping.parentId
                                    AND po.period IS NULL
                                    AND pl.liik = 1
				    and t.rekvid = qryTooleping.rekvid
                                    AND year(po.kpv) = year(tdKpv) AND month(po.kpv) = month(tdKpv)
                                    AND (tnSumma IS NOT NULL OR po.id NOT IN (SELECT id
                                                                              FROM palk_oper
                                                                              WHERE
                                                                                kpv = tdKpv
                                                                                AND lepingid = tnLepingid
                                                                                AND libid = tnLibId))
      );


	raise notice ' l_isiku_tulubaas %',  l_isiku_tulubaas;

      -- arvestame kuu tulud

      IF coalesce(tnSumma, 0) = 0
      THEN
        SELECT sum(po.summa)
        INTO lnKuuSumma
        FROM palk_oper po
          INNER JOIN tooleping t ON t.id = po.lepingId
          INNER JOIN palk_lib pl ON pl.parentId = po.libId
        WHERE t.parentid = qryTooleping.parentId and t.rekvId = qryTooleping.rekvId
              AND pl.liik = 1
              AND po.period IS NULL -- ainult arvestuse period
              AND year(po.kpv) = year(tdKpv) AND month(po.kpv) = month(tdKpv)
              --            AND po.rekvId = qryTooleping.rekvId --Arvestame koik tulud seles kuu
              AND (po.id NOT IN (SELECT id
                                                        FROM palk_oper
                                                        WHERE kpv = tdKpv AND lepingid = tnLepingid AND
                                                              libid = tnLibId)); -- kui parandus siis v]ttame koik summad

        lnKuuSumma = coalesce(lnKuuSumma, 0) + (lnSumma - coalesce(tnSumma, 0));
      ELSE
        lnKuuSumma = tnSumma; --if umardamine then do not neccessory calculate kuu summa
      END IF;


      -- 2 kasutatud mvt

	l_tulubaas = fnc_calc_mvt(lnSumma,  l_tulubaas_kokku, l_isiku_tulubaas, lnKuuSumma, lTKI, lPM, tdkpv);

	/*

      IF coalesce(tnUmardamine, 0) = 0
      THEN
        -- ei ole umardamine
        
	l_tulubaas = l_tulubaas - coalesce(l_isiku_tulubaas, 0);
	
        if l_tulubaas <  0 then
		-- kasutatud
		l_tulubaas = 0;
        end if;
        
      END IF;

	*/
/*
      IF l_tulubaas > lnSumma
      THEN
        l_tulubaas = lnSumma - lTKI - lPM;
      END IF;
*/

      IF coalesce(tnUmardamine, 0) = 1 and l_tulubaas_kokku > 0
      THEN
	l_tulubaas = coalesce(l_kasutatud_tulubaas,0);

      END IF;

    IF l_tulubaas < 0 AND (qryPalkLib.lisa IS NULL AND year(tdKpv) < 2018)
    THEN
      l_tulubaas = 0;
    END IF;
/*
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
--    lTM = round(lTM * 0.01 * l_TM_maar, 2);
    */

    lTM = fnc_calc_tm(lnSumma, l_tulubaas, lTKI, lPM, qryPalkLib.tululiik);
 --   raise notice 'fnc_calc_tm lTM %, lnSumma %, l_tulubaas %, lTKI %, lPM %, qryPalkLib.tululiik %', lTM, lnSumma, l_tulubaas, lTKI, lPM, qryPalkLib.tululiik;
    

--    raise notice 'tulubaas lTM %, l_tulubaas %, lnSumma %, lTKI %, lPM %, l_isiku_tulubaas %, l_kasutatud_tulubaas %', lTM, l_tulubaas, lnSumma, lTKI, lPM, l_isiku_tulubaas, l_kasutatud_tulubaas;

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
--raise notice 'salvestame lSM %', lSM;
    
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

GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date, numeric, date, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date, numeric, date, integer) TO dbpeakasutaja;
COMMENT ON FUNCTION sp_calc_arv(integer, integer, date, numeric, date, integer) IS 'Muudetud 01/02/2005 lisatud ohtu-uletoo tunni alusel tootajad';


/*

	select sp_calc_arv(137587, 289312, '2018-02-28', null, null, null);

	select * from asutus where regkood = '48510032228'
	select * from rekv where nimetus ilike '%22011%'

	select sp_calc_umardamine(37118, '2018-02-28', 121)
	-- 205.77

*/