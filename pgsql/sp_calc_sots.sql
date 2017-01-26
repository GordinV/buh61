-- Function: sp_calc_sots(integer, integer, date)

-- DROP FUNCTION sp_calc_sots(integer, integer, date);

CREATE OR REPLACE FUNCTION sp_calc_sots(
    integer,
    integer,
    date)
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
	ln_umardamine numeric(14,2) = 0;
	lnSotsmaksMinPalk numeric(14,2) = 0;
	l_kuu_paevad integer = 30;
	l_too_paevad integer = 30;
begin
ltEnter = '
';

lnBaas :=0;
lnsUMMA :=0;
lnKuurs = fnc_currentkuurs(tdKpv);

lcTimestamp = left('SOTS'+LTRIM(RTRIM(str(tnLepingId)))+LTRIM(RTRIM(str(tnLibId)))+ltrim(rtrim(str(dateasint(tdKpv)))),20);

--select pohikoht, rekvid, algab, lopp into qryTooleping from tooleping where id = tnlepingId;


select tooleping.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, pc.minpalk into qryTooleping 
	from tooleping left outer join dokvaluuta1 on (tooleping.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 19)
	left outer join palk_config pc on pc.rekvid = tooleping.rekvid 
	where tooleping.id = tnLepingId; 

select parentid, round INTO qryPalkLib from palk_lib where parentId = tnLibId;

select palk_kaart.summa, palk_kaart.percent_, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, 
	coalesce(palk_kaart.minsots,0) as minsots, coalesce(pc.minpalk,0) as minpalk into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (dokvaluuta1.dokid = palk_kaart.id and dokvaluuta1.dokliik = 20)
	left outer join palk_config pc on pc.rekvid = qryTooleping.rekvid
	where lepingid = tnLepingid and libId = tnLibId;

-- 2015
select sum(po.sotsmaks * ifnull(dokvaluuta1.kuurs,1)) as sotsmaks  into lnSumma
	from palk_oper po
	left outer join dokvaluuta1 on (po.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
	WHERE po.kpv = tdKpv 	
	And po.rekvid = qryTooLeping.rekvId
	and po.lepingId = tnlepingId
	and po.sotsmaks is not null;
--muudetud 03/01/2005
-- min sots
	-- paevad kuus
	l_kuu_paevad = (gomonth(date(year(tdKpv), month(tdKpv),1),1) - 1) - date(year(tdKpv), month(tdKpv),1) + 1; 
	-- kokku paevad tool
	l_too_paevad = case when coalesce(qryTooleping.lopp,tdKpv) < tdKpv then qryTooleping.lopp else tdKpv end - 
		case when qryTooleping.algab > date(year(tdKpv),month(tdKpv),1) then qryTooleping.algab else date(year(tdKpv),month(tdKpv),1) end + 
		1 - sp_puudumise_paevad(tdKpv, tnLepingid);
		
	lnSotsmaksMinPalk = (v_Palk_kaart.MinPalk * v_palk_kaart.minsots * v_palk_kaart.summa * 0.01) / l_kuu_paevad * l_too_paevad ;
	raise notice 'lnSumma %, lnSotsmaksMinPalk %, v_Palk_kaart.MinPalk  %,  l_kuu_paevad %, l_too_paevad %', lnSumma, lnSotsmaksMinPalk, v_Palk_kaart.MinPalk ,  l_kuu_paevad, l_too_paevad;
	if lnSumma < lnSotsmaksMinPalk then
		lnSotsmaksMinPalk = (lnSotsmaksMinPalk - lnSumma);
		ltSelgitus = ltSelgitus + 'SM kasutame min.palk (' + v_Palk_kaart.MinPalk::text + ') parandus maksusumma '+ round(lnSotsmaksMinPalk,2)::text +  ltEnter;
--		lnSumma = lnSotsmaksMinPalk + lnSumma;
	else
		lnSotsmaksMinPalk = 0;
	end if;


ltSelgitus = ltSelgitus + ' Enne arvestatud sotsmaks: ' + coalesce(lnSumma,0)::varchar + ltEnter;

if coalesce(lnSumma,0) > 0  or lnSotsmaksMinPalk > 0 then
	for v_tululiik in
		select distinct  pl.tululiik, l.tun2 as sots
			from palk_oper po
			inner join palk_lib pl on pl.parentId = po.libId and (pl.tululiik is not null and pl.tululiik <> '')
			inner join library l on l.kood = pl.tululiik and library = 'MAKSUKOOD'
			where po.lepingid = tnLepingId
			and po.kpv = tdKpv
	loop
		select sum(summa * v_tululiik.sots) into lnTulud
			from palk_oper po 
			where po.lepingId = tnLepingId
			and po.kpv = tdKpv
			and po.sotsmaks is not null and po.sotsmaks > 0;
			
		-- parandame summa (umardamine)
		
		ln_umardamine =  (lnTulud * 0.01 * v_palk_kaart.summa - lnSumma) * case when lnTulud > 0 then 1 else 0 end;

		if ln_umardamine <> 0 and lnTulud > 0 then
			ltSelgitus = ltSelgitus + 'SM (tululiik ' + v_tululiik.tululiik +' umardamine :' +  ln_umardamine::text + 'SM:' + lnSumma::text + ltEnter;
			update palk_oper set sotsmaks = sotsmaks + ln_umardamine 
				where id in (
					select po.id 
						from palk_oper po
						inner join palk_lib pl on pl.parentId = po.libId and (pl.tululiik is not null and pl.tululiik <> '')
						where  po.lepingId = tnLepingId
						and pl.tululiik = v_tululiik.tululiik
						and po.kpv = tdKpv
						and po.sotsmaks is not null and po.sotsmaks > 0 
						order by sotsmaks desc limit 1);
		end if;
	end loop;	
	raise notice 'lnSumma %,lnSotsmaksMinPalk %, ln_umardamine %',lnSumma ,lnSotsmaksMinPalk , ln_umardamine;
	lnSumma = f_round(lnSumma + lnSotsmaksMinPalk + ln_umardamine,qryPalkLib.round);
end if;



if lnSumma = 0 or lnSumma is null then
		
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
ALTER FUNCTION sp_calc_sots(integer, integer, date)
  OWNER TO vlad;

/*
select * from asutus where regkood = '36607022762'
select * from tooleping where parentid = 21459
select * from palk_oper 
	where lepingid = 136787
	and kpv between '2015-07-01' and '2015-07-31'
	and libid in (select id from library l inner join palk_lib pl on pl.parentid = l.id where l.rekvid =qryTooleping.rekvid )

select pl.liik, pk.* from palk_kaart pk
inner join palk_lib pl on pl.parentid = pk.libid
where lepingid = 135645


select * from palk_lib where parentid = 598809

select sp_calc_sots(135645, 26192, '2015-08-13')

select '2015-7-01'::date + interval '1 month'

select * from library where nimetus = 'SOTSIAALMAKS 08102'  and rekvid = 66

select * from palk_lib where parentid = 598809
*/
