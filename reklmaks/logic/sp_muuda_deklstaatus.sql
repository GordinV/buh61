-- View: "public.curtsd"

-- DROP VIEW public.curtsd;

CREATE OR REPLACE VIEW public.curtsd AS 
 SELECT asutus.rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, comtooleping.pohikoht, comtooleping.osakondid, 
palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, palk_oper.kpv, 
        CASE
            WHEN (rtrim(ltrim(str(palk_lib.liik::integer)::text))::bpchar + '-'::bpchar + ltrim(rtrim(str(palk_kaart.tulumaar::integer)::text))::bpchar) = '1-26'::bpchar THEN palk_oper.summa
            ELSE 0::numeric
        END AS palk26, 
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
        END AS sotsmaks
   FROM comtooleping
   JOIN palk_oper ON comtooleping.id = palk_oper.lepingid
   JOIN asutus ON asutus.id = comtooleping.parentid
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN palk_kaart ON (palk_kaart.lepingid = comtooleping.id and palk_kaart.libid = palk_oper.libid);

GRANT ALL ON TABLE public.curtsd TO vlad WITH GRANT OPTION;
GRANT SELECT ON TABLE public.curtsd TO GROUP dbpeakasutaja;
GRANT SELECT ON TABLE public.curtsd TO GROUP dbkasutaja;
GRANT SELECT ON TABLE public.curtsd TO GROUP dbadmin;
GRANT SELECT ON TABLE public.curtsd TO GROUP dbvaatleja;
