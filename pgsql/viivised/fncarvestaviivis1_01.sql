-- Function: fncarvestaviivis1(integer, integer, numeric, date, integer)

-- DROP FUNCTION fncarvestaviivis1(integer, integer, numeric, date, integer);
/*
select fncarvestaviivis1(asutusid, 3, 0.05, date(2012,06,30), 6) from arv where number = '466r12' and rekvid = 6

select fncarvestaviivis1(id, 1, 0.05, date(2012,07,31), 6) from arv where number = '86r12' and rekvid = 6

select fncarvestaviivis1(176846, 1, 0.05, date(2012,06,30), 6, date(2012,01,10))
select fncViiviseTahtajastePaevad(id,date(2012,06,30), 'test',date(2012,02,29)) from arv where number = '170r12' and rekvid = 6


select * from tmp_viivis where timestamp = '201207253745435' 
order by timestamp desc limit 10

select * from tmp_viivis where timestamp = '201207233634585'

select * from tmp_viivis where timestamp = '201207254445887'


 order by timestamp desc limit 10

select * from tmp_viivis where mark = 0

delete from tmp_viivis 

*/

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
	lnPaevadT integer;
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
	lnKuurs numeric (14,4);
	ldKpvViimane date;
	lnAasta integer;
	lnTasu2011 numeric(14,4);
	ldTasuKpv date;
	ldEnneKoostatudViiviseArve date;
	lnArveSumma numeric(14,4);

BEGIN
	lnArveId1 = 0;
	lnArveId2 = 999999999;
	lnAasta = 1900;

	lcTimestamp = to_char(now(), 'YYYYMMDDMISSSS')::varchar;
	lnViiviseIntress = ifnull(tnViiviseMaar,0.01);
	lnAlgsaldo = 0;
	lnTasu2011 = 0;
	ldTasuKpv = date(2011,31,12);
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
		arv.summa * ifnull(dokvaluuta1.kuurs,1) as summa, arv.jaak, arv.tasud, fncArvJaak2012(arv.id) as jaak2012
		from arv  left outer join dokprop on arv.doklausId = dokprop.id
		left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 3)
		where kpv < ldKpv and arv.asutusid = lnAsutusid and rekvid = lnRekvid 
		and arv.id >= lnArveId1 and arv.id <= lnArveId2
		and year(arv.kpv) >= 2011
		and fncArvJaak2012(arv.id) > 0
		and arv.liik = 0
		and arv.objektid = 0
	loop
--		and ifnull(objekt,'') = ifnull(lcobjekt,'null') 
		raise notice 'QRYaRVED.number %',qryArved.number;
		raise notice 'QRYaRVED.jaak2012 %',qryArved.jaak2012;

		raise notice 'QRYaRVED.ID %',qryArved.id;
		raise notice 'QRYaRVED.kpv %',qryArved.kpv;
		ldKpvViimane = qryArved.tahtaeg;
		lnArveSumma = qryArved.summa;

		-- kontrollime kas on enne koostatud viivise arve

		ldEnneKoostatudViiviseArve = fncviivisearvekpv(qryArved.id);
		if not empty(ldEnneKoostatudViiviseArve) then
			raise notice 'Leitud enne koostatud viivise arve %',ldEnneKoostatudViiviseArve;
			ldKpvViimane = ldEnneKoostatudViiviseArve;
		end if;

--		if not empty (qryArved.konto) then
--			lnAlgsaldo := asd(qryArved.konto, tnrekvid, qryArved.AsutusId, qryArved.kpv - 1);
--		end if;
		lnVolg = qryArved.summa;
		if qryArved.kpv < date(2012,01,01) then
			lnVolg = qryArved.jaak2012;
			lnAasta = 2011;
			-- laekumised seisuga 31.12.2011
			select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasu2011
				from arvtasu left outer join dokvaluuta1 on (arvtasu.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 21)
				where arvid = qryArved.id 
				and year(arvtasu.kpv) < 2012;
			lnTasu2011 = ifnull(lnTasu2011,0);
			
		end if;		
		lnPaevad = fncViiviseTahtajastePaevad(qryArved.id,tdKpv, lcTimestamp, ldKpvViimane);
		
		if not empty(ldEnneKoostatudViiviseArve) then
			lnVolg = fncArvJaakSeisuga(qryArved.id,ldEnneKoostatudViiviseArve);
--			lnTasu2011 = qryArved.summa - lnVolg;
			lnArveSumma = lnVolg;
			if lnVolg = 0 and not empty(ldEnneKoostatudViiviseArve) then
				-- jaak seisuge enne koostatud viivise arve = 0, siis paevad = 0
				lnPaevad = 0;
			end if;
--			if lnVolg = 0 then
				-- arvestame et volg = viimane tasu summa voi arve summa
--				lnVolg = fncArvViimaneSaldo(qryArved.id);
--			end if;
			raise notice 'Parandatud lnVolg %',lnVolg;
			raise notice 'Parandatud lnpaevad %',lnPaevad;
			
		end if;
		lnViivisK = lnVolg * lnPaevad * lnViiviseIntress * 0.01;

		raise notice 'lnVolg %',lnVolg;
		raise notice 'lnPaevad %',lnPaevad;
		raise notice 'lnViivisK  %',lnViivisK ;

		insert into tmp_viivis (Timestamp, id, rekvId , asutusId , konto , algjaak , algkpv , arvnumber , tahtaeg , summa, tasud1, tasun1, volg1, paev1, viivis1)
			values (lcTimestamp, qryArved.id, tnRekvId, qryArved.AsutusId, qryArved.Konto, lnAlgsaldo, qryArved.kpv-1,  qryArved.number, qryArved.tahtaeg, 
				lnArveSumma, ldTasuKpv, lnTasu2011, lnVolg, lnPaevad, lnViivisK);


--	tasud

		liKirjad = 0;
		if not empty(ldEnneKoostatudViiviseArve) then
			ldTasuKpv = ldEnneKoostatudViiviseArve;
--			update tmp_viivis set tasud1 = ldTasuKpv, tasun1 = lnVolg where timestamp = lcTimestamp;
		else
			ldTasuKpv = date(1900,01,01);
		end if;
		for v_tasud in
			select kpv, sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa 
				from arvtasu left outer join dokvaluuta1 on (arvtasu.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 21)
				where arvid = qryArved.id 
				and year(arvtasu.kpv) > lnAasta
				and kpv >= ldTasuKpv
				group by kpv order by kpv


		loop
			raise notice 'tasumine %',v_tasud.kpv;
			raise notice 'tasumine %',v_tasud.summa;
			ldKpv = v_tasud.Kpv;
			if ldKpv > tdKpv then
				ldKpv = tdKpv;
			end if;
			
			lnPaevadT = fncViiviseTahtajastePaevad(qryArved.id,ldKpv, lcTimestamp, ldKpvViimane);
			raise notice 'lnPaevadT:%',lnPaevadT;
			
			ldKpvViimane = v_tasud.Kpv;
			if ldKpvViimane < qryArved.tahtaeg then
				ldKpvViimane = qryArved.tahtaeg;
			end if;
			if ldKpvViimane > tdKpv then
				ldKpvViimane = tdKpv;
			end if;
			if lnPaevadT > 0 then
				lnPaevad = lnPaevadT;
			else
				-- Arve makstud
				if ldKpv < qryArved.tahtaeg then
					lnPaevad = 0;
				end if;
			end if;
			 
			lnViivis = lnVolg * lnPaevadT * lnViiviseIntress * 0.01;
			raise notice 'Paevad muudetud, lnVolg:%',lnVolg;
			raise notice 'Paevad muudetud :%',lnPaevadT;
			raise notice 'tasu %',v_tasud.summa;
			raise notice 'lnViivis %',lnViivis;

			if lnViivis > 0 then
				if liKirjad = 0 then
					lnViivisK = 0;
				end if;
			end if;
			lnViivisK = lnViivisK + lnViivis;
			liKirjad = liKirjad + 1;
			lnVolg = lnVolg - v_tasud.summa;
			-- parandus 13.07.2012
			if lnPaevadT = 0 and lnVolg = 0 then
			
				lnViivisK = 0;
				lnPaevad = lnPaevadT;
				raise notice 'lnVolg %',lnVolg;
				raise notice 'lnPaevad %',lnPaevad;
				raise notice 'lnViivisK %',lnViivisK;
				raise notice 'llnViivis %',lnViivis;
			end if;
/*
			if lnPaevad > 0 and lnPaevadT = 0 and lnVolg > 0 then
				lnPaevad = lnPaevadT;
			end if;
*/				
			if lnVolg = 0 and  lnPaevad = 0 and lnViivis = 0 and qryArved.jaak <= 0 then
				raise notice 'Volg puudub, paevad = 0, kustutan kiri';
				raise notice 'qryArved.jaak %',qryArved.jaak;

				update tmp_viivis set mark = 0 where id = qryArved.id and timestamp = lcTimestamp;
				delete from tmp_viivis where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcTimestamp)) and id = qryArved.id;
--				delete from tmp_viivis where id = qryArved.id;

				if (select count(*) from tmp_viivis where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcTimestamp)) and id = qryArved.id ) > 0 then
					raise notice 'Kustutatud';
				else
					raise notice 'Kustutamine eba onnestus';
				end if;
				
				
			else
				raise notice 'lnVolg %',lnVolg;

--			lcKpv = 'date('+year(
				lcString = 'update tmp_viivis set tasud'+ltrim(rtrim(str(liKirjad)))+' = '+quote_literal(v_tasud.kpv::varchar)+' , '+
					' tasun' + ltrim(rtrim(str(liKirjad))) +' = '+v_tasud.summa::varchar+ ', '+
					' paev' + ltrim(rtrim(str(liKirjad))) +' = '+lnPaevad::varchar+ ', '+
					' volg' + ltrim(rtrim(str(liKirjad)))+ ' = '+lnVolg::varchar +', '+
					' viivis' + ltrim(rtrim(str(liKirjad)))+ ' = '+lnViivis::varchar +
					' where timestamp = '+quote_literal(lcTimestamp)+
					' and id = '+qryArved.id::varchar;

				raise notice 'lcString %',lcString;
				execute lcString;

			end if;
			
			if lnVolg = 0 then
				exit;
			end if;

		end loop;
		-- v_tasu
		if lnVolg > 0 and liKirjad > 0 then
			liKirjad = liKirjad +1;
			lnPaevad = fncViiviseTahtajastePaevad(qryArved.id,tdKpv, lcTimestamp, ldKpvViimane);
			lnViivis = lnVolg * lnPaevad * lnViiviseIntress * 0.01;
			raise notice 'Volg > 0 , salvestan paevad %',lnPaevad;
				
			lcString = 'update tmp_viivis set tasun' + ltrim(rtrim(str(liKirjad))) +' = 0, '+
				' paev' + ltrim(rtrim(str(liKirjad))) +' = '+lnPaevad::varchar+ ', '+
				' volg' + ltrim(rtrim(str(liKirjad)))+ ' = '+lnVolg::varchar +', '+
				' viivis' + ltrim(rtrim(str(liKirjad)))+ ' = '+lnViivis::varchar +
				' where timestamp = '+quote_literal(lcTimestamp)+
				' and id = '+qryArved.id::varchar;
			raise notice 'lcString2 %',lcString;
			execute lcString;
		end if;
		
		ldEnneKoostatudViiviseArve = null;
	END loop;
	--qryArved
--	select sum(viivis1) into lnSumma from tmp_viivis where timestamp = lcTimestamp;

--	lnSumma = ifnull(lnSumma,0);
--	delete from tmp_viivis where mark = 0;
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
