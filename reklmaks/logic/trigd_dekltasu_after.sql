-- Function: public.sp_calc_muuda(int4, int4, date)

-- DROP FUNCTION public.sp_calc_muuda(int4, int4, date);

CREATE OR REPLACE FUNCTION public.sp_calc_muuda(int4, int4, date)
  RETURNS numeric AS
'
declare
	tnLepingid alias for $1;
	tnLibId alias for $2;
	tdKpv alias for $3;
	lnSumma numeric (12,4);
	v_palk_kaart record;
	qrytooleping record;
	qryPalkLib   record;
	v_palk_config record;
	qryTaabel1 record;
	nSumma numeric(12,4);
	nHours int4;
	lnBaas numeric(12,4);
	lnrekv int4;
begin

lnSumma :=0;

select * into v_palk_kaart from palk_kaart where lepingid = tnLepingid and libId = tnLibId;
select * INTO qryPalkLib from palk_lib where parentId = tnLibId;
select * into qryTooleping from tooleping where id = tnlepingId;
select * into v_palk_config from palk_config where rekvid = lnrekv;
select rekvId into lnrekv from library where id = qryPalkLib.parentId;
select * into qryTaabel1 from palk_taabel1 where toolepingId = tnlepingId; 


nHours := (sp_workdays(1, month(tdKpv), year(tdKpv), 31,v_palk_kaart.lepingId) / (qryTooleping.koormus * 0.01) * qryTooleping.toopaev)::INT4;
If v_palk_kaart.percent_ = 1 then
	if  qryPalkLib.palgafond = 0 then
		lnSumma := qryTooleping.palk * 0.01 * qryTooleping.toopaev * (qryTaabel1.kokku / nHours);
	end if;
	if qryPalkLib.palgafond = 1 then
		SELECT sum(Palk_oper.summa) INTO lnSumma 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			WHERE  Palk_oper.kpv = tdKpv      
			AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId;
	end if;
	lnSumma := f_round(v_palk_kaart.summa * 0.01 * lnSumma, qryPalkLib.round);
Else
	lnSumma := f_round(v_palk_kaart.Summa, qryPalkLib.round);
End if;

Return lnSumma;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
