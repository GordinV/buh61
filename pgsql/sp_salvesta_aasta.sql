-- Function: sp_salvesta_aasta(integer, integer, integer, integer, integer, integer)

/*

select sp_salvesta_aasta(0, 2, 2998, 1, 0, 0);

select * from aasta order by id desc limit 10
*/

-- DROP FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnaasta alias for $3;
	tnkuu alias for $4;
	tnkinni alias for $5;
	tndefault_ alias for $6;
	lnaastaId int;
	lnId int; 
	lrCurRec record;
begin

if tnId = 0 then
	-- uus kiri
	insert into aasta (rekvid,aasta,kuu,kinni,default_) 
		values (tnrekvid,tnaasta,tnkuu,tnkinni,tndefault_);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		raise notice 'lnId %',lnId;
		lnaastaId:= cast(CURRVAL('public.aasta_id_seq') as int4);
		raise notice 'lnaastaId %',lnaastaId;
	else
		lnAastaId = 0;
	end if;
else
	-- muuda 
	select * into lrCurRec from aasta where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or lrCurRec.aasta <> tnaasta or lrCurRec.kuu <> tnkuu or lrCurRec.kinni <> tnkinni or lrCurRec.default_ <> tndefault_ then 
	update aasta set 
		rekvid = tnrekvid,
		aasta = tnaasta,
		kuu = tnkuu,
		kinni = tnkinni,
		default_ = tndefault_
	where id = tnId;
	end if;
	lnaastaId := tnId;
end if;

         return  lnaastaId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_aasta(integer, integer, integer, integer, integer, integer) TO dbpeakasutaja;
