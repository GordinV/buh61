-- Function: public.gen_lausend_mahakandmine(int4)

-- DROP FUNCTION public.gen_lausend_mahakandmine(int4);

CREATE OR REPLACE FUNCTION public.gen_lausend_PARANDUS(int4)
  RETURNS int4 AS
'
declare 	tnId alias $1;	lnJournalNumber int4;	lcDbKonto varchar(20);	lcKrKonto varchar(20);	lcDbTp varchar(20);	lcKrTp varchar(20);	lnAsutusId int4;	lnJournalId int4;	v_pv_oper pv_oper@rowtype;	v_pv_kaart pv_kaart@rowtype;	v_dokprop dokprop@rowtype;	v_aa aa@rowtype;begin	select * into v_pv_oper from pv_oper where id = tnId;	select * into v_pv_kaart from pv_kaart where id = v_pv_oper.parentId;	If v_pv_oper.doklausid = 0 then		Return 0;	End if;	select * into v_dokprop from dokprop where id = v_pv_oper.doklausid;	If not Found Or v_dokprop.registr = 0 then;		Return 0;	End if;
	If v_pv_oper.journalid > 0 then		select number into lnJournalNumber from journalId where journalId = v_pv_oper.journalId;		if sp_del_journal(v_pv_oper.journalid::int4,1::int4) = 0 then			Return 0;		End if;	End if;	select * into v_aa from aa where parentid = v_pv_oper.rekvId;		lcDbKonto := v_pv_kaart.konto;	lcKrKonto := v_pv_oper.konto;	lcDbTp := v_aa.tp;	lckrTp := v_pv_oper.tp;	lnAsutusId = v_pv_oper.Asutusid;	Insert Into journal (rekvid, Userid, kpv, Asutusid, selg, muud) Values 	(v_pv_oper.rekvId, 0, v_pv_oper.kpv, lnAsutusId, v_dokprop.selg, ''AUTOMATSELT LAUSEND (GEN_LAUSEND_PARANDUS)'' );
	select lastnum into lnJournalId from dbase where alias = ''JOURNAL'';	Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 		kood3, kood4, kood5, tunnus) Values 		(v_journal.Id, v_pv_oper.Summa, lcDbKonto, lcKrKonto, lcDbTp,lcKrTp,v_pv_oper.kood1,		v_pv_oper.kood2, v_pv_oper.kood3, v_pv_oper.kood4, v_pv_oper.kood5, v_pv_oper.tunnus );	update pv_oper set journalId = lnJournalId where id = v_pv_oper.id;
	if v_pv_oper.journalid > 0 then		update journalid set number = lnJournalNumber where journalid = lnJournalId;	end if;
	return lnJournalId;end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
