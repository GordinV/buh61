-- Function: sp_calc_muuda(integer, integer, date)

-- DROP FUNCTION sp_calc_muuda(integer, integer, date);

CREATE OR REPLACE FUNCTION sp_calc_muuda(
    integer,
    integer,
    date)
  RETURNS numeric AS
$BODY$
declare
	tnLepingid alias for $1;
	tnLibId alias for $2;
	tdKpv alias for $3;
	lnSumma numeric (14,4);
	v_palk_kaart record;
	qrytooleping record;
	qryPalkLib   record;
	v_palk_config record;
	qryTaabel1 record;
	nSumma numeric(14,4);
	nHours int4;
	lnBaas numeric(14,4);
	lnrekv int4;
	lnKulud numeric(14,4);
	lnKuurs numeric(12,4);


	ltSelgitus text = '';
	ltEnter character;
	lcTimestamp varchar(20);
	v_tululiik record;
	lnTulud numeric(14,4) = 0;
	ln_umardamine numeric(14,4) = 0;
	l_tsd_2015 boolean = false;
	
begin
ltEnter = '
';
lcTimestamp = left('TK'+LTRIM(RTRIM(str(tnLepingId)))+LTRIM(RTRIM(str(tnLibId)))+ltrim(rtrim(str(dateasint(tdKpv)))),20);

lnSumma :=0;
lnKuurs =  fnc_currentkuurs(tdKpv);

select palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, pl.asutusest into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20)	
	inner join palk_lib pl on pl.parentid = palk_kaart.libid
	where palk_kaart.lepingid = tnLepingid and palk_kaart.libId = tnLibId;
	
select * INTO qryPalkLib from palk_lib where parentId = tnLibId;

select tooleping.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into qryTooleping 
	from tooleping left outer join dokvaluuta1 on (tooleping.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 19)
	where tooleping.id = tnlepingId;

select palk_config.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_config 
	from palk_config left outer join dokvaluuta1 on (palk_config.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 26) where palk_config.rekvid = qryTooleping.rekvid;
--select rekvId into lnrekv from library where id = qryPalkLib.parentId;
select * into qryTaabel1 from palk_taabel1 where toolepingId = tnlepingId; 


nHours := (sp_workdays(1, month(tdKpv), year(tdKpv), 31,v_palk_kaart.lepingId) / (qryTooleping.koormus * 0.01) * qryTooleping.toopaev)::INT4;
If v_palk_kaart.percent_ = 1 then
	if  qryPalkLib.palgafond = 0 then
		lnSumma := qryTooleping.palk * 0.01 * qryTooleping.toopaev * (qryTaabel1.kokku / nHours) * qryTooleping.kuurs / lnKuurs;
	end if;
	if qryPalkLib.palgafond = 1 then
		if qryPalkLib.liik = 7   then

			-- 2015
			if v_palk_kaart.asutusest = 0 then
			-- TKI
				select sum(tootumaks ) as tootumaks  into lnSumma
					from palk_oper 
					left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
					WHERE Palk_oper.kpv = tdKpv 	
					and palk_oper.lepingId = tnlepingId
					and palk_oper.tootumaks is not null;
				--muudetud 03/01/2005

				ltSelgitus = ltSelgitus + 'Enne arvestatud tootumaks: ' + coalesce(lnSumma,0)::varchar + ltEnter;
				/*
				if coalesce(lnSumma,0) > 0 then
					for v_tululiik in
						select distinct  pl.tululiik, l.tun1 as tm, l.tun2 as sm, l.tun4 as tki, l.tun5 as pm, po.period
							from palk_oper po
							inner join palk_lib pl on pl.parentId = po.libId and (pl.tululiik is not null and pl.tululiik <> '')
							inner join library l on l.kood = pl.tululiik and library = 'MAKSUKOOD'
							where po.lepingid = tnLepingId
							and po.kpv = tdKpv
					loop
						select sum(summa * v_tululiik.tki ) into lnTulud 
							from palk_oper po 
							where po.lepingId = tnLepingId
							and po.kpv = tdKpv
							and po.tootumaks is not null and po.tootumaks <> 0;
							
						-- parandame summa (umardamine)
						l_tsd_2015 = true;
						if v_tululiik.period is not null and year (v_tululiik.period) < year(tdKpv) then
							v_palk_kaart.summa = 2; -- 2014 tulumaar = 2%
						end if;
						
						ln_umardamine =  (lnTulud * 0.01 * v_palk_kaart.summa - lnSumma) * case when lnTulud > 0 then 1 else 0 end;
						raise notice 'lnTulud %, lnSumma%,  ln_umardamine %',lnTulud, lnSumma, ln_umardamine;
						if ln_umardamine <> 0 then
							ltSelgitus = ltSelgitus + 'TKI (tululiik ' + v_tululiik.tululiik +' umardamine :' +  ln_umardamine::text + 'TKI:' + lnSumma::text + ltEnter;
							update palk_oper set tootumaks = tootumaks + ln_umardamine 
								where id in (
									select po.id 
										from palk_oper po
										inner join palk_lib pl on pl.parentId = po.libId and (pl.tululiik is not null and pl.tululiik <> '')
										where  po.lepingId = tnLepingId
										and pl.tululiik = v_tululiik.tululiik
										and po.kpv = tdKpv
										and po.tootumaks is not null and po.tootumaks <> 0 
										order by tootumaks desc limit 1);
						end if;
					end loop;	
					lnSumma = f_round(lnSumma + ln_umardamine,qryPalkLib.round);
				end if;	
				*/
			else
				raise notice 'TKA';

			-- TKA
				select sum(tka )  into lnSumma
					from palk_oper 
					left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
					WHERE Palk_oper.kpv = tdKpv 	
					and palk_oper.lepingId = tnlepingId
					and palk_oper.tka is not null;
				--muudetud 03/01/2005
				raise notice 'lnSumma %', lnSumma;
				ltSelgitus = ltSelgitus + 'Enne arvestatud tootumaks (asutusest): ' + coalesce(lnSumma,0)::varchar + ltEnter;
/*				
				if coalesce(lnSumma,0) > 0 then
					for v_tululiik in
						select distinct  pl.tululiik, l.tun1 as tm, l.tun2 as sm, l.tun4 as tki, l.tun5 as pm, po.period
							from palk_oper po
							inner join palk_lib pl on pl.parentId = po.libId and (pl.tululiik is not null and pl.tululiik <> '')
							inner join library l on l.kood = pl.tululiik and library = 'MAKSUKOOD'
							where po.lepingid = tnLepingId
							and po.kpv = tdKpv
					loop
						select sum(summa * v_tululiik.tki ) into lnTulud 
							from palk_oper po 
							where po.lepingId = tnLepingId
							and po.kpv = tdKpv
							and po.tka is not null and po.tka <> 0;
							
						-- parandame summa (umardamine)
						l_tsd_2015 = true;
						if v_tululiik.period is not null and year (v_tululiik.period) < year(tdKpv) then
							v_palk_kaart.summa = 1; -- 2014 tulumaar = 1%
						end if;
						ln_umardamine =  (lnTulud * 0.01 * v_palk_kaart.summa - lnSumma) * case when lnTulud <> 0 then 1 else 0 end;
						raise notice 'lnTulud %, lnSumma%,  ln_umardamine %',lnTulud, lnSumma, ln_umardamine;
						if ln_umardamine <> 0 then
							ltSelgitus = ltSelgitus + 'TKA (tululiik ' + v_tululiik.tululiik +' umardamine :' +  ln_umardamine::text + 'TKA:' + lnSumma::text + ltEnter;
							update palk_oper set tka = tka + ln_umardamine 
								where id in (
									select po.id 
										from palk_oper po
										inner join palk_lib pl on pl.parentId = po.libId and (pl.tululiik is not null and pl.tululiik <> '')
										where  po.lepingId = tnLepingId
										and pl.tululiik = v_tululiik.tululiik
										and po.kpv = tdKpv
										and po.tka is not null and po.tka > 0 
										order by tka desc limit 1);
						end if;
					end loop;	
					lnSumma = f_round(lnSumma + ln_umardamine,qryPalkLib.round);
				end if;	
				*/
					-- salvestame arvetuse analuus
				delete from tmp_viivis where timestamp = lcTimestamp;
				insert into tmp_viivis (rekvid, dkpv, timestamp,muud) values (qryTooleping.rekvid,tdKpv, lcTimestamp,ltSelgitus);
				if lnSumma <> 0 then		
					return lnSumma;
				end if;
			end if;
			
			if not l_tsd_2015 then
			
				raise notice '7';
				SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnSumma 
				FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
				left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
				WHERE  Palk_oper.kpv = tdKpv      
				AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1 
				and palk_lib.tululiik <> '13';
			else
				return 	lnSumma;

			end if;
		end if;	
		if  qryPalkLib.liik = 8 then
			raise notice '8';
			-- 2015
			select sum(pensmaks) as pensmaks  into lnSumma
				from palk_oper 
				left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
				WHERE Palk_oper.kpv = tdKpv 	
				And Palk_oper.rekvid = qryTooLeping.rekvId
				and palk_oper.lepingId = tnlepingId
				and palk_oper.pensmaks is not null;
			--muudetud 03/01/2005
		
			raise notice 'PM lnSumma %', lnSumma;

			ltSelgitus = ltSelgitus + 'Enne arvestatud pensionimaks: ' + coalesce(lnSumma,0)::varchar + ltEnter;

			if coalesce(lnSumma,0) > 0 then
/*			
				for v_tululiik in
					select distinct  pl.tululiik, l.tun1 as tm, l.tun2 as sm, l.tun4 as tki, l.tun5 as pm
						from palk_oper po
						inner join palk_lib pl on pl.parentId = po.libId and (pl.tululiik is not null and pl.tululiik <> '')
						inner join library l on l.kood = pl.tululiik and library = 'MAKSUKOOD'
						where po.lepingid = tnLepingId
						and po.kpv = tdKpv
				loop
					l_tsd_2015 = true;
					
					select sum(summa * v_tululiik.pm) into lnTulud
						from palk_oper po 
						where po.lepingId = tnLepingId
						and po.kpv = tdKpv
						and po.pensmaks is not null and po.pensmaks > 0;
						
					-- parandame summa (umardamine)
					
					ln_umardamine =  (lnTulud * 0.01 * v_palk_kaart.summa - lnSumma) * case when lnTulud > 0 then 1 else 0 end;
					raise notice 'lnTulud %, lnSumma%,  ln_umardamine %, lnKuurs %',lnTulud, lnSumma, ln_umardamine, lnKuurs;
					if ln_umardamine <> 0  then
						ltSelgitus = ltSelgitus + 'PM (tululiik ' + v_tululiik.tululiik +' umardamine :' +  ln_umardamine::text + 'PM:' + lnSumma::text + ltEnter;
						update palk_oper set pensmaks = pensmaks + ln_umardamine 
							where id in (
								select po.id 
									from palk_oper po
									inner join palk_lib pl on pl.parentId = po.libId and (pl.tululiik is not null and pl.tululiik <> '')
									where  po.lepingId = tnLepingId
									and pl.tululiik = v_tululiik.tululiik
									and po.kpv = tdKpv
									and po.pensmaks is not null and po.pensmaks > 0 
									order by pensmaks desc limit 1);
					end if;
				end loop;	
				*/
				lnSumma = f_round(lnSumma + ln_umardamine,qryPalkLib.round);
			end if;	
			raise notice 'lnSumma %, ln_umardamine %, l_tsd_2015 %', lnSumma, ln_umardamine, l_tsd_2015;
			delete from tmp_viivis where timestamp = lcTimestamp;
			insert into tmp_viivis (rekvid, dkpv, timestamp,muud) values (qryTooleping.rekvid,tdKpv, lcTimestamp,ltSelgitus);

			return lnSumma;
			if not l_tsd_2015 then
			
				SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnSumma 
				FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
				left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
				WHERE  Palk_oper.kpv = tdKpv      
				AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1;
			end if;
		end if;	
		if  qryPalkLib.liik <> 7 and qryPalkLib.liik <> 8 then
			raise notice 'muud';
			-- tulud
			SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnSumma 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE  Palk_oper.kpv = tdKpv      
			AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId;
		end if;
	end if;
	if qryPalkLib.maks = 1 then
		-- Tulud - Kulud
		-- Arvestame kulud

		SELECT sum(palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) into lnKulud
		FROM palk_kaart inner join palk_oper on 
		(palk_kaart.lepingid = palk_oper.lepingid and palk_kaart.libid = palk_oper.libid)  
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
		where palk_kaart.lepingId = tnLepingId
		AND Palk_oper.kpv = tdKpv  
		and palk_kaart.libid in (select library.id from library inner join palk_lib on palk_lib.parentid = library.id where Palk_lib.liik in (2,4,7,8 ));
		lnSumma = lnSumma - ifnull(lnKulud,0);
		if lnSumma < 0 then
			lnSumma = 0;
		end if;		
	end if;

	
	lnSumma := f_round(v_palk_kaart.summa * 0.01 * lnSumma / lnKuurs, qryPalkLib.round);
Else
	lnSumma := f_round(v_palk_kaart.Summa * v_palk_kaart.kuurs / lnKuurs, qryPalkLib.round);
End if;

Return lnSumma;
end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_muuda(integer, integer, date)
  OWNER TO vlad;


select sp_calc_muuda(137350, 563605, date(2015,12,31))