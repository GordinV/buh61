-- View: "public.curtsd"

-- DROP VIEW public.curtsd;

CREATE OR REPLACE VIEW public.curtsd AS 
 SELECT palk_oper.id, palk_oper.rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, comtooleping.pohikoht, comtooleping.osakondid, palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv, palk_oper.summa, rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar AS form, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-01'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk26, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-02'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_02, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-03'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_03, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-04'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_04, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-05'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_05, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-06'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_06, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-07'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_07, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-08'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_08, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-09'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_09, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-10'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_10, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-11'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_11, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-12'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_12, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-13'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_13, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-14'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_14, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-15'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_15, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-16'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_16, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-17'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_17, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-18'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk_18, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar)+'-'+ltrim(rtrim(palk_lib.tululiik))::bpchar = '1-26-19'::bpchar THEN palk_oper.summa
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
