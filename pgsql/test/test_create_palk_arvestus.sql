
CREATE OR REPLACE FUNCTION test_create_palk_arvestus(t_toolepind_id integer, t_kpv date)
  RETURNS integer AS
$BODY$
	declare 
		l_rekvId integer = (select id from rekv order by id desc limit 1);
		l_leping_id integer = coalesce(t_toolepind_id, 0);
		l_kpv date = coalesce(t_kpv, (date(year(date()), month(date()),1) + interval '1 month' - interval '1 day')::date );
		l_hours numeric(14,4) = 0;
		l_success integer = 0;
		l_palk_oper_id integer;
		v_palk_kaart record;
begin
	if l_leping_id = 0 then
		raise exception 'test_create_palk_arvestus, no lepingId %',t_toolepind_id;
	end if;

	raise notice 'start arvestus: lepingId %', l_leping_id;
	for v_palk_kaart in 
		select l.kood, pk.* 
			from palk_kaart pk 
			inner join library l on l.id = pk.libId
			inner join   Palk_lib pl on pl.parentId = l.id
			where lepingid = l_leping_id and status = 1
			order by liik, case when empty(pl.tululiik) then 99::text else tululiik end, Pk.percent_ desc, pk.summa desc 
	loop
		l_palk_oper_id = gen_palkoper(l_leping_id, v_palk_kaart.libId, 0, l_kpv, 0, 1);

		if l_palk_oper_id is null or l_palk_oper_id = 0 then
			raise exception 'test_create_palk_arvestus failed, palk operatsioon ei ole salvestatud: kood -> %, id %', v_palk_kaart.kood, l_palk_oper_id;
		end if;
	end loop;


	select count(id) into l_success from palk_oper where lepingid = l_leping_id and kpv = l_kpv;

	if l_success is null or l_success = 0 then
		raise exception 'test_create_palk_arvestus failed, palk operatsioonid puuduvad: l_success %', l_success;
	end if;

/*
	if l_hours <>  l_kontrol_hours then
		raise exception 'test_create_palk_arvestus, arvestatud tunnis ei soobib: arvestatud -> %,  peaks olla-> %', l_hours, l_kontrol_hours;
	end if;
*/
	raise notice 'test_create_palk_arvestus success, l_success = %', l_success;

         return l_success;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

--select test_create_palk_arvestus(0, null);