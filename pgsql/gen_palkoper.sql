-- Function: gen_palkoper_test(integer, integer, integer, date, integer)

-- DROP FUNCTION gen_palkoper_test(integer, integer, integer, date, integer);

CREATE OR REPLACE FUNCTION gen_palkoper(
    integer,
    integer,
    integer,
    date,
    integer)
  RETURNS integer AS
$BODY$
declare
	tnLepingId alias for $1;
	tnLibId alias for $2;
	tnDokLausId alias for $3;
	tdKpv alias for $4;
	tnAvans alias for $5;


	lnLiik int;
	qrypalklib record;
	v_klassiflib record;
	v_palk_kaart record;
	v_dokprop record;
	lnAsutusest int;
	lnSumma numeric(12,4);
	lcTunnus varchar;
	lnPalkOperId int;
	lnJournalId int;
	lcTp varchar;
	v_valuuta record;
	lnRekvId integer;

	lcPref varchar = '';
	lcTimestamp varchar = LTRIM(RTRIM(str(tnLepingId)))+LTRIM(RTRIM(str(tnLibId)))+ltrim(rtrim(str(dateasint(tdKpv))));
	v_palk_selg record;

begin
	select rekvid into lnrekvid from tooleping where id = tnLepingId;

	SELECT Library.kood, ifnull((select valuuta1.kuurs from valuuta1 
		where parentid = library.id order by Library.id desc limit 1),0) as kuurs into v_valuuta
		FROM Library WHERE  library = 'VALUUTA' and library.tun1 = 1;

	lcTp := '800699';
	lcTunnus := space(1);
	lnSumma := 0;
	select * into v_klassiflib from klassiflib where libId = tnLibId order by id desc limit 1;
	select * into v_palk_kaart from palk_kaart where libId = tnLibId and lepingId = tnLepingId;
	select palk_lib.*, library.rekvId into qrypalklib from palk_lib inner join library on library.id = palk_lib.parentid 
		where palk_lib.parentid = tnLibId;
	select * into v_dokprop from dokprop where id = tnDokLausId;
	if qryPalkLib.liik = 1 and (select count(id) from palk_oper where kpv = tdKpv and lepingId = tnLepingid and libId = tnLibId and period is not null and period <> tdKpv) > 0 then
		--ei saa arvestada sest on parandusi
		return 0;
	else
		delete from journal where id in (select journalId from palk_oper where lepingid = tnLepingId and libId = tnLibId and kpv = tdKpv);
		delete from palk_oper where lepingid = tnLepingId and libId = tnLibId and kpv = tdKpv;
	
	end if;

--	raise notice 'qryPalkLib.liik %', qryPalkLib.liik;
	if qryPalkLib.liik = 1 then
		
		lnSumma := sp_calc_arv(tnLepingId, tnLibId, tdKpv, null, null);
		raise notice 'lnSumma %', lnSumma;
		lcPref = 'ARV';
	end if;		
	if qryPalkLib.liik = 2 then
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 3 then
		lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 4 then
		lnSumma := sp_calc_tulumaks(tnLepingId, tnLibId, tdKpv);
		lcTp := '014001';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;
		lcPref = 'TM';

	end if;		
	if qryPalkLib.liik = 5 then
		lcPref = 'SOTS';
		lnSumma := sp_calc_sots(tnLepingId, tnLibId, tdKpv);
		lcTp := '014001';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;

	end if;		
	if qryPalkLib.liik = 6 then
		lnSumma := sp_calc_tasu(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 7 then
		lcPref = 'TK';
		if lnAsutusest < 1 then
			raise notice 'sp_calc_kinni tnLibId %', tnLibId;
			lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
		else
			raise notice 'sp_calc_muuda tnLibId %', tnLibId;
			lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
		end if;
		lcTp := '014001';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;
	end if;		
	if qryPalkLib.liik = 8 then
		lcPref = 'PM';
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;	
	lcTimestamp = left(lcPref + lcTimestamp,20);
	raise notice 'lcTimestamp %', lcTimestamp;
	if lnSumma <> 0 or (qryPalkLib.liik = 1 and (select volg2 from tmp_viivis where timestamp = lcTimestamp order by oid desc limit 1) > 0) then
		if v_klassiflib.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_klassiflib.tunnusId;
		end if;
		if v_palk_kaart.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_palk_kaart.tunnusId;
		end if;

		lcTunnus = ifnull(lcTunnus,space(1));	

		select muud::varchar as selg, volg1 as tm, tasun1 as tulubaas, volg2 as sm, volg4 as tki, volg5 as pm, volg6 as tka into v_palk_selg 
			from tmp_viivis 
			where timestamp = lcTimestamp order by oid desc limit 1;
--		end if;


		if qrypalklib.tululiik is null or ltrim(rtrim(qrypalklib.tululiik)) = '' then
			qrypalklib.tululiik = '0';
		end if;
		raise notice 'lcTunnus %, lcTimestamp %, v_palk_selg.selg %, qrypalklib.tululiik %, lnSumma %',lcTunnus, lcTimestamp, v_palk_selg.selg, coalesce(qrypalklib.tululiik,'null'), lnSumma ;

		lnPalkOperId = sp_salvesta_palk_oper(0, lnRekvid, tnLibId, tnlepingid, tdKpv, lnSumma, tnDoklausid, v_palk_selg.selg, 
			ifnull(v_klassiflib.kood1,space(1)),ifnull(v_klassiflib.kood2,'LE-P'), ifnull(v_klassiflib.kood3,space(1)), 
			ifnull(v_klassiflib.kood4,space(1)), ifnull(v_klassiflib.kood5,space(1)), ifnull(v_klassiflib.konto,space(1)), 
			 lcTp, lcTunnus,v_valuuta.kood, v_valuuta.kuurs,v_klassiflib.proj,
			qrypalklib.tululiik::integer, ifnull(v_palk_selg.tm,0), ifnull(v_palk_selg.sm,0), ifnull(v_palk_selg.tki,0), ifnull(v_palk_selg.pm,0), 
			ifnull(v_palk_selg.tulubaas,0), coalesce(v_palk_selg.tka,0), null::date);

		delete from tmp_viivis where rekvid = lnRekvid and timestamp = lcTimestamp;


--		lisatud 31/12/2004
		IF tnAvans > 0 AND qryPalkLib.liik = 6 then 	
			perform sp_calc_avansimaksed(lnpalkOperId);
		END IF;

	end if;
	Return lnpalkOperId;
end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION gen_palkoper(integer, integer, integer, date, integer)
  OWNER TO vlad;
