-- Function: trigd_journal1_after()

-- DROP FUNCTION trigd_journal1_after();

CREATE OR REPLACE FUNCTION trigd_journal1_after()
  RETURNS trigger AS
$BODY$
declare 
	v_journal record;
begin

	select * into v_journal from journal where id = old.parentid;

	delete from dokvaluuta1 where dokid = old.id and dokliik = 1;

	--reklmaks
	delete from ettemaksud where journalid = old.id;
	
	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigd_journal1_after() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigd_journal1_after() TO vlad;
GRANT EXECUTE ON FUNCTION trigd_journal1_after() TO public;
GRANT EXECUTE ON FUNCTION trigd_journal1_after() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigd_journal1_after() TO dbpeakasutaja;
