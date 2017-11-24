-- Function: sp_del_arved(integer, integer)

-- DROP FUNCTION sp_del_arved(integer, integer);



CREATE OR REPLACE FUNCTION sp_del_hooleping(integer,integer)
  RETURNS smallint AS
$BODY$

declare 
	tnId alias for $1;
	v_leping record;
begin
	select * into v_leping from hooleping where id = tnId;
	if v_leping.jaak = 0 then
		delete from hooteenused where lepingid = tnId;
		DELETE FROM hooleping WHERE id = tnid;
	else
		raise notice 'jaak > 0';
	end if;
	Return 1;
end; 


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_del_hooleping(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_del_hooleping(integer) TO hkametnik;
GRANT EXECUTE ON FUNCTION sp_del_hooleping(integer) TO soametnik;
