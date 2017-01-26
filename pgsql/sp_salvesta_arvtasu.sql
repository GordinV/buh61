
CREATE OR REPLACE FUNCTION sp_salvesta_arvtasu(integer, integer, integer, date, numeric, character, integer, integer, integer, integer, text, integer, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnarvid alias for $3;
	tdkpv alias for $4;
	tnsumma alias for $5;
	tcdok alias for $6;
	tnnomid alias for $7;
	tnpankkassa alias for $8;
	tnjournalid alias for $9;
	tnsorderid alias for $10;
	ttmuud alias for $11;
	tndoklausid alias for $12;
	tcValuuta alias for $13;
	tnKuurs alias for $14;
	lnarvtasuId int;
	lnId int; 
	lrCurRec record;

	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into arvtasu (rekvid,arvid,kpv,summa,dok,nomid,pankkassa,journalid,sorderid,muud,doklausid) 
		values (tnrekvid,tnarvid,tdkpv,tnsumma,tcdok,tnnomid,tnpankkassa,tnjournalid,tnsorderid,ttmuud,tndoklausid);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnarvtasuId:= cast(CURRVAL('public.arvtasu_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnarvtasuId = 0;
	end if;

	if lnarvtasuId= 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (21, lnarvtasuId ,tcValuuta, tnKuurs);



else
	-- muuda 
	select * into lrCurRec from arvtasu where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or lrCurRec.arvid <> tnarvid or lrCurRec.kpv <> tdkpv or lrCurRec.summa <> tnsumma or lrCurRec.dok <> tcdok or lrCurRec.nomid <> tnnomid or lrCurRec.pankkassa <> tnpankkassa or lrCurRec.journalid <> tnjournalid or lrCurRec.sorderid <> tnsorderid or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.doklausid <> tndoklausid then 
	update arvtasu set 
		rekvid = tnrekvid,
		arvid = tnarvid,
		kpv = tdkpv,
		summa = tnsumma,
		dok = tcdok,
		nomid = tnnomid,
		pankkassa = tnpankkassa,
		journalid = tnjournalid,
		sorderid = tnsorderid,
		muud = ttmuud,
		doklausid = tndoklausid
	where id = tnId;
	end if;
	lnarvtasuId := tnId;
end if;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 21 and dokid = lnarvtasuId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (21, lnjournal1Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 21 and dokid = lnarvtasuId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;
	
	if lnArvTasuId > 0 then
		PERFORM sp_updateArvJaak(tnArvId, tdKpv);
	end if;		
         return  lnarvtasuId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_salvesta_arvtasu(integer, integer, integer, date, numeric, character, integer, integer, integer, integer, text, integer,character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_arvtasu(integer, integer, integer, date, numeric, character, integer, integer, integer, integer, text, integer,character varying, numeric) TO dbpeakasutaja;
