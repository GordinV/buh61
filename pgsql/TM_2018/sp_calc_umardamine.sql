-- Function: sp_calc_umardamine(integer, date, integer)

-- DROP FUNCTION sp_calc_umardamine(integer, date, integer);

CREATE OR REPLACE FUNCTION sp_calc_umardamine(tnisikid integer, tdkpv date, tnrekvid integer)
  RETURNS numeric AS
$BODY$
declare
	v_tululiik record;
	lnSumma numeric(14,4);
	v_leping record;
	lcTimestamp varchar(20); 
	v_arv record;
	v_fakt_arv record;
	l_arv_count integer; -- tululiige arv
	ldKpv date = gomonth(DATE(year(tdKpv),month(tdKpv),1), 1) - 1;
	l_tulubaas numeric(14,4); --mvt
	l_tulubaas_kokku numeric (14,4); 

	l_mvt_kokku numeric(14,4) = 0;	
	l_pm_kokku numeric(14,4) = 0;	
	l_tk_kokku numeric(14,4) = 0;
	l_tm_kokku numeric(14,4) = 0;
	l_tulu_kokku numeric(14,4) = 0;
	l_mvt_diff numeric(14,4) = 0;
	l_id integer;

	v_max_mvt record; 
	v_miinus_mvt record;
	l_lepingId integer;
	l_libId integer;	
	l_uus_tm numeric(14,4) = 0;	

begin
	-- kustutame eelamise arvestus
	delete from palk_oper po 
		where po.lepingId in (
					select id from tooleping 
					where parentId = tnIsikId 
					)
		and po.kpv >= date(year(tdKpv), month(tdKpv), 1) and kpv <= ldKpv
		and po.rekvId = tnRekvId
		and po.summa = 0;


	  select 0::numeric(14,4) as summa, 0::numeric(14,4) as mvt, 0::numeric(14,4) as tm, 0::numeric(14,4) as tki, 0::numeric(14,4) as pm, ''::text as tululiik, null::integer as lepingId, null::integer as libId into v_max_mvt; 
	  select 0::numeric(14,4) as summa, 0::numeric(14,4) as mvt, 0::numeric(14,4) as tm, 0::numeric(14,4) as tki, 0::numeric(14,4) as pm, ''::text as tululiik, null::integer as lepingId, null::integer as libId into v_miinus_mvt; 

	-- arvestame 

	for v_tululiik in 	
		select  pl.tululiik, sum(po.summa) as summa, count(po.id) as arv_count, sum(po.tulubaas) as mvt, sum(po.tootumaks) as tki, sum(po.pensmaks) as pm, sum(tulumaks) as tm
			from palk_oper po
			inner join library l on l.id = po.libid
			inner join palk_lib pl on pl.parentid = l.id
			where po.lepingId in (
					select id from tooleping 
					where parentId = tnIsikId 
					)
			and po.kpv >= date(year(tdKpv), month(tdKpv), 1) and kpv <= ldKpv
			--and po.kpv = tdKpv
			and po.rekvId = tnRekvId
			and pl.liik = 1
			group by pl.tululiik,pl.liik
			order by pl.liik	
	loop

			--raise notice 'v_tululiik.mvt %, v_tululiik.tululiik %', v_tululiik.mvt, v_tululiik.tululiik;

			-- salvestame max tululiige summa
			if (v_tululiik.summa > v_max_mvt.summa) then 
				v_max_mvt.summa = v_tululiik.summa;
				v_max_mvt.mvt = v_tululiik.mvt;
				v_max_mvt.tm = v_tululiik.tm;
				v_max_mvt.tki = v_tululiik.tki;			
				v_max_mvt.pm = v_tululiik.pm;
				v_max_mvt.tululiik = v_tululiik.tululiik;
				--raise notice 'v_tululiik.summa > v_max_mvt.summa %, v_tululiik.summa %', v_max_mvt.summa, v_tululiik.summa;
			end if;

			-- salvestame miinus tululiige summa
			if (v_tululiik.mvt < 0) then
				v_miinus_mvt.summa = v_tululiik.summa;
				v_miinus_mvt.mvt = v_tululiik.mvt;
				v_miinus_mvt.tm = v_tululiik.tm;
				v_miinus_mvt.tki = v_tululiik.tki ;
				v_miinus_mvt.pm = v_tululiik.pm; 
				v_miinus_mvt.tululiik = v_tululiik.tululiik;
			end if;
	
		if v_tululiik.arv_count > 1 then 
			select  po.*, pl.tululiik into v_leping
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

			--salvestame max mvt lepingid ja libId
			if v_max_mvt.tululiik = v_leping.tululiik and v_max_mvt.lepingId is null then
				v_max_mvt.lepingId = v_leping.lepingId;
				v_max_mvt.libId = v_leping.libId;
			end if;

			if lcTimestamp is null then
				lcTimestamp = left('ARV'+LTRIM(RTRIM(str(v_leping.LepingId)))+LTRIM(RTRIM(str(v_leping.LibId)))+ltrim(rtrim(str(dateasint(tdKpv)))),20);
			end if;

			if v_leping.lepingId is null then
				--raise notice 'v_leping.lepingId is null';
				return 0;
			end if;
		
			lnSumma = sp_calc_arv(v_leping.lepingId, v_leping.libId, v_leping.kpv, v_tululiik.summa, null, 1);

			select round(tasun1,2) as tulubaas,round(volg1,2) as tm,  round(volg2,2) as sm, round(volg4,2) as tki, round(volg5,2) as pm, round(volg6,2) as tka, muud, 0::numeric(14,4) as mvt into v_arv
				from tmp_viivis
				where alltrim(timestamp) = alltrim(lcTimestamp);

				
			select sum(summa) as arv, sum(tulumaks) as tm, sum(sotsmaks) as sm, sum(tootumaks) as tki,  sum(pensmaks) as pm, sum(tka) as tka, sum(tulubaas) as mvt into v_fakt_arv
				from palk_oper po
				inner join library l on l.id = po.libid
				inner join palk_lib pl on pl.parentid = l.id
				where po.lepingId in (
						select id from tooleping 
						where parentId = tnIsikId 
						)
			--	and po.kpv = tdKpv
				and po.kpv >= date(year(tdKpv), month(tdKpv), 1) and kpv <= ldKpv
				and po.rekvId = tnRekvId
				and pl.liik = 1
				and pl.tululiik = v_tululiik.tululiik;

			-- kontrollime MVT 
			l_tulubaas_kokku = coalesce((select sum(summa) 
				from taotlus_mvt mvt 
				inner join tooleping t on t.id = mvt.lepingId 
				where t.parentId = tnIsikId and alg_kpv <= tdKpv and lopp_kpv >= tdKpv),0);

			l_tulubaas = calc_mvt(v_fakt_arv.arv, l_tulubaas_kokku, tdKpv);	



			if v_fakt_arv.mvt - (v_arv.tm - round(v_fakt_arv.tm,2) - (v_arv.pm - round(v_fakt_arv.pm,2)) - v_arv.tki-round(v_fakt_arv.tki,2)) > l_tulubaas then
				v_arv.mvt = l_tulubaas - v_fakt_arv.mvt;
			end if;

			--raise notice 'v_arv.mvt %', v_arv.mvt;

			
			if v_arv.tm - round(v_fakt_arv.tm,2) <> 0 or 
				v_arv.sm - round(v_fakt_arv.sm,2) <> 0 or
				v_arv.tki-round(v_fakt_arv.tki,2) <> 0 or
				v_arv.tka - round(v_fakt_arv.tka,2) <> 0 or
				v_arv.pm - round(v_fakt_arv.pm,2) <> 0  
				then

				--raise notice 'umardamine, salvestamine %', v_arv.tulubaas;
				l_id = sp_salvesta_palk_oper(0, tnRekvId, v_leping.libId, v_leping.lepingId, ldKpv, 0, v_leping.Doklausid, 'Ümardamine' + v_arv.muud, 
					ifnull(v_leping.kood1,space(1)),ifnull(v_leping.kood2,'LE-P'), ifnull(v_leping.kood3,space(1)), 
					ifnull(v_leping.kood4,space(1)), ifnull(v_leping.kood5,space(1)), ifnull(v_leping.konto,space(1)), 
					 v_leping.tp, v_leping.tunnus,'EUR', 1,v_leping.proj,
					v_tululiik.tululiik::integer, ifnull(v_arv.tm - round(v_fakt_arv.tm,2),0), ifnull(v_arv.sm - round(v_fakt_arv.sm,2),0), ifnull(v_arv.tki-round(v_fakt_arv.tki,2),0), ifnull( v_arv.pm - round(v_fakt_arv.pm,2),0), 
					l_mvt_diff, coalesce(v_arv.tka - round(v_fakt_arv.tka,2),0), null::date);

				if v_fakt_arv.mvt < 500 then
					-- arvestame kasutatud MVT
					select sum(summa) as arv, sum(tulumaks) as tm, sum(tootumaks) as tki,  sum(pensmaks) as pm, sum(tulubaas) as mvt 
						into l_tulu_kokku, l_tm_kokku, l_tk_kokku, l_pm_kokku, l_mvt_kokku
						from palk_oper po
						inner join library l on l.id = po.libid
						inner join palk_lib pl on pl.parentid = l.id
						where po.lepingId in (
								select id from tooleping 
								where parentId = tnIsikId 
								)
						and po.kpv >= date(year(tdKpv), month(tdKpv), 1) and kpv <= ldKpv
						and po.rekvId = tnRekvId
						and pl.liik = 1;

					l_mvt_diff = coalesce(l_mvt_kokku,0) - (coalesce(l_tulu_kokku,0) - (coalesce(l_tm_kokku,0) + coalesce(l_tk_kokku,0) + coalesce(l_pm_kokku,0)));

					if l_mvt_diff > 0 then
						update palk_oper set Tulubaas = Tulubaas - l_mvt_diff where id = l_id;
					end if;
				end if;
					
			else
				raise notice 'Pole vaja';

			end if;

		end if; -- arv count peaks rohkem kui 1

	end loop;					
	-- kontrollime kas on periodis -mvt 
	if (v_miinus_mvt.mvt < 0) then
--		raise notice 'mvt parandus v_miinus_mvt.tm %, v_miinus_mvt.mvt %, v_miinus_mvt.summa %, v_miinus_mvt.tki %, v_miinus_mvt.pm %',v_miinus_mvt.tm, v_miinus_mvt.mvt, v_miinus_mvt.summa, v_miinus_mvt.tki, v_miinus_mvt.pm ;
--		raise notice 'mvt parandus v_max_mvt.tm %, v_max_mvt.mvt %',v_max_mvt.tm, v_max_mvt.mvt;
		
		-- arvestame tm diff 
		l_uus_tm = ((v_miinus_mvt.summa - v_miinus_mvt.tki - v_miinus_mvt.pm) * 0.20) - v_miinus_mvt.tm;

--		raise notice 'uus tm arvestus l_uus_tm %', l_uus_tm;

		if v_miinus_mvt.lepingId is null then
			select  po.lepingId, po.libId into l_lepingId, l_libId
				from palk_oper po
				inner join library l on l.id = po.libid
				inner join palk_lib pl on pl.parentid = l.id
				inner join tooleping t on t.id = po.lepingId
				where t.parentId = tnIsikId 
				and po.kpv = tdKpv
				and po.rekvId = tnRekvId
				and pl.liik = 1
				and pl.tululiik = v_miinus_mvt.tululiik
				and po.tulubaas < 0
				order by t.pohikoht desc, po.summa desc limit 1;

			v_miinus_mvt.lepingId = l_lepingId;
			v_miinus_mvt.libId = l_libId;	

		end if;

		-- parandame miinus mvt ja tm
		l_id = sp_salvesta_palk_oper(0, tnRekvId, v_miinus_mvt.libId, v_miinus_mvt.lepingId, ldKpv, 0, v_leping.Doklausid, 'MVT miinus parandus' + v_arv.muud, 
			ifnull(v_leping.kood1,space(1)),ifnull(v_leping.kood2,'LE-P'), ifnull(v_leping.kood3,space(1)), 
			ifnull(v_leping.kood4,space(1)), ifnull(v_leping.kood5,space(1)), ifnull(v_leping.konto,space(1)), 
			 v_leping.tp, v_leping.tunnus,'EUR', 1,v_leping.proj,
			v_miinus_mvt.tululiik::integer, l_uus_tm, 0, 0, 0, 
			- 1 * v_miinus_mvt.mvt, 0, null::date);

		-- arvestame mvt diff 
		
		l_uus_tm = (v_max_mvt.summa - (v_max_mvt.mvt + v_miinus_mvt.mvt + v_max_mvt.tki + v_max_mvt.pm)) * 0.20;
		--raise notice '(v_max_mvt.summa - (v_max_mvt.mvt + v_miinus_mvt.mvt + v_max_mvt.tki + v_max_mvt.pm) * 0.20) %', l_uus_tm;
		
		l_uus_tm =  v_max_mvt.tm -  l_uus_tm;

		-- parandame max mvt ja tm
		--raise notice 'v_miinus_mvt.mvt %, v_max_mvt.mvt %, v_max_mvt.tm %', v_miinus_mvt.mvt, v_max_mvt.mvt, v_max_mvt.tm ; 
		l_id = sp_salvesta_palk_oper(0, tnRekvId, v_max_mvt.libId, v_max_mvt.lepingId, ldKpv, 0, v_leping.Doklausid, 'MVT miinus parandus' + v_arv.muud, 
			ifnull(v_leping.kood1,space(1)),ifnull(v_leping.kood2,'LE-P'), ifnull(v_leping.kood3,space(1)), 
			ifnull(v_leping.kood4,space(1)), ifnull(v_leping.kood5,space(1)), ifnull(v_leping.konto,space(1)), 
			 v_leping.tp, v_leping.tunnus,'EUR', 1,v_leping.proj,
			v_max_mvt.tululiik::integer, l_uus_tm, 0, 0, 0, 
			v_miinus_mvt.mvt, 0, null::date);
		

	end if;	 


	return 0;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_umardamine(integer, date, integer) OWNER TO vlad;


select sp_calc_umardamine(36509, date(2018,01,31), 121);


/*
select * from asutus where regkood = '48211113758'
--36509

select * from tooleping where id = 137542
select * from palk_oper where lepingid in (128141) and year(kpv) = 2018 and month(kpv) = 8 and summa = 0
--1184

select * from rekv where regkood = '75009160'

select * from palk_oper where id = 4858367


select * from palk_oper where tulubaas < 0 and year(kpv) = 2018 order by id desc limit 10
*/