
CREATE OR REPLACE FUNCTION test_min_sots(integer, date)
  RETURNS integer AS
$BODY$
declare
	tnLepingid alias for $1;
	tdKpv alias for $2;

	l_success integer = 0;
	l_kpv date = coalesce(tdKpv, date(2017,02,28));
	l_leping_id integer;
	l_palk_kaart_id integer;
	l_tulemus numeric[];
	l_sotsmaks numeric;
	l_summa numeric;
begin
	raise notice 'test for pohikoht, ootame tagasi null arvestus ';
	l_leping_id = (select id from tooleping 
		where (lopp is null or lopp <= l_kpv)
		and pohikoht = 0
		and parentid in (select parentid from tooleping where id = tnLepingId)
		order by id desc limit 1
		);
		
	l_tulemus =  sp_calc_min_sots(l_leping_id, l_kpv);
	if l_tulemus is null then
		raise notice 'test Ok %', l_tulemus;
	else 
		raise exception 'test for pohikoht,  %', l_tulemus;
	end if;

	raise notice 'test for min.palk, ootame tagasi null arvestus ';
	l_palk_kaart_id = (select pk.id
		from palk_kaart pk 
		inner join palk_lib pl on pl.parentid = pk.libId
		where pk.lepingid = tnLepingid 
		and pl.liik = 5
		and pk.status = 1
		and coalesce(pk.minsots,0) = 1
		order by id desc limit 1);

	update 	palk_kaart set minsots = 0 where id =  	l_palk_kaart_id;
		
	l_tulemus =  sp_calc_min_sots(tnLepingid, l_kpv);
	if l_tulemus is null then
		update 	palk_kaart set minsots = 1 where id =  	l_palk_kaart_id;
		raise notice 'test Ok %', l_tulemus;

	else 
		raise exception 'test for pohikoht,  %', l_tulemus;
	end if;

	
	raise notice 'test for arvestus, ootame';
	
	l_tulemus =  sp_calc_min_sots(tnLepingid, l_kpv);
	if l_tulemus is null then
		raise exception 'test for arvestus, ei pea null  %', l_tulemus;
	end if;
	l_sotsmaks = l_tulemus[1];
	l_summa = l_tulemus[2];

	if l_summa > 0 and (l_sotsmaks = 0 or l_sotsmaks is null) then
		raise exception 'test for arvestus, sotsmaks > 0  %, l_summa %', l_sotsmaks, l_summa;
	end if;

	if round(l_summa * 0.33,2) <> round(l_sotsmaks, 2) and abs(l_sotsmaks - l_summa * 0.33) > 1 then
		raise exception 'test for arvestus, sotsmaks != 0.33 * %,%, %', l_summa, (l_summa * 0.33), l_sotsmaks;
	end if;
	

	l_success = 1;
	raise notice 'test Ok %, arvestus %', l_tulemus, l_summa * 0.33;


         return l_success;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;


select test_min_sots(142086, date(2017,02,28));

/*

select * from palk_kaart where lepingid = 142086

select * from palk_oper order by id desc limit 10

select * from tooleping where id =33155

select * from asutus where nimetus ilike 'lall%'

*/