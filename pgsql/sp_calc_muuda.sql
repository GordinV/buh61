-- Function: sp_calc_muuda(integer, integer, date)

-- DROP FUNCTION sp_calc_muuda(integer, integer, date);

CREATE OR REPLACE FUNCTION sp_calc_muuda(integer, integer, date)
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
begin

lnSumma :=0;
lnKuurs =  fnc_currentkuurs(tdKpv);

select palk_kaart .*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20)	
	where lepingid = tnLepingid and libId = tnLibId;
	
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
		if qryPalkLib.liik = 7  then
			raise notice '7';
			SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnSumma 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE  Palk_oper.kpv = tdKpv      
			AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1 
			and palk_lib.tululiik <> '13';
		end if;	
		if  qryPalkLib.liik = 8 then
			raise notice '8';
			SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnSumma 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE  Palk_oper.kpv = tdKpv      
			AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1;
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
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_muuda(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO taabel;
