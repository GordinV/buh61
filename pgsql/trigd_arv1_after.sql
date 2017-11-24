-- Function: trigd_arv1_after()

-- DROP FUNCTION trigd_arv1_after();

CREATE OR REPLACE FUNCTION trigd_arv1_after()
  RETURNS trigger AS
$BODY$
declare
lnId		int;
recArv		record; 
begin
	select id into lnId from ladu_grupp where ladu_grupp.nomId = old.nomId;
	if not found then
		return null;
	end if;
	select * into recArv from arv where id = old.parentId;

--	if recArv.operId > 0  and recArv.liik = 1 then
	-- vara sisetulik
--		delete from ladu_jaak where dokItemId = old.id;
--	else
		perform sp_recalc_ladujaak(recArv.rekvId, old.nomId, 0);
--	end if;	

	-- kustutan valuuta info

	delete from dokvaluuta1 where dokid = old.id and dokliik = 2;

	return null;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigd_arv1_after() OWNER TO vlad;


CREATE TRIGGER trigd_arv1_after
  AFTER DELETE
  ON arv1
  FOR EACH ROW
  EXECUTE PROCEDURE trigd_arv1_after();
