-- Function: sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer)

-- DROP FUNCTION sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer);

CREATE OR REPLACE FUNCTION sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer, character)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnuserid alias for $3;
	tdkpv alias for $4;
	tnasutusid alias for $5;
	ttselg alias for $6;
	tcdok alias for $7;
	ttmuud alias for $8;
	tndokid alias for $9;
	tcObjekt alias for $10;
	lnjournalId int;
	lnId int; 
	lrCurRec record;
begin

if (fnc_aasta_kontrol(tnrekvid, tdkpv)= 0) then
	raise exception 'Perion on kinnitatud';
	return 0;
end if;


if tnId = 0 then
	-- uus kiri
	insert into journal (rekvid,userid,kpv,asutusid,selg,dok,muud,dokid, objekt) 
		values (tnrekvid,tnuserid,tdkpv,tnasutusid,ttselg+' ',tcdok,ttmuud,tndokid,ifnull(tcObjekt,space(20)) );


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnjournalId:= cast(CURRVAL('public.journal_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnjournalId = 0;
	end if;

	if lnjournalId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;


--	lnjournalId:= cast(CURRVAL('public.journal_id_seq') as int4);

else
	-- muuda 
	select * into lrCurRec from journal where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or lrCurRec.userid <> tnuserid or lrCurRec.kpv <> tdkpv or lrCurRec.asutusid <> tnasutusid 
		or lrCurRec.selg <> ttselg or lrCurRec.dok <> tcdok or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) 
		or lrCurRec.dokid <> tndokid or lrCurRec.objekt <> tcObjekt then 
	update journal set 
		rekvid = tnrekvid,
		userid = tnuserid,
		kpv = tdkpv,
		asutusid = tnasutusid,
		selg = ttselg,
		dok = tcdok,
		objekt = tcObjekt,
		muud = ttmuud,
		dokid = tndokid
	where id = tnId;
	end if;
	lnjournalId := tnId;
end if;



         return  lnjournalId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer, character) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer, character) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer, character) TO dbpeakasutaja;



