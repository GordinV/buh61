-- View: "public.curtsd"

-- DROP VIEW public.curtsd;

CREATE OR REPLACE VIEW public.curtsd AS 
 SELECT palk_oper.id, palk_oper.rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, comtooleping.pohikoht, comtooleping.osakondid, palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv, palk_oper.summa, rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar AS form, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '01' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk26, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '02' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_02, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '03' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_03, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '04' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_04, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '05' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_05, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '06' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_06, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '07' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_07, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '08' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_08, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '09' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_09, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '10' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_10, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '11' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_11, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '12' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_12, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '13' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_13, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '14' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_14, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '15' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_15, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '16' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_16, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '17' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_17, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '18' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_18, 
        CASE
            WHEN palk_lib.liik = 1 and palk_lib.tululiik = '19' THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_19, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-15'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk15, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-10'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk10, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-5'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk5, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-0'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk0, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-0'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS tm, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_lib.asutusest::integer)::text))::bpchar) = '7-1'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS atm, 
        CASE
            WHEN palk_lib.liik = 8 THEN palk_oper.summa
            ELSE 0::numeric
        END AS pm, 
        CASE
            WHEN palk_lib.liik = 4 THEN palk_oper.summa
            ELSE 0::numeric
        END AS tulumaks, 
        CASE
            WHEN palk_lib.liik = 5 THEN palk_oper.summa
            ELSE 0::numeric
	END AS sotsmaks,
        CASE
            WHEN palk_lib.elatis = 1 and palk_lib.liik = 2 THEN palk_oper.summa
            ELSE 0::numeric
        END AS elatis
   FROM palk_oper
   JOIN comtooleping ON comtooleping.id = palk_oper.lepingid
   JOIN asutus ON asutus.id = comtooleping.parentid
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN palk_kaart ON palk_kaart.lepingid = comtooleping.id AND palk_kaart.libid = palk_lib.parentid

GRANT ALL ON TABLE public.curtsd TO vlad WITH GRANT OPTION;
GRANT SELECT ON TABLE public.curtsd TO GROUP dbpeakasutaja;
GRANT SELECT ON TABLE public.curtsd TO GROUP dbkasutaja;
GRANT SELECT ON TABLE public.curtsd TO GROUP dbadmin;
GRANT SELECT ON TABLE public.curtsd TO GROUP dbvaatleja;
