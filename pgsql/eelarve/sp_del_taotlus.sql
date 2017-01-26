-- Function: sp_del_taotlus(integer, integer)

-- DROP FUNCTION sp_del_taotlus(integer, integer);

CREATE OR REPLACE FUNCTION sp_del_taotlus(integer, integer)
  RETURNS integer AS
$BODY$
declare

	tnId alias for $1;
	v_taotlus record;
begin

	select * into v_taotlus from taotlus where id = tnId;
--	if v_taotlus.staatus > 1 then
--		raise exception 'Ei saa kustuta taotlus';
--	end if;
	delete from eelarve where id in (select eelarveid from taotlus1 where parentid = tnId and eelarveid > 0);
	DELETE FROM taotlus1 WHERE parentId = tnId;
	DELETE FROM taotlus WHERE Id = tnId;

	if found then

		return 1;

	else

		return 0;

	end if;

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_del_taotlus(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_del_taotlus(integer, integer) TO vlad;
