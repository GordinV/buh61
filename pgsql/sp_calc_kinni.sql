-- Function: sp_calc_kinni(integer, integer, date)

-- DROP FUNCTION sp_calc_kinni(integer, integer, date);

CREATE OR REPLACE FUNCTION sp_calc_kinni(integer, integer, date)
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
	nHours int;
	lnRate numeric (12,4);
	nSumma numeric (12,4);
	lnBaas numeric (12,4);
	lnkulumaks	numeric(12,4);
	lnKuurs numeric(12,4);
begin
nHours :=0;
lnSumma := 0;
nPalk:=0;
lnBaas :=0;
lnKuurs = fnc_currentkuurs(tdKpv);

select palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20)
	where lepingid = tnLepingid and libId = tnLibId;
	
select * INTO qryPalkLib from palk_lib where parentId = tnLibId;
select tooleping.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into qryTooleping 
	from tooleping left outer join dokvaluuta1 on (tooleping.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 19)
	where tooleping.id = tnlepingId;

nHours := (sp_workdays(1,month(tdKpv), year(tdKpv), 31,v_palk_kaart.lepingId) * qryTooleping.koormus * 0.01 * qryTooleping.toopaev)::int4;
select * into qryTaabel1 from palk_taabel1 where toolepingId = tnlepingId and kuu = month(tdKpv) and aasta = year (tdKpv);

if qryPalkLib.palgafond = 0 then
		lnSumma := qryTooleping.palk * qryTooleping.kuurs  * 0.01 * qryTooleping.tooPAEV * (qryTaabel1.kokku / nHours) / lnKuurs;
end if;

nPalk = 0;

if qryPalkLib.palgafond = 1 then
	IF qryPalkLib.LIIK = 7  THEN
		SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO npalk 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE  Palk_oper.kpv = tdKpv      
			AND Palk_lib.liik = 1 
			and palk_oper.lepingId = tnLepingId 
			and palk_lib.tululiik not in (select kood from library where library = 'MAKSUKOOD' and tun4 = 0) 
			and palk_lib.sots = 1 ;

	END IF;
	IF qryPalkLib.LIIK = 8  THEN
--		raise notice '8';
		SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO npalk 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE  Palk_oper.kpv = tdKpv      
			AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1;

	END IF;
	IF nPalk = 0 and qryPalkLib.LIIK <> 7  and qryPalkLib.LIIK <> 8  THEN
			SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO npalk 
			FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid  
			left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			WHERE Palk_oper.kpv = tdKpv
			AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId;
	end if;
	
End if;

If qryPalkLib.maks = 1 then
	SELECT sum (Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnkulumaks 
		FROM palk_oper inner join Palk_lib on palk_oper.libid = palk_lib.parentid 
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
		WHERE Palk_lib.liik = 4    AND Palk_oper.kpv = tdKpv   
		AND palk_oper.lepingId = tnLepingId;
Else
	lnkulumaks := 0;
End if;

--raise notice ' npalk: %',npalk;

nPalk := nPalk - lnkulumaks;

If v_palk_kaart.percent_ > 0 then
	lnSumma := f_round(nPalk * (0.01 * v_palk_kaart.summa) / lnKuurs,qryPalkLib.round);
Else
	lnSumma := f_round(v_palk_kaart.summa * v_palk_kaart.kuurs / lnKuurs,qryPalkLib.round);
End if;

-- muudetud 23/02/2005
IF lnSumma > 0 then
		-- kontrol kas on tulumaks avansimaksetest

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) inTO lnkulumaks 
		from palk_oper 
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
		where palk_oper.lepingId = tnLepingId 
		AND YEAR(palk_oper.kpv) = YEAR(tdKpv) 
		and MONTH(palk_oper.kpv) = MONTH(tdKpv)  
		AND palk_oper.libId = tnLibId 
		AND palk_oper.MUUD = 'AVANS';

		IF lnkulumaks > 0 then 
			lnSumma := lnSumma - lnkulumaks / lnKuurs;
		END IF;
	END IF;

Return lnSumma;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_kinni(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_kinni(integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_kinni(integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_kinni(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_kinni(integer, integer, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_kinni(integer, integer, date) TO taabel;
