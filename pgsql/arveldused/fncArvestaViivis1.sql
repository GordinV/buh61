-- Function: fncarvestaviivis(integer)

-- DROP FUNCTION fncarvestaviivis(integer);

CREATE OR REPLACE FUNCTION fncarvestaviivis(integer)
  RETURNS numeric AS
$BODY$


declare 
	tnId ALIAS FOR $1;
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

BEGIN

	lnViiviseIntress = 0.01;
	
	select * into v_arv from arv where id = tnId;
	lcViivis =  sp_calc_viivis(v_arv.rekvid, v_arv.asutusId, v_arv.kpv, 1);
	for v_viivis in
		select * from tmp_viivis where timestamp = lcViivis and id in (select id from arv  where kpv < v_arv.kpv and arv.asutusid = v_arv.asutusid)
--			and ifnull(objekt,'null') = ifnull(v_arv.objekt,'null') )
	loop
		lnAlgsaldo = v_viivis.algjaak;

		lnSumma = 0;
		lnPeni = 0;
		lnkVolg = 0;
		lnTasud = 0;

		lnViivis = 0;
		lnViivisK = 0;

		lnVolg = v_viivis.volg1+v_viivis.volg2+v_viivis.volg3+v_viivis.volg4+v_viivis.volg5+v_viivis.volg6 + lnAlgsaldo;

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

		lnViivis = ifnull(lnViivis,0);
--		lnViivis = round(lnViivis,2)

		IF not empty(v_viivis.tasud1) then 
			ldtasud = v_viivis.tasud1;
		end if;
		lnViivisK = lnViivisK + lnViivis;

		lnPeni = lnPeni + lnViivisK;

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
--		lnViivis = round(lnViivis,2)

			IF not empty(v_viivis.tasud2) then 
				ldtasud = v_viivis.tasud2;
			end if;
			lnViivisK = lnViivisK + lnViivis;

			lnPeni = lnPeni + lnViivisK;

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

			lnPeni = lnPeni + lnViivisK;
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

			lnPeni = lnPeni + lnViivisK;
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

			lnPeni = lnPeni + lnViivisK;

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

			lnPeni = lnPeni + lnViivisK;

		end if;
		raise notice 'lnPeni %',lnPeni;

	END loop;

	return lnPeni;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fncarvestaviivis(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fncarvestaviivis(integer) TO public;
GRANT EXECUTE ON FUNCTION fncarvestaviivis(integer) TO vlad;
GRANT EXECUTE ON FUNCTION fncarvestaviivis(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncarvestaviivis(integer) TO dbpeakasutaja;
