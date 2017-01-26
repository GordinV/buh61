
CREATE OR REPLACE FUNCTION gen_lausend_reklintress(integer)
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
		v_luba record;	
		v_dekl record;	
		v_dokprop record;	
		v_nom record;
		lnSumma numeric;
		lnLausendiSumma numeric;
		lcTunnus varchar(20);
		lnId integer = 0;
begin

	select toiming.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_dekl 
		from toiming left outer join dokvaluuta1 on (toiming.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 24)  where toiming.id = tnId;

	If v_dekl.dokpropid = 0 then	
		raise notice 'ei registreeri';
		Return 0;	
	End if;
	select * into v_dokprop from dokprop where id = v_dekl.dokpropid;	
	
	If not found Or v_dokprop.registr = 0 then		
		raise notice 'puudub dokprop or ei registreeri';
		Return 0;	
	End if;	

	lnJournalId = 0;
	lnSumma = 0;
	lnLausendiSumma = 0;
	lcTunnus = space(1);

	select luba.id, luba.rekvid, luba.parentid, luba.number, luba1.nomid,  luba1.summa into v_luba
			from luba inner join luba1 on luba.id = luba1.parentid where luba.id = v_dekl.lubaId;
		select klassiflib.* into v_nom from nomenklatuur 
			inner join klassiflib on (nomenklatuur.id = klassiflib.nomId and klassiflib.tyyp = 1) 
			where nomenklatuur.dok = 'REKL' and nomenklatuur.kood like 'INTRESS%' order by id desc limit 1;	
		if ifnull(v_nom.tunnusid,0) = 0 then
			select kood into lcTunnus from library where id = v_nom.tunnusid;
		end if;
		lcTunnus = ifnull(lcTunnus,space(1));


		If v_dekl.journalid > 0 then			
			Select number into lnJournalNumber from journalid where journalid = v_dekl.journalId;			

			update toiming set journalId = 0 where id = v_dekl.id;
			v_dekl.journalId := sp_del_journal(v_dekl.journalid,1);		
		End if;	
		if lnJournalId = 0 then


			lnJournalId:= sp_salvesta_journal(0, v_luba.rekvId, 0, v_dekl.kpv,v_luba.parentId, 
				v_dokprop.selg, v_luba.number,'AUTOMATSELT LAUSEND (GEN_LAUSEND_REKLINTRESS)',v_dekl.id) ;
/*		
			Insert Into journal (rekvid, Userid, kpv, Asutusid, selg, muud) Values 			
			(v_luba.rekvId, 0, v_dekl.kpv, v_luba.parentId, v_dokprop.selg, 'AUTOMATSELT LAUSEND (GEN_LAUSEND_REKLINTRESS)' );


			lnJournalId:= cast(CURRVAL('public.journal_id_seq') as int4);
*/		
			select tp into lcDbTp from asutus where id = v_luba.parentid;
			lcKrTp = lcDbTp;
--			lcDbKonto := v_dokprop.konto;	
			
			update toiming set journalId = lnJournalId where id = v_dekl.id;		

		end if;

--		lcDbKonto := v_dokprop.konto;	
		lcDbKonto = '102095';
		lcKrKonto := '304400';			
		
--		lcKrKonto := v_nom.konto;			
		lnAsutusId := v_luba.parentid;		


		lnId =  sp_salvesta_journal1(0,lnJournalId,v_dekl.summa,''::varchar,''::text,
				v_nom.kood1,v_nom.kood2,v_nom.kood3,v_nom.kood4,v_nom.kood5,
				lcDbKonto,lcDbTp,lcKrKonto,lcKrTp,v_dekl.valuuta,v_dekl.kuurs,v_dekl.summa*v_dekl.kuurs,
				lctunnus,v_nom.proj);
		raise notice 'sp_salvesta_journal1 %', lnId;

/*
		Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, kood3, kood4, kood5, TUNNUS, proj) Values 
			(lnJournalId, v_dekl.summa, lcDbKonto, lcKrKonto, lcDbTp,lcKrTp,v_nom.kood1,
			v_nom.kood2, v_nom.kood3, v_nom.kood4, v_nom.kood5, lctunnus, v_nom.proj );
*/

		if v_dekl.journalid > 0 and lnJournalNumber is not null then		
			update journalid set number = lnJournalNumber where journalid = lnJournalId;		
		end if;


	return lnJournalId;
end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
