-- Function: public.sp_calc_kinni(int4, int4, date)

-- DROP FUNCTION public.sp_calc_kinni(int4, int4, date);

CREATE OR REPLACE FUNCTION public.sp_calc_kinni(int4, int4, date)
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
	qryTaabel1 record;
	npalk	numeric(12,4);
	nHours int;
	lnRate numeric (12,4);
	nSumma numeric (12,4);
	lnBaas numeric (12,4);
	lnkulumaks	numeric(12,4);
begin
nHours :=0;
lnSumma := 0;
nPalk:=0;
lnBaas :=0;
select * into v_palk_kaart from palk_kaart where lepingid = tnLepingid and libId = tnLibId;
select * INTO qryPalkLib from palk_lib where parentId = tnLibId;
select * into qryTooleping from tooleping where id = tnlepingId;

nHours := (sp_workdays(1,month(tdKpv), year(tdKpv), 31,v_palk_kaart.lepingId) * qryTooleping.koormus * 0.01 * qryTooleping.toopaev)::int4;
select * into qryTaabel1 from palk_taabel1 where toolepingId = tnlepingId and kuu = month(tdKpv) and aasta = year (tdKpv);

if qryPalkLib.palgafond = 0 then
		lnSumma := qryTooleping.palk * 0.01 * qryTooleping.tooPAEV * (qryTaabel1.kokku / nHours);
end if;
if qryPalkLib.palgafond = 1 then
	SELECT sum(Palk_oper.summa) INTO npalk 
		FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
		WHERE Palk_oper.kpv = tdKpv
		AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId;
End if;

If qryPalkLib.maks = 1 then
	SELECT sum (Palk_oper.summa) INTO lnkulumaks 
		FROM palk_oper inner join Palk_lib on palk_oper.libid = palk_lib.parentid 
		WHERE Palk_lib.liik = 4    AND Palk_oper.kpv = tdKpv   
		AND palk_oper.lepingId = tnLepingId;
Else
	lnkulumaks := 0;
End if;

nPalk := nPalk - lnkulumaks;

If v_palk_kaart.percent_ > 0 then
	lnSumma := f_round(nPalk * (0.01 * v_palk_kaart.summa),qryPalkLib.round);
Else
	lnSumma := f_round(v_palk_kaart.summa,qryPalkLib.round);
End if;

Return lnSumma;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
