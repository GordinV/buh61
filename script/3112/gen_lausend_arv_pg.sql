-- Function: public.gen_lausend_arv(int4)

-- DROP FUNCTION public.gen_lausend_arv(int4);

CREATE OR REPLACE FUNCTION public.gen_lausend_arv(int4)
  RETURNS int4 AS
'
declare 
	lnJournalNumber int4;
	lcKbmTp varchar(20);
begin
	select * into v_arv from arv where id = tnId;
	If v_arv.doklausid = 0 then
		Return 0;
	End if;
	select * into v_dokprop from dokprop where id = v_arv.doklausid;
	If not Found Or dokprop.registr = 0 then
		Return 0;
	End if;
	If v_arv.journalid > 0 then

	Insert Into journal (rekvid, Userid, kpv, Asutusid, selg, muud) Values 


	for v_arv1 in select * from arv1 where parentid = v_arv.Id
	If v_arv.kbm <> 0 then
		Else
			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
				kood3, kood4, kood5) Values 
				(lnJournalId, v_arv.kbm, v_dokprop.kbmkonto,  v_dokprop.konto, lcKbmTp, v_aa.tp, v_dokprop.kood1,
				v_dokprop.kood2, v_dokprop.kood3, v_dokprop.kood4, v_dokprop.kood5 );
		End if;
	End if;

	update arv set journalId = lnJournalId where id = v_arv.id;
	return lnJournalId;
'
  LANGUAGE 'plpgsql' VOLATILE;