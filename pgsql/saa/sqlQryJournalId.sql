-- View: curjournal

 --DROP VIEW qryJournalId;

CREATE OR REPLACE VIEW qryJournalId AS 
 SELECT journalid.id, journalid.number, journalid.rekvid, journalid.aasta, journal1.id as journal1id
   from journalid
   JOIN journal1 ON journalid.journalid = journal1.parentid;
 
ALTER TABLE qryJournalId OWNER TO vlad;
GRANT SELECT ON TABLE qryJournalId TO dbkasutaja;
GRANT SELECT ON TABLE qryJournalId TO dbpeakasutaja;
GRANT SELECT ON TABLE qryJournalId TO dbvaatleja;
GRANT SELECT ON TABLE qryJournalId TO dbadmin;

