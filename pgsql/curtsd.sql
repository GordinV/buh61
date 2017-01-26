-- View: curtsd

DROP VIEW curtsd;

CREATE OR REPLACE VIEW curtsd AS 
 SELECT palk_oper.id, rekv.parentid, rekv.id AS rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, tooleping.pohikoht, tooleping.osakondid, 
	tooleping.resident, tooleping.riik, tooleping.toend, palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv,
	 palk_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric as summa, 
	 rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar AS form, 
        CASE
            WHEN palk_lib.liik = 1 THEN palk_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk26, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '02'::text THEN palk_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_02, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '03'::text THEN palk_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_03, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '04'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_04, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '05'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_05, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '06'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_06, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '07'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_07, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '08'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_08, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '09'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_09, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '10'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_10, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '11'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_11, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '12'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_12, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '13'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_13, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '14'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_14, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '15'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_15, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '16'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_16, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '17'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_17, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '18'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_18, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '19'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_19, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '19a'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_19a, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '20'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_20, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.tululiik::text = '21'::text THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palk_21, 
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
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-0'::bpchar THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS tm, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-1'::bpchar THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS atm, 
        CASE
            WHEN palk_lib.liik = 8 THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS pm, 
        CASE
            WHEN palk_lib.liik = 4 THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS tulumaks, 
        CASE
            WHEN palk_lib.liik = 5 THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS sotsmaks, 
        CASE
            WHEN palk_lib.elatis = 1 AND palk_lib.liik = 2 THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS elatis, 
        CASE
            WHEN palk_lib.liik = 1 AND palk_lib.sots = 1 THEN palk_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric
            ELSE 0::numeric
        END AS palksots
   FROM palk_oper
   JOIN tooleping ON tooleping.id = palk_oper.lepingid
   JOIN rekv ON rekv.id = palk_oper.rekvid
   JOIN asutus ON asutus.id = tooleping.parentid
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN palk_kaart ON palk_kaart.lepingid = tooleping.id AND palk_kaart.libid = palk_lib.parentid AND palk_kaart.parentid = asutus.id
 left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)   ;

ALTER TABLE curtsd OWNER TO vlad;
GRANT SELECT ON TABLE curtsd TO dbpeakasutaja;
GRANT SELECT ON TABLE curtsd TO dbkasutaja;
GRANT SELECT ON TABLE curtsd TO dbvaatleja;

