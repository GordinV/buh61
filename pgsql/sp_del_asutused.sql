-- Function: sp_del_asutused(integer, integer)

DROP FUNCTION if exists sp_del_asutused(integer, integer);

CREATE OR REPLACE FUNCTION sp_del_asutused(integer, integer)
  RETURNS smallint AS
$BODY$
declare 	
	tnId alias for $1;
begin
	DELETE FROM asutusaa WHERE parentid = tnId;
	DELETE FROM asutus WHERE id = tnId;
	if found then
		Return 1;
	else
		Return 0;
	end if;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_del_asutused(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_del_asutused(integer, integer) TO dbpeakasutaja;
