DROP FUNCTION if exists sp_del_taotlus_mvt(integer, integer);

CREATE OR REPLACE FUNCTION sp_del_taotlus_mvt(tnId integer, force integer)
  RETURNS integer AS
$BODY$
declare
	v_taotlus record;
begin

	DELETE FROM taotlus_mvt WHERE Id = tnId;

	if found then

		return 1;

	else

		return 0;

	end if;

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION sp_del_taotlus_mvt(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_del_taotlus_mvt(integer, integer) TO taabel;
GRANT EXECUTE ON FUNCTION sp_del_taotlus_mvt(integer, integer) TO dbpeakasutaja;
