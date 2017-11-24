
CREATE OR REPLACE FUNCTION test_create_amet(t_osakond_id integer)
  RETURNS integer AS
$BODY$
	declare 
		l_rekvId integer = (select id from rekv order by id desc limit 1);
		l_osakond_id integer;
		l_success integer = 0;
		l_kood varchar(20) = 'test-amet';
		l_nimetus varchar(254) = 'test-amet-nimetus';
		l_library varchar(20) = 'AMET';
		l_muud text;
		l_kogus numeric = 1;
		l_tunnus_id integer = 0;
		l_vaba numeric = 0;
		l_palga_maar integer = 1;
begin
	-- puhastame eelmise testi andmed

	if (select count(id) from library where library = l_library and kood = l_kood and rekvid = l_rekvId) > 0 then
		perform test_delete_amet(id) as deleted_id from library where library = l_library and kood = l_kood and rekvid = l_rekvId;
	end if;	

	if t_osakond_id is null or (select count(id) from library where id = t_osakond_id) = 0 then
		raise exception 'Puudub osakond %', t_osakond_id;
	end if;

	l_success = sp_salvesta_palk_amet(0, l_rekvId, l_kood, l_nimetus, t_osakond_id,l_kogus, l_tunnus_id, l_vaba, l_palga_maar);


	if l_success is null or l_success = 0 then
		raise exception 'test_create_osakond failed %', l_success;
	end if;

	raise notice 'test_create_amet success, id = %', l_success;

         return l_success;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

--select test_create_amet(0);