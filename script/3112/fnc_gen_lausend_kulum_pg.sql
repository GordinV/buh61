-- Function: public.gen_lausend_mahakandmine(int4)

-- DROP FUNCTION public.gen_lausend_mahakandmine(int4);

CREATE OR REPLACE FUNCTION public.gen_lausend_kulum(int4)
  RETURNS int4 AS
'
declare 
begin
	select * into v_pv_oper from pv_oper where id = tnId;
	select * into v_pv_kaart from pv_kaart where id = v_pv_oper.parentId;
	If v_pv_oper.doklausid = 0 then
		Return 0;
	End if;
	select * into v_dokprop from dokprop where id = v_pv_oper.doklausid;
	If not Found Or v_dokprop.registr = 0 then;
		Return 0;
	End if;
	If v_pv_oper.journalid > 0 then
	select * into v_aa from aa where parentid = v_pv_oper.rekvId;	
	select lastnum into lnJournalId from dbase where alias = \'JOURNAL\';
	if v_pv_oper.journalid > 0 then
	update pv_oper set journalId = lnJournalId where id = v_pv_oper.id;
	return lnJournalId;
'
  LANGUAGE 'plpgsql' VOLATILE;