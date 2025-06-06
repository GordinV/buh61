﻿-- Function: sp_del_arved(integer, integer)

-- DROP FUNCTION sp_del_arved(integer, integer);

CREATE OR REPLACE FUNCTION sp_del_arved(integer, integer)
  RETURNS smallint AS
$BODY$


declare 


	tnId alias for $1;
	lnCount int;

	v_arv record;

begin

	select * into v_arv from arv where id = tnId;

	DELETE FROM arv WHERE id = tnid;

	-- arveldused
	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'COUNTER';
	if ifnull(lnCount,0) > 0 then
		update counter set muud = null where ifnull(muud,'null') <> 'null' and muud = ltrim(rtrim(str(tnid)));
	end if; 

	perform sp_recalc_ladujaak (v_arv.rekvid,0,v_arv.id);
	
	Return 1;


end; 


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_del_arved(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_del_arved(integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_del_arved(integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_del_arved(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_del_arved(integer, integer) TO taabel;
