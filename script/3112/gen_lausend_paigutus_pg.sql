-- Function: public.gen_lausend_mahakandmine(int4)

-- DROP FUNCTION public.gen_lausend_mahakandmine(int4);

CREATE OR REPLACE FUNCTION public.gen_lausend_paigutus(int4)
  RETURNS int4 AS
'
declare 
	End if;
	If v_pv_oper.journalid > 0 then
	select * into v_aa from aa where parentid = v_pv_oper.rekvId;	
	lcDbKonto := v_pv_kaart.konto;
	Insert Into journal (rekvid, Userid, kpv, Asutusid, selg, muud) Values 
	select lastnum into lnJournalId from dbase where alias = ''JOURNAL'';
	if v_pv_oper.journalid > 0 then
	return lnJournalId;
'
  LANGUAGE 'plpgsql' VOLATILE;