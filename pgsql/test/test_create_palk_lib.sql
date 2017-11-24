
CREATE OR REPLACE FUNCTION test_create_palk_lib(t_liik integer, t_kood varchar(20), t_tund integer)
  RETURNS integer AS
$BODY$
declare
	l_success integer = 0;
	l_rekvId integer = (select id from rekv order by id desc limit 1);
	l_liik integer = coalesce(t_liik, 1);
	l_kood varchar(20) = coalesce(t_kood, 'TEST_PALK');
	l_annuleeritud integer = 0;
	l_liikmemaks integer = 0;
	l_tund integer = coalesce(t_tund, 1);
	l_maks integer = 0;
	l_palgafond integer = 0;
	l_asutussest integer = 0;
	l_sots integer = 1;
	l_konto varchar(20) = '';
	l_elatis integer = 0;
	l_tululiik varchar(20) = '10';
	l_palk_lib_id integer;

begin
	-- puhastame eelmise testi andmed

	if (select count(id) from library where library = 'PALK' and kood = l_kood and rekvid = l_rekvId) > 0 then
		perform test_delete_library(id) as deleted_id from library where library = 'PALK' and kood = l_kood and rekvid = l_rekvId;
	end if;

	raise notice 'puhastatud';
	
	l_success = sp_salvesta_library(0, l_rekvId, l_kood, l_kood, 'PALK', null, l_liikmemaks, 0, 0, 0, l_annuleeritud);

	raise notice 'sp_salvesta_library %',l_success  ;

	insert into palk_lib (parentid, liik, tund, maks ,  palgafond,   asutusest, sots , konto,elatis, tululiik)
		values (l_success, l_liik, l_tund, l_maks, l_palgafond,l_asutussest, l_sots,l_konto, l_elatis, l_tululiik  ) returning id into l_palk_lib_id;

	raise notice 'insert into palk_lib %',l_palk_lib_id  ;

	-- uus kood

	if l_success is null or l_success = 0 or l_palk_lib_id is null then
		raise exception 'test test_create_palk_lib id = %, l_palk_lib_id = %', l_success, l_palk_lib_id;
	end if;
	
	raise notice 'test_create_palk_lib success %', l_success;

         return l_success;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;


select test_create_palk_lib(5, 'TEST_SOTS-1', null);

