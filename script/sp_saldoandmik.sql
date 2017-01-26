-- Function: sp_saldoandmik_report(integer, date, integer, integer)

-- DROP FUNCTION sp_saldoandmik_report(integer, date, integer, integer);

CREATE OR REPLACE FUNCTION sp_saldoandmik_report(integer, date, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE tnrekvid alias for $1;
	tdKpv alias for $2;
	tnSvod alias for $3;
	tnTyyp alias for $4;
	lcReturn varchar;
	lcString varchar;
	lcPnimi varchar;

	lnreturn int;
	LNcOUNT int;
	lnTun int;

	lnDeebet numeric(12,2);
	lnKreedit numeric(12,2);
	lcTp varchar(20);
	lcAllikas varchar(20);
	lcTegev varchar(20);
	lcRahavoog varchar(20);
	lcEelarve varchar(20);
	lcKonto varchar(20);

	lcKulumKontoString varchar(254);
	v_saldo record;
	v_library record;
	
	
	lnTase int;

	lcMeetmekood varchar(20);
begin

lnreturn = 0;


if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMP_SALDOANDMIK')  < 1 then
	
	create table tmp_saldoandmik (id serial NOT NULL, nimetus varchar(254) not null default space(1), db numeric(12,2) not null default 0, kr numeric(12,2) not null default 0, konto varchar(20) not null default space(1), 		
		tegev varchar(20) not null default space(1), tp varchar(20) not null default space(1), allikas varchar(20) not null default space(1), 			
		rahavoo varchar(20) not null default space(1), 
		timestamp varchar(20) not null , kpv date default date(), rekvid int )  ;
		
		GRANT ALL ON TABLE tmp_saldoandmik TO GROUP public;
		GRANT ALL ON TABLE tmp_saldoandmik_id_seq TO public;

else
	delete from tmp_saldoandmik where kpv < date() and rekvid = tnrekvId;
end if;

lcreturn := to_char(now(), 'YYYYMMDDMISSSS');

if tnTyyp = 1 then
	-- meetmeandmik
	lcMeetmekood = '56056605662';
	
	INSERT INTO tmp_saldoandmik (konto, tp,  db, kr, rekvid, timestamp) 
	SELECT '32' as konto, lcMeetmekood, 0 As db, sum(journal1.Summa) As kr,tnRekvId , lcReturn  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		where journal.kpv <= tdKpv 
		and year(kpv) = year(tdKpv)
		and left(kreedit,2) = '32'
	union all
	SELECT '35' as konto, lcMeetmekood, 0 As db, sum(journal1.Summa) As kr,tnRekvId , lcReturn  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		where journal.kpv <= tdKpv 
		and year(kpv) = year(tdKpv)
		and left(kreedit,2) = '35'
	union all
	SELECT '38' as konto, lcMeetmekood, 0 As db, sum(journal1.Summa) As kr,tnRekvId , lcReturn  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		where journal.kpv <= tdKpv 
		and year(kpv) = year(tdKpv)
		and left(kreedit,2) = '38'
	union all
	SELECT '4 ' as konto, lcMeetmekood, 0 As db, sum(journal1.Summa) As kr,tnRekvId , lcReturn  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		where journal.kpv <= tdKpv 
		and year(kpv) = year(tdKpv)
		and left(kreedit,1) = '4'
	union all
	SELECT '50' as konto, lcMeetmekood, 0 As db, sum(journal1.Summa) As kr,tnRekvId , lcReturn  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		where journal.kpv <= tdKpv 
		and year(kpv) = year(tdKpv)
		and left(kreedit,2) = '50'
	union all
	SELECT '55' as konto, lcMeetmekood, 0 As db, sum(journal1.Summa) As kr,tnRekvId , lcReturn  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		where journal.kpv <= tdKpv 
		and year(kpv) = year(tdKpv)
		and left(kreedit,2) = '55'
	union all
	SELECT '60' as konto, lcMeetmekood, 0 As db, sum(journal1.Summa) As kr,tnRekvId , lcReturn  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		where journal.kpv <= tdKpv 
		and year(kpv) = year(tdKpv)
		and left(kreedit,2) = '60'
	union all
	SELECT '61' as konto, lcMeetmekood, 0 As db, sum(journal1.Summa) As kr,tnRekvId , lcReturn  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		where journal.kpv <= tdKpv 
		and year(kpv) = year(tdKpv)
		and left(kreedit,2) = '61'
	union all
	SELECT '655' as konto, lcMeetmekood, 0 As db, sum(journal1.Summa) As kr,tnRekvId , lcReturn  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		where journal.kpv <= tdKpv 
		and year(kpv) = year(tdKpv)
		and left(kreedit,3) = '655'
	union all
	SELECT '658' as konto, lcMeetmekood, 0 As db, sum(journal1.Summa) As kr,tnRekvId , lcReturn  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
		where journal.kpv <= tdKpv 
		and year(kpv) = year(tdKpv)
		and left(kreedit,3) = '658';

	return lcReturn;

end if;


/*
PREPARE v_rekv AS
  SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, 3)::int as tase FROM rekv;

*/

if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMPREKV')  > 0 then
	truncate TABLE tmpRekv;
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





INSERT INTO tmp_saldoandmik (konto, rahavoo, db, kr, tp, rekvid, timestamp, nimetus) 
		SELECT LEFT(LTRIM(library.kood),6), 
			case when library.tun4 = 1 then  '00' else '' end, 
			case when (library.tun5 = 1 or library.tun5 = 3) then Subkonto.algsaldo else 0 end, 
			case when (library.tun5 = 2 or library.tun5 = 4) then -1 * Subkonto.algsaldo else 0 end,
			case when library.tun1 = 1 then asutus.tp else '' end, 
			tnrekvId, lcreturn, library.nimetus
		FROM library  inner join Subkonto on (library.id = Subkonto.kontoid and library.library = 'KONTOD') 
		inner join asutus on asutus.id = subkonto.asutusId
		inner join tmprekv on subkonto.rekvId = tmprekv.id
		where LEN(LTRIM(library.kood)) >= 6;

raise notice 'subkonto 1 lopp';

INSERT INTO tmp_saldoandmik (konto, rahavoo,  db, kr, rekvId, timestamp, nimetus) 
	SELECT LEFT(ALLTRIM(CursorAlgSaldo.konto),6), 
		case when library.tun4 = 1 then  '00' else '' end, 
		case when (library.tun5=1 or library.tun5 = 3) then
			(CursorAlgSaldo.deebet - CursorAlgSaldo.kreedit) else 0 end as db, 
		case when (library.tun5=2 or library.tun5 = 4) then 
			(CursorAlgSaldo.kreedit - CursorAlgSaldo.deebet) else 0 end as kr, 
		tnrekvid, lcReturn, library.nimetus
	FROM 
		(
			SELECT  library.kood AS konto,  
				CASE
					WHEN kontoinf.algsaldo >= 0::numeric THEN kontoinf.algsaldo
					ELSE 0::numeric(12,4)
					END AS deebet, 
				CASE
					WHEN kontoinf.algsaldo < 0::numeric THEN (- 1::numeric) * kontoinf.algsaldo
					ELSE 0::numeric(12,4)
				END AS kreedit
			FROM library
				JOIN kontoinf ON library.id = kontoinf.parentid
				Inner join tmpRekv on kontoinf.rekvid = tmpRekv.id
			WHERE kontoinf.algsaldo <> 0::numeric
			and library.id  not in 
			(
				select distinct kontoid from Subkonto  
					inner join tmpRekv on subkonto.rekvid = tmpRekv.id
				where subkonto.algsaldo <> 0
			)
			union all
			SELECT  journal1.deebet AS konto, sum(journal1.summa) AS deebet, 0::numeric(12,4) AS kreedit 
				FROM journal inner join journal1 on journal.id = journal1.parentid 
					inner join tmpRekv on Journal.rekvid = tmpRekv.id
				where year(Journal.kpv) < year(tdKpv)
				group by journal1.deebet
			UNION ALL 
			SELECT  journal1.kreedit AS konto, 0::numeric(12,4) as deebet, sum(journal1.summa) AS kreedit
				FROM journal inner join journal1 on journal.id = journal1.parentid 
				inner join tmpRekv on Journal.rekvid = tmpRekv.id
				where year(Journal.kpv) < year(tdKpv)
				group by journal1.kreedit
		) CursorAlgSaldo inner join library on (library.kood = CursorAlgSaldo.konto and library.library = 'KONTOD')	
	WHERE LEFT(LTRIM(CursorAlgSaldo.konto),6) NOT in 
			(
			select distinct LEFT(LTRIM(library.kood),6) 
				FROM library 
				inner join eelarveinf on library.id = eelarveinf.kontoid 
				inner join tmprekv on eelarveinf.rekvid = tmprekv.id
				where eelarveinf.algsaldo <> 0 
			)	
	and (CursorAlgSaldo.deebet <> 0 OR CursorAlgSaldo.kreedit <> 0) 
	AND  LEN(LTRIM(CursorAlgSaldo.konto)) >= 6;

raise notice 'CursorAlgSaldo 2  lopp';
-- and isdigit(lcAllikas) > 0	
INSERT INTO tmp_saldoandmik (konto, allikas, db, kr, rekvid, timestamp, nimetus) 
	SELECT LEFT(LTRIM(library.kood),6), 
		case when library.tun3 = 1  then allikad.kood else '' end as allikas, 
		case when (library.tun5=1 or library.tun5 = 3) then
			(eelarveinf.algsaldo) else 0 end as db, 
		case when (library.tun5=2 or library.tun5 = 4) then 
			(-1 * eelarveinf.algsaldo) else 0 end as kr, 
		tnrekvId, lcReturn, library.nimetus
		FROM eelarveinf inner join library on eelarveinf.kontoId = library.id 
		inner join library Allikad on eelarveinf.allikadId = allikad.id
		inner join tmprekv on tmprekv.id = eelarveinf.rekvid	
		where LEN(LTRIM(library.kood)) >= 6
		and eelarveinf.algsaldo <> 0; 

raise notice 'eelarveinf 3  lopp';


INSERT INTO tmp_saldoandmik (konto, rahavoo, db, kr, rekvid, timestamp, nimetus) 
	SELECT LEFT(LTRIM(library.kood),6), 
		case when library.tun4 = 1 then  comRaharemote.kood else '' end, 
		case when (library.tun5=1 or library.tun5 = 3) then (eelarveinf.algsaldo) else 0 end as db, 
		case when (library.tun5=2 or library.tun5 = 4) then (-1 * eelarveinf.algsaldo) else 0 end as kr, 
		tnRekvid, lcreturn, library.nimetus
		FROM eelarveinf inner join library on eelarveinf.kontoId = library.id 
		inner join library comRaharemote on eelarveinf.RahavooId = comRaharemote.id
		inner join tmprekv on eelarveinf.rekvid = tmprekv.id
		where LEN(LTRIM(library.kood)) >= 6
		and eelarveinf.algsaldo <> 0 ;

raise notice 'eelarveinf 4  lopp';

--and isdigit(lcAllikas) > 0
INSERT INTO tmp_saldoandmik (konto, tp, tegev, allikas, rahavoo, db, kr, rekvid, timestamp, nimetus) 
SELECT konto, 
	case when library.tun1 = 1 then tp else '' end, 
	case when (library.tun2 = 1 and (left(konto,3) <> '154' or left(konto,3) <> '155' or left(konto,3) <> '156')) then tegev else '' end, 
	case when (library.tun3 = 1 ) then allikas else '' end as allikas, 
	case when library.tun4 = 1 then  rahavoo else '' end, 
	case when (library.tun5=1 or library.tun5 = 3) then
			(sum(deebet) - sum (kreedit) ) else 0 end as db, 
	case when (library.tun5=2 or library.tun5 = 4) then 
			(sum (kreedit) - sum(deebet)) else 0 end as kr, 
	tnRekvId , lcReturn, library.nimetus
from 
(
	SELECT journal1.deebet As konto, journal1.lisa_d As tp, journal1.kood1 As tegev, journal1.kood2 As allikas, journal1.kood3 As rahavoo, 
		sum(journal1.Summa) As deebet, 0 As kreedit  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
			inner join tmpRekv on Journal.rekvid = tmpRekv.id
		where journal.kpv <= tdKpv
		and year(kpv) = year(tdKpv)
		group by journal1.deebet, journal1.lisa_d, journal1.kood1, journal1.kood2, journal1.kood3 
		UNION All 
	SELECT journal1.kreedit As konto, journal1.lisa_k As tp, journal1.kood1 As tegev, journal1.kood2 As allikas, journal1.kood3 As rahavoo, 
		0 As deebet, sum(journal1.Summa) As kreedit  
		FROM Journal inner join journal1 on journal.id = journal1.parentid
			inner join tmpRekv on Journal.rekvid = tmpRekv.id
		where journal.kpv <= tdKpv 
		and year(kpv) = year(tdKpv)
		group by journal1.kreedit, journal1.lisa_k, journal1.kood1, journal1.kood2, journal1.kood3 

) qrySaldoaruanne inner join library on (library.kood =  qrySaldoaruanne.konto and library.library = 'KONTOD') 
group BY konto, tp, tegev, allikas, rahavoo, library.tun1, library.tun2, library.tun3, library.tun4, library.tun5, library.nimetus  
ORDER BY konto, tp, tegev, allikas, rahavoo;


raise notice 'kaibed 5  lopp';


DELETE FROM tmp_saldoandmik WHERE  (konto = '999999' or (db = 0 and kr= 0)) and rekvid = tnRekvId;

return LCRETURN;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
ALTER FUNCTION sp_saldoandmik_report(integer, date, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_report(integer, date, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_report(integer, date, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_report(integer, date, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_report(integer, date, integer, integer) TO dbpeakasutaja;
