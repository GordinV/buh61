-- Function: sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text, character varying, character varying, integer)

-- DROP FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text, character varying, character varying, integer);

CREATE OR REPLACE FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text, character varying, character varying, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnvastisikid alias for $2;
	tdsoetkpv alias for $3;
	tnkulum alias for $4;
	tnalgkulum alias for $5;
	tngruppid alias for $6;
	tckonto alias for $7;
	tntunnus alias for $8;
	ttselg alias for $9;
	ttrentnik alias for $10;
	tcKood alias for $11;
	tcNimetus alias for $12;
	tnRekvId alias for $13;
	lnpv_kaartId int;
	lnId int; 
	lnParentId int;
	lrCurRec record;
begin

raise notice 'vats %',tnVastisikId;
if tnId = 0 then
	-- uus kiri

	lnParentId = sp_salvesta_library(tnId, tnRekvId, tcKood, tcNimetus, 'POHIVARA', ttSelg, 0, 1, 0, 0, 0);

	if lnParentId = 0 then
		raise notice 'Viga, ei saa salvesta dokument';
		return 0;
	end if;
	
	insert into pv_kaart (parentid,vastisikid,soetkpv,kulum,algkulum,gruppid,konto,tunnus,muud) 
		values (lnparentid,tnvastisikid,tdsoetkpv,tnkulum,tnalgkulum,tngruppid,tckonto,tntunnus,ttRentnik);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnpv_kaartId:= cast(CURRVAL('public.pv_kaart_id_seq') as int4);
	else
		lnpv_kaartId = 0;
	end if;

	if lnpv_kaartId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

else
	-- muuda 

--	select parentid into lnParentId from pv_kaart where id = tnId;
	lnParentId = sp_salvesta_library(tnId, tnRekvId, tcKood, tcNimetus, 'POHIVARA', ttSelg, 0, 0, 0, 0, 0);

	if lnParentId = 0 then
		raise notice 'Viga, ei saa salvesta dokument';
		return 0;
	end if;


	update pv_kaart set 
			vastisikid = tnvastisikid,
			soetkpv = tdsoetkpv,
			kulum = tnkulum,
			algkulum = tnalgkulum,
			gruppid = tngruppid,
			konto = tckonto,
			muud = ttRentnik
		where parentid = tnId;

	lnpv_kaartId := tnId;

	perform sp_update_pv_jaak(tnId);
end if;

         return  lnParentId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text, character varying, character varying, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text, character varying, character varying, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text, character varying, character varying, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text, character varying, character varying, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_kaart(integer, integer, date, numeric, numeric, integer, character varying, integer, text, text, character varying, character varying, integer) TO dbpeakasutaja;
