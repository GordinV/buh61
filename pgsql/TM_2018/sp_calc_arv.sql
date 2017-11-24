-- Function: sp_calc_arv(integer, integer, date, numeric, date)

--DROP FUNCTION if exists sp_calc_arv(integer, integer, date, numeric, date);
DROP FUNCTION if exists sp_calc_arv(integer, integer, date, numeric, date, integer);

CREATE OR REPLACE FUNCTION sp_calc_arv(tnLepingid integer, tnLibId integer, tdKpv date, tnSumma numeric, tdPeriod date, tnUmardamine integer)
  RETURNS numeric AS
$BODY$
declare
	lnSumma numeric (18,8);
	v_palk_kaart record;
	qrytooleping record;
	qryPalkLib   record;
	qryTaabel1 record;
	npalk	numeric(20,10);
	nHours NUMERIC(20,10);
	lnRate numeric (20,10);
	nSumma numeric (20,10);
	lnKuuSumma numeric (20,10) = 0;
	lnBaas numeric (20,10);
	lnKuurs numeric(12,4);

	ltSelgitus text;
	ltEnter character;
	lcTimestamp varchar(20);

	lTKA numeric(14,4) = 0;
	lTKI numeric(14,4) = 0;
	lTM numeric(14,4) = 0;
	lSM numeric(14,4) = 0;
	lPM numeric(14,4) = 0;

	v_kaart record;
	l_tulubaas_kokku numeric(14,4) = 0;
	l_tulubaas numeric(14,4) = 0;
	l_kasutatud_tulubaas numeric(14,4) = 0;
	l_period integer = 1;
	l_PM_maar numeric(8,2) = 2;
	l_TKI_maar numeric(8,2) = 1.6;
	l_TKA_maar numeric(8,2) = 0.8;
	l_SM_maar  numeric(8,2) = 33;
	l_TM_maar numeric(8,2) = 20;
	l_min_sots numeric(14,4) = 0;
	v_maksud record;
	l_aasta_alg date = date(year(tdKpv),01,01);
	l_count integer;
begin

nHours :=0;
lnSumma := 0;
nPalk:=0;
lnBaas :=0;
lnKuurs =  fnc_currentkuurs(tdKpv);

ltSelgitus = '';
ltEnter = '
';
lcTimestamp = left('ARV'+LTRIM(RTRIM(str(tnLepingId)))+LTRIM(RTRIM(str(tnLibId)))+ltrim(rtrim(str(dateasint(tdKpv)))),20);

select palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs  into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20) 
	where lepingid = tnLepingid and libId = tnLibId;

select pl.*, l.muud as lisa, l.tun1, l.tun2, l.tun3, l.tun4, l.tun5 INTO qryPalkLib
	from palk_lib pl
	left outer join library l on l.kood = pl.tululiik and library = 'MAKSUKOOD'
	where pl.parentId = tnLibId;

select tooleping.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, pc.minpalk into qryTooleping 
	from tooleping left outer join dokvaluuta1 on (tooleping.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 19)
	left outer join palk_config pc on pc.rekvid = tooleping.rekvid 
	where tooleping.id = tnLepingId; 
	
if qryTooleping.algab > l_aasta_alg then
	l_aasta_alg = qryTooleping.algab;
end if;

if tnSumma is null  then  
	If v_palk_kaart.percent_ = 1 then
		-- calc based on taabel 
--		raise notice 'calc based on taabel';
		If v_palk_kaart.alimentid = 0 then
			--raise notice 'alimentid = 0';		

			select * into qryTaabel1 from palk_taabel1 where toolepingId = tnlepingId 
				and kuu = month(tdKpv) and aasta = year (tdKpv);

			if not found then
				--raise notice 'TAABEL1 NOT FOUND';
				return lnSumma;
			end if;

		SELECT tund into nHours FROM Toograf WHERE lepingid = tnLepingId AND kuu = month(tdKpv) AND aasta = year(tdKpv);
		IF ifnull(nHours,0) = 0 then
			nHours := (sp_workdays(1, month(tdKpv), year(tdKpv), 31,v_palk_kaart.lepingId)::numeric(6,4) * qryTooleping.toopaev )::INT4;
			ltSelgitus = ltSelgitus + 'Kokku tunnid kuues,:'+ltrim(rtrim(round(nHours,2)::varchar))+ltEnter;

			nHours := nHours - sp_calc_tahtpaevad(qryTooleping.rekvId, month(tdKpv));
			ltSelgitus = ltSelgitus + 'Kokku tunnid kuues, parandatud:'+ltrim(rtrim(round(nHours,2)::varchar))+ltEnter;

		END IF;

			--raise notice 'hOUR %',nHours;
			if qryTooleping.tasuliik = 1 then
				lnRate := (qryTooleping.palk * qryTooleping.kuurs)/ nHours * 0.01 * qryTooleping.koormus ;
				--raise notice 'Rate %',lnrate;
				ltSelgitus = ltSelgitus + 'Tunni hind:'+ltrim(rtrim(round(lnRate,2)::varchar))+ltEnter;

			end if;

			if qryTooleping.tasuliik = 2 then
				lnSumma := f_round((qryTooleping.palk * qryTooleping.kuurs) * qryTaabel1.kokku / lnKuurs,qryPalkLib.round);
				lnRate := qryTooleping.palk * qryTooleping.kuurs;
				ltSelgitus = ltSelgitus + 'arvestus:'+ltrim(rtrim(qryTooleping.palk::varchar))+'*'+ltrim(rtrim(qryTooleping.kuurs::varchar))+'*'+
					ltrim(rtrim(round(qryTaabel1.kokku,3)::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;
				
				-- muudetud 01/02/2005
				if qryPalkLib.tund = 5 then
					lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev  / lnKuurs,qryPalkLib.round);
					ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(round(lnRate,2)::varchar))+'*'+ltrim(rtrim(round(v_palk_kaart.Summa,2)::varchar))+'*0.01*'+
						ltrim(rtrim(round(qryTaabel1.tahtpaev,3)::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

				end if;
				If  qryPalkLib.tund = 6 then
					lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev  / lnKuurs,qryPalkLib.round);
					ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(round(lnRate,2)::varchar))+'*'+ltrim(rtrim(round(v_palk_kaart.Summa,2)::varchar))+'*0.01*'+
						ltrim(rtrim(round(qryTaabel1.puhapaev,3)::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

				End if;
				If  qryPalkLib.tund = 7 then
					lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo / lnKuurs,qryPalkLib.round);
					ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(round(lnRate,2)::varchar))+'*'+ltrim(rtrim(round(v_palk_kaart.Summa,2)::varchar))+'*0.01*'+
						ltrim(rtrim(round(qryTaabel1.uleajatoo,3)::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

				End if;
				if qryPalkLib.tund =3 then
					lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu / lnKuurs,qryPalkLib.round);
					ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(round(lnRate,2)::varchar))+'*'+ltrim(rtrim(round(v_palk_kaart.Summa,2)::varchar))+'*0.01*'+
						ltrim(rtrim(qryTaabel1.ohtu::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

				end if;
				if qryPalkLib.tund =4 then
					lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo / lnKuurs,qryPalkLib.round);
					ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(round(lnRate,2)::varchar))+'*'+ltrim(rtrim(round(v_palk_kaart.Summa,2)::varchar))+'*0.01*'+
						ltrim(rtrim(round(qryTaabel1.oo,3)::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

				end if;
				if qryPalkLib.tund =2 then
					lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev / lnKuurs,qryPalkLib.round);
					ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(round(lnRate,2)::varchar))+'*'+ltrim(rtrim(round(v_palk_kaart.Summa,2)::varchar))+'*0.01*'+
						ltrim(rtrim(round(qryTaabel1.paev,3)::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

				end if;

			else

				If  qryPalkLib.tund = 5 then

					lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev / lnKuurs,qryPalkLib.round);
					ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(round(lnRate,2)::varchar))+'*'+ltrim(rtrim(round(v_palk_kaart.Summa,2)::varchar))+'*0.01*'+
							ltrim(rtrim(round(qryTaabel1.tahtpaev,3)::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

					lnBaas := qryTaabel1.tahtpaev;

				End if;

				If  qryPalkLib.tund = 6 then

					lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev / lnKuurs,qryPalkLib.round);
					lnBaas := qryTaabel1.puhapaev;
					ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(round(lnRate,2)::varchar))+'*'+ltrim(rtrim(round(v_palk_kaart.Summa,2)::varchar))+'*0.01*'+
							ltrim(rtrim(round(qryTaabel1.puhapaev,3)::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

				End if;

				If  qryPalkLib.tund = 7 then

					lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo / lnKuurs,qryPalkLib.round);

					lnBaas := qryTaabel1.uleajatoo;
					ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(round(lnRate,2)::varchar))+'*'+ltrim(rtrim(round(v_palk_kaart.Summa,2)::varchar))+'*0.01*'+
							ltrim(rtrim(round(qryTaabel1.uleajatoo,3)::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;


				End if;

				If  qryPalkLib.tund < 5 then			

					if qryPalkLib.tund =3 then

						nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu;

						ltSelgitus = ltSelgitus + 'parandamine(nSumma):'+ltrim(rtrim(round(lnRate,2)::varchar))+'*'+ltrim(rtrim(round(v_palk_kaart.Summa,2)::varchar))+'*0.01*'+
							ltrim(rtrim(round(qryTaabel1.ohtu,3)::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;


					end if;

					if qryPalkLib.tund =4 then

						nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo;
						ltSelgitus = ltSelgitus + 'parandamine(nSumma):'+ltrim(rtrim(round(lnRate,2)::varchar))+'*'+ltrim(rtrim(round(v_palk_kaart.Summa,2)::varchar))+'*0.01*'+
							ltrim(rtrim(round(qryTaabel1.oo,3)::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

					end if;

					if qryPalkLib.tund =2 then

						nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev;
						ltSelgitus = ltSelgitus + 'parandamine(nSumma):'+ltrim(rtrim(round(lnRate,2)::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
							ltrim(rtrim(round(qryTaabel1.paev,3)::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

					end if;

					if qryPalkLib.tund =1 then

						nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.kokku;
						ltSelgitus = ltSelgitus + 'parandamine(nSumma):'+ltrim(rtrim(round(lnRate,2)::varchar))+'*'+ltrim(rtrim(round(v_palk_kaart.Summa,2)::varchar))+'*0.01*'+
							ltrim(rtrim(round(qryTaabel1.kokku,3)::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

					end if;
					lnSumma := lnSumma + f_round( nSumma / lnKuurs, qryPalkLib.round);
					lnBaas := lnBaas + case when qryPalkLib.tund =3 then qryTaabel1.ohtu else 
						case when qryPalkLib.tund =4 then qryTaabel1.oo else qryTaabel1.paev end end; 

				end if;
			End if;
		End if;
	Else

		lnSumma := f_round(v_palk_kaart.Summa * v_palk_kaart.kuurs / lnKuurs,qryPalkLib.round);
		ltSelgitus = ltSelgitus +ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*'+ltrim(rtrim(v_palk_kaart.kuurs::varchar))+ '/' +ltrim(rtrim(lnKuurs::varchar))+ltEnter;
		lnBaas := 0;
	End if;
else
	ltSelgitus = ltSelgitus + ' Käsi arvestus või ümardamine '+ltEnter;
	lnSumma = tnSumma;
end if;

-- salvestame arvetuse analuus
delete from tmp_viivis where alltrim(timestamp) = alltrim(lcTimestamp);
insert into tmp_viivis (rekvid, dkpv, timestamp,muud) values (qryTooleping.rekvid,tdKpv, lcTimestamp,ltSelgitus);

--raise notice 'lcTimestamp %, qryPalkLib.tululiik %', lcTimestamp, qryPalkLib.tululiik;
-- TSD 2015
if qryPalkLib.tululiik is not null then
	--Tootuskind-lustusmakse-> tun4, Kogumispension -> tun5
	select sum(sm) as sm, sum(tki) as tki, sum(tka) as tka, sum(pm) as pm into v_kaart from (
		select case when pl.liik = 5 then status else 0 end as sm, 
			case when pl.liik = 7 and asutusest = 0 then status else 0 end as tki,
			case when pl.liik = 7 and asutusest = 1 then status else 0 end as tka,
			case when pl.liik = 8 then status else 0 end as pm
			from palk_kaart pk
			inner join palk_lib pl on pl.parentid = pk.libid
			where pk.lepingid = qryTooleping.id
			) qry;

	for v_maksud in
		select pk.summa, pk.tulumaks, pl.liik, pl.asutusest, pk.minsots
			from palk_kaart pk
			inner join palk_lib pl on pl.parentId = pk.libid
			where pk.status = 1 
			and pk.lepingId = qryTooleping.id
			and pl.liik in (5, 7, 8)
		loop
			if v_maksud.liik = 5 then
					-- SM
					l_SM_maar = v_maksud.summa;
					l_min_sots = coalesce(v_maksud.minsots,0);
			elsif v_maksud.liik = 7 and v_maksud.asutusest = 0 then
					-- TKI
					l_TKI_maar = v_maksud.summa;
			elsif v_maksud.liik = 7 and v_maksud.asutusest = 1 then
					-- TKA
					l_TKA_maar = v_maksud.summa;
			elsif v_maksud.liik = 8 then
					-- PM
					l_PM_maar = v_maksud.summa;
			else
					-- null
			end if;
		end loop;
	l_TM_maar = qryPalkLib.tun1 ;	
	-- kui period on eelmine aasta siis kasutame eelmise aasta maksumaarad
	if tdPeriod is not null and year(tdPeriod) < year(tdKpv) then
		l_TKI_maar = 2;
		l_TKA_maar = 1;
		l_TM_maar = 21;
	end if;	

	lTKI = round(lnSumma * 0.01 * l_TKI_maar * qryPalkLib.tun4 * coalesce(case when v_kaart.tki > 0 then 1 else 0 end,0),2);
	
	ltSelgitus = ltSelgitus + 'TKI arvestus:' + round(lnSumma,2)::text + '*'+ (0.01 * l_TKI_maar)::text+ '*' + qryPalkLib.tun4::text + ltEnter;
	
	lPM = round(lnSumma * 0.01 * l_PM_maar * qryPalkLib.tun5 * coalesce(case when v_kaart.pm > 0 then 1 else 0 end,0),2);	
	ltSelgitus = ltSelgitus + 'PM arvestus:' + round(lnSumma,2)::text + '*' + (0.01 * l_PM_maar)::text + '*' + qryPalkLib.tun5::text + ltEnter;
/*	
	if lnSumma < qryTooleping.minpalk * l_min_sots then
		ltSelgitus = ltSelgitus + 'SM kasutame min.palk ' + qryTooleping.minpalk::text + ltEnter;
	end if;
*/	
--	raise notice 'lnSumma %, l_SM_maar %, qryPalkLib.tun2 %, v_kaart.sm %', lnSumma, l_SM_maar, qryPalkLib.tun2, v_kaart.sm ;
	lSM = round(lnSumma  * 0.01 * l_SM_maar * qryPalkLib.tun2 * coalesce(case when v_kaart.sm > 0 then 1 else 0 end,0),2);


	

	--lSM = (case when lnSumma < qryTooleping.minpalk * l_min_sots then qryTooleping.minpalk else lnSumma end) * 0.01 * l_SM_maar * qryPalkLib.tun2 * coalesce(case when v_kaart.sm > 0 then 1 else 0 end,0);

	ltSelgitus = ltSelgitus + 'SM arvestus: ' + (case when lnSumma < qryTooleping.minpalk * l_min_sots then qryTooleping.minpalk else round(lnSumma,2) end)::text + 
		'*' + (0.01 * l_SM_maar)::text + '*' + qryPalkLib.tun2::text + ltEnter;
			

	lTKA = round(lnSumma  * 0.01 * l_TKA_maar * qryPalkLib.tun4 * coalesce(case when v_kaart.tka > 0 then 1 else 0 end,0),2);
--	lSM = (case when lnSumma < qryTooleping.minpalk * l_min_sots then qryTooleping.minpalk else lnSumma end) * 0.01 * l_SM_maar * qryPalkLib.tun2 * coalesce(case when v_kaart.sm > 0 then 1 else 0 end,0);

	ltSelgitus = ltSelgitus + 'TKA arvestus:' + round(lnSumma,2)::text + 
		'*' + (0.01 * l_TKA_maar)::text + '*' + qryPalkLib.tun4::text + ltEnter;

	if year(tdKpv) < 2018 then
		raise notice '2017 arvestus';
		if qryTooleping.pohikoht = 1 then
			
			if year(tdKpv) >= 2015 then
				l_tulubaas_kokku = (select month(tdKpv) - month(l_aasta_alg)  + 1)  * 
					(select coalesce(tulubaas,154) from palk_config where rekvid = qryTooleping.rekvid limit 1);
			else
				l_tulubaas_kokku = (144 * 11) + (select coalesce(tulubaas,154) from palk_config where rekvid = qryTooleping.rekvid limit 1);
			end if;

			
			-- kasutatud tulubaas
			select sum(tulubaas) as tulubaas into l_kasutatud_tulubaas
					from palk_oper po
					inner join tooleping t on po.lepingid = t.id
					where tulubaas is not null
					and tulubaas > 0 
					and kpv >= date(year(tdKpv),month(l_aasta_alg),01) and kpv <= tdKpv 
					and po.id not in (select id from palk_oper where libId = tnLibId and lepingId = tnLepingId and kpv = tdKpv)
					and po.libId in (select l.Id from library l inner join palk_lib pl on l.id = pl.parentId where rekvId = qryTooleping.rekvId and pl.liik = 1)
					and t.parentid = qryTooleping.parentid;

			if year(tdKpv) < 2015 then
				select sum(g31) into l_tulubaas 
					from palk_jaak 
					where lepingid in (select id from tooleping where rekvid =  qryTooleping.rekvid and parentId = qryTooleping.parentId)
					and kuu >= 1 and kuu < month(tdKpv) and aasta = year(tdKpv);
					
				l_kasutatud_tulubaas = coalesce(l_kasutatud_tulubaas,0) + coalesce(l_tulubaas,0);
			end if;

--			raise notice 'l_tulubaas_kokku %, l_kasutatud_tulubaas %, l_aasta_alg %', l_tulubaas_kokku, l_kasutatud_tulubaas, l_aasta_alg;

			-- periodi kogus
--			raise notice 'tulubaasi kasutamine lnSumma %, tnSumma %', lnSumma, tnSumma;
			if tnSumma is null or lnSumma != tnSumma then
				l_tulubaas = coalesce(l_tulubaas_kokku,0) - coalesce(l_kasutatud_tulubaas,0);
			else
				select sum(tulubaas) into l_tulubaas 
					from palk_oper po
					where po.lepingid in (select id from tooleping where parentId = qryTooleping.parentid and rekvId = qryTooleping.rekvId)
					and kpv = tdKpv
					and libId in 
					(
						select l.id from library l
							inner join palk_lib pl on l.id = pl.parentId
							where l.rekvId = qryTooleping.rekvId
							and pl.tululiik = qryPalkLib.tululiik
							and pl.liik = qryPalkLib.liik
					);
					
				l_tulubaas = coalesce(l_tulubaas,0);
				ltSelgitus = ltSelgitus + ' kasutame enne arvestatud kasutatud tulubaas ' + ltEnter;
			end if;
		end if;
	else
	--	raise notice 'Tulubaas 2018 arvestus';
		-- TM 2018 arvestus
		l_tulubaas_kokku = coalesce((select sum(summa) from taotlus_mvt mvt inner join tooleping t on t.id = mvt.lepingId where t.parentId = qryTooleping.parentId and alg_kpv <= tdKpv and lopp_kpv >= tdKpv),0);
		-- 1.  arvestus
		-- arvestame kuu tulud
		  select sum(po.summa), sum(po.tulubaas) into lnKuuSumma,  l_kasutatud_tulubaas 
			from palk_oper po 
			inner join tooleping t on t.id = po.lepingId
			inner join palk_lib pl on pl.parentId = po.libId
			where t.parentid = qryTooleping.parentId
			and pl.liik = 1
			and year(po.kpv) = year(tdKpv) and month(po.kpv) = month(tdKpv) 
			and po.rekvId = qryTooleping.rekvId
			and (tnSumma is not null or po.id not in (select id from palk_oper where kpv = tdKpv and lepingid = tnLepingid and libid = tnLibId)); -- kui parandus siis v]ttame koik summad

		lnKuuSumma = coalesce(lnKuuSumma,0) + (lnSumma - coalesce(tnSumma,0));

					
		-- 2 kasutatud mvt
		

		 l_tulubaas = calc_mvt(lnKuuSumma, l_tulubaas_kokku, tdkpv);	

		--raise notice 'Tulubaas arvestus l_tulubaas %, lnKuuSumma % ', l_tulubaas, lnKuuSumma;

		-- 3. parandus

		if coalesce(tnUmardamine,0) = 0 then 	
			-- ei ole umardamine
			l_tulubaas = coalesce(l_tulubaas,0) - coalesce(l_kasutatud_tulubaas,0);
		end if;
		
		if l_tulubaas > lnSumma then
			l_tulubaas = lnSumma -  lTKI - lPM;
		end if;
		--raise notice 'Tulubaas parandus l_tulubaas %, l_kasutatud_tulubaas % ', l_tulubaas, l_kasutatud_tulubaas;

		if coalesce(tnUmardamine,0) = 0 and (l_kasutatud_tulubaas + l_tulubaas) > lnKuuSumma then
			-- liga palju
			l_tulubaas = (l_kasutatud_tulubaas + l_tulubaas) - lnKuuSumma;
			--raise notice 'Tulubaas parandus, liga palju l_tulubaas %, l_kasutatud_tulubaas %, lnKuuSumma % ', l_tulubaas, l_kasutatud_tulubaas, lnKuuSumma;
		end if;

	end if;
	
	IF l_tulubaas < 0 and (qryPalkLib.lisa is null and year(tdKpv) < 2018) THEN 
		l_tulubaas = 0;
	end if;
	
	if lnSumma > 0 then 
		lTM = (lnSumma -  lTKI - lPM);
	else
		lTM = lnSumma;
	end if;

	--raise notice 'lTM %, l_tulubaas %', lTM, l_tulubaas;

	if lTM > l_Tulubaas and lTM > 0 then
		lTM = lTM - l_tulubaas;
	else
		l_tulubaas = case when lTM > 0 then lTM else 0 end;
		lTM = 0; -- parandus 28.10.2015 sest votab arvestus 1 euriost
	end if;
	lTM = round(lTM * 0.01 * l_TM_maar,2);

	ltSelgitus = ltSelgitus + 'TM arvestus:(' + round(lnSumma,2)::text + 
		'-' + (case when lTKI > 0 then lTKI else 0 end)::text+ 
		'-'+(case when lPM > 0 then lPM else 0 end)::text + 
		'-' + l_tulubaas::text +') * ' + (0.01 * l_TM_maar)::text  + ltEnter;

	
	-- tulumaks (tmp_viivis.volg1)		
--	if qryPalkLib.tun1 > 0 then
	--raise notice 'l_Tulubaas %, lTM %, lTKI %, lPM %, lcTimestamp %', l_Tulubaas, lTM, lTKI, lPM, lcTimestamp;
	update tmp_viivis set volg1 = lTM,
			paev1 = case when qryPalkLib.tululiik = '' then '0' else qryPalkLib.tululiik end::integer,  
			tasun1 = coalesce(l_Tulubaas,0),
			volg2 = lSM,
			volg4 = lTKI,
			volg5 = lPM,
			volg6 = lTKA,
			muud = 	ltSelgitus
			where alltrim(timestamp) = alltrim(lcTimestamp);
--	end if;
end if;

Return lnSumma;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date, numeric, date, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date, numeric, date, integer) TO dbpeakasutaja;
COMMENT ON FUNCTION sp_calc_arv(integer, integer, date, numeric, date, integer) IS 'Muudetud 01/02/2005 lisatud ohtu-uletoo tunni alusel tootajad';

/*
select sp_calc_arv(134258, 566075, date(2018,02,28), 1273.64, null, 1); 


select * from asutus where regkood = '46904023710'

select * from tooleping where parentid = 25515


delete from palk_jaak WHERE lepingid in (select id FROM tooleping WHERE rekvid = 106 AND parentid = 25515) and aasta = 2018 and kuu = 10

DELETE FROM palk_oper WHERE lepingid in (select id FROM tooleping WHERE rekvid = 106 AND parentid = 25515) AND kpv = date(2018,10,05)

select sum(po.summa) from palk_oper po where lepingid in (select id from tooleping where parentId = 25515 and id = 134258) and kpv = date(2018,02,28) and tka > 0 

delete from palk_oper where lepingid in (select id from tooleping where parentId = 25515) and kpv = date(2018,02,28) 

select * from palk_jaak where lepingid in (select id from tooleping where parentId = 22013)  and aasta = 2018

select * from curpalkjaak where regkood = '38403123743' and aasta = 2018 and kuu = 1

				select pk.id, pk.parentid, pk.lepingid, pk.libid, pk.summa
							 FROM Library l
							 inner join Palk_kaart  pk on pk.libId = l.id
							 inner join   Palk_lib pl on pl.parentId = l.id
							 inner join tooleping t on pk.lepingId = t.id
							 left outer join dokvaluuta1 on (pk.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20)
							 where pk.parentid = ?tnId
							 and t.rekvid = ?gRekv
							 and pk.status = 1
							 and not EMPTY(pk.summa)
							 and t.algab <= ?gdKpv
							 and (t.lopp is null or t.lopp >= ?gdKpv)
							 and (?lcOsakonnad = ''  or and t.osakondid  in ?lcOsakonnad)
							 order by liik, case when empty(pl.tululiik) then 99::text else tululiik end, Pk.percent_ desc, pk.summa desc

*/