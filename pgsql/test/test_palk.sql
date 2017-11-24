
CREATE OR REPLACE FUNCTION test_palk(tnLepingId integer, tdKpv date)
  RETURNS integer AS
$BODY$
declare
	l_success integer = coalesce(tnLepingId,0);
	l_kpv date = coalesce(tdKpv,date(2017,01,31));
	l_arv_summa numeric(14,2);
begin

	-- uus tootaja test

	if empty(l_success) then
		l_success = (select a.id from asutus a inner join tooleping t on t.parentid = a.id and a.regkood = '37303023729' order by id desc limit 1);
	end if;
	
	if l_success is null then
		l_success = test_create_tootaja();
	end if;
	
	if l_success is null or l_success = 0 then
		raise exception 'test palk failed, tootaja ei ole salvestatud %',l_success ;
	end if;

	-- taabel 

	
	perform test_create_taabel(id, l_kpv) from tooleping where parentid = l_success;

	if (select count(id) from palk_taabel1 where toolepingid in (
		select id from tooleping where parentid = l_success
		)) = 0 then

		raise notice 'test palk failed, taabel puudub';
	end if; 


	-- arvestus	

	update aasta set kinni = 0 where kuu = month(l_kpv) and aasta = year(l_kpv) and rekvid = (select rekvid from tooleping where parentid = l_success order by id desc limit 1);

	update tooleping set palk = 300 where parentid = l_success;

	perform test_create_palk_arvestus(id::integer, l_kpv) from tooleping where parentid = l_success;

	if (select count(id) from palk_oper where lepingid in (
		select id from tooleping where parentid = l_success
		) and kpv = l_kpv) = 0 then

		raise notice 'test palk failed, palk arvestus puudub';
	end if; 

	-- min. sots test

	if (select sum(po.summa) 
		from palk_oper po
		inner join tooleping t on t.id = po.lepingid
		inner join palk_lib pl on pl.parentid = po.libId
		
		where t.parentid = l_success
		and pl.liik = 1
		and month(kpv) = month(l_kpv)
		and year(kpv) = year(l_kpv)) < 430 then

		-- peaks min.sots arveststus

		if empty((select sum(summa) 
			from palk_oper po
			inner join tooleping t on t.id = po.lepingid
			inner join palk_lib pl on pl.parentid = po.libId			
			where t.parentid = l_success
			and pl.liik = 5
			and month(kpv) = month(l_kpv) and year(kpv) = year(l_kpv)
			and po.sotsmaks <> 0))  then

			raise exception 'test palk min.sots arvesttus fail, peaks != 0';

		end if;	
	else 
		if (select sum(summa) 
			from palk_oper po
			inner join tooleping t on t.id = po.lepingid
			inner join palk_lib pl on pl.parentid = po.libId			
			where t.parentid = l_success
			and pl.liik = 5
			and month(kpv) = month(l_kpv) and year(kpv) = year(l_kpv)
			and po.sotsmaks <> 0) > 0  then

			raise exception 'test palk min.sots arvesttus fail, peaks = 0';

		end if;			
	end if;	

	-- delete tootaja test
/*
	l_success = test_delete_tootaja(l_success);

	if l_success is null or l_success = 0 then
		raise exception 'test palk failed';
	end if;
*/	
	raise notice 'test_palk %', l_success;

         return l_success;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;


select test_palk(null, date(2017,02,28));

/*
select * from palk_oper order by id desc limit 10
*/
