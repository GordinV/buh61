-- Function: public.sp_calc_sots(int4, int4, date)

-- DROP FUNCTION public.sp_calc_sots(int4, int4, date);

CREATE OR REPLACE FUNCTION public.sp_calc_sots(int4, int4, date)
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
	nSumma numeric (12,4);
	lnBaas numeric (12,4);
	lnrekv int;
	lnMinPalk numeric (12,4);
begin
lnBaas :=0;
lnsUMMA :=0;


select * into v_palk_kaart from palk_kaart where lepingid = tnLepingid and libId = tnLibId;
select * INTO qryPalkLib from palk_lib where parentId = tnLibId;
select * into qryTooleping from tooleping where id = tnlepingId;
select * into v_palk_config from palk_config where rekvid = lnrekv;
select rekvId into lnrekv from library where id = qryPalkLib.parentId;

SELECT sum(Palk_oper.summa) INTO lnBaas 
	FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
	WHERE  Palk_oper.kpv = tdKpv      
	AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1;

	lnMinPalk := case when qryTooleping.pohikoht > 0 then v_palk_config.minpalk else 0 end;
	lnSumma := f_round(v_palk_kaart.summa * 0.01 * lnBaas,qryPalkLib.round);

Return lnSumma;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
