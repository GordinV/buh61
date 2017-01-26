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

BEGIN

	lcTimestamp = to_char(now(), 'YYYYMMDDMISSSS')::varchar;
	lnViiviseIntress = ifnull(tnViiviseMaar,0.01);
	lnAlgsaldo = 0;
	
	if tnLiik = 1 then
		--arve
		select asutusId, kpv, rekvid, objekt into v_arv from arv where id = tnId;
		lnAsutusId = v_arv.asutusId;
		ldKpv = v_arv.kpv;
		lnRekvId = v_arv.rekvId;
		lcObjekt = ifnull(v_arv.objekt,'');
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
		and arv.liik = 0
	loop
--		and ifnull(objekt,'') = ifnull(lcobjekt,'null') 


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
				from arvtasu left outer join dokvaluuta1 on (arvtasu.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 22)
				where arvid = qryArved.id 
				group by kpv order by kpv
		loop
			
			lnPaevad = fncViiviseTahtajastePaevad(qryArved.id,v_tasud.Kpv, lcTimestamp);
			lnViivis = lnVolg * lnPaevad * lnViiviseIntress * 0.01;
			raise notice 'Paevad muudetud :%',lnPaevad;
			if lnViivis > 0 then
				if liKirjad = 0 then
					lnViivisK = 0;
				end if;
			end if;
			lnViivisK = lnViivisK + lnViivis;
			liKirjad = liKirjad + 1;
			lnVolg = lnVolg - v_tasud.summa;
			if lnVolg = 0 then
				exit;
			end if;
--			lcKpv = 'date('+year(
			lcString = 'update tmp_viivis set tasud'+ltrim(rtrim(str(liKirjad)))+' = '+quote_literal(v_tasud.kpv::varchar)+' , '+
			' tasun' + ltrim(rtrim(str(liKirjad))) +' = '+v_tasud.summa::varchar+ ', '+
			' volg' + ltrim(rtrim(str(liKirjad)))+ ' = '+lnVolg::varchar +', '+
			' viivis' + ltrim(rtrim(str(liKirjad)))+ ' = '+lnViivis::varchar +
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
