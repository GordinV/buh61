-- Function: gen_lausend_mk(integer)

-- DROP FUNCTION gen_lausend_mk(integer);

CREATE OR REPLACE FUNCTION gen_lausend_mk(integer)
  RETURNS integer AS
$BODY$
declare 	tnId alias for $1;	
		lnJournalNumber int4;	
		lcDbKonto varchar(20);	
		lcKrKonto varchar(20);	
		lcDbTp varchar(20);	
		lcKrTp varchar(20);	
		lnAsutusId int4;	
		lnJournalId int4;	
		lnJournal1Id int4;	
		v_mk mk%rowtype;	
		v_mk1 record;	
		v_dokprop dokprop%rowtype;	
		v_aa aa%rowtype;
		lnUserId int;
		lcDok varchar;
begin
	select * into v_mk from mk where id = tnId;	

	If v_mk.doklausid = 0 then		
		Return 0;	
	End if;
	select * into v_dokprop from dokprop where id = v_mk.doklausid;	
	
	If not found Or v_dokprop.registr = 0 then		
		Return 0;	
	End if;	

	select * into v_aa from aa where id = v_mk.aaId;		

	for v_mk1 in select mk1.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
		from mk1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = mk1.id and dokvaluuta1.dokliik = 4) 
		where parentid = v_mk.Id
	loop		

		If v_mk1.journalid > 0 then			
			Select number into lnJournalNumber from journalid where journalid = v_mk1.journalId;			
			update mk1 set journalId = 0 where id = v_mk1.id;
			v_mk1.journalId := sp_del_journal(v_mk1.journalid,1);		
		End if;		

		If v_mk.opt = 0 then			
			-- kreedit pank			
			lcDbKonto := v_mk1.konto;			
			lcKrKonto := v_aa.konto;			
			lcKrTp := v_aa.tp;			
			lcDbTp := v_mk1.tp;			
			lnAsutusId := v_mk1.Asutusid;		
		Else			
			lcKrKonto := v_mk1.konto;			
			lcDbKonto := v_aa.konto;			
			lcDbTp := v_aa.tp;			
			lcKrTp := v_mk1.tp;			
			lnAsutusId := v_mk1.Asutusid;		
		End if;

		if v_mk.arvid > 0 then
			select arv.number into lcDok from arv where id = v_mk.arvId;
		else
			lcDok = v_mk.number;
		end if;
		lcDok = ifnull(lcDok,'');
		select id into lnUserId from userid where userid.rekvid = v_mk.rekvid and userid.kasutaja = CURRENT_USER::varchar;

		lnJournalId:= sp_salvesta_journal(0, v_mk.rekvId, lnUserId, v_mk.kpv, v_mk1.AsutusId, 
			ltrim(rtrim(v_dokprop.selg))+space(1)+ltrim(rtrim(v_mk.selg)), lcDok,'AUTOMATSELT LAUSEND (GEN_LAUSEND_MK)',v_mk.id) ;


		if lnJournalId = 0 then
			return 0;
		end if;

		lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_mk1.summa,''::varchar,''::text,
				v_mk1.kood1,v_mk1.kood2,v_mk1.kood3,v_mk1.kood4,v_mk1.kood5,
					lcDbKonto,lcDbTp,lcKrKonto,lcKrTp,v_mk1.valuuta,v_mk1.kuurs,v_mk1.summa*v_mk1.kuurs,
					v_mk1.tunnus,v_mk1.proj);

		update mk1 set journalId = lnJournalId where id = v_mk1.id;		

		if v_mk1.journalid > 0 then		
			update journalid set number = lnJournalNumber where journalid = lnJournalId;		
		end if;

		if v_mk.arvid > 0 then
		    update arvtasu set journalid = lnJournalId
			   where arvtasu.arvid = v_mk.arvId
			   and sorderId = v_mk.id;
		end if;

	End loop;
	return lnJournalId;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_mk(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_mk(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_mk(integer) TO dbpeakasutaja;
