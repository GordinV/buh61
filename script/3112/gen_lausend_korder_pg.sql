-- Function: public.gen_lausend_mahakandmine(int4)

-- DROP FUNCTION public.gen_lausend_mahakandmine(int4);

CREATE OR REPLACE FUNCTION public.gen_lausend_korder(int4)
  RETURNS int4 AS
'
declare 
	lcKbmTp varchar(20);
begin
	select * into v_korder1 from korder1 where id = tnId;
	If v_korder1.doklausid = 0 then
		Return 0;
	End if;
	select * into v_dokprop from dokprop where id = v_korder1.doklausid;
	If not Found Or v_dokprop.registr = 0 then;
		Return 0;
	End if;
	If v_korder1.journalid > 0 then
	Insert Into journal (rekvid, Userid, kpv, Asutusid, selg, muud) Values 
	select lastnum into lnJournalId from dbase where alias = ''JOURNAL'';
	for v_korder2 in select * from korder2 where parentid = v_korder1.Id;
	loop
		If korder1.tyyp = 1 then
			-- sisetulik
			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
				kood3, kood4, kood5, tunnus) Values 
				(lnJournalId, v_korder2.Summa, v_aa.konto, v_korder2.konto, v_aa.tp, v_korder2.tp,v_korder2.kood1,
				v_korder2.kood2, v_korder2.kood3, v_korder2.kood4, v_korder2.kood5, v_korder2.tunnus );
		Else
			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
				kood3, kood4, kood5, tunnus) Values 
				(lnJournalId, v_korder2.Summa, v_korder2.konto,  v_aa.konto, v_korder2.tp, v_aa.tp, v_korder2.kood1,
				v_korder2.kood2, v_korder2.kood3, v_korder2.kood4, v_korder2.kood5 );
		End if;
	End loop;

	update korder1 set journalId = lnJournalId where id = v_korder1.id;

	return lnJournalId;
'
  LANGUAGE 'plpgsql' VOLATILE;