-- Function: sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer)

-- DROP FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer);

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

	lcreturn := to_char(now(), 'YYYYMMDDMISS');

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
				sum(case when ltrim(rtrim(kreedit)) = ltrim(rtrim(v_account.konto)) then (summa*inull(dokvaluuta1.kuurs,1)) else 0::numeric(14,2) end) as kr into v_kaibed 
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

			select algJaak into lnAlg from tmp_subkontod_report 
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;

			lnAlg := ifnull(lnAlg,0) + ifnull(v_saldo.db,0) - ifnull(v_saldo.kr,0);



			update 	tmp_subkontod_report set algjaak = lnAlg
				where timestamp = lcreturn 
				and rekvid = tnRekvId
				and ltrim(rtrim(konto)) = ltrim(rtrim(v_account.konto)) and asutusId = v_account.asutusId;


		end loop;
		delete from tmp_subkontod_report where algjaak = 0  and timestamp = lcreturn and rekvid = tnRekvId;

	end if;


	if tnOpt = 4 then


		-- kaibeasutus andmik tunnuse järgi

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
GRANT EXECUTE ON FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_subkontod_report(character varying, integer, date, date, integer, character varying, integer, integer) TO dbvaatleja;
