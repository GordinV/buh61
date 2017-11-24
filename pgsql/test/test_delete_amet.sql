
CREATE OR REPLACE FUNCTION test_delete_amet(t_id integer)
  RETURNS integer AS
$BODY$
	declare 
		l_success integer = 0;
begin
	l_success = sp_del_ametid(t_id, 0);

	if l_success is null or l_success = 0 then
		raise exception 'test_delete_amet  failed %', l_success;
	end if;

	raise notice 'test_delete_amet %', l_success;

         return l_success;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  cost 100;

  --select test_delete_amet(0);