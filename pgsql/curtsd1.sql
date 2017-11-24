-- View: curtsd1

 DROP VIEW curtsd1;

CREATE OR REPLACE VIEW curtsd1 AS 
 SELECT palk_oper.id, palk_oper.rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, comtooleping.pohikoht, comtooleping.osakondid, 
	palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv, palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric as summa, 
	rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar AS form, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '01'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric 
            ELSE 0::numeric
        END AS palk26, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '02'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_02, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '03'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_03, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '04'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_04, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '05'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_05, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '06'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_06, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '07'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_07, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '08'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_08, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '09'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_09, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '10'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_10, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '11'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_11, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '12'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_12, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '13'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_13, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '14'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_14, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '15'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_15, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '16'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_16, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '17'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_17, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '18'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_18, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '19'::text THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_19, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-15'::bpchar 
            THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk15, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-10'::bpchar 
            THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk10, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-5'::bpchar 
            THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk5, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-0'::bpchar 
            THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk0, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-0'::bpchar 
            THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS tm, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-1'::bpchar 
            THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS atm, 
        CASE
            WHEN palk_lib.liik = 8 THEN palk_oper.summa* ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS pm, 
        CASE
            WHEN palk_lib.liik = 4 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS tulumaks, 
        CASE
            WHEN palk_lib.liik = 5 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS sotsmaks, 
        CASE
            WHEN palk_lib.elatis = 1 AND palk_lib.liik = 2 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS elatis, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.sots = 1 THEN palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palksots
   FROM palk_oper
   JOIN comtooleping ON comtooleping.id = palk_oper.lepingid
   JOIN asutus ON asutus.id = comtooleping.parentid
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN palk_kaart ON palk_kaart.lepingid = comtooleping.id AND palk_kaart.libid = palk_lib.parentid
   left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12);

ALTER TABLE curtsd1 OWNER TO vlad;
GRANT SELECT ON TABLE curtsd1 TO dbpeakasutaja;
GRANT SELECT ON TABLE curtsd1 TO dbkasutaja;
GRANT SELECT ON TABLE curtsd1 TO dbvaatleja;

