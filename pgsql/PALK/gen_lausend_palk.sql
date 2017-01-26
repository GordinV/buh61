-- Function: gen_lausend_palk(integer)

-- DROP FUNCTION gen_lausend_palk(integer);

CREATE OR REPLACE FUNCTION gen_lausend_palk(integer)
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
	v_palk_oper record;	
	v_dokprop dokprop%rowtype;	
	v_aa record;	
	v_palk_lib palk_lib%rowtype;	
	v_tooleping tooleping%rowtype;	
	v_asutus asutus%rowtype;

	lnUsrId int;
	lcAllikas varchar(20);
	lcviga varchar;


begin	
	lcDbTp := '800699';
	lcKrTp := '800699';

	select palk_oper.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta into v_palk_oper 
		from palk_oper left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
		where palk_oper.id = tnId;

	If v_palk_oper.doklausid = 0 then		
		raise notice 'Konteerimine ei ole vajalik, dok tyyp ei ole defineeritud';
		Return 0;	
	End if;	

	select * into v_dokprop from dokprop where id = v_palk_oper.doklausid;	
	If not Found Or v_dokprop.registr = 0 then		
		raise notice 'Konteerimine ei ole vajalik';
		Return 0;	
	End if;

--	select recalc into lnKontrol from rekv where id =  v_palk_oper.rekvid;
--	lcAllikas = 'LE-P';
	lcAllikas = ' ';



	If v_palk_oper.journalid > 0 then		
		select number into lnJournalNumber from journalId where journalId = v_palk_oper.journalId;
		update palk_oper set journalId = 0 where id = v_palk_oper.id;		
		v_palk_oper.journalid:= sp_del_journal(v_palk_oper.journalid,1);	
	End if;	
	select * into v_tooleping from tooleping where id = v_palk_oper.LepingId;	
	select * into v_palk_lib from palk_lib where parentid = v_palk_oper.libId;	
	select * into v_asutus from asutus where id = v_tooleping.parentId;	
	lnAsutusId:= v_asutus.id;


	lcDbTp := v_asutus.tp;
	lcKrTp := v_asutus.tp;

	select * into v_aa from aa where parentid = v_palk_oper.rekvId and kassa = 1 order by default_ desc limit 1;		
	if  v_palk_lib.liik = 1  then		 
		--arv		
		lcDbKonto := v_palk_oper.konto;		
		lcKrKonto := v_dokprop.konto;		
--		lcDbTp := v_asutus.tp;		
--		lcKrTp := v_asutus.tp;		
		lnAsutusId := v_asutus.Id;	
	end if;
	if v_palk_lib.liik = 2 then 		
		-- kinni		
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
--		lcKrTp := v_asutus.tp;		
		lcDbTp := v_palk_oper.tp;		
		lnAsutusId := v_asutus.Id;	
	end if;
	if  v_palk_lib.liik = 4 then	
		-- tulumaks		
		Select * into v_asutus from asutus where id = v_dokprop.asutusId;		
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
--		lcKrTp := v_asutus.tp;		
--		lcDbTp := '800699';	
	end if;
	if v_palk_lib.liik = 5 then 	
		-- sotsmaks		
--		if v_dokprop.asutusId > 0 then
--			Select * into v_asutus from asutus where id = v_dokprop.asutusId;		
---		end if;
		lcKrKonto := v_palk_lib.konto;		
		lcDbKonto := v_palk_oper.konto;		
--		lcKrTp := v_asutus.tp;		
--		lcDbTp := '800699';		
		if ifnull(v_asutus.Id,0) > 0 then
			lnAsutusId := v_asutus.Id;	
		end if;
	end if;
	if v_palk_lib.liik = 6 then
	-- tasu		
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
		lcKrTp := v_aa.tp;		
		lcDbTp := v_palk_oper.tp;		
		lnAsutusId := v_asutus.Id;
		-- lisatud 01/02/2005
		if left(lcKrKonto,6) = '100000' then
			lcKrTp := space(1);
		end if;
	end if;
	if v_palk_lib.liik = 7 And v_palk_lib.asutusest = 1 then 
		--tookindl asutus	
--		if v_dokprop.asutusId > 0 then
--			Select * into v_asutus from asutus where id = v_dokprop.asutusId;		
--		end if;
		lcKrKonto := v_palk_lib.konto;		
		lcDbKonto := v_palk_oper.konto;		
--		lcKrTp := v_asutus.tp;	
--		if ifnull(v_asutus.Id,0) = 0 then
--			lcKrTp := '800699';	
--		end if;
	
--		lcDbTp := '800699';		
		if ifnull(v_asutus.Id,0) > 0 then
			lnAsutusId := v_asutus.Id;	
		end if;
	end if;
	if v_palk_lib.liik = 7 And v_palk_lib.asutusest = 0  then	
		-- tookindl isik		
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
--		lcKrTp := v_palk_oper.tp;		
--		lcDbTp := v_asutus.tp;		
		if ifnull(v_asutus.Id,0) > 0 then
			lnAsutusId := v_asutus.Id;	
		end if;
		if ifnull(v_asutus.Id,0) = 0 then
			lcKrTp :=v_asutus.tp;	
		end if;
	
--		lcDbTp := '800699';		

	end if;
	if v_palk_lib.liik = 8 then
		-- pensmaks		
--		if v_dokprop.asutusId > 0 then			
--			Select * into v_asutus from asutus where id = v_dokprop.asutusId;		
--		end if;
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
--		lcKrTp := v_asutus.tp;		
--		lcDbTp := '800699';	
		if ifnull(v_asutus.Id,0) > 0 then
			lnAsutusId := v_asutus.Id;	
		end if;
	End if;	
	if left(lcKrKonto,3) = '203' and lcKrKonto <> '203690' then
		lcKrTp := '014001';
	end if;
	if lcKrKonto = '203690' then
		lcKrTp := '800399';
	end if;
	if lcKrKonto = '203640' then
		lcKrTp := '800699';
	end if;
/*	
	if lcKrKonto = '202000' then
		lcKrTp := '800699';
	end if;
	
	if lcDbKonto = '103560' then
		lcDbTp := '016003';
	end if;
*/	
	if lcDbKonto = '103560' then
		lcDbTp := '016001';
	end if;
/*	
	if lcKrKonto = '202090' then
		lcKrTp := '800699';
	end if;
	if lcKrKonto = '202002' then
		lcKrTp := '800699';
	end if;
	if lcKrKonto = '202003' then
		lcKrTp := '800699';
	end if;
	if lcKrKonto = '202004' then
		lcKrTp := '800699';
	end if;
*/
	SELECT id INTO lnUsrID from userid WHERE rekvid = v_palk_oper.rekvId and  kasutaja = CURRENT_USER::VARCHAR order by id desc limit 1;

	lnJournalId:= sp_salvesta_journal(0, v_palk_oper.rekvId, lnUsrID, v_palk_oper.kpv, lnAsutusId, 
		ltrim(rtrim(v_dokprop.selg)), '','AUTOMATSELT LAUSEND (GEN_LAUSEND_PALK)',v_palk_oper.id) ;

	if lnJournalId = 0 then
		return 0;
	end if; 	

	v_palk_oper.kood1 := ifnull(v_palk_oper.kood1,space(1));
	v_palk_oper.kood2 := ifnull(ltrim(rtrim(v_palk_oper.kood2)),' ');
	v_palk_oper.kood3 := ifnull(v_palk_oper.kood3,space(1));
	v_palk_oper.kood4 := ifnull(v_palk_oper.kood4,space(1));
	v_palk_oper.kood5 := ifnull(v_palk_oper.kood5,space(1));

	if empty(ltrim(rtrim(v_palk_oper.kood2))) then
		v_palk_oper.kood2 := 'LE-P';
	end if;

	lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_palk_oper.Summa,''::varchar,''::text,
				v_palk_oper.kood1,v_palk_oper.kood2,v_palk_oper.kood3,v_palk_oper.kood4,v_palk_oper.kood5,
				lcDbKonto,lcDbTp,lcKrKonto,lcKrTp,v_palk_oper.valuuta,v_palk_oper.kuurs,v_palk_oper.summa*v_palk_oper.kuurs,
				v_palk_oper.tunnus,v_palk_oper.proj);

	update palk_oper set journalId = lnJournalId where id = v_palk_oper.id;

	if v_palk_oper.journalId > 0 and ifnull(lnJournalNumber,0) > 0 then		
		update journalid set number = lnJournalNumber where journalid = lnJournalId;	
	end if;
	return lnJournalId;
end; 
	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_palk(integer)
  OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_palk(integer) TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_palk(integer) TO public;
GRANT EXECUTE ON FUNCTION gen_lausend_palk(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_palk(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_palk(integer) TO dbadmin;
GRANT EXECUTE ON FUNCTION gen_lausend_palk(integer) TO dbvaatleja;
GRANT EXECUTE ON FUNCTION gen_lausend_palk(integer) TO taabel;
