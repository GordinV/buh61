-- Function: test_create_palk_kaart(integer)

-- DROP FUNCTION test_create_palk_kaart(integer);

CREATE OR REPLACE FUNCTION test_create_palk_kaart(t_leping_id integer)
  RETURNS integer AS
$BODY$
declare
	l_success integer = 0;
	l_rekvId integer = (select id from rekv order by id desc limit 1);
	l_count integer = 0;
	l_lib_id integer;
	l_parent_id integer = (select parentid from tooleping where id = t_leping_id order by id desc limit 1);
begin
	if (select count(id) from userid where rekvid = l_rekvId and kasutaja = CURRENT_USER::VARCHAR) = 0 then
		insert into userid (rekvid, kasutaja, ametnik, kasutaja_) values (l_rekvId, CURRENT_USER::VARCHAR, CURRENT_USER::VARCHAR, 1);
	end if;

	delete from library where rekvid = l_rekvId and library = 'PALK' and kood in ('TEST_PALK','TEST_SOTS', 'TEST_TULUMAKS', 'TEST_PM', 'TEST_TKI', 'TEST_TKA', 'TEST_TASU');

	if t_leping_id is null then 
		raise exception 'test_create_palk_kaart, puudub lepingId, test failed';
	end if;

	-- puhastame eelmise testi andmed

	if (select count(id) from palk_kaart where lepingid = t_leping_id) > 0 then
		delete from palk_kaart where lepingid = t_leping_id;
	end if;

	-- PALK

	l_lib_id = test_create_palk_lib(1, 'TEST_PALK', 1);

	
	l_success = sp_salvesta_palk_kaart(0, l_parent_id, t_leping_id, l_lib_id, 100, 1, 1, 1, 1, null, 0, 0, 'EUR', 1, 0);

	if l_success is null or l_success = 0  then
		raise exception 'test_create_palk_kaart, id -> 0000 %', l_success;
	end if;

	l_lib_id = test_create_palk_lib(5, 'TEST_SOTS', 5);
	l_success = sp_salvesta_palk_kaart(0, l_parent_id, t_leping_id, l_lib_id, 33, 1, 0, 1, 1, null, 0, 0, 'EUR', 1, 1);


	if l_success is null or l_success = 0  then
		raise exception 'test_create_palk_kaart, id %', l_success;
	end if;

	l_lib_id = test_create_palk_lib(4, 'TEST_TULUMAKS', 4);
	l_success = sp_salvesta_palk_kaart(0, l_parent_id, t_leping_id, l_lib_id, 20, 1, 0, 1, 1, null, 0, 0, 'EUR', 1, 0);


	if l_success is null or l_success = 0  then
		raise exception 'test_create_palk_kaart, id %', l_success;
	end if;

	l_lib_id = test_create_palk_lib(8, 'TEST_PM', 8);
	l_success = sp_salvesta_palk_kaart(0, l_parent_id, t_leping_id, l_lib_id, 2, 1, 1, 1, 1, null, 0, 0, 'EUR', 1, 0);


	if l_success is null or l_success = 0  then
		raise exception 'test_create_palk_kaart, id %', l_success;
	end if;

	l_lib_id = test_create_palk_lib(7, 'TEST_TKI', 7);
	l_success = sp_salvesta_palk_kaart(0, l_parent_id, t_leping_id, l_lib_id, 1.6, 1, 1, 1, 1, null, 0, 0, 'EUR', 1, 0);


	if l_success is null or l_success = 0  then
		raise exception 'test_create_palk_kaart, id %', l_success;
	end if;

	l_lib_id = test_create_palk_lib(7, 'TEST_TKA', 7);
	l_success = sp_salvesta_palk_kaart(0, l_parent_id, t_leping_id, l_lib_id, 0.8, 1, 0, 1, 1, null, 0, 0, 'EUR', 1, 0);


	if l_success is null or l_success = 0  then
		raise exception 'test_create_palk_kaart, id %', l_success;
	end if;

	l_lib_id = test_create_palk_lib(6, 'TEST_TASU', 6);
	l_success = sp_salvesta_palk_kaart(0, l_parent_id, t_leping_id, l_lib_id, 100, 1, 0, 1, 1, null, 0, 0, 'EUR', 1, 0);


	if l_success is null or l_success = 0  then
		raise exception 'test_create_palk_kaart, id %', l_success;
	end if;


	raise notice 'test_create_palk_lib success %', l_success;

         return l_success;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION test_create_palk_kaart(integer) OWNER TO vlad;


select test_create_palk_kaart(id) from tooleping where parentid =41067
