DROP FUNCTION if exists gen_palkoper(integer, integer, integer, date, integer);

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
	lnParentId integer;

	lcPref varchar;
	lcTimestamp varchar;
	v_palk_selg record;

begin
	lcPref = '';
	select rekvid, parentId into lnrekvid, lnParentId from tooleping where id = tnLepingId;

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
	
	if lnSumma <> 0 then
	
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
				and kpv = tdKpv
				) > 1
				
		--	and not exists -- puudub umerdamine				
		--			(select palk_oper.id 
		--				from palk_oper 
		--				where  lepingId in (select id from tooleping where parentId = lnParentId
		--				)
		--				and rekvId = lnrekvid
		-- 				and libId in (select l.id from library l inner join palk_lib pl on pl.parentId = l.id and pl.liik = 1 )
		--				and kpv = tdKpv
		--				and summa = 0)
				
			
		then
				-- umardamine
				perform  sp_calc_umardamine(lnParentId, tdKpv,  lnrekvid);

		end if;


		
	end if;
	Return lnpalkOperId;
end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION gen_palkoper(integer, integer, integer, date, integer)
  OWNER TO vlad;


--select gen_palkoper(131778, 294236, 1576, date(2015,12,31), 0)

/*

select * from palk_oper where Kpv = date(2015,12,31) and rekvid = 119 limit 10

select * from asutus where nimetus ilike '%pereskoka%'
select * from tmp_viivis where timestamp = 'SM138203261782014123'
	
select * from tooleping where parentid = 3557

select palk_lib.tululiik, palk_lib.parentId, liik, palk_kaart.summa
from Library inner join Palk_kaart  on palk_kaart.libId = library.id  
inner join   Palk_lib on palk_lib.parentId = library.id  
inner join tooleping on palk_kaart.lepingId = tooleping.id 
inner join library amet on amet.id = tooleping.ametid  
inner join library osakond on osakond.id = tooleping.osakondid   
left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20)  
where status > 0 and lepingid = 138203
order by liik, case when coalesce(palk_lib.tululiik,'99') = '' then '99' else tululiik end, Palk_kaart.percent_ desc

select * from  palk_kaart where status > 0 and lepingid = 131844

select * from tmp_viivis 
order by dkpv desc
limit 100

delete from tmp_viivis

select * from palk_lib where parentid = 284099
*/