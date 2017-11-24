-- Function: fncviivisetahtajastepaevad(integer, date, character varying)
/*
select date(2012,06,30) - date(2012,03,23)


*/
-- DROP FUNCTION fncviivisetahtajastepaevad(integer, date, character varying);

CREATE OR REPLACE FUNCTION fncviivisetahtajastepaevad(integer, date, character varying, date)
  RETURNS integer AS
$BODY$


declare 
	tnId ALIAS FOR $1;
	tdKpv ALIAS FOR $2;
	tcTimestamp ALIAS FOR $3;
	tdKpvViimane ALIAS FOR $4;
	lnPaevad integer;
	lnViimanePaev integer;
	ldKpvViimane date;
	ldKpv date;
	v_arv record;

	lnCount integer;
	lcArveString varchar;
	lnPaevadInString integer;
	lnPaevadInStringLopp Integer;
	
BEGIN
	if empty(tdKpv) then
		ldKpv = date();
	else
		ldKpv = tdKpv;
	end if;
	select id, tahtaeg, kpv, number, rekvid, asutusId into v_arv from arv where id = tnId;
	if ifnull(v_arv.id,0) = 0 or empty(v_arv.tahtaeg) then
		lnPaevad = 0;
	else
		ldKpvViimane = tdKpvViimane ;
		-- parandus 16.07.2012
		if year(ldKpvViimane) < 2012 then
			ldKpvViimane = date(2011,12,31);
		end if;
		lnPaevad = tdKpv - ldKpvViimane;
--		raise notice 'tdKpv: %',tdKpv;
--		raise notice 'ldKpvViimane: %',ldKpvViimane;
--		raise notice 'Paevad: %',lnPaevad;
	end if; 
	
	if lnPaevad < 0 then
		lnPaevad = 0;
	end if;

-- otsime enne valjastatud viivise arved

	select count(arv.id) into lnCount
		from arv inner join arv1 on arv.id = arv1.parentid 
		where rekvid = v_arv.RekvId and arv1.muud like '%Arve nr.:'+ltrim(rtrim(v_Arv.number))+'%' and arv1.muud like '%viivis%'; 
									
	lnCount = ifnull(lnCount,0);
	
	if lnCount > 0 then
--		raise notice 'leitud tasud viivise arve nr  valastame paevade arv uuendatud%',v_Arv.number;

		select ltrim(rtrim(arv1.muud::varchar(512))) into lcArveString from arv1 inner join arv on arv.id = arv1.parentid 
			where arv.rekvid = v_arv.rekvId and arv.asutusid = v_arv.asutusid  and arv1.muud like '%Arve nr.:'+ltrim(rtrim(v_arv.number))+'%' 
			and arv1.muud like '%viivis%' order by arv.id desc limit 1;

		lcArveString = ifnull(lcArveString,'tuhi');
		update tmp_printarv set arvmuud = lcArveString;
--		raise notice 'lcArveString: %',lcArveString;
--		lnPaevadInString = position(upper('Paevad:') in upper(lcArveString));
--		if empty(lnPaevadInString) then
			lnPaevadInString = position(upper('Paevad:') in upper(lcArveString));
--		end if;
		lnPaevadInStringLopp = position(upper('viivis') in upper(lcArveString));
--		raise notice 'Position lnPaevadInString %',lnPaevadInString;
--		raise notice 'Position lnPaevadInStringLopp %',lnPaevadInStringLopp;
		
		lnPaevadInString = ifnull( lnPaevadInString,0);
		if not empty( lnPaevadInString) and lnPaevadInString > 0  then
--						raise notice 'lcArveString: %',lcArveString;
			lcArveString = ltrim(rtrim(substring(lcArveString,lnPaevadInString+7,lnPaevadInStringLopp-(lnPaevadInString+7))));
--						lcArveString = ltrim(rtrim(substring(lcArveString,lnPaevadInString+7,lnPaevadInStringLopp-(lnPaevadInString+7))))::integer;
--			raise notice 'lcArveString: %',lcArveString;
			if empty(lcArveString) then
				lcArveString = '0';
			end if;
			lnPaevadInString = val(lcArveString);
		else
			lnPaevadInString = 0;
		end if;
				--	raise notice 'substring lnPaevadInString %',lnPaevadInString;
		lnPaevad = lnPaevad - lnPaevadInString;
		if lnPaevad < 0 then
			lnPaevad = 0;
		end if;					
	end if;
--		raise notice 'tnid:%',tnId;
--		raise notice 'tdKpv:%',tdKpv;
		raise notice 'lnPaevad:%',lnPaevad;


	return lnPaevad;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fncviivisetahtajastepaevad(integer, date, character varying, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fncviivisetahtajastepaevad(integer, date, character varying, date) TO public;
GRANT EXECUTE ON FUNCTION fncviivisetahtajastepaevad(integer, date, character varying, date) TO vlad;
GRANT EXECUTE ON FUNCTION fncviivisetahtajastepaevad(integer, date, character varying, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncviivisetahtajastepaevad(integer, date, character varying, date) TO dbpeakasutaja;
