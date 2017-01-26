-- Function: public.sp_calc_arv(int4, int4, date)

-- DROP FUNCTION public.sp_calc_arv(int4, int4, date);

CREATE OR REPLACE FUNCTION public.sp_calc_arv(int4, int4, date)
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
begin
nHours :=0;
lnSumma := 0;
nPalk:=0;
lnBaas :=0;
select * into v_palk_kaart from palk_kaart where lepingid = tnLepingid and libId = tnLibId;
select * INTO qryPalkLib from palk_lib where parentId = tnLibId;
raise notice \'Percent %\',v_palk_kaart.percent_;
If v_palk_kaart.percent_ = 1 then
	-- calc based on taabel 
	raise notice \'calc based on taabel\';
	If v_palk_kaart.alimentid = 0 then
		raise notice \'alimentid = 0\';
		
		select * into qryTooleping from tooleping where id = tnLepingId; 
		select * into qryTaabel1 from palk_taabel1 where toolepingId = tnlepingId 
			and kuu = month(tdKpv) and aasta = year (tdKpv);
		if not found then
			raise notice \'TAABEL1 NOT FOUND\';
			return lnSumma;
		end if;
		nHours := (sp_workdays(1, month(tdKpv), year(tdKpv), 31,v_palk_kaart.lepingId) / (qryTooleping.koormus * 0.01) * qryTooleping.toopaev)::INT4;
--		nHours := (sp_workdays(1, month(tdKpv), year(tdKpv), 31,v_palk_kaart.lepingId)  * qryTooleping.toopaev)::INT4;
			raise notice \'hOUR %\',nHours;


		if qryTooleping.tasuliik = 1 then
			lnRate := qryTooleping.palk / nHours;
		end if;
		if qryTooleping.tasuliik = 2 then
			lnSumma := f_round(qryTooleping.palk * qryTaabel1.kokku,qryPalkLib.round);
			lnRate := qryTooleping.palk;
			return lnSumma;
		end if;
		If  qryPalkLib.tund = 5 then
			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev,qryPalkLib.round);
			lnBaas := qryTaabel1.tahtpaev;
		End if;
		If  qryPalkLib.tund = 6 then
			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev,qryPalkLib.round);
			lnBaas := qryTaabel1.puhapaev;
		End if;
		If  qryPalkLib.tund < 5 then			
			if qryPalkLib.tund =3 then
				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu;
			end if;
			if qryPalkLib.tund =4 then
				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo;
			end if;
			if qryPalkLib.tund =2 then
				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev;
			end if;
			if qryPalkLib.tund =1 then
				nSumma := lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.kokku;
			end if;
--			raise notice \'nSumma %\',nSumma;
--			raise notice \'lnSumma %\',lnSumma;
			lnSumma := lnSumma + f_round( nSumma, qryPalkLib.round);
--			raise notice \'LnSumma %\',lnSumma;
--			raise notice \'	qryPalklib.round %\',qrypalklib.round;
			lnBaas := lnBaas + case when qryPalkLib.tund =3 then qryTaabel1.ohtu else 
				case when qryPalkLib.tund =4 then qryTaabel1.oo else qryTaabel1.paev end end; 
		End if;
	Else
--		lnBaas := calc_alimentid ();
--		lnPalk = f_round( lnBaas * v_palk_kaart.Summa * 0.01)
	End if;

Else
	lnSumma := f_round(v_palk_kaart.Summa,qryPalkLib.round);
	lnBaas := 0;
End if;

Return lnSumma;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
