-- Function: gen_lausend_korder(integer)

-- DROP FUNCTION gen_lausend_korder(integer);

/*
select GEN_LAUSEND_KORDER(        20)


select recalc  from rekv where id = 3;
update rekv set recalc =1  where id = 3


*/

CREATE OR REPLACE FUNCTION gen_lausend_korder(integer)
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
		lcKbmTp varchar(20);	
		v_korder1 korder1%rowtype;	
		v_dokprop dokprop%rowtype;	
		v_aa aa%rowtype;	
		v_korder2 record;

		lnKontrol int;
		lcAllikas varchar(20);
		lcviga varchar;
		lcOmaTp varchar;

begin


	select * into v_korder1 from korder1 where id = tnId;
	If v_korder1.doklausid = 0 then
		Return 0;
	End if;

	select recalc into lnKontrol from rekv where id = v_korder1.rekvid;
	lcAllikas = 'LE-P';


	select * into v_dokprop from dokprop where id = v_korder1.doklausid;
	If not Found Or v_dokprop.registr = 0 then
		Return 0;
	End if;
	If v_korder1.journalid > 0 then
		update korder1 set journalId = 0 where id = v_korder1.id;		
		select number into lnJournalNumber from journalId where journalId = v_korder1.journalId;		
		v_korder1.journalid:= sp_del_journal(v_korder1.journalid,1) ;	
	End if;	
	select * into v_aa from aa where id = v_korder1.kassaId;	

	lnJournalId:= sp_salvesta_journal(0, v_korder1.rekvId, v_korder1.UserId, v_korder1.kpv, v_korder1.AsutusId, 
		ltrim(rtrim(v_dokprop.selg)), v_korder1.number,'AUTOMATSELT LAUSEND (GEN_LAUSEND_KORDER)',v_korder1.id) ;

	for v_korder2 in 
		select korder2.*,ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
			from korder2 left outer join dokvaluuta1 on (korder2.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 11)  where parentid = v_korder1.Id
	loop
		If v_korder1.tyyp = 1 then
			-- sisetulik
			raise notice 'Sise';
			if not empty(v_korder2.kood2) then
				lcAllikas = v_korder2.kood2;
			end if;
			raise notice 'kontorol TPK %',v_korder2.tp;
			raise notice 'lnKontrol %',lnKontrol;
/*
			if ifnull(lnKontrol,0) = 1 then
				raise notice 'kontorol TPK %',v_korder2.tp;

				lcOmaTp = ltrim(rtrim(fnc_getomatp(v_korder1.rekvId,year(v_korder1.Kpv))));		

				lcViga = sp_lausendikontrol( v_aa.konto, v_korder2.konto, v_aa.tp, v_korder2.tp, v_korder2.kood1, lcAllikas::varchar, v_korder2.kood5, v_korder2.kood3, lcOmaTp, v_korder1.kpv);
				if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
					raise exception ':%',lcViga;
				end if;
			end if;
*/
			lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_korder2.Summa,''::varchar,''::text,
				v_korder2.kood1,v_korder2.kood2,v_korder2.kood3,v_korder2.kood4,v_korder2.kood5,
					v_aa.konto,v_aa.tp,v_korder2.konto,v_korder2.tp,v_korder2.valuuta,v_korder2.kuurs,v_korder2.summa*v_korder2.kuurs,
					v_korder2.tunnus,v_korder2.proj);
		
		Else
			-- valjamineku order
			raise notice 'Valja';

			lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_korder2.Summa,''::varchar,''::text,
				v_korder2.kood1,v_korder2.kood2,v_korder2.kood3,v_korder2.kood4,v_korder2.kood5,
				v_korder2.konto,v_korder2.tp,v_aa.konto, v_aa.tp,v_korder2.valuuta,v_korder2.kuurs,v_korder2.summa*v_korder2.kuurs,
				v_korder2.tunnus,v_korder2.proj);


		End if;
	End loop;

	update korder1 set journalId = lnJournalId where id = v_korder1.id;	

	If v_korder1.journalid > 0 and ifnull(lnJournalNumber,0) > 0 then		
		update journalid set number = lnJournalNumber where journalid = lnJournalId;	
	end if;

	return lnJournalId;end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_korder(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_korder(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_korder(integer) TO dbpeakasutaja;
