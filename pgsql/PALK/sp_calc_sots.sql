-- Function: sp_calc_sots(integer, integer, date)
/*
select * from asutus where regkood = '46009283718  '
select * from tooleping where parentid = 254
select * from library where kood = 'SOTSIAALM '
UPDATE tooleping set pank = 1 where id = 508

select sp_calc_sots (508, 609081, date(2013,01,31))

*/
-- DROP FUNCTION sp_calc_sots(integer, integer, date);

CREATE OR REPLACE FUNCTION sp_calc_sots(integer, integer, date)
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
	nSumma numeric (12,4);
	lnBaas numeric (12,4);
	lnrekv int;
	lnMinPalk numeric (12,4);
	lnKuurs numeric(12,4);
	lnSoodus numeric(18,6);
	ltSelgitus text;
	ltEnter character;
	lcTimestamp varchar(20);


begin
lnBaas :=0;
lnsUMMA :=0;
lnSoodus = 290;
lnKuurs = fnc_currentkuurs(tdKpv);

ltSelgitus = '';
ltEnter = '
';


lcTimestamp = left('SOTS'+LTRIM(RTRIM(str(tnLepingId)))+LTRIM(RTRIM(str(tnLibId)))+ltrim(rtrim(str(dateasint(tdKpv)))),20);



select palk_kaart.summa, palk_kaart.percent_, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (dokvaluuta1.dokid = palk_kaart.id and dokvaluuta1.dokliik = 20)
	where lepingid = tnLepingid and libId = tnLibId;
	
select parentid, round INTO qryPalkLib from palk_lib where parentId = tnLibId;

If v_palk_kaart.percent_ = 1 then

	select pohikoht, pank as inv, rekvid into qryTooleping from tooleping where id = tnlepingId;
	select rekvId into lnrekv from library where id = qryPalkLib.parentId;

	select palk_config.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_config 
		from palk_config left outer join dokvaluuta1 on (palk_config.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 26) where palk_config.rekvid = lnrekv;
	
--	select minpalk into v_palk_config from palk_config where rekvid = lnrekv;

	SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnBaas 
	FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid 
	left outer join dokvaluuta1 on (dokvaluuta1.dokid = palk_oper.id and dokvaluuta1.dokliik = 12) 
	WHERE  Palk_oper.kpv = tdKpv      
	AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1;

	lnMinPalk := case when qryTooleping.pohikoht > 0 then v_palk_config.minpalk * v_palk_config.kuurs else 0 end;
	lnSumma := f_round(v_palk_kaart.summa * 0.01 * lnBaas / lnKuurs,qryPalkLib.round);

	ltSelgitus =  ltrim(rtrim(v_palk_kaart.summa::varchar))+'*'+ltrim(rtrim(lnBaas::varchar))+'*0.01 /'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

	-- soodus
	if qryTooleping.inv > 0 then
		lnSumma := f_round(v_palk_kaart.summa * 0.01 * (lnBaas - lnSoodus)/ lnKuurs,qryPalkLib.round);
		if lnSumma < 0 then
			lnSumma = 0;
		end if;
	ltSelgitus =  'parandamine, soodus'+ltrim(rtrim(v_palk_kaart.summa::varchar))+'*('+ltrim(rtrim(lnBaas::varchar))+'-'+ltrim(rtrim(lnSoodus::varchar))+') * 0.01/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;
			
	end if;
else
	lnSumma := f_round(v_palk_kaart.Summa * v_palk_kaart.kuurs / lnKuurs, qryPalkLib.round);
	ltSelgitus =  ltrim(rtrim(v_palk_kaart.summa::varchar))+'*'+ltrim(rtrim(v_palk_kaart.kuurs::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

end if;

	-- salvestame arvetuse analuus
	insert into tmp_viivis (rekvid, dkpv, timestamp,muud) values (qryTooleping.rekvid,tdKpv, lcTimestamp,ltSelgitus);
	raise notice 'selg %',ltSelgitus;
Return lnSumma;

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_sots(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_sots(integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_sots(integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_sots(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_sots(integer, integer, date) TO taabel;
GRANT EXECUTE ON FUNCTION sp_calc_sots(integer, integer, date) TO dbpeakasutaja;
