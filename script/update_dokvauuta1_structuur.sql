 DROP VIEW cursaldoasutus;
DROP VIEW cursaldotunnus;
 DROP VIEW qrykassatulutaitm;
DROP VIEW v_saldoaruanne;

DROP VIEW curarved;
DROP VIEW curarvtasud;

DROP VIEW cureelarve;

DROP VIEW cureelarvekulud;


DROP VIEW curkassakuludetaitmine;

DROP VIEW curkassatuludetaitmine;

DROP VIEW curkuludetaitmine;

DROP VIEW curkulum;

DROP VIEW curpalkoper;


DROP VIEW curpalkoper3;

DROP VIEW curpohivara;

DROP VIEW cursaldo;

DROP VIEW curteenused;


DROP VIEW curtsd;

DROP VIEW curtsd1;

DROP VIEW curtuludetaitmine;

DROP VIEW curjournal;



ALTER TABLE dokvaluuta1
   ALTER COLUMN kuurs TYPE numeric(20,10);

-- View: cursaldotunnus




CREATE OR REPLACE VIEW curtuludetaitmine AS 
 SELECT month(journal.kpv) AS kuu, year(journal.kpv) AS aasta, journal.rekvid, rekv.nimetus, journal1.tunnus AS tun, sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood5 AS kood, space(1) AS eelarve, journal1.kood1 AS tegev, journal1.kood2
   FROM journal
   JOIN journal1 ON journal.id = journal1.parentid
   LEFT JOIN dokvaluuta1 ON dokvaluuta1.dokid = journal1.id AND dokvaluuta1.dokliik = 1
   JOIN fakttulud ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(fakttulud.kood::text))
   JOIN rekv ON journal.rekvid = rekv.id
  GROUP BY year(journal.kpv), month(journal.kpv), journal.rekvid, rekv.nimetus, journal1.kreedit, journal1.kood1, journal1.kood5, journal1.kood2, journal1.tunnus
  ORDER BY year(journal.kpv), month(journal.kpv), journal.rekvid, rekv.nimetus, journal1.kreedit, journal1.kood1, journal1.kood5, journal1.kood2, journal1.tunnus;

ALTER TABLE curtuludetaitmine
  OWNER TO vlad;
GRANT ALL ON TABLE curtuludetaitmine TO vlad;
GRANT SELECT ON TABLE curtuludetaitmine TO dbpeakasutaja;
GRANT SELECT ON TABLE curtuludetaitmine TO dbkasutaja;
GRANT SELECT ON TABLE curtuludetaitmine TO dbadmin;
GRANT SELECT ON TABLE curtuludetaitmine TO dbvaatleja;



CREATE OR REPLACE VIEW curtsd1 AS 
 SELECT palk_oper.id, palk_oper.rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, comtooleping.pohikoht, comtooleping.osakondid, palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv, palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric) AS summa, rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar AS form, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '01'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk26, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '02'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_02, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '03'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_03, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '04'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_04, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '05'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_05, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '06'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_06, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '07'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_07, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '08'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_08, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '09'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_09, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '10'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_10, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '11'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_11, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '12'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_12, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '13'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_13, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '14'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_14, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '15'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_15, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '16'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_16, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '17'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_17, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '18'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_18, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '19'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_19, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '20'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_20, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '21'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_21, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '22'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_22, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-15'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk15, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-10'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk10, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-5'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk5, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-0'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk0, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-0'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS tm, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-1'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS atm, 
        CASE
            WHEN palk_lib.liik = 8 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS pm, 
        CASE
            WHEN palk_lib.liik = 4 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS tulumaks, 
        CASE
            WHEN palk_lib.liik = 5 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS sotsmaks, 
        CASE
            WHEN palk_lib.elatis = 1 AND palk_lib.liik = 2 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS elatis, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.sots = 1 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palksots
   FROM palk_oper
   JOIN comtooleping ON comtooleping.id = palk_oper.lepingid
   JOIN asutus ON asutus.id = comtooleping.parentid
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN palk_kaart ON palk_kaart.lepingid = comtooleping.id AND palk_kaart.libid = palk_lib.parentid
   LEFT JOIN dokvaluuta1 ON palk_oper.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 12;

ALTER TABLE curtsd1
  OWNER TO vlad;
GRANT ALL ON TABLE curtsd1 TO vlad;
GRANT SELECT ON TABLE curtsd1 TO dbpeakasutaja;
GRANT SELECT ON TABLE curtsd1 TO dbkasutaja;
GRANT SELECT ON TABLE curtsd1 TO dbvaatleja;



CREATE OR REPLACE VIEW curtsd AS 
 SELECT palk_oper.id, rekv.parentid, rekv.id AS rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, tooleping.pohikoht, tooleping.osakondid, tooleping.resident, tooleping.riik, tooleping.toend, palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv, palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric) AS summa, rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar AS form, 
        CASE
            WHEN palk_lib.liik = 1 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk26, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '02'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_02, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '03'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_03, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '04'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_04, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '05'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_05, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '06'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_06, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '07'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_07, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '08'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_08, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '09'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_09, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '10'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_10, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '11'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_11, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '12'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_12, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '13'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_13, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '14'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_14, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '15'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_15, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '16'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_16, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '17'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_17, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '18'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_18, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '19'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_19, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '19a'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_19a, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '20'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_20, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '21'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_21, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '22'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palk_22, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-15'::bpchar THEN 0::numeric
            ELSE 0::numeric
        END AS palk15, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-10'::bpchar THEN 0::numeric
            ELSE 0::numeric
        END AS palk10, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-5'::bpchar THEN 0::numeric
            ELSE 0::numeric
        END AS palk5, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-0'::bpchar THEN 0::numeric
            ELSE 0::numeric
        END AS palk0, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-0'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS tm, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-1'::bpchar THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS atm, 
        CASE
            WHEN palk_lib.liik = 8 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS pm, 
        CASE
            WHEN palk_lib.liik = 4 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS tulumaks, 
        CASE
            WHEN palk_lib.liik = 5 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS sotsmaks, 
        CASE
            WHEN palk_lib.elatis = 1 AND palk_lib.liik = 2 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS elatis, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.sots = 1 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)
            ELSE 0::numeric
        END AS palksots
   FROM palk_oper
   JOIN tooleping ON tooleping.id = palk_oper.lepingid
   JOIN rekv ON rekv.id = palk_oper.rekvid
   JOIN asutus ON asutus.id = tooleping.parentid
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN palk_kaart ON palk_kaart.lepingid = tooleping.id AND palk_kaart.libid = palk_lib.parentid AND palk_kaart.parentid = asutus.id
   LEFT JOIN dokvaluuta1 ON palk_oper.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 12;

ALTER TABLE curtsd
  OWNER TO vlad;
GRANT ALL ON TABLE curtsd TO vlad;
GRANT SELECT ON TABLE curtsd TO dbpeakasutaja;
GRANT SELECT ON TABLE curtsd TO dbkasutaja;
GRANT SELECT ON TABLE curtsd TO dbvaatleja;



CREATE OR REPLACE VIEW curteenused AS 
 SELECT arv.id, arv.rekvid, arv.journalid, arv.liik, arv.number, arv.kpv, arv1.kogus, arv1.summa, asutus.regkood, asutus.nimetus AS asutus, nomenklatuur.kood, nomenklatuur.nimetus, nomenklatuur.uhik, arv1.hind, arv1.kbm, asutus.omvorm, arv1.summa - arv1.kbm AS kbmta, 
        CASE
            WHEN nomenklatuur.doklausid = 0 THEN 18
            ELSE 
            CASE
                WHEN nomenklatuur.doklausid = 1 OR nomenklatuur.doklausid = 3 THEN 0
                ELSE 
                CASE
                    WHEN nomenklatuur.doklausid = 2 THEN 5
                    ELSE 
                    CASE
                        WHEN nomenklatuur.doklausid = 5 THEN 20
                        ELSE NULL::integer
                    END
                END
            END
        END AS kaibemaks, arv1.kood4 AS uritus, arv1.proj, ifnull(dokvaluuta1.valuuta::bpchar, 'EEK'::bpchar)::character varying AS valuuta, ifnull(dokvaluuta1.kuurs, 1::numeric) AS kuurs, ifnull(arv.objekt::bpchar, space(20))::character varying AS objekt
   FROM arv
   JOIN arv1 ON arv.id = arv1.parentid
   JOIN asutus ON arv.asutusid = asutus.id
   JOIN nomenklatuur ON arv1.nomid = nomenklatuur.id
   LEFT JOIN dokvaluuta1 ON arv1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 2;

ALTER TABLE curteenused
  OWNER TO vlad;
GRANT ALL ON TABLE curteenused TO vlad;
GRANT SELECT ON TABLE curteenused TO dbpeakasutaja;
GRANT SELECT ON TABLE curteenused TO dbkasutaja;
GRANT SELECT ON TABLE curteenused TO dbvaatleja;



CREATE OR REPLACE VIEW cursaldo AS 
 SELECT journal.kpv, journal.rekvid, journal1.deebet AS konto, journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric) AS deebet, 0::numeric(12,4) AS kreedit, 4 AS opt, journal.asutusid
   FROM journal
   JOIN journal1 ON journal.id = journal1.parentid
   JOIN journalid ON journal.id = journalid.journalid
   LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
UNION ALL 
 SELECT journal.kpv, journal.rekvid, journal1.kreedit AS konto, 0::numeric(12,4) AS deebet, journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric) AS kreedit, 4 AS opt, journal.asutusid
   FROM journal
   JOIN journal1 ON journal.id = journal1.parentid
   JOIN journalid ON journal.id = journalid.journalid
   LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1;

ALTER TABLE cursaldo
  OWNER TO vlad;
GRANT ALL ON TABLE cursaldo TO vlad;
GRANT SELECT ON TABLE cursaldo TO dbpeakasutaja;
GRANT SELECT ON TABLE cursaldo TO dbkasutaja;
GRANT SELECT ON TABLE cursaldo TO dbadmin;
GRANT SELECT ON TABLE cursaldo TO dbvaatleja;


CREATE OR REPLACE VIEW curpohivara AS 
 SELECT library.id, library.kood, library.nimetus, library.rekvid, pv_kaart.vastisikid, ifnull(asutus.nimetus, space(254)) AS vastisik, pv_kaart.algkulum, pv_kaart.kulum, pv_kaart.soetmaks, pv_kaart.parhind, pv_kaart.soetkpv, grupp.nimetus AS grupp, pv_kaart.konto, pv_kaart.gruppid, pv_kaart.tunnus, pv_kaart.mahakantud, pv_kaart.muud::character varying(254) AS rentnik, 
        CASE
            WHEN pv_kaart.kulum > 0::numeric THEN 'Pohivara'::text
            ELSE 'Vaikevahendid'::text
        END AS liik, ifnull(dokvaluuta1.valuuta::bpchar, 'EEK'::bpchar)::character varying AS valuuta, ifnull(dokvaluuta1.kuurs, 1::numeric) AS kuurs
   FROM library
   JOIN pv_kaart ON library.id = pv_kaart.parentid
   LEFT JOIN dokvaluuta1 ON dokvaluuta1.dokid = pv_kaart.id AND dokvaluuta1.dokliik = 18
   JOIN library grupp ON pv_kaart.gruppid = grupp.id AND library.rekvid = grupp.rekvid
   LEFT JOIN asutus ON pv_kaart.vastisikid = asutus.id;

ALTER TABLE curpohivara
  OWNER TO vlad;
GRANT ALL ON TABLE curpohivara TO vlad;
GRANT SELECT ON TABLE curpohivara TO dbpeakasutaja;
GRANT SELECT ON TABLE curpohivara TO dbkasutaja;
GRANT SELECT ON TABLE curpohivara TO dbvaatleja;



CREATE OR REPLACE VIEW curpalkoper3 AS 
 SELECT palk_oper.summa, palk_oper.kpv, palk_oper.rekvid, asutus.nimetus AS isik, asutus.id AS isikid, asutus.regkood AS isikukood, palk_lib.liik, palk_lib.asutusest, osakond.kood AS okood, amet.kood AS akood, ifnull(dokvaluuta1.kuurs, 1::numeric) AS kuurs, ifnull(dokvaluuta1.valuuta::bpchar, 'EEK'::bpchar)::character varying AS valuuta
   FROM palk_oper
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN library lib ON lib.id = palk_lib.parentid
   JOIN tooleping ON palk_oper.lepingid = tooleping.id
   JOIN asutus ON tooleping.parentid = asutus.id
   JOIN library osakond ON osakond.id = tooleping.osakondid
   JOIN library amet ON amet.id = tooleping.ametid
   LEFT JOIN dokvaluuta1 ON palk_oper.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 12;

ALTER TABLE curpalkoper3
  OWNER TO vlad;
GRANT ALL ON TABLE curpalkoper3 TO vlad;
GRANT SELECT ON TABLE curpalkoper3 TO dbkasutaja;
GRANT SELECT ON TABLE curpalkoper3 TO dbvaatleja;
GRANT SELECT ON TABLE curpalkoper3 TO dbpeakasutaja;


CREATE OR REPLACE VIEW curpalkoper AS 
 SELECT library.tun1, library.tun2, library.tun3, library.tun4, library.tun5, library.nimetus, asutus.nimetus AS isik, asutus.id AS isikid, ifnull(journalid.number, 0) AS journalid, palk_oper.journal1id, palk_oper.kpv, palk_oper.summa, palk_oper.id, palk_oper.libid, palk_oper.rekvid, tooleping.pank, tooleping.aa, tooleping.osakondid, 
        CASE
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '1-0'::bpchar THEN '+'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '2-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '6-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '4-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '8-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(palk_lib.liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(palk_lib.asutusest::double precision, '9'::text)::bpchar)) = '7-0'::bpchar THEN '-'::text::bpchar
            ELSE '%'::bpchar
        END AS liik, 
        CASE
            WHEN palk_lib.tund = 1 THEN 'KOIK'::text
            WHEN palk_lib.tund = 2 THEN 'PAEV'::text
            WHEN palk_lib.tund = 3 THEN 'OHT'::text
            WHEN palk_lib.tund = 4 THEN 'OO'::text
            WHEN palk_lib.tund = 5 THEN 'PUHKUS'::text
            WHEN palk_lib.tund = 6 THEN 'PUHA'::text
            WHEN palk_lib.tund = 7 THEN 'ULETOO'::text
            ELSE NULL::text
        END AS tund, 
        CASE
            WHEN palk_lib.maks = 1 THEN 'JAH'::text
            ELSE 'EI'::text
        END AS maks, ifnull(dokvaluuta1.valuuta::bpchar, 'EEK'::bpchar)::character varying AS valuuta, ifnull(dokvaluuta1.kuurs, 1::numeric) AS kuurs
   FROM palk_oper
   JOIN library ON palk_oper.libid = library.id
   JOIN palk_lib ON palk_lib.parentid = library.id
   JOIN tooleping ON palk_oper.lepingid = tooleping.id
   JOIN asutus ON tooleping.parentid = asutus.id
   LEFT JOIN journalid ON palk_oper.journalid = journalid.journalid
   LEFT JOIN dokvaluuta1 ON palk_oper.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 12;

ALTER TABLE curpalkoper
  OWNER TO vlad;
GRANT ALL ON TABLE curpalkoper TO vlad;
GRANT SELECT ON TABLE curpalkoper TO dbkasutaja;
GRANT SELECT ON TABLE curpalkoper TO dbvaatleja;
GRANT SELECT ON TABLE curpalkoper TO dbpeakasutaja;



CREATE OR REPLACE VIEW curkulum AS 
 SELECT library.id, pv_oper.liik, (pv_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric))::numeric(12,4) AS summa, pv_oper.kpv, library.rekvid, grupp.nimetus AS grupp, nomenklatuur.kood, nomenklatuur.nimetus AS opernimi, pv_kaart.soetmaks, pv_kaart.soetkpv, pv_kaart.kulum, pv_kaart.algkulum, pv_kaart.gruppid, pv_kaart.konto, pv_kaart.tunnus, ifnull(asutus.nimetus, space(254)) AS vastisik, library.kood AS ivnum, library.kood AS invnum, library.nimetus AS pohivara
   FROM library
   JOIN pv_oper ON library.id = pv_oper.parentid
   JOIN pv_kaart ON library.id = pv_kaart.parentid
   JOIN library grupp ON pv_kaart.gruppid = grupp.id
   LEFT JOIN asutus ON pv_kaart.vastisikid = asutus.id
   LEFT JOIN dokvaluuta1 ON pv_oper.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 13
   JOIN nomenklatuur ON pv_oper.nomid = nomenklatuur.id;

ALTER TABLE curkulum
  OWNER TO vlad;
GRANT ALL ON TABLE curkulum TO vlad;
GRANT SELECT ON TABLE curkulum TO dbpeakasutaja;
GRANT SELECT ON TABLE curkulum TO dbkasutaja;
GRANT SELECT ON TABLE curkulum TO dbadmin;
GRANT SELECT ON TABLE curkulum TO dbvaatleja;
GRANT SELECT ON TABLE curkulum TO public;



CREATE OR REPLACE VIEW curkuludetaitmine AS 
 SELECT month(journal.kpv) AS kuu, year(journal.kpv) AS aasta, journal.rekvid, sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood5 AS kood, space(1) AS eelarve, journal1.kood1 AS tegev, journal1.tunnus AS tun, journal1.kood2
   FROM journal
   JOIN journal1 ON journal.id = journal1.parentid
   LEFT JOIN dokvaluuta1 ON dokvaluuta1.dokid = journal1.id AND dokvaluuta1.dokliik = 1
   JOIN faktkulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(faktkulud.kood::text))
  GROUP BY year(journal.kpv), month(journal.kpv), journal.rekvid, journal1.deebet, journal1.kood1, journal1.tunnus, journal1.kood5, journal1.kood2
  ORDER BY year(journal.kpv), month(journal.kpv), journal.rekvid, journal1.deebet, journal1.kood1, journal1.tunnus, journal1.kood5, journal1.kood2;

ALTER TABLE curkuludetaitmine
  OWNER TO vlad;
GRANT ALL ON TABLE curkuludetaitmine TO vlad;
GRANT SELECT ON TABLE curkuludetaitmine TO dbpeakasutaja;
GRANT SELECT ON TABLE curkuludetaitmine TO dbkasutaja;
GRANT SELECT ON TABLE curkuludetaitmine TO dbadmin;
GRANT SELECT ON TABLE curkuludetaitmine TO dbvaatleja;



CREATE OR REPLACE VIEW curkassatuludetaitmine AS 
 SELECT month(journal.kpv) AS kuu, year(journal.kpv) AS aasta, journal.rekvid, rekv.nimetus, rekv.nimetus AS asutus, journal1.tunnus AS tun, sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood5 AS kood, space(1) AS eelarve, journal1.kood1 AS tegev, journal1.kood2
   FROM journal
   JOIN journal1 ON journal.id = journal1.parentid
   LEFT JOIN dokvaluuta1 ON dokvaluuta1.dokid = journal1.id AND dokvaluuta1.dokliik = 1
   JOIN kassatulud ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
   JOIN rekv ON journal.rekvid = rekv.id
  GROUP BY year(journal.kpv), month(journal.kpv), journal.rekvid, rekv.nimetus, journal1.kreedit, journal1.kood1, journal1.kood5, journal1.kood2, journal1.tunnus
  ORDER BY year(journal.kpv), month(journal.kpv), journal.rekvid, rekv.nimetus, journal1.kreedit, journal1.kood1, journal1.kood5, journal1.kood2, journal1.tunnus;

ALTER TABLE curkassatuludetaitmine
  OWNER TO vlad;
GRANT ALL ON TABLE curkassatuludetaitmine TO vlad;
GRANT SELECT ON TABLE curkassatuludetaitmine TO dbpeakasutaja;
GRANT SELECT ON TABLE curkassatuludetaitmine TO dbkasutaja;
GRANT SELECT ON TABLE curkassatuludetaitmine TO dbadmin;
GRANT SELECT ON TABLE curkassatuludetaitmine TO dbvaatleja;
GRANT SELECT, UPDATE, INSERT, REFERENCES, TRIGGER ON TABLE curkassatuludetaitmine TO public;


CREATE OR REPLACE VIEW curkassakuludetaitmine AS 
 SELECT month(journal.kpv) AS kuu, year(journal.kpv) AS aasta, journal.rekvid, sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood5 AS kood, space(1) AS eelarve, journal1.kood1 AS tegev, journal1.tunnus AS tun, journal1.kood2, rekv.nimetus AS asutus
   FROM journal
   JOIN journal1 ON journal1.parentid = journal.id
   JOIN rekv ON rekv.id = journal.rekvid
   LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
   JOIN kassakulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
  GROUP BY year(journal.kpv), month(journal.kpv), journal.rekvid, journal1.deebet, journal1.kood1, journal1.tunnus, journal1.kood5, journal1.kood2, rekv.nimetus
  ORDER BY year(journal.kpv), month(journal.kpv), journal.rekvid, journal1.deebet, journal1.kood1, journal1.tunnus, journal1.kood5, journal1.kood2;

ALTER TABLE curkassakuludetaitmine
  OWNER TO vlad;
GRANT ALL ON TABLE curkassakuludetaitmine TO vlad;
GRANT SELECT ON TABLE curkassakuludetaitmine TO dbpeakasutaja;
GRANT SELECT ON TABLE curkassakuludetaitmine TO dbkasutaja;
GRANT SELECT ON TABLE curkassakuludetaitmine TO dbadmin;
GRANT SELECT ON TABLE curkassakuludetaitmine TO dbvaatleja;
GRANT SELECT, UPDATE, INSERT, REFERENCES, TRIGGER ON TABLE curkassakuludetaitmine TO public;


CREATE OR REPLACE VIEW curjournal AS 
 SELECT journal.id, journal.rekvid, journal.kpv, journal.asutusid, month(journal.kpv) AS kuu, year(journal.kpv) AS aasta, journal.selg::character varying(254) AS selg, journal.dok, journal1.summa, journal1.valsumma, ifnull(dokvaluuta1.valuuta::bpchar, 'EEK'::bpchar)::character varying(20) AS valuuta, ifnull(dokvaluuta1.kuurs, 1::numeric)::numeric(12,6) AS kuurs, journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood4, journal1.kood5, journal1.proj, journal1.deebet, journal1.kreedit, journal1.lisa_d, journal1.lisa_k, ifnull(ltrim(rtrim(asutus.nimetus::text))::bpchar + space(1) + ltrim(rtrim(asutus.omvorm::text))::bpchar, space(120)) AS asutus, journal1.tunnus, journalid.number
   FROM journal
   JOIN journal1 ON journal.id = journal1.parentid
   JOIN journalid ON journal.id = journalid.journalid
   LEFT JOIN asutus ON journal.asutusid = asutus.id
   LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1;

ALTER TABLE curjournal
  OWNER TO vlad;
GRANT ALL ON TABLE curjournal TO vlad;
GRANT SELECT ON TABLE curjournal TO dbkasutaja;
GRANT SELECT ON TABLE curjournal TO dbpeakasutaja;
GRANT SELECT ON TABLE curjournal TO dbvaatleja;
GRANT SELECT ON TABLE curjournal TO dbadmin;



CREATE OR REPLACE VIEW cureelarvekulud AS 
 SELECT eelarve.id, eelarve.rekvid, eelarve.aasta, eelarve.allikasid, eelarve.summa, eelarve.kood1, eelarve.kood2, eelarve.kood3, eelarve.kood4, eelarve.kood5, ifnull(t.kood, space(20))::character varying AS tunnus, rekv.nimetus AS asutus, rekv.regkood, rekv.parentid, ifnull(parent.nimetus, space(254)) AS parasutus, ifnull(parent.regkood, space(20)) AS parregkood, eelarve.kuu, eelarve.kpv, eelarve.muud, ifnull(dokvaluuta1.valuuta::bpchar, 'EEK'::bpchar)::character varying AS valuuta, ifnull(dokvaluuta1.kuurs, 1::numeric) AS kuurs, eelarve.tunnus AS tun
   FROM eelarve
   JOIN rekv ON eelarve.rekvid = rekv.id
   JOIN library ON eelarve.kood5::bpchar = library.kood AND library.library = 'TULUDEALLIKAD'::bpchar
   LEFT JOIN dokvaluuta1 ON eelarve.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 8
   LEFT JOIN rekv parent ON parent.id = rekv.parentid
   LEFT JOIN library t ON t.id = eelarve.tunnusid
  WHERE library.tun5 = 2;

ALTER TABLE cureelarvekulud
  OWNER TO vlad;
GRANT ALL ON TABLE cureelarvekulud TO vlad;
GRANT SELECT ON TABLE cureelarvekulud TO dbpeakasutaja;
GRANT SELECT ON TABLE cureelarvekulud TO dbkasutaja;
GRANT SELECT ON TABLE cureelarvekulud TO dbadmin;
GRANT SELECT ON TABLE cureelarvekulud TO dbvaatleja;
GRANT SELECT, UPDATE, INSERT, REFERENCES, TRIGGER ON TABLE cureelarvekulud TO public;


CREATE OR REPLACE VIEW cureelarve AS 
 SELECT eelarve.id, eelarve.rekvid, eelarve.aasta, eelarve.summa, eelarve.kood1, eelarve.kood2, eelarve.kood3, eelarve.kood4, eelarve.kood5, eelarve.tunnus AS tun, rekv.nimetus, rekv.nimetus AS asutus, rekv.regkood, rekv.parentid, ifnull(tunnus.kood, space(20)) AS tunnus, ifnull(parent.nimetus, space(254)) AS parasutus, ifnull(parent.regkood, space(20)) AS parregkood, eelarve.kuu, eelarve.kpv, eelarve.muud, ifnull(dokvaluuta1.valuuta::bpchar, 'EEK'::bpchar)::character varying AS valuuta, ifnull(dokvaluuta1.kuurs, 1::numeric) AS kuurs
   FROM eelarve
   JOIN rekv ON eelarve.rekvid = rekv.id
   JOIN library ON eelarve.kood5::bpchar = library.kood AND library.library = 'TULUDEALLIKAD'::bpchar
   LEFT JOIN rekv parent ON parent.id = rekv.parentid
   LEFT JOIN library tunnus ON eelarve.tunnusid = tunnus.id
   LEFT JOIN dokvaluuta1 ON dokvaluuta1.dokid = eelarve.id AND dokvaluuta1.dokliik = 8
  WHERE library.tun5 = 1;

ALTER TABLE cureelarve
  OWNER TO vlad;
GRANT ALL ON TABLE cureelarve TO vlad;
GRANT SELECT ON TABLE cureelarve TO dbpeakasutaja;
GRANT SELECT ON TABLE cureelarve TO dbkasutaja;
GRANT SELECT ON TABLE cureelarve TO dbadmin;
GRANT SELECT ON TABLE cureelarve TO dbvaatleja;
GRANT SELECT, UPDATE, INSERT, REFERENCES, TRIGGER ON TABLE cureelarve TO public;


CREATE OR REPLACE VIEW curarvtasud AS 
 SELECT arv.id AS arvid, arv.rekvid, arv.number, arv.kpv AS arvkpv, arv.summa AS arvsumma, arv.tahtaeg, arv.liik, asutus.nimetus AS asutus, arvtasu.kpv, arvtasu.summa, arvtasu.dok, arvtasu.id, arvtasu.journalid, arvtasu.pankkassa, arvtasu.sorderid, ifnull(arv.objekt::bpchar, space(20))::character varying AS objekt, 
        CASE
            WHEN arvtasu.pankkassa = 1 THEN 'MK'::character varying
            WHEN arvtasu.pankkassa = 2 THEN 'KASSA'::character varying
            WHEN arvtasu.pankkassa = 3 THEN 'RAAMAT'::character varying
            ELSE 'MUUD'::character varying
        END AS tasuliik, ifnull(dokvaluuta1.valuuta::bpchar, 'EEK'::bpchar)::character varying(20) AS valuuta, ifnull(dokvaluuta1.kuurs, 1::numeric) AS kuurs
   FROM arvtasu arvtasu
   JOIN arv ON arvtasu.arvid = arv.id
   JOIN asutus ON asutus.id = arv.asutusid
   LEFT JOIN dokvaluuta1 ON arvtasu.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 10;

ALTER TABLE curarvtasud
  OWNER TO vlad;
GRANT ALL ON TABLE curarvtasud TO vlad;
GRANT SELECT ON TABLE curarvtasud TO dbpeakasutaja;
GRANT SELECT ON TABLE curarvtasud TO dbkasutaja;
GRANT SELECT ON TABLE curarvtasud TO dbvaatleja;


CREATE OR REPLACE VIEW curarved AS 
 SELECT arv.id, arv.rekvid, arv.number, arv.kpv, arv.tahtaeg, arv.summa, arv.tasud, arv.tasudok, arv.userid, asutus.nimetus AS asutus, arv.asutusid, arv.journalid, arv.liik, arv.operid, arv.jaak, arv.objektid, arv.doklausid, ifnull(dokprop.konto::bpchar, space(20)) AS konto, arv.muud, ifnull(dokvaluuta1.valuuta::bpchar, 'EEK'::bpchar)::character varying AS valuuta, ifnull(dokvaluuta1.kuurs, 1::numeric) AS kuurs, ifnull(arv.objekt::bpchar, space(20))::character varying AS objekt, userid.ametnik
   FROM arv
   JOIN asutus asutus ON asutus.id = arv.asutusid
   JOIN userid ON arv.userid = userid.id
   LEFT JOIN dokprop ON dokprop.id = arv.doklausid
   LEFT JOIN dokvaluuta1 ON arv.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 3;

ALTER TABLE curarved
  OWNER TO vlad;
GRANT ALL ON TABLE curarved TO vlad;
GRANT SELECT ON TABLE curarved TO dbpeakasutaja;
GRANT SELECT ON TABLE curarved TO dbkasutaja;
GRANT SELECT ON TABLE curarved TO dbvaatleja;



CREATE OR REPLACE VIEW cursaldotunnus AS 
( SELECT date(2000, 1, 1) AS kpv, tunnusinf.rekvid, library.kood AS konto, 
        CASE
            WHEN tunnusinf.algsaldo >= 0::numeric THEN tunnusinf.algsaldo
            ELSE 0::numeric
        END AS deebet, 
        CASE
            WHEN tunnusinf.algsaldo < 0::numeric THEN (- 1::numeric) * tunnusinf.algsaldo
            ELSE 0::numeric
        END AS kreedit, 1 AS opt, tunnusinf.tunnusid
   FROM library
   JOIN tunnusinf ON library.id = tunnusinf.kontoid
UNION ALL 
 SELECT curjournal.kpv, curjournal.rekvid, curjournal.deebet AS konto, curjournal.summa AS deebet, 0 AS kreedit, 4 AS opt, t.id AS tunnusid
   FROM curjournal
   JOIN library t ON curjournal.tunnus::bpchar = t.kood
  WHERE len(ltrim(rtrim(curjournal.tunnus::text))::character varying) > 0)
UNION ALL 
 SELECT curjournal.kpv, curjournal.rekvid, curjournal.kreedit AS konto, 0 AS deebet, curjournal.summa AS kreedit, 4 AS opt, t.id AS tunnusid
   FROM curjournal
   JOIN library t ON curjournal.tunnus::bpchar = t.kood
  WHERE len(ltrim(rtrim(curjournal.tunnus::text))::character varying) > 0;

ALTER TABLE cursaldotunnus
  OWNER TO vlad;
GRANT ALL ON TABLE cursaldotunnus TO vlad;
GRANT SELECT ON TABLE cursaldotunnus TO dbpeakasutaja;
GRANT SELECT ON TABLE cursaldotunnus TO dbkasutaja;
GRANT SELECT ON TABLE cursaldotunnus TO dbadmin;
GRANT SELECT ON TABLE cursaldotunnus TO dbvaatleja;




CREATE OR REPLACE VIEW cursaldoasutus AS 
( SELECT date(2000, 1, 1) AS kpv, subkonto.rekvid, library.kood AS konto, 
        CASE
            WHEN subkonto.algsaldo >= 0::numeric THEN subkonto.algsaldo
            ELSE 0::numeric(12,4)
        END AS deebet, 
        CASE
            WHEN subkonto.algsaldo < 0::numeric THEN (- 1::numeric) * subkonto.algsaldo
            ELSE 0::numeric(12,4)
        END AS kreedit, 2 AS opt, subkonto.asutusid
   FROM library
   JOIN subkonto ON library.id = subkonto.kontoid
UNION ALL 
 SELECT curjournal.kpv, curjournal.rekvid, curjournal.deebet AS konto, curjournal.summa AS deebet, 0::numeric(12,4) AS kreedit, 4 AS opt, curjournal.asutusid
   FROM curjournal)
UNION ALL 
 SELECT curjournal.kpv, curjournal.rekvid, curjournal.kreedit AS konto, 0::numeric(12,4) AS deebet, curjournal.summa AS kreedit, 4 AS opt, curjournal.asutusid
   FROM curjournal;

ALTER TABLE cursaldoasutus
  OWNER TO vlad;
GRANT ALL ON TABLE cursaldoasutus TO vlad;
GRANT SELECT ON TABLE cursaldoasutus TO dbpeakasutaja;
GRANT SELECT ON TABLE cursaldoasutus TO dbkasutaja;
GRANT SELECT ON TABLE cursaldoasutus TO dbadmin;
GRANT SELECT ON TABLE cursaldoasutus TO dbvaatleja;



CREATE OR REPLACE VIEW qrykassatulutaitm AS 
 SELECT curjournal.kpv, curjournal.rekvid, rekv.nimetus, curjournal.tunnus AS tun, curjournal.summa * curjournal.kuurs AS summa, curjournal.kood5 AS kood, space(1) AS eelarve, curjournal.kood1 AS tegev
   FROM curjournal
   JOIN kassatulud ON ltrim(rtrim(curjournal.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(curjournal.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
   JOIN rekv ON curjournal.rekvid = rekv.id;

ALTER TABLE qrykassatulutaitm
  OWNER TO vlad;
GRANT ALL ON TABLE qrykassatulutaitm TO vlad;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbpeakasutaja;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbkasutaja;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbadmin;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbvaatleja;



CREATE OR REPLACE VIEW v_saldoaruanne AS 
 SELECT qrysaldoaruanne.konto, qrysaldoaruanne.tp, qrysaldoaruanne.tegev, qrysaldoaruanne.allikas, qrysaldoaruanne.rahavoo, sum(qrysaldoaruanne.deebet) AS db, sum(qrysaldoaruanne.kreedit) AS kr
   FROM ( SELECT curjournal.deebet AS konto, curjournal.lisa_d AS tp, curjournal.kood1 AS tegev, curjournal.kood2 AS allikas, curjournal.kood3 AS rahavoo, curjournal.summa AS deebet, 0::numeric(12,4) AS kreedit
           FROM curjournal
UNION ALL 
         SELECT curjournal.kreedit AS konto, curjournal.lisa_d AS tp, curjournal.kood1 AS tegev, curjournal.kood2 AS allikas, curjournal.kood3 AS rahavoo, 0::numeric(12,4) AS deebet, curjournal.summa AS kreedit
           FROM curjournal) qrysaldoaruanne
  GROUP BY qrysaldoaruanne.konto, qrysaldoaruanne.tp, qrysaldoaruanne.tegev, qrysaldoaruanne.allikas, qrysaldoaruanne.rahavoo
  ORDER BY qrysaldoaruanne.konto, qrysaldoaruanne.tp, qrysaldoaruanne.tegev, qrysaldoaruanne.allikas, qrysaldoaruanne.rahavoo;

ALTER TABLE v_saldoaruanne
  OWNER TO vlad;
GRANT ALL ON TABLE v_saldoaruanne TO vlad;
GRANT SELECT ON TABLE v_saldoaruanne TO dbkasutaja;
GRANT SELECT ON TABLE v_saldoaruanne TO dbpeakasutaja;
GRANT SELECT ON TABLE v_saldoaruanne TO dbadmin;
GRANT SELECT ON TABLE v_saldoaruanne TO dbvaatleja;



