-- View: curjournal
/*

 SELECT sum(curjournal.summa * curjournal.kuurs) 
   FROM curjournal
   JOIN kassatulud ON ltrim(rtrim(curjournal.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(curjournal.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
   JOIN rekv ON curjournal.rekvid = rekv.id
where rekvid = 63 and curjournal.kood5 like '352%'
   ;
   
 SELECT sum(curjournal.summa * curjournal.kuurs) 
   FROM curjournal 
where rekvid = 63 and curjournal.kood5 like '352%'
   ;


*/
-- DROP VIEW curjournal;

CREATE OR REPLACE VIEW curjournal AS 
 SELECT journal.id, journal.rekvid, journal.kpv, journal.asutusid, month(journal.kpv) AS kuu, year(journal.kpv) AS aasta, 
 journal.selg::character varying(254) AS selg, journal.dok, journal1.summa, journal1.valsumma, 
 ifnull(dokvaluuta1.valuuta,'EEK')::character varying(20) as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric(12,6) as kuurs, 
 journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood4, journal1.kood5, journal1.proj, journal1.deebet, journal1.kreedit, 
 journal1.lisa_d, journal1.lisa_k, ifnull(ltrim(rtrim(asutus.nimetus::text))::bpchar + space(1) + ltrim(rtrim(asutus.omvorm::text))::bpchar, space(120)) AS asutus, 
 journal1.tunnus, journalid.number
   FROM journal
   JOIN journal1 ON journal.id = journal1.parentid
   JOIN journalid ON journal.id = journalid.journalid
   LEFT JOIN asutus ON journal.asutusid = asutus.id
   left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1);

ALTER TABLE curjournal OWNER TO vlad;
GRANT SELECT ON TABLE curjournal TO dbkasutaja;
GRANT SELECT ON TABLE curjournal TO dbpeakasutaja;
GRANT SELECT ON TABLE curjournal TO dbvaatleja;

