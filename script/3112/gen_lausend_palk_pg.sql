-- Function: public.gen_lausend_mahakandmine(int4)

-- DROP FUNCTION public.gen_lausend_mahakandmine(int4);

CREATE OR REPLACE FUNCTION public.gen_lausend_palk(int4)
  RETURNS int4 AS
'
declare 
	If v_palk_oper.journalid > 0 then
	select * into v_aa from aa where parentid = v_pv_oper.rekvId;	
	if v_palk_lib.liik = 2 then 
	if  v_palk_lib.liik = 4 then
	if v_palk_lib.liik = 5 then 
	if v_palk_lib.liik = 6 then
	-- tasu
	if v_palk_lib.liik = 7 And v_palk_lib.asutusest = 1 then
	if v_palk_lib.liik = 7 And v_palk_lib.asutusest = 0  then
	if v_palk_lib.liik = 8 then
	select lastnum into lnJournalId from dbase where alias = ''JOURNAL'';
	if v_palk_oper.journalId > 0 then
	return lnJournalId;
'
  LANGUAGE 'plpgsql' VOLATILE;