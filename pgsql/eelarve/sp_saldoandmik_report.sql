-- Function: sp_saldoandmik_report(integer, date, integer, integer, integer)
/*

select * from library where library = 'KONTOD' and kood = '290400'

update library set tun5 = 1 where id = 62456

and left(kood,1) not in ('1','2','9') and tun5 not in (3,4)

select * from tmp_saldoandmik where timestamp = '63201203122533951'
and tp = '011002'
order by id desc limit 10
delete from tmp_saldoandmik

select sp_saldoandmik_report(63, date(2012,01,31), 2, 1, 0)


*/
--select * from tmp_saldoandmik where rekvid = 63 and konto like '15%' and rahavoo = '00' order by id desc limit 100

-- DROP FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE tnrekvid alias for $1;
	tdKpv alias for $2;
	tnTyyp alias for $3;
	tnSvod alias for $4;
	tnVar alias for $5;
	lcReturn varchar;
	lcString varchar;
	lcPnimi varchar;

	lnreturn int;
	LNcOUNT int;
	lnTun int;

	lnDeebet numeric(16,4);
	lnKreedit numeric(16,4);
	lcTp varchar(20);
	lcAllikas varchar(20);
	lcTegev varchar(20);
	lcRahavoog varchar(20);
	lcEelarve varchar(20);
	lcKonto varchar(20);
	lcKontoNimi varchar(254);

	lcKulumKontoString varchar(254);
	v_saldo record;
	v_library record;
	lcReturn1 varchar;
	
	lnTunTulemus int;
	lnTase int;

	lcMeetmekood varchar(20);
	ldKpv1 date;
	ldKpv2 date;
	lnAasta int;
	
begin
lnAasta = 1;
lnreturn = 0;


if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMP_SALDOANDMIK')  < 1 then
	
	create table tmp_saldoandmik (id serial NOT NULL, nimetus varchar(254) not null default space(1), db numeric(16,4) not null default 0, kr numeric(16,4) not null default 0, konto varchar(20) not null default space(1), 		
		tegev varchar(20) not null default space(1), tp varchar(20) not null default space(1), allikas varchar(20) not null default space(1), 			
		rahavoo varchar(20) not null default space(1), 
		timestamp varchar(20) not null , kpv date default date(), rekvid int, tyyp int default 0 not null )  ;
		
		GRANT ALL ON TABLE tmp_saldoandmik TO GROUP public;
		GRANT ALL ON TABLE tmp_saldoandmik_id_seq TO public;

else
	delete from tmp_saldoandmik where kpv < date();
	raise notice 'vana andmed kustutatud';
end if;

lcreturn := ltrim(rtrim(str(tnrekvId)))+to_char(now(), 'YYYYMMDDMISSSS');
raise notice 'Timestamp %',lcreturn;
/*
if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMPREKV')  > 0 then
	delete from tmpRekv;
--	truncate TABLE tmpRekv;
	insert into tmpRekv
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv where parentid <> 9999;
else
	CREATE TABLE tmpRekv AS
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv where parentid <> 9999;
		GRANT ALL ON TABLE tmpRekv TO GROUP public;

END IF;

if tnSvod = 1 then
	delete from tmpRekv where tase < 3;

else
	delete from tmpRekv where tase in (0,1,2,4);
end if;
*/

if tnSvod = 1 then
	lnTase = 3;

else
	lnTase = 9;
end if;

lcKonto = '';

	INSERT INTO tmp_saldoandmik ( konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) 
	SELECT KONTO, 
	CASE WHEN (library.tun1 = 0 or left(library.kood,3) in ('154','155','156')) THEN ''::varchar(20) ELSE tmpAlgSaldo.tp end AS tp,
	CASE WHEN (library.tun2 = 0 or left(library.kood,3) in ('154','155','156')) THEN ''::varchar(20) ELSE tmpAlgSaldo.tegev end AS tegev,
	CASE WHEN library.tun3 = 0 THEN ''::varchar(20) ELSE tmpAlgSaldo.allikas end AS allikas,
	CASE WHEN library.tun4 = 0 THEN ''::varchar(20) ELSE '00'::varchar(20) end AS rahavood,
	CASE WHEN library.tun5 = 1 or library.tun5 = 3 THEN db - kr ELSE 0::numeric end AS db,
 	CASE WHEN library.tun5 = 2 or library.tun5 = 4 THEN kr - db ELSE 0::numeric end AS kr,
        tnRekvId, lcReturn, alltrim(library.nimetus), 20 
	from 
	(
	SELECT  journal1.deebet AS konto, left(journal1.lisa_d,6)::varchar as tp, 
		journal1.kood2 as allikas, journal1.kood1 as tegev, journal1.kood3 as rahavoo, journal1.kood5 as eelarve,
		sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1)) AS dB, 0::numeric(12,4) AS kr 
		FROM journal inner join journal1 on journal.id = journal1.parentid 
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where year(Journal.kpv) < year(tdKpv) 
		and journal1.summa <> 0
		and (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
		group by journal1.deebet, journal1.lisa_d, journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood5
	UNION ALL 
		SELECT  journal1.kreedit AS konto, left(journal1.lisa_k,6)::varchar as tp,
		journal1.kood2 as allikas,journal1.kood1 as tegev, journal1.kood3 as rahavoo, journal1.kood5 as eelarve,
		0::numeric(12,4) as dB, sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1)) AS kr
		FROM journal inner join journal1 on journal.id = journal1.parentid 
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where year(Journal.kpv) < year(tdKpv) 
		and journal1.summa <> 0
		and (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
		group by journal1.kreedit, journal1.lisa_k,journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood5
		) tmpAlgSaldo inner join library on (tmpAlgSaldo.konto = library.kood and library.library = 'KONTOD');

--update tmp_saldoandmik set tp = '011001' where tp = '011002' and timestamp = lcReturn;

/*

for v_saldo in 
	SELECT  journal1.deebet AS konto, journal1.lisa_d as tp, 
		journal1.kood2 as allikas, journal1.kood1 as tegev, journal1.kood3 as rahavoo, journal1.kood5 as eelarve,
		sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1)) AS dB, 0::numeric(12,4) AS kr 
		FROM journal inner join journal1 on journal.id = journal1.parentid 
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where year(Journal.kpv) < year(tdKpv) 
		and journal1.summa <> 0
		and (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
		group by journal1.deebet, journal1.lisa_d, journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood5
	UNION ALL 
		SELECT  journal1.kreedit AS konto, journal1.lisa_k as tp,
		journal1.kood2 as allikas,journal1.kood1 as tegev, journal1.kood3 as rahavoo, journal1.kood5 as eelarve,
		0::numeric(12,4) as dB, sum(journal1.summa * ifnull(dokvaluuta1.kuurs,1)) AS kr
		FROM journal inner join journal1 on journal.id = journal1.parentid 
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where year(Journal.kpv) < year(tdKpv) 
		and journal1.summa <> 0
		and (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
		group by journal1.kreedit, journal1.lisa_k,journal1.kood1, journal1.kood2, journal1.kood3, journal1.kood5

loop

	lnDeebet = 0;
	lnKreedit = 0;

			select * into v_library from library where ltrim(rtrim(kood)) = ltrim(rtrim(v_saldo.konto)) and ltrim(rtrim(library)) = 'KONTOD' order by id desc limit 1; 


	-- tp
	if empty (v_library.tun1) then 
		v_saldo.tp = '';
	end if;
	if ((left(ltrim(rtrim(v_saldo.konto)),3) = '154' or left(ltrim(rtrim(v_saldo.konto)),3) = '155' or left(ltrim(rtrim(v_saldo.konto)),3) = '156'))  then 
		v_saldo.tp = '';
	end if;

	--tegev
	if empty (v_library.tun2) or ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo <> '01') then 
		v_saldo.tegev = '';
	end if;
	-- allikas
	if empty (v_library.tun3) or isdigit(v_saldo.allikas) = 0 then 
		v_saldo.allikas = '';
	end if;
	-- rahavoo
	if empty (v_library.tun4) then 
		v_saldo.rahavoo = '';
	else
		v_saldo.tegev = '';
		v_saldo.rahavoo = '00';
	end if;
	if v_library.tun5 = 1 or v_library.tun5 = 3 then
		lnDeebet = v_saldo.db - v_saldo.kr;
	else
		lnKreedit = v_saldo.kr - v_saldo.db;
	end if;
	lnDeebet = ifnull(lnDeebet,0);
	lnKreedit = ifnull(lnKreedit,0);
	raise notice ' konto %',v_saldo.konto;

	INSERT INTO tmp_saldoandmik ( konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) values 
		( alltrim(v_saldo.konto), alltrim(v_saldo.tp), alltrim(v_saldo.tegev), alltrim(v_saldo.allikas), alltrim(v_saldo.rahavoo), lnDeebet, lnKreedit,
		tnRekvId, lcReturn, alltrim(v_library.nimetus), 20 );
end loop;

*/
raise notice 'Alg saldo koostatud';
/*
if (select count(*) from tmp_saldoandmik where konto like '103000' and tp = '185101' and timestamp = lcReturn) > 0 then
	raise notice '1 found';
end if; 
*/
-- update pv konto

update tmp_saldoandmik set tp = '' where not empty (tp) and ltrim(rtrim(rahavoo)) = '00' and left(ltrim(rtrim(konto)),3) in ('154','155','156') and ltrim(rtrim(timestamp)) = lcreturn and rekvid = tnRekvId;


-- ajutised kontod (kulud /tulud (kulud - tun5 = 3, tulud - tun5 = 4) )


-- kontrolin aasta
if (select  count(*) from curJournal where month(kpv) = 6 and year(kpv) = year(tdKpv) - 1) > 1 then 
lnAasta = 0;

select nimetus into lcKontoNimi from library where kood = '298000' and library = 'KONTOD' order by id desc limit 1;
select tun5 into lnTunTulemus from library where kood = '298000' and library = 'KONTOD' order by id desc limit 1;

lnTunTulemus = ifnull(lnTunTulemus,2);
--	and left(ltrim(rtrim(kood)),1) not in ('1','2')  

for v_library in
SELECT library.kood as konto, library.tun1, library.tun2, library.tun3, library.tun4, library.tun5
	from library 
	where library = 'KONTOD' 
	and left(ltrim(rtrim(kood)),1) <> '9'
	and library.tun5 > 2
	and library.kood in (select distinct konto from tmp_saldoandmik where timestamp = lcReturn) 

loop
	raise notice 'ajutiselt konto: %',v_library.konto;

	SELECT sum(db) into lnDeebet from tmp_saldoandmik
	where timestamp = lcReturn
	and konto = v_library.konto;

	SELECT sum(kr) into lnKreedit from tmp_saldoandmik
	where timestamp = lcReturn
	and konto = v_library.konto;

	lnDeebet = ifnull(lnDeebet,0);
	lnKreedit = ifnull(lnKreedit,0);	
	
	raise notice 'deebet %',lnDeebet;
	raise notice 'deebet %',lnKreedit;




	if lnTunTulemus = 1  then
		-- lisame kiri kus on see konto lopp saldo 
		insert into tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus) values 
		 ('298000','','','','00',(lnDeebet-lnKreedit),0,tnRekvId, lcreturn,lcKontoNimi);
	
	else
		-- lisame kiri kus on see konto lopp saldo 
		insert into tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus) values 
		 ('298000','','','','00',0,lnKreedit-lnDeebet,tnRekvId, lcreturn,lcKontoNimi);

	end if;

	-- kustutame kulu / tulu saldo

	delete from tmp_saldoandmik where timestamp = lcReturn and konto = v_library.konto;


end loop;

raise notice ' 298000 arvestatud';

end if;

	SELECT sum(db) into lnDeebet from tmp_saldoandmik
	where timestamp = lcReturn
	and konto = '298000';

	SELECT sum(kr) into lnKreedit from tmp_saldoandmik
	where timestamp = lcReturn
	and konto = '298000';

	lnDeebet = ifnull(lnDeebet,0);
	lnKreedit = ifnull(lnKreedit,0);	
	
	raise notice 'deebet 298%',lnDeebet;
	raise notice 'deebet 298%',lnKreedit;


raise notice 'pohi osa (kaibed)';

for v_saldo in 
	SELECT library.tun1,library.tun2, library.tun3, library.tun4,library.tun5, konto,  tp, tegev, allikas, rahavoo, 
			case when (library.tun5=1 or library.tun5 = 3) then
			(sum(deebet) - sum (kreedit) ) else 0 end as db, 
		case when (library.tun5=2 or library.tun5 = 4) then 
			(sum (kreedit) - sum(deebet)) else 0 end as kr, 
		tnRekvId as rekvid, lcReturn as timestamp, library.nimetus, 5 as tyyp
	from 
	(
	SELECT journal1.deebet As konto, left(journal1.lisa_d,6)::varchar As tp, journal1.kood1 As tegev, journal1.kood2 As allikas, journal1.kood3 As rahavoo, 
		sum(journal1.Summa* ifnull(dokvaluuta1.kuurs,1)) As deebet, 0 As kreedit  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where journal.kpv <= tdKpv
		and year(kpv) = year(tdKpv)
		and journal1.summa <> 0
		and (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
		group by journal1.deebet, left(journal1.lisa_d,6), journal1.kood1, journal1.kood2, journal1.kood3 
		
	) qrySaldoaruanne inner join library on (ltrim(rtrim(library.kood)) =  ltrim(rtrim(qrySaldoaruanne.konto)) and ltrim(rtrim(library.library)) = 'KONTOD') 
	group BY konto, tp, tegev, allikas, rahavoo, library.tun1, library.tun2, library.tun3, library.tun4, library.tun5, library.nimetus  
	ORDER BY konto, tp, tegev, allikas, rahavoo

loop
	-- tp
	if empty (v_saldo.tun1) then 
		v_saldo.tp = '';
	end if;
	if ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo = '16') and v_saldo.rahavoo <> '01' then 
		v_saldo.tp = '';
	end if;
	
	--tegev
	if empty (v_saldo.tun2) or ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo <> '01') then 
		v_saldo.tegev = '';
	end if;
	-- allikas
	if empty (v_saldo.tun3) or isdigit(v_saldo.allikas) = 0 then 
		v_saldo.allikas = '';
	end if;
	-- rahavoo
	if empty (v_saldo.tun4) then 
		v_saldo.rahavoo = '';
	end if;


	INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) values 
		(alltrim(v_saldo.konto), alltrim(v_saldo.tp), alltrim(v_saldo.tegev), alltrim(v_saldo.allikas), alltrim(v_saldo.rahavoo), v_saldo.db, v_saldo.kr, v_saldo.rekvid, v_saldo.timestamp, alltrim(v_saldo.nimetus), v_saldo.tyyp );
	
end loop;

/*
if (select count(*) from tmp_saldoandmik where konto = '103000' and tp = '185101' and timestamp = lcReturn) > 0 then
	raise notice '2 found';
end if; 

*/
for v_saldo in
SELECT konto, library.tun1, library.tun2, library.tun3, library.tun4, library.tun5,tp, tegev, allikas, rahavoo, 
	case when (library.tun5=1 or library.tun5 = 3) then
			(sum(deebet) - sum (kreedit) ) else 0 end as db, 
	case when (library.tun5=2 or library.tun5 = 4) then 
			(sum (kreedit) - sum(deebet)) else 0 end as kr, 
	tnRekvId as rekvid , lcReturn as timestamp, library.nimetus, 5 as tyyp
from 
(
	SELECT journal1.kreedit As konto, left(journal1.lisa_k,6)::varchar As tp, journal1.kood1 As tegev, journal1.kood2 As allikas, journal1.kood3 As rahavoo, 
		0 As deebet, sum(journal1.Summa * ifnull(dokvaluuta1.kuurs,1)) As kreedit  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where journal.kpv <= tdKpv 
		and year(kpv) = year(tdKpv)
		and journal1.summa <> 0
		and (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
		group by journal1.kreedit, left(journal1.lisa_k,6), journal1.kood1, journal1.kood2, journal1.kood3 

) qrySaldoaruanne inner join library on (ltrim(rtrim(library.kood)) =  ltrim(rtrim(qrySaldoaruanne.konto)) and ltrim(rtrim(library.library)) = 'KONTOD') 
group BY konto, tp, tegev, allikas, rahavoo, library.tun1, library.tun2, library.tun3, library.tun4, library.tun5, library.nimetus  
ORDER BY konto, tp, tegev, allikas, rahavoo

loop
	-- tp
	if empty (v_saldo.tun1) then 
		v_saldo.tp = '';
	end if;
	if ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo = '16') then 
		v_saldo.tp = '';
	end if;
	--tegev
	if empty (v_saldo.tun2) or ((left(v_saldo.konto,3) = '154' or left(v_saldo.konto,3) = '155' or left(v_saldo.konto,3) = '156') and v_saldo.rahavoo <> '01') then 
		v_saldo.tegev = '';
	end if;
	-- allikas
	if empty (v_saldo.tun3) or isdigit(v_saldo.allikas) = 0 then 
		v_saldo.allikas = '';
	end if;
	-- rahavoo
	if empty (v_saldo.tun4) then 
		v_saldo.rahavoo = '';
	end if;


	INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) values 
		(alltrim(v_saldo.konto), alltrim(v_saldo.tp), alltrim(v_saldo.tegev), alltrim(v_saldo.allikas), alltrim(v_saldo.rahavoo), v_saldo.db, v_saldo.kr, v_saldo.rekvid, v_saldo.timestamp, alltrim(v_saldo.nimetus), v_saldo.tyyp );
	
end loop;
/*
if (select count(*) from tmp_saldoandmik where konto = '103000' and tp = '185101' and timestamp = lcReturn) > 0 then
	raise notice '3 found';
end if; 
*/
/*
INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) 
SELECT konto, ltrim(rtrim(tp)), ltrim(rtrim(tegev)), ltrim(rtrim(allikas)), ltrim(rtrim(rahavoo)), db, kr, rekvid, lcreturn, nimetus, 6
from tmp_saldoandmik
where timestamp = lcReturn;
*/




raise notice ' kustutame eelmine aasta naidised (9)';
if lnAasta = 0 then
	delete from tmp_saldoandmik where timestamp = lcReturn and left(konto,1) = '9';
end if;


INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) 
SELECT left(konto,6) as konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, 70
from tmp_saldoandmik
where ltrim(rtrim(timestamp)) = lcReturn
order by timestamp, REKVID, left(konto,6), tp, tegev, allikas, rahavoo, nimetus;


INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus, tyyp) 
SELECT konto, tp, tegev, allikas, rahavoo, sum(db), sum(kr), rekvid, timestamp, nimetus, 7
from tmp_saldoandmik
where ltrim(rtrim(timestamp)) = lcReturn
and tyyp = 70
group by timestamp, REKVID, konto, tp, tegev, allikas, rahavoo, nimetus
order by timestamp, REKVID, konto, tp, tegev, allikas, rahavoo, nimetus;


--and tyyp = 6

raise notice 'kaibed 5  lopp';

DELETE FROM tmp_saldoandmik WHERE timestamp = lcReturn and rekvid = tnRekvId and tyyp <> 7;

DELETE FROM tmp_saldoandmik WHERE  (ltrim(rtrim(konto)) in ('999999','000000','888888') or (db = 0 and kr= 0)) and rekvid = tnRekvId;


return LCRETURN;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_report(integer, date, integer, integer, integer) TO dbpeakasutaja;
