-- Function: sp_pvkaardid_kopeerimine(integer)

DROP FUNCTION sp_pvkaardid_kopeerimine(integer);

CREATE OR REPLACE FUNCTION sp_pvkaardid_kopeerimine(integer)
  RETURNS integer AS
$BODY$

declare
	tnrekvid alias for $1;

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
begin

lnTaastamine = 0;
ldKpv = date(2011,09,30);
-- uus nom. operatsioon
lnId = 0;
select id into lnNomMahaId from nomenklatuur where rekvid = tnRekvId and kood = 'PVMAHA' order by id desc limit 1;

if ifnull(lnNomMahaId,0) = 0 then
	-- operatsioon puudub, lisame
	lnNomMahaId = sp_salvesta_nomenklatuur(0, tnRekvId, 0, 'MAHAKANDMINE','PVMAHA', 'PV kaardid mahakandmine', '', 0, '',0, 0, '', 'EUR', 1);
end if;

select id into lnNomPaigId from nomenklatuur where rekvid = tnRekvId and kood = 'PVPAIG' order by id desc limit 1;
if ifnull(lnNomPaigId,0) = 0 then
	-- operatsioon puudub, lisame
	lnNomPaigId = sp_salvesta_nomenklatuur(0, tnRekvId, 0, 'PAIGUTUS','PVPAIG', 'PV kaardid paigaldamine', '', 0, 'Rahandusameti korraldus',0, 0, '', 'EUR', 1);
end if;

if lnTaastamine = 0 then
-- koostame pv minekiri
	raise notice 'Koostame PV kaardide nimekiri';

-- nullime lausendide kontrol
	update rekv set recalc = 0 where id = tnRekvId;
--	select recalc into lnKontrol from rekv where id = v_pv_kaart.rekvid;

for lrPvKaardid  in
	select * from curPohivara where rekvid = 28 
		and tunnus = 1 
		and (kood not in ('S155400-01', 'S155400-02','MUU-0001','MUU-0008','MUU-0009')
		or konto not in ('155500')
		)
loop
	raise notice 'PV kaart: %',lrPvKaardid.kood;
--	lnId = 1;

	lnPvOperId = sp_salvesta_pv_oper(0, lrPvKaardid.id, lnNomMahaId, 0, 4, ldKpv, lrPvKaardid.parhind, 'Mahakandmine, rahandusameti korralduse alusel', '', '', '', '', '', '', '', 0, '', 'MAHA', 'EUR', 15.6466);

	-- konteerimine

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
	lcVanaKood = ltrim(rtrim(lrPvKaardid.kood));
	lcKood = ltrim(rtrim(left(lcVanaKood,16)))+'-EEK';
	update library set kood = lcKood where id = lrPvKaardid.id;

	-- uus kaart

	insert into library (rekvid, kood, nimetus, library, muud, tun1, tun2, tun3, tun4, tun5) 
		select rekvid,lcVanaKood, nimetus, library, muud, tun1, tun2, tun3, tun4, lrPvKaardid.id from library where id = lrPvKaardid.id;

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
	if lrPvKaardid.valuuta = 'EUR' then
		lnSoetmaks = lrPvKaardid.parhind;
		lnKulum = ifnull(lnKulum,0) / 15.6466 + lnAlgkulum;
	else
		lnSoetmaks = lrPvKaardid.parhind / 15.6466;
		lnKulum = (ifnull(lnKulum,0) + lnAlgkulum)/ 15.6466;
	end if;

	

	insert into pv_kaart (parentid, vastisikid, soetmaks, soetkpv, kulum, algkulum, gruppid, konto, tunnus, mahakantud, otsus,  muud , parhind , jaak)
		select 	lnid, vastisikid, lnSoetmaks, soetkpv, kulum, lnKulum, gruppid, konto, 1, null, otsus,  muud , lnSoetmaks , lnSoetmaks from pv_kaart
			where parentid = lrPvKaardid.id;

--	lnHind = lrPvKaardid.parhind;		

	lnPvOperId = sp_salvesta_pv_oper(0, lnid, lnNomPaigId, 0, 1, ldKpv, lnSoetmaks, 'Paigaldamine, rahandusameti korralduse alusel', '', '', '', '', '', '', '', 0, '', 'PAIG', 'EUR', 15.6466);

-- konteerimine
	if ifnull(lnHind,0) > 0  and not empty(lrPvKaardid.konto) then
		lnJournalId:= sp_salvesta_journal(0, tnRekvId, 9999, ldkpv, 0, 'Paigaldamine, rahandusameti korralduse alusel'::varchar, 'Inv.number '+lrPvKaardid.kood::varchar,''::varchar,lnPvOperId) ;

		lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,lnHind,''::varchar,''::text,
				''::varchar,''::varchar,''::varchar,''::varchar,''::varchar,
				lrPvKaardid.konto::varchar,''::varchar,'888888'::varchar,''::varchar,'EUR'::varchar,15.6466::numeric,lnHind,
				''::varchar,''::varchar);
		update pv_oper set journalid = lnJournalId where id = lnPvOperId;
	end if;


end loop;

else
	-- taastamine
		raise notice 'Taastamine';

	-- koostame nimekiri
	for lrPvKaardid  in
		select * from curPohivara where rekvid = tnRekvId and tunnus = 0 and kulum > 0 and kood like '%-EEK%'
	loop

		raise notice 'PV kaart: %',lrPvKaardid.kood;
--		-- operatsioon
		select id into lnId from pv_oper where parentid = lrPvKaardid.id and liik = 4 and nomid = lnNomMahaId and kpv = ldKpv;
		if ifnull(lnId,0) > 0 then
			-- leitud
			delete from pv_oper where id = lnId;
			-- muutume kood
			lcKood = substring(lrPvKaardid.kood,1,len(ltrim(rtrim(lrPvKaardid.kood)))-4);
			raise notice 'PV kaardi kood taastamine: %',lckood;

			update library set kood = lcKood where id = lrPvKaardid.id;
		end if;
		-- kustutame uus kaart
		select id into lnId from library where tun5 =  lrPvKaardid.id;

		if ifnull(lnId,0) > 0 then

			raise notice 'kustutan PV kaart: %',lnId;
--
			select journalid into lnJournalId from pv_oper where parentid = lnId order by id desc limit 1;

			delete from pv_kaart where parentid = lnId;
			delete from pv_oper where parentid = lnId;
			delete from library where id = lnId;
			if ifnull(lnJournalId,0) > 0 then
				delete from journal where id = lnJournalId;
				delete from journal1 where parentid = lnJournalId;
			end if;
		end if;

	end loop;
end if;

update rekv set recalc = 1 where id = tnRekvId;

return lnId;
         
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sp_pvkaardid_kopeerimine(integer)
  OWNER TO vlad;
