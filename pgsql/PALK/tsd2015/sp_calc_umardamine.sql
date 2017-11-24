 
CREATE OR REPLACE FUNCTION sp_calc_umardamine(integer, date, integer)
  RETURNS numeric AS
$BODY$
declare
	tnIsikId alias for $1;
	tdKpv alias for $2;
	tnRekvId alias for $3;
	v_tululiik record;
	lnSumma numeric(14,4);
	v_leping record;
	lcTimestamp varchar(20); 
	v_arv record;
	v_fakt_arv record;
	l_arv_count integer;
begin
	-- kustutame eelamise arvestus
	delete from palk_oper po 
		where po.lepingId in (
					select id from tooleping 
					where parentId = tnIsikId 
					)
		and po.kpv >= date(year(tdKpv), month(tdKpv), 1) and kpv <= tdKpv
		and po.rekvId = tnRekvId
		and po.summa = 0;

	-- arvestame 

	for v_tululiik in 	
		select  pl.tululiik, sum(po.summa) as summa, count(po.id) as arv_count
			from palk_oper po
			inner join library l on l.id = po.libid
			inner join palk_lib pl on pl.parentid = l.id
			where po.lepingId in (
					select id from tooleping 
					where parentId = tnIsikId 
					)
			and po.kpv >= date(year(tdKpv), month(tdKpv), 1) and kpv <= tdKpv
			--and po.kpv = tdKpv
			and po.rekvId = tnRekvId
			and pl.liik = 1
			group by pl.tululiik,pl.liik
			order by pl.liik	
	loop
		if v_tululiik.arv_count > 1 then 
			select  po.* into v_leping
				from palk_oper po
				inner join library l on l.id = po.libid
				inner join palk_lib pl on pl.parentid = l.id
				inner join tooleping t on t.id = po.lepingId
				where t.parentId = tnIsikId 
				and po.kpv = tdKpv
				and po.rekvId = tnRekvId
				and pl.liik = 1
				and pl.tululiik = v_tululiik.tululiik
				order by t.pohikoht desc, po.summa desc limit 1;

			if lcTimestamp is null then
				lcTimestamp = left('ARV'+LTRIM(RTRIM(str(v_leping.LepingId)))+LTRIM(RTRIM(str(v_leping.LibId)))+ltrim(rtrim(str(dateasint(tdKpv)))),20);
			end if;
		
			lnSumma = sp_calc_arv(v_leping.lepingId, v_leping.libId, v_leping.kpv, v_tululiik.summa, null);
			raise notice 'v_tululiik.tululiik %, v_tululiik.summa %, lnSumma %, v_leping.lepingId %',v_tululiik.tululiik, v_tululiik.summa, lnSumma, v_leping.lepingId ;

			select tasun1 as Tulubaas,round(volg1,2) as tm,  round(volg2,2) as sm, round(volg4,2) as tki, round(volg5,2) as pm, round(volg6,2) as tka, muud into v_arv
				from tmp_viivis
				where alltrim(timestamp) = alltrim(lcTimestamp);
				
			select sum(tulumaks) as tm, sum(sotsmaks) as sm, sum(tootumaks) as tki,  sum(pensmaks) as pm, sum(tka) as tka into v_fakt_arv
				from palk_oper po
				inner join library l on l.id = po.libid
				inner join palk_lib pl on pl.parentid = l.id
				where po.lepingId in (
						select id from tooleping 
						where parentId = tnIsikId 
						)
			--	and po.kpv = tdKpv
				and po.kpv >= date(year(tdKpv), month(tdKpv), 1) and kpv <= tdKpv
				and po.rekvId = tnRekvId
				and pl.liik = 1
				and pl.tululiik = v_tululiik.tululiik;

			raise notice 	'tulubaas %,tm %,  sm %, tki %, tka %, pm %', v_arv.tulubaas, v_arv.tm - round(v_fakt_arv.tm,2), v_arv.sm - round(v_fakt_arv.sm,2), 
				v_arv.tki-round(v_fakt_arv.tki,2), v_arv.tka - round(v_fakt_arv.tka,2), v_arv.pm - round(v_fakt_arv.pm,2);
				v_arv.tulubaas = null;

			if v_arv.tm - round(v_fakt_arv.tm,2) <> 0 or 
				v_arv.sm - round(v_fakt_arv.sm,2) <> 0 or
				v_arv.tki-round(v_fakt_arv.tki,2) <> 0 or
				v_arv.tka - round(v_fakt_arv.tka,2) <> 0 or
				v_arv.pm - round(v_fakt_arv.pm,2) <> 0 
				then

				perform sp_salvesta_palk_oper(0, tnRekvId, v_leping.libId, v_leping.lepingId, tdKpv, 0, v_leping.Doklausid, 'Ümardamine' + v_arv.muud, 
					ifnull(v_leping.kood1,space(1)),ifnull(v_leping.kood2,'LE-P'), ifnull(v_leping.kood3,space(1)), 
					ifnull(v_leping.kood4,space(1)), ifnull(v_leping.kood5,space(1)), ifnull(v_leping.konto,space(1)), 
					 v_leping.tp, v_leping.tunnus,'EUR', 1,v_leping.proj,
					v_tululiik.tululiik::integer, ifnull(v_arv.tm - round(v_fakt_arv.tm,2),0), ifnull(v_arv.sm - round(v_fakt_arv.sm,2),0), ifnull(v_arv.tki-round(v_fakt_arv.tki,2),0), ifnull( v_arv.pm - round(v_fakt_arv.pm,2),0), 
					ifnull(v_arv.tulubaas,0), coalesce(v_arv.tka - round(v_fakt_arv.tka,2),0), null::date);

			end if;
		end if; -- arv count peaks rohkem kui 1
	end loop;					

	return 0;
end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


select  sp_calc_umardamine(961, date(2016,01,31),63)

/*
select * from asutus where regkood = '36304283734'

select count(*) from asutus

select * from rekv where parentid = 119 and nimetus ilike '%paem%' order by id desc

select * from palk_oper where lepingid in (select id from tooleping where parentid = 35105) order by id desc limit 10
-- 4192399

SELECT Palk_oper.id, palk_oper.libId, palk_lib.liik 
		FROM Palk_oper 
		inner join palk_lib on palk_oper.libId = palk_lib.Parentid
		WHERE Palk_oper.libId = 585455   
		AND Palk_oper.kpv = date(2015, 11, 30)
		AND Palk_oper.LepingId = 136430
		and palk_lib.liik not in (6,9) 
	--	and palk_oper.id <> tnid 
		and palk_oper.summa <> 0 


*/