
CREATE OR REPLACE FUNCTION test_create_tootaja()
  RETURNS integer AS
$BODY$
	declare 
		l_rekvId integer = (select id from rekv order by id desc limit 1);
		l_isikukood varchar(20) = '37303023729';
		l_nimi varchar(254) = 'Vladislav Gordin';
		l_omvorm varchar(20) = 'ISIK';
		l_aadress text = 'Kudrukula';
		l_kontakt text = '';
		l_tel varchar(254) = '53480604';
		l_faks varchar(254) = '';
		l_mail varchar(254) = 'vladislav.giordin@gmail.com';
		l_muud text;
		l_tp varchar(20) = '800699';
		l_mark text;
		l_new_id integer;
		l_aa_id integer;
		l_osakond_id integer;
		l_amet_id integer;
		l_leping_id integer;
		l_palgamaar integer = 0;

begin

	if exists (select id from asutus where regkood = l_isikukood) then
		-- puhastame
		perform sp_del_tooleping(id, 0) from tooleping where parentid in (select id from asutus where regkood = l_isikukood) and rekvid = l_rekvId;
		perform sp_del_asutused(id, 0) from asutus where regkood = l_isikukood;
	end if;

	l_new_id =  sp_salvesta_asutus(0, l_rekvId, l_isikukood, l_nimi, l_omvorm, l_aadress, l_kontakt, l_tel, l_faks, l_mail, l_muud, l_tp, l_mark);

	if l_new_id is null or l_new_id = 0 then
		raise exception 'test_create_tootaja failed' ;
	end if;

	-- salvesta aa andmed
	
	insert into asutusaa (parentId, aa, pank) values (l_new_id, '1234567890', '767')  RETURNING id into l_aa_id ;

	-- uus osakond

	l_osakond_id = test_create_osakond();

	-- uus amet

	l_amet_id = test_create_amet(l_osakond_id);
	-- tooleping

	
	l_leping_id = sp_salvesta_tooleping(0, l_new_id, l_osakond_id, l_amet_id, date(year(date()), 1, 1), null::date, 8, 1000, l_palgamaar, 1, 100, 0, 1, 0, '', null::text, l_rekvId, 1, 'EE'::character varying, null::date, 'EUR',1);
	raise notice 'lepingId: %', l_leping_id;

	if empty (l_new_id) or empty(l_leping_id)then
		raise exception 'test_create_tootaja failed l_new_id: %,  l_leping_id %',l_new_id,  l_leping_id;
	end if;

	-- palk_kaart

	if test_create_palk_kaart(l_leping_id) = 0 then
		raise exception 'test_create_tootaja failed, palk_kaart';
	end if;


	raise notice 'test_create_tootaja success, id = %, aa_id = %, l_leping_id %', l_new_id, l_aa_id, l_leping_id;

         return l_new_id;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;


select test_create_tootaja();

