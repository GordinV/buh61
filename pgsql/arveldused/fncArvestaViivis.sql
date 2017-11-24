-- Function: f_round(numeric, numeric)

-- DROP FUNCTION f_round(numeric, numeric);

/*

select *from asutus where nimetus like '

select * from tmp_viivis

select fncArvestaViivis( id) from arv where year(kpv) = 2010
from arv where year(kpv) = 2010 

select * from arv where rekvid = 6 and number like'446%'
select * from asutus where nimetus = 'NOORTE KLUBI ALEKS   '

select * from arv where year(kpv)=2010 

select fncArvestaViivis(      1772,3,0.50,date(2011, 2,01),6)
delete from tmp_viivis 


select * from tmp_viivis


		select * from tmp_viivis where  id in 
			(
				select id from arv  
					where kpv < date() and arv.asutusid = 1772 and rekvid = 6
					and ifnull(objekt,'null') = ifnull(null,'null') 
			)
 
*/



CREATE OR REPLACE FUNCTION fncArvestaViivis(integer,integer,numeric, date,integer)
  RETURNS numeric AS
$BODY$


declare 
	tnId ALIAS FOR $1;
	tnLiik ALIAS FOR $2;
	tnViiviseMaar ALIAS FOR $3;
	tdKpv ALIAS FOR $4;
	tnRekvId ALIAS FOR $5;
	lcViivis varchar;
	v_viivis record;
	v_arv record;
	lnAlgsaldo numeric;
	lnSumma numeric;
	lnPeni numeric;
	lnkVolg numeric;
	lnTasud numeric;
	lnViivis numeric;
	lnViivisK numeric;
	lnVolg numeric;
	lnlVolg numeric;
	ldTasud date;
	lnViiviseIntress numeric;

	lnAsutusId integer;
	ldKpv date;
	lnRekvId integer;
	lcObjekt varchar(20);

BEGIN

	lnViiviseIntress = ifnull(tnViiviseMaar,0.01);
	
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
		select leping1.asutusId, leping1.rekvId, objekt.kood as objekt into v_arv from leping1 left outer join library objekt on leping1.objektId = objekt.id 
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
	lcViivis =  sp_calc_viivis(lnRekvid, lnAsutusId, ldKpv, 1);
	lnPeni = 0;
	
	for v_viivis in
		select * from tmp_viivis where timestamp = lcViivis and id in 
			(
				select id from arv  
					where kpv < ldKpv and arv.asutusid = lnAsutusid and rekvid = lnRekvid
					and ifnull(objekt,'') = ifnull(lcobjekt,'null') 
			)
	loop
--		raise notice 'v_viivis.algjaak %',v_viivis.algjaak;
		lnAlgsaldo = v_viivis.algjaak;

		lnSumma = 0;
		lnkVolg = 0;
		lnTasud = 0;

		lnViivis = 0;
		lnViivisK = 0;
		lnlVolg = 0;
		lnVolg = 0;
		lnVolg = v_viivis.volg1+v_viivis.volg2+v_viivis.volg3+v_viivis.volg4+v_viivis.volg5+v_viivis.volg6 + lnAlgsaldo;

		raise notice 'lnVolg %',lnVolg;

		lnlVolg =v_viivis.volg1;
		If lnAlgsaldo <> 0 then
			lnlVolg = lnlVolg + lnAlgsaldo;
			lnAlgsaldo = 0;
			
		End if;
		if v_viivis.paev1 > 0 then
			lnViivis = lnlVolg * 0.01 * lnViiviseIntress * v_viivis.paev1;
		else
			lnViivis = 0;
		end if;
--			raise notice 'lnViivis1 %',lnViivis;
--			raise notice 'v_viivis.paev1 %',v_viivis.paev1;
		lnViivis = ifnull(lnViivis,0);
--		lnViivis = round(lnViivis,2)

		IF not empty(v_viivis.tasud1) then 
			ldtasud = v_viivis.tasud1;
		end if;
		lnViivisK = lnViivisK + lnViivis;

		if ifnull(v_viivis.tasud2,date()+1) < date() then
			lnlVolg =v_viivis.volg2;
			If lnAlgsaldo <> 0 then
				lnlVolg = lnlVolg + lnAlgsaldo;
				lnAlgsaldo = 0;
				
			End if;
			if v_viivis.paev2 > 0 then
				lnViivis = lnlVolg * 0.01 * lnViiviseIntress * v_viivis.paev2;
			else
				lnViivis = 0;
			end if;

			lnViivis = ifnull(lnViivis,2);
--			raise notice 'v_viivis.paev2 %',v_viivis.paev2;
--			raise notice 'lnViivis2 %',lnViivis;

--		lnViivis = round(lnViivis,2)

			IF not empty(v_viivis.tasud2) then 
				ldtasud = v_viivis.tasud2;
			end if;
			lnViivisK = lnViivisK + lnViivis;

--			lnPeni = lnPeni + ifnull(lnViivisK,0);

		end if;
		if ifnull(v_viivis.tasud3,date()+1) < date() then
			lnlVolg =v_viivis.volg3;
			If lnAlgsaldo <> 0 then
				lnlVolg = lnlVolg + lnAlgsaldo;
				lnAlgsaldo = 0;
				
			End if;
			if v_viivis.paev3 > 0 then
				lnViivis = lnlVolg * 0.01 * lnViiviseIntress * v_viivis.paev3;
			else
				lnViivis = 0;
			end if;

			lnViivis = ifnull(lnViivis,0);
--		lnViivis = round(lnViivis,2)

			IF not empty(v_viivis.tasud3) then 
				ldtasud = v_viivis.tasud3;
			end if;
			lnViivisK = lnViivisK + lnViivis;

--			lnPeni = lnPeni + ifnull(lnViivisK,0);
		end if;
		if ifnull(v_viivis.tasud4,date()+1) < date() then
			lnlVolg =v_viivis.volg2;
			If lnAlgsaldo <> 0 then
				lnlVolg = lnlVolg + lnAlgsaldo;
				lnAlgsaldo = 0;
				
			End if;
			if v_viivis.paev2 > 0 then
				lnViivis = lnlVolg * 0.01 *lnViiviseIntress * v_viivis.paev4;
			else
				lnViivis = 0;
			end if;

			lnViivis = ifnull(lnViivis,0);
--		lnViivis = round(lnViivis,2)

			IF not empty(v_viivis.tasud4) then 
				ldtasud = v_viivis.tasud4;
			end if;
			lnViivisK = lnViivisK + lnViivis;

--			lnPeni = lnPeni + ifnull(lnViivisK,0);
		end if;
		if ifnull(v_viivis.tasud5,date()+1) < date() then
			lnlVolg =v_viivis.volg5;
			If lnAlgsaldo <> 0 then
				lnlVolg = lnlVolg + lnAlgsaldo;
				lnAlgsaldo = 0;
				
			End if;
			if v_viivis.paev5 > 0 then
				lnViivis = lnlVolg * 0.01 * lnViiviseIntress * v_viivis.paev5;
			else
				lnViivis = 0;
			end if;

			lnViivis = ifnull(lnViivis,0);
--		lnViivis = round(lnViivis,2)

			IF not empty(v_viivis.tasud5) then 
				ldtasud = v_viivis.tasud5;
			end if;
			lnViivisK = lnViivisK + lnViivis;

--			lnPeni = lnPeni + ifnull(lnViivisK,0);

		end if;
		if ifnull(v_viivis.tasud6,date()+1) < date() then
			lnlVolg =v_viivis.volg6;
			If lnAlgsaldo <> 0 then
				lnlVolg = lnlVolg + lnAlgsaldo;
				lnAlgsaldo = 0;
				
			End if;
			if v_viivis.paev6 > 0 then
				lnViivis = lnlVolg * 0.01 * lnViiviseIntress * v_viivis.paev6;
			else
				lnViivis = 0;
			end if;

			lnViivis = ifnull(lnViivis,0);
--		lnViivis = round(lnViivis,2)

			IF not empty(v_viivis.tasud6) then 
				ldtasud = v_viivis.tasud6;
			end if;
			lnViivisK = lnViivisK + lnViivis;

--			lnPeni = lnPeni + ifnull(lnViivisK,0);

		end if;
		lnPeni = lnPeni + ifnull(lnViivisK,0);

		raise notice 'lnPeni %',lnPeni;
		raise notice ' lnViivisK %', lnViivisK;

	END loop;

	return lnPeni;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fncArvestaViivis(integer,integer,numeric, date,integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fncArvestaViivis(integer,integer,numeric, date,integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncArvestaViivis(integer,integer,numeric, date,integer) TO dbpeakasutaja;
