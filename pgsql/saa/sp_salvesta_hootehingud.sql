-- Function: sp_salvesta_aasta(integer, integer, integer, integer, integer, integer)

-- DROP FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying,text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnIsikId alias for $2;
	tnEttemaksid alias for $3;
	tnDokId alias for $4;
	tcDokTyyp alias for $5;
	tdKpv alias for $6;
	tnSumma alias for $7;
	tcAllikas alias for $8;
	tcTyyp alias for $9;
	ttMuud alias for $10;

	lnId int; 
	lrCurRec record;
	lnTehinguSumma numeric;
	lnEttemaksuSumma numeric;
begin
if tnId = 0 then
	-- uus kiri
	insert into hootehingud (isikid, ettemaksid,dokid,doktyyp, kpv ,summa ,allikas,tyyp, muud) 
		values (tnIsikid, tnettemaksid,tndokid,tcdoktyyp, tdkpv ,tnsumma ,tcallikas,tctyyp, ttmuud);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
--		raise notice 'lnId %',lnId;
		lnId:= cast(CURRVAL('public.hootehingud_id_seq') as int4);
--		raise notice 'lnaastaId %',lnaastaId;
	else
		lnId = 0;
	end if;
else
	-- muuda 
--	select * into lrCurRec from aasta where id = tnId;
--	if lrCurRec.rekvid <> tnrekvid or lrCurRec.aasta <> tnaasta or lrCurRec.kuu <> tnkuu or lrCurRec.kinni <> tnkinni or lrCurRec.default_ <> tndefault_ then 
	update hootehingud set 
		isikid = tnIsikId, 
		ettemaksid = tnEttemaksId,
		dokid = tnDokId,
		doktyyp = tcDoktyyp, 
		kpv = tdKpv,
		summa = tnSumma,
		allikas = tcAllikas,
		tyyp = tcTyyp, 
		muud = ttMuud
	where id = tnId;
--	end if;
	lnId := tnId;
end if;

	-- kontrollime kas ettemaksu summa vordleb tehingusumma

	select sum(summa) into lnEttemaksuSumma from hooEttemaksud where id = tnEttemaksId;
	select sum(summa) into lnTehinguSumma from hootehingud where ettemaksid = tnEttemaksId;
	if ifnull(lnTehinguSumma,0) = ifnull(lnEttemaksuSumma,0) and ifnull(lnTehinguSumma,0) > 0 then
		-- ettemaks klassifitseeritud, staatus = 0
		update hooettemaksud set staatus = 0 where id = tnEttemaksId;
	end if;
	-- arvestame jaagid
	perform sp_calc_hoojaak(tnIsikId);

	-- uhendame arved ja isik
	if (select count(id) from hoouhendused where isikid = tnIsikId and dokid = tnDokId and doktyyp = tcDoktyyp) = 0 THEN
		insert into hoouhendused (isikid, dokid, doktyyp) values (tnIsikId, tnDokId, tcDoktyyp);
	end if;


         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying,text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying,text) TO hkametnik;
GRANT EXECUTE ON FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying,text) TO soametnik;
