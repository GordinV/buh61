-- Function: sp_calc_tulumaks(integer, integer, date)

-- DROP FUNCTION sp_calc_tulumaks(integer, integer, date);

CREATE OR REPLACE FUNCTION sp_calc_tulumaks(integer, integer, date)
  RETURNS numeric AS
$BODY$
declare
	tnLepingid alias for $1;
	tnLibId alias for $2;
	tdKpv alias for $3;
	lnSumma numeric (12,4);
	v_palk_kaart record;
	qrytooleping record;
	qryPalkLib   record;
	v_palk_config record;
	qryTulumaks record;
	nSumma numeric (12,4);
	lnBaas numeric (12,4);
	lnrekv int;
	lnMinPalk numeric (12,4);
	lnTulud numeric (12,4);
	lnTuludPm numeric (12,4);
	lnKulud numeric (12,4);
	lnTulubaas numeric(12,4);	
	lnG31 numeric(12,4);
	lnG31_2004 numeric(12,4);
	lnG31_2005 numeric(12,4);

	nG31 numeric(12,4);
	lnCount	int;
	lnCount_2004	int;
	lnCount_2005	int;
	lnArvJaak numeric (12,4);
	lnKuurs  numeric(12,4);

	ltSelgitus text;
	ltEnter character;
	lcTimestamp varchar(20);

	lnTkiPm numeric (12,4);
	lnPMPm numeric (12,4);
begin
lnBaas :=0;
lnsUMMA :=0;
lnKuurs =  fnc_currentkuurs(tdKpv);
ltSelgitus = '';
ltEnter = '
';
lcTimestamp = left('TM'+LTRIM(RTRIM(str(tnLepingId)))+LTRIM(RTRIM(str(tnLibId)))+ltrim(rtrim(str(dateasint(tdKpv)))),20);
-- kustutame vana info
delete from tmp_viivis where timestamp = lcTimestamp;

select  palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20) 
	where lepingid = tnLepingid and libId = tnLibId;
	
select * into qryTooleping from tooleping where id = tnlepingId;

--muudetud 25/01/2005
IF v_palk_kaart.tulumaar = 0 AND qryTooleping.pohikoht = 0 then
	RETURN 0;
END IF;


select * INTO qryPalkLib from palk_lib where parentId = tnLibId;
select rekvId into lnrekv from library where id = qryPalkLib.parentId;
--select * into v_palk_config from palk_config where rekvid = lnrekv;

select palk_config.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_config 
	from palk_config left outer join dokvaluuta1 on (palk_config.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 26) where palk_config.rekvid = lnrekv;


--muudetud 03/01/2005

if qryTooleping.pohikoht > 0  then
	lnTulubaas = V_palk_config.tulubaas * v_palk_config.kuurs;

	if year(tdKpv) = 2014 then
		lnTulubaas := 144;
	end if;

else
	lnTulubaas :=0;	
end if;
--raise notice 'lnTulubaas %',lnTulubaas;

--lnTulubaas := case when qryTooleping.pohikoht > 0 then case when year(tdKpv) = 2004 then 1400 else 1700 end V_palk_config.tulubaas else 0 end;
if v_palk_kaart.percent_ = 0 then
	-- summa 
	lnSumma := v_palk_kaart.summa * v_palk_kaart.kuurs;
	ltSelgitus = ltSelgitus + ltrim(rtrim(round(v_palk_kaart.summa / v_palk_config.kuurs,2)::varchar))+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

else
--	raise notice 'alg';


	--muudetud 25/01/2005
	If qryTooleping.pohikoht = 1 then

		Select  Sum(Palk_oper.Summa * ifnull(dokvaluuta1.kuurs,1)) into lnTulud		
		FROM  Palk_oper inner Join palk_lib On palk_lib.parentId = Palk_oper.libId 	
		inner Join palk_kaart  On (palk_kaart.libId = Palk_oper.libId 
		And Palk_oper.lepingid = palk_kaart.lepingid)
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE palk_lib.liik = 1   And palk_kaart.tulumaks = 1   And Palk_oper.kpv = tdKpv 	
		and Palk_oper.kpv = tdKpv  And Palk_oper.rekvid = lnrekv 
		And palk_kaart.lepingid In 
		(SELECT id FROM tooleping WHERE parentid = qryTooleping.parentId AND (tooleping.id = tnlepingId  
		OR tooleping.id in (select DISTINCT lepingId FROM palk_kaart WHERE tulumaar = 0)));


		-- otsime tululiik 22 (PM)

		select sum(palk_oper.summa* ifnull(dokvaluuta1.kuurs,1)) into lnTuludPM 
		FROM  Palk_oper inner Join palk_lib On palk_lib.parentId = Palk_oper.libId 	
		inner Join palk_kaart  On (palk_kaart.libId = Palk_oper.libId And Palk_oper.lepingid = palk_kaart.lepingid)
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE palk_lib.liik = 1   And palk_kaart.tulumaks = 1   And Palk_oper.kpv = tdKpv 
		and ltrim(rtrim(palk_lib.tululiik)) = '22'
		and Palk_oper.kpv = tdKpv  And Palk_oper.rekvid = lnrekv 
		And palk_kaart.lepingid In 
		(SELECT id FROM tooleping WHERE parentid = qryTooleping.parentId AND (tooleping.id = tnlepingId  
		OR tooleping.id in (select DISTINCT lepingId FROM palk_kaart WHERE tulumaar = 0)));

		raise notice 'lnTulud %',lnTulud;
		ltSelgitus = ltSelgitus + 'Tulud:'+ltrim(round(lnTulud / v_palk_config.kuurs,2)::varchar) ;
		if ifnull(lnTuludPm,0) > 0 then
			ltSelgitus = ltSelgitus + ' s.h. PM III samba tulu: '+ltrim(rtrim(round(lnTuludPm / v_palk_config.kuurs,2)::varchar));
		end if;
		ltSelgitus = ltSelgitus + ltEnter;

		Select Sum(Palk_oper.Summa * ifnull(dokvaluuta1.kuurs,1)) into lnKulud 	
		FROM palk_kaart inner Join Palk_oper On 	
		(palk_kaart.lepingid = Palk_oper.lepingid And palk_kaart.libId = Palk_oper.libId)
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE Palk_oper.kpv = tdKpv
		AND Palk_oper.rekvid = lnrekv And palk_kaart.tulumaks = 1 
		and palk_kaart.libId In (Select Library.Id From Library inner Join palk_lib On palk_lib.parentId = Library.Id 	
		where palk_lib.liik = 2 Or palk_lib.liik = 7 Or palk_lib.liik = 8 )
		And palk_kaart.lepingid In (SELECT id FROM tooleping WHERE parentid = qryTooleping.parentId AND (id = tnlepingId  
		OR id in (select DISTINCT lepingId FROM palk_kaart WHERE tulumaar = 0)));

		raise notice 'lnKulud %',lnKulud;
		ltSelgitus = ltSelgitus + 'Kulud:'+ltrim(round(lnKulud / v_palk_config.kuurs,2)::varchar)+ltEnter;
	raise notice 'ltSelgitus %',ltSelgitus;

	else

		SELECT  sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) into lnTulud
		FROM  Palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid 
		inner join Palk_kaart  on (palk_kaart.libid = palk_oper.libid and palk_oper.lepingId = palk_kaart.lepingid) 
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE Palk_lib.liik = 1   AND Palk_kaart.tulumaks = 1   
		AND Palk_oper.kpv = tdkpv 
		AND Palk_oper.rekvId = lnrekv and palk_oper.lepingId = tnLepingid;

		-- otsime tululiik 22 (PM)

		select sum(palk_oper.summa* ifnull(dokvaluuta1.kuurs,1)) into lnTuludPM 
		FROM  Palk_oper inner Join palk_lib On palk_lib.parentId = Palk_oper.libId 	
		inner Join palk_kaart  On (palk_kaart.libId = Palk_oper.libId And Palk_oper.lepingid = palk_kaart.lepingid)
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE palk_lib.liik = 1   And palk_kaart.tulumaks = 1   And Palk_oper.kpv = tdKpv 
		and ltrim(rtrim(palk_lib.tululiik)) = '22'
		And Palk_oper.rekvid = lnrekv 
		And palk_kaart.lepingid = tnLepingid;

		raise notice 'lnTulud %',lnTulud;
		ltSelgitus = ltSelgitus + 'Tulud:'+ltrim(round(lnTulud / v_palk_config.kuurs,2)::varchar);
		if ifnull(lnTuludPm,0) > 0 then
			ltSelgitus = ltSelgitus + ' s.h. PM III samba tulu: '+ltrim(rtrim(round(lnTuludPm / v_palk_config.kuurs,2)::varchar));
		end if;
		ltSelgitus = ltSelgitus + ltEnter;

--		and val(ltrim(rtrim(palk_Lib.algoritm))) = v_palk_kaart.summa ;

--		raise notice 'lnTulud %',lnTulud;
		ltSelgitus = ltSelgitus + 'Tulud:'+ltrim(round(lnTulud/ v_palk_config.kuurs,2)::varchar)+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;


		SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) into lnKuluD  
		FROM palk_kaart inner join palk_oper on 
		(palk_kaart.lepingid = palk_oper.lepingid and palk_kaart.libid = palk_oper.libid)  
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		where palk_kaart.lepingId = tnLepingid 
		AND Palk_oper.kpv = tdKpv
		AND Palk_oper.kpv = tdKpv
		AND Palk_oper.rekvId = lnRekv and palk_kaart.tulumaks = 1 
		and palk_kaart.libid in (select library.id from library inner join palk_lib on palk_lib.parentid = library.id 
		where Palk_lib.liik = 2 OR PALK_LIB.LIIK = 7 OR PALK_LIB.LIIK = 8 );
 
		ltSelgitus = ltSelgitus + 'Kulud:'+ltrim(round(lnKulud / v_palk_config.kuurs,2) ::varchar)+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

--	and tulumaar = v_palk_kaart.summa

	end if;

--	arvestame (-) maksud PM-st
	lnTuludPm = ifnull(lnTuludPm,0);
	if lnTuludPm > 0 then
		-- tki, otsime maar
		select palk_kaart.summa into lnTKIPm from 
			palk_kaart INNER JOIN palk_lib on palk_kaart.libid = palk_lib.parentid
			where palk_kaart.lepingid = tnLepingId
			and palk_lib.liik = 7 and palk_lib.asutusest = 0;
		lnTKIPm = ifnull(lnTKIpm,0);

		-- pm, otsime maar
		select palk_kaart.summa into lnPmPm from 
			palk_kaart INNER JOIN palk_lib on palk_kaart.libid = palk_lib.parentid
			where palk_kaart.lepingid = tnLepingId
			and palk_lib.liik = 8;
		lnPmPm = ifnull(lnPmPm,0);	

		ltSelgitus = ltSelgitus + 'Parandame kulud(PM III):'+ltrim(round(lnKulud / v_palk_config.kuurs,2) ::varchar)+
			'+('+ltrim(round(lnTuludPM / v_palk_config.kuurs,2)::varchar) +'-'+ltrim(((lnTuludPm * 0.01 * lnTKIPM)/ v_palk_config.kuurs)::varchar)+
			'-'+ltrim(round((lnTuludPm * 0.01 * lnPmPm) / v_palk_config.kuurs,2)::varchar)+')'+ltEnter;

		lnKulud = lnKulud + (lnTuludPm - lnTuludPm * 0.01 * lnTKIPM - lnTuludPm * 0.01 * lnPmPm);
	end if;
	
raise notice 'lnKulud %, lnTulubaas %, qryTooleping.pohikoht %',lnKulud, lnTulubaas, qryTooleping.pohikoht;
	if lnTulubaas > 0 and qryTooleping.pohikoht > 0 then  
--		raise notice 'lnTulubaas %',lnTulubaas;
		select sum(palk_jaak.g31) into lng31_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = year(tdKpv) 
			and kuu < month(tdKpv);

		lng31 := lng31_2005;

--		raise notice 'lng31 %',lng31;
--		ltSelgitus = ltSelgitus + 'Soodus:'+ltrim(ifnull(lng31,0)::varchar)+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

		
		select count(*) into lnCount_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = year(tdKpv) 
			and kuu < month(tdKpv)
			and date(aasta,kuu,1) >= qryTooleping.algab;

	

		raise notice 'lnCount_2005 %',lnCount_2005;

		-- should be 1400 * periods
		if year(date()) = 2015 and V_palk_config.tulubaas > lnTulubaas and year(tdKpv) = 2014 then
			select count(*) into lnCount_2004 from palk_jaak 
				where lepingId = tnlepingId 
				and aasta = year(tdKpv) 
				and kuu < month(tdKpv)
				and date(aasta,kuu,1) >= qryTooleping.algab
				and kuu < 12;
			
			ng31 := (lnTulubaas * v_palk_config.kuurs * (lnCount_2004));
			lnTulubaas = V_palk_config.tulubaas * v_palk_config.kuurs ;
		else
			ng31 := lnTulubaas * v_palk_config.kuurs * lnCount_2005 ;
		end if;

		ltSelgitus = ltSelgitus + 'Soodus kokku:'+ltrim(round(ng31 / v_palk_config.kuurs,2)::varchar)+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

		lnArvJaak := lnTulud - lnKulud;
		if lnArvJaak < lnTulubaas then
			lnTulubaas := lnArvJaak;
			raise notice 'less then vaja %',lnTulubaas;
			ltSelgitus = ltSelgitus + 'Soodus arvestatud vaiksem :'+ltrim(round(lnTulubaas / v_palk_config.kuurs,2) ::varchar)+ltEnter;

		else

			if ng31 > lng31_2005 and lnCount_2005 > 0 then
--				raise notice 'with reserv  %',lnTulubaas;
				ltSelgitus = ltSelgitus + 'Soodus arvestatud suurem :'+ltrim(round(lnTulubaas / v_palk_config.kuurs,2) ::varchar)+
				'+('+ltrim(round(ng31 / v_palk_config.kuurs,2) ::varchar)+
				'-'+ltrim(round(lng31_2005/ v_palk_config.kuurs,2)::varchar)+')'+ltEnter;

				-- on reserv
				lnTulubaas := lnTulubaas + (ng31 - lng31_2005);

			end if;
--			raise notice 'with reserv after %',lnTulubaas;
--			raise notice 'limited lnArvJaak%',lnArvJaak;
			if lnTulubaas > lnArvJaak then
				lnTulubaas := lnArvJaak;
				ltSelgitus = ltSelgitus + 'Soodus parandatud :'+ltrim(round(lnTulubaas / v_palk_config.kuurs,2) ::varchar)+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

			end if;
		end if;

	end if;

	lnSumma := v_palk_kaart.summa * 0.01 * (ifnull(lnTuluD,0) - ifnull(lnTulubaas,0) - ifnull(lnkuluD,0)) / lnKuurs;
	ltSelgitus = ltSelgitus + 'Arvestus:'+ltrim((v_palk_kaart.summa) ::varchar)+
		'*0.01*('+ltrim(ifnull(round(lnTuluD / v_palk_config.kuurs,2),0)::varchar)+
		'-'+ltrim(ifnull(round(lnTulubaas / v_palk_config.kuurs,2),0)::varchar)+
		'-'+ltrim(ifnull(round(lnkuluD / v_palk_config.kuurs,2) ,0)::varchar)+
		')'+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;
	
	lnSumma := case when lnSumma < 0 then 0 else lnSumma end;
	ltSelgitus = ltSelgitus + 'Summa parandatud:'+ltrim(round(lnSumma / v_palk_config.kuurs,2)::varchar)+ltEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

-- muudetud 04/01/2005

	IF lnSumma > 0 then
		-- kontrol kas on tulumaks avansimaksetest

		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) inTO lnTulubaas 
			from palk_oper left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			where lepingId = tnLepingId AND YEAR(kpv) = YEAR(tdKpv) and MONTH(kpv) = MONTH(tdKpv)  AND libId = tnLibId 
			AND palk_oper.MUUD = 'AVANS';
		IF lnTulubaas > 0 then 
			lnSumma := lnSumma - (lnTulubaas / lnKuurs);
			ltSelgitus = ltSelgitus + 'Summa parandatud(avans):'+ltrim(round(lnSumma / v_palk_config.kuurs,2) ::varchar)+
				'-('+ltrim(round(lnTulubaas / v_palk_config.kuurs,2) ::varchar)+')'+tlEnter;
--	raise notice 'ltSelgitus %',ltSelgitus;

		END IF;
	END IF;

	lnSumma = f_round(lnSumma,qryPalkLib.Round);
--	raise notice 'lnSumma %',lnSumma;
	ltSelgitus = ltSelgitus +'Umardamine:'+ltrim(lnSumma  ::varchar);
--	raise notice 'ltSelgitus %',ltSelgitus;

	-- salvestame arvetuse analuus
	insert into tmp_viivis (rekvid, dkpv, timestamp,muud) values (qryTooleping.rekvid,tdKpv, lcTimestamp,ltSelgitus);
	
end if;
Return lnSumma;
end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_tulumaks(integer, integer, date)
  OWNER TO vlad;
  
select sp_calc_tulumaks (213, 37457, date(2014,12,31));

/*
select * from asutus where regkood = '34606053716  '

select * from tooleping where parentid = 3557

select * from library where kood = 'Tulumaks 5002 ' and rekvid = 28

*/