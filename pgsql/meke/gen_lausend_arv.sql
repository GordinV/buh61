-- Function: gen_lausend_arv(integer)

-- DROP FUNCTION gen_lausend_arv(integer);

CREATE OR REPLACE FUNCTION gen_lausend_arv(integer)
  RETURNS integer AS
$BODY$
declare 
	tnId alias for $1;

	lnJournalNumber int4;
	lcDbKonto varchar(20);
	lcKrKonto varchar(20);
	lcDbTp varchar(20);
	lcKrTp varchar(20);
	lcKood5 varchar(20);
	lnAsutusId int4;
	lnJournal int4;
	lcKbmTp varchar(20);
	lcDbKbmTp varchar(20);
	v_arv arv%rowtype;
	v_dokprop dokprop%rowtype;
	v_aa aa%rowtype;
	v_arv1 record;
	v_asutus asutus%rowtype;
	lnUserId int;
	lnKontrol int;
	lcAllikas varchar(20);
	lcviga varchar;
	lnJournal1 int;
	lcOmaTP varchar(20);
	lcValuuta varchar(20);
	lnKuurs numeric (14,4);
	lcKreedit varchar(20);
	lcDeebet VARCHAR(20);
begin


	select * into v_arv from arv where id = tnId;
	If v_arv.doklausid = 0 then
		Return 0;
	End if;

	select recalc into lnKontrol from rekv where id = v_arv.rekvid;
	if v_arv.rekvid > 1 then
		lcAllikas = 'LE-P';
	end if;
--	raise notice 'lnKontrol: %',lnKontrol;

	select * into v_dokprop from dokprop where id = v_arv.doklausid limit 1;
	If not Found or v_dokprop.registr = 0 then
		Return 0;
	End if;

	If v_arv.journalid > 0 then
		update arv set journalId = 0 where id = v_arv.id;
		select number into lnJournalNumber from journalId where journalId = v_arv.journalId;
		if ifnull(lnJournalNumber,0) > 0 then
			if sp_del_journal(v_arv.journalid,1) = 0 then
				Return 0;
			End if;
		end if;
	End if;
	select * into v_aa from aa where parentid = v_arv.rekvId limit 1;	
	select id into lnUserId from userid where userid.rekvid = v_arv.rekvid and userid.kasutaja = CURRENT_USER::varchar;

	lnJournal:= sp_salvesta_journal(0, v_arv.rekvId, v_arv.UserId, v_arv.kpv, v_arv.asutusId, ltrim(rtrim(v_dokprop.selg))+' '+ltrim(rtrim(v_arv.lisa)), 
		v_arv.number,space(1),v_arv.id, v_arv.objekt) ;

--	lisatud 01/02/2005
	Select tp into lcDbKbmTp from asutus where id = v_arv.Asutusid;
	lcDbKbmTp:= ifnull(lcDbKbmTp,'800599');
	lcKrTp:=ifnull(lcDbKbmTp,'800599');
	for v_arv1 in 
		select arv1.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
			from arv1 left outer join dokvaluuta1 on (arv1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 2) 
			where arv1.parentid = v_arv.Id
	loop
	--	lisatud 18/03/2005
		if not empty(v_arv1.tp) then 
			lcDbKbmTp:= v_arv1.tp;
		end if;
		if not empty(v_arv1.kood2) then
				lcAllikas = v_arv1.kood2;
		end if;
		lcKood5 = v_arv1.kood5;

		If v_arv.liik = 0 then
			if v_arv.objektId = 0 then
				if left(ltrim(rtrim(v_dokprop.konto)),6) = '103701' then
					lcDbKbmTp:= '014003';
				end if;

				lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbmta,''::varchar,''::text,
					v_arv1.kood1,v_arv1.kood2,v_arv1.kood3,v_arv1.kood4,v_arv1.kood5,
					v_dokprop.konto,lcDbKbmTp,v_arv1.konto,lcDbKbmTp,v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbmta*v_arv1.kuurs,
					v_arv1.tunnus,v_arv1.proj);

				-- kbm
				If v_arv1.kbm <> 0 and not empty(v_dokprop.kbmkonto) then
					lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbm,''::varchar,''::text,
						v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
						v_dokprop.konto,lcDbKbmTp,v_dokprop.kbmkonto,'014003',v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbm*v_arv1.kuurs,
						v_arv1.tunnus,v_arv1.proj);
				END IF;
			else
				--	lisatud 30/12/2004 (mahakandmine)				

				if left(ltrim(rtrim(v_arv1.konto)),6) = '103701' then
					lcDbKbmTp:= '014003';
				end if;
				if (select count(id) from ladu_grupp where nomid = v_arv1.nomid) > 0 then 
					lcKreedit = '108100';
					lcDeebet = v_arv1.konto;
				end if;	
				lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbmta,''::varchar,''::text,
					v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
					lcDeebet,v_arv1.tp,lcKreedit,v_arv1.tp,v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbmta*v_arv1.kuurs,
					v_arv1.tunnus,v_arv1.proj);

/*
				Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
					kood3, kood4, kood5, tunnus, proj) Values 
					(lnJournal, v_arv1.kbmta, v_arv1.konto,  v_dokprop.konto, ifnull(v_asutus.tp,'800599'), ifnull(v_asutus.tp,'800599'), v_arv1.kood1,
					lcAllikas, v_arv1.kood3, v_arv1.kood4, lcKood5, v_arv1.tunnus, v_arv1.proj );
*/
				-- kbm
				If v_arv1.kbm <> 0 and not empty(v_dokprop.kbmkonto) then

					lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbm,''::varchar,''::text,
						v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
						v_dokprop.kbmkonto,'014003',v_dokprop.konto,ifnull(v_asutus.tp,'800599'),v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbm*v_arv1.kuurs,
						v_arv1.tunnus,v_arv1.proj);

/*
					Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
						kood3, kood4, kood5, tunnus, proj) Values 
						(lnJournal, v_arv1.kbmta, v_dokprop.kbmkonto,  v_dokprop.konto, '014003', ifnull(v_asutus.tp,'800599'), v_arv1.kood1,
						lcAllikas, v_arv1.kood3, v_arv1.kood4, lcKood5, v_arv1.tunnus, v_arv1.proj );
*/
				end if;
			end if;

		
		Else
			if v_arv1.konto = '601000' or v_arv1.konto = '203000' then
				lcDbKbmTp := '014003';
			end if;
			if left(ltrim(rtrim(v_arv1.konto)),6) = '103701' then
				lcDbKbmTp:= '014003';
			end if;
			

			if lnKontrol = 1 then

				lcViga = sp_lausendikontrol(v_arv1.konto, v_dokprop.konto,  lcDbKbmTp, lcKrTp,v_arv1.kood1, lcAllikas, lckood5, v_arv1.kood3, 
							lcOmaTP, v_arv.Kpv);
				if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
					raise exception ':%',lcViga;
				end if;
			end if;	

			lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbmta,''::varchar,''::text,
					v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
					v_arv1.konto,lcDbKbmTp,v_dokprop.konto,lcKrTp,v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbmta*v_arv1.kuurs,
					v_arv1.tunnus,v_arv1.proj);

/*
			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
				kood3, kood4, kood5, tunnus, proj) Values 
				(lnJournal, v_arv1.kbmta, v_arv1.konto,  v_dokprop.konto, lcDbKbmTp, lcKrTp, v_arv1.kood1,
				lcAllikas, v_arv1.kood3, v_arv1.kood4, lckood5, v_arv1.tunnus, v_arv1.proj );
*/
			-- kbm
			If v_arv1.kbm <> 0 and not empty(v_dokprop.kbmkonto) then

				lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbm,''::varchar,''::text,
						v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
						v_dokprop.kbmkonto,'014003',v_dokprop.konto, lcKrTp,v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbm*v_arv1.kuurs,
						v_arv1.tunnus,v_arv1.proj);

/*
				Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
					kood3, kood4, kood5, tunnus, proj) Values 
					(lnJournal, v_arv1.kbm, v_dokprop.kbmkonto,  v_dokprop.konto, '014003', lcKrTp, v_arv1.kood1,
					lcAllikas, v_arv1.kood3, v_arv1.kood4, lckood5, v_arv1.tunnus, v_arv1.proj );
*/
			end if;
		End if;
	End loop;

	update arv set journalId = lnJournal where id = v_arv.id;
	If v_arv.journalid > 0 and ifnull(lnJournalNumber,0) > 0 then
		update journalid set number = lnJournalNumber where journalid = lnJournal;
	end if;
--	commit;
	return lnJournal;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_arv(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_arv(integer) TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_arv(integer) TO public;
GRANT EXECUTE ON FUNCTION gen_lausend_arv(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_arv(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_arv(integer) TO dbadmin;
GRANT EXECUTE ON FUNCTION gen_lausend_arv(integer) TO dbvaatleja;
