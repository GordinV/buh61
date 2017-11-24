-- 

CREATE OR REPLACE FUNCTION test_create_osakond()
  RETURNS integer AS
$BODY$
	declare 
		l_rekvId integer = (select id from rekv order by id desc limit 1);
		l_success integer = 0;
		l_kood varchar(20) = 'test-osakond';
		l_nimetus varchar(254) = 'test-osakond-nimetus';
		l_library varchar(20) = 'OSAKOND';
		l_muud text;
begin
	-- puhastame eelmise testi andmed

	if (select count(id) from library where library = l_library and kood = l_kood and rekvid = l_rekvId) > 0 then
		perform test_delete_library(id) as deleted_id from library where library = l_library and kood = l_kood and rekvid = l_rekvId;
--		l_success = test_delete_library(t_id integer)
	end if;

	l_success = sp_salvesta_library(0, l_rekvId, l_kood, l_nimetus, l_library, l_muud, 0, 0, 0, 0, 0);

	if l_success is null or l_success = 0 then
		raise exception 'test_create_osakond failed %', l_success;
	end if;

	raise notice 'test_create_osakond, id = %', l_success;

         return l_success;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;


--select test_create_osakond();