-- Function: sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying, text)
/*
select * from hootaabel

 hooldajaid integer NOT NULL DEFAULT 0,
  isikid integer NOT NULL DEFAULT 0,
  kohtumaarus character varying(254) NOT NULL,
  algkpv date NOT NULL, -- alg.kpv
  loppkpv date,
  muud 
*/
-- DROP FUNCTION sp_salvesta_hootehingud(integer, integer, integer, integer, character varying, date, numeric, character varying, character varying, text);

CREATE OR REPLACE FUNCTION sp_salvesta_hooldaja(integer, integer, integer, character varying, date,date, text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnhooldajaid alias for $2;
	tnisikId alias for $3;
	tcKohtumaarus alias for $4;
	tdAlgKpv alias for $5;
	tdLoppKpv alias for $6;
	ttMuud alias for $7;

	lnId int; 
	lrCurRec record;
begin
if tnId = 0 then
	-- uus kiri
	insert into hooldaja (hooldajaid,  IsikId, Kohtumaarus, algkpv,loppkpv, muud) 
		values (tnhooldajaid,  tnIsikId, tcKohtumaarus, tdalgkpv,tdloppkpv,ttmuud);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnId:= cast(CURRVAL('public.hooldaja_id_seq') as int4);
	else
		lnId = 0;
	end if;
else
	-- muuda 
--	select * into lrCurRec from aasta where id = tnId;
--	if lrCurRec.rekvid <> tnrekvid or lrCurRec.aasta <> tnaasta or lrCurRec.kuu <> tnkuu or lrCurRec.kinni <> tnkinni or lrCurRec.default_ <> tndefault_ then 
	update hooldaja set 
		hooldajaid = tnhooldajaid,  
		IsikId = tnIsikId, 
		Kohtumaarus = tcKohtumaarus, 
		algkpv = tdAlgKpv,
		loppkpv = tdLoppKpv,
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
ALTER FUNCTION sp_salvesta_hooldaja(integer, integer, integer, character varying, date,date, text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_hooldaja(integer, integer, integer, character varying, date,date, text) TO hkametnik;
GRANT EXECUTE ON FUNCTION sp_salvesta_hooldaja(integer, integer, integer, character varying, date,date, text) TO soametnik;
