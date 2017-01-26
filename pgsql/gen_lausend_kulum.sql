-- Function: gen_lausend_kulum(integer)

-- DROP FUNCTION gen_lausend_kulum(integer);

CREATE OR REPLACE FUNCTION gen_lausend_kulum(integer)
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
	v_pv_oper record;
	v_pv_kaart record;
	v_dokprop dokprop%rowtype;
	v_aa aa%rowtype;
	lcDok varchar(100);

	lnKontrol int;
	lcAllikas varchar(20);
	lcviga varchar;
	lnUsrID int;
	lcSelg text;

begin

	select pv_oper.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta into v_pv_oper 
		from pv_oper left outer join dokvaluuta1 on (pv_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 13)
		where pv_oper.id = tnId;
	
	If v_pv_oper.doklausid = 0 then
		raise notice 'Konteerimine ei ole vajalik, dok tyyp ei ole defineeritud';
		Return 0;

	End if;

	select * into v_dokprop from dokprop where dokprop.id = v_pv_oper.doklausid;

	If not Found Or v_dokprop.registr = 0 then
		raise notice 'Konteerimine ei ole vajalik';

		Return 0;

	End if;

	select library.rekvid, library.kood,pv_kaart.* into v_pv_kaart 
		from library inner join pv_kaart on pv_kaart.parentid = library.id 
		where pv_kaart.parentid = v_pv_oper.parentId;

	lcDok := 'Inv.number '+IFNULL(v_pv_kaart.kood,SPACE(1));	

	select recalc into lnKontrol from rekv where  rekv.id = v_pv_kaart.rekvid;
	lcAllikas = 'LE-P';


	If v_pv_oper.journalid > 0 then
		raise notice 'kustutan vana lausend';

		select number into lnJournalNumber from journalId where journalId = v_pv_oper.journalId;
		update pv_oper set journalid = 0 where pv_oper.id = v_pv_oper.id;

		perform sp_del_journal(v_pv_oper.journalid,1); 
	End if;


	select * into v_aa from aa where parentid = v_pv_kaart.rekvId;	
	select kood into lcKrKonto from library where id in (
	select tun2 from library where id = v_pv_kaart.gruppId);

	lcKrKonto := ifnull(lcKrKonto,space(1));
	lcDbKonto := v_pv_oper.konto;
	lcDbTp := space(1);
	lckrTp := space(1);
	lnAsutusId = v_pv_oper.Asutusid;

	SELECT id INTO lnUsrID from userid WHERE kasutaja = CURRENT_USER::VARCHAR;

	lcSelg = ltrim(rtrim(v_dokprop.selg));

	if empty (lcSelg::varchar) then
		lcSelg = 'Kulum';
	end if;

	lnJournalId:= sp_salvesta_journal(0, v_pv_kaart.rekvId, lnUsrID, v_pv_oper.kpv, lnAsutusId, 
		lcSelg, lcDok,'AUTOMATSELT LAUSEND (GEN_LAUSEND_AVANS)',v_pv_oper.id) ;

	if lnJournalId = 0 then
		return 0;
	end if; 	

	raise notice 'Lausend koostatud';


		if not empty(v_pv_oper.kood2) then
				lcAllikas = v_pv_oper.kood2;
		end if;
/*
		if ifnull(lnKontrol,0) = 1 then
			lcViga = sp_lausendikontrol(lcDbKonto, lcKrKonto, lcDbTp,lcKrTp, v_pv_oper.kood1, lcAllikas, v_pv_oper.kood5, '11',v_pv_oper.kpv);
			if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
				raise exception ':%',lcViga;
			end if;
			raise notice 'Kontrol lõppetatud';
		end if;
*/
		lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_pv_oper.Summa,''::varchar,''::text,
				v_pv_oper.kood1,v_pv_oper.kood2,'11',v_pv_oper.kood4,v_pv_oper.kood5,
				lcDbKonto,lcDbTp,lcKrKonto,lcKrTp,v_pv_oper.valuuta,v_pv_oper.kuurs,v_pv_oper.summa*v_pv_oper.kuurs,
				v_pv_oper.tunnus,v_pv_oper.proj);

	if v_pv_oper.journalid > 0 and ifnull(lnJournalNumber,0) > 0 then
		update journalid set number = lnJournalNumber where journalid = lnJournalId;
	end if;

	update pv_oper set journalId = lnJournalId where id = v_pv_oper.id;

	raise notice 'Koonteerimine lõpp';

	return lnJournalId;
end; 


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_kulum(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_kulum(integer) TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_kulum(integer) TO public;
GRANT EXECUTE ON FUNCTION gen_lausend_kulum(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_kulum(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_kulum(integer) TO dbadmin;
GRANT EXECUTE ON FUNCTION gen_lausend_kulum(integer) TO dbvaatleja;
GRANT EXECUTE ON FUNCTION gen_lausend_kulum(integer) TO taabel;
