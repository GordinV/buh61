
CREATE OR REPLACE FUNCTION test_delete_library(t_id integer)
  RETURNS integer AS
$BODY$
	declare 
		l_success integer = 0;
begin
	l_success = sp_del_library(t_id);

	if l_success is null or l_success = 0 then
		raise exception 'test_delete_library  failed %', l_success;
	end if;

	raise notice 'test_delete_library %', l_success;

         return l_success;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;


--select test_delete_library(655918);