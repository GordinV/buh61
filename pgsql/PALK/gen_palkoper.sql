
--DROP FUNCTION if exists gen_palkoper(integer, integer, integer, date, integer);
--DROP FUNCTION if exists gen_palkoper(integer, integer, integer, date, integer, integer);

CREATE OR REPLACE FUNCTION gen_palkoper(integer, integer, integer, date, integer, integer)
  RETURNS integer AS
$BODY$
declare
	tnLepingId alias for $1;
	tnLibId alias for $2;
	tnDokLausId alias for $3;
	tdKpv alias for $4;
	tnAvans alias for $5;
	tnMinPalk alias for $6;
	
	l_sotsmaks_min_palk numeric[];
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
	lnParentId integer;
	l_pohikoht integer = 0;

	lcPref varchar;
	lcTimestamp varchar;
	v_palk_selg record;
	l_last_paev date = (date(year(tdKpv), month(tdKpv),1) + interval '1 month')::date  - 1;

	l_sotsmaks_min_id integer = 0;
	l_lepingId_min_sots integer;
	l_min_sots_id integer;
	l_libId_min_sots integer;


begin
	lcPref = '';
	select rekvid, parentId, pohikoht into lnrekvid, lnParentId, l_pohikoht from tooleping where id = tnLepingId;

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
		delete from palk_oper where lepingid = tnLepingId and libId = tnLibId and kpv = tdKpv and summa <> 0;
	
	end if;

	if qryPalkLib.liik = 1 then
		lnSumma := sp_calc_arv(tnLepingId, tnLibId, tdKpv, null, null);
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
		lcPref = 'PM';
		lnSumma := sp_calc_kinni(tnLepingId, tnLibId, tdKpv);
	end if;	
	
	if lnSumma <> 0 or qryPalkLib.liik = 5 then

		lnSumma = coalesce(lnSumma,0);
	
		if v_klassiflib.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_klassiflib.tunnusId;
		end if;
		if v_palk_kaart.tunnusid > 0 then
			select kood into lcTunnus from library where id = v_palk_kaart.tunnusId;
		end if;

		lcTunnus = ifnull(lcTunnus,space(1));	
		lcTimestamp = left(lcPref+LTRIM(RTRIM(str(tnLepingId)))+LTRIM(RTRIM(str(tnLibId)))+ltrim(rtrim(str(dateasint(tdKpv)))),20);
		select muud::varchar as selg, volg1 as tm, tasun1 as tulubaas, volg2 as sm, volg4 as tki, volg5 as pm, volg6 as tka into v_palk_selg 
			from tmp_viivis 
			where timestamp = lcTimestamp order by oid desc limit 1;
--		end if;
		if qrypalklib.tululiik = '' then
			qrypalklib.tululiik = '0';
		end if;

		if lnSumma <> 0 then

			lnPalkOperId = sp_salvesta_palk_oper(0, lnRekvid, tnLibId, tnlepingid, tdKpv, lnSumma, tnDoklausid, v_palk_selg.selg, 
				ifnull(v_klassiflib.kood1,space(1)),ifnull(v_klassiflib.kood2,'LE-P'), ifnull(v_klassiflib.kood3,space(1)), 
				ifnull(v_klassiflib.kood4,space(1)), ifnull(v_klassiflib.kood5,space(1)), ifnull(v_klassiflib.konto,space(1)), 
				 lcTp, lcTunnus,v_valuuta.kood, v_valuuta.kuurs,v_klassiflib.proj,
				qrypalklib.tululiik::integer, ifnull(v_palk_selg.tm,0), ifnull(v_palk_selg.sm,0), ifnull(v_palk_selg.tki,0), ifnull(v_palk_selg.pm,0), 
				ifnull(v_palk_selg.tulubaas,0), coalesce(v_palk_selg.tka,0), null::date);

			delete from tmp_viivis where rekvid = lnRekvid and timestamp = lcTimestamp;


		end if;
		
		if qryPalkLib.liik = 5 and not empty(tnMinPalk) and (select count(pk.id) 
				from palk_kaart pk 
				inner join palk_lib pl on pl.parentid = pk.libId
				where pk.lepingid in (select id from tooleping  where parentid = lnParentId and pohikoht = 1 or id = tnLepingid) 
				and pl.liik = 5
				and coalesce(pk.minsots,0) = 1) > 0 and l_pohikoht = 1 then

				select po.id, po.libid, po.lepingId into l_sotsmaks_min_id , l_lepingId_min_sots, l_libId_min_sots
					from palk_oper po
					where lepingid in  (select id from tooleping  where parentid = lnParentId and pohikoht = 1 and rekvid = lnrekvid)
					and kpv = l_last_paev 
					and libId = tnLibId 
					and id <> lnPalkOperId 
					and po.sotsmaks <> 0
					limit 1;


			-- arvestame sotsmaks minpalgast
			l_sotsmaks_min_palk =  sp_calc_min_sots(tnLepingid, l_last_paev);

			if l_sotsmaks_min_palk is not null then 
								
				l_sotsmaks_min_id =  sp_salvesta_palk_oper(coalesce(l_sotsmaks_min_id,0), lnRekvid, coalesce(l_libId_min_sots,tnLibId), coalesce(l_lepingId_min_sots,tnlepingid), l_last_paev, l_sotsmaks_min_palk[1], tnDoklausid, 
					('SM min. palgast -> ' + ifnull(l_sotsmaks_min_palk[1],0)::text + ' SM summast -> ' + ifnull(l_sotsmaks_min_palk[2],0)::text), 
					ifnull(v_klassiflib.kood1,space(1)),ifnull(v_klassiflib.kood2,'LE-P'), ifnull(v_klassiflib.kood3,space(1)), 
					ifnull(v_klassiflib.kood4,space(1)), ifnull(v_klassiflib.kood5,space(1)), ifnull(v_klassiflib.konto,space(1)), 
					 lcTp, lcTunnus,v_valuuta.kood, v_valuuta.kuurs,v_klassiflib.proj,
					qrypalklib.tululiik::integer, 0, ifnull(l_sotsmaks_min_palk[2],0), 0, 0, 
					0, 0, null::date);
			else
				if coalesce(l_sotsmaks_min_id,0) > 0 then
					-- kustuta vana arvestus
					perform sp_del_palk_oper(l_sotsmaks_min_id,1);
				end if;

			end if;
		end if;


--		lisatud 31/12/2004
		IF tnAvans > 0 AND qryPalkLib.liik = 6 then 	
			perform sp_calc_avansimaksed(lnpalkOperId);
		END IF;

		-- umardamine
		if qryPalkLib.liik = 1 and lnSumma <> 0 
			and -- tulud rohkem kui 1
				(
				select count(palk_oper.id) from palk_oper 
				where lepingId in (select id from tooleping where parentId = lnParentId
				)
				and rekvId = lnrekvid
				and summa <> 0
				and libId in (select l.id from library l inner join palk_lib pl on pl.parentId = l.id and pl.liik = 1 )
				and year(kpv) = year(tdKpv) and month(kpv) = month(tdKpv)
				) > 1
				
			
		then
				-- umardamine
				perform  sp_calc_umardamine(lnParentId, tdKpv,  lnrekvid);

		end if;


		
	end if;
	Return lnpalkOperId;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;


/*
select * from rekv where nimetus ilike '%0911036%'
--99

select * from asutus where regkood = '45803153738'
-- 16450

select * from tooleping where parentid = 16450 and rekvid = 99
-- 140939

select * from palk_kaart where lepingid = 140939


select * from palk_oper where lepingid = 140939 order by id desc limit 10

select gen_palkoper(140939, 289426, 1526, date(2017,05,31), 0, 1)

select count(pk.id) 
				from palk_kaart pk 
				inner join palk_lib pl on pl.parentid = pk.libId
				where pk.lepingid = (select id from tooleping  where parentid = 16450 and pohikoht = 1 or id = 140939) 
				and pl.liik = 5
				and coalesce(pk.minsots,0) = 1

*/