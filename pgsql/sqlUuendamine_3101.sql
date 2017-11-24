-- Function: fnc_avansijaak(integer)

-- DROP FUNCTION fnc_avansijaak(integer);
/*
select *from avans1 where number = '1' and rekvid = 63 and year(kpv) = 2011
select * from avans3 where parentid = 15573

select * from curJournal where id in (3748079, 3258864)

select fnc_avansijaak(avans1.id) from avans1 where year(kpv) = 2011
*/

CREATE OR REPLACE FUNCTION fnc_avansijaak(integer)
  RETURNS numeric AS
$BODY$


declare 
	tnId	ALIAS FOR $1;
	lnTasuSumma numeric(14,2);
	lnSumma numeric(14,2);
	v_avans record;
	lnDokValuuta numeric(14,2);
	lnId int;
	ldKpv date;
BEGIN

select id into lnId from avans2 where parentid = tnId order by id limit 1;
--raise notice 'LnId %',lnId;

select dokvaluuta1.kuurs into lnDokValuuta from dokvaluuta1 where dokid = lnId and dokliik = 5;
lnDokValuuta = ifnull(lnDokValuuta,1);
--raise notice 'lnDokValuuta %',lnDokValuuta;

-- summa, korkonto
select ifnull(dokprop.konto,space(20)) as konto,avans1.asutusId, avans1.rekvId, avans1.number, avans1.kpv into v_avans
	from avans1 left outer join dokprop on dokprop.id = avans1.dokpropId
	where avans1.id = tnId;

-- tasumine via päevaraamat

delete from avans3 where parentid = tnId and liik = 1;


insert into avans3 (parentid,dokid,liik, muud, summa )
select tnId, journal.id,1,'JOURNAL',(journal1.summa*ifnull(dokvaluuta1.kuurs,1))	
	from journal1 inner join journal on journal.id = journal1.parentId 
	left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
	where journal.rekvid = v_avans.rekvid
	and journal.asutusId = v_avans.AsutusId
	and ltrim(rtrim(journal.dok)) = v_avans.number
	and year(journal.kpv) = year(v_avans.Kpv)
	and ltrim(rtrim(journal1.deebet)) = ltrim(rtrim(v_avans.konto));



select sum(summa) into lnTasuSumma from avans3 where parentid = tnId;
raise notice 'lnTasuSumma %',lnTasuSumma;


select sum(summa) into lnSumma from avans2 where parentid = tnId;

update avans1 set jaak = ifnull(lnSumma,0) - ifnull(lnTasuSumma,0)/lnDokValuuta where id = tnId;

RETURN (ifnull(lnSumma,0) - ifnull(lnTasuSumma,0)/lnDokValuuta);


end;




$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_avansijaak(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO dbpeakasutaja;

-- View: curjournal
/*

 SELECT sum(curjournal.summa * curjournal.kuurs) 
   FROM curjournal
   JOIN kassatulud ON ltrim(rtrim(curjournal.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(curjournal.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
   JOIN rekv ON curjournal.rekvid = rekv.id
where rekvid = 63 and curjournal.kood5 like '352%'
   ;
   
 SELECT sum(curjournal.summa * curjournal.kuurs) 
   FROM curjournal 
where rekvid = 63 and curjournal.kood5 like '352%'
   ;


*/
-- DROP VIEW curjournal;

CREATE OR REPLACE VIEW curjournal AS 
 SELECT journal.id, journal.rekvid, journal.kpv, journal.asutusid, month(journal.kpv) AS kuu, year(journal.kpv) AS aasta, 
 journal.selg::character varying(254) AS selg, journal.dok, journal1.summa, journal1.valsumma, 
 ifnull(dokvaluuta1.valuuta,'EEK')::character varying(20) as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric(12,6) as kuurs, 
 journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood4, journal1.kood5, journal1.proj, journal1.deebet, journal1.kreedit, 
 journal1.lisa_d, journal1.lisa_k, ifnull(ltrim(rtrim(asutus.nimetus::text))::bpchar + space(1) + ltrim(rtrim(asutus.omvorm::text))::bpchar, space(120)) AS asutus, 
 journal1.tunnus, journalid.number
   FROM journal
   JOIN journal1 ON journal.id = journal1.parentid
   JOIN journalid ON journal.id = journalid.journalid
   LEFT JOIN asutus ON journal.asutusid = asutus.id
   left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1);

ALTER TABLE curjournal OWNER TO vlad;
GRANT SELECT ON TABLE curjournal TO dbkasutaja;
GRANT SELECT ON TABLE curjournal TO dbpeakasutaja;
GRANT SELECT ON TABLE curjournal TO dbvaatleja;

-- Function: sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)

/*
select * from palk_config

select sp_salvesta_palk_config(0, 110, 278::numeric, 144::numeric, 0::integer, 0::integer, 1::integer, 0::integer, 
	'EUR':: character varying, 15.6466::numeric) 

	from palk_config 

select * from rekv where id not in (select rekvid from palk_config)

*/
CREATE OR REPLACE FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnMinpalk alias for $3;
	tntulubaas alias for $4;
	tnround alias for $5;
	tnjaak alias for $6;
	tngenlausend alias for $7;
	tnsuurasu alias for $8;
	tcvaluuta alias for $9;
	tnKuurs alias for $10;

	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into palk_config (  rekvid, minpalk, tulubaas, round, jaak, genlausend, suurasu) 
		values (tnrekvid, tnminpalk, tntulubaas, tnround, tnjaak, tngenlausend, tnsuurasu);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnId:= cast(CURRVAL('public.palk_config_id_seq') as int4);
	else
		lnId = 0;
	end if;

	if lnId = 0 then
		raise exception 'Viga:%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (26, lnId,tcValuuta, tnKuurs);


else
	-- muuda 
	update palk_config set 
		 rekvid = tnRekvId, 
		 minpalk = tnMinPalk, 
		 tulubaas = tnTulubaas, 
		 round = tnRound, 
		 jaak = tnJaak, 
		 genlausend = tnGenLausend, 
		 suurasu = tnSuurasu
		where id = tnId;

	lnId := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 26 and dokid = lnId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (26, tnId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 26 and dokid = tnId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;

	
end if;


         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric) TO dbpeakasutaja;

-- View: qrykassatulutaitm

 DROP VIEW qrykassatulutaitm;

CREATE OR REPLACE VIEW qrykassatulutaitm AS 
 SELECT curjournal.kpv, curjournal.rekvid, rekv.nimetus, curjournal.tunnus AS tun,  curjournal.summa * curjournal.kuurs::numeric as summa, curjournal.kood5 AS kood, space(1) AS eelarve, curjournal.kood1 AS tegev
   FROM curjournal
   JOIN kassatulud ON ltrim(rtrim(curjournal.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
   JOIN kassakontod ON ltrim(rtrim(curjournal.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
   JOIN rekv ON curjournal.rekvid = rekv.id;

ALTER TABLE qrykassatulutaitm OWNER TO vlad;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbpeakasutaja;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbkasutaja;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbadmin;
GRANT SELECT ON TABLE qrykassatulutaitm TO dbvaatleja;


CREATE OR REPLACE FUNCTION sp_salvesta_vanemtasu4(integer, integer, integer, character varying, character varying, integer, numeric, numeric, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text,character varying,numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnisikid alias for $3;
	tcmaksjakood alias for $4;
	tcmaksjanimi alias for $5;
	tnnomid alias for $6;
	tnkogus alias for $7;
	tnhind alias for $8;
	tnsumma alias for $9;
	tckonto alias for $10;
	tctp alias for $11;
	tckood1 alias for $12;
	tckood2 alias for $13;
	tckood3 alias for $14;
	tckood4 alias for $15;
	tckood5 alias for $16;
	ttmuud alias for $17;
	tcValuuta alias for $18;
	tnKuurs alias for $19;

	lnvanemtasu4Id int;

	lnId int; 

	lrCurRec record;
	v_dokvaluuta record;

begin



if tnId = 0 then

	-- uus kiri

	insert into vanemtasu4 (parentid,isikid,maksjakood,maksjanimi,nomid,kogus,hind,summa,konto,tp,kood1,kood2,kood3,kood4,kood5,muud) 
		values (tnparentid,tnisikid,tcmaksjakood,tcmaksjanimi,tnnomid,tnkogus,tnhind,tnsumma,tckonto,tctp,tckood1,tckood2,tckood3,tckood4,tckood5,ttmuud);

	lnvanemtasu4Id:= cast(CURRVAL('public.vanemtasu4_id_seq') as int4);

	
	-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lnvanemtasu4Id,16,tcValuuta, tnKuurs);




else

	-- muuda 
	select * into lrCurRec from vanemtasu4 where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.isikid <> tnisikid or lrCurRec.maksjakood <> tcmaksjakood or lrCurRec.maksjanimi <> tcmaksjanimi or lrCurRec.nomid <> tnnomid or lrCurRec.kogus <> tnkogus or lrCurRec.hind <> tnhind or lrCurRec.summa <> tnsumma or lrCurRec.konto <> tckonto or lrCurRec.tp <> tctp or lrCurRec.kood1 <> tckood1 or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) then 
	update vanemtasu4 set 
		parentid = tnparentid,
		isikid = tnisikid,
		maksjakood = tcmaksjakood,
		maksjanimi = tcmaksjanimi,
		nomid = tnnomid,
		kogus = tnkogus,
		hind = tnhind,
		summa = tnsumma,
		konto = tckonto,
		tp = tctp,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		muud = ttmuud

	where id = tnId;

	end if;

	lnvanemtasu4Id := tnId;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 16 and dokid = lnvanemtasu4Id) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (16, lnvanemtasu4Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 16 and dokid = lnvanemtasu4Id ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then
			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;						
		end if;
	end if;

end if;



         return  lnvanemtasu4Id;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_vanemtasu4(integer, integer, integer, character varying, character varying, integer, numeric, numeric, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text,character varying,numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_vanemtasu4(integer, integer, integer, character varying, character varying, integer, numeric, numeric, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text,character varying,numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_vanemtasu4(integer, integer, integer, character varying, character varying, integer, numeric, numeric, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, text,character varying,numeric) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE tcKonto alias for $1;
	tnrekvid alias for $2;
	tdKpv1 alias for $3;
	tdKpv2 alias for $4;
	tnAsutus alias for $5;
	tcTunnus alias for $6;
	tnOpt alias for $7;
	tnSvod alias for $8;
	lcReturn varchar;
	lnId int;
	lnDb numeric (14,2);
	lnKr numeric (14,2);
	lnAlg numeric (14,2);
	lnLopp numeric (14,2);
	lnAsutusId1 int;
	lnAsutusId2 int;
	v_kaibed record;
	v_saldo record;
	v_account record;
	v_tunnus record;
	lnCount int;


begin


	if tnAsutus > 0 then
		lnAsutusId1 := tnAsutus;
		lnAsutusId2 := tnAsutus;
	else
		lnAsutusId1 := 0;
		lnAsutusId2 := 99999999;
	end if;

	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_SUBKONTOD_REPORT';
	if ifnull(lnCount,0) < 1 then

		create table tmp_subkontod_report (id serial, asutusId int default 0, Asutus varchar(254) default space(1), regkood varchar(20) default space(1), 
			aadress text default space(1), konto varchar(20) default space(1), korkonto varchar(20) default space(1),
			tunnus varchar(20) default space(1), dokkpv date default date(),
			algjaak numeric (14,2) default 0, db numeric(14,2) default 0, kr numeric(14,2) default 0, loppjaak numeric(14,2) default 0,
			kood1 varchar(20) default space(1), kood2 varchar(20) default space(1), kood3 varchar(20) default space(1),
			kood4 varchar(20) default space(1), kood5 varchar(20) default space(1), dok varchar(120) default space(1),
			lausend int default 0, 
			timestamp varchar(20) , kpv date default date(), rekvid int )  ;


		GRANT ALL ON TABLE tmp_subkontod_report TO GROUP public;
	else
		delete from tmp_subkontod_report where kpv < date() ;

	end if;

	lcreturn := to_char(now(), 'YYYYMMDDMISSSS');

-- lisatud 27/08/2008 kondaruanne koostamine

if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMPREKV')  > 0 then
	delete from tmpRekv;
--	truncate TABLE tmpRekv;
	insert into tmpRekv
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv;
else
	CREATE TABLE tmpRekv AS
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv;
		GRANT ALL ON TABLE tmpRekv TO GROUP public;

END IF;

if tnSvod = 1 then
	delete from tmpRekv where tase < 3;

else
	delete from tmpRekv where tase in (0,1,2,4);
end if;




	-- matrix of subkontod

	if tnOpt < 5 then

		insert into tmp_subkontod_report (konto, asutusId,  regkood , Asutus, Aadress, algjaak, timestamp, rekvid )  
		select kontod.kood, asutus.id, asutus.regkood, asutus.nimetus as asutus, asutus.aadress, sum(subkonto.algsaldo) ,
		lcReturn, tnRekvId 
		from library kontod inner join subkonto  on (subkonto.kontoid = kontod.id and kontod.library = 'KONTOD') 
		inner join asutus on asutus.id = subkonto.asutusId
		where kontod.kood like tcKonto 
		and subkonto.rekvid in (select id from tmprekv)
		and subkonto.asutusId >= lnAsutusId1 and subkonto.asutusId <= lnAsutusid2 
		group by   kontod.kood,asutus.id, asutus.regkood, asutus.nimetus, asutus.aadress;

	else

		insert into tmp_subkontod_report (konto, asutusId,  regkood , Asutus, Aadress, algjaak, timestamp, rekvid, subrekvid )  
		select kontod.kood, asutus.id, asutus.regkood, asutus.nimetus as asutus, asutus.aadress, sum(subkonto.algsaldo) ,
		lcReturn, tnRekvId,subkonto.rekvid from library kontod inner join subkonto  on (subkonto.kontoid = kontod.id and kontod.library = 'KONTOD') 
		inner join asutus on asutus.id = subkonto.asutusId
		inner join tmprekv on subkonto.rekvId = tmprekv.id
		where (kontod.kood like '102%' or kontod.kood like '103%' or kontod.kood like '201%' or kontod.kood like '202%' or kontod.kood like '203%') 
		and subkonto.rekvid in (select id from tmprekv)
		and subkonto.asutusId >= lnAsutusId1 and subkonto.asutusId <= lnAsutusid2 
		group by  kontod.kood, subkonto.rekvid, asutus.id, asutus.regkood, asutus.nimetus, asutus.aadress;


	end if;


	if tnOpt = 1 then
		-- kaibeasutus andmik
		for v_account in 
			select konto, asutusId from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId
		loop

		-- kaibed
			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end) as kr into v_kaibed 
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus like tcTunnus
				and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id
				where kpv >= tdKpv1 and kpv <= tdKpv2  and asutusId = v_account.asutusid);

			-- algkaibed

			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
				from journal1  left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus like tcTunnus
				and parentId in (select journal.id from journal	inner join tmprekv on journal.rekvId = tmprekv.id 
				where journal.kpv < tdKpv1  
				 and JOURNAL.asutusId = v_account.asutusid);


			select algJaak into lnAlg from tmp_subkontod_report 
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

			lnAlg := ifnull(lnAlg,0) + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0);
			lnLopp := lnAlg + ifnull(v_kaibed.db,0) - ifnull(v_kaibed.kr,0);
	

			update 	tmp_subkontod_report set db = ifnull(v_kaibed.db,0),
				kr = ifnull(v_kaibed.kr,0),
				algjaak = lnAlg,
				loppjaak = lnLopp
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

		end loop;
		delete from tmp_subkontod_report where algjaak = 0 and db = 0 and kr = 0 and timestamp = lcreturn and rekvid = tnRekvId;

	end if;


	if tnOpt = 2 then
		-- konto andmik
		for v_account in 
			select konto, asutusId from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId
		loop

-- kanded deebet
-- muudetud 16/02/2005
	insert into tmp_subkontod_report (dokkpv,konto, asutusId,  regkood , Asutus, Aadress, db, kr, korkonto, dok, kood1, kood2, kood3, kood4, 
	kood5, lausend, timestamp, rekvid, subrekvid, subrekvnimi )  
	select journal.kpv, v_account.konto, asutus.id, asutus.regkood, asutus.nimetus as asutus, asutus.aadress, 
		(journal1.summa*ifnull(dokvaluuta1.kuurs,1)), 0,
		journal1.kreedit, journal.dok, journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood4, journal1.kood5,
		journalid.number, lcReturn, tnrekvid, rekv.Id, rekv.nimetus 
		from journal inner join journal1 on journal.id = journal1.parentid
		left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
		inner join journalId on journal.id = journalId.journalId
		inner join asutus on asutus.id = journal.asutusId
		inner join tmprekv on journal.rekvId = tmprekv.id
		inner join rekv on journal.rekvid = rekv.id 
		where ltrim(rtrim(journal1.deebet)) = ltrim(rtrim(v_account.konto))
		and journal.asutusId = v_account.asutusId 
		and journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2;

-- kanded kreedit
-- muudetud 16/02/2005
	insert into tmp_subkontod_report (dokkpv, konto, asutusId,  regkood , Asutus, Aadress, db, kr, korkonto, dok, kood1, kood2, kood3, kood4, 
	kood5, lausend, timestamp, rekvid, subrekvid, subrekvnimi )  
	select journal.kpv, v_account.konto, asutus.id, asutus.regkood, asutus.nimetus as asutus, asutus.aadress,
		0, (journal1.summa*ifnull(dokvaluuta1.kuurs,1)), 
		journal1.deebet, journal.dok, journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood4, journal1.kood5,
		journalid.number, lcReturn, tnrekvId, rekv.id, rekv.nimetus 
		from journal inner join journal1 on journal.id = journal1.parentid
		left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
		 inner join journalId on journal.id = journalId.journalId
		inner join asutus on asutus.id = journal.asutusId
		inner join tmprekv on journal.rekvId = tmprekv.id
		inner join rekv on journal.rekvid = rekv.id
		where ltrim(rtrim(journal1.kreedit)) = ltrim(rtrim(v_account.konto))
		and journal.asutusId = v_account.asutusid
		and journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2;

-- algjaak
	select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
		sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
		from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
		where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
		and tunnus like tcTunnus
		and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id where kpv < tdKpv1  
		and asutusId = v_account.asutusid);

-- algjaak
	select sum(db) as db, sum(kr) as kr into v_kaibed from tmp_subkontod_report 
		where timestamp = lcreturn 
		and rekvid = tnRekvId
		and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

	select algJaak into lnAlg from tmp_subkontod_report 
		where timestamp = lcreturn 
		and rekvid = tnRekvId
		and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

	lnAlg := ifnull(lnAlg,0) + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0);
	lnLopp := lnAlg + ifnull(v_kaibed.db,0) - ifnull(v_kaibed.kr,0);

	update 	tmp_subkontod_report set algjaak = lnAlg,
		loppjaak = lnLopp
		where timestamp = lcreturn 
		and rekvid = tnRekvId
		and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;
	end loop;

	delete from tmp_subkontod_report where algjaak = 0 and db = 0 and kr = 0 and timestamp = lcreturn and rekvid = tnRekvId;

	end if;

	if tnOpt = 3 then
		-- saldo andmik

		for v_account in 
			select konto, asutusId from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId and konto like tcKonto

		loop
			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus like tcTunnus
				and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id  
				where kpv <= tdKpv2 and asutusId = v_account.asutusid);
/*
			select algJaak into lnAlg from tmp_subkontod_report 
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;
			lnAlg := ifnull(lnAlg,0) + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0);

*/
			lnAlg := ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0);

-- delete from tmp_subkontod_report
-- select *from tmp_subkontod_report order by asutus
			update 	tmp_subkontod_report set algjaak = lnAlg
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;


		end loop;
		delete from tmp_subkontod_report where algjaak = 0  and timestamp = lcreturn and rekvid = tnRekvId;

	end if;


	if tnOpt = 4 then


		-- kaibeasutus andmik tunnuse jargi

		for v_account in 
			select konto, asutusId, asutus, regkood, aadress, algjaak from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId

		loop

			-- kaibed

		for v_tunnus in 

			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end) as db, 
			sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end) as kr,
			 ltrim(rtrim(tunnus)) as tunnus 
			from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
			where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
			and tunnus like tcTunnus
			and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id 
			where kpv >= tdKpv1 and kpv <= tdKpv2 and asutusId = v_account.asutusid)
			group by ltrim(rtrim(tunnus))

		loop

			-- algkaibed
			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus =  v_tunnus.tunnus 
				and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id where kpv < tdKpv1  
				and asutusId = v_account.asutusid);


			insert into tmp_subkontod_report (konto, tunnus, asutusId, regkood , Asutus, Aadress, db, kr, algjaak, loppjaak, timestamp, rekvid)
			values (v_account.konto,v_tunnus.tunnus, v_account.asutusId, v_account.regkood, v_account.asutus, v_account.aadress,
			ifnull(v_tunnus.db,0), ifnull(v_tunnus.kr,0), 
			v_account.algjaak + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0),
			v_account.algjaak + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0) + ifnull(v_tunnus.db,0) - ifnull(v_tunnus.kr,0),
			lcreturn , tnRekvId);

		end loop;

		end loop;

--		delete from tmp_subkontod_report where algjaak = 0 and db = 0 and kr = 0 and timestamp = lcreturn and rekvid = tnRekvId;


	end if;


	if tnOpt = 5 then
		-- saldokinnitus
		for v_account in 
			select distinct konto, asutusId from tmp_subkontod_report where timestamp = lcreturn and rekvid = tnRekvId and konto not in ('103701','103950')

		loop
			select sum(case when ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2)  end) as db, 
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*ifnull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end ) as kr into v_saldo
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where (ltrim(rtrim(deebet)) = ltrim(rtrim(v_account.konto)) or ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)))
				and tunnus like tcTunnus
				and parentId in (select journal.id from journal inner join tmprekv on journal.rekvId = tmprekv.id  
				where kpv <= tdKpv2 and asutusId = v_account.asutusid);

			select algJaak into lnAlg from tmp_subkontod_report 
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

			lnAlg := ifnull(lnAlg,0) + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0);



			update 	tmp_subkontod_report set algjaak = lnAlg, db = v_saldo.db, kr = v_saldo.kr
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;


		end loop;

		if (select count(*) from tmp_subkontod_report where  timestamp = lcreturn and rekvid = tnRekvId and db = 0 and kr = 0 and algjaak <> 0) > 0 then
			-- meil on vaja ainult 1 kiri tesed kustutame
			select id into lnId from tmp_subkontod_report where  timestamp = lcreturn and rekvid = tnRekvId and db = 0 and kr = 0 and algjaak <> 0;
			delete from  tmp_subkontod_report where  timestamp = lcreturn and rekvid = tnRekvId and db = 0 and kr = 0 and algjaak <> 0 and id <> lnId;
		end if; 

		delete from tmp_subkontod_report where ifnull(algjaak,0) = 0 and ifnull(db,0) = 0 and ifnull(kr,0) = 0 and timestamp = lcreturn and rekvid = tnRekvId;

	end if;


	return LCRETURN;

end;



$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) TO dbvaatleja;


CREATE OR REPLACE FUNCTION fnc_avansijaak(integer)
  RETURNS numeric AS
$BODY$


declare 
	tnId	ALIAS FOR $1;
	lnTasuSumma numeric(14,2);
	lnSumma numeric(14,2);
	v_avans record;
	lnDokValuuta numeric(14,2);
	lnId int;
	ldKpv date;
BEGIN

select id into lnId from avans2 where parentid = tnId order by id limit 1;
--raise notice 'LnId %',lnId;

select dokvaluuta1.kuurs into lnDokValuuta from dokvaluuta1 where dokid = lnId and dokliik = 5;
lnDokValuuta = ifnull(lnDokValuuta,1);
--raise notice 'lnDokValuuta %',lnDokValuuta;

-- summa, korkonto
select ifnull(dokprop.konto,space(20)) as konto,avans1.asutusId, avans1.rekvId, avans1.number, avans1.kpv into v_avans
	from avans1 left outer join dokprop on dokprop.id = avans1.dokpropId
	where avans1.id = tnId;

-- tasumine via päevaraamat

delete from avans3 where parentid = tnId and liik = 1;


insert into avans3 (parentid,dokid,liik, muud, summa )
select tnId, journal.id,1,'JOURNAL',(journal1.summa*ifnull(dokvaluuta1.kuurs,1))	
	from journal1 inner join journal on journal.id = journal1.parentId 
	left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
	where journal.rekvid = v_avans.rekvid
	and journal.asutusId = v_avans.AsutusId
	and ltrim(rtrim(journal.dok)) = v_avans.number
	and year(journal.kpv) = year(v_avans.Kpv)
	and ltrim(rtrim(journal1.deebet)) = ltrim(rtrim(v_avans.konto));



select sum(summa) into lnTasuSumma from avans3 where parentid = tnId;
raise notice 'lnTasuSumma %',lnTasuSumma;


select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma from avans2  left outer join dokvaluuta1 on (dokvaluuta1.dokid = avans2.id and dokvaluuta1.dokliik = 5) 
where avans2.parentid = tnId;
raise notice 'lnSumma %',lnSumma;

update avans1 set jaak = round((ifnull(lnSumma,0) - ifnull(lnTasuSumma,0))/lnDokValuuta,2) where id = tnId;

RETURN round((ifnull(lnSumma,0) - ifnull(lnTasuSumma,0))/lnDokValuuta,2);


end;




$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_avansijaak(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnnomid alias for $3;
	tndoklausid alias for $4;
	tnliik alias for $5;
	tdkpv alias for $6;
	tnsumma alias for $7;
	ttmuud alias for $8;
	tckood1 alias for $9;
	tckood2 alias for $10;
	tckood3 alias for $11;
	tckood4 alias for $12;
	tckood5 alias for $13;
	tckonto alias for $14;
	tctp alias for $15;
	tnasutusid alias for $16;
	tctunnus alias for $17;
	tcProj alias for $18;
	tcValuuta alias for $19;
	tnKuurs alias for $20;
	lnpv_operId int;
	lnId int; 
	lnSumma numeric(12,2);
	v_pv_kaart record;
	lrCurRec record;
	lnPvElu numeric(6,2);
	lnKulum numeric(12,2);

	lnSoetSumma numeric (12,4);
	lnParandatudSumma numeric (12,4);
	lnUmberhindatudSumma numeric (12,4);
	
	lnDokKuurs numeric(14,4);
	lcString varchar;
	v_dokvaluuta record;
	ldKpv date;


begin

if tnId = 0 then
	-- uus kiri
	insert into pv_oper (parentid,nomid,doklausid,liik,kpv,summa,muud,kood1,kood2,kood3,kood4,kood5,konto,tp,asutusid,tunnus, proj) 
		values (tnparentid,tnnomid,tndoklausid,tnliik,tdkpv,tnsumma,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tckonto,tctp,tnasutusid,tctunnus, tcProj);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnpv_operId:= cast(CURRVAL('public.pv_oper_id_seq') as int4);
	else
		lnpv_operId = 0;
	end if;

	if lnpv_operId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

			-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lnpv_operId,13,tcValuuta, tnKuurs);



else
	-- muuda 
	select * into lrCurRec from pv_oper where id = tnId;
	if  lrCurRec.nomid <> tnnomid or lrCurRec.doklausid <> tndoklausid or lrCurRec.liik <> tnliik or lrCurRec.kpv <> tdkpv 
		or lrCurRec.summa <> tnsumma or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.kood1 <> tckood1 
		or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 
		or lrCurRec.konto <> tckonto or lrCurRec.tp <> tctp or lrCurRec.asutusid <> tnasutusid or lrCurRec.tunnus <> tctunnus then 

	update pv_oper set 
		nomid = tnnomid,
		doklausid = tndoklausid,
		liik = tnliik,
		kpv = tdkpv,
		summa = tnsumma,
		muud = ttmuud,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		konto = tckonto,
		tp = tctp,
		asutusid = tnasutusid,
		proj = tcProj,
		tunnus = tctunnus
	where id = tnId;
	end if;

	lnpv_operId := tnId;
end if;


	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 13 and dokid =lnpv_operId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (13, lnpv_operId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 13 and dokid = lnpv_operId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;

						
		end if;
	
	end if;


	if tnLiik = 1 then
-- 
		Select id into lnId from pv_kaart where parentid = tnParentId;
		lnId = ifnull(lnId,0);
		if lnId > 0 then
			if (select count(id) from dokvaluuta1 where dokliik = 18 and dokid = lnId) = 0 then
	
				insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
					values (lnId,18,tcValuuta, tnKuurs);
			else
	
				update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where dokid = lnId and dokliik = 18;

			end if;
		end if;
		update pv_kaart set soetmaks = tnSumma where id = lnId;


	end if;


	select soetmaks, parhind, algkulum, kulum, soetkpv, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_pv_kaart 
		from pv_kaart left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_kaart.id and dokliik = 18) where parentId = tnparentid;

	lnKulum := v_pv_kaart.kulum;
	ldKpv := v_pv_kaart.soetkpv;

	perform sp_update_pv_jaak(tnParentId);
	
	if tnliik = 1 then
		perform gen_lausend_paigutus(lnpv_operId);
	end if;
	if tnliik = 2 THEN
		perform gen_lausend_kulum(lnpv_operId);
	end if;
	if tnliik = 3 then
		perform gen_lausend_parandus(lnpv_operId);
	end if;
	if tnliik = 4 then
		perform gen_lausend_mahakandmine(lnpv_operId);
	end if;
	if tnliik = 5 then
		perform gen_lausend_umberhindamine(lnpv_operId);
	end if; 
	
         return  lnpv_operId;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_pv_oper(integer, integer, integer, integer, integer, date, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, numeric) TO dbpeakasutaja;


CREATE OR REPLACE FUNCTION fnc_updateformula(integer, integer, character varying)
  RETURNS integer AS
$BODY$


declare 
	tnId		ALIAS FOR $1;
	tnDokTyyp 	ALIAS FOR $2;
	tcFormula	ALIAS FOR $3;
	lnId int;
BEGIN

if tnDokTyyp = 1 then
	update nomenklatuur set formula = tcFormula where id = tnId;
end if;
if tnDokTyyp = 2 then
	update pakett set formula = tcFormula where libid = tnId;
end if;
if tnDokTyyp = 3 then
	update leping2 set formula = tcFormula where id = tnId;
end if;

GET DIAGNOSTICS lnId = ROW_COUNT;	

RETURN lnId;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_updateformula(integer, integer, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_updateformula(integer, integer, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_updateformula(integer, integer, character varying) TO dbpeakasutaja;




