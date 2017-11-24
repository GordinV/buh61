-- Function: sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying, text)
/*

*/
-- DROP FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying, text);

CREATE OR REPLACE FUNCTION sp_salvesta_hooteenused(integer, integer, integer, numeric, date, text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnLepingId alias for $2;
	tnNomId alias for $3;
	tnHind alias for $4;
	tdKehtivus alias for $5;
	ttMuud alias for $6;

	lnId int; 
	lrCurRec record;
begin
if tnId = 0 then
	-- uus kiri
	insert into hooteenused (Lepingid,  NomId, allikas, Hind,Kehtivus, muud) 
		values (tnLepingid, tnNomId,space(1), tnHind,tdKehtivus,ttmuud);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
--		raise notice 'lnId %',lnId;
		lnId:= cast(CURRVAL('public.hooteenused_id_seq') as int4);
--		raise notice 'lnaastaId %',lnaastaId;
	else
		lnId = 0;
	end if;
else
	-- muuda 
--	select * into lrCurRec from aasta where id = tnId;
--	if lrCurRec.rekvid <> tnrekvid or lrCurRec.aasta <> tnaasta or lrCurRec.kuu <> tnkuu or lrCurRec.kinni <> tnkinni or lrCurRec.default_ <> tndefault_ then 
	update hooteenused set 
		Lepingid = tnLepingId, 
		NomId = tnNomId,
		Hind = tnHind,
		Kehtivus= tdkehtivus,
		muud = ttMuud
	where id = tnId;
--	end if;
	lnId := tnId;
end if;

--	perform sp_calc_hoojaak(tnIsikId);
         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_hooteenused(integer, integer, integer, numeric, date, text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_hooteenused(integer, integer, integer, numeric, date, text) TO hkametnik;
GRANT EXECUTE ON FUNCTION sp_salvesta_hooteenused(integer, integer, integer, numeric, date, text) TO soametnik;
