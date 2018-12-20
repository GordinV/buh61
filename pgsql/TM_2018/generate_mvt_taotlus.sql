drop function if exists generate_mvt_taotlus(integer);

CREATE OR REPLACE FUNCTION generate_mvt_taotlus(tn_rekvid integer)
  RETURNS void AS
$BODY$
declare v_isik record;
declare v_leping record;
l_mvt numeric(14,2) = 500;
l_id integer;
l_count integer = 0;
l_count_mvt integer = 0;
begin

for v_isik in 
	select i.id, i.regkood, i.nimetus, count(t.id) as count
	from asutus i 
	inner join tooleping t on t.parentid = i.id
	where (t.lopp is null or t.lopp > date(2018,01,01))
	and t.rekvid in (select id from rekv where (id = tn_rekvid or parentid = tn_rekvid))
--	and i.id = 2894
	group by t.parentid, i.regkood, i.nimetus, i.id
loop
	raise notice 'v_isik.id-> %, %', v_isik.regkood, v_isik.nimetus;
	-- tootajad pohi koht

	select sum(summa), count(id) into l_mvt, l_count_mvt from taotlus_mvt where lepingid in (select id from tooleping where parentid = v_isik.id);
	l_mvt = 500 - coalesce(l_mvt,0);
	
	if l_mvt < 0 then
		l_mvt = 0;
	end if;

	--tvl

	if not exists (select id from tooleping t
		where t.rekvid in (select id from rekv where (id = tn_rekvid or parentid = tn_rekvid)) 
		and (t.lopp is null or t.lopp > date(2018,01,01))
		and t.pohikoht = 1) then
		-- found tvl -> mvt = 0;
		l_mvt = 0;	
		raise notice 'TVL, mvt = 0';
	end if;

	
	for v_leping in 
	select *
		from tooleping t
		where parentId = v_isik.id
		and (t.lopp is null or t.lopp > date(2018,01,01))
		and t.rekvid in (select id from rekv where (id = tn_rekvid or parentid = tn_rekvid))
		order by pohikoht desc
	loop

	
		raise notice 'v_leping.id-> %', v_leping.id;
		if not exists (select id from taotlus_mvt where lepingid = v_leping.id) then
			l_id = sp_salvesta_taotlus_mvt(0, v_leping.rekvid, v_leping.parentid, date(2018,01,02), date(2018,01,01), date(2018,12,31), v_leping.id, l_mvt, 'Koostatud automaatselt');			
			raise notice 'salvestatud, id-> %', l_id;
		else 
			raise notice 'pole vaja';
		end if;	
		l_mvt = 0;
		l_count = l_count + 1;
	end loop;	
end loop;
raise notice 'Kokku %', l_count;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;	


/*
delete from taotlus_mvt
*/
select generate_mvt_taotlus(1);  