
CREATE OR REPLACE FUNCTION test_create_taabel(t_toolepind_id integer, t_kpv date)
  RETURNS integer AS
$BODY$
	declare 
		l_rekvId integer = (select id from rekv order by id desc limit 1);
		l_leping_id integer = coalesce(t_toolepind_id, 0);
		l_kpv date = coalesce(t_kpv, (date(year(date()), month(date()),1) + interval '1 month' - interval '1 day')::date );
		l_hours numeric(14,4) = 0;
		l_success integer = 0;
		l_kontrol_hours numeric(14,4) = case when month(l_kpv) = 1 then 176 else 162 end;
begin
	if l_leping_id = 0 then
		raise exception 'test_create_taabel failed, no lepingId %',t_toolepind_id;
	end if;

	l_hours = gen_taabel1(l_leping_id, month(l_kpv), year(l_kpv));
	

	select id into l_success from palk_taabel1 where toolepingid = l_leping_id and kuu =  month(l_kpv) and aasta = year(l_kpv);

	if l_hours is null or l_hours = 0 or l_success is null then
		raise exception 'test_create_taabel failed, no tootunnid voi puudub taable hours: %, l_success %', l_hours, l_success;
	end if;
/*
	if l_hours <>  l_kontrol_hours then
		raise exception 'test_create_taabel failed, arvestatud tunnis ei soobib: arvestatud -> %,  peaks olla-> %', l_hours, l_kontrol_hours;
	end if;
*/
	raise notice 'test_create_taabel success, hours = %', l_hours;

         return l_success;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

--select test_create_taabel(0, null);