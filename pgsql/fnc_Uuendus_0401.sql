-- Function: gen_palkoper(integer, integer, integer, date, integer)

-- DROP FUNCTION gen_palkoper(integer, integer, integer, date, integer);

CREATE OR REPLACE FUNCTION gen_palkoper(integer, integer, integer, date, integer)
  RETURNS integer AS
$BODY$
declare
	tnLepingId alias for $1;
	tnLibId alias for $2;
	tnDokLausId alias for $3;
	tdKpv alias for $4;
	tnAvans alias for $5;

	lnLiik int;
	qrypalklib record;
	v_klassiflib record;
	v_palk_kaart record;
	v_dokprop record;
	lnAsutusest int;
	lnSumma numeric(12,4);
	lcTunnus varchar;
	lnPalkOperId int;
	lnJournalId int;
	lcTp varchar;
	v_valuuta record;
begin
	raise notice 'start';

	SELECT Library.kood, ifnull((select valuuta1.kuurs from valuuta1 
		where parentid = library.id order by Library.id desc limit 1),0) as kuurs into v_valuuta
		FROM Library WHERE  library = 'VALUUTA' and library.tun1 = 1;

	lcTp := '800699';
	lcTunnus := space(1);
	lnSumma := 0;
	select * into v_klassiflib from klassiflib where libId = tnLibId;
	select * into v_palk_kaart from palk_kaart where libId = tnLibId and lepingId = tnLepingId;
	select palk_lib.*, library.rekvId into qrypalklib from palk_lib inner join library on library.id = palk_lib.parentid 
		where palk_lib.parentid = tnLibId;
	select * into v_dokprop from dokprop where id = tnDokLausId;

	if qryPalkLib.liik = 1 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_arv(tnLepingId, tnLibId, tdKpv);
		raise notice 'summa %',lnSumma;
	end if;		
	if qryPalkLib.liik = 2 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 3 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 4 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_tulumaks(tnLepingId, tnLibId, tdKpv);
		lcTp := '014003';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;
	end if;		
	if qryPalkLib.liik = 5 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_sots(tnLepingId, tnLibId, tdKpv);
		lcTp := '014003';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;

	end if;		
	if qryPalkLib.liik = 6 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_tasu(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 7 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		if lnAsutusest < 1 then
			lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
		else
			lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
		end if;
		lcTp := '014003';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;
	end if;		
	if qryPalkLib.liik = 8 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;	
	raise notice 'lnSumma> %',lnSumma;
	
	if lnSumma > 0 then
		if v_klassiflib.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_klassiflib.tunnusId;
		end if;
		if v_palk_kaart.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_palk_kaart.tunnusId;
		end if;

		lcTunnus = ifnull(lcTunnus,space(1));	

		-- pohivaluuta
--		lnSumma = lnSumma / fnc_currentkuurs(tdKpv);

		lnPalkOperId = sp_salvesta_palk_oper(0, qryPalkLib.rekvid, tnLibId, tnlepingid, tdKpv, lnSumma, tnDoklausid, '', 
			ifnull(v_klassiflib.kood1,space(1)),ifnull(v_klassiflib.kood2,'LE-P'), ifnull(v_klassiflib.kood3,space(1)), 
			ifnull(v_klassiflib.kood4,space(1)), ifnull(v_klassiflib.kood5,space(1)), ifnull(v_klassiflib.konto,space(1)), 
			 lcTp, lcTunnus,v_valuuta.kood, v_valuuta.kuurs,v_klassiflib.proj );


--		lisatud 31/12/2004
		IF tnAvans > 0 AND qryPalkLib.liik = 6 then 	
			perform sp_calc_avansimaksed(lnpalkOperId);
		END IF;

	end if;
	Return lnpalkOperId;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_palkoper(integer, integer, integer, date, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO dbpeakasutaja;


-- Function: sp_calc_tulumaks(integer, integer, date)

-- DROP FUNCTION sp_calc_tulumaks(integer, integer, date);

CREATE OR REPLACE FUNCTION sp_calc_tulumaks(integer, integer, date)
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
	lnKuurs  numeric(12,4);
begin
lnBaas :=0;
lnsUMMA :=0;
lnKuurs =  fnc_currentkuurs(tdKpv);


select  palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20) 
	where lepingid = tnLepingid and libId = tnLibId;
	
select * into qryTooleping from tooleping where id = tnlepingId;

--muudetud 25/01/2005
IF v_palk_kaart.tulumaar = 0 AND qryTooleping.pohikoht = 0 then
	RETURN 0;
END IF;


select * INTO qryPalkLib from palk_lib where parentId = tnLibId;
select rekvId into lnrekv from library where id = qryPalkLib.parentId;
select * into v_palk_config from palk_config where rekvid = lnrekv;



--muudetud 03/01/2005

if qryTooleping.pohikoht > 0  then
/*
	if year(date()) = 2004 then
		lnTulubaas := 1400;
	else
		lnTulubaas := 1700;
	end if;
*/
	lnTulubaas = V_palk_config.tulubaas;
else
	lnTulubaas :=0;	
end if;
raise notice 'lnTulubaas %',lnTulubaas;
--lnTulubaas := case when qryTooleping.pohikoht > 0 then case when year(tdKpv) = 2004 then 1400 else 1700 end V_palk_config.tulubaas else 0 end;
if v_palk_kaart.percent_ = 0 then
	-- summa 
	lnSumma := v_palk_kaart.summa * v_palk_kaart.kuurs;

else
--	raise notice 'alg';


	--muudetud 25/01/2005
	If qryTooleping.pohikoht = 1 then

		Select  Sum(Palk_oper.Summa * ifnull(dokvaluuta1.kuurs,1)) into lnTulud		
		FROM  Palk_oper inner Join palk_lib On palk_lib.parentId = Palk_oper.libId 	
		inner Join palk_kaart  On (palk_kaart.libId = Palk_oper.libId 
		And Palk_oper.lepingid = palk_kaart.lepingid)
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE palk_lib.liik = 1   And palk_kaart.tulumaks = 1   And Palk_oper.kpv = tdKpv 	
		and Palk_oper.kpv = tdKpv  And Palk_oper.rekvid = lnrekv 
		And palk_kaart.lepingid In 
		(SELECT id FROM tooleping WHERE parentid = qryTooleping.parentId AND (tooleping.id = tnlepingId  
		OR tooleping.id in (select DISTINCT lepingId FROM palk_kaart WHERE tulumaar = 0)));


	raise notice 'lnTulud %',lnTulud;

		Select Sum(Palk_oper.Summa * ifnull(dokvaluuta1.kuurs,1)) into lnKulud 	
		FROM palk_kaart inner Join Palk_oper On 	
		(palk_kaart.lepingid = Palk_oper.lepingid And palk_kaart.libId = Palk_oper.libId)
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE Palk_oper.kpv = tdKpv
		AND Palk_oper.rekvid = lnrekv And palk_kaart.tulumaks = 1 
		and palk_kaart.libId In (Select Library.Id From Library inner Join palk_lib On palk_lib.parentId = Library.Id 	
		where palk_lib.liik = 2 Or palk_lib.liik = 7 Or palk_lib.liik = 8 )
		And palk_kaart.lepingid In (SELECT id FROM tooleping WHERE parentid = qryTooleping.parentId AND (id = tnlepingId  
		OR id in (select DISTINCT lepingId FROM palk_kaart WHERE tulumaar = 0)));

raise notice 'lnKulud %',lnKulud;
	else

		SELECT  sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) into lnTulud
		FROM  Palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid 
		inner join Palk_kaart  on (palk_kaart.libid = palk_oper.libid and palk_oper.lepingId = palk_kaart.lepingid) 
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		WHERE Palk_lib.liik = 1   AND Palk_kaart.tulumaks = 1   
		AND Palk_oper.kpv = tdkpv 
		and palk_oper.kpv = tdKpv  
		AND Palk_oper.rekvId = lnrekv and palk_oper.lepingId = tnLepingid;


--		and val(ltrim(rtrim(palk_Lib.algoritm))) = v_palk_kaart.summa ;

raise notice 'lnTulud %',lnTulud;


		SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) into lnKuluD  
		FROM palk_kaart inner join palk_oper on 
		(palk_kaart.lepingid = palk_oper.lepingid and palk_kaart.libid = palk_oper.libid)  
		left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12) 	
		where palk_kaart.lepingId = tnLepingid 
		AND Palk_oper.kpv = tdKpv
		AND Palk_oper.kpv = tdKpv
		AND Palk_oper.rekvId = lnRekv and palk_kaart.tulumaks = 1 
		and palk_kaart.libid in (select library.id from library inner join palk_lib on palk_lib.parentid = library.id 
		where Palk_lib.liik = 2 OR PALK_LIB.LIIK = 7 OR PALK_LIB.LIIK = 8 );
 

--	and tulumaar = v_palk_kaart.summa

	end if;
raise notice 'lnKulud %',lnKulud;
	if lnTulubaas > 0 and qryTooleping.pohikoht > 0 then  
--		raise notice 'lnTulubaas %',lnTulubaas;
		select sum(palk_jaak.g31) into lng31_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = year(tdKpv) 
			and kuu < month(tdKpv);

		lng31 := lng31_2005;

		raise notice 'lng31 %',lng31;
		select count(*) into lnCount_2005 from palk_jaak 
			where lepingId = tnlepingId 
			and aasta = year(tdKpv) 
			and kuu < month(tdKpv)
			and date(aasta,kuu,1) >= qryTooleping.algab;


		raise notice 'lnCount %',lnCount;

		-- should be 1400 * periods
		ng31 := V_palk_config.tulubaas * lnCount_2005 ;
		raise notice 'ng31 %',ng31;

		lnArvJaak := lnTulud - lnKulud;
		if lnArvJaak < lnTulubaas then
			lnTulubaas := lnArvJaak;
			raise notice 'less then vaja %',lnTulubaas;
		else

			if ng31 > lng31_2005 and lnCount_2005 > 0 then
				-- on reserv
				lnTulubaas := lnTulubaas + (ng31 - lng31_2005);
				raise notice 'with reserv  %',lnTulubaas;
			end if;
			raise notice 'with reserv after %',lnTulubaas;
			raise notice 'limited lnArvJaak%',lnArvJaak;
			if lnTulubaas > lnArvJaak then
				lnTulubaas := lnArvJaak;
			end if;
		end if;

	end if;

	lnSumma := v_palk_kaart.summa * 0.01 * (ifnull(lnTuluD,0) - ifnull(lnTulubaas,0) - ifnull(lnkuluD,0)) / lnKuurs;
	lnSumma := case when lnSumma < 0 then 0 else lnSumma end;

-- muudetud 04/01/2005
	IF lnSumma > 0 then
		-- kontrol kas on tulumaks avansimaksetest

		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) inTO lnTulubaas 
			from palk_oper left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
			where lepingId = tnLepingId AND YEAR(kpv) = YEAR(tdKpv) and MONTH(kpv) = MONTH(tdKpv)  AND libId = tnLibId 
			AND palk_oper.MUUD = 'AVANS';
		IF lnTulubaas > 0 then 
			lnSumma := lnSumma - (lnTulubaas / lnKuurs);
		END IF;
	END IF;

	lnSumma = f_round(lnSumma,qryPalkLib.Round);
	raise notice 'lnSumma %',lnSumma;
end if;
Return lnSumma;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_tulumaks(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_tulumaks(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_tulumaks(integer, integer, date) TO dbpeakasutaja;

-- Function: sp_calc_tasu(integer, integer, date)

-- DROP FUNCTION sp_calc_tasu(integer, integer, date);

CREATE OR REPLACE FUNCTION sp_calc_tasu(integer, integer, date)
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
	v_palk_jaak record;
	nSumma numeric (12,4);
	lnKuurs numeric(12,4);
begin

lnsUMMA :=0;
lnKuurs = fnc_currentkuurs(tdKpv);

select palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20)
	where lepingid = tnLepingid and libId = tnLibId;
	
select * INTO qryPalkLib from palk_lib where parentId = tnLibId;


if v_palk_kaart.percent_ = 1 then
	SELECT Palk_jaak.lepingId, Palk_jaak.id, Palk_jaak.kuu, Palk_jaak.aasta,  Palk_jaak.jaak, Palk_jaak.arvestatud, Palk_jaak.kinni,  
	Palk_jaak.TKA, Palk_jaak.tki, Palk_jaak.pm, Palk_jaak.tulumaks, Palk_jaak.sotsmaks, Palk_jaak.muud 
	into v_palk_jaak
	FROM  Palk_jaak WHERE Palk_jaak.lepingId = tnLepingId   AND Palk_jaak.kuu = month(tdKpv)   
	AND Palk_jaak.aasta = year(tdKpv)  
	ORDER by kuu desc, aasta desc 
	limit 1;

	lnSumma := f_round(v_palk_kaart.summa * 0.01 * v_palk_jaak.jaak * v_palk_kaart.kuurs / lnKuurs, qryPalkLib.round);


else

	lnSumma := f_round(v_palk_kaart.summa * v_palk_kaart.kuurs / lnKuurs, qryPalkLib.round);

end if;


Return lnSumma;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_tasu(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_tasu(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_tasu(integer, integer, date) TO dbpeakasutaja;


-- Function: sp_calc_sots(integer, integer, date)

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
begin
lnBaas :=0;
lnsUMMA :=0;
lnKuurs = fnc_currentkuurs(tdKpv);


select palk_kaart.summa, palk_kaart.percent_, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (dokvaluuta1.dokid = palk_kaart.id and dokvaluuta1.dokliik = 20)
	where lepingid = tnLepingid and libId = tnLibId;
	
select parentid, round INTO qryPalkLib from palk_lib where parentId = tnLibId;

If v_palk_kaart.percent_ = 1 then

	select pohikoht into qryTooleping from tooleping where id = tnlepingId;
	select rekvId into lnrekv from library where id = qryPalkLib.parentId;
	select minpalk into v_palk_config from palk_config where rekvid = lnrekv;

	SELECT sum(Palk_oper.summa * ifnull(dokvaluuta1.kuurs,1)) INTO lnBaas 
	FROM palk_oper inner join Palk_lib on palk_lib.parentid = palk_oper.libid 
	left outer join dokvaluuta1 on (dokvaluuta1.dokid = palk_oper.id and dokvaluuta1.dokliik = 12) 
	WHERE  Palk_oper.kpv = tdKpv      
	AND Palk_lib.liik = 1 and palk_oper.lepingId = tnLepingId and palk_lib.sots = 1;

	lnMinPalk := case when qryTooleping.pohikoht > 0 then v_palk_config.minpalk else 0 end;
	lnSumma := f_round(v_palk_kaart.summa * 0.01 * lnBaas / lnKuurs,qryPalkLib.round);
else
	lnSumma := f_round(v_palk_kaart.Summa * v_palk_kaart.kuurs / lnKuurs, qryPalkLib.round);
end if;

Return lnSumma;

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_sots(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_sots(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_sots(integer, integer, date) TO dbpeakasutaja;


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

select * into v_palk_config from palk_config where rekvid = qryTooleping.rekvid;
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
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO dbpeakasutaja;

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

select * into v_palk_config from palk_config where rekvid = qryTooleping.rekvid;
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
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_muuda(integer, integer, date) TO dbpeakasutaja;

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
			and palk_lib.tululiik <> '13'
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
GRANT EXECUTE ON FUNCTION sp_calc_kinni(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_kinni(integer, integer, date) TO dbpeakasutaja;


-- Function: sp_calc_arv(integer, integer, date)

-- DROP FUNCTION sp_calc_arv(integer, integer, date);

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

begin

nHours :=0;
lnSumma := 0;
nPalk:=0;
lnBaas :=0;
lnKuurs =  fnc_currentkuurs(tdKpv);

select palk_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs  into v_palk_kaart 
	from palk_kaart left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20) 
	where lepingid = tnLepingid and libId = tnLibId;

select * INTO qryPalkLib from palk_lib where parentId = tnLibId;

--raise notice 'Percent %',v_palk_kaart.percent_;

If v_palk_kaart.percent_ = 1 then
	-- calc based on taabel 
	raise notice 'calc based on taabel';
	If v_palk_kaart.alimentid = 0 then
		--raise notice 'alimentid = 0';		
		select tooleping.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into qryTooleping 
			from tooleping left outer join dokvaluuta1 on (tooleping.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 19) 
			where tooleping.id = tnLepingId; 

		select * into qryTaabel1 from palk_taabel1 where toolepingId = tnlepingId 
			and kuu = month(tdKpv) and aasta = year (tdKpv);

		if not found then
			--raise notice 'TAABEL1 NOT FOUND';
			return lnSumma;
		end if;

	SELECT tund into nHours FROM Toograf WHERE lepingid = tnLepingId AND kuu = month(tdKpv) AND aasta = year(tdKpv);
	IF ifnull(nHours,0) = 0 then
		nHours := (sp_workdays(1, month(tdKpv), year(tdKpv), 31,v_palk_kaart.lepingId)::numeric(6,4) * qryTooleping.toopaev )::INT4;
		nHours := nHours - sp_calc_tahtpaevad(qryTooleping.rekvId, month(tdKpv));
	END IF;

		--raise notice 'hOUR %',nHours;
		if qryTooleping.tasuliik = 1 then
			lnRate := (qryTooleping.palk * qryTooleping.kuurs)/ nHours * 0.01 * qryTooleping.koormus ;
			--raise notice 'Rate %',lnrate;
		end if;

		if qryTooleping.tasuliik = 2 then
			lnSumma := f_round((qryTooleping.palk * qryTooleping.kuurs) * qryTaabel1.kokku / lnKuurs,qryPalkLib.round);
			lnRate := qryTooleping.palk * qryTooleping.kuurs;
			
			-- muudetud 01/02/2005
			if qryPalkLib.tund = 5 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev  / lnKuurs,qryPalkLib.round);
			end if;
			If  qryPalkLib.tund = 6 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev  / lnKuurs,qryPalkLib.round);
			End if;
			If  qryPalkLib.tund = 7 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo / lnKuurs,qryPalkLib.round);
			End if;
			if qryPalkLib.tund =3 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.ohtu / lnKuurs,qryPalkLib.round);
			end if;
			if qryPalkLib.tund =4 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.oo / lnKuurs,qryPalkLib.round);
			end if;
			if qryPalkLib.tund =2 then
				lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.paev / lnKuurs,qryPalkLib.round);
			end if;

			return lnSumma;

		end if;

		If  qryPalkLib.tund = 5 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev / lnKuurs,qryPalkLib.round);

			lnBaas := qryTaabel1.tahtpaev;

		End if;

		If  qryPalkLib.tund = 6 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev / lnKuurs,qryPalkLib.round);

			lnBaas := qryTaabel1.puhapaev;

		End if;

		If  qryPalkLib.tund = 7 then

			lnSumma := f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.uleajatoo / lnKuurs,qryPalkLib.round);

			lnBaas := qryTaabel1.uleajatoo;

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

--			raise notice 'nSumma %',nSumma;


--			raise notice 'lnSumma %',lnSumma;


			lnSumma := lnSumma + f_round( nSumma / lnKuurs, qryPalkLib.round);


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

	lnBaas := 0;

End if;



Return lnSumma;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_arv(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_arv(integer, integer, date) TO dbpeakasutaja;

-- Function: sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying)

-- DROP FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying)
  RETURNS character varying AS
$BODY$
DECLARE 
	tnrekvid alias for $1;
	tdKpv1 alias for $2;
	tdKpv2 alias for $3;
	tcKonto alias for $4;
	tcGrupp alias for $5;
	tcVastIsik alias for $6;


	lcReturn varchar;
	lcString varchar;

	LNcOUNT int;
	lnSumma numeric(12,4);
	lnSoetmaks numeric(12,4);
	lnAlgKulum numeric(12,4);
	lnKulum numeric(12,4);
	lnParandus numeric(12,4);
	lnMaha numeric(12,4);
	v_pvkaart record;

	ldAlgkpv date;
	lMaha int;

begin

	

	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_PV_ARUANNE1';



	if ifnull(lnCount,0) < 1 then



	raise notice ' lisamine  ';

	

		create table tmp_pv_aruanne1 (id int, kood varchar(20), nimetus varchar(254), konto varchar(20), grupp varchar(254),
			soetkpv date, 
			soetmaks numeric(14,2), algkulum numeric(14,2), kulum numeric(14,2), kulukokku numeric(14,2),
			jaak numeric(14,2), parandus numeric(14,2), mahakantud numeric(14,2), 
			timestamp varchar(20), kpv date default date(), rekvid int, vastisik varchar(254), muud varchar(254))  ;

		

		GRANT ALL ON TABLE tmp_pv_aruanne1 TO GROUP public;



	else
		delete from tmp_pv_aruanne1 where kpv < date() and rekvid = tnrekvId;

	end if;


	lcreturn := to_char(now(), 'YYYYMMDDMISSSS');


	-- pv list 

	for v_pvkaart in 

	select curPohivara.id, curPohivara.kood, curPohivara.nimetus, curPohivara.konto, curPohivara.grupp, 
		curPohivara.soetkpv, curPohivara.soetmaks * curPohivara.kuurs as soetmaks, curpohivara.algkulum * curPohivara.kuurs as algkulum, 
		curpohivara.TUNNUS, curPohivara.vastisik, curPohivara.rentnik as muud
		from curPohivara 
		where rekvid = tnRekvId 
		and upper(curPohivara.konto) like upper(tcKonto)
		and upper(curPohivara.grupp) like upper(tcGrupp)
		and upper(curPohivara.vastisik) like upper(tcvastisik)
		and curpohivara.kulum > 0
		order by curPohivara.grupp, curPohivara.kood, curPohivara.konto

	loop
		lMaha = 0;
		if v_pvkaart.tunnus = 0 then
			-- mahakantud
			select kpv into ldAlgkpv from pv_oper 
				where parentid = v_pvkaart.id and liik = 4 order by kpv desc limit 1;
			if ldAlgkpv < tdKpv1 then
				lMaha = 1;
			end if;
		end if;

		if lMaha = 0 then

		insert into tmp_pv_aruanne1 (id, rekvid, timestamp, kood , nimetus, konto , grupp , soetkpv, vastisik, muud) 
			values (v_pvkaart.id, tnrekvId, lcreturn, v_pvkaart.kood , v_pvkaart.nimetus, v_pvkaart.konto , v_pvkaart.grupp , v_pvkaart.soetkpv, v_pvkaart.vastisik, v_pvkaart.muud);

		select summa * ifnull(dokvaluuta1.kuurs,1), kpv into lnSumma, ldAlgkpv 
			from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where parentid = v_pvkaart.id and liik = 5 order by kpv desc limit 1;
		if ifnull(lnSumma,0) = 0 then
			lnSoetmaks := v_pvkaart.soetmaks;
			ldAlgkpv := v_pvkaart.soetkpv;
		else
			lnSoetmaks := lnSumma;
		end if;
		if tdKpv2 < ldAlgkpv then
			lnSoetmaks := v_pvkaart.soetmaks;
			ldAlgkpv := v_pvkaart.soetkpv;
		end if;

		-- kulum
		-- algkulum
		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where liik = 2 and parentId = v_pvkaart.id and kpv > ldAlgkpv  and kpv < tdKpv1;

		lnAlgkulum = ifnull(lnSumma,0);
		if ldAlgkpv = v_pvkaart.soetkpv then
			-- puudu umberhindlus
			lnAlgkulum = lnAlgKulum + v_pvkaart.algkulum;
		end if;
		-- kulum
		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where liik = 2 and parentId = v_pvkaart.id 
			and kpv > ldAlgkpv  and kpv >= tdKpv1 and kpv <= tdKpv2;
		lnKulum := ifnull(lnSumma,0);
/*
		-- Kulumi mahakandmine, kui pv oli mahakantud
		-- kas see pv_kaart oli mahakantud

		if (select count(id) from pv_oper where liik = 4 
			and parentId = v_pvkaart.id and kpv > ldAlgkpv  and kpv >= tdKpv1 and kpv <= tdKpv2) > 0 then
			-- kui see kart oli mahakantud, siis kgu kulum oli ka mahakantud

		end if;
*/

		-- parandus
		-- algparandus
		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where liik = 3 and parentId = v_pvkaart.id and kpv > ldAlgkpv  and kpv < tdKpv1;
		lnSoetmaks := lnSoetmaks + ifnull(lnSumma,0);
		-- parandus
		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where liik = 3 and parentId = v_pvkaart.id and kpv > ldAlgkpv  and kpv >= tdKpv1 and kpv <= tdKpv2;
		lnParandus := ifnull(lnSumma,0);

	
		-- maha
		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where liik = 4 and parentId = v_pvkaart.id and kpv > ldAlgkpv  and kpv >= tdKpv1 and kpv <= tdKpv2;
		lnMaha := ifnull(lnSumma,0);


		

		update tmp_pv_aruanne1 set soetmaks = lnSoetmaks, 
			algkulum = lnAlgKulum, 
			kulum = lnKulum, 
			kulukokku = lnAlgKulum + lnKulum,
			parandus = lnParandus,
			mahakantud = lnMaha,
			jaak = lnSoetmaks + lnParandus - lnAlgKulum -lnKulum
			where id = v_pvkaart.id and timestamp = LCRETURN;

		end if;

	end loop;



	return LCRETURN;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying) TO dbvaatleja;

-- View: curkulum

-- DROP VIEW curkulum;

CREATE OR REPLACE VIEW curkulum AS 
 SELECT library.id, pv_oper.liik, (pv_oper.summa * IFNULL(dokvaluuta1.kuurs,1))::numeric(12,4) as summa, pv_oper.kpv, library.rekvid, grupp.nimetus AS grupp, nomenklatuur.kood, 
	nomenklatuur.nimetus AS opernimi, pv_kaart.soetmaks, pv_kaart.soetkpv, pv_kaart.kulum, pv_kaart.algkulum, pv_kaart.gruppid, 
	pv_kaart.konto, pv_kaart.tunnus, ifnull(asutus.nimetus, space(254)) AS vastisik, library.kood AS ivnum, library.kood AS invnum, 
	library.nimetus AS pohivara
   FROM library
   JOIN pv_oper ON library.id = pv_oper.parentid
   JOIN pv_kaart ON library.id = pv_kaart.parentid
   JOIN library grupp ON pv_kaart.gruppid = grupp.id
   LEFT JOIN asutus ON pv_kaart.vastisikid = asutus.id
   left outer join dokvaluuta1 on (pv_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 13)
   JOIN nomenklatuur ON pv_oper.nomid = nomenklatuur.id;

ALTER TABLE curkulum OWNER TO vlad;
GRANT ALL ON TABLE curkulum TO vlad;
GRANT SELECT ON TABLE curkulum TO dbpeakasutaja;
GRANT SELECT ON TABLE curkulum TO dbkasutaja;
GRANT SELECT ON TABLE curkulum TO dbadmin;
GRANT SELECT ON TABLE curkulum TO dbvaatleja;


-- Function: sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric)
/*

select * from curPohivara order by id desc limit 3

select * from dokvaluuta1 where dokliik in (13,18) order by id desc limit 5

*/
-- DROP FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric);

CREATE OR REPLACE FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnnomid alias for $3;
	tndoklausid alias for $4;
	tnliik alias for $5;
	tdkpv alias for $6;
	tnsumma alias for $7;
	ttmuud alias for $8;
	tckood1 alias for $9;
	tckood2 alias for $10;
	tckood3 alias for $11;
	tckood4 alias for $12;
	tckood5 alias for $13;
	tckonto alias for $14;
	tctp alias for $15;
	tnasutusid alias for $16;
	tctunnus alias for $17;
	tcProj alias for $18;
	tcValuuta alias for $19;
	tnKuurs alias for $20;
	lnpv_operId int;
	lnId int; 
	lnSumma numeric(12,2);
	v_pv_kaart record;
	lrCurRec record;
	lnPvElu numeric(6,2);
	lnKulum numeric(12,2);

	lnSoetSumma numeric (12,4);
	lnParandatudSumma numeric (12,4);
	lnUmberhindatudSumma numeric (12,4);
	
	lnDokKuurs numeric(14,4);
	lcString varchar;
	v_dokvaluuta record;
	ldKpv date;


begin

if tnId = 0 then
	-- uus kiri
	insert into pv_oper (parentid,nomid,doklausid,liik,kpv,summa,muud,kood1,kood2,kood3,kood4,kood5,konto,tp,asutusid,tunnus, proj) 
		values (tnparentid,tnnomid,tndoklausid,tnliik,tdkpv,tnsumma,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tckonto,tctp,tnasutusid,tctunnus, tcProj);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnpv_operId:= cast(CURRVAL('public.pv_oper_id_seq') as int4);
	else
		lnpv_operId = 0;
	end if;

	if lnpv_operId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

			-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lnpv_operId,13,tcValuuta, tnKuurs);



else
	-- muuda 
	select * into lrCurRec from pv_oper where id = tnId;
	if  lrCurRec.nomid <> tnnomid or lrCurRec.doklausid <> tndoklausid or lrCurRec.liik <> tnliik or lrCurRec.kpv <> tdkpv 
		or lrCurRec.summa <> tnsumma or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.kood1 <> tckood1 
		or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 
		or lrCurRec.konto <> tckonto or lrCurRec.tp <> tctp or lrCurRec.asutusid <> tnasutusid or lrCurRec.tunnus <> tctunnus then 

	update pv_oper set 
		nomid = tnnomid,
		doklausid = tndoklausid,
		liik = tnliik,
		kpv = tdkpv,
		summa = tnsumma,
		muud = ttmuud,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		konto = tckonto,
		tp = tctp,
		asutusid = tnasutusid,
		proj = tcProj,
		tunnus = tctunnus
	where id = tnId;
	end if;

	lnpv_operId := tnId;
end if;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 13 and dokid =lnpv_operId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (13, lnpv_operId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 13 and dokid = lnpv_operId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;

						
		end if;
	
	end if;


	if tnLiik = 1 then
-- 
		Select id into lnId from pv_kaart where parentid = tnParentId;
		lnId = ifnull(lnId,0);
		if lnId > 0 then
			if (select count(id) from dokvaluuta1 where dokliik = 18 and dokid = lnId) = 0 then
	
				insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
					values (lnId,18,tcValuuta, tnKuurs);
			else
	
				update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where dokid = lnId and dokliik = 18;

			end if;
		end if;
		update pv_kaart set soetmaks = tnSumma where id = lnId;


	end if;


	select soetmaks, parhind, algkulum, kulum, soetkpv, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_pv_kaart 
		from pv_kaart left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_kaart.id and dokliik = 18) where parentId = tnparentid;

	lnKulum := v_pv_kaart.kulum;
	ldKpv := v_pv_kaart.soetkpv;

	-- PARANDAME PARANDATUD SUMMA.

--	lnSumma = get_pv_summa(tnparentid);
/*
	if tnLiik = 5 then
		ldKpv := tdKpv;
		lnUmberhindatudSumma := tnSumma*tnKuurs;

		-- parandame pv kulum
		raise notice 'v_pv_kaart.kulum %',v_pv_kaart.kulum;

		lnPvElu := (100 / v_pv_kaart.kulum);
		raise notice 'lnPvElu %',lnPvElu;
		lnPvElu := lnPvElu - (year(tdkpv) - year(v_pv_kaart.soetkpv));
		lnKulum := 100 / lnPvElu;
		raise notice 'lnPvElu %',lnPvElu;
		raise notice 'lnKulum %',lnKulum;

		lcString = 'update pv_kaart set kulum = ' + lnKulum::varchar; 

	else
		select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnUmberhindatudSumma 
			from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where pv_oper.parentId = tnparentid and liik = 5;

		lnUmberhindatudSumma := ifnull(lnUmberhindatudSumma,0);
		if lnUmberhindatudSumma > 0 then
			select kpv into ldKpv from pv_oper where liik = 5 and parentId = tnParentId order by kpv desc limit 1;
		else
			lnUmberhindatudSumma := v_pv_kaart.soetmaks;
		end if;
	end if;



	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnSoetSumma 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnparentid and liik = 1;

	lnSoetSumma  = ifnull(lnSoetSumma ,v_pv_kaart.soetmaks);

	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnParandatudSumma 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnparentid and liik = 3 and kpv > ldKpv;


	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnKulum 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnparentid and liik = 2;

	lnParandatudSumma := ifnull(lnParandatudSumma,0) + ifnull(lnUmberhindatudSumma,v_pv_kaart.soetmaks);
		raise notice 'lnParandatudSumma %',lnParandatudSumma;

	-- otsime dok.valuuta
	Select id into lnId from pv_kaart where parentid = tnParentId;
	
	select kuurs into lnDokKuurs from dokvaluuta1 where dokid = lnId and dokliik = 18;
	lnDokKuurs = ifnull(lnDokKuurs,1);
		
	lnParandatudSumma = lnParandatudSumma / lnDokKuurs;
		raise notice 'lnParandatudSumma dokvaluutas %',lnParandatudSumma;

--	if v_pv_kaart.parhind <> lnParandatudSumma then

	lnKulum = (ifnull(lnKulum,0) + v_pv_kaart.algkulum * v_pv_kaart.kuurs) / lnDokKuurs;

	update pv_kaart set parhind = lnParandatudSumma, jaak = lnParandatudSumma - lnKulum where parentId = tnparentid;
*/
	perform sp_update_pv_jaak(tnParentId);


         return  lnpv_operId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric) TO dbpeakasutaja;

-- Function: sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date)

-- DROP FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date);

CREATE OR REPLACE FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnallikasid alias for $3;
	tnaasta alias for $4;
	tnsumma alias for $5;
	ttmuud alias for $6;
	tntunnus alias for $7;
	tntunnusid alias for $8;
	tckood1 alias for $9;
	tckood2 alias for $10;
	tckood3 alias for $11;
	tckood4 alias for $12;
	tckood5 alias for $13;
	tnkuu alias for $14;
	tdkpv alias for $15;
	tcValuuta alias for $16;
	tnKuurs alias for $17;
	lneelarveId int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
	
begin

if tnId = 0 then
	-- uus kiri
	insert into eelarve (rekvid,allikasid,aasta,summa,muud,tunnus,tunnusid,kood1,kood2,kood3,kood4,kood5,kuu,kpv) 
		values (tnrekvid,tnallikasid,tnaasta,tnsumma,ttmuud,tntunnus,tntunnusid,tckood1,tckood2,tckood3,tckood4,tckood5,tnkuu,tdkpv);

	GET DIAGNOSTICS lnId = ROW_COUNT;


	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lneelarveId:= cast(CURRVAL('public.eelarve_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lneelarveId = 0;
	end if;

	if lneelarveId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

		-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lneelarveId,8,tcValuuta, tnKuurs);




else
	-- muuda 
	select * into lrCurRec from eelarve where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or lrCurRec.allikasid <> tnallikasid or lrCurRec.aasta <> tnaasta or lrCurRec.summa <> tnsumma or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.tunnus <> tntunnus or lrCurRec.tunnusid <> tntunnusid or lrCurRec.kood1 <> tckood1 or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 or ifnull(lrCurRec.kuu,0) <> ifnull(tnkuu,0) or ifnull(lrCurRec.kpv,date(1900,01,01)) <> ifnull(tdkpv,date(1900,01,01)) then 
	update eelarve set 
		rekvid = tnrekvid,
		allikasid = tnallikasid,
		aasta = tnaasta,
		summa = tnsumma,
		muud = ttmuud,
		tunnus = tntunnus,
		tunnusid = tntunnusid,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		kuu = tnkuu,
		kpv = tdkpv
	where id = tnId;
	end if;
	lneelarveId := tnId;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 8 and dokid = lneelarveId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (8, lneelarveId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 8 and dokid = lneelarveId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;

						
		end if;
	
	end if;



end if;




         return  lneelarveId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_eelarve(integer, integer, integer, integer, numeric, text, integer, integer, character varying, character varying, character varying, character varying, character varying, integer, date, character varying, numeric) TO dbpeakasutaja;


-- Function: sp_saldoandmik_report(integer, date, integer, integer, integer)

-- DROP FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE tnrekvid alias for $1;
	tdKpv alias for $2;
	tnTyyp alias for $3;
	tnSvod alias for $4;
	tnVar alias for $5;
	lcReturn varchar;
	lcString varchar;
	lcPnimi varchar;

	lnreturn int;
	LNcOUNT int;
	lnTun int;

	lnDeebet numeric(12,2);
	lnKreedit numeric(12,2);
	lcTp varchar(20);
	lcAllikas varchar(20);
	lcTegev varchar(20);
	lcRahavoog varchar(20);
	lcEelarve varchar(20);
	lcKonto varchar(20);
	lcKontoNimi varchar(254);

	lcKulumKontoString varchar(254);
	v_saldo record;
	v_library record;
	lcReturn1 varchar;
	
	
	lnTase int;

	lcMeetmekood varchar(20);
begin

lnreturn = 0;


if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMP_SALDOANDMIK')  < 1 then
	
	create table tmp_saldoandmik (id serial NOT NULL, nimetus varchar(254) not null default space(1), db numeric(12,2) not null default 0, kr numeric(12,2) not null default 0, konto varchar(20) not null default space(1), 		
		tegev varchar(20) not null default space(1), tp varchar(20) not null default space(1), allikas varchar(20) not null default space(1), 			
		rahavoo varchar(20) not null default space(1), 
		timestamp varchar(20) not null , kpv date default date(), rekvid int, tyyp int default 0 not null )  ;
		
		GRANT ALL ON TABLE tmp_saldoandmik TO GROUP public;
		GRANT ALL ON TABLE tmp_saldoandmik_id_seq TO public;

else
	delete from tmp_saldoandmik where kpv < date() and rekvid = tnrekvId;
end if;

lcreturn := ltrim(rtrim(str(tnrekvId)))+to_char(now(), 'YYYYMMDDMISSSS');

/*
if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMPREKV')  > 0 then
	delete from tmpRekv;
--	truncate TABLE tmpRekv;
	insert into tmpRekv
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv where parentid <> 9999;
else
	CREATE TABLE tmpRekv AS
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv where parentid <> 9999;
		GRANT ALL ON TABLE tmpRekv TO GROUP public;

END IF;

if tnSvod = 1 then
	delete from tmpRekv where tase < 3;

else
	delete from tmpRekv where tase in (0,1,2,4);
end if;
*/

if tnSvod = 1 then
	lnTase = 3;

else
	lnTase = 9;
end if;

lcKonto = '';

for v_saldo in 
	SELECT  journal1.deebet AS konto, journal1.lisa_d as tp, 
		journal1.kood2 as allikas, journal1.kood1 as tegev, journal1.kood3 as rahavoo, journal1.kood5 as eelarve,
		sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1)) AS dB, 0::numeric(12,4) AS kr 
		FROM journal inner join journal1 on journal.id = journal1.parentid 
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where year(Journal.kpv) < year(tdKpv) 
		and journal1.summa <> 0
		and (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
		group by journal1.deebet, journal1.lisa_d, journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood5
	UNION ALL 
		SELECT  journal1.kreedit AS konto, journal1.lisa_k as tp,
		journal1.kood2 as allikas,journal1.kood1 as tegev, journal1.kood3 as rahavoo, journal1.kood5 as eelarve,
		0::numeric(12,4) as dB, sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1)) AS kr
		FROM journal inner join journal1 on journal.id = journal1.parentid 
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where year(Journal.kpv) < year(tdKpv)
		and journal1.summa <> 0
		and (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
		group by journal1.kreedit, journal1.lisa_k,journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood5

loop

	lnDeebet = 0;
	lnKreedit = 0;
/*
	if lcKonto <> '' then
		if ltrim(rtrim(v_saldo.konto)) <> lcKonto then
			lcKonto = ltrim(rtrim(v_library.kood));
		end if;
	end if;
*/

			select * into v_library from library where ltrim(rtrim(kood)) = ltrim(rtrim(v_saldo.konto)) and ltrim(rtrim(library)) = 'KONTOD' order by id desc limit 1; 


	-- tp
	if empty (v_library.tun1) then 
		v_saldo.tp = '';
	end if;
	if ((left(ltrim(rtrim(v_saldo.konto)),3) = '154' or left(ltrim(rtrim(v_saldo.konto)),3) = '155' or left(ltrim(rtrim(v_saldo.konto)),3) = '156'))  then 
		v_saldo.tp = '';
	end if;

	--tegev
	if empty (v_library.tun2) or ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo <> '01') then 
		v_saldo.tegev = '';
	end if;
	-- allikas
	if empty (v_library.tun3) or isdigit(v_saldo.allikas) = 0 then 
		v_saldo.allikas = '';
	end if;
	-- rahavoo
	if empty (v_library.tun4) then 
		v_saldo.rahavoo = '';
	else
		v_saldo.rahavoo = '00';
	end if;
	if v_library.tun5 = 1 or v_library.tun5 = 3 then
		lnDeebet = v_saldo.db - v_saldo.kr;
	else
		lnKreedit = v_saldo.kr - v_saldo.db;
	end if;
	lnDeebet = ifnull(lnDeebet,0);
	lnKreedit = ifnull(lnKreedit,0);
/*
	if alltrim(v_saldo.konto) = '201000' and v_saldo.tp = '014601' then
		raise notice ' lnDeebet %',lnDeebet;
		raise notice ' lnKreedit %',lnKreedit;
	end if;
*/
	INSERT INTO tmp_saldoandmik ( konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) values 
		( alltrim(v_saldo.konto), alltrim(v_saldo.tp), alltrim(v_saldo.tegev), alltrim(v_saldo.allikas), alltrim(v_saldo.rahavoo), lnDeebet, lnKreedit,
		tnRekvId, lcReturn, alltrim(v_library.nimetus), 20 );
end loop;


/*
if (select count(*) from tmp_saldoandmik where konto like '103000' and tp = '185101' and timestamp = lcReturn) > 0 then
	raise notice '1 found';
end if; 
*/
-- update pv konto

update tmp_saldoandmik set tp = '' where not empty (tp) and ltrim(rtrim(rahavoo)) = '00' and left(ltrim(rtrim(konto)),3) in ('154','155','156') and ltrim(rtrim(timestamp)) = lcreturn and rekvid = tnRekvId;


-- pohi osa (kaibed)

for v_saldo in 
	SELECT library.tun1,library.tun2, library.tun3, library.tun4,library.tun5, konto,  tp, tegev, allikas, rahavoo, 
			case when (library.tun5=1 or library.tun5 = 3) then
			(sum(deebet) - sum (kreedit) ) else 0 end as db, 
		case when (library.tun5=2 or library.tun5 = 4) then 
			(sum (kreedit) - sum(deebet)) else 0 end as kr, 
		tnRekvId as rekvid, lcReturn as timestamp, library.nimetus, 5 as tyyp
	from 
	(
	SELECT journal1.deebet As konto, journal1.lisa_d As tp, journal1.kood1 As tegev, journal1.kood2 As allikas, journal1.kood3 As rahavoo, 
		sum(journal1.Summa* ifnull(dokvaluuta1.kuurs,1)) As deebet, 0 As kreedit  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where journal.kpv <= tdKpv
		and year(kpv) = year(tdKpv)
		and journal1.summa <> 0
		and (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
		group by journal1.deebet, journal1.lisa_d, journal1.kood1, journal1.kood2, journal1.kood3 
		
	) qrySaldoaruanne inner join library on (ltrim(rtrim(library.kood)) =  ltrim(rtrim(qrySaldoaruanne.konto)) and ltrim(rtrim(library.library)) = 'KONTOD') 
	group BY konto, tp, tegev, allikas, rahavoo, library.tun1, library.tun2, library.tun3, library.tun4, library.tun5, library.nimetus  
	ORDER BY konto, tp, tegev, allikas, rahavoo

loop
	-- tp
	if empty (v_saldo.tun1) then 
		v_saldo.tp = '';
	end if;
	if ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo = '16') and v_saldo.rahavoo <> '01' then 
		v_saldo.tp = '';
	end if;

	--tegev
	if empty (v_saldo.tun2) or ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo <> '01') then 
		v_saldo.tegev = '';
	end if;
	-- allikas
	if empty (v_saldo.tun3) or isdigit(v_saldo.allikas) = 0 then 
		v_saldo.allikas = '';
	end if;
	-- rahavoo
	if empty (v_saldo.tun4) then 
		v_saldo.rahavoo = '';
	end if;
	/*
	if alltrim(v_saldo.konto) = '201000' and v_saldo.tp = '014601' then
		raise notice 'v_saldo.db %',v_saldo.db;
		raise notice ' v_saldo.kr %',v_saldo.kr;
	end if;
*/


	INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) values 
		(alltrim(v_saldo.konto), alltrim(v_saldo.tp), alltrim(v_saldo.tegev), alltrim(v_saldo.allikas), alltrim(v_saldo.rahavoo), v_saldo.db, v_saldo.kr, v_saldo.rekvid, v_saldo.timestamp, alltrim(v_saldo.nimetus), v_saldo.tyyp );
	
end loop;
/*
if (select count(*) from tmp_saldoandmik where konto = '103000' and tp = '185101' and timestamp = lcReturn) > 0 then
	raise notice '2 found';
end if; 

*/
for v_saldo in
SELECT konto, library.tun1, library.tun2, library.tun3, library.tun4, library.tun5,tp, tegev, allikas, rahavoo, 
	case when (library.tun5=1 or library.tun5 = 3) then
			(sum(deebet) - sum (kreedit) ) else 0 end as db, 
	case when (library.tun5=2 or library.tun5 = 4) then 
			(sum (kreedit) - sum(deebet)) else 0 end as kr, 
	tnRekvId as rekvid , lcReturn as timestamp, library.nimetus, 5 as tyyp
from 
(
	SELECT journal1.kreedit As konto, journal1.lisa_k As tp, journal1.kood1 As tegev, journal1.kood2 As allikas, journal1.kood3 As rahavoo, 
		0 As deebet, sum(journal1.Summa * ifnull(dokvaluuta1.kuurs,1)) As kreedit  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where journal.kpv <= tdKpv 
		and year(kpv) = year(tdKpv)
		and journal1.summa <> 0
		and (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
		group by journal1.kreedit, journal1.lisa_k, journal1.kood1, journal1.kood2, journal1.kood3 

) qrySaldoaruanne inner join library on (ltrim(rtrim(library.kood)) =  ltrim(rtrim(qrySaldoaruanne.konto)) and ltrim(rtrim(library.library)) = 'KONTOD') 
group BY konto, tp, tegev, allikas, rahavoo, library.tun1, library.tun2, library.tun3, library.tun4, library.tun5, library.nimetus  
ORDER BY konto, tp, tegev, allikas, rahavoo

loop
	-- tp
	if empty (v_saldo.tun1) then 
		v_saldo.tp = '';
	end if;
	if ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo = '16') then 
		v_saldo.tp = '';
	end if;

	--tegev
	if empty (v_saldo.tun2) or ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo <> '01') then 
		v_saldo.tegev = '';
	end if;
	-- allikas
	if empty (v_saldo.tun3) or isdigit(v_saldo.allikas) = 0 then 
		v_saldo.allikas = '';
	end if;
	-- rahavoo
	if empty (v_saldo.tun4) then 
		v_saldo.rahavoo = '';
	end if;


	INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) values 
		(alltrim(v_saldo.konto), alltrim(v_saldo.tp), alltrim(v_saldo.tegev), alltrim(v_saldo.allikas), alltrim(v_saldo.rahavoo), v_saldo.db, v_saldo.kr, v_saldo.rekvid, v_saldo.timestamp, alltrim(v_saldo.nimetus), v_saldo.tyyp );
	
end loop;
/*
if (select count(*) from tmp_saldoandmik where konto = '103000' and tp = '185101' and timestamp = lcReturn) > 0 then
	raise notice '3 found';
end if; 
*/
/*
INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) 
SELECT konto, ltrim(rtrim(tp)), ltrim(rtrim(tegev)), ltrim(rtrim(allikas)), ltrim(rtrim(rahavoo)), db, kr, rekvid, lcreturn, nimetus, 6
from tmp_saldoandmik
where timestamp = lcReturn;
*/

INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) 
SELECT left(konto,6) as konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, 70
from tmp_saldoandmik
where ltrim(rtrim(timestamp)) = lcReturn
order by timestamp, REKVID, left(konto,6), tp, tegev, allikas, rahavoo, nimetus;


INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) 
SELECT konto, tp, tegev, allikas, rahavoo, sum(db), sum(kr), rekvid, timestamp, nimetus, 7
from tmp_saldoandmik
where ltrim(rtrim(timestamp)) = lcReturn
and tyyp = 70
group by timestamp, REKVID, konto, tp, tegev, allikas, rahavoo, nimetus
order by timestamp, REKVID, konto, tp, tegev, allikas, rahavoo, nimetus;


--and tyyp = 6

raise notice 'kaibed 5  lopp';

DELETE FROM tmp_saldoandmik WHERE timestamp = lcReturn and rekvid = tnRekvId and tyyp <> 7;

DELETE FROM tmp_saldoandmik WHERE  (ltrim(rtrim(konto)) in ('999999','000000','888888') or (db = 0 and kr= 0)) and rekvid = tnRekvId;


return LCRETURN;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer) TO dbpeakasutaja;
