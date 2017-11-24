-- Function: public.gen_lausend_mk(int4)

-- DROP FUNCTION public.gen_lausend_mk(int4);

CREATE OR REPLACE FUNCTION public.gen_lausend_mk(int4)
  RETURNS int4 AS
'
declare 	tnId alias $1;	lnJournalNumber int4;	lcDbKonto varchar(20);	lcKrKonto varchar(20);	lcDbTp varchar(20);	lcKrTp varchar(20);	lnAsutusId int4;	lnJournalId int4;	v_mk mk@rowtype;	v_mk1 mk1@rowtype;	v_dokprop dokprop@rowtype;	v_aa aa@rowtype;
begin
	select * into v_mk from mk where id = tnId;	If v_mk.doklausid = 0 then		Return 0;	End if;
	select * into v_dokprop from dokprop where id = v_mk.doklausid;	If not found Or v_dokprop.registr = 0 then		Return 0;	End if;	select * into v_aa from aa where id = v_mk.aaId;		for v_mk1 in select * from mk1 where parentid = v_mk.Id		If v_mk1.journalid > 0 then			Select number into lnJournalNumber from journalid where journalid = v_mk1.journalId;			If sp_del_journal(v_mk1.journalid::int4,1::int4) = 0 then
				Return 0;
			End if;		End if;		If v_mk.opt = 0 then			-- kreedit pank			lcDbKonto := v_mk1.konto;			lcKrKonto := v_aa.konto;			lcKrTp := v_aa.tp;			lcDbTp := v_mk1.tp;			lnAsutusId := v_mk1.Asutusid;		Else			lcKrKonto := v_mk1.konto;			lcDbKonto := v_aa.konto;			lcDbTp := v_aa.tp;			lcKrTp := v_mk1.tp;			lnAsutusId := v_mk1.Asutusid;		End if;
		Insert Into journal (rekvid, Userid, kpv, Asutusid, selg, muud) Values 			(v_mk.rekvId, 0, v_mk.kpv, lnAsutusId, v_dokprop.selg, ''AUTOMATSELT LAUSEND (GEN_LAUSEND_MK)'' );		select lastnum into lnJournalId from dbase where alias = ''JOURNAL'';
		Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, kood3, kood4, kood5, TUNNUS) Values 
			(lnJournalId, v_mk1.Summa, lcDbKonto, lcKrKonto, lcDbTp,lcKrTp,v_mk1.kood1,
			v_mk1.kood2, v_mk1.kood3, v_mk1.kood4, v_mk1.kood5, v_mk1.tunnus );
		update mk1 set journalId = lnJournalId where id = v_mk.id;		if v_mk1.journalid > 0 then		
			update journalid set number = lnJournalNumber where journalid = lnJournalId;		end if;
	End loop;
	return lnJournalId;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
