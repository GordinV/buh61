-- View: "public.curpalkoper"

-- DROP VIEW public.curpalkoper;

CREATE OR REPLACE VIEW public.curpalkoper AS 
 SELECT library.nimetus, asutus.nimetus AS isik, asutus.id AS isikid, ifnull(journalid.number, 0) AS journalid, palk_oper.journal1id, palk_oper.kpv, palk_oper.summa, palk_oper.id, palk_oper.libid, palk_oper.rekvid, tooleping.pank, tooleping.aa, 
        CASE
            WHEN (alltrim(to_char(liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(asutusest::double precision, '9'::text)::bpchar)) = '1-0'::bpchar THEN '+'::text::bpchar
            WHEN (alltrim(to_char(liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(asutusest::double precision, '9'::text)::bpchar)) = '2-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(asutusest::double precision, '9'::text)::bpchar)) = '6-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(asutusest::double precision, '9'::text)::bpchar)) = '4-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(asutusest::double precision, '9'::text)::bpchar)) = '8-0'::bpchar THEN '-'::text::bpchar
            WHEN (alltrim(to_char(liik::double precision, '9'::text)::bpchar) + '-'::bpchar + alltrim(to_char(asutusest::double precision, '9'::text)::bpchar)) = '7-0'::bpchar THEN '-'::text::bpchar
            ELSE '%'::bpchar
        END AS liik, 
        CASE
            WHEN tund = 1 THEN 'KOIK'::text
            WHEN tund = 2 THEN 'PAEV'::text
            WHEN tund = 3 THEN 'OHT'::text
            WHEN tund = 4 THEN 'OO'::text
            WHEN tund = 5 THEN 'PUHKUS'::text
            WHEN tund = 6 THEN 'PUHA'::text
            ELSE NULL::text
        END AS tund, 
        CASE
            WHEN maks = 1 THEN 'JAH'::text
            ELSE 'EI'::text
        END AS maks
   FROM palk_oper
   JOIN library ON palk_oper.libid = library.id
   JOIN palk_lib ON palk_lib.parentid = library.id
   JOIN tooleping ON palk_oper.lepingid = tooleping.id
   JOIN asutus ON tooleping.parentid = asutus.id
   LEFT JOIN journalid ON palk_oper.journalid = journalid.journalid;

GRANT ALL ON TABLE public.curpalkoper TO vlad WITH GRANT OPTION;
GRANT SELECT ON TABLE public.curpalkoper TO GROUP dbkasutaja;
GRANT SELECT ON TABLE public.curpalkoper TO GROUP dbvaatleja;
GRANT SELECT ON TABLE public.curpalkoper TO GROUP dbpeakasutaja;
GRANT SELECT ON TABLE public.curpalkoper TO GROUP dbadmin;
