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
	lnDb numeric (18,6);
	lnKr numeric (18,6);
	lnAlg numeric (18,6);
	lnLopp numeric (18,6);
	v_kaibed record;
	v_saldo record;
	v_account record;
	v_tunnus record;
	lnCount int;


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


		delete from tmp_kaibeandmik_report where timestamp = lcreturn and rekvid = tnRekvId and algdb=0 and algkr = 0 and db = 0 and kr = 0;


	end if;
	lcreturn = lcReturn + 'L';

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
