-- Function: trigd_arved_after()

-- DROP FUNCTION trigd_arved_after();

CREATE OR REPLACE FUNCTION trigd_arved_after()
  RETURNS trigger AS
$BODY$
declare 
	lnCount int4;
	
begin
--	lnCount:=sp_recalc_ladujaak(old.RekvId,0,old.Id);
	IF old.JournalId > 0 then
		  lnCount:= sp_del_journal(old.journalId,1);
	end if;
	-- kustutan valuuta infot;
	delete from dokvaluuta1 where dokid = old.id and dokliik = 3;
		perform sp_register_oper(old.rekvid,old.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, old.rekvid));
	return NULL;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigd_arved_after() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigd_arved_after() TO vlad;
GRANT EXECUTE ON FUNCTION trigd_arved_after() TO public;
GRANT EXECUTE ON FUNCTION trigd_arved_after() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigd_arved_after() TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION trigd_arved_after() TO dbadmin;
GRANT EXECUTE ON FUNCTION trigd_arved_after() TO dbvaatleja;
