-- View: cursaldo

--DROP VIEW cursaldo;


/*

SELECT journal.id, journal.rekvid, journal.kpv, journal.asutusid, "month"(journal.kpv) AS kuu, "year"(journal.kpv) AS aasta, journal.selg::character varying(254) AS selg, journal.dok, journal1.summa,  journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood4, journal1.kood5, journal1.proj, journal1.deebet, journal1.kreedit, journal1.lisa_d, journal1.lisa_k, ifnull(ltrim(rtrim(asutus.nimetus::text))::bpchar + space(1) + ltrim(rtrim(asutus.omvorm::text))::bpchar, space(120)) AS asutus, journal1.tunnus, journalid.number , journal.muud::character varying(254) AS muud, ifnull(userid.ametnik,space(1)) as kasutaja, journal1.proj, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, ifnull(dokvaluuta1.valuuta,'EEK')::varchar(20) as valuuta  FROM journal  JOIN journal1 ON journal.id = journal1.parentid JOIN journalid ON journal.id = journalid.journalid   LEFT JOIN asutus ON journal.asutusid = asutus.id left outer join userid on userid.id = journal.userid LEFT OUTER JOIN dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1)
*/

CREATE OR REPLACE VIEW cursaldo AS 
	SELECT journal.kpv, journal.rekvid,   journal1.deebet AS KONTO, 
	(journal1.summa * ifnull(dokvaluuta1.kuurs,1))::numeric as deebet, 0::numeric(12,4) AS kreedit, 
	 4 AS opt, journal.asutusid    
	 FROM journal  JOIN journal1 ON journal.id = journal1.parentid JOIN journalid ON journal.id = journalid.journalid   
	 LEFT OUTER JOIN dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1)
UNION ALL 
	SELECT journal.kpv, journal.rekvid,   journal1.kreedit AS KONTO, 
	0::numeric(12,4) AS deebet, (journal1.summa * ifnull(dokvaluuta1.kuurs,1))::numeric as kreedit,  
	 4 AS opt, journal.asutusid     
	 FROM journal  JOIN journal1 ON journal.id = journal1.parentid JOIN journalid ON journal.id = journalid.journalid   
	 LEFT OUTER JOIN dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1);

ALTER TABLE cursaldo OWNER TO vlad;
GRANT ALL ON TABLE cursaldo TO vlad;
GRANT SELECT ON TABLE cursaldo TO dbpeakasutaja;
GRANT SELECT ON TABLE cursaldo TO dbkasutaja;
GRANT SELECT ON TABLE cursaldo TO dbadmin;
GRANT SELECT ON TABLE cursaldo TO dbvaatleja;

