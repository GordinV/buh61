DROP FUNCTION if exists round_maksud(integer, date, integer);

CREATE OR REPLACE FUNCTION round_maksud(
    integer,
    date,
    integer)
  RETURNS boolean AS
$BODY$
declare 
	tnIsikId alias for $1;
	tdDate alias for $2;
	tnRekvId alias for $3;

	l_tulemus boolean = false;
	l_tulud numeric(14,2) = 0;
	l_pm numeric(14,2) = 0;
	l_tki numeric(14,2) = 0;
	l_tapsestus numeric(14,2) = 0;

	v_leping record;
	lnPalkOperId integer;
begin
	-- kontrollime arvestused
	if (select count(id) 
		from palk_oper 
		where lepingid in (select id from tooleping where parentid = tnIsikId) 
		and kpv = tdDate 
		and libId in (select parentid from palk_lib where liik = 1)) > 1 then
		-- on arvestused. rohkem kui 1
		-- Tulud
		select sum(summa) into l_tulud 
			from palk_oper po 
			inner join palk_lib pl on pl.parentid = po.libid
			where lepingid in (select id from tooleping where parentid = tnIsikId and rekvid = tnRekvId)
			and kpv = tdDate
			and libId in (select l.id from palk_lib pl inner join library l on l.id = pl.parentid where rekvid = tnRekvId and liik = 1);

		
		-- arvestame PM
		select sum(summa) into l_pm 
			from palk_oper po
			inner join palk_lib pl on pl.parentid = po.libid
			where lepingid in (select id from tooleping where parentid = tnIsikId and rekvid = tnRekvId)
			and kpv = tdDate
			and libId in (select l.id from palk_lib pl inner join library l on l.id = pl.parentid where rekvid = tnRekvId and liik = 8);
			
		
		l_tapsestus = l_tulud * (select summa 
			from palk_kaart 
			where lepingId in (select id from tooleping where parentid = tnIsikId and rekvid = tnRekvId and pohikoht = 1) 
			and libId in (select l.id from palk_lib pl inner join library l on l.id = pl.parentid where rekvid = tnRekvId and liik = 8) -- PM
			and status = 1 
			order by id desc limit 1
			) * 0.01 - l_pm;

		raise notice 'l_tulud %, l_pm  %, l_tapsestus %', l_tulud, l_pm, l_tapsestus;

		if l_tapsestus <> 0 then 
			l_tulemus = true;
			l_tapsestus = 0;
		end if;	


		-- arvestame TKI
		select lepingId, libId, doklausId, kood1, kood2, kood3, kood4, kood5, proj, konto, tp, tunnus, journal1id AS tululiik into v_leping
				from palk_oper po
				where po.libId in (select l.id from palk_lib pl inner join library l on l.id = pl.parentid where rekvid = tnRekvId and liik = 7 and asutusest = 0) 
				and lepingid in (select id from tooleping where parentid = tnIsikId and rekvid = tnRekvId and pohikoht = 1)
				and date = tdDate
				limit 1;
		if found then
			-- on maksuarvestus
			select sum(summa) into l_tki 
				from palk_oper po
				inner join palk_lib pl on pl.parentid = po.libid
				where lepingid in (select id from tooleping where parentid = tnIsikId and rekvid = tnRekvId)
				and kpv = tdDate
				and libId in (select l.id from palk_lib pl inner join library l on l.id = pl.parentid where rekvid = tnRekvId and liik = 7 and asutusest = 0);
				
			if (l_tki > 0) then
				l_tapsestus = l_tulud * (select summa 
					from palk_kaart 
					where lepingId in (select id from tooleping where parentid = tnIsikId and rekvid = tnRekvId and pohikoht = 1) 
					and libId in (select l.id from palk_lib pl inner join library l on l.id = pl.parentid where rekvid = tnRekvId and liik = 7 and asutusest = 0) -- PM
					and status = 1 
					order by id desc limit 1
					) * 0.01 - l_tki;
			end if;
		end if;	

		if l_tapsestus <> 0 then
			-- kustutame vana

			--delete from palk_oper where libid = v_leping.libId and kpv = tdKpv and lepingId = v_leping.lepingid and selg = 'Umardamine';	
			
			lnPalkOperId = sp_salvesta_palk_oper(0, tnRekvid, v_leping.libId, v_leping.lepingid, tdKpv, l_tapsestus, v_leping.Doklausid, 'Umardamine', 
				v_leping.kood1,v_leping.kood2, v_leping.kood3, v_leping.kood4, v_leping.kood5, v_leping.konto, v_leping.tp,v_leping.tunnus,
				'EUR', 1,v_leping.proj, v_leping.tululiik,0, 0, 0, 0, 0, 0, null::date);
			
			raise notice 'l_tulud %, l_tki  %, l_tapsestus %, lnPalkOperId %', l_tulud, l_tki, l_tapsestus, lnPalkOperId;

			l_tulemus = true;
			l_tapsestus = 0;
		end if;	

			
	end if;

         return  l_tulemus;
end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


select round_maksud(21923, date(2015,08,31), 121);

/*
select id from asutus where regkood = '48302223720  '
*/
