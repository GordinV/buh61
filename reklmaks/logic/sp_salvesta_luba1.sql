-- Function: sp_calc_tulumaks(int4, int4, date)

-- DROP FUNCTION sp_calc_tulumaks(int4, int4, date);
-- muudetud 03/01/2004
-- lisatud soodus 1700 kroon

CREATE OR REPLACE FUNCTION sp_calc_tulumaks(int4, int4, date)
  RETURNS "numeric" AS
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
	qryTulumaks record;
	nSumma numeric (12,4);
	lnBaas numeric (12,4);
	lnrekv int;
	lnMinPalk numeric (12,4);
	lnTulud numeric (12,4);
	lnKulud numeric (12,4);
	lnTulubaas numeric(12,4);	
	lnG31 numeric(12,4);
	lnG31_2004 numeric(12,4);
	lnG31_2005 numeric(12,4);

	nG31 numeric(12,4);
	lnCount	int;
	lnCount_2004	int;
	lnCount_2005	int;
	lnArvJaak numeric (12,4);
begin
lnBaas :=0;
lnsUMMA :=0;


select * into v_palk_kaart from palk_kaart where lepingid = tnLepingid and libId = tnLibId;
select * INTO qryPalkLib from palk_lib where parentId = tnLibId;
select * into qryTooleping from tooleping where id = tnlepingId;
select rekvId into lnrekv from library where id = qryPalkLib.parentId;
select * into v_palk_config from palk_config where rekvid = lnrekv;

--muudetud 03/01/2005
if qryTooleping.pohikoht > 0  then
	if year(date()) = 2004 then
		lnTulubaas := 1400;
	else
		lnTulubaas := 1700;
	end if;
else
	lnTulubaas :=0;	
end if;
raise notice \'lnTulubaas %\',lnTulubaas;
--lnTulubaas := case when qryTooleping.pohikoht > 0 then case when year(tdKpv) = 2004 then 1400 else 1700 end V_palk_config.tulubaas else 0 end;
if v_palk_kaart.percent_ = 0 then
	-- summa 
	lnSumma := v_palk_kaart.summa;

else
	SELECT  sum(Palk_oper.summa ) into lnTulud
		FROM  Palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid 
		inner join Palk_kaart  on (palk_kaart.libid = palk_oper.libid and palk_oper.lepingId = palk_kaart.lepingid) 
		WHERE Palk_lib.liik = 1   AND Palk_kaart.tulumaks = 1   
		AND Palk_oper.kpv = tdkpv 
		and palk_oper.kpv = tdKpv  
		AND Palk_oper.rekvId = lnrekv and palk_oper.lepingId = tnLepingid;

--		and val(ltrim(rtrim(palk_Lib.algoritm))) = v_palk_kaart.summa ;

raise notice \'lnTulud %\',lnTulud;


	SELECT sum(Palk_oper.summa) into lnKuluD  
	FROM palk_kaart inner join palk_oper on 
	(palk_kaart.lepingid = palk_oper.lepingid and palk_kaart.libid = palk_oper.libid)  
	where palk_kaart.lepingId = tnLepingid 
	AND Palk_oper.kpv = tdKpv
	AND Palk_oper.kpv = tdKpv
	AND Palk_oper.rekvId = lnRekv and palk_kaart.tulumaks = 1 
	and palk_kaart.libid in (select library.id from library inner join palk_lib on palk_lib.parentid = library.id 
	where Palk_lib.liik = 2 OR PALK_LIB.LIIK = 7 OR PALK_LIB.LIIK = 8 ); 

--	and tulumaar = v_palk_kaart.summa


raise notice \'lnKulud %\',lnKulud;
	if lnTulubaas > 0 and qryTooleping.pohikoht > 0 then  
--		raise notice \'lnTulubaas %\',lnTulubaas;

		-- calc g31 column : sum( g31) for all period where arv > 0 

		-- muudetud 03/01/2005
	
		select sum(palk_jaak.g31) into lng31_2004 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = year(tdKpv) 
			and aasta = 2004
			and kuu < month(tdKpv);

		select sum(palk_jaak.g31) into lng31_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = year(tdKpv) 
			and aasta <= 2005
			and kuu < month(tdKpv);

		lng31 := lng31_2004+lng31_2005;

		raise notice \'lng31 %\',lng31;

		select count(*) into lnCount_2004 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = year(tdKpv) 
			and kuu < month(tdKpv)
			and aasta = 2004
			and date(aasta,kuu,1) >= qryTooleping.algab;

		select count(*) into lnCount_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = year(tdKpv) 
			and kuu < month(tdKpv)
			and aasta >= 2005
			and date(aasta,kuu,1) >= qryTooleping.algab;


--		raise notice \'lnCount %\',lnCount;

		-- should be 1400 * periods
		ng31 := 1400 * lnCount_2004 + 1700 * lnCount_2005 ;
--		raise notice \'ng31 %\',ng31;

		lnArvJaak := lnTulud - lnKulud;
		if lnArvJaak < lnTulubaas then
			lnTulubaas := lnArvJaak;
--			raise notice \'less then vaja %\',lnTulubaas;
		else

			if ng31 > (lng31_2004+lng31_2005) and (lnCount_2004+lnCount_2005) > 0 then
				-- on reserv
				lnTulubaas := lnTulubaas + (ng31 - (lng31_2004+lng31_2005));
--				raise notice \'with reserv  %\',lnTulubaas;
			end if;
--			raise notice \'with reserv after %\',lnTulubaas;
--			raise notice \'limited lnArvJaak%\',lnArvJaak;
			if lnTulubaas > lnArvJaak then
				lnTulubaas := lnArvJaak;
			end if;
		end if;

	end if;

	lnSumma := f_round(v_palk_kaart.summa * 0.01 * (ifnull(lnTuluD,0) - ifnull(lnTulubaas,0) - ifnull(lnkuluD,0)),qryPalkLib.Round);
	lnSumma := case when lnSumma < 0 then 0 else lnSumma end;

-- muudetud 04/01/2005
	IF lnSumma > 0 then
		-- kontrol kas on tulumaks avansimaksetest

		select sum(summa) inTO lnTulubaas from palk_oper 
			where lepingId = tnLepingId AND YEAR(kpv) = YEAR(tdKpv) and MONTH(kpv) = MONTH(tdKpv)  AND libId = tnLibId 
			AND MUUD = ''AVANS'';
		IF lnTulubaas > 0 then 
			lnSumma := lnSumma - lnTulubaas;
		END IF;
	END IF;


	--raise notice \'lnSumma %\',lnSumma;
end if;
Return lnSumma;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;

GRANT EXECUTE ON FUNCTION sp_calc_tulumaks(int4, int4, date) TO GROUP dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_tulumaks(int4, int4, date) TO GROUP dbkasutaja;
