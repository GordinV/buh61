-- Function: fncarvestaviivis1(integer, integer, numeric, date, integer)

-- DROP FUNCTION fncarvestaviivis1(integer, integer, numeric, date, integer);

CREATE OR REPLACE FUNCTION fncarvestaviivis1(integer, integer, numeric, date, integer)
  RETURNS character varying AS
$BODY$


declare 
	tnId ALIAS FOR $1;
	tnLiik ALIAS FOR $2;
	tnViiviseMaar ALIAS FOR $3;
	tdKpv ALIAS FOR $4;
	tnRekvId ALIAS FOR $5;

	lnPaevad integer;
	qryArved record;
	v_tasud record;
	lcTimestamp varchar(20);
	liKirjad integer;
	
	lcViivis varchar;
	v_viivis record;
	v_arv record;
	lnAlgsaldo numeric;
	lnSumma numeric;
	lnViivis numeric;
	lnViivisK numeric;
	lnVolg numeric;
	lcString varchar;

	lnAsutusId integer;
	ldKpv date;
	lcKpv varchar;
	lnRekvId integer;
	lcObjekt varchar(20);
	lnViiviseIntress numeric(12,4);
	lnArveId1 integer;
	lnArveId2 integer;
	lnKuurs numeric(12,4);

BEGIN
	lnArveId1 = 0;
	lnArveId2 = 999999999;


	lcTimestamp = to_char(now(), 'YYYYMMDDMISSSS')::varchar;
	lnViiviseIntress = ifnull(tnViiviseMaar,0.01);
	lnAlgsaldo = 0;
	lnKuurs = fnc_currentkuurs(tdKpv);
	if tnLiik = 1 then
		--arve
		select asutusId, kpv, rekvid, objekt into v_arv from arv where id = tnId;
		lnAsutusId = v_arv.asutusId;
		ldKpv = v_arv.kpv;
		lnRekvId = v_arv.rekvId;
		lcObjekt = ifnull(v_arv.objekt,'');
		lnArveId1 =  tnId;
		lnArveId2 =  tnId;

	end if;
	if tnLiik = 2 then
		-- leping
		select leping1.asutusId, leping1.rekvId, objekt.kood as objekt into v_arv 
			from leping1 left outer join library objekt on leping1.objektId = objekt.id 
			where leping1.id = tnId;
		lnAsutusId = v_arv.asutusId;
		ldKpv = tdkpv;
		lnRekvId = v_arv.rekvId;
		lcObjekt = ifnull(v_arv.objekt,'');
	end if;	
	if tnLiik = 3 then
		-- asutusId
		lnAsutusId = tnId;
		ldKpv = tdkpv;
		lnRekvId = ifnull(tnRekvId,1);
		lcObjekt = '';
	end if;	

	if ifnull(tnLiik,0) = 0 then
		return 0;
	end if;
	raise notice 'lnAsutusId %',lnAsutusId;
	raise notice 'lnRekvId %',lnRekvid;
--	lcViivis =  sp_calc_viivis(lnRekvid, lnAsutusId, ldKpv, 1);

	ldKpv = tdKpv;

	for qryArved in
	select arv.id, arv.number, arv.kpv, arv.asutusId, arv.tahtaeg,
		ifnull(dokprop.konto, space(20))::varchar(20) as konto,
		arv.summa * ifnull(dokvaluuta1.kuurs,1) as summa 
		from arv  left outer join dokprop on arv.doklausId = dokprop.id
		left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 3)
		where kpv < ldKpv and arv.asutusid = lnAsutusid and rekvid = lnRekvid 
		and arv.id >= lnArveId1 and arv.id <= lnArveId2
		and year(arv.kpv) >= 2011
		and arv.liik = 0
	loop
--		and ifnull(objekt,'') = ifnull(lcobjekt,'null') 


		raise notice 'QRYaRVED.number %',qryArved.number;
		raise notice 'QRYaRVED.ID %',qryArved.id;
		raise notice 'QRYaRVED.kpv %',qryArved.kpv;

--		if not empty (qryArved.konto) then
--			lnAlgsaldo := asd(qryArved.konto, tnrekvid, qryArved.AsutusId, qryArved.kpv - 1);
--		end if;
		lnVolg = qryArved.summa;
		lnPaevad = fncViiviseTahtajastePaevad(qryArved.id,tdKpv, lcTimestamp);
		lnViivisK = lnVolg * lnPaevad * lnViiviseIntress * 0.01;

		raise notice 'lnVolg %',lnVolg;
		raise notice 'lnPaevad %',lnPaevad;
		raise notice 'lnViivisK  %',lnViivisK ;

		insert into tmp_viivis (Timestamp, id, rekvId , asutusId , konto , algjaak , algkpv , arvnumber , tahtaeg , summa, volg1, paev1, viivis1)
			values (lcTimestamp, qryArved.id, tnRekvId, qryArved.AsutusId, qryArved.Konto, lnAlgsaldo, qryArved.kpv-1,  qryArved.number, qryArved.tahtaeg, 
				qryArved.summa, lnVolg, lnPaevad, lnViivisK);


--	tasud

		liKirjad = 0;
		for v_tasud in
			select kpv, sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa 
				from arvtasu left outer join dokvaluuta1 on (arvtasu.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 21)
				where arvid = qryArved.id 
				group by kpv order by kpv
		loop
			
			lnPaevad = fncViiviseTahtajastePaevad(qryArved.id,v_tasud.Kpv, lcTimestamp);
			lnViivis = lnVolg * lnPaevad * lnViiviseIntress * 0.01;
			raise notice 'Paevad muudetud :%',lnPaevad;
			raise notice 'tasu %',v_tasud.summa;

			if lnViivis > 0 then
				if liKirjad = 0 then
					lnViivisK = 0;
				end if;
			end if;
			lnViivisK = lnViivisK + lnViivis;
			liKirjad = liKirjad + 1;
			lnVolg = lnVolg - v_tasud.summa;
			raise notice 'lnVolg %',lnVolg;

			if lnVolg = 0 then
				exit;
			end if;
--			lcKpv = 'date('+year(
			lcString = 'update tmp_viivis set tasud'+ltrim(rtrim(str(liKirjad)))+' = '+quote_literal(v_tasud.kpv::varchar)+' , '+
			' tasun' + ltrim(rtrim(str(liKirjad))) +' = '+round(v_tasud.summa/ lnKuurs,2)::varchar+ ', '+
			' volg' + ltrim(rtrim(str(liKirjad)))+ ' = '+round(lnVolg/lnKuurs,2)::varchar +', '+
			' viivis' + ltrim(rtrim(str(liKirjad)))+ ' = '+round(lnViivis/lnKuurs,2)::varchar +
			' where timestamp = '+quote_literal(lcTimestamp)+
			' and id = '+qryArved.id::varchar;

			raise notice 'lcString %',lcString;
		execute lcString;
/*
			update tmp_viivis set tasud1 = v_tasud.kpv,
				tasun1 = v_tasud.summa,
				volg1 = lnVolg,
				viivis1 = lnViivis1
				where timestamp = lcTimestamp;


		-- parandus (NarvaLv)
		if qryArved.tahtaeg < date(2012,01,01) then
			-- viimane tasu kuupaev		
			select * into v_viivis from tmp_viivis where timestamp = lcTimestamp;	
			ldKpv = qryArved.tahtaeg;
			if not empty(v_viivis.tasun1) and v_viivis.tasud1 > ldKpv and v_viivis.tasud1 < date(2012,01,01) then
				ldKpv = v_viivis.tasud1;
				-- jaak seisuga ldKpv
				lnSumma = qryArved.summa - v_viivis.tasun1;
			end if;
			if not empty(v_viivis.tasun2) and v_viivis.tasud2 > ldKpv and v_viivis.tasud2 < date(2012,01,01) then
				ldKpv = v_viivis.tasud2;
				-- jaak seisuga ldKpv
				lnSumma = qryArved.summa - (v_viivis.tasun1+v_viivis.tasun2);
			end if;
			if not empty(v_viivis.tasun3) and v_viivis.tasud3 > ldKpv and v_viivis.tasud3 < date(2012,01,01) then
				ldKpv = v_viivis.tasud3;
				-- jaak seisuga ldKpv
				lnSumma = qryArved.summa - (v_viivis.tasun1+v_viivis.tasun2+v_viivis.tasun3);
			end if;
			if not empty(v_viivis.tasun4) and v_viivis.tasud4 > ldKpv and v_viivis.tasud4 < date(2012,01,01) then
				ldKpv = v_viivis.tasud4;
				-- jaak seisuga ldKpv
				lnSumma = qryArved.summa - (v_viivis.tasun1+v_viivis.tasun2+v_viivis.tasun3+v_viivis.tasun4);
			end if;
			if not empty(v_viivis.tasun5) and v_viivis.tasud5 > ldKpv and v_viivis.tasud5 < date(2012,01,01) then
				ldKpv = v_viivis.tasud5;
				-- jaak seisuga ldKpv
				lnSumma = qryArved.summa - (v_viivis.tasun1+v_viivis.tasun2+v_viivis.tasun3+v_viivis.tasun4+v_viivis.tasun5);
			end if;
		end if;
*/
		end loop;
		-- v_tasu
		
	END loop;
	--qryArved
--	select sum(viivis1) into lnSumma from tmp_viivis where timestamp = lcTimestamp;

--	lnSumma = ifnull(lnSumma,0);
	return lcTimestamp;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fncarvestaviivis1(integer, integer, numeric, date, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fncarvestaviivis1(integer, integer, numeric, date, integer) TO public;
GRANT EXECUTE ON FUNCTION fncarvestaviivis1(integer, integer, numeric, date, integer) TO vlad;
GRANT EXECUTE ON FUNCTION fncarvestaviivis1(integer, integer, numeric, date, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncarvestaviivis1(integer, integer, numeric, date, integer) TO dbpeakasutaja;
