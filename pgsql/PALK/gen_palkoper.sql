-- Function: gen_palkoper(integer, integer, integer, date, integer)

-- DROP FUNCTION gen_palkoper(integer, integer, integer, date, integer);

CREATE OR REPLACE FUNCTION gen_palkoper(integer, integer, integer, date, integer)
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

	lcPref varchar;
	lcTimestamp varchar;
	ltSelg varchar;

begin
	raise notice 'start';
	lcPref = '';
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

	if qryPalkLib.liik = 1 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_arv(tnLepingId, tnLibId, tdKpv);
		raise notice 'summa %',lnSumma;
		lcPref = 'ARV';
	end if;		
	if qryPalkLib.liik = 2 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 3 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 4 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_tulumaks(tnLepingId, tnLibId, tdKpv);
		lcTp := '014001';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;
		lcPref = 'TM';

	end if;		
	if qryPalkLib.liik = 5 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_sots(tnLepingId, tnLibId, tdKpv);
		lcTp := '014001';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;

	end if;		
	if qryPalkLib.liik = 6 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_tasu(tnLepingId, tnLibId, tdKpv);
	end if;		
	if qryPalkLib.liik = 7 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		if lnAsutusest < 1 then
			lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
		else
			lnSumma := sp_calc_muuda(tnLepingId, tnLibId, tdKpv);
		end if;
		lcTp := '014001';
		if v_dokprop.asutusid > 0 then
			select tp into lcTp from asutus where id = v_dokprop.asutusId;
		end if;
	end if;		
	if qryPalkLib.liik = 8 then
		raise notice 'palk_lib %',qryPalkLib.liik;
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;	
	raise notice 'lnSumma> %',lnSumma;
	
	if lnSumma > 0 then
		if v_klassiflib.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_klassiflib.tunnusId;
		end if;
		if v_palk_kaart.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_palk_kaart.tunnusId;
		end if;

		lcTunnus = ifnull(lcTunnus,space(1));	

		-- pohivaluuta
--		lnSumma = lnSumma / fnc_currentkuurs(tdKpv);
		lcTimestamp = '';
		if not empty(lcPref) then
			lcTimestamp = left(lcPref+LTRIM(RTRIM(str(tnLepingId)))+LTRIM(RTRIM(str(tnLibId)))+ltrim(rtrim(str(dateasint(tdKpv)))),20);
--			raise notice 'timestamp'
			select muud::varchar into ltSelg from tmp_viivis where rekvid = lnRekvid and timestamp = lcTimestamp order by oid desc limit 1;
		end if;
		lnPalkOperId = sp_salvesta_palk_oper(0, lnRekvid, tnLibId, tnlepingid, tdKpv, lnSumma, tnDoklausid, ltSelg, 
			ifnull(v_klassiflib.kood1,space(1)),ifnull(v_klassiflib.kood2,'LE-P'), ifnull(v_klassiflib.kood3,space(1)), 
			ifnull(v_klassiflib.kood4,space(1)), ifnull(v_klassiflib.kood5,space(1)), ifnull(v_klassiflib.konto,space(1)), 
			 lcTp, lcTunnus,v_valuuta.kood, v_valuuta.kuurs,v_klassiflib.proj );


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
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO vlad;
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO public;
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION gen_palkoper(integer, integer, integer, date, integer) TO taabel;
