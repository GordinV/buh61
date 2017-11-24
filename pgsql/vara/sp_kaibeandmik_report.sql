-- Function: sp_kaibeandmik_report(character varying, integer, date, date, character varying, integer, integer)

-- DROP FUNCTION sp_kaibeandmik_report(character varying, integer, date, date, character varying, integer, integer);

CREATE OR REPLACE FUNCTION sp_kaibeandmik_report(character varying, integer, date, date, character varying, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE tcKonto alias for $1;
	tnrekvid alias for $2;
	tdKpv1 alias for $3;
	tdKpv2 alias for $4;
	tcTunnus alias for $5;
	tnOpt alias for $6;
	tnSvod alias for $7;
	lcReturn varchar;
	lnDb numeric (18,4);
	lnKr numeric (18,4);
	lnAlg numeric (18,4);
	lnLopp numeric (18,4);
	v_kaibed record;
	v_saldo record;
	v_account record;
	v_tunnus record;
	lnCount int;
	ldKpv date;


begin


	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_KAIBEANDMIK_REPORT';
	if ifnull(lnCount,0) < 1 then

		create table tmp_kaibeandmik_report (asutusId int default 0, Asutus varchar(254) default space(1), regkood varchar(20) default space(1), 
			aadress text default space(1), konto varchar(20) default space(1), korkonto varchar(20) default space(1),
			tunnus varchar(20) default space(1), dokkpv date default date(),
			algdb numeric (18,6) default 0, algkr numeric (18,6) default 0, db numeric(18,6) default 0, kr numeric(18,6) default 0, 
			loppdb numeric(18,6) default 0, loppkr numeric(18,6) default 0,
			kood1 varchar(20) default space(1), kood2 varchar(20) default space(1), kood3 varchar(20) default space(1),
			kood4 varchar(20) default space(1), kood5 varchar(20) default space(1), dok varchar(120) default space(1),
			lausend int default 0, 
			timestamp varchar(20) , kpv date default date(), rekvid int )  ;


		GRANT ALL ON TABLE tmp_kaibeandmik_report TO GROUP public;
	else
		delete from tmp_kaibeandmik_report where kpv < date() ;

	end if;

	lcreturn := ltrim(rtrim(str(tnrekvId)))+to_char(now(), 'YYYYMMDDMISSSS');

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
delete from tmpRekv where parentid = 9999;
if tnSvod = 1 then
	delete from tmpRekv where tase < 3;

else
	delete from tmpRekv where tase in (0,1,2,4);
end if;
if tnOpt = 2 then
	-- dok.saldo (varaamet 29.08.2012)
-- 1. alg. saldo seisiga tdkpv1

	-- 1.1 Deebet arved

	insert into tmp_kaibeandmik_report (lausend, algdb, timestamp, rekvid )  
	select id, algjaak, lcreturn, tnrekvId from 
		(
		select id, sum(algdb - algkr) as algjaak from 
		(
		select arv.id ,arv.summa * ifnull(dokvaluuta1.kuurs,1) as algdb, 0 as algkr
			from arv left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv.id and dokvaluuta1.dokliik = 3)
			where arv.rekvid = tnRekvId and fnc_arvkpvParandamine(arv.id) < tdKpv1 and liik = 0
				union all
		select arvtasu.arvid as id ,0 as algdb, arvtasu.summa * ifnull(dokvaluuta1.kuurs,1) as algkr
			from arvtasu inner join arv on arvtasu.arvid = arv.id 
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = arvtasu.id and dokvaluuta1.dokliik = 21)
			where arvtasu.rekvid = tnrekvId and arvtasu.kpv < tdKpv1 and arv.liik = 0  
		) tmpAlg
	group by id
		) tmpAlgArvJaak 
	where round(algjaak/15.6466,2) <> 0;


	-- 1.1 Kreedit arved
	insert into tmp_kaibeandmik_report (lausend, algkr, timestamp, rekvid )  
	select id, algjaak, lcreturn, tnrekvId from 
		(
		select id, sum(algkr - algdb) as algjaak from 
		(
		select arv.id ,arv.summa * ifnull(dokvaluuta1.kuurs,1) as algkr, 0 as algdb
			from arv left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv.id and dokvaluuta1.dokliik = 3)
			where arv.rekvid = tnRekvId and fnc_arvkpvParandamine(arv.id) < tdKpv1 and liik = 1
				union all
		select arvtasu.arvid as id ,0 as algkr, arvtasu.summa * ifnull(dokvaluuta1.kuurs,1) as algdb
			from arvtasu inner join arv on arvtasu.arvid = arv.id 
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = arvtasu.id and dokvaluuta1.dokliik = 21)
			where arvtasu.rekvid = tnrekvId and arvtasu.kpv < tdKpv1 and arv.liik = 1  
		) tmpAlg
	group by id
		) tmpAlgArvJaak 
	where round(algjaak/15.6466,2) <> 0;

-- 2. kaibed tdkpv1 - tdKpv2

--	2.1 deebet arved

	insert into tmp_kaibeandmik_report (lausend, db, kr, timestamp, rekvid )  
		select id, sum(db), sum(kr),lcreturn, tnrekvId  from 
		(
		select arv.id ,arv.summa * ifnull(dokvaluuta1.kuurs,1) as db, 0 as kr
			from arv left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv.id and dokvaluuta1.dokliik = 3)
			where arv.rekvid = tnRekvId and fnc_arvkpvParandamine(arv.id) >= tdKpv1 and arv.kpv <= tdKpv2 and arv.liik = 0
				union all
		select arvtasu.arvid as id ,0 as db, arvtasu.summa * ifnull(dokvaluuta1.kuurs,1) as kr
			from arvtasu inner join arv on arvtasu.arvid = arv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = arvtasu.id and dokvaluuta1.dokliik = 21)
			where arvtasu.rekvid = 6 and arvtasu.kpv >= tdKpv1 and arvtasu.kpv <= tdKpv2 and arv.liik = 0
		) tmpAlg
	group by id;

--	2.1 kreedit arved

	insert into tmp_kaibeandmik_report (lausend, db, kr, timestamp, rekvid )  
		select id, sum(db), sum(kr),lcreturn, tnrekvId  from 
		(
		select arv.id ,arv.summa * ifnull(dokvaluuta1.kuurs,1) as kr, 0 as db
			from arv left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv.id and dokvaluuta1.dokliik = 3)
			where arv.rekvid = tnRekvId and fnc_arvkpvParandamine(arv.id) >= tdKpv1 and arv.kpv <= tdKpv2 and arv.liik = 1
				union all
		select arvtasu.arvid as id ,0 as kr, arvtasu.summa * ifnull(dokvaluuta1.kuurs,1) as db
			from arvtasu inner join arv on arvtasu.arvid = arv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = arvtasu.id and dokvaluuta1.dokliik = 21)
			where arvtasu.rekvid = 6 and arvtasu.kpv >= tdKpv1 and arvtasu.kpv <= tdKpv2 and arv.liik = 1
		) tmpAlg
	group by id;

-- 3. lopp saldo seisuga tdKpv2
	for v_kaibed in
		select lausend as arvid ,sum(algdb) as algdb, sum(algkr) as algkr, sum(db) as db, sum(kr) as kr 
			from tmp_kaibeandmik_report where timestamp = lcReturn group by lausend 	
	loop
		select arv.asutusid,arv.liik, arv.number, arv.kpv, dokprop.konto, asutus.regkood, asutus.nimetus as asutus into v_account 
			from arv inner join dokprop on arv.doklausid = dokprop.id 
			inner join asutus on arv.asutusid = asutus.id
			where arv.id = v_kaibed.arvid;
			
---		raise notice 'arvid %',v_kaibed.arvid;
--		raise notice 'asutus %',v_account.asutus;


		if v_account.liik = 0 then
			lnDb =  v_kaibed.algdb -v_kaibed.algkr + v_kaibed.db - v_kaibed.kr;
			lnKr = 0;			
		else
			lnDb = 0;
			lnKr = v_kaibed.algkr - v_kaibed.algdb + v_kaibed.kr - v_kaibed.db;
		end if;	
--		raise notice 'lnDb %',lnDb;
--		raise notice 'lnKr %',lnKr;
		
		insert into tmp_kaibeandmik_report (lausend, asutusid, asutus, regkood, konto,algdb, algkr,db, kr, loppdb, loppkr, dok, timestamp, rekvid)
		values (v_kaibed.arvid, v_account.asutusid,v_account.asutus, v_account.regkood, v_account.konto, v_kaibed.algdb, v_kaibed.algkr, v_kaibed.db, v_kaibed.kr,
		lnDb, lnKr, ltrim(rtrim(v_account.number))+'.kpv:'+dtoc(v_account.kpv), lcReturn+'KK', tnrekvid);

	end loop;

	lcReturn = lcReturn+'KK';

	-- 4 gruppin arved, koostatud varemt kui 2011 a., teised koperrimie
	insert into tmp_kaibeandmik_report (lausend, asutusid, asutus, regkood, konto,algdb, algkr,db, kr, loppdb, loppkr, dok, timestamp, rekvid)
		select 0, tmp.asutusid, tmp.asutus, tmp.regkood, tmp.konto,sum(tmp.algdb), sum(tmp.algkr), sum(tmp.db), sum(tmp.kr), 
		sum(tmp.loppdb), sum(tmp.loppkr), 'Arved < 2011 a.', lcReturn+'A', tmp.rekvid
		from tmp_kaibeandmik_report tmp inner join arv on (tmp.lausend = arv.id and year(arv.kpv) < 2011) 
		where timestamp = lcReturn   
		group by tmp.asutusid, tmp.asutus, tmp.regkood, tmp.konto, tmp.rekvid;
	-- teised arved (kuuopaev >= 2011 a.)
	insert into tmp_kaibeandmik_report (lausend, asutusid, asutus, regkood, konto,algdb, algkr,db, kr, loppdb, loppkr, dok, timestamp, rekvid)
		select tmp.lausend, tmp.asutusid, tmp.asutus, tmp.regkood, tmp.konto,tmp.algdb, tmp.algkr, tmp.db, tmp.kr, 
			tmp.loppdb, tmp.loppkr, tmp.dok, lcReturn+'A', tmp.rekvid
		from tmp_kaibeandmik_report tmp inner join arv on (tmp.lausend = arv.id and year(arv.kpv) >= 2011)
		where timestamp = lcReturn  ;

	delete from tmp_kaibeandmik_report where timestamp = lcReturn;
	lcreturn = lcReturn+'A';

end if;

	if tnOpt = 1 then
		-- kaibeandmik 
		raise notice 'kaibeandmik';

		-- algjaak db
		insert into tmp_kaibeandmik_report (konto, algdb, timestamp, rekvid )  
		select ltrim(rtrim(journal1.deebet)), sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1)),lcReturn, tnRekvId 
		from journal1 inner join journal on journal.id = journal1.parentid	
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1)
		inner join tmprekv on journal.rekvId = tmprekv.id
		where journal1.deebet like tcKonto and journal.kpv < tdKpv1
		and journal1.tunnus like tcTunnus
		group by ltrim(rtrim(journal1.deebet));


		-- algjaak kr
		insert into tmp_kaibeandmik_report (konto, algkr, timestamp, rekvid )  
		select ltrim(rtrim(journal1.kreedit)), sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1)),
		lcReturn, tnRekvId 
		from journal1 inner join journal on journal.id = journal1.parentid	
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1)
		inner join tmprekv on journal.rekvId = tmprekv.id
		where journal1.kreedit like tcKonto and journal.kpv < tdKpv1 
		and journal1.tunnus like tcTunnus
		group by ltrim(rtrim(journal1.kreedit));

		raise notice 'algjaak tehtud';
		

		-- kaibed db
		insert into tmp_kaibeandmik_report (konto, db, timestamp, rekvid )  
		select ltrim(rtrim(journal1.deebet)), sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1)),
		lcReturn, tnRekvId 
		from journal1 inner join journal on journal.id = journal1.parentid	
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1)
		inner join tmprekv on journal.rekvId = tmprekv.id
		where journal1.deebet like tcKonto and journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2 
		and journal1.tunnus like tcTunnus
		group by ltrim(rtrim(journal1.deebet));

		-- kaibed kr
		insert into tmp_kaibeandmik_report (konto, kr, timestamp, rekvid )  
		select ltrim(rtrim(journal1.kreedit)), sum(journal1.summa*ifnull(dokvaluuta1.kuurs,1)),
		lcReturn, tnRekvId 
		from journal1 inner join journal on journal.id = journal1.parentid	
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1)
		inner join tmprekv on journal.rekvId = tmprekv.id
		where journal1.kreedit like tcKonto and journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2 
		and journal1.tunnus like tcTunnus
		group by ltrim(rtrim(journal1.kreedit));

		raise notice 'kaibed tehtud';

		-- lopp

		insert into tmp_kaibeandmik_report (konto, algdb, algkr, db, kr, timestamp, rekvid )  
		select ltrim(rtrim(konto)), sum(algdb) as algdb, sum(algkr) as algkr, sum(db) as db, sum(kr) as kr, 
		lcReturn+'L', tnRekvId 
		from tmp_kaibeandmik_report
		where timestamp = lcReturn and rekvid = tnrekvid 
		group by ltrim(rtrim(konto));

		raise notice 'lopp';


		delete from tmp_kaibeandmik_report where timestamp = lcreturn;

		lcreturn = lcReturn + 'L';
		delete from tmp_kaibeandmik_report where timestamp = lcreturn 	and rekvid = tnRekvId and algdb=0 and algkr = 0 and db = 0 and kr = 0;


	end if;

	return LCRETURN;

end;


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_kaibeandmik_report(character varying, integer, date, date, character varying, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_kaibeandmik_report(character varying, integer, date, date, character varying, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_kaibeandmik_report(character varying, integer, date, date, character varying, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_kaibeandmik_report(character varying, integer, date, date, character varying, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_kaibeandmik_report(character varying, integer, date, date, character varying, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_kaibeandmik_report(character varying, integer, date, date, character varying, integer, integer) TO dbvaatleja;
