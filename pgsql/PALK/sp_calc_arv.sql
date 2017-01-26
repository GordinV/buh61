-- Function: sp_calc_arv(integer, integer, date)

-- DROP FUNCTION sp_calc_arv(integer, integer, date);

/*
select * from asutus where regkood = '47104013758'
select * from tooleping where rekvid = 119 and parentid = 2894

select * from library order by id desc limit 1

select sp_calc_arv(131844, 599509, date(2012,01,31))

*/

CREATE OR REPLACE FUNCTION sp_calc_arv(integer, integer, date)
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
	qryTaabel1 record;
	npalk	numeric(12,4);
	nHours NUMERIC(12,4);
	lnRate numeric (12,4);
	nSumma numeric (12,4);
	lnBaas numeric (12,4);
	lnKuurs numeric(12,4);

	ltSelgitus text;
	ltEnter character;
	lcTimestamp varchar(20);


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

select * INTO qryPalkLib from palk_lib where parentId = tnLibId;

select tooleping.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into qryTooleping 
	from tooleping left outer join dokvaluuta1 on (tooleping.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 19) 
	where tooleping.id = tnLepingId; 


--raise notice 'Percent %',v_palk_kaart.percent_;

If v_palk_kaart.percent_ = 1 then
	-- calc based on taabel 
	raise notice 'calc based on taabel';
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
		ltSelgitus = ltSelgitus + 'Kokku tunnid kuues:'+ltrim(rtrim(nHours::varchar))+ltEnter;

		nHours := nHours - sp_calc_tahtpaevad(qryTooleping.rekvId, month(tdKpv));
		ltSelgitus = ltSelgitus + 'Kokku tunnid kuues, parandatud:'+ltrim(rtrim(nHours::varchar))+ltEnter;

	END IF;

		--raise notice 'hOUR %',nHours;
		if qryTooleping.tasuliik = 1 then
			lnRate := (qryTooleping.palk * qryTooleping.kuurs)/ nHours * 0.01 * qryTooleping.koormus ;
			--raise notice 'Rate %',lnrate;
			ltSelgitus = ltSelgitus + 'Tunni hind:'+ltrim(rtrim(lnRate::varchar))+ltEnter;

		end if;

		if qryTooleping.tasuliik = 2 then
			lnSumma := f_round((qryTooleping.palk * qryTooleping.kuurs) * qryTaabel1.kokku / lnKuurs,qryPalkLib.round);
			lnRate := qryTooleping.palk * qryTooleping.kuurs;
			ltSelgitus = ltSelgitus + 'arvestus:'+ltrim(rtrim(qryTooleping.palk::varchar))+'*'+ltrim(rtrim(qryTooleping.kuurs::varchar))+'*'+
				ltrim(rtrim(qryTaabel1.kokku::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;
			
			-- muudetud 01/02/2005
			if qryPalkLib.tund = 5 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev  / lnKuurs,qryPalkLib.round);
				ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.tahtpaev::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			end if;
			If  qryPalkLib.tund = 6 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev  / lnKuurs,qryPalkLib.round);
				ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.puhapaev::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			End if;
			If  qryPalkLib.tund = 7 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo / lnKuurs,qryPalkLib.round);
				ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.uleajatoo::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			End if;
			if qryPalkLib.tund =3 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu / lnKuurs,qryPalkLib.round);
				ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.ohtu::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			end if;
			if qryPalkLib.tund =4 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo / lnKuurs,qryPalkLib.round);
				ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.oo::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			end if;
			if qryPalkLib.tund =2 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev / lnKuurs,qryPalkLib.round);
				ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.paev::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			end if;

			return lnSumma;

		end if;

		If  qryPalkLib.tund = 5 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev / lnKuurs,qryPalkLib.round);
			ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.tahtpaev::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			lnBaas := qryTaabel1.tahtpaev;

		End if;

		If  qryPalkLib.tund = 6 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev / lnKuurs,qryPalkLib.round);
			lnBaas := qryTaabel1.puhapaev;
			ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.puhapaev::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

		End if;

		If  qryPalkLib.tund = 7 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo / lnKuurs,qryPalkLib.round);

			lnBaas := qryTaabel1.uleajatoo;
			ltSelgitus = ltSelgitus + 'parandamine:'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.uleajatoo::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;


		End if;

		If  qryPalkLib.tund < 5 then			

			if qryPalkLib.tund =3 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu;

				ltSelgitus = ltSelgitus + 'parandamine(nSumma):'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.ohtu::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;


			end if;

			if qryPalkLib.tund =4 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo;
				ltSelgitus = ltSelgitus + 'parandamine(nSumma):'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.oo::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			end if;

			if qryPalkLib.tund =2 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev;
				ltSelgitus = ltSelgitus + 'parandamine(nSumma):'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.paev::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			end if;

			if qryPalkLib.tund =1 then

				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.kokku;
				ltSelgitus = ltSelgitus + 'parandamine(nSumma):'+ltrim(rtrim(lnRate::varchar))+'*'+ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*0.01*'+
					ltrim(rtrim(qryTaabel1.kokku::varchar))+'/'+ltrim(rtrim(lnKuurs::varchar))+ltEnter;

			end if;

--			raise notice 'nSumma %',nSumma;


--			raise notice 'lnSumma %',lnSumma;


			lnSumma := lnSumma + f_round( nSumma / lnKuurs, qryPalkLib.round);
--			ltSelgitus = ltSelgitus + 'parandamine(kokku):'+ltrim(rtrim(lnSumma::varchar))+'+'+ltrim(rtrim((nSumma / lnKuurs)::varchar))+ltEnter;


--			raise notice 'LnSumma %',lnSumma;


--			raise notice '	qryPalklib.round %',qrypalklib.round;

			lnBaas := lnBaas + case when qryPalkLib.tund =3 then qryTaabel1.ohtu else 

				case when qryPalkLib.tund =4 then qryTaabel1.oo else qryTaabel1.paev end end; 

		End if;

	Else

--		lnBaas := calc_alimentid ();

--		lnPalk = f_round( lnBaas * v_palk_kaart.Summa * 0.01)

	End if;



Else

	lnSumma := f_round(v_palk_kaart.Summa * v_palk_kaart.kuurs / lnKuurs,qryPalkLib.round);
	ltSelgitus = ltSelgitus +ltrim(rtrim(v_palk_kaart.Summa::varchar))+'*'+ltrim(rtrim(v_palk_kaart.kuurs::varchar))+ '/' +ltrim(rtrim(lnKuurs::varchar))+ltEnter;

	lnBaas := 0;

End if;


	-- salvestame arvetuse analuus
	insert into tmp_viivis (rekvid, dkpv, timestamp,muud) values (qryTooleping.rekvid,tdKpv, lcTimestamp,ltSelgitus);

Return lnSumma;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_arv(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO dbpeakasutaja;
