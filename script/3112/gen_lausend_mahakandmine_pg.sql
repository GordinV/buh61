-- Function: public.gen_lausend_mahakandmine(int4)

-- DROP FUNCTION public.gen_lausend_mahakandmine(int4);

CREATE OR REPLACE FUNCTION public.gen_lausend_mahakandmine(int4)
  RETURNS int4 AS
'
declare 
begin
	select * into v_pv_oper from pv_oper where id = tnId;
		select number into lnJournalNumber from journalId where journalId = v_pv_oper.journalId;
		if sp_del_journal(v_pv_oper.journalid,1) = 0 then
			Return 0;
		End if;
	End if;
	select * into v_aa from aa where parentid = v_pv_oper.rekvId;	
	lcDbTp := v_pv_oper.tp;
	Insert Into journal (rekvid, Userid, kpv, Asutusid, selg, muud) Values 
	select lastnum into lnJournalId from dbase where alias = \'JOURNAL\';
	Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
	update pv_oper set journalId = lnJournalId where id = v_pv_oper.id;
	if v_pv_oper.journalId > 0 then;
		update journalid set number = lnJournalNumber where journalid = lnJournalId;
	return lnJournalId;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;