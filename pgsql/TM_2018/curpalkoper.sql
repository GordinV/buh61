-- View: curpalkoper

-- DROP VIEW curpalkoper;

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
            WHEN palk_lib.tund = 8 THEN 'HAIGUS'::text
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

ALTER TABLE curpalkoper OWNER TO vlad;
GRANT ALL ON TABLE curpalkoper TO vlad;
GRANT SELECT ON TABLE curpalkoper TO dbkasutaja;
GRANT SELECT ON TABLE curpalkoper TO dbvaatleja;
GRANT SELECT ON TABLE curpalkoper TO dbpeakasutaja;

