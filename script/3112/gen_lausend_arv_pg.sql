-- Function: public.gen_lausend_arv(int4)

-- DROP FUNCTION public.gen_lausend_arv(int4);

CREATE OR REPLACE FUNCTION public.gen_lausend_arv(int4)
  RETURNS int4 AS
'
declare 	tnId alias for $1;
	lnJournalNumber int4;	lcDbKonto varchar(20);	lcKrKonto varchar(20);	lcDbTp varchar(20);	lcKrTp varchar(20);	lnAsutusId int4;	lnJournalId int4;
	lcKbmTp varchar(20);	v_arv arv%rowtype;	v_dokprop dokprop%rowtype;	v_aa aa%rowtype;	v_arv1 arv1%rowtype;	v_asutus asutus%rowtype;	lnUserId int;
begin
	select * into v_arv from arv where id = tnId;
	If v_arv.doklausid = 0 then
		Return 0;
	End if;
	select * into v_dokprop from dokprop where id = v_arv.doklausid;
	If not Found Or dokprop.registr = 0 then
		Return 0;
	End if;
	If v_arv.journalid > 0 then		select number into lnJournalNumber from journalId where journalId = v_arv.journalId;		if sp_del_journal(v_arv.journalid,1) = 0 then			Return 0;		End if;	End if;	select * into v_aa from aa where parentid = v_arv.rekvId;		select id into lnUserId from userid where userid.rekvid = v_arv.rekvid and userid.kasutaja = CURRENT_USER::varchar;

	Insert Into journal (rekvid, Userid, kpv, Asutusid, selg, muud) Values 	(v_arv.rekvId, lnUserId, v_arv.kpv, v_arv.AsutusId, v_dokprop.selg, ''AUTOMATSELT LAUSEND (GEN_LAUSEND_ARV)'' );
	lnJournalId:= cast(CURRVAL(''public.journal_id_seq'') as int4);

	for v_arv1 in select * from arv1 where parentid = v_arv.Id	loop		If v_arv.liik = 0 then			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 				kood3, kood4, kood5, tunnus) Values 				(lnJournalId, v_arv1.kbmta, v_dokprop.konto, v_arv1.konto, v_arv1.tp, v_arv1.tp, v_arv1.kood1,				v_arv1.kood2, v_arv1.kood3, v_arv1.kood4, v_arv1.kood5, v_arv1.tunnus );		Else			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 				kood3, kood4, kood5, tunnus) Values 				(lnJournalId, v_arv1.kbmta, v_arv1.konto,  v_dokprop.konto, v_arv1.tp, v_arv1.tp, v_arv1.kood1,				v_arv1.kood2, v_arv1.kood3, v_arv1.kood4, v_arv1.kood5, v_arv1.tunnus );		End if;	End loop;	-- kbm
	If v_arv.kbm <> 0 then		If v_dokprop.Asutusid > 0 then			Select * into v_asutus from asutus where id = v_dokprop.Asutusid;			lcKbmTp := v_asutus.tp;		else				lcKbmTp := space(20);		End if;		If v_arv.liik = 0 then			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 				kood3, kood4, kood5) Values 				(lnJournalId, v_arv.kbm, v_dokprop.konto, v_dokprop.kbmkonto, v_aa.tp,lcKbmTp,v_dokprop.kood1,				v_dokprop.kood2, v_dokprop.kood3, v_dokprop.kood4, v_dokprop.kood5 );
		Else
			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
				kood3, kood4, kood5) Values 
				(lnJournalId, v_arv.kbm, v_dokprop.kbmkonto,  v_dokprop.konto, lcKbmTp, v_aa.tp, v_dokprop.kood1,
				v_dokprop.kood2, v_dokprop.kood3, v_dokprop.kood4, v_dokprop.kood5 );
		End if;
	End if;

	update arv set journalId = lnJournalId where id = v_arv.id;	If v_arv.journalid > 0 then		update journalid set number = lnJournalNumber where journalid = lnJournalId;	end if;
	return lnJournalId;end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
