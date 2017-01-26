-- Function: sp_salvesta_korder1(integer, integer, integer, integer, integer, integer, integer, character, date, integer, text, text, text, text, numeric, text, integer, integer, integer)

-- DROP FUNCTION sp_salvesta_korder1(integer, integer, integer, integer, integer, integer, integer, character, date, integer, text, text, text, text, numeric, text, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_salvesta_korder1(integer, integer, integer, integer, integer, integer, integer, character, date, integer, text, text, text, text, numeric, text, integer, integer, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnuserid alias for $3;
	tnjournalid alias for $4;
	tnkassaid alias for $5;
	tntyyp alias for $6;
	tndoklausid alias for $7;
	tcnumber alias for $8;
	tdkpv alias for $9;
	tnasutusid alias for $10;
	ttnimi alias for $11;
	ttaadress alias for $12;
	ttdokument alias for $13;
	ttalus alias for $14;
	tnsumma alias for $15;
	ttmuud alias for $16;
	tnarvid alias for $17;
	tndoktyyp alias for $18;
	tndokid alias for $19;
	lnkorder1Id int;
	lnId int; 
	lrCurRec record;
begin

if tnId = 0 then
	-- uus kiri
	insert into korder1 (rekvid,userid,journalid,kassaid,tyyp,doklausid,number,kpv,asutusid,nimi,aadress,dokument,alus,summa,muud,arvid,doktyyp,dokid) 
		values (tnrekvid,tnuserid,tnjournalid,tnkassaid,tntyyp,tndoklausid,tcnumber,tdkpv,tnasutusid,ttnimi,ttaadress,ttdokument,ttalus,tnsumma,ttmuud,tnarvid,tndoktyyp,tndokid);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnkorder1Id:= cast(CURRVAL('public.korder1_id_seq') as int4);
	else
		lnkorder1Id = 0;
	end if;

	if lnkorder1Id = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

else
	-- muuda 
	select * into lrCurRec from korder1 where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or lrCurRec.userid <> tnuserid or lrCurRec.journalid <> tnjournalid or lrCurRec.kassaid <> tnkassaid or lrCurRec.tyyp <> tntyyp or lrCurRec.doklausid <> tndoklausid or lrCurRec.number <> tcnumber or lrCurRec.kpv <> tdkpv or lrCurRec.asutusid <> tnasutusid or lrCurRec.nimi <> ttnimi or lrCurRec.aadress <> ttaadress or lrCurRec.dokument <> ttdokument or lrCurRec.alus <> ttalus or lrCurRec.summa <> tnsumma or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.arvid <> tnarvid or lrCurRec.doktyyp <> tndoktyyp or lrCurRec.dokid <> tndokid then 
	update korder1 set 
		rekvid = tnrekvid,
		userid = tnuserid,
		journalid = tnjournalid,
		kassaid = tnkassaid,
		tyyp = tntyyp,
		doklausid = tndoklausid,
		number = tcnumber,
		kpv = tdkpv,
		asutusid = tnasutusid,
		nimi = ttnimi,
		aadress = ttaadress,
		dokument = ttdokument,
		alus = ttalus,
		summa = tnsumma,
		muud = ttmuud,
		arvid = tnarvid,
		doktyyp = tndoktyyp,
		dokid = tndokid
	where id = tnId;
	end if;
	lnkorder1Id := tnId;
end if;

         return  lnkorder1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_korder1(integer, integer, integer, integer, integer, integer, integer, character, date, integer, text, text, text, text, numeric, text, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_korder1(integer, integer, integer, integer, integer, integer, integer, character, date, integer, text, text, text, text, numeric, text, integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_korder1(integer, integer, integer, integer, integer, integer, integer, character, date, integer, text, text, text, text, numeric, text, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_korder1(integer, integer, integer, integer, integer, integer, integer, character, date, integer, text, text, text, text, numeric, text, integer, integer, integer) TO dbpeakasutaja;
