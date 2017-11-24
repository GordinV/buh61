-- Function: public.gen_lausend_palk(int4)

-- DROP FUNCTION public.gen_lausend_palk(int4);

CREATE OR REPLACE FUNCTION public.gen_lausend_palk(int4)
  RETURNS int4 AS
'
declare 	
	tnId alias for $1;	
	lnJournalNumber int4;	
	lcDbKonto varchar(20);	
	lcKrKonto varchar(20);	
	lcDbTp varchar(20);	
	lcKrTp varchar(20);	
	lnAsutusId int4;	
	lnJournalId int4;	
	v_palk_oper palk_oper%rowtype;	
	v_dokprop dokprop%rowtype;	
	v_aa aa%rowtype;	
	v_palk_lib palk_lib%rowtype;	
	v_tooleping tooleping%rowtype;	
	v_asutus asutus%rowtype;
begin	
	lcDbTp := space(1);
	lcKrTp := space(1);
	select * into v_palk_oper from palk_oper where id = tnId;	
	If v_palk_oper.doklausid = 0 then		
		Return 0;	
	End if;	
	select * into v_dokprop from dokprop where id = v_palk_oper.doklausid;	
	If not Found Or v_dokprop.registr = 0 then		
		Return 0;	
	End if;
	If v_palk_oper.journalid > 0 then		
		select number into lnJournalNumber from journalId where journalId = v_palk_oper.journalId;
		update palk_oper set journalId = 0 where id = v_palk_oper.id;		
		v_palk_oper.journalid:= sp_del_journal(v_palk_oper.journalid,1);	
	End if;	
	select * into v_tooleping from tooleping where id = v_palk_oper.LepingId;	
	select * into v_palk_lib from palk_lib where parentid = v_palk_oper.libId;	
	select * into v_asutus from asutus where id = v_tooleping.parentId;	
	lnAsutusId:= v_asutus.id;
	select * into v_aa from aa where parentid = v_palk_oper.rekvId and kassa = 1 and default_ = 1;		
	if  v_palk_lib.liik = 1  then		 
		--arv		
		lcDbKonto := v_palk_oper.konto;		
		lcKrKonto := v_dokprop.konto;		
		lcDbTp := v_asutus.tp;		
		lcKrTp := v_asutus.tp;		
		lnAsutusId := v_asutus.Id;	
	end if;
	if v_palk_lib.liik = 2 then 		
		-- kinni		
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
		lcKrTp := v_aa.tp;		
		lcDbTp := v_palk_oper.tp;		
		lnAsutusId := v_asutus.Id;	
	end if;
	if  v_palk_lib.liik = 4 then	
		-- tulumaks		
		Select * into v_asutus from asutus where id = v_dokprop.asutusId;		
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
		lcKrTp := v_asutus.tp;		
		lcDbTp := v_palk_oper.tp;	
	end if;
	if v_palk_lib.liik = 5 then 	
		-- sotsmaks		
		Select * into v_asutus from asutus where id = v_dokprop.asutusId;		
		lcKrKonto := v_palk_lib.konto;		
		lcDbKonto := v_palk_oper.konto;		
		lcKrTp := v_asutus.tp;		
		lcDbTp := v_palk_oper.tp;		
		lnAsutusId := ifnull(v_asutus.Id,0);	
	end if;
	if v_palk_lib.liik = 6 then
	-- tasu		
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
		lcKrTp := v_aa.tp;		
		lcDbTp := v_palk_oper.tp;		
		lnAsutusId := v_asutus.Id;	
	end if;
	if v_palk_lib.liik = 7 And v_palk_lib.asutusest = 1 then 
		--tookindl asutus		
		Select * into v_asutus from asutus where id = v_dokprop.asutusId;		
		lcKrKonto := v_palk_lib.konto;		
		lcDbKonto := v_palk_oper.konto;		
		lcKrTp := v_asutus.tp;		
		lcDbTp := v_palk_oper.tp;		
		lnAsutusId := ifnull(v_asutus.Id,0);	
	end if;
	if v_palk_lib.liik = 7 And v_palk_lib.asutusest = 0  then	
		-- tookindl isik		
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
		lcKrTp := v_palk_oper.tp;		
		lcDbTp := v_asutus.tp;		
		lnAsutusId := ifnull(v_asutus.Id,0);	
	end if;
	if v_palk_lib.liik = 8 then
		-- pensmaks		
		Select * into v_asutus from asutus where id = v_dokprop.asutusId;		
		lcKrKonto := v_palk_oper.konto;		
		lcDbKonto := v_dokprop.konto;		
		lcKrTp := v_asutus.tp;		
		lcDbTp := v_palk_oper.tp;		
		lnAsutusId := ifnull(v_asutus.Id,0);	
	End if;	
	Insert Into journal (rekvid, Userid, kpv, Asutusid, selg, muud) Values 	
		(v_palk_oper.rekvId, 0, v_palk_oper.kpv, lnAsutusId, v_dokprop.selg, \'AUTOMATSELT LAUSEND (GEN_LAUSEND_PALK)\' );
	lnJournalId:= cast(CURRVAL(\'public.journal_id_seq\') as int4);		
	lcDbTp := ifnull(lcDbTp,space(1));
	lcKrTp := ifnull(lcDbTp,space(1));
	v_palk_oper.kood1 := ifnull(v_palk_oper.kood1,space(1));
	v_palk_oper.kood2 := ifnull(v_palk_oper.kood2,space(1));
	v_palk_oper.kood3 := ifnull(v_palk_oper.kood3,space(1));
	v_palk_oper.kood4 := ifnull(v_palk_oper.kood4,space(1));
	v_palk_oper.kood5 := ifnull(v_palk_oper.kood5,space(1));
	Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, kood3, kood4, kood5, tunnus) Values 		
	(lnJournalId, v_palk_oper.Summa, lcDbKonto, lcKrKonto, lcDbTp,lcKrTp, v_palk_oper.kood1,		
		v_palk_oper.kood2, v_palk_oper.kood3, v_palk_oper.kood4, v_palk_oper.kood5, v_palk_oper.tunnus );	
	update palk_oper set journalId = lnJournalId where id = v_palk_oper.id;
	if v_palk_oper.journalId > 0 then		
		update journalid set number = lnJournalNumber where journalid = lnJournalId;	
	end if;
	return lnJournalId;end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
