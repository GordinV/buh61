-- Function: gen_lausend_avans(integer)

-- DROP FUNCTION gen_lausend_avans(integer);

/*
select GEN_LAUSEND_AVANS(     13972)
*/

CREATE OR REPLACE FUNCTION gen_lausend_avans(integer)
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
	lnJournal1Id int4;

	lcKbmTp varchar(20);
	v_avans1 avans1%rowtype;
	v_avans2 record;
	v_dokprop dokprop%rowtype;
	v_asutus asutus%rowtype;
	lnUserId int;
	lnRecCount int;

	lcViga varchar(254);
	lnKontrol int;

begin


	select * into v_avans1 from avans1 where id = tnId;

	select * into v_asutus from asutus where id = v_avans1.asutusId;

--	select recalc into lnKontrol from rekv where id = v_avans1.rekvid;


	If v_avans1.dokpropid = 0 then


		Return 0;


	End if;


	select * into v_dokprop from dokprop where id = v_avans1.dokpropid limit 1;


	If not Found Or v_dokprop.registr = 0 then


		Return 0;


	End if;



	If v_avans1.journalid > 0 then
		update avans1 set journalId = 0 where id = v_avans1.id;

		select number into lnJournalNumber from journalId where journalId = v_avans1.journalId;
		if sp_del_journal(v_avans1.journalid,1) = 0 then
			Return 0;
		End if;
	End if;


	select id into lnUserId from userid where userid.rekvid = v_avans1.rekvid and userid.kasutaja = CURRENT_USER::varchar;

	lnJournalId:= sp_salvesta_journal(0, v_avans1.rekvId, lnUserId, v_avans1.kpv, v_avans1.AsutusId, 
		ltrim(rtrim(v_dokprop.selg)), v_avans1.number,'AUTOMATSELT LAUSEND (GEN_LAUSEND_AVANS)',v_avans1.id) ;


	if lnJournalId = 0 then
		return 0;
	end if;
	
	for v_avans2 in select avans2.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
		from avans2 left outer join dokvaluuta1 on (dokvaluuta1.dokid = avans2.id and dokvaluuta1.dokliik = 5) 
		where parentid = v_avans1.Id
	loop
		lcDbTp := v_asutus.tp;
		lcKrTp := v_asutus.tp;

		if left(ltrim(rtrim(v_avans2.konto)),3) = '601' then
			lcDbTp := '014003';
		end if;

		lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_avans2.summa,''::varchar,''::text,
				v_avans2.kood1,v_avans2.kood2,v_avans2.kood3,v_avans2.kood4,v_avans2.kood5,
					v_avans2.konto,lcDbTp,v_dokprop.konto,lcKrTp,v_avans2.valuuta,v_avans2.kuurs,v_avans2.summa*v_avans2.kuurs,
					v_avans2.tunnus,v_avans2.proj);


		
	End loop;

	update avans1 set journalId = lnJournalId where id = v_avans1.id;


	return lnJournalId;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_avans(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_avans(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_avans(integer) TO dbpeakasutaja;
