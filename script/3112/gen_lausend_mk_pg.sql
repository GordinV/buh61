-- Function: public.gen_lausend_mk(int4)

-- DROP FUNCTION public.gen_lausend_mk(int4);

CREATE OR REPLACE FUNCTION public.gen_lausend_mk(int4)
  RETURNS int4 AS
'
declare 
begin
	select * into v_mk from mk where id = tnId;
	select * into v_dokprop from dokprop where id = v_mk.doklausid;
				Return 0;
			End if;
		Insert Into journal (rekvid, Userid, kpv, Asutusid, selg, muud) Values 
		Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, kood3, kood4, kood5, TUNNUS) Values 
			(lnJournalId, v_mk1.Summa, lcDbKonto, lcKrKonto, lcDbTp,lcKrTp,v_mk1.kood1,
			v_mk1.kood2, v_mk1.kood3, v_mk1.kood4, v_mk1.kood5, v_mk1.tunnus );
		update mk1 set journalId = lnJournalId where id = v_mk.id;
			update journalid set number = lnJournalNumber where journalid = lnJournalId;
	End loop;
	return lnJournalId;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;