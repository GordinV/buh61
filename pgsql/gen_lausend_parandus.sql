-- Function: gen_lausend_parandus(integer)

-- DROP FUNCTION gen_lausend_parandus(integer);


/*
select GEN_LAUSEND_PAIGUTUS(        50)
select GEN_LAUSEND_PARANDUS(        49)



select * from pv_oper where id in (49,50)

select * from library order by id desc limit 10
select * from pv_kaart where parentid = 439
select * from pv_oper where parentid = 439


*/
CREATE OR REPLACE FUNCTION gen_lausend_parandus(integer)
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
	lnUsrId int;
	lnJournalId int4;
	lnJournal1Id int4;
	v_pv_oper record;
	v_pv_kaart record;
	v_dokprop dokprop%rowtype;
	v_aa aa%rowtype;

	lnKontrol int;
	lcAllikas varchar(20);
	lcviga varchar;
	lcDok varchar;

begin
	select pv_oper.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta into v_pv_oper 
		from pv_oper left outer join dokvaluuta1 on (pv_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 13)
		where pv_oper.id = tnId;

	If v_pv_oper.doklausid = 0 then
		raise notice 'Konteerimine ei ole vajalik, dok tyyp ei ole defineeritud';
		Return 0;

	End if;

	select * into v_dokprop from dokprop where id = v_pv_oper.doklausid;

	If not Found Or v_dokprop.registr = 0 then
		raise notice 'Konteerimine ei ole vajalik';
		Return 0;

	End if;

	select library.rekvid, library.kood,pv_kaart.* into v_pv_kaart 
		from library inner join pv_kaart on pv_kaart.parentid = library.id 
		where pv_kaart.parentid = v_pv_oper.parentId;

	lcDok := 'Inv.number '+IFNULL(v_pv_kaart.kood,SPACE(1));	

	select recalc into lnKontrol from rekv where id = v_pv_kaart.rekvid;
	lcAllikas = 'LE-P';


	If v_pv_oper.journalid > 0 then
		select number into lnJournalNumber from journalId where journalId = v_pv_oper.journalId;

		update pv_oper set journalid = 0 where pv_oper.id = v_pv_oper.id;
		perform sp_del_journal(v_pv_oper.journalid::int4,1::int4);
	End if;

	select * into v_aa from aa where parentid = v_pv_kaart.rekvId;	
	lcDbKonto := v_pv_kaart.konto;
	lcKrKonto := v_pv_oper.konto;
	lcDbTp := ifnull(v_aa.tp,space(1));
	lckrTp := v_pv_oper.tp;
	lnAsutusId = v_pv_oper.Asutusid;


	SELECT id INTO lnUsrID from userid WHERE kasutaja = CURRENT_USER::VARCHAR;

	lnJournalId:= sp_salvesta_journal(0, v_pv_kaart.rekvId, lnUsrID, v_pv_oper.kpv, lnAsutusId, 
		ltrim(rtrim(v_dokprop.selg)), lcDok,'AUTOMATSELT LAUSEND (GEN_LAUSEND_PARANDUS)',v_pv_oper.id) ;

	if lnJournalId = 0 then
		return 0;
	end if; 	

	if not empty(v_pv_oper.kood2) then
		lcAllikas = v_pv_oper.kood2;
	end if;

		if ifnull(lnKontrol,0) = 1 then
			lcViga = sp_lausendikontrol(lcDbKonto, lcKrKonto, lcDbTp,lcKrTp, v_pv_oper.kood1, lcAllikas, v_pv_oper.kood5, v_pv_oper.kood3, v_pv_oper.kpv);
			if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
				raise exception ':%',lcViga;
			end if;
		end if;

	lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_pv_oper.Summa,''::varchar,''::text,
				v_pv_oper.kood1,v_pv_oper.kood2,v_pv_oper.kood3,v_pv_oper.kood4,v_pv_oper.kood5,
				lcDbKonto,lcDbTp,lcKrKonto,lcKrTp,v_pv_oper.valuuta,v_pv_oper.kuurs,v_pv_oper.summa*v_pv_oper.kuurs,
				v_pv_oper.tunnus,v_pv_oper.proj);

	update pv_oper set journalId = lnJournalId where id = v_pv_oper.id;


	if v_pv_oper.journalid > 0 and ifnull(lnJournalNumber,0) > 0 then
		update journalid set number = lnJournalNumber where journalid = lnJournalId;
	end if;


	return lnJournalId;
end; 



$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_parandus(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_parandus(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_parandus(integer) TO dbpeakasutaja;
