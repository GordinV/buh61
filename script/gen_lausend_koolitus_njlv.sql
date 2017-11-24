-- Function: gen_lausend_koolitus(integer)

-- DROP FUNCTION gen_lausend_koolitus(integer);

CREATE OR REPLACE FUNCTION gen_lausend_koolitus(integer)
  RETURNS integer AS
$BODY$


declare 
	tnId alias for $1;
	lnJournalNumber int4;
	lcDbKonto varchar(20);
	lcKrKonto varchar(20);
	lcDbTp varchar(20);
	lcKrTp varchar(20);
	lnAsutusId int4;
	lnJournalId int4;
	lcKbmTp varchar(20);
	v_vanemtasu3 record;
	v_dokprop dokprop%rowtype;
	v_vanemtasu4 record;
	v_asutus asutus%rowtype;
	lnUserId int;
	v_aa record;


begin
	lcDbTp := '800699';
	lcKrTp := '800699';

	select * into v_vanemtasu3 from vanemtasu3 where id = tnId;


	If v_vanemtasu3.dokpropid = 0 then


		Return 0;


	End if;


	select * into v_dokprop from dokprop where id = v_vanemtasu3.dokpropid limit 1;


	If not Found Or v_dokprop.registr = 0 then


		Return 0;


	End if;





	If v_vanemtasu3.journalid > 0 then
		select number into lnJournalNumber from journalId where journalId = v_vanemtasu3.journalId;


		if sp_del_journal(v_vanemtasu3.journalid,1) = 0 then
			Return 0;


		End if;


	End if;




	select * into v_aa from aa where parentid = v_vanemtasu3.rekvId limit 1;	

	select * into v_asutus from asutus where id = v_dokprop.asutusId;


	-- otsime vanemtasu asutused

	lnAsutusId = 0;

	select id into lnAsutusId from asutus where regkood = v_vanemtasu3.tunnus;

	Insert Into journal (rekvid, Userid, kpv, Asutusid, selg, muud) Values 
		(v_vanemtasu3.rekvId, v_vanemtasu3.UserId, v_vanemtasu3.kpv, ifnull(lnAsutusId1,0), v_dokprop.selg, 'AUTOMATSELT LAUSEND (GEN_LAUSEND_KOOLITUS)' );

	lnJournalId:= cast(CURRVAL('public.journal_id_seq') as int4);

	for v_vanemtasu4 in 
		select sum(summa) as summa, konto, kood1, kood2, kood3, kood4, kood5  
			from vanemtasu4 
			where parentid = v_vanemtasu3.Id 
			group by konto, kood1, kood2, kood3, kood4, kood5
	loop
		if v_vanemtasu3.opt = 1 then
			-- kassa
			if left(v_vanemtasu3.konto,6) = '100100' then
				-- pank
				lcDbTp:= ifnull(v_asutus.tp,v_aa.tp) ;
			end if;
			if left(v_vanemtasu3.konto,6) = '100000' then
			-- kassa
				lcDbTp:= space(1);
			end if;
			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2,kood3, kood4, kood5, tunnus) Values 
				(lnJournalId, v_vanemtasu4.summa, v_vanemtasu3.konto, v_vanemtasu4.konto, lcDbtp, '800699', v_vanemtasu4.kood1,
				v_vanemtasu4.kood2, v_vanemtasu4.kood3, v_vanemtasu4.kood4, v_vanemtasu4.kood5, v_vanemtasu3.tunnus );
		else
			-- fakt
			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, kood3, kood4, kood5, tunnus) Values 
				(lnJournalId, v_vanemtasu4.summa, v_vanemtasu3.konto, v_vanemtasu4.konto,'800699' , '800699', v_vanemtasu4.kood1,
				v_vanemtasu4.kood2, v_vanemtasu4.kood3, v_vanemtasu4.kood4, v_vanemtasu4.kood5, v_vanemtasu3.tunnus );
		end if;

	End loop;
	

	If v_vanemtasu3.journalid > 0 then

		update journalid set number = lnJournalNumber where journalid = lnJournalId;

	end if;


	update vanemtasu3 set journalid = lnJournalId where id = tnid;


	return lnJournalId;
end;


$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
GRANT EXECUTE ON FUNCTION gen_lausend_koolitus(integer) TO GROUP dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_koolitus(integer) TO GROUP dbpeakasutaja;



/*

select * from asutus where nimetus = ' vm-lasteaed '
*/
