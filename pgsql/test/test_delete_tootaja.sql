
CREATE OR REPLACE FUNCTION test_delete_tootaja(t_isik_id integer)
  RETURNS integer AS
$BODY$
declare
	l_success integer = 0;
begin

	perform sp_del_tooleping(id, 0) from tooleping where parentid = t_isik_id;

	l_success = sp_del_asutused(t_isik_id, 0);

	if l_success  is null or l_success = 0 then
		raise exception 'test_delete_tootaja failed %', l_success;
	end if;

	raise notice 'test_delete_tootaja success %', l_success;

         return l_success;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;


--select test_delete_tootaja((select id from asutus where regkood = '37303023721' order by id desc limit 1));
/*
select * from tooleping where parentid = 39772
select sp_del_asutused(39772, 0)
*/

