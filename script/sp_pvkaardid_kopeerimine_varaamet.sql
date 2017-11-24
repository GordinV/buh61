-- Function: sp_pvkaardid_kopeerimine(integer)
/*
select sp_pvkaardid_ja_saldo_kopeerimine(2)

select * from curPohivara where rekvid  in (6,28)  
and kood = 'H155100-1'
order by kood, rekvid

SELECT * FROM LIBRARY where kood = 'H155100-1'
select * from pv_kaart where parentid = 615423

select * from library where id = 35676


select * from tmp_subkontod_report where timestamp = '201305074134876'
*/
-- DROP FUNCTION sp_pvkaardid_kopeerimine(integer);

CREATE OR REPLACE FUNCTION sp_pvkaardid_ja_saldo_kopeerimine(integer)
  RETURNS integer AS
$BODY$

declare
	tnOpt alias for $1;

	lnNomMahaId int;
	lnNomPaigId int;
	lnPvOperId int;
	v_dokvaluuta record;
	lnId int; 
	lrPvKaardid record;
	ldKpv date;
	ldSoetKpv date;
	lcKood varchar(20);
	lcVanaKood varchar(20);
	lnTaastamine int;
	lnHind numeric(14,6);
	lnSoetmaks numeric(14,6);
	lnKulum numeric(14,6);
	lnAlgKulum numeric(14,6);
	lnUmberHind int;
	lnJournalId int;
	lnJournal1Id int;

	lcresult varchar(20);
	v_query record;
	v_subquery record;
	lcTp varchar(20);
	lnGruppId integer;
	v_lib record;
begin

ldKpv = date(2013,03,31);

if tnOpt = 1 then
	-- saldo
	-- koostame saldoandmik 1%
	lcResult = sp_subkontod_report('1%', 6, ldKpv, ldKpv, 0, '%', 3, 0);
		raise notice 'lcResult %',lcResult;
		for v_subquery in
			select  konto, algjaak, asutusId from tmp_subkontod_report where timestamp = lcResult and konto in (
				'102060','102090','102160','102190','103000','103009','103100','103250','103500','103799','103860','103930','103931',
				'103932','103990','154000','154010','155000','155100','155101','155106','155109','155110','155111','155116','155119','155400','155410','155600',
				'155610','155900','155910'
			) and algjaak <> 0
		loop
			select tp into lcTp from asutus where id = v_subquery.asutusid;
			lcTp = ifnull(lcTp,'800599');
			raise notice 'v_subquery.konto %, v_subquery.algjaak %, v_subquery.asutusid %',v_subquery.konto, v_subquery.algjaak, v_subquery.asutusid;
			-- kostame lausend
			lnJournalId = sp_salvesta_journal(0, 6, 60, ldKpv+90, v_subquery.asutusid, 'Saldo uleandmine',' ', 'Teostaja v.Gordin', 0, ' ');
			if ifnull(lnJournalId,0) > 0 then
				raise notice 'Lausendinumber : lnJournalId %',lnJournalId;
				lnJournal1Id = sp_salvesta_journal1(0, lnJournalId, v_subquery.algjaak, ' ', ' ', ' ', ' ', ' ', ' ', ' ', '710010','18510128', v_subquery.konto, lcTP, 'EUR', 1, v_subquery.algjaak, ' ', ' ');
				raise notice 'Lausendidetail : lnJournal1Id %',lnJournal1Id;
				if ifnull(lnJournal1Id,0) = 0 then
					raise exception 'Viga ';
				end if;
			else
				raise exception 'Lausend ei salvestatud';
			end if;
			-- kostame vastus lausend
			lnJournalId = sp_salvesta_journal(0, 28, 60, ldKpv+90, v_subquery.asutusid, 'Saldo vastuvotmine',' ', 'Teostaja v.Gordin', 0, ' ');
			if ifnull(lnJournalId,0) > 0 then
				raise notice 'Lausendinumber : lnJournalId %',lnJournalId;
				lnJournal1Id = sp_salvesta_journal1(0, lnJournalId, v_subquery.algjaak, ' ', ' ', ' ', ' ', ' ', ' ', ' ',v_subquery.konto, lcTP, '700010', '18510106', 'EUR', 1, v_subquery.algjaak, ' ', ' ');
				raise notice 'Lausendidetail : lnJournal1Id %',lnJournal1Id;
				if ifnull(lnJournal1Id,0) = 0 then
					raise exception 'Viga ';
				end if;
			else
				raise exception 'Lausend ei salvestatud';
			end if;
			
		end loop;


	-- koostame saldoandmik 2%
	lcResult = sp_subkontod_report('2%', 6, ldKpv, ldKpv, 0, '%', 3, 0);
		raise notice 'lcResult %',lcResult;
		for v_subquery in
			select  konto, algjaak, asutusId from tmp_subkontod_report where timestamp = lcResult and konto in (
				'201000','201010','202010','203000','203620','203900'
				) and algjaak <> 0

		loop
			raise notice 'v_subquery.konto %, v_subquery.algjaak %, v_subquery.asutusid %',v_subquery.konto, v_subquery.algjaak, v_subquery.asutusid;
			-- kostame lausend
			lnJournalId = sp_salvesta_journal(0, 6, 60, ldKpv+90, v_subquery.asutusid, 'Saldo uleandmine',' ', 'Teostaja v.Gordin', 0, ' ');
			if ifnull(lnJournalId,0) > 0 then
				raise notice 'Lausendinumber : lnJournalId %',lnJournalId;
				lnJournal1Id = sp_salvesta_journal1(0, lnJournalId, -1*v_subquery.algjaak, ' ', ' ', ' ', ' ', ' ', ' ', ' ', v_subquery.konto, lcTP, '710010', '18510128', 'EUR', 1, -1*v_subquery.algjaak, ' ', ' ');
				raise notice 'Lausendidetail : lnJournal1Id %',lnJournal1Id;
				if ifnull(lnJournal1Id,0) = 0 then
					raise exception 'Viga ';
				end if;
			else
				raise exception 'Lausend ei salvestatud';
			end if;
			-- kostame vastus lausend
			lnJournalId = sp_salvesta_journal(0, 28, 60, ldKpv+90, v_subquery.asutusid, 'Saldo vastuvotmine',' ', 'Teostaja v.Gordin', 0, ' ');
			if ifnull(lnJournalId,0) > 0 then
				raise notice 'Lausendinumber : lnJournalId %',lnJournalId;
				lnJournal1Id = sp_salvesta_journal1(0, lnJournalId, -1*v_subquery.algjaak, ' ', ' ', ' ', ' ', ' ', ' ', ' ','700010', '18510106', v_subquery.konto, lcTP, 'EUR', 1,-1* v_subquery.algjaak, ' ', ' ');
				raise notice 'Lausendidetail : lnJournal1Id %',lnJournal1Id;
				if ifnull(lnJournal1Id,0) = 0 then
					raise exception 'Viga ';
				end if;
			else
				raise exception 'Lausend ei salvestatud';
			end if;
			
		end loop;

	
	/*
	for v_query in 
		select library.kood from library 
		where library = 'KONTOD' and kood in ('102060','102090','102160','102190','103000','103009','103100','103250','103500','103799','103860','103930','103931',
			'103932','103990','154000','154010','155000','155100','155101','155106','155109','155110','155111','155116','155119','155400','155410','155600',
			'155610','155900','155910')
	loop		
		lcResult = sp_subkontod_report(v_query.kood, 6, ldKpv, ldKpv, 0, '%', 3, 0);
		raise notice 'lcResult %',lcResult;
		for v_subquery in
			select  konto, algjaak, asutusId from tmp_subkontod_report where timestamp = lcResult
		loop
			raise notice 'v_subquery.konto %, v_subquery.algjaak %, v_subquery.asutusid %',v_subquery.konto, v_subquery.algjaak, v_subquery.asutusid;
		end loop;
	end loop;
	*/

end if;
if tnOpt = 2 then

lnTaastamine = 0;
ldKpv = date(2013,03,31);
-- uus nom. operatsioon
lnId = 0;
select id into lnNomMahaId from nomenklatuur where rekvid = 6 and kood = 'PVMAHA' order by id desc limit 1;

if ifnull(lnNomMahaId,0) = 0 then
	-- operatsioon puudub, lisame
	lnNomMahaId = sp_salvesta_nomenklatuur(0, 6, 0, 'MAHAKANDMINE','PVMAHA', 'PV kaardid mahakandmine', '', 0, 'Rahandusameti korraldus',0, 0, '', 'EUR', 1);
end if;

select id into lnNomPaigId from nomenklatuur where rekvid = 28 and kood = 'PVPAIG' order by id desc limit 1;
if ifnull(lnNomPaigId,0) = 0 then
	-- operatsioon puudub, lisame
	lnNomPaigId = sp_salvesta_nomenklatuur(0, 28, 0, 'PAIGUTUS','PVPAIG', 'PV kaardid paigaldamine', '', 0, 'Rahandusameti korraldus',0, 0, '', 'EUR', 1);
end if;

-- koostame pv minekiri
	raise notice 'Koostame PV kaardide nimekiri';

-- nullime lausendide kontrol
--	update rekv set recalc = 0 where id = tnRekvId;
--	select recalc into lnKontrol from rekv where id = v_pv_kaart.rekvid;

for lrPvKaardid  in
	select * from curPohivara where rekvid = 6 and tunnus = 1 and kulum = 0
loop
	raise notice 'PV kaart: %',lrPvKaardid.kood;
--	lnId = 1;
	-- mahandmine
	lnPvOperId = sp_salvesta_pv_oper(0, lrPvKaardid.id, lnNomMahaId, 0, 4, ldKpv, lrPvKaardid.parhind, 'Mahakandmine, rahandusameti korralduse alusel', '', '', '', '', '', '', '', 0, '', 'MAHA', 'EUR', 1);

	if ifnull(lnPvOperId,0) = 0 then
		raise exception 'Mahakandmine ebaonnestus';
	end if;
	-- konteerimine
/*
	select jaak into lnHind from pv_kaart where parentid = lrPvKaardid.id;
	if ifnull(lnHind,0) > 0 and not empty (lrPvKaardid.konto) then 
		if lrPvKaardid.valuuta = 'EEK' then
			lnHind = round(lnHind / 15.6466,2);
		end if;

		lnJournalId:= sp_salvesta_journal(0, tnRekvId, 9999, ldkpv, 0, 'Mahakandmine, rahandusameti korralduse alusel'::varchar, 'Inv.number '+lrPvKaardid.kood::varchar,''::varchar,lnPvOperId) ;
	
		lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,lnHind,''::varchar,''::text,
				''::varchar,''::varchar,''::varchar,''::varchar,''::varchar,
				'888888'::varchar,''::varchar,lrPvKaardid.konto::varchar,''::varchar,'EUR'::varchar,15.6466::numeric,lnHind::numeric,
				''::varchar,''::varchar);
		update pv_oper set journalid = lnJournalId where id = lnPvOperId;

	end if;

	-- muutume pv kaardi kood
	lcKood = ltrim(rtrim(left(lcVanaKood,16)))+'-EEK';
	update library set kood = lcKood where id = lrPvKaardid.id;
*/
	lcVanaKood = ltrim(rtrim(lrPvKaardid.kood));

	-- uus kaart

	insert into library (rekvid, kood, nimetus, library, muud, tun1, tun2, tun3, tun4, tun5) 
		select 28 ,lcVanaKood, nimetus, library, muud, tun1, tun2, tun3, tun4, lrPvKaardid.id from library where id = lrPvKaardid.id;

	select id into lnId from library order by id desc limit 1;

	-- arvestame summad	-- kulum
	lnUmberHind = 0;
	lnAlgKulum = lrPvKaardid.algkulum;
	ldSoetKpv = lrPvKaardid.soetkpv;
	if (select count(id) from pv_oper where parentid = lrPvKaardid.id and liik = 1) > 0 then
		select kpv into ldSoetKpv from pv_oper where parentid = lrPvKaardid.id and liik = 1 order by id desc limit 1;
	end if; 

	if (select count(id) from pv_oper where parentid = lrPvKaardid.id and liik = 5) > 0 then
		select kpv into ldSoetKpv from pv_oper where parentid = lrPvKaardid.id and liik = 5 order by id desc limit 1;
		lnUmberHind = 1;		
	end if; 

	SELECT sum (Pv_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric) into lnKulum 
		FROM Pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13) 
		WHERE Pv_oper.parentid = lrPvKaardid.id 
		AND Pv_oper.liik = 2 
		and kpv > ldSoetKpv;


		if lnUmberHind = 1 then
			lnAlgKulum = 0;
		end if;

	-- Soetmaks
	lnSoetmaks = lrPvKaardid.parhind;
	lnKulum = ifnull(lnKulum,0) / 1 + lnAlgkulum;

	-- pv_grupp
	
	if (select count(id) from library where tun5 = lrPvKaardid.gruppid) = 0 then
		-- salvestame varaameti pv grupp
		select * into v_lib from library where id = lrPvKaardid.gruppid ;             
		lnGruppId = sp_salvesta_library(0, 28, v_lib.kood, v_lib.nimetus, v_lib.library, v_lib.muud, v_lib.tun1, v_lib.tun2, v_lib.tun3, v_lib.tun4, lrPvKaardid.gruppid);
	else
		select id into 	lnGruppId from library where tun5 = lrPvKaardid.gruppid;
	end if;
	
	if ifnull(lnGruppId,0) = 0 then
		raise exception 'Pv grupp ei leidnud';
	end if;
	insert into pv_kaart (parentid, vastisikid, soetmaks, soetkpv, kulum, algkulum, gruppid, konto, tunnus, mahakantud, otsus,  muud , parhind , jaak)
		select 	lnid, vastisikid, lnSoetmaks, soetkpv, kulum, lnKulum, lnGruppId, konto, 1, null, otsus,  muud , lnSoetmaks , lnSoetmaks from pv_kaart
			where parentid = lrPvKaardid.id;

--	lnHind = lrPvKaardid.parhind;		

	lnPvOperId = sp_salvesta_pv_oper(0, lnid, lnNomPaigId, 0, 1, ldKpv, lnSoetmaks, 'Paigaldamine, rahandusameti korralduse alusel', '', '', '', '', '', '', '', 0, '', 'PAIG', 'EUR', 1);

-- konteerimine
/*
	if ifnull(lnHind,0) > 0  and not empty(lrPvKaardid.konto) then
		lnJournalId:= sp_salvesta_journal(0, tnRekvId, 9999, ldkpv, 0, 'Paigaldamine, rahandusameti korralduse alusel'::varchar, 'Inv.number '+lrPvKaardid.kood::varchar,''::varchar,lnPvOperId) ;

		lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,lnHind,''::varchar,''::text,
				''::varchar,''::varchar,''::varchar,''::varchar,''::varchar,
				lrPvKaardid.konto::varchar,''::varchar,'888888'::varchar,''::varchar,'EUR'::varchar,15.6466::numeric,lnHind,
				''::varchar,''::varchar);
		update pv_oper set journalid = lnJournalId where id = lnPvOperId;
	end if;
*/

end loop;
end if;
if tnOpt = 3 then
-- taastamine
	raise notice 'Taastamine';
	select id into lnNomMahaId from nomenklatuur where rekvid = 6 and kood = 'PVMAHA' order by id desc limit 1;

	-- koostame nimekiri
	for lrPvKaardid  in
		select * from curPohivara where rekvid = 6 and tunnus = 0 and kulum > 0 and mahakantud = date(2013,03,31) 
	loop

		raise notice 'PV kaart: %',lrPvKaardid.kood;
--		-- operatsioon
		select id into lnId from pv_oper where parentid = lrPvKaardid.id and liik = 4 and nomid = lnNomMahaId and kpv = ldKpv;
		if ifnull(lnId,0) > 0 then
			-- leitud
			delete from pv_oper where id = lnId;
		end if;
		-- kustutame uus kaart
		select id into lnId from library where tun5 =  lrPvKaardid.id;

		if ifnull(lnId,0) > 0 then

			raise notice 'kustutan PV kaart: %',lnId;
--

			delete from pv_kaart where parentid = lnId;
			delete from pv_oper where parentid = lnId;
			delete from library where id = lnId;
		end if;

	end loop;

end if;



return lnId;
         
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sp_pvkaardid_kopeerimine(integer)
  OWNER TO vlad;
