--DROP FUNCTION if exists sp_calc_sots(integer, integer, date);

CREATE OR REPLACE FUNCTION sp_calc_sots(integer, integer, date)
  RETURNS numeric AS
$BODY$
declare
	tnLepingid alias for $1;
	tnLibId alias for $2;
	tdKpv alias for $3;
	lnSumma numeric (12,4) = 0;
	v_palk_kaart record;
	qrytooleping record;
	qryPalkLib   record;
	v_palk_config record;
	nSumma numeric (12,4) = 0;
	lnBaas numeric (12,4);
	lnrekv int;
	lnMinPalk numeric (12,4) = 0;
	lnKuurs numeric(12,4) = 1;

	ltSelgitus text = '';
	ltEnter character;
	lcTimestamp varchar(20);

	v_tululiik record;
	lnTulud numeric(14,2) = 0;
	ln_umardamine numeric(14,4) = 0;
	lnSotsmaksMinPalk numeric(14,4) = 0;
	lnEnneArvestatudSotsmaks numeric(14,4) = 0;
	lnEnneKoostatudSotsmaks numeric(14,4) = 0;
	lnEnneArvestatudSM numeric(14,4) = 0;
	l_min_sots boolean = false;
	l_kuu_paevad integer = 30;
	l_too_paevad integer = 30;
	l_puudu_paevad integer = 0;
	l_last_paev date = (date(year(tdKpv), month(tdKpv),1) + interval '1 month')::date  - 1;
	
begin
ltEnter = '
';

lnBaas :=0;
lnsUMMA :=0;
lnKuurs = fnc_currentkuurs(tdKpv);

lcTimestamp = left('SOTS'+LTRIM(RTRIM(str(tnLepingId)))+LTRIM(RTRIM(str(tnLibId)))+ltrim(rtrim(str(dateasint(tdKpv)))),20);

select pohikoht, rekvid, algab, lopp, parentid into qryTooleping from tooleping where id = tnlepingId;
select parentid, round INTO qryPalkLib from palk_lib where parentId = tnLibId;

select palk_kaart.summa, palk_kaart.percent_, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, 
	coalesce(palk_kaart.minsots,0) as minsots, coalesce(pc.minpalk,0) as minpalk into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (dokvaluuta1.dokid = palk_kaart.id and dokvaluuta1.dokliik = 20)
	left outer join palk_config pc on pc.rekvid = qryTooleping.rekvid
	where lepingid = tnLepingid and libId = tnLibId;

-- 2015
select sum(po.sotsmaks ) as sotsmaks, sum(po.summa)  into lnSumma, lnTulud
	from palk_oper po
	inner join library l on l.id = po.libid
	inner join palk_lib pl on pl.parentid = l.id
	left outer join dokvaluuta1 on (po.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE po.kpv = tdKpv 	
	And po.rekvid = qryTooLeping.rekvId
	and po.lepingId = tnlepingId
	and pl.liik = 1
	and po.sotsmaks is not null;
--muudetud 03/01/2005
-- min sots
	-- paevad kuus
	l_kuu_paevad = (gomonth(date(year(tdKpv), month(tdKpv),1),1) - 1) - date(year(tdKpv), month(tdKpv),1) + 1; 
	l_puudu_paevad = sp_puudumise_paevad(l_last_paev, tnLepingid);
	-- kokku paevad tool
	l_too_paevad = case when coalesce(qryTooleping.lopp,l_last_paev) < l_last_paev then qryTooleping.lopp else l_last_paev end - 
		case when qryTooleping.algab > date(year(tdKpv),month(tdKpv),1) then qryTooleping.algab else date(year(tdKpv),month(tdKpv),1) end + 
		1 - l_puudu_paevad;
		
-- kontrollime enne arvestatud sotsmaks
	select sum(summa) into lnEnneArvestatudSotsmaks
	 from palk_oper 
	 where lepingid in (
			select id from tooleping where parentid = qryTooleping.parentid and rekvid = qryTooleping.rekvId				
			)
	and year(kpv) = year(tdKpv) and month(kpv) = month(tdKpv) 
	and libId in (
		select parentId from palk_lib where liik = 5 
		)
	and id not in (select id from palk_oper where lepingId = tnLepingId and libId = tnLibid and kpv = tdKpv);	

	lnEnneArvestatudSotsmaks = coalesce(lnEnneArvestatudSotsmaks,0);

-- kontrollime SM arvestus 

	-- kontrollime enne koostatud sotsmaks (ilma kaesoaleva lepinguta)
	select sum(sotsmaks) into lnEnneKoostatudSotsmaks
		 from palk_oper 
		 where lepingid in (
				select id from tooleping where parentid = qryTooleping.parentid and rekvid = qryTooleping.rekvId and id <> tnlepingId				
				)
		and year(kpv) = year(tdKpv) and month(kpv) = month(tdKpv) and libId in (
			select parentId from palk_lib where liik = 1
		);	

		raise notice ' lnEnneKoostatudSotsmaks %', lnEnneKoostatudSotsmaks;
		if coalesce(lnEnneArvestatudSotsmaks,0) >  lnEnneKoostatudSotsmaks  then
			-- sotsmaks min.pallgast oli kasutusel
			l_min_sots = true;
		end if;
		
		if coalesce(lnEnneArvestatudSotsmaks,0) = 0 and coalesce(lnEnneKoostatudSotsmaks , 0) > 0 then
			lnEnneArvestatudSotsmaks = lnEnneKoostatudSotsmaks;
		end if;

	if l_puudu_paevad = 0 then	
		l_too_paevad = 30;
	end if;

	lnSotsmaksMinPalk = ((v_Palk_kaart.MinPalk * v_palk_kaart.minsots * v_palk_kaart.summa * 0.01) / 30 * (l_too_paevad) ) - coalesce(lnEnneArvestatudSotsmaks,0);

	if lnSotsmaksMinPalk <= 0 then
		lnSotsmaksMinPalk = 0;
		if l_min_sots then
			lnSumma = 0; -- min. sotsmaks juba kasutusel
			ltSelgitus = ltSelgitus + 'SM min.palgast juba rakendatud ' +  ltEnter;
			raise notice 'lnSumma %', lnSumma;
		end if;
	end if;

	raise notice 'l_min_sots %, lnSumma %,lnEnneArvestatudSotsmaks %, lnSotsmaksMinPalk %, v_Palk_kaart.MinPalk  %,  l_kuu_paevad %, l_too_paevad %, l_puudu_paevad %', l_min_sots, lnSumma, lnEnneArvestatudSotsmaks, lnSotsmaksMinPalk, v_Palk_kaart.MinPalk ,  l_kuu_paevad, l_too_paevad, l_puudu_paevad;
	
	if lnSumma < lnSotsmaksMinPalk and (lnTulud = 0 or lnSumma > 0) 
		
	then
		-- ainult , kui olid tulud
		lnSotsmaksMinPalk = (lnSotsmaksMinPalk  - lnSumma);
		ltSelgitus = ltSelgitus + 'SM kasutame min.palk (' + v_Palk_kaart.MinPalk::text + ' / 30 * (30 - ' + l_puudu_paevad::text + '))' +
			case when coalesce(lnEnneArvestatudSotsmaks,0) <> 0 then ' Enne arvestatud sotsmaks' + lnEnneArvestatudSotsmaks::text else '' end +
		 ' parandus maksusumma '+ round(lnSotsmaksMinPalk,2)::text +  ltEnter;
--		lnSumma = lnSotsmaksMinPalk + lnSumma;
	else
		lnSotsmaksMinPalk = 0;
	end if;

if lnSumma <> 0 then
	ltSelgitus = ltSelgitus + ' Enne arvestatud sotsmaks: ' + coalesce(lnSumma,0)::varchar + ltEnter;
end if;

	lnSumma = f_round(lnSumma + lnSotsmaksMinPalk + ln_umardamine,qryPalkLib.round);


if (lnSumma = 0 and not l_min_sots) or lnSumma is null then
		
	If v_palk_kaart.percent_ = 1 then


		select palk_config.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_config 
			from palk_config left outer join dokvaluuta1 on (palk_config.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 26) where palk_config.rekvid = qryTooLeping.rekvid;
	
		SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnBaas 
		FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid 
		left outer join dokvaluuta1 on (dokvaluuta1.dokid = palk_oper.id and dokvaluuta1.dokliik = 12) 
		WHERE  Palk_oper.kpv = tdKpv      
		AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1;

		lnMinPalk := case when qryTooleping.pohikoht > 0 then v_palk_config.minpalk * v_palk_config.kuurs else 0 end;
		lnSumma := v_palk_kaart.summa * 0.01 * lnBaas / lnKuurs;
	else
		lnSumma := v_palk_kaart.Summa * v_palk_kaart.kuurs / lnKuurs;
	end if;
end if;
	lnSumma = f_round(lnSumma,qryPalkLib.Round);
	ltSelgitus = ltSelgitus +'Umardamine:'+ltrim(lnSumma::varchar);

	-- salvestame arvetuse analuus
	delete from tmp_viivis where timestamp = lcTimestamp;
	insert into tmp_viivis (rekvid, dkpv, timestamp,muud, volg2) values (qryTooleping.rekvid,tdKpv, lcTimestamp,ltSelgitus, lnSotsmaksMinPalk);
Return lnSumma;

end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


select  sp_calc_sots(141048, 289507, date(2016,02,29))
/*
select * from asutus where regkood ilike '47706063711%'

select po.* 
from palk_oper po 
inner join tooleping t on t.id = po.lepingid
where kpv = date(2016,02,29) and parentid = 38761

*/