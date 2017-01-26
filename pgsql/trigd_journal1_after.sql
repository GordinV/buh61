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
	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigd_journal1_after() OWNER TO vlad;


CREATE TRIGGER trigd_journal1_after
  AFTER DELETE
  ON journal1
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_journal1_after();
