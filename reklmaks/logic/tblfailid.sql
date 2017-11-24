-- Function: public.gen_palkoper(int4, int4, int4, date)

-- DROP FUNCTION public.gen_palkoper(int4, int4, int4, date);

CREATE OR REPLACE FUNCTION public.gen_palkoper(int4, int4, int4, date)
  RETURNS int4 AS
'
declare
	tnLepingId alias for $1;
	tnLibId alias for $2;
	tnDokLausId alias for $3;
	tdKpv alias for $4;
	lnLiik int;
	qrypalklib record;
	v_klassiflib record;
	lnAsutusest int;
	lnSumma numeric(12,4);
	lcTunnus varchar;
	lnPalkOperId int;
	lnJournalId int;
begin
	lcTunnus := space(1);
	lnSumma := 0;
	select * into v_klassiflib from klassiflib where libId = tnLibId;
	select palk_lib.*, library.rekvId into qrypalklib from palk_lib inner join library on library.id = palk_lib.parentid 
		where parentid = tnLibId;
	if qryPalkLib.liik = 1 then
		lnSumma := sp_calc_arv(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 2 then
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 3 then
		lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 4 then
		lnSumma := sp_calc_tulumaks(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 5 then
		lnSumma := sp_calc_sots(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 6 then
		lnSumma := sp_calc_tasu(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 7 then
		if lnAsutusest < 1 then
			lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
		else
			lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
		end if;
	end if;		
	if qryPalkLib.liik = 8 then
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;		
	if lnSumma > 0 then
		if v_klassiflib.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_klassiflib.tunnusId;
		end if;
		lcTunnus = ifnull(lcTunnus,space(1));	
		insert into palk_oper (rekvid, libId, lepingid, kpv, summa,  kood1, kood2, kood3, kood4, kood5, konto, tp, tunnus, dokLausId ) 
			VALUES (qryPalkLib.rekvid, tnLibId,tnlepingid,tdKpv,lnSumma, ifnull(v_klassiflib.kood1,space(1)), 
			ifnull(v_klassiflib.kood2,space(1)), ifnull(v_klassiflib.kood3,space(1)), ifnull(v_klassiflib.kood4,space(1)), 
			ifnull(v_klassiflib.kood5,space(1)), ifnull(v_klassiflib.konto,space(1)), \'800699\',lcTunnus, tnDoklausid );

		lnpalkOperId:= cast(CURRVAL(\'public.palk_oper_id_seq\') as int4);	
		lnJournalid := GEN_LAUSEND_PALK(lnpalkoperid);
		if lnJournalid > 0 then
			update palk_oper set journalid = lnJournalId where id = lnPalkOperid;
		end if;
	end if;
	Return lnpalkOperId;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
