-- Function: public.gen_lausend_mahakandmine(int4)

-- DROP FUNCTION public.gen_lausend_mahakandmine(int4);

CREATE OR REPLACE FUNCTION public.gen_lausend_PARANDUS(int4)
  RETURNS int4 AS
'
declare 
	If v_pv_oper.journalid > 0 then
	select lastnum into lnJournalId from dbase where alias = ''JOURNAL'';
	if v_pv_oper.journalid > 0 then
	return lnJournalId;
'
  LANGUAGE 'plpgsql' VOLATILE;