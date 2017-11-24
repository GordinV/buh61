-- Function: sp_saldoandmik_aruanned(integer, date, integer, integer, integer, integer)

-- DROP FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE tnRekvId alias for $1;
	tdKpv alias for $2;
	tnAasta alias for $3;
	tnLiik alias for $4; 
	tnTyyp alias for $5;
	tnSvod alias for $6;

	lnTase integer;
	lcReturn varchar;
	lcString varchar;
	lcOmaTp varchar;
	cOmaTp varchar;
	v_rekv record;
	v_tp record;
	v_omatp record;
	v_saldo record;
	lnRekvId integer;
	lnDeebet numeric(14,2);
	lnKreedit numeric(14,2);

	lnDb2 numeric(14,2);
	lnDb3 numeric(14,2);
	lnDb31 numeric(14,2);
	lnDb7 numeric(14,2);
	lnDb2035 numeric(14,2);
	lnKr2 numeric(14,2);
	lnKr3 numeric(14,2);
	lnKr31 numeric(14,2);
	lnKr7 numeric(14,2);
	lnKr2035 numeric(14,2);

	lnTulemus integer;

	v_test record;
	lcRetElim varchar(20);
begin


lnTulemus = 0;
--tnSvod = 1;

if (select count(*) from pg_stat_all_tables where UPPER(relname) = 'TMP_SK_ARUANNED')  < 1 then
	
	CREATE TABLE tmp_sk_aruanned
	(
	id serial NOT NULL,
	nimetus character varying(254) NOT NULL DEFAULT space(1),
	summa01 numeric(14,2) NOT NULL DEFAULT 0,
	summa02 numeric(14,2) NOT NULL DEFAULT 0,
	summa03 numeric(14,2) NOT NULL DEFAULT 0,
	summa04 numeric(14,2) NOT NULL DEFAULT 0,
	summa05 numeric(14,2) NOT NULL DEFAULT 0,
	summa06 numeric(14,2) NOT NULL DEFAULT 0,
	summa07 numeric(14,2) NOT NULL DEFAULT 0,
	summa08 numeric(14,2) NOT NULL DEFAULT 0,
	summa09 numeric(14,2) NOT NULL DEFAULT 0,
	summa10 numeric(14,2) NOT NULL DEFAULT 0,
	summa11 numeric(14,2) NOT NULL DEFAULT 0,
	summa12 numeric(14,2) NOT NULL DEFAULT 0,
	summa13 numeric(14,2) NOT NULL DEFAULT 0,
	summa14 numeric(14,2) NOT NULL DEFAULT 0,
	summa15 numeric(14,2) NOT NULL DEFAULT 0,
	konto character varying(20) NOT NULL DEFAULT space(1),
	tegev character varying(20) NOT NULL DEFAULT space(1),
	tp character varying(20) NOT NULL DEFAULT space(1),
	allikas character varying(20) NOT NULL DEFAULT space(1),
	rahavoo character varying(20) NOT NULL DEFAULT space(1),
	kpv date DEFAULT date(),
	rekvid integer,
	timestamp varchar(20) not null,
	omatp character varying(20) NOT NULL DEFAULT space(1),
	tyyp integer DEFAULT 0
	) ;

	ALTER TABLE tmp_sk_aruanned OWNER TO vlad;

	GRANT ALL ON TABLE tmp_sk_aruanned TO GROUP public;
	GRANT ALL ON TABLE tmp_sk_aruanned_id_seq TO public;
		

end if;

delete from tmp_sk_aruanned where kpv < date() and rekvid = tnrekvId;

lnRekvId = tnRekvId;

if tnSvod = 1 then
	lnTase = 3;

	if tnrekvId = 63 then 
		lnRekvId = 0;
	end if;

else
	lnTase = 9;
end if;


-- otsime oma TP kood

/*
SELECT TP INTO lcOmaTp FROM Aa WHERE Aa.parentid = tnRekvId   AND Aa.kassa = 2 ORDER BY ID DESC LIMIT 1;
lcOmaTp = ifnull(lcOmaTp,'');
*/
lcOmaTp = ltrim(rtrim(fnc_getomatp(tnrekvid,tnAasta)));		
raise notice 'Oma tp: %',lcOmaTp;

-- kpv kontroll

if tnTyyp = 1 or (select count(*) from saldoandmik where aasta = year(tdKpv) and kuu = month(tdKpv) and rekvid = tnrekvId and kpv = tdKpv) = 0 then
	-- re-arvesta saldoandmik
	raise notice 'Arvestame saldoandmik.. ';
	lnTulemus =  sp_koosta_saldoandmik(tnrekvId, tdKpv, 1, 1);

	if tnSvod = 1 and tnRekvId = 63 then
		perform sp_saldoandmik_aruanned(tnRekvid, tdKpv, year(tdKpv), 2, 0, 1);
	end if;
	raise notice 'Arvestame saldoandmik, tulemus: %',lnTulemus;
end if;

lcreturn := ltrim(rtrim(str(tnrekvId)))+to_char(now(), 'YYYYMMDDMISSSS');
if tnLiik = 7 then


	raise notice 'Materiaalse pohivara liikumise aruanne';

lnDb2 = 0;
lnKr2 = 0;
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '01','Jaak perioodi alguses',0,tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),1)) >= 3 and val(left(ltrim(rtrim(saldoandmik.konto)),2)) <= 64;

--Saldoandmikust (Sum: Konto 155000 Deebet RV 00) - (Sum: Konto 155000 Kreedit RV 00)
			select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '155000' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('010','Soetusmaksumus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);	
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);

--Saldoandmikust (Sum: Konto 15510* Deebet RV 00) - (Sum: Konto 15510* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '15510' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('010','Soetusmaksumus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

	lnDb2 = lnDb2 + ifnull(lnDeebet,0);	
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);

--Saldoandmikust (Sum: Konto 15530* Deebet RV 00) - (Sum: Konto 15530* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '15530' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('010','Soetusmaksumus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

	lnDb2 = lnDb2 + ifnull(lnDeebet,0);	
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);

--Saldoandmikust (Sum: Konto 15540* Deebet RV 00+Konto 15550* Deebet RV 00) - (Sum: Konto 15540* Kreedit RV 00 +Konto 15550* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '15540' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('010','Soetusmaksumus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

	lnDb2 = lnDb2 + ifnull(lnDeebet,0);	
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);

--Saldoandmikust (Sum: Konto 15560* Deebet RV 00+Konto 15570* Deebet RV 00) - (Sum: Konto 15560* Kreedit RV 00 +Konto 15570* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '15560' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('010','Soetusmaksumus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

	lnDb2 = lnDb2 + ifnull(lnDeebet,0);	
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);

--Saldoandmikust (Sum: Konto 1559* Deebet RV 00) - (Sum: Konto 1559* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '15559' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('010','Soetusmaksumus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

	lnDb2 = lnDb2 + ifnull(lnDeebet,0);	
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);

	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('010','Soetusmaksumus',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);

--Kogunenud kulum
	lnDb2 = 0;
	lnKr2 = 0;
--Saldoandmikust (Sum: Konto 15511* Deebet RV 00) - (Sum: Konto 15511* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '15511' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('011','Kogunenud kulum',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

	lnDb2 = lnDb2 + ifnull(lnDeebet,0);	
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
			
--Saldoandmikust (Sum: Konto 15531* Deebet RV 00) - (Sum: Konto 15531* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '15531' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('011','Kogunenud kulum',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

	lnDb2 = lnDb2 + ifnull(lnDeebet,0);	
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);

--Saldoandmikust (Sum: Konto 15541* Deebet RV 00+Konto 15551* Deebet RV 00) - (Sum: Konto 15541* Kreedit RV 00 +Konto 15551* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) in ('15541','15551') and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('011','Kogunenud kulum',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

	lnDb2 = lnDb2 + ifnull(lnDeebet,0);	
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);

--Saldoandmikust (Sum: Konto 15561* Deebet RV 00+Konto 15571* Deebet RV 00) - (Sum: Konto 15561* Kreedit RV 00 +Konto 15571* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) in ('15561','15571') and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('011','Kogunenud kulum',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

	lnDb2 = lnDb2 + ifnull(lnDeebet,0);	
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);

	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('011','Kogunenud kulum',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);

--Jaakvaartus
	lnDb2 = 0;
	lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet RV 00) - (Sum: Konto 155000 Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '155000' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('012','Jaakvaartus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

--Saldoandmikust (Sum: Konto 1551* Deebet RV 00) - (Sum: Konto 1551* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1551' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('012','Jaakvaartus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);


--Saldoandmikust (Sum: Konto 1553* Deebet RV 00) - (Sum: Konto 1553* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1553' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('012','Jaakvaartus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

--Saldoandmikust (Sum: Konto 1554* Deebet RV 00+Konto 1555* Deebet RV 00) - (Sum: Konto 1554* Kreedit RV 00+Konto 1555* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1554' and saldoandmik.rahavoo = '00';
	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('012','Jaakvaartus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

--Saldoandmikust (Sum: Konto 1556* Deebet RV 00+Konto 1557* Deebet) - (Sum: Konto 1556* Kreedit +Konto 1557* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1556' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('012','Jaakvaartus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

--Saldoandmikust (Sum: Konto 1559* Deebet RV 00) - (Sum: Konto 1559* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('012','Jaakvaartus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

--Saldoandmikust (Sum: Konto 155* Deebet RV 00) - (Sum: Konto 155* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = '155' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('012','Jaakvaartus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

--Muugiootel pohivara
--Saldoandmikust (Sum: Konto 109010 Deebet RV 00) - (Sum: Konto 109010 Kreedit RV 00)

		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '109010' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('013','Muugiootel pohivara',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
--Saldoandmikust (Sum: Konto 109011, 109012, 109013 Deebet RV 00) - (Sum: Konto 109011, 109012, 109013 Kreedit RV 00)

		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('109011','109012','109013') and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('013','Muugiootel pohivara',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
--Saldoandmikust (Sum: Konto 109014 Deebet RV 00) - (Sum: Konto 109014 Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '109014' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('013','Muugiootel pohivara',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
--Saldoandmikust (Sum: Konto 109015,109016,109017 Deebet RV 00) - (Sum: Konto 109015,109016,109017 Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('109015','109016','109017') and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('013','Muugiootel pohivara',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
--Saldoandmikust (Sum: Konto 109018,109019 Deebet RV 00) - (Sum: Konto 109018,109019 Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('109018','109019') and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('013','Muugiootel pohivara',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
--Saldoandmikust (Sum: Konto 10901* Deebet RV 00) - (Sum: Konto 10901* Kreedit RV 00)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '10901' and saldoandmik.rahavoo = '00';

	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('013','Muugiootel pohivara',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
--Soetused ja parendused
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 01)) - (Sum: Konto 155000 Kreedit (RV 01))
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '155000' and saldoandmik.rahavoo = '01';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('02','Soetused ja parendused',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 01)) - (Sum: Konto 1551* Kreedit (RV 01))
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1551' and saldoandmik.rahavoo = '01';

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('02','Soetused ja parendused',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 01)) - (Sum: Konto 1553* Kreedit (RV 01))
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1553' and saldoandmik.rahavoo = '01';

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('02','Soetused ja parendused',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 01); Konto 1555* Deebet (RV 01)) - (Sum: Konto 1554* Kreedit (RV 01); konto 1555* Kreedit (RV 01))
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555') and saldoandmik.rahavoo = '01';

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('02','Soetused ja parendused',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 01); Konto 1557* Deebet (RV 01)) - (Sum: Konto 1556* Kreedit (RV 01); Konto 1557* Kreedit (RV 01))
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557') and saldoandmik.rahavoo = '01';

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('02','Soetused ja parendused',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 01)) - (Sum: Konto 1559* Kreedit (RV 01))
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559' and saldoandmik.rahavoo = '01';

raise notice '1559 lnDeebet %',lnDeebet;
raise notice '1559 lnKreedit %',lnKreedit;
	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('02','Soetused ja parendused',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);

	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('02','Soetused ja parendused',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);

--Saadud mitterahaline sihtfinantseerimine
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 19)) - (Sum: Konto 155000 Kreedit (RV 19))
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '155000' and saldoandmik.rahavoo = '19';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('03','Saadud mitterahaline sihtfinantseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 19)) - (Sum: Konto 1551* Kreedit (RV 19))
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1551' and saldoandmik.rahavoo = '19';

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('03','Saadud mitterahaline sihtfinantseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 19)) - (Sum: Konto 1553* Kreedit (RV 19))
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1553' and saldoandmik.rahavoo = '19';

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('03','Saadud mitterahaline sihtfinantseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);

--Saldoandmikust (Sum: Konto 1554* Deebet (RV 19); Konto 1555* Deebet (RV 19)) - (Sum: Konto 1554* Kreedit (RV 19); Konto 1555* Kreedit (RV 19))
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in('1554','1555') and saldoandmik.rahavoo = '19';

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('03','Saadud mitterahaline sihtfinantseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 19); Konto 1557* Deebet (RV 19)) - (Sum: Konto 1556* Kreedit (RV 19); Konto 1557* Kreedit (RV 19))
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in('1556','1557') and saldoandmik.rahavoo = '19';

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('03','Saadud mitterahaline sihtfinantseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 19)) - (Sum: Konto 1559* Kreedit (RV 19))
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559' and saldoandmik.rahavoo = '19';

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('03','Saadud mitterahaline sihtfinantseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);

	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('03','Saadud mitterahaline sihtfinantseerimine',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);

--Saadud mitterahalised sissemaksed
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 18); konto 109010 deebet RV 18) - (Sum: Konto 155000 Kreedit (RV 18); konto 109010 kreedit RV 18)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '155000' and saldoandmik.rahavoo = '18';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('03','Saadud mitterahalised sissemaksed',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 18); konto 109011 deebet RV 18; konto 109012 deebet RV 18; konto 109013 deebet RV 18) - (Sum: Konto 1551* Kreedit (RV 18); konto 109011 kreedit RV 18; konto 109012 kreedit RV 18; konto 109013 kreedit RV 18)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1551' or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109011','109012','109013')) and saldoandmik.rahavoo = '18';

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('03','Saadud mitterahalised sissemaksed',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 18); konto 109014 deebet RV 18) - (Sum: Konto 1553* Kreedit (RV 18); konto 109014 kreedit RV 18)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1553' or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109014')) and saldoandmik.rahavoo = '18';

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('03','Saadud mitterahalised sissemaksed',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 18); Konto 1555* Deebet (RV18); konto 109015 deebet RV 18; konto 109016 deebet RV 18; konto 109017 deebet RV 18) - (Sum: Konto 1554* Kreedit (RV18); Konto 1555* Kreedit (RV18); konto 109015 kreedit RV 18; konto 109016 kreedit RV 18; konto 109017 kreedit RV 18)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in( '1554','1555') or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109015','109016','109017')) and saldoandmik.rahavoo = '18';

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('03','Saadud mitterahalised sissemaksed',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 18); Konto 1557* Deebet (RV 18); konto 109018 deebet RV 18; konto 109019 deebet RV 18) - (Sum: Konto 1556* Kreedit (RV 18); Konto 1557* Kreedit (RV 18); konto 109018 kreedti RV 18; konto 109019 kreedit RV 18)
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in( '1556','1557') or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109018','109019')) and saldoandmik.rahavoo = '18';

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('03','Saadud mitterahalised sissemaksed',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 18)) - (Sum: Konto 1559* Kreedit (RV 18))
		select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559' and saldoandmik.rahavoo = '18';

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('03','Saadud mitterahalised sissemaksed',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('03','Saadud mitterahalised sissemaksed',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);

--Varade suurenemine seoses valitseva moju tekkimisega
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 20); konto 109010 deebet RV 20) - (Sum: Konto 155000 Kreedit (RV 20); konto 109010 kreedit RV 20)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6) = '155000' or left(ltrim(rtrim(saldoandmik.konto)),6) = '109010') 
			and saldoandmik.rahavoo = '20';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('04','Varade suurenemine seoses valitseva moju tekkimisega',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 20); konto 109011 deebet RV 20; konto 109012 deebet RV 20; konto 109013 deebet RV 20) - (Sum: Konto 1551* Kreedit (RV 20); konto 109011 kreedit RV 20; konto 109012 kreedit RV 20; konto 109013 kreedit RV 20)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1551' or left(ltrim(rtrim(saldoandmik.konto)),6) in('109011','109012','109013')) 
			and saldoandmik.rahavoo = '20';

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('04','Varade suurenemine seoses valitseva moju tekkimisega',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 20); konto 109014 deebet RV 20) - (Sum: Konto 1553* Kreedit (RV 20); konto 109014 kreedit RV 20)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1553' or left(ltrim(rtrim(saldoandmik.konto)),6) in('109014')) 
			and saldoandmik.rahavoo = '20';

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('04','Varade suurenemine seoses valitseva moju tekkimisega',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 20); Konto 1555* Deebet (RV 20); konto 109015 deebet RV 20; konto 109016 deebet RV 20; konto 109017 deebet RV 20) - (Sum: Konto 1554* Kreedit (RV 20); Konto 1555* Kreedit (RV 20); konto 109015 kreedit RV 20; konto 109016 kreedit RV 20; konto 109017 kreedit RV 20)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1555' or left(ltrim(rtrim(saldoandmik.konto)),6) in('109015','109016','109017')) 
			and saldoandmik.rahavoo = '20';

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('04','Varade suurenemine seoses valitseva moju tekkimisega',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 20); Konto 1557* Deebet (RV 20); konto 109018 deebet RV 20; konto 109019 deebet RV 20) - (Sum: Konto 1556* Kreedit (RV 20); Konto 1557* Kreedit (RV 20); konto 109018 kreedit RV 20; konto 109019 kreedit RV 20)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557') or left(ltrim(rtrim(saldoandmik.konto)),6) in('109018','109019')) 
			and saldoandmik.rahavoo = '20';

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('04','Varade suurenemine seoses valitseva moju tekkimisega',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 20)) - (Sum: Konto 1559* Kreedit (RV 20))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'  
			and saldoandmik.rahavoo = '20';

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('04','Varade suurenemine seoses valitseva moju tekkimisega',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('04','Varade suurenemine seoses valitseva moju tekkimisega',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);

--Ule toodud kinnisvarainvesteeringutest
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 14)) - (Sum: Konto 155000 Kreedit (RV 14))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '155000'  
			and saldoandmik.rahavoo = '14';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('05','Ule toodud kinnisvarainvesteeringutest',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 14)) - (Sum: Konto 1551* Kreedit (RV 14))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1551'  
			and saldoandmik.rahavoo = '14';

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('05','Ule toodud kinnisvarainvesteeringutest',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 14)) - (Sum: Konto 1553* Kreedit (RV 14))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1553'  
			and saldoandmik.rahavoo = '14';

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('05','Ule toodud kinnisvarainvesteeringutest',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 14); Konto 1555* Deebet (RV 14)) - (Sum: Konto 1554* Kreedit (RV 14); Konto 1555* Kreedit (RV 14))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555')   
			and saldoandmik.rahavoo = '14';

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('05','Ule toodud kinnisvarainvesteeringutest',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 14); Konto 1557* Deebet (RV 14)) - (Sum: Konto 1556* Kreedit (RV 14); Konto 1557* Kreedit (RV 14))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557')   
			and saldoandmik.rahavoo = '14';

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('05','Ule toodud kinnisvarainvesteeringutest',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 14)) - (Sum: Konto 1559* Kreedit (RV 14))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('15569')   
			and saldoandmik.rahavoo = '14';

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('05','Ule toodud kinnisvarainvesteeringutest',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('05','Ule toodud kinnisvarainvesteeringutest',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);
--Kulum ja allahindlus
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 11); konto 109010 Deebet (RV 11)) - (Sum: Konto 155000 Kreedit (RV 11); konto 109010 Kreedit (RV 11))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('155000','109010')   
			and saldoandmik.rahavoo = '11';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('06','Kulum ja allahindlus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 11); konto 109011 deebet RV 11, 109012 deebet RV 11, 109013 deebet RV 11) - (Sum: Konto 1551* Kreedit (RV 11); konto 109011 kreedit RV 11, konto 109012 kreedit RV 11; konto 109013 kreedit RV 11)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1551' or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109011','109012','109013'))   
			and saldoandmik.rahavoo = '11';

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('06','Kulum ja allahindlus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 11); konto 109014 deebet RV 11) - (Sum: Konto 1553* Kreedit (RV 11); konto 109014 kreedit RV 11)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1553' or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109014'))   
			and saldoandmik.rahavoo = '11';

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('06','Kulum ja allahindlus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 11); konto 1555* deebet RV 11; konto 109015 deebet Rv 11; konto 109016 deebet RV 11, konto 109017 deebet Rv 11) - (Sum: Konto 1554* Kreedit (RV 11)); Konto 1555* Kreedit (RV 11), konto 109015 kreedit Rv 11; konto 109016 kreedit RV 11; konto 109017 kreedit RV 11)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555') or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109015','109016','109017'))   
			and saldoandmik.rahavoo = '11';

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('06','Kulum ja allahindlus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 11); konto 1557* deebet RV 11; konto 109018 deebet RV 11; konto 109019 deebet RV 11) - (Sum: Konto 1556* Kreedit (RV 11));Konto 1557* Kreedit (RV 11); konto 109018 kreedit RV 11; konto 109019 kreedit RV 11)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557') or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109018','109019'))   
			and saldoandmik.rahavoo = '11';

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('06','Kulum ja allahindlus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 11)) - (Sum: Konto 1559* Kreedit (RV 11))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'   
			and saldoandmik.rahavoo = '11';

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('06','Kulum ja allahindlus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('06','Kulum ja allahindlus',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);

--Muudud pohivara jaakvaartuse mahakandmine
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 02), konto 109010 deebet RV 02) - (Sum: Konto 155000 Kreedit (RV 02); konto 109010 kreedit RV 02)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('155000','109010')   
			and saldoandmik.rahavoo = '02';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('07','Muudud pohivara jaakvaartuse mahakandmine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 02); konto 109011 deebet RV 02, konto 109012 deebet RV 02, konto 109013 deebet RV 02) - (Sum: Konto 1551* Kreedit (RV 02); konto 109011 kreedit RV 02, konto 109012 kreedit RV 02; konto 109013 kreedit RV 02)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1551' or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109011','109012','109013'))   
			and saldoandmik.rahavoo = '02';

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('07','Muudud pohivara jaakvaartuse mahakandmine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 02); konto 109014 deebet RV 02) - (Sum: Konto 1553* Kreedit (RV 02); konto 109014 kreedit RV 02)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1553' or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109014'))   
			and saldoandmik.rahavoo = '02';

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('07','Muudud pohivara jaakvaartuse mahakandmine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 02)); Konto 1555* Deebet (RV 02); konto 109015 deebet RV 02; konto 109016 deebet RV 02; konto 109017 deebet RV 02) - (Sum: Konto 1554* Kreedit (RV 02)); Konto 1555* Kreedit (RV 02); konto 109015 kreedit RV 02; konto 109016 kreedit RV 02; konto 109017 kreedit RV 02)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555') or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109015','109016','109017'))   
			and saldoandmik.rahavoo = '02';

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('07','Muudud pohivara jaakvaartuse mahakandmine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 02)); Konto 1557* Deebet (RV 02); konto 109018 deebet RV 02; konto 109019 deebet RV 02) - (Sum: Konto 1556* Kreedit (RV 02); Konto 1557* Kreedit (RV 02); konto 109018 kreedit RV 02; konto 109019 kreedit RV 02)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557') or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109018','109019'))   
			and saldoandmik.rahavoo = '02';

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('07','Muudud pohivara jaakvaartuse mahakandmine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 02)) - (Sum: Konto 1559* Kreedit (RV 02))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) =  '1559'   
			and saldoandmik.rahavoo = '02';

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('07','Muudud pohivara jaakvaartuse mahakandmine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('07','Muudud pohivara jaakvaartuse mahakandmine',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);

--Muu mahakandmine jaakvaartuses
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 12)) - (Sum: Konto 155000 Kreedit (RV 12))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) =  '155000'   
			and saldoandmik.rahavoo = '12';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('08','Muu mahakandmine jaakvaartuses',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 12)) - (Sum: Konto 1551* Kreedit (RV 12))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) =  '1551'   
			and saldoandmik.rahavoo = '12';

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('08','Muu mahakandmine jaakvaartuses',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 12)) - (Sum: Konto 1553* Kreedit (RV 12))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) =  '1553'   
			and saldoandmik.rahavoo = '12';

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('08','Muu mahakandmine jaakvaartuses',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 12); Konto 1555* Deebet (RV 12)) - (Sum: Konto 1554* Kreedit (RV 12); Konto 1555* Kreedit (RV 12))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in('1554','1555')   
			and saldoandmik.rahavoo = '12';

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('08','Muu mahakandmine jaakvaartuses',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 12); Konto 1557* Deebet (RV 12)) - (Sum: Konto 1556* Kreedit (RV 12); Konto 1557* Kreedit (RV 12))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in('1556','1557')   
			and saldoandmik.rahavoo = '12';

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('08','Muu mahakandmine jaakvaartuses',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 12)) - (Sum: Konto 1559* Kreedit (RV 12))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'   
			and saldoandmik.rahavoo = '12';

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('08','Muu mahakandmine jaakvaartuses',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('08','Muu mahakandmine jaakvaartuses',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);
--Ule viidud kinnisvarainvesteeringutesse
lnDb2 = 0;
lnKr2= 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 13)) - (Sum: Konto 155000 Kreedit (RV 13))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '155000'   
			and saldoandmik.rahavoo = '13';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('09','Ule viidud kinnisvarainvesteeringutesse',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 13)) - (Sum: Konto 1551* Kreedit (RV 13))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1551'   
			and saldoandmik.rahavoo = '13';

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('09','Ule viidud kinnisvarainvesteeringutesse',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 13)) - (Sum: Konto 1553* Kreedit (RV 13))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1553'   
			and saldoandmik.rahavoo = '13';

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('09','Ule viidud kinnisvarainvesteeringutesse',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 13); Konto 1555* Deebet (RV 13)) - (Sum: Konto 1554* Kreedit (RV 13); Konto 1555* Kreedit (RV 13))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555')   
			and saldoandmik.rahavoo = '13';

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('09','Ule viidud kinnisvarainvesteeringutesse',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 13); Konto 1557* Deebet (RV 13)) - (Sum: Konto 1556* Kreedit (RV 13); Konto 1557* Kreedit (RV 13))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557')   
			and saldoandmik.rahavoo = '13';

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('09','Ule viidud kinnisvarainvesteeringutesse',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 13)) - (Sum: Konto 1559* Kreedit (RV 13))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'   
			and saldoandmik.rahavoo = '13';

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('09','Ule viidud kinnisvarainvesteeringutesse',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('09','Ule viidud kinnisvarainvesteeringutesse',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);
--Ule toodud ja ule viidud muugiootel pohivaraks
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 26, RV 27); konto 109010 deebet (RV 26; RV 27)) - (Sum: Konto 155000 Kreedit (RV 26, RV 27); konto 109010 kreedit (RV 26, RV 27))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('155000','109010')   
			and saldoandmik.rahavoo in ('26','27');

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('10','Ule toodud ja ule viidud muugiootel pohivaraks',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 26, RV 27); konto 109011 deebet RV 26 RV 27; konto 109012 RV deebet RV 26, RV 27; konto 109013 deebet RV 26, RV 27) - (Sum: Konto 1551* Kreedit (RV 26, RV 27); konto 109011 kreedit RV 26, RV 27; konto 109012 kreedit RV 26, RV 27; konto 109013 kreedit RV 26, RV 27)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1551' or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109011','109012','109013'))   
			and saldoandmik.rahavoo in ('26','27');

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('10','Ule toodud ja ule viidud muugiootel pohivaraks',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 26, RV 27); konto 109014 deebet RV 26, RV 27) - (Sum: Konto 1553* Kreedit (RV 26, RV 27); konto 109014 kreedit RV 26, RV 27)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1553' or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109014'))   
			and saldoandmik.rahavoo in ('26','27');

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('10','Ule toodud ja ule viidud muugiootel pohivaraks',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 26, RV 27);Konto 1555* Deebet (RV 26, RV 27); konto 109015 deebet RV 26, RV 27; konto 109016 deebet RV 26, RV 27; konto 109017 deebet RV 26, RV 27) - (Sum: Konto 1554* Kreedit (RV 26, RV 27); Konto 1555* Kreedit (RV 26, RV 27); konto 109015 kreedit RV 26, RV 27; konto 109016 kreedti RV 26, RV 27; konto 109017 kreedit RV 26, RV 27)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555') or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109015','109016','109017'))   
			and saldoandmik.rahavoo in ('26','27');

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('10','Ule toodud ja ule viidud muugiootel pohivaraks',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 26, RV 27); Konto 1557* Deebet (RV 26, RV 27); konto 109018 deebet RV 26, RV 27; konto 109019 deebet RV 26, RV 27) - (Sum: Konto 1556* Kreedit (RV 26, RV 27); Konto 1557* Kreedit (RV 26, RV 27); konto 109018 kreedit RV 26, RV 27; konto 109019 kreedit RV 26, RV 27)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557') or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109018','109019'))   
			and saldoandmik.rahavoo in ('26','27');

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('10','Ule toodud ja ule viidud muugiootel pohivaraks',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 26, RV 27)) - (Sum: Konto 1559* Kreedit (RV 26, RV 27))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'   
			and saldoandmik.rahavoo in ('26','27');

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('10','Ule toodud ja ule viidud muugiootel pohivaraks',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('10','Ule toodud ja ule viidud muugiootel pohivaraks',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);
--Saadud ja ule antud siiretena
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 15, RV 16); konto 109010 deebet RV 15, RV 16) - (Sum: Konto 155000 Kreedit (RV 15, RV 16); konto 109010 kreedit RV 15, RV 16)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('155000','109010')   
			and saldoandmik.rahavoo in ('15','16');

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('11','Saadud ja ule antud siiretena',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 15, RV 16); konto 109011 deebet RV 15, RV 16, konto 109012 deebet RV 15, RV 16, konto deebet 109013 RV 15; RV 16) - (Sum: Konto 1551* Kreedit (RV 15, RV 16); konto 109011 kreedit RV 15, RV 16; konto 109012 kreedit RV 15, RV 16; konto 109013 kreedit RV 15, RV 16)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1551' or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109011','109012','109013'))   
			and saldoandmik.rahavoo in ('15','16');

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('11','Saadud ja ule antud siiretena',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 15, RV 16); konto 109014 deebet RV 15, RV 16) - (Sum: Konto 1553* Kreedit (RV 15, RV 16); konto 109014 kreedit RV 15, RV 16)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1553' or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109014'))   
			and saldoandmik.rahavoo in ('15','16');

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('11','Saadud ja ule antud siiretena',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 15, RV 16); Konto 1555* Deebet (RV15, RV 16); konto 109015 deebet RV 15, RV 16; konto 109016 deebet RV 15, RV 16; konto 109017 deebet RV 15, RV 16) - (Sum: Konto 1554* Kreedit (RV15, RV 16); konto 1555* Kreedit (RV15, RV 16); konto 109015 kreedit RV 15, RV 16; konto 109016 kreedit RV 15, RV 16; konto 109017 kreedit RV 15, RV 16)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555') or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109015','109016','109017'))   
			and saldoandmik.rahavoo in ('15','16');

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('11','Saadud ja ule antud siiretena',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 15, RV 16)); Konto 1557* Deebet (RV 15, RV 16); konto 109018 deebet RV 15, RV 16; konto 109019 deebet RV 15, RV 16) - (Sum: Konto 1556* Kreedit (RV 15; RV 16); Konto 1557* Kreedit (RV 15, RV 16); konto 109018 kreedit RV 15, RV 16; konto 109019 kreedit RV 15, RV 16)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557') or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109018','109019'))   
			and saldoandmik.rahavoo in ('15','16');

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('11','Saadud ja ule antud siiretena',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 15, RV 16)) - (Sum: Konto 1559* Kreedit (RV 15, RV 16))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'   
			and saldoandmik.rahavoo in ('15','16');

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('11','Saadud ja ule antud siiretena',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('11','Saadud ja ule antud siiretena',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);
--Ule antud mitterahalised sissemaksed
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 17); konto 109010 deebet RV 17) - (Sum: Konto 155000 Kreedit (RV 17); konto 109010 kreedit RV 17)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('155000','109010')   
			and saldoandmik.rahavoo in ('17');

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('12','Ule antud mitterahalised sissemaksed',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 17); konto 109011 deebet RV 17; konto 109012 deebet RV 17; konto 109013 deebet RV 17) - (Sum: Konto 1551* Kreedit (RV 17); konto 109011 kreedit RV 17; konto 109012 kreedit RV 17; konto 109013 kreedit RV 17)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1551' or left(ltrim(rtrim(saldoandmik.konto)),6) in  ('109011','109012','109013'))    
			and saldoandmik.rahavoo in ('17');

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('12','Ule antud mitterahalised sissemaksed',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 17); konto 109014 deebet RV 17) - (Sum: Konto 1553* Kreedit (RV 17); konto 109014 kreedit RV 17)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1553' or left(ltrim(rtrim(saldoandmik.konto)),6) in  ('109014'))    
			and saldoandmik.rahavoo in ('17');

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('12','Ule antud mitterahalised sissemaksed',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 17); Konto 1555* Deebet (RV17); konto 109015 deebet RV 17; konto 109016 deebet RV 17; konto 109017 deebet RV 17) - (Sum: Konto 1554* Kreedit (RV17); Konto 1555* Kreedit (RV17); konto 109015 kreedit RV 17; konto 109016 kreedit RV 17; konto 109017 kreedit RV 17)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555') or left(ltrim(rtrim(saldoandmik.konto)),6) in  ('109015','109016','109017'))    
			and saldoandmik.rahavoo in ('17');

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('12','Ule antud mitterahalised sissemaksed',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 17); Konto 1557* Deebet (RV 17); konto 109018 deebet RV 17; konto 109019 deebet RV 17) - (Sum: Konto 1556* Kreedit (RV 17); Konto 1557* Kreedit (RV 17); konto 109018 kreedti RV 17; konto 109019 kreedit RV 17)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557') or left(ltrim(rtrim(saldoandmik.konto)),6) in  ('109018','109019'))    
			and saldoandmik.rahavoo in ('17');

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('12','Ule antud mitterahalised sissemaksed',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 17)) - (Sum: Konto 1559* Kreedit (RV 17))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'    
			and saldoandmik.rahavoo in ('17');

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('12','Ule antud mitterahalised sissemaksed',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('12','Ule antud mitterahalised sissemaksed',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);

--Ule antud mitterahaline sihtfinantseerimine
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 24)) - (Sum: Konto 155000 Kreedit (RV 24))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '155000'    
			and saldoandmik.rahavoo in ('24');

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('13','Ule antud mitterahaline sihtfinantseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 24)) - (Sum: Konto 1551* Kreedit (RV 24))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1551'    
			and saldoandmik.rahavoo in ('24');

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('13','Ule antud mitterahaline sihtfinantseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 24)) - (Sum: Konto 1553* Kreedit (RV 24))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1553'    
			and saldoandmik.rahavoo in ('24');

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('13','Ule antud mitterahaline sihtfinantseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 24); Konto 1555* Deebet (RV 24)) - (Sum: Konto 1554* Kreedit (RV 24); Konto 1555* Kreedit (RV 24))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555')    
			and saldoandmik.rahavoo in ('24');

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('13','Ule antud mitterahaline sihtfinantseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 24); Konto 1557* Deebet (RV 24)) - (Sum: Konto 1556* Kreedit (RV 24); Konto 1557* Kreedit (RV 24))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557')    
			and saldoandmik.rahavoo in ('24');

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('13','Ule antud mitterahaline sihtfinantseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 24)) - (Sum: Konto 1559* Kreedit (RV 24))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'    
			and saldoandmik.rahavoo in ('24');

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('13','Ule antud mitterahaline sihtfinantseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('13','Ule antud mitterahaline sihtfinantseerimine',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);

--Varade vahenemine seoses valitseva moju kadumisega
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 25); 109010 deebet RV 25) - (Sum: Konto 155000 Kreedit (RV 25); konto 109010 kreedit RV 25)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('155000','109010')    
			and saldoandmik.rahavoo in ('25');

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('14','Varade vahenemine seoses valitseva moju kadumisega',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 25); konto 109011 deebet RV 25; konto 109012 deebet RV 25; konto 109013 deebet RV 25) - (Sum: Konto 1551* Kreedit (RV 25); konto 109011 kreedit RV 25; konto 109012 kreedit RV 25; konto 109013 kreedit RV 25)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1551' or left(ltrim(rtrim(saldoandmik.konto)),4) in ('109011','109012','109013'))    
			and saldoandmik.rahavoo in ('25');

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('14','Varade vahenemine seoses valitseva moju kadumisega',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 25); konto 109014 deebet RV 25) - (Sum: Konto 1553* Kreedit (RV 25); konto 109014 kreedit RV 25)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1553' or left(ltrim(rtrim(saldoandmik.konto)),4) in ('109014'))    
			and saldoandmik.rahavoo in ('25');

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('14','Varade vahenemine seoses valitseva moju kadumisega',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 25); Konto 1555* Deebet (RV 25); konto 109015 deebet RV 25; konto 109016 deebet RV 25; konto 109017 deebet RV 25) - (Sum: Konto 1554* Kreedit (RV 25); Konto 1555* Kreedit (RV 25); konto 109015 kreedit RV 25; konto 109016 kreedit RV 25; konto 109017 kreedit RV 25)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555') or left(ltrim(rtrim(saldoandmik.konto)),4) in ('109015','109016','109017'))    
			and saldoandmik.rahavoo in ('25');

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('14','Varade vahenemine seoses valitseva moju kadumisega',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 25); konto 1557* deebet (RV 25); konto 109018 deebet RV 25; konto 109019 deebet RV 25) - (Sum: Konto 1556* Kreedit (RV 25); Konto 1557* Kreedit (RV 25); konto 109018 kreedti RV 25; konto 109019 kreedit RV 25)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557') or left(ltrim(rtrim(saldoandmik.konto)),4) in ('109018','109019'))    
			and saldoandmik.rahavoo in ('25');

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('14','Varade vahenemine seoses valitseva moju kadumisega',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 25)) - (Sum: Konto 1559* Kreedit (RV 25))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'    
			and saldoandmik.rahavoo in ('25');

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('14','Varade vahenemine seoses valitseva moju kadumisega',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);

	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('14','Varade vahenemine seoses valitseva moju kadumisega',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);

--Umberhindlused
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 21)) - (Sum: Konto 155000 Kreedit (RV 21))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '155000'    
			and saldoandmik.rahavoo in ('21');

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('15','Umberhindlused',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 21)) - (Sum: Konto 1551* Kreedit (RV 21))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1551'    
			and saldoandmik.rahavoo in ('21');

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('15','Umberhindlused',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 21)) - (Sum: Konto 1553* Kreedit (RV 21))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1553'    
			and saldoandmik.rahavoo in ('21');

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('15','Umberhindlused',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 21); Konto 1555* Deebet (RV 21)) - (Sum: Konto 1554* Kreedit (RV 21); Konto 1555* Kreedit (RV 21))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555')    
			and saldoandmik.rahavoo in ('21');

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('15','Umberhindlused',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 21); Konto 1557* Deebet (RV 21)) - (Sum: Konto 1556* Kreedit (RV 21); Konto 1557* Kreedit (RV 21))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557')    
			and saldoandmik.rahavoo in ('21');

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('15','Umberhindlused',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 21)) - (Sum: Konto 1559* Kreedit (RV 21))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'    
			and saldoandmik.rahavoo in ('21');

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('15','Umberhindlused',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);

	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('15','Umberhindlused',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);
--Umberklassifitseerimine
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 23)) - (Sum: Konto 155000 Kreedit (RV 23))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '155000'    
			and saldoandmik.rahavoo in ('23');

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('16','Umberklassifitseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 23)) - (Sum: Konto 1551* Kreedit (RV 23))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1551'    
			and saldoandmik.rahavoo in ('23');

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('16','Umberklassifitseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 23)) - (Sum: Konto 1553* Kreedit (RV 23))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1553'    
			and saldoandmik.rahavoo in ('23');

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('16','Umberklassifitseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 23); Konto 1555* Deebet (RV 23)) - (Sum: Konto 1554* Kreedit (RV 23); Konto 1555* Kreedit (RV 23))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555')    
			and saldoandmik.rahavoo in ('23');

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('16','Umberklassifitseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 23); Konto 1557* Deebet (RV 23)) - (Sum: Konto 1556* Kreedit (RV 23); Konto 1557* Kreedit (RV 23))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557')    
			and saldoandmik.rahavoo in ('23');

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('16','Umberklassifitseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 23)) - (Sum: Konto 1559* Kreedit (RV 23))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'    
			and saldoandmik.rahavoo in ('23');

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('16','Umberklassifitseerimine',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('16','Umberklassifitseerimine',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);
--Korrigeerimine arvestuspohimotete muutuse ja vigade tottu
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 28); 109010 deebet RV 28) - (Sum: Konto 155000 Kreedit (RV 28); konto 109010 kreedit RV 28)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '155000'    
			and saldoandmik.rahavoo in ('28');

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('17','Korrigeerimine arvestuspohimotete muutuse ja vigade tottu',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 28); konto 109011 deebet RV 28; konto 109012 deebet RV 28; konto 109013 deebet RV 28) - (Sum: Konto 1551* Kreedit (RV 28); konto 109011 kreedit RV 28; konto 109012 kreedit RV 28; konto 109013 kreedit RV 28)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1551' or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109011','109012','109013'))    
			and saldoandmik.rahavoo in ('28');

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('17','Korrigeerimine arvestuspohimotete muutuse ja vigade tottu',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 28); konto 109014 deebet RV 28) - (Sum: Konto 1553* Kreedit (RV 28); konto 109014 kreedit RV 28)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1553' or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109014'))    
			and saldoandmik.rahavoo in ('28');

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('17','Korrigeerimine arvestuspohimotete muutuse ja vigade tottu',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 28); Konto 1555* Deebet (RV 28); konto 109015 deebet RV 28; konto 109016 deebet RV 28; konto 109017 deebet RV 28) - (Sum: Konto 1554* Kreedit (RV 28); Konto 1555* Kreedit (RV 28); konto 109015 kreedit RV 28; konto 109016 kreedit RV 28; konto 109017 kreedit RV 28)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555') or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109015','109016','109017'))    
			and saldoandmik.rahavoo in ('28');

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('17','Korrigeerimine arvestuspohimotete muutuse ja vigade tottu',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 28); konto 1557* deebet (RV 28); konto 109018 deebet RV 28; konto 109019 deebet RV 28) - (Sum: Konto 1556* Kreedit (RV 28); Konto 1557* Kreedit (RV 28); konto 109018 kreedti RV 28; konto 109019 kreedit RV 28)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557') or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109018','109019'))    
			and saldoandmik.rahavoo in ('28');

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('17','Korrigeerimine arvestuspohimotete muutuse ja vigade tottu',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 28)) - (Sum: Konto 1559* Kreedit (RV 28))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'    
			and saldoandmik.rahavoo in ('28');

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('17','Korrigeerimine arvestuspohimotete muutuse ja vigade tottu',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('17','Korrigeerimine arvestuspohimotete muutuse ja vigade tottu',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);
--Muud varade liikumised
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet (RV 29); konto 109010 deebet RV 29) - (Sum: Konto 155000 Kreedit (RV 29); konto 109010 kreedit RV 29)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('155000','109010')    
			and saldoandmik.rahavoo in ('29');

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('18','Muud varade liikumised',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet (RV 29); konto 109011 deebet RV 29; konto 109012 deebet RV 29; konto 109013 deebet RV 29) - (Sum: Konto 1551* Kreedit (RV 29); konto 109011 kreedit RV 29; konto 109012 kreedit RV 29; konto 109013 kreedit RV 29)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1551' or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109011','109012','109013'))     
			and saldoandmik.rahavoo in ('29');

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('18','Muud varade liikumised',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	
--Saldoandmikust (Sum: Konto 1553* Deebet (RV 29); konto 109014 deebet RV 29) - (Sum: Konto 1553* Kreedit (RV 29); konto 109014 kreedit RV 29)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '1553' or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109014'))     
			and saldoandmik.rahavoo in ('29');

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('18','Muud varade liikumised',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet (RV 29); Konto 1555* Deebet (RV 29); konto 109015 deebet RV 29; konto 109016 deebet RV 29; konto 109017 deebet RV 29) - (Sum: Konto 1554* Kreedit (RV 29); Konto 1555* Kreedit (RV 29); konto 109015 kreedit RV 29; konto 109016 kreedit RV 29; konto 109017 kreedit RV 29)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555') or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109015','109016','109017'))     
			and saldoandmik.rahavoo in ('29');

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('18','Muud varade liikumised',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet (RV 29); Konto 1557* Deebet (RV 29); konto 109018 deebet RV 29; konto 109019 deebet RV 29) - (Sum: Konto 1556* Kreedit (RV 29); Konto 1557* Kreedit (RV 29); konto 109018 kreedti RV 29; konto 109019 kreedit RV 29)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557') or left(ltrim(rtrim(saldoandmik.konto)),6) in ('109018','109019'))     
			and saldoandmik.rahavoo in ('29');

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('18','Muud varade liikumised',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet (RV 29)) - (Sum: Konto 1559* Kreedit (RV 29))
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'     
			and saldoandmik.rahavoo in ('29');

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('18','Muud varade liikumised',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('18','Muud varade liikumised',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);
--Kokku liikumised

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,summa02,summa03,summa04,summa05,summa06,summa07, kpv, rekvid, timestamp, tyyp)
	 select '19','Kokku liikumised',sum(summa01),sum(summa02),sum(summa03),sum(summa04),sum(summa05),sum(summa06),sum(summa07),tdKpv, tnRekvId,lcReturn, 0
			from tmp_sk_aruanned
			where timestamp = lcReturn and tyyp = 0 and konto not in ('01','010','011','012');

--Jaak perioodi lopus
lnDb2 = 0;
lnKr2 = 0;
	insert into  tmp_sk_aruanned (konto, nimetus,  kpv, rekvid, timestamp, tyyp)
	 values ('19','Jaak perioodi lopus',tdKpv, tnRekvId,lcReturn, 0);
--Soetusmaksumus
--Saldoandmikust (Sum: Konto 155000 Deebet) - (Sum: Konto 155000 Kreedit)

	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '155000'; 

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('20','Soetusmaksumus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 15510* Deebet) - (Sum: Konto 15510* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '15510'; 

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('20','Soetusmaksumus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 15530* Deebet) - (Sum: Konto 15530* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '15530'; 

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('20','Soetusmaksumus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 15540* Deebet + Konto 15550* Deebet) - (Sum: Konto 15540* Kreedit + Konto 15550* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) in ('15540','15550'); 

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('20','Soetusmaksumus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 15560* Deebet + Konto 15570* Deebet) - (Sum: Konto 15560* Kreedit + Konto 15570* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) in ('15560','15570'); 

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('20','Soetusmaksumus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet) - (Sum: Konto 1559* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'; 

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('20','Soetusmaksumus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('20','Soetusmaksumus',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);

--Kogunenud kulum
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 15511* Deebet) - (Sum: Konto 15511* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '15511'; 

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('21','Kogunenud kulum',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 15531* Deebet) - (Sum: Konto 15531* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '15531'; 

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('21','Kogunenud kulum',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 15541* Deebet + Konto 15551* Deebet) - (Sum: Konto 15541* Kreedit + Konto 15551* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) in ('15541','15551'); 

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('21','Kogunenud kulum',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 15561* Deebet + Konto 15571* Deebet) - (Sum: Konto 15561* Kreedit + Konto 15571* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) in ('15561','15571'); 

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('21','Kogunenud kulum',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('21','Kogunenud kulum',ifnull(lnDb2,0) - ifnull(lnKr2,0),tdKpv, tnRekvId,lcReturn, 0);
--Jaakvaartus
lnDb2 = 0;
lnKr2 = 0;
--Saldoandmikust (Sum: Konto 155000 Deebet) - (Sum: Konto 155000 Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) =  '155000'; 

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('22','Jaakvaartus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1551* Deebet) - (Sum: Konto 1551* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) =  '1551'; 

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('22','Jaakvaartus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1553* Deebet) - (Sum: Konto 1553* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) =  '1553'; 

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('22','Jaakvaartus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1554* Deebet + Konto 1555* Deebet) - (Sum: Konto 1554* Kreedit + Konto 1555* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1554','1555'); 

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('22','Jaakvaartus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1556* Deebet + Konto 1557* Deebet) - (Sum: Konto 1556* Kreedit + Konto 1557* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1556','1557'); 

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('22','Jaakvaartus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 1559* Deebet) - (Sum: Konto 1559* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1559'; 

	insert into  tmp_sk_aruanned (konto, nimetus, summa06,  kpv, rekvid, timestamp, tyyp)
	 values ('22','Jaakvaartus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
	lnDb2 = lnDb2 + ifnull(lnDeebet,0);
	lnKr2 = lnKr2 + ifnull(lnKreedit,0);
--Saldoandmikust (Sum: Konto 155* Deebet) - (Sum: Konto 155* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = '155'; 

	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('22','Jaakvaartus',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
--Muugiootel pohivara
lnDb2 = 0;
lnKr2 = 0;	
--Saldoandmikust (Sum: Konto 109010 Deebet) - (Sum: Konto 109010 Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '109010'; 

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp)
	 values ('23','Muugiootel pohivara',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
--Saldoandmikust (Sum: Konto 109011, 109012, 109013 Deebet) - (Sum: Konto 109011, 109012, 109013 Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('109011','109012','109013'); 

	insert into  tmp_sk_aruanned (konto, nimetus, summa02,  kpv, rekvid, timestamp, tyyp)
	 values ('23','Muugiootel pohivara',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
--Saldoandmikust (Sum: Konto 109014 Deebet) - (Sum: Konto 109014 Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '109014'; 

	insert into  tmp_sk_aruanned (konto, nimetus, summa03,  kpv, rekvid, timestamp, tyyp)
	 values ('23','Muugiootel pohivara',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
--Saldoandmikust (Sum: Konto 109015,109016,109017 Deebet) - (Sum: Konto 109015,109016,109017 Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('109015','109016','109017'); 

	insert into  tmp_sk_aruanned (konto, nimetus, summa04,  kpv, rekvid, timestamp, tyyp)
	 values ('23','Muugiootel pohivara',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
--Saldoandmikust (Sum: Konto 109018,109019 Deebet) - (Sum: Konto 109018,109019 Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('109018','109019'); 

	insert into  tmp_sk_aruanned (konto, nimetus, summa05,  kpv, rekvid, timestamp, tyyp)
	 values ('23','Muugiootel pohivara',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);
--Saldoandmikust (Sum: Konto 10901* Deebet) - (Sum: Konto 10901* Kreedit)
	select sum(db),sum(kr) into lnDeebet, lnKreedit 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '10901'; 

	insert into  tmp_sk_aruanned (konto, nimetus, summa07,  kpv, rekvid, timestamp, tyyp)
	 values ('23','Muugiootel pohivara',ifnull(lnDeebet,0) - ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0);

-- kond

	insert into  tmp_sk_aruanned (konto, nimetus,summa01,summa02,summa03,summa04,summa05,summa06, summa07,  kpv, rekvid, timestamp, tyyp)
	 select  konto, nimetus,sum(summa01),sum(summa02),sum(summa03),sum(summa04),sum(summa05),sum(summa06),sum(summa07),tdKpv, tnRekvId,lcReturn, 1
		from tmp_sk_aruanned
		where timestamp = lcReturn and rekvid = tnRekvId and tyyp = 0
		group by konto, nimetus
		order by konto, nimetus;

	delete from tmp_sk_aruanned where timestamp = lcReturn and tyyp = 0;
--	delete from tmp_sk_aruanned where timestamp = lcReturn and summa07 = 0;

	raise notice 'Materiaalse pohivara liikumise aruanne lopp';
end if;

if tnLiik = 6 then
--Saldode vordlus teiste riigi konsolideerimisgrupi uksustega
	raise notice 'Saldode vordlus teiste riigi konsolideerimisgrupi uksustega';
	if tnrekvId = 63 and tnSvod = 1 then
		lnRekvId = 999;
	end if;
-- kontagentide nimekirja, siis on koik riigi asutused

	for v_tp in
		select distinct tp from saldoandmik 
		where aasta = year(tdKpv) and kuu = month(tdKpv) 
		and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
		and (ltrim(rtrim(tp)) not in ('800599','800699','800399','800499') and left(ltrim(rtrim(tp)),3) <> '800' and left(ltrim(rtrim(tp)),4) <> '1851')
	loop
		raise notice 'tp %',v_tp.tp;
-- nouded
		insert into  tmp_sk_aruanned (tp,  konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select v_tp.tp, konto, 'Nouded',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),3)) = 103
			and saldoandmik.tp = v_tp.tp
			group by konto;

-- kohustused
		insert into  tmp_sk_aruanned (tp,  konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select v_tp.tp, konto, 'Kohustused',ifnull(sum(kr),0) - ifnull(sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),2)) = 20
			and saldoandmik.tp = v_tp.tp
			group by konto;

--tulud
		insert into  tmp_sk_aruanned (tp, konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select v_tp.tp, konto, 'Tulud',ifnull(sum(kr),0) - ifnull(sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),3)) = 3
			and saldoandmik.tp = v_tp.tp
			group by konto;

--kulud
		insert into  tmp_sk_aruanned (tp,  konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select v_tp.tp, konto, 'Kulud',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),1)) >= 4 and val(left(ltrim(rtrim(saldoandmik.konto)),2)) <= 64 
			and saldoandmik.tp = v_tp.tp
			group by konto;

	end loop;

	raise notice 'Saldode vordlus teiste riigi konsolideerimisgrupi uksustega lopp';
end if;

if tnLiik = 5 then
-- Kond rahavoog

	raise notice 'Rahavoog';
	raise notice 'Arvestan..';

	lnDb3 = 12;
	lnDb2 = year(tdKpv) - 1;

	raise notice 'Eelmine aasta..%',lnDb2;
	if tnrekvId = 63 and tnSvod = 1 then
		lnRekvId = 999;
	else	
		lnRekvId = tnRekvId;
	end if;

	insert into  tmp_sk_aruanned (jrnr,grupp,grupp2, konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select 10,'Rahavood põhitegevusest', '', '1','Aruandeperioodi tegevustulem',ifnull(sum(kr),0) - ifnull(sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),1)) >= 3 and val(left(ltrim(rtrim(saldoandmik.konto)),2)) <= 64;

--Jooksva per Saldoandmikust (Sum: Kontod 61* deebet) - (Sum: Kontod 61* Kreedit)

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select 20,'Rahavood põhitegevusest', 'Korrigeerimised','2','  Põhivara amortisatsioon ja ümberhindlus',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),2)) = 61;
--Käibemaksukulu põhivara soetamiseks 
--Jooksva per Saldoandmikust (Sum: Kontod 601002 deebet) - (Sum: Kontod 601002 Kreedit)

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select 30,'Rahavood põhitegevusest','Korrigeerimised', '2','  Käibemaksukulu põhivara soetamiseks ',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '601002';
--Saadud sihtfinantseerimine põhivara soetuseks		
--Jooksva per Saldoandmikust (Sum: konto 3502* deebet) - (Sum: konto 3502* kreedit)
	
	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select 40,'Rahavood põhitegevusest','Korrigeerimised','2','  Saadud sihtfinantseerimine põhivara soetuseks',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = ('3502');

	insert into  tmp_sk_aruanned (jrnr,grupp,grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select 50,'Rahavood põhitegevusest','Korrigeerimised', '2','  Saadud sihtfinantseerimise amortisatsioon ',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),3)) = 351;

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select 60,'Rahavood põhitegevusest', 'Korrigeerimised','2','  Saadud liitumistasude amortisatsioon ',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),6)) = 323880;

	insert into  tmp_sk_aruanned (jrnr,grupp,grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select 70,'Rahavood põhitegevusest','Korrigeerimised','2','  Kasum/kahjum pohivara muugist ',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),4)) in (3810,3811,3813,3814);
--Üle antud mitterahaline sihtfinantseerimine
--Üle antud mitterahaline sihtfinantseerimine / Antud sihtfinantseerimine põhivara soetuseks
--Jooksva per Saldoandmikust (4502* deebet miinus kreedit) 
			
	insert into  tmp_sk_aruanned (jrnr,grupp,grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select 80,'Rahavood põhitegevusest', 'Korrigeerimised','2','  Antud sihtfinantseerimine põhivara soetuseks ',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '4502';

	insert into  tmp_sk_aruanned (jrnr,grupp,grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select 90,'Rahavood põhitegevusest','Korrigeerimised', '2','  Ebatoenaoliselt laekuvate laenude muutus',ifnull(sum(db),0) - ifnull(sum(kr),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(ltrim(rtrim(saldoandmik.konto)),6)) in (605000,605010,605020);

--= aruandeper tegevustulem + korrigeerimised

	select sum(summa01) into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn and ltrim(rtrim(konto)) = '1';
	lnDeebet = ifnull(lnDeebet,0);

	select sum(summa01) into lnKreedit from tmp_sk_aruanned where timestamp = lcReturn and ltrim(rtrim(konto)) = '2';
	lnKreedit = ifnull(lnKreedit,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
		(100,'Rahavood põhitegevusest','Korrigeerimised','3','Korrigeeritud tegevustulem',lnDeebet + lnKreedit,tdKpv, tnRekvId,lcReturn, 0) ;

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(205,'Rahavood põhitegevusest','Põhitegevusega seotud käibevarade netomuutus','40','Põhitegevusega seotud käibevarade netomuutus',0,tdKpv, tnRekvId,lcReturn, 0 );


--(Eelmise aruandeper saldoandmikust (sum: kontod 102* deebet + kontod 152* deebet) - (sum kontod 102* kreedit+ kontod 152* kreedit)) - (Jooksva per saldoandmikust (sum kontod 102* deebet+ kontod 152* deebet) - (sum kontod 102* kreedit + kontod 152* kreedit))

			select ifnull(sum(db),0) - ifnull(sum(kr),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) in ('102','152');		
			
			select ifnull(sum(db),0) - ifnull(sum(kr),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) in ('102','152');

			lnKreedit = ifnull(lnKreedit,0);
			raise notice 'lnKreedit %',lnKreedit;
			lnDeebet = ifnull(lnDeebet,0);
			raise notice 'lnDeebet %',lnDeebet;

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(120,'Rahavood põhitegevusest','Põhitegevusega seotud käibevarade netomuutus','4','  Maksu-, lõivu- ja trahvinõuete muutus',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 10300* deebet + kontod 15300* deebet) - (sum kontod 10300* kreedit + kontod 15300* kreedit)) - (Jooksva per saldoandmikust (sum kontod 10300* deebet + kontod 15300* deebet) - (sum kontod 10300* kreedit + kontod 15300* kreedit))
			select ifnull(sum(db) - sum(kr),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),5)) in ('10300','15300');		
			
			select ifnull(sum(db) - sum(kr),0) into lnKreedit
			from saldoandmik
			where  aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),5)) in ('10300','15300');		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(130, 'Rahavood põhitegevusest','Põhitegevusega seotud käibevarade netomuutus','4','  Muutus nõuetes ostjate vastu',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 103190 deebet) - (sum kontod 103190 kreedit)) - (Jooksva per saldoandmikust (sum kontod 103190 deebet) - (sum kontod 103190 kreedit))

			select ifnull(sum(db) - sum(kr),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) = '103190';		
			
			select ifnull(sum(db) - sum(kr),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) = '103190';		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);


	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(140,'Rahavood põhitegevusest','Põhitegevusega seotud käibevarade netomuutus','4','  Muutus viitlaekumistes',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 1035* deebet - konto 103500 deebet - konto 103540 deebet - konto 103556 deebet - konto 103557 deebet) - 
--(sum kontod 1035* kreedit - konto 103500 kreedit - konto 103540 kreedit - konto 103556 kreedit - konto 103557 kreedit)) - 
--(Jooksva per saldoandmikust (sum: kontod 1035* deebet - konto 103500 deebet - konto 103540 deebet - konto 103556 deebet - konto 103557 deebet) - (sum kontod 1035* kreedit - konto 103500 kreedit - konto 103540 kreedit - konto 103556 kreedit - konto 103557 kreedit))

			select sum(db), sum(kr) into lnDb31, lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) = '1035';		

			
			
			select  sum(db),sum(kr) into lnDeebet, lnKreedit  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('103500','103540','103556','103557');		
			
			lnDeebet = (ifnull(lnDb31,0) - ifnull(lnDeebet,0)) - (ifnull(lnKr31,0) - ifnull(lnKreedit,0));

			select sum(db), sum(kr)into lnDb7,lnKr7  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) = '1035';		

			select sum(db) ,sum(kr) into lnDb31, lnKr31  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('103500','103540','103556','103557');		

			lnKreedit = (ifnull(lnDb7,0)-ifnull(lnDb31,0))-(ifnull(lnKr31,0)-ifnull(lnKr7,0));

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr, grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(150, 'Rahavood põhitegevusest','Põhitegevusega seotud käibevarade netomuutus','4','  Muutus nõuetes toetuste ja siirete eest',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 1036* deebet + sum kontod 1536* deebet) - (sum kontod 1036* kreedit + sum kontod 1536* kreedit)) - (Jooksva per saldoandmikust (sum kontod 1036* deebet + sum ontod 1536* deebet) - (sum kontod 1036* kreedit + sum kontod 1536* kreedit))

			select ifnull(sum(db) - sum(kr),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('1036','1536');		
			
			select ifnull(sum(db) - sum(kr),0) into lnKreedit
			from saldoandmik
			where  aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('1036','1536');		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr, grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(160,'Rahavood põhitegevusest','Põhitegevusega seotud käibevarade netomuutus','4','  Muutus muudes nõuetes',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

--(Eelmise aruandeper saldoandmikust (sum: kontod 1037* deebet) - (sum kontod 1037* kreedit)) - (Jooksva per saldoandmikust (sum kontod 1037* deebet) - (sum kontod 1037* kreedit))

			select ifnull(sum(db) - sum(kr),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) = '1037';		
			
			select ifnull(sum(db) - sum(kr),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) = '1037';		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(170,'Rahavood põhitegevusest','Põhitegevusega seotud käibevarade netomuutus','4','  Muutus maksude, lõivude, trahvide ettemaksetes',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 1038* deebet + kontod 1537* deebet) - (sum kontod 1038* kreedit + kontod 1537* kreedit)) - (Jooksva per saldoandmikust (sum kontod 1038* deebet + kontod 1537* deebet) - (sum kontod 1038* kreedit + kontod 1537* kreedit))

--Muutus toetuste ettemaksetes
--(Eelmise aruandeper saldoandmikust (sum: kontod 1038* deebet miinus kreedit - 103856, 103857 deebet miinus kreedit) - 
--(Jooksva per saldoandmikust (sum kontod 1038* deebet miinus kreedit miinus kreedit - 103856, 103857 deebet miinus kreedit)

			select ifnull(sum(db) - sum(kr),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('1038');

			select ifnull(sum(db) - sum(kr),0) into lnKr2
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('103856', '103857');

			lnKreedit = ifnull(lnKreedit,0) - ifnull(lnKr2,0);

			select ifnull(sum(db) - sum(kr),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('1038');		
		
			select ifnull(sum(db) - sum(kr),0) into lnKr2
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('103856','103857');		

			lnDeebet = ifnull(lnDeebet,0)  - ifnull(lnKr2,0);
			
	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(180,'Rahavood põhitegevusest','Põhitegevusega seotud käibevarade netomuutus','4','  Muutus toetuste ettemaksetes',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 1039* deebet + konto 153990 deebet) - (sum kontod 1039* kreedit + konto 153990 kreedit)) - 
--(Jooksva per saldoandmikust (sum kontod 1039* deebet + konto 153990 deebet) - (sum kontod 1039* kreedit + konto 153990 kredit))


			select sum(db) - sum(kr) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and 
			(
			(left(ltrim(rtrim(saldoandmik.konto)),4)) = '1039' or
			(left(ltrim(rtrim(saldoandmik.konto)),6)) = '153990'
			);		
			
			select sum(db) - sum(kr)into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (			
			(left(ltrim(rtrim(saldoandmik.konto)),4)) = '1039' or
			(left(ltrim(rtrim(saldoandmik.konto)),6)) = '153990'
			);		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(190,'Rahavood põhitegevusest','Põhitegevusega seotud käibevarade netomuutus','4','  Muutus muudes ettemaksetes',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 108* deebet) - (sum kontod 108* kreedit)) - (Jooksva per saldoandmikust (sum kontod 108* deebet) - (sum kontod 108* kreedit))

			select ifnull(sum(db) - sum(kr),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) = '108';		
			
			select ifnull(sum(db) - sum(kr),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) = '108';		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);
	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(200,'Rahavood põhitegevusest','Põhitegevusega seotud käibevarade netomuutus','4','  Muutus varudes',lnKreedit - lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(konto)) = '4' and ltrim(rtrim(timestamp)) = lcReturn;

	update tmp_sk_aruanned set summa01 = ifnull(lnDeebet,0) where ltrim(rtrim(konto)) = '40' and ltrim(rtrim(timestamp)) = lcReturn;


	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(315,'Rahavood põhitegevusest','Põhitegevusega seotud kohustuste netomuutus','50','Põhitegevusega seotud kohustuste netomuutus kokku',0,tdKpv, tnRekvId,lcReturn, 0 );
--(Jooksva per saldoandmikust (sum: kontod 200* kreedit) - (sum kontod 200* deebet)) - (Eelmise per saldoandmikust (sum kontod 200* kreedit) - (sum kontod 200* deebet))

			select ifnull(sum(kr) - sum(db),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) = '200';		
			
			select ifnull(sum(kr) - sum(db),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) = '200';		
			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(220,'Rahavood põhitegevusest','Põhitegevusega seotud kohustuste netomuutus','5','  Muutus saadud maksude, lõivude, trahvide ettemaksetes',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 201000 kreedit + konto 25000* kreedit) - (sum konto 201000 deebet + konto 25000* deebet)) - 
--(Eelmise per saldoandmikust (sum kontod 201000 kreedit + konto 25000* kreedit) - (sum kontod 201000 deebet + konto 25000* deebet))
			select sum(kr) - sum(db)  into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			left(ltrim(rtrim(saldoandmik.konto)),5) = '25000' or left(ltrim(rtrim(saldoandmik.konto)),6) = '201000'
			);		

			raise notice 'Jooksev 201000+2500 %', lnDeebet ;
			select sum(kr) - sum(db) into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ( 
			(left(ltrim(rtrim(saldoandmik.konto)),5)) = '25000' or (left(ltrim(rtrim(saldoandmik.konto)),6)) = '201000'
			);		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

			raise notice 'Eelmine 201000+2500 %', lnKreedit ;

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(230,'Rahavood põhitegevusest','Põhitegevusega seotud kohustuste netomuutus','5','  Muutus võlgades hankjatele',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 202* kreedit) - (sum konto 202* deebet)) - (Eelmise per saldoandmikust (sum kontod 202* kreedit) - (sum kontod 202* deebet))

			select ifnull(sum(kr) - sum(db),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) = '202';	
			
			raise notice 'Muutus volgades toovotjatele lnDeebet %',lnDeebet;	
			
			select ifnull(sum(kr) - sum(db),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) = '202';		
			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

			raise notice 'Muutus volgades toovotjatele lnKr %',lnKreedit;	
			raise notice 'Muutus volgades toovotjatele aasta %',lnDb2;	
			raise notice 'Muutus volgades toovotjatele kuu %',lnDb3;	
			raise notice 'Muutus volgades toovotjatele lnRekvId %',lnRekvId;	
			raise notice 'Muutus volgades toovotjatele lnTase %',lnTase;	

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(240,'Rahavood põhitegevusest','Põhitegevusega seotud kohustuste netomuutus','5','  Muutus võlgades töövõtjatele',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

--(Jooksva per saldoandmikust (sum: konto 2030* kreedit + konto 2530* kreedit) - (sum konto 2030* deebet + konto 2530* deebet)) - (Eelmise per saldoandmikust (sum kontod 2030* kreedit + konto 2530* kreedit) - (sum kontod 2030* deebet + konto 2530* deebet))

			select ifnull(sum(kr) - sum(db),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) = '2030';		
			
			select ifnull(sum(kr) - sum(db),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) = '2030';		
			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(250,'Rahavood põhitegevusest','Põhitegevusega seotud kohustuste netomuutus','5','  Muutus maksu-, lõivu- ja trahvikohustustes',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 203290 kreedit) - (sum konto 203290 deebet)) - (Eelmise per saldoandmikust (sum kontod 203290 kreedit) - (sum kontod 203290 deebet))

			select ifnull(sum(kr) - sum(db),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) = '203290';		
			
			select ifnull(sum(kr) - sum(db),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) = '203290';		
			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(260,'Rahavood põhitegevusest','Põhitegevusega seotud kohustuste netomuutus','5','  Muutus viitvõlgades',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 2035* kreedit - konto 203500 kreedit - konto 203540 kreedit + 2535* kreedit) - (sum konto 2035* deebet - konto 203500 deebet - konto 203540 deebet + 2535* deebet)) - 
--(Eelmise per saldoandmikust (sum kontod 2035* kreedit - konto 203500 kreedit - konto 203540 kreedit + 2535* kreedit) - (sum kontod 2035* deebet - konto 203500 deebet - konto 203540 deebet + 2535* deebet))

--(Jooksva per saldoandmikust (sum: konto 2035* kreedit - konto 203500 kreedit - konto 203540 kreedit + 2535* kreedit) - 
--(sum konto 2035* deebet - konto 203500 deebet - konto 203540 deebet + 2535* deebet)) - 
--(Eelmise per saldoandmikust (sum kontod 2035* kreedit - konto 203500 kreedit - konto 203540 kreedit + 2535* kreedit) - (sum kontod 2035* deebet - konto 203500 deebet - konto 203540 deebet + 2535* deebet))			
--raise notice 'vigane rea';

--Muutus toetuste ja siirete kohustustes
--(Jooksva per saldoandmikust (sum: konto 2035* kreedit miinus deebet- konto 203500, 203540, 203556, 203557 kreedit miinus deebet) - 
--(Eelmise per saldoandmikust (sum kontod 2035* kreedit miinus deebet - konto 203500, 203540, 203556, 203557 kreedit miinus de


			select sum(db), sum(kr) into lnDb31, lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('2035');		

			raise notice '2035 %',lnKr31  ;

			select sum(db), sum(kr) into lnDeebet, lnKreedit  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('203500',' 203540', '203556', '203557');		


			lnDb31 = ifnull(lnKr31,0) - ifnull(lnDb31,0)-ifnull(lnKreedit,0) - ifnull(lnDeebet,0);

			raise notice '203500, 203540, 203556, 203557 %',lnDb31;
			
			select sum(db), sum(kr) into lnKr2, lnKr3  
			from saldoandmik
			where aasta =  lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('2035');		

			select sum(db), sum(kr) into lnDeebet, lnKreedit  
			from saldoandmik
			where aasta =  lnDb2 and kuu = lnDb3 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('203500',' 203540', '203556', '203557');		

			lnDeebet = ifnull(lnKr3,0) - ifnull(lnKr2,0) - ifnull(lnKreedit,0) - ifnull(lnDeebet,0);

--Muutus toetuste ja siirete kohustustes
--(Jooksva per saldoandmikust (sum: konto 2035* kreedit miinus deebet- konto 203500, 203540, 203556, 203557 kreedit miinus deebet) - 
--(Eelmise per saldoandmikust (sum kontod 2035* kreedit miinus deebet - konto 203500, 203540, 203556, 203557 kreedit miinus de

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(270,'Rahavood põhitegevusest','Põhitegevusega seotud kohustuste netomuutus','5','  Muutus toetuste ja siirete kohustustes',lnDb31-lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 2036* kreedit + konto 2536* kreedit) - (sum konto 2036* deebet + 2536* deebet)) - (Eelmise per saldoandmikust (sum kontod 2036* kreedit + 2536* kreedit) - (sum kontod 2036* deebet + 2536* deebet))
			select ifnull(sum(kr) - sum(db),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('2036','2536');		
			
			select ifnull(sum(kr) - sum(db),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4)) in ('2036','2536');		

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);
	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(280,'Rahavood põhitegevusest','Põhitegevusega seotud kohustuste netomuutus','5','  Muutus muudes kohustustes',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 2038* kreedit - konto 203856 kreedit- konto 203857 kreedit) - 
--(sum konto 2038* deebet - konto 203856 deebet - konto 203857 deebet)) - 
--(Eelmise per saldoandmikust (sum: konto 2038* kreedit - konto 203856 kreedit- konto 203857 kreedit) - 
--(sum konto 2038* deebet - konto 203856 deebet - konto 203857 deebet))

			select sum(db),sum(kr)  into lnDb31 ,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '2038';		

			select sum(db), sum(kr) into lnDb7,lnKr7  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('203856','203857');		

			lnDeebet = ifnull(lnKr31,0) - ifnull(lnKr7,0) - ifnull(lnDb31,0) - ifnull(lnDb7,0);
			

			select sum(db), sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '2038';		

			select sum(db),sum(kr) into lnDb7,lnKr7  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('203856','203857');		

			lnKreedit = ifnull(lnKr31,0) - ifnull(lnKr7,0) - ifnull(lnDb31,0) - ifnull(lnDb7,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(290,'Rahavood põhitegevusest','Põhitegevusega seotud kohustuste netomuutus','5','  Muutus saadud toetuste ettemaksetes',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 203900 kreedit + konto 203990 kreedit + konto 253890 kreedit) - (sum konto 203900 deebet + konto 203990 deebet + konto 253890 deebet)) - (Eelmise per saldoandmikust (sum kontod 203900 kreedit + konto 203990 kreedit + konto 253890 kreedit) - (sum kontod 203900 deebet + konto 203990 deebet + konto 253890 deebet))

			select ifnull(sum(kr) - sum(db),0) into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('203900','203990','253890');		
			
			select ifnull(sum(kr) - sum(db),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) in ('203900','203990','253890');		
			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(300,'Rahavood põhitegevusest','Põhitegevusega seotud kohustuste netomuutus','5','  Muutus muudes saadud ettemaksetes',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (sum: ((konto 206* kreedit RV 41, 49, 05, 06) - (konto 206030 kreedit RV 41, 49, 05, 06))+ (konto 256* kreedit RV 41, 49, 05, 06) - 
--((sum konto 206* deebet RV 41, 49, 05, 06) - (konto 206030 deebet RV 41, 49, 05, 06)) - (konto 256* deebet RV 41, 49, 06, 05))

			select sum(db), sum(kr) into lnDb31, lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) in ('41','49','05','06')
			and (left(ltrim(rtrim(saldoandmik.konto)),3)) IN ('206','256');		
		
			lnDb31 = ifnull(lnDb31,0);
			lnKr31 = ifnull(lnKr31,0);	
			
			select sum(db),sum(kr) into lnDb7, lnKr7  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) in ('41','49','05','06')
			and (left(ltrim(rtrim(saldoandmik.konto)),6)) = ('206030');		

			lnDeebet = lnKr31 - ifnull(lnKr7,0)-lnDb31-ifnull(lnDb7,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(310,'Rahavood põhitegevusest','Põhitegevusega seotud kohustuste netomuutus','5','  Muutus eraldistes',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
		-- arvestame kokku
	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '5';
	update tmp_sk_aruanned set summa01 = ifnull(lnDeebet,0) where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '50';
		


--= korrigeeritud tegevustulem (3) + käibevarade muutus (4) + kohustuste muutus (5)

	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '3';
	lnKreedit = ifnull(lnDeebet,0);
	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '4';
	lnKreedit = lnKreedit + ifnull(lnDeebet,0);
	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '5';
	lnKreedit = lnKreedit + ifnull(lnDeebet,0);

	raise notice 'lnKreedit %',lnKreedit;
	insert into  tmp_sk_aruanned (jrnr,grupp,grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(320,'Rahavood põhitegevusest','','60','Rahavood põhitegevusest kokku',lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

	insert into  tmp_sk_aruanned (jrnr,grupp, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(330, 'Rahavood põhitegevusest kokku','7','Rahavood investeerimistegevusest',0,tdKpv, tnRekvId,lcReturn, 0); 

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(340,'Rahavood investeerimistegevusest','Tasutud põhivara eest (v.a. finantsinvesteeringud ja osalused)','710',' Tasutud põhivara eest (v.a. finantsinvesteeringud ja osalused)',0,tdKpv, tnRekvId,lcReturn, 0); 

--Jooksva per saldoandmikust (Sum: Konto 155* kreedit (RV 01)) - (Sum: Konto 155* deebet (RV 01)) + 
--(sum: konto 2082* kreedit (RV 01; RV 05)) - (sum: konto 2082* deebet (RV 01; RV 05)) + 
--(sum: konto 2582* kreedit (RV 01; RV 05)) - (sum: konto 2582* deebet (RV 01; RV 05)) + 
--(sum: konto 350200 kreedit (RV 01)) - (sum: konto 350200 deebet (RV 01)) + 
--(sum: konto 350220 kreedit (RV 01)) - (sum: konto 350220 deebet (RV 01)) + 
--(sum: konto 350240 kreedit (RV 01)) - (sum: konto 350240 deebet RV 01)) + 
--(sum 257* kreedit (RV 01)) - (sum 257* kreedit RV 01))

--25.05.2012
--Materiaalse ja immateriaalse põhivara soetus	
--Jooksva per saldoandmikust (Konto 155* kreedit (RV 01)) - (Sum: Konto 155* deebet (RV 01)) +(Sum: Konto 156* kreedit (RV 01)) - (Sum: Konto 156* deebet (RV 01)) +
--( 601002 Kreedit miinus deebet)+(650990 kreedit - deebet) + (sum: konto 2082* kreedit (RV 01; RV 05)) 
-- - (sum: konto 2082* deebet (RV 01; RV 05)) + (sum: konto 2582* kreedit (RV 01; RV 05)) - (sum: konto 2582* deebet (RV 01; RV 05)) + 
--(sum: konto 350200 kreedit (RV 01)) - (sum: konto 350200 deebet (RV 01)) + (sum: konto 350220 kreedit (RV 01)) - (sum: konto 350220 deebet (RV 01)) + (sum: konto 350240 kreedit (RV 01)) - (sum: konto 350240 deebet RV 01)) + 
-- (sum 257* kreedit (RV 01)) - (sum 257* kreedit RV 01)) +
-- (sum: konto 2086* kreedit (RV 01; RV 05)) - (sum: konto 2086* deebet (RV 01; RV 05)) + (sum: konto 2586* kreedit (RV 01; RV 05)) - (sum: konto 2586* deebet (RV 01; RV 05))  +
--(Jooksva per saldoandmikust (sum: konto 201010 kreedit + konto 25001* kreedit) - (sum konto 201010 deebet + konto 25001* deebet)) - 
--(Eelmise per saldoandmikust (sum kontod 201010 kreedit + konto 25001* kreedit) - (sum kontod 201010 deebet + konto 25001* deebet))
--Jooksva per saldoandmikust (Konto 155* kreedit (RV 01)) - (Sum: Konto 155* deebet (RV 01)) +(Sum: Konto 156* kreedit (RV 01)) - (Sum: Konto 156* deebet (RV 01)) +( 601002 Kreedit miinus deebet)+(650990 kreedit - deebet) + (sum: konto 2082* kreedit (RV 01;
			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ((ltrim(rtrim(rahavoo)) = '01' and left(ltrim(rtrim(saldoandmik.konto)),3) in ('155','156','257'))
			or (left(ltrim(rtrim(saldoandmik.konto)),6) in ('601002','650990'))
			or (ltrim(rtrim(rahavoo)) in ('01','05') and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2082','2582', '2086', '2586'))
			or (ltrim(rtrim(rahavoo)) = '01' and left(ltrim(rtrim(saldoandmik.konto)),6) in ('350200','350220','350240'))
			or (left(ltrim(rtrim(saldoandmik.konto)),6) = '201010')
			or (left(ltrim(rtrim(saldoandmik.konto)),5) = '25001')


			);
				
			lnDeebet = ifnull(lnDeebet,0);

			select ifnull(sum(kr) - sum(db),0) into lnKreedit
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ((left(ltrim(rtrim(saldoandmik.konto)),6)) = '201010'
			or left(ltrim(rtrim(saldoandmik.konto)),5) = '25001');		

			lnKreedit = ifnull(lnKreedit,0);




	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(335,'Rahavood investeerimistegevusest','Tasutud põhivara eest (v.a. finantsinvesteeringud ja osalused)','71','  Materiaalse ja immateriaalse põhivara soetus',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum: Konto 154* kreedit (RV 01)) - (Sum: Konto 154* deebet (RV 01))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) = '01' and left(ltrim(rtrim(saldoandmik.konto)),3) in ('154'); 

			select sum(kr) - sum(db) into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) = '01' and left(ltrim(rtrim(saldoandmik.konto)),3) in ('154'); 

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(360,'Rahavood investeerimistegevusest','Tasutud põhivara eest (v.a. finantsinvesteeringud ja osalused)','71','  Kinnisvarainvesteeringute soetus',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

--Jooksva per saldoandmikust (Sum: Konto 156* kreedit (RV 01)) - (Sum: Konto 156* deebet (RV 01))
/*
			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) = '01' and left(ltrim(rtrim(saldoandmik.konto)),3) in ('156'); 

			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('71','  Immateriaalse põhivara soetus',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

*/
--Jooksva per saldoandmikust (Sum: Konto 157* kreedit (RV 01)) - (Sum: Konto 157* deebet (RV 01))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) = '01' and left(ltrim(rtrim(saldoandmik.konto)),3) in ('157'); 

			select sum(kr) - sum(db) into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and ltrim(rtrim(rahavoo)) = '01' and left(ltrim(rtrim(saldoandmik.konto)),3) in ('157'); 

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(370,'Rahavood investeerimistegevusest','Tasutud põhivara eest (v.a. finantsinvesteeringud ja osalused)','71','  Bioloogiliste varade soetus',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

/*
--(Jooksva per saldoandmikust (sum: konto 201010 kreedit + konto 25001* kreedit) - 
--(sum konto 201010 deebet + konto 25001* deebet)) - (Eelmise per saldoandmikust (sum kontod 201010 kreedit + konto 25001* kreedit) - (sum kontod 201010 deebet + konto 25001* deebet))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6) = ('201010') or left(ltrim(rtrim(saldoandmik.konto)),5) = ('25001')); 

			select sum(kr) - sum(db) into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6) = ('201010') or left(ltrim(rtrim(saldoandmik.konto)),5) = ('25001')); 

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			('71','  Korrigeerimine muutusega võlgades hankijatele',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

*/
	select sum(summa01) into lnDeebet from tmp_sk_aruanned  where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '71';

	update tmp_sk_aruanned set summa01 = ifnull(lnDeebet,0) where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '710';


	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(425,'Rahavood investeerimistegevusest','Laekunud põhivara müügist (v.a. finantsinvesteeringud ja osalused)','720',' Laekunud põhivara müügist (v.a. finantsinvesteeringud ja osalused)',0,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per Saldoandmikust (Sum: Kontod 381000+381001+381100+381101+381110+381111+381115+381116+381120+381121+381125+381126+381130+381131+381140+381141+381145+381146+
--381150+381151+381160+381161+381170+381171+381180+381181+381300+381301+381320+381321+381360+381361+381400+381401+381410+381411+381420+381421 kreedit) 
-- - (Sum: 381000+381001+381100+381101+381110+381111+381115+381116+381120+381121+381125+381126+381130+381131+381140+381141+381145+381146+381150+381151+381160+
--381161+381170+381171+381180+381181+381300+381301+381320+381321+381360+381361+381400+381401+381410+381411+381420+381421 deebet)
			
			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('381000','381001','381100','381101','381110','381111','381115','381116','381120','381121','381125',
				'381126','381130','381131','381140','381141','381145','381146','381150','381151','381160','381161','381170','381171','381180','381181',
				'381300','381301','381320','381321','381360','381361','381400','381401','381410','381411','381420','381421'); 
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(390,'Rahavood investeerimistegevusest','Laekunud põhivara müügist (v.a. finantsinvesteeringud ja osalused)','72','  Müügist saadud tulu',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 10301* deebet + konto 15301* deebet) - (sum kontod 10301* kreedit + konto 15301* kreedit)) - 
--(Jooksva per saldoandmikust (sum: kontod 10301* deebet + konto 15301* deebet) - (sum kontod 10301* kreedit + konto 15301* kreedit))

			select sum(db) - sum(kr)  into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) in ('10301','15301');

			select sum(db) - sum(kr)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) in ('10301','15301');

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(400,'Rahavood investeerimistegevusest','Laekunud põhivara müügist (v.a. finantsinvesteeringud ja osalused)','72','  Korrigeerimine laekumata nõuete muutusega',lnKreedit-lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 203910 kreedit) - (sum konto 203910 deebet)) - (Eelmise per saldoandmikust (sum kontod 203910 kreedit) - (sum kontod 203910 deebet))

			select sum(kr) - sum(db)  into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('203910');

			select sum(kr)  - sum(db) into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('203910');

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(410,'Rahavood investeerimistegevusest','Laekunud põhivara müügist (v.a. finantsinvesteeringud ja osalused)','72','  Korrigeerimine laekunud ettemaksete muutusega',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise aruandeper saldoandmikust (sum: kontod 10325* deebet + konto 15325* deebet) - (sum kontod 10325* kreedit + konto 15325* kreedit)) - (Jooksva per saldoandmikust (sum: kontod 10325* deebet + konto 15325* deebet) - (sum kontod 10325* kreedit + konto 15325* kreedit))

			select sum(db) - sum(kr)   into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) in ('10325','15325');

			select sum(db) - sum(kr)  into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) in ('10325','15325');

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(420,'Rahavood investeerimistegevusest','Laekunud põhivara müügist (v.a. finantsinvesteeringud ja osalused)','72','  Korrigeerimine järelmaksunõuete muutusega',lnKreedit-lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per Saldoandmikust (Sum: Konto 605020 kreedit) - (Sum: Konto 605020 deebet)

			select sum(kr)  - sum(db)   into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('605020');

			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(430,'Rahavood investeerimistegevusest','Laekunud põhivara müügist (v.a. finantsinvesteeringud ja osalused)','72','  Korrigeerimine ebatõenäoliselt laekuvaks arvatud järelmaksunõuetega',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum: konto 206030 kreedit) - (sum konto 206030 deebet)) - (Eelmise per saldoandmikust (sum kontod 206030 kreedit) - (sum kontod 206030 deebet)) + (jooksva per saldoandmikust (konto 700030 kreedit + konto 710030 kreedit - konto 700030 deebet - konto 710030 deebet)

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('206030');

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('206030');

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(440,'Rahavood investeerimistegevusest','Laekunud põhivara müügist (v.a. finantsinvesteeringud ja osalused)','72','  Korrigeerimine kustutatud EVP-de jäägi muutusega',lnKreedit-lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

		select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '72';

		update tmp_sk_aruanned set summa01 = ifnull(lnDeebet,0) where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '720';


			
--Jooksva per saldoandmikust (Sum: Konto 1032* kreedit (RV 01) + sum konto 1532* kreedit (RV 01)) - (Sum: Konto 1032* deebet (RV 01)+ sum konto 1532* deebet (RV 01))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1032','1532') and ltrim(rtrim(rahavoo)) = '01';

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1032','1532') and ltrim(rtrim(rahavoo)) = '01';

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(450,'Rahavood investeerimistegevusest','Laekunud põhivara müügist (v.a. finantsinvesteeringud ja osalused)','7',' Antud laenud',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum: Konto 1032* kreedit (RV 02) + sum konto 1532* kreedit (RV 02)) - (Sum: Konto 1032* deebet (RV 02)+ sum konto 1532* deebet (RV 02))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1032','1532') and ltrim(rtrim(rahavoo)) = '02';

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('1032','1532') and ltrim(rtrim(rahavoo)) = '02';

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(460,'Rahavood investeerimistegevusest','Laekunud põhivara müügist (v.a. finantsinvesteeringud ja osalused)','7',' Tagasi makstud laenud',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

--(Eelmise per saldoandmikust (Sum konto 103540 deebet) - (sum konto 103540 kreedit) - (sum konto 203540 kreedit) + (sum konto 203540 deebet)) - (sum konto 257800 kreedit) +
-- (sum konto 257800 deebet)) - 
--(Jooksva per saldoandmikust (Sum: Konto 103540 deebet) - (sum konto 103540 kreedit) - 
--(konto 203540 kreedt) + (konto 203540 deebet) - 
--(konto 257800 kreedit) + (konto 257800 deebet))

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('103540');
			
			lnDeebet = ifnull(lnDb31,0) - ifnull(lnKr31,0);

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('203540');

			lnDeebet = lnDeebet  - ifnull(lnKr31,0) + ifnull(lnDb31,0) ;

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('257800');

			lnDeebet = lnDeebet  - ifnull(lnKr31,0) + ifnull(lnDb31,0) ;
			
			select sum(db),sum(kr)    into lnDb31,lnKr31 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('103540');
			
			lnKreedit = ifnull(lnDb31,0) - ifnull(lnKr31,0);

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('203540');

			lnKreedit = lnKreedit  - ifnull(lnKr31,0) + ifnull(lnDb31,0) ;

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('257800');

			lnKreedit = lnKreedit  - ifnull(lnKr31,0) + ifnull(lnDb31,0) ;

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(470,'Rahavood investeerimistegevusest','','7',' Korrigeerimine laenutegevuseks saadud sihtfinantseerimise muutusega',lnKreedit-lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum: Konto 101* kreedit (RV 01) + sum konto 151* kreedit (RV 01)) - (Sum: Konto 101* deebet (RV 01)+ sum konto 151* deebet (RV 01))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) in ('101','151') and ltrim(rtrim(rahavoo)) = '01';
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(480,'Rahavood investeerimistegevusest','','7',' Tasutud finantsinvesteeringute soetamisel',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum: Konto 101* kreedit (RV 02) + sum konto 151* kreedit (RV 02)) - (Sum: Konto 101* deebet (RV 02)+ sum konto 151* deebet (RV 02))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) in ('101','151') and ltrim(rtrim(rahavoo)) = '02';
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(490,'Rahavood investeerimistegevusest','','7',' Laekunud finantsinvesteeringute müügist',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum: Konto 150* kreedit (RV 01)) - (Sum: Konto 150* deebet (RV 01))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = '150' and ltrim(rtrim(rahavoo)) = '01';
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(500,'Rahavood investeerimistegevusest','','7',' Tasutud osaluste soetamisel',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum: Konto 150* kreedit (RV 02)) - (Sum: Konto 150* deebet (RV 02))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = '150' and ltrim(rtrim(rahavoo)) = '02';
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr, grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(510,'Rahavood investeerimistegevusest','','7',' Laekunud osaluste müügist',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (Sum: Konto 655500 kreedit+ konto 652010 kreedit) - (sum konto 655500  deebet + konto 652010 deebet) + 
--(sum 103110 kreedit RV 02 - Sum Konto 10311 0 deebet RV 02))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			left(ltrim(rtrim(saldoandmik.konto)),6) in ('655500','652010') 
			or (left(ltrim(rtrim(saldoandmik.konto)),6) = '103110' and ltrim(rtrim(rahavoo)) = '02')
			);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(520,'Rahavood investeerimistegevusest','','7',' Laekunud dividendid',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Eelmise per saldoandmikust (Sum konto 10310* deebet) - (sum konto 10310* kreedit)) + 
--(Jooksva per saldoandmikust (Sum: Konto 6580* kreedit) - (sum konto 6580* deebet) + 
--(konto 658910 kreedit) - (konto 658910 deebet) - 
--(sum 10310* deebet - Sum Konto 10310* kreedit )) + (Sum: Konto 655* kreedit - konto 655* deebet) - 
--((sum 101* deebet RV 21, 29, 22) - (sum 101* kreedit RV 21, 29, 22)) - 
--((Sum: Konto 151* deebet RV 21, 29, 22) - (konto 151* kreedit RV 21, 29, 22)) - 
--(konto 655500 kreedit miinus konto 655500 deebet) -
--((sum 1032* deebet RV 22 - sum 1032* kreedit RV 22 + sum 1532* deebet RV 22 - sum 1532* kreedit RV 22)) + 
--((konto 101900 deebet RV 21 - konto 101900 kreedit RV 21)) 


			select sum(db) - sum(kr)    into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '10310'; 

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '6580';
			
			lnDeebet = ifnull(lnKr31,0) - ifnull(lnDb31,0);

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '658910';
			
			lnDeebet = lnDeebet + ifnull(lnKr31,0) - ifnull(lnDb31,0);

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),5) = '10310';
			
			lnDeebet = lnDeebet - ifnull(lnDb31,0) - ifnull(lnKr31,0) ;

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = '655';
			lnDeebet = lnDeebet + ifnull(lnKr31,0) - ifnull(lnDb31,0)   ;
--((sum 101* deebet RV 21, 29, 22) - (sum 101* kreedit RV 21, 29, 22)) - 
			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = '101' and ltrim(rtrim(rahavoo)) in ('21','29','22');
			lnDeebet = lnDeebet - ifnull(lnDb31,0) - ifnull(lnKr31,0)    ;
 --((Sum: Konto 151* deebet RV 21, 29, 22) - (konto 151* kreedit RV 21, 29, 22)) - 

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = '151' and ltrim(rtrim(rahavoo)) in ('21','29','22');
			lnDeebet = lnDeebet - ifnull(lnDb31,0) - ifnull(lnKr31,0)    ;
---(konto 655500 kreedit miinus konto 655500 deebet) -

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '655500';
			lnDeebet = lnDeebet - ifnull(lnKr31,0) - ifnull(lnDb31,0);
--((sum 1032* deebet RV 22 - sum 1032* kreedit RV 22 + sum 1532* deebet RV 22 - sum 1532* kreedit RV 22)) + 

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = '1032' and ltrim(rtrim(rahavoo)) = '22';

			lnDeebet = lnDeebet - ifnull(lnDb31,0) - ifnull(lnKr31,0) ;
--((konto 101900 deebet RV 21 - konto 101900 kreedit RV 21)) 

			select sum(db),sum(kr) into lnDb31,lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '101900' and ltrim(rtrim(rahavoo)) = '21';

			lnDeebet = lnDeebet + ifnull(lnDb31,0) - ifnull(lnKr31,0) ;

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(528,'Rahavood investeerimistegevusest','','711',' Laekunud intressid ja muu finantstulu',lnKreedit +lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(540, 'Rahavood finantseerimistegevusest','','8','Rahavood finantseerimistegevusest',0,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2080* kreedit (RV 05) - konto 2080* deebet (RV 05) + sum konto 2580* kreedit (RV 05) - konto 2580* deebet (RV 05) 

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2080','2580') and ltrim(rtrim(rahavoo)) = '05';

			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(550,'Rahavood finantseerimistegevusest','','8',' Laekunud võlakirjade emiteerimisest',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2080* kreedit (RV 06) - konto 2080* deebet (RV 06) + sum konto 2580* kreedit (RV 06) - konto 2580* deebet (RV 06) 

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2080','2580') and ltrim(rtrim(rahavoo)) = '06';

			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(560,'Rahavood finantseerimistegevusest','','8',' Lunastatud võlakirjad',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2081* kreedit (RV 05) - konto 2081* deebet (RV 05) + sum konto 2581* kreedit (RV 05) - konto 2581* deebet (RV 05) 

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2081','2581') and ltrim(rtrim(rahavoo)) = '05';

			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp,grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(570,'Rahavood finantseerimistegevusest','','8',' Laekunud laenud',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2081* kreedit (RV 06) - konto 2081* deebet (RV 06) + sum konto 2581* kreedit (RV 06) - konto 2581* deebet (RV 06) 

			select sum(db), sum(kr) into lnDb31, lnKr31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2081','2581') and ltrim(rtrim(rahavoo)) = '06';

			lnDeebet = ifnull(lnKr31,0) - ifnull(lnDb31,0);

			raise notice 'Tagasi makstud laenud %',lnDeebet;

	insert into  tmp_sk_aruanned (jrnr, grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(580,'Rahavood finantseerimistegevusest','','8',' Tagasi makstud laenud',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (Sum konto 208100 kreedit - konto 208100 deebet)) - (eelmise per saldoandmikust (sum konto 208100 kreedit- konto 208100 deebet))

			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('208100');

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('208100');

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(590, 'Rahavood finantseerimistegevusest','','8',' Arvelduskrediidi muutus',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2082* kreedit (RV 06) - konto 2082* deebet (RV 06) + sum konto 2582* kreedit (RV 06) - konto 2582* deebet (RV 06) 
			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2082','2582') and ltrim(rtrim(rahavoo)) = '06';

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2082','2582') and ltrim(rtrim(rahavoo)) = '06';

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(600, 'Rahavood finantseerimistegevusest','','8',' Tagasi makstud kapitalirendikohustused',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2083* kreedit (RV 05) - konto 2083* deebet (RV 05) + sum konto 2583* kreedit (RV 05) - konto 2583* deebet (RV 05) 
			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2083','2583') and ltrim(rtrim(rahavoo)) = '05';

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2083','2583') and ltrim(rtrim(rahavoo)) = '05';

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(610,'Rahavood finantseerimistegevusest','','8',' Laekunud faktooringlepingute alusel',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum konto 2083* kreedit (RV 06) - konto 2083* deebet (RV 06) + sum konto 2583* kreedit (RV 06) - konto 2583* deebet (RV 06) 
			
			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2083','2583') and ltrim(rtrim(rahavoo)) = '06';

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) in ('2083','2583') and ltrim(rtrim(rahavoo)) = '06';

			lnKreedit = ifnull(lnKreedit,0);
			lnDeebet = ifnull(lnDeebet,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(620,'Rahavood finantseerimistegevusest','','8',' Tagasi makstud faktooringlepingute alusel',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

--Jooksva per saldoandmikust (Sum: Konto 257* kreedit (RV 05) + konto 350200 kreedit (RV 05) + konto 350220 kreedit (RV 05) + konto 350240 kreedit (RV 05)) - 
--(Sum: Konto 257* deebet (RV 05)+ konto 350200 deebet (RV 05) + konto 350220 deebet (RV 05) + konto 350240 deebet (RV 05)) + 
--(Jooksva per saldoandmikust (sum: konto 203856 kreedit + konto 203857 kreedit) - (sum konto 203856 deebet + konto 203857 deebet)) - 

--(Eelmise per saldoandmikust (sum kontod 203856 kreedit + konto 203857 kreedit) - (sum kontod 203856 deebet + konto 203857 deebet)) + 
--(Eelmise per saldoandmikust (sum konto 103556 deebet + konto 103557 deebet + 153556 deebet) - (sum konto 103556 kreedit + konto 103557 kreedit + konto 153556 kreedit)) - 
--(Jooksva per saldoandmikust (sum konto 103556 deebet + konto 103557 deebet + konto 153556 deebet) - (sum konto 103556 kreedit + konto 103557 kreedit + konto 153556 kreedit))  

--25.05.2012
 --Jooksva per saldoandmikust (Sum: Konto 257* kreedit-deebet (RV 05) + (konto 3502* kreedit miinus deebet) - 
 --(konto 3502 RV 19, RV 01 kreedit miinus deebet)+ (Jooksva per saldoandmikust (sum: konto 203856 kreedit + konto 203857 kreedit) - 
 --(sum konto 203856 deebet + konto 203857 deebet)) - (Eelmise per saldoandmikust (sum kontod 203856 kreedit + konto 203857 kreedit) - 
 --(sum kontod 203856 deebet + konto 203857 deebet)) + (Eelmise per saldoandmikust (sum konto 103556 deebet + konto 103557 deebet + 153556 deebet) - 
 --(sum konto 103556 kreedit + konto 103557 kreedit + konto 153556 kreedit)) - (Jooksva per saldoandmikust (sum konto 103556 deebet + konto 103557 deebet + 
 --konto 153556 deebet) - (sum konto 103556 kreedit + konto 103557 kreedit + konto 153556 kreedit))  



			select sum(kr) - sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			(left(ltrim(rtrim(saldoandmik.konto)),3) = ('257') and ltrim(rtrim(rahavoo)) = '05')
			or (left(ltrim(rtrim(saldoandmik.konto)),4) = '3502' and ltrim(rtrim(rahavoo)) not in ('19','01'))
			or (left(ltrim(rtrim(saldoandmik.konto)),6) in ('203856','203857'))
			);

			lnDeebet = ifnull(lnDeebet,0);

			select sum(kr) - sum(db)   into lnKreedit  
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('203856','203857');

			lnDeebet = lnDeebet - ifnull(lnKreedit,0);

			select sum(db) -sum(kr)   into lnKr31
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('103556','103557','153556');

			lnDeebet = lnDeebet + ifnull(lnKr31,0);


			select sum(db)-sum(kr) into lnDb31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('103556','103557','153556');

			lnDeebet = lnDeebet -  ifnull(lnDb31,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(525,'Rahavood investeerimistegevusest','','712',' Laekunud sihtfinanteerimine põhivara soetuseks',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--25.05.2012
--Tasutud sihtfinantseerimine põhivara soetuseks
--Jooksva per saldoandmikust (Konto 4502* kreedit-deebet) + 1KDRV24+ (Jooksva per saldoandmikust (konto 203556, 203557, 253550 kreedit miinus deebet) - 
--(sum konto 103856, 103857, 1537 deebet miinus kreedit) - (Eelmise per saldoandmikust (sum kontod 203556, 203557, 253550 kreedit miinus deebet) + 
--(Eelmise per saldoandmikust (konto 103856, 103857, 1537 deebet miinus kreedit)

			select sum(kr)-sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),4) = '4502' 
			or left(ltrim(rtrim(saldoandmik.konto)),6) in ('203556', '203557', '253550')
			or left(ltrim(rtrim(saldoandmik.konto)),1) = '1' and  ltrim(rtrim(rahavoo)) = '24');

			lnDeebet = ifnull(lnDeebet,0);

			select sum(db)-sum(kr) into lnDb31  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6) in ('103856', '103857')
			or left(ltrim(rtrim(saldoandmik.konto)),4) = '1537');

			lnDeebet = ifnull(lnDeebet,0)-ifnull(lnDb31,0);


			select sum(kr) - sum(db)  into lnKreedit 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('203556', '203557', '253550') ;

			select sum(db) - sum(kr)  into lnKr31
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (left(ltrim(rtrim(saldoandmik.konto)),6) in ('103856', '103857')
			or left(ltrim(rtrim(saldoandmik.konto)),4) = '1537');

			lnKreedit = ifnull(lnKreedit,0)-ifnull(lnKr31,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(527,'Rahavood investeerimistegevusest','','713',' Makstud sihtfinantseerimine põhivara soetuseks',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 
--Laekunud liitumistasud
--(Jooksva per saldoandmikust (sum: konto 253800 kreedit + konto 323880 kreedit) - (sum konto 253800 deebet + konto 323880 deebet)) - 
--(Eelmise per saldoandmikust (sum konto 253800 kreedit) - (sum kontod 253800 deebet))
			select sum(kr) -sum(db)into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('253800','323880') ;

			lnDeebet = ifnull(lnDeebet,0);

			select sum(kr) - sum(db)  into lnKreedit 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '253800' ;

			lnKreedit = ifnull(lnKreedit,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(650,'Rahavood finantseerimistegevusest','','8',' Laekunud liitumistasud',lnDeebet-lnKreedit,tdKpv, tnRekvId,lcReturn, 0); 

--Jooksva per saldoandmikust (Sum konto 650* kreedit - konto 650* deebet) + jooksva per saldoandmikust (konto 203200 kreedit - konto 203200 deebet) - 
--(eelmise per saldoandmikust (konto 203200 kreedit- konto 203200 deebet)) + (jooksva per saldoandmikust (konto 209000 kreedit - konto 209000 deebet) - 
--(eelmise per saldoandmikust (konto 209000 kreedit - konto 209000 deebet)) + eelmise per saldandmikust (konto 103300 deebet - konto 103300 kreedit)) - 
--jooksva per saldoandmikust (konto 103300 deebet - konto 103300 kreedit) + jooksva per saldoandmikust (konto 256* kreedit RV 42 - konto 256* deebet RV 42) + 
--jooksva per saldoandmikust (konto 208* kreedit (RV 42) - konto 208* deebet (RV 42)) + jooksva per saldoandmikust (konto 258* kreedit (RV 42) - konto 258* deebet (RV 42))

--Jooksva per saldoandmikust (Sum konto 650* kreedit - konto 650* deebet) + jooksva per saldoandmikust (konto 203200 kreedit - konto 203200 deebet) - 

			select sum(kr)-sum(db) into lnDeebet  
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			(left(ltrim(rtrim(saldoandmik.konto)),3) = '650')
			or (left(ltrim(rtrim(saldoandmik.konto)),6) = '203200')  
			);
--(eelmise per saldoandmikust (konto 203200 kreedit- konto 203200 deebet)) + (jooksva per saldoandmikust (konto 209000 kreedit - konto 209000 deebet) - 

			select sum(kr) - sum(db)  into lnKreedit 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '203200';  

			select sum(kr)-sum(db) into lnDb31 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '209000';

			lnDeebet = ifnull(lnDeebet,0) - ifnull(lnKreedit,0) + ifnull(lnDb31,0);
			
--(eelmise per saldoandmikust (konto 209000 kreedit - konto 209000 deebet)) + eelmise per saldandmikust (konto 103300 deebet - konto 103300 kreedit)) - 

			select sum(kr) - sum(db)  into lnKreedit 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '209000';

			lnDeebet = lnDeebet - ifnull(lnKreedit,0);		

			select sum(db)-sum(kr)  into lnKreedit 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '103300';
			
			lnDeebet = lnDeebet + ifnull(lnKreedit,0);		
--jooksva per saldoandmikust (konto 103300 deebet - konto 103300 kreedit) + jooksva per saldoandmikust (konto 256* kreedit RV 42 - konto 256* deebet RV 42) + 
			select sum(db) - sum(kr) into lnDb31 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = '103300';

			lnDeebet = lnDeebet - ifnull(lnDb31,0);		

			select sum(kr) - sum(db) into lnDb31 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = '256' and ltrim(rtrim(rahavoo)) = '42';

			lnDeebet = lnDeebet + ifnull(lnDb31,0);		
--jooksva per saldoandmikust (konto 208* kreedit (RV 42) - konto 208* deebet (RV 42)) + jooksva per saldoandmikust (konto 258* kreedit (RV 42) - konto 258* deebet (RV 42))
			select sum(kr) - sum(db) into lnDb31 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) in ('208','258') and ltrim(rtrim(rahavoo)) = '42';

			lnDeebet = lnDeebet + ifnull(lnDb31,0);		

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(660,'Rahavood finantseerimistegevusest','','8',' Makstud intressid',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

--(Jooksva per saldoandmikust (Sum konto 6589* kreedit - konto 6589* deebet - 658910 kreedit + 658910 deebet)) + 
--jooksva per saldoandmikust (konto 208* kreedit (RV 41*) - konto 208* deebet (RV 41)) + 
--jooksva per saldoandmikust (konto 258* kreedit (RV 41*) - konto 258* deebet (RV 41*))

--(Jooksva per saldoandmikust (Sum konto 6589* kreedit - konto 6589* deebet - 658910 kreedit + 658910 deebet)) + 
			select sum(kr) - sum(db) into lnDb31 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),4) = ('6589');
			
			lnDeebet = ifnull(lnDb31,0);	

			select  sum(db), sum(kr)  into lnDb31, lnKr31 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('658910');

			lnDeebet = lnDeebet  - ifnull(lnKr31,0) + ifnull(lnDb31,0);	
--jooksva per saldoandmikust (konto 208* kreedit (RV 41*) - konto 208* deebet (RV 41)) + 
--jooksva per saldoandmikust (konto 258* kreedit (RV 41*) - konto 258* deebet (RV 41*))
			select sum(kr) - sum(db) into lnDb31 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) in ('208','258') and ltrim(rtrim(rahavoo)) = '41';

			lnDeebet = lnDeebet + ifnull(lnDb31,0);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(670,'Rahavood finantseerimistegevusest','','8',' Makstud muud finantskulud',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (Sum konto 297* kreedit - konto 297* deebet)) - (eelmise per saldoandmikust (Sum konto 297* kreedit - konto 297* deebet))
			select sum(kr) - sum(db) into lnDeebet
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = ('297') ;

			select sum(kr) - sum(db)  into lnKreedit 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),3) = ('297') ;

			lnDeebet = ifnull(lnDeebet,0) - ifnull(lnKreedit,0); 

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(680,'Rahavood finantseerimistegevusest','','8',' Riskimaandamise reservi muutus',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

--(Jooksva per saldoandmikust (konto 203210 kreedit RV 06 miinus konto 203210 deebet RV 06)
			select sum(kr) - sum(db) into lnDeebet
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) = ('203210') and ltrim(rtrim(rahavoo)) = '06' ;

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(690,'Rahavood finantseerimistegevusest','','8',' Makstud dividendid',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum (konto 29* RV 05 kreedit - konto 29* RV 05 deebet)) + (sum konto 289000 kreedit RV 05 - sum konto 289000 deebet RV 05))
			select sum(kr) - sum(db) into lnDeebet
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			(left(ltrim(rtrim(saldoandmik.konto)),2) = ('29') and ltrim(rtrim(rahavoo)) = '05') or 
			(left(ltrim(rtrim(saldoandmik.konto)),6) = ('289000') and ltrim(rtrim(rahavoo)) = '05')
			);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(700,'Rahavood finantseerimistegevusest','','8',' Laekunud sissemaksed omakapitali',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (Sum (konto 29* RV 06 kreedit - konto 29* RV 06 deebet)) + (sum konto 289000 kreedit RV 06 - sum konto 289000 deebet RV 06))
			select sum(kr) - sum(db) into lnDeebet
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			(left(ltrim(rtrim(saldoandmik.konto)),2) = ('29') and ltrim(rtrim(rahavoo)) = '06') or 
			(left(ltrim(rtrim(saldoandmik.konto)),6) = ('289000') and ltrim(rtrim(rahavoo)) = '06')
			);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(710,'Rahavood finantseerimistegevusest','','8',' Tasutud väljamaksed omakapitalist',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (Sum konto 68* kreedit - konto 68* deebet)) 
			select sum(kr) - sum(db) into lnDeebet
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),2) = '68';

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(720,'Rahavood finantseerimistegevusest','','8',' Dividendidelt makstud tulumaks',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 
--(Jooksva per saldoandmikust (sum konto 7* kreedit - 7* deebet - konto 700002 kreedit - konto 710002 kreedit - konto 700030 kreedit - konto 710030 kreedit + 
--konto 700002 deebet + konto 710002 deebet + konto 700030 deebet + konto 710030 deebet) + kontod 1* kreedit (RV 15 + RV 16) - kontod 1* deebet (RV 15 + RV 16) + 
--kontod 2* kreedit (RV 15 + RV 16 + RV 35 + RV 36) - kontod 2* deebet (RV 15 + RV 16 + RV 35 + RV 36)
			select sum(kr) - sum(db) into lnDeebet
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),1) = '7';

			lnDeebet = ifnull(lnDeebet,0);

			select sum(db),sum(kr)  into lnDb31,lnKr31
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(saldoandmik.konto)),6) in ('700002','710002','700030','710030 ');

			lnDeebet = lnDeebet  - ifnull(lnKr31,0) + ifnull(lnDb31,0);

			select sum(db),sum(kr)  into lnDb31,lnKr31
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			(left(ltrim(rtrim(saldoandmik.konto)),1) = '1' and ltrim(rtrim(rahavoo)) in ('15','16')) or
			(left(ltrim(rtrim(saldoandmik.konto)),1) = '2' and ltrim(rtrim(rahavoo)) in ('15','16','35','36'))
			);

			lnDeebet = lnDeebet  + ifnull(lnKr31,0) - ifnull(lnDb31,0);
			if round(lnDeebet/15.6466,2) <> 0 then

				insert into  tmp_sk_aruanned (jrnr, grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
					(725,'Rahavood finantseerimistegevusest','','8',' Netofinantseerimine eelavest',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 

			end if;
-- = grupp kokku 

			select sum(summa01) into lnDeebet  
			from tmp_sk_aruanned
			where ltrim(rtrim(timestamp)) =  lcReturn 
			and ltrim(rtrim(konto)) in ('710','711','712','713','720');

			lnDeebet = ifnull(lnDeebet,0);

			raise notice 'lnDeebet 79 %',lnDeebet;

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(529,'Rahavood investeerimistegevusest','','79','Rahavood investeerimistegevusest kokku',lnDeebet,tdKpv, tnRekvId,lcReturn, 0); 



--= grupp kokku 
			select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and ltrim(rtrim(konto)) = '8';

			raise notice 'lnDeebet %',lnDeebet;

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2, konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(740,'Rahavood finantseerimistegevusest','','80','Rahavood finantseerimistegevusest kokku',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 

--= rahavood põhitegevusest + rahavood inv tegevusest + rahavood fin tegevusest
/*
	select sum(summa01/15.6466) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn
		and (
		ltrim(rtrim(konto)) in ('60')
		);
	raise notice 'Puhas rahavoog: osa 60 %',lnDeebet;
	select sum(summa01/15.6466) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn
		and (
		ltrim(rtrim(konto)) in ('70')
		);
	raise notice 'Puhas rahavoog: osa 70 %',lnDeebet;
	select sum(summa01/15.6466) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn
		and (
		ltrim(rtrim(konto)) in ('80')
		);
	raise notice 'Puhas rahavoog: osa 80 %',lnDeebet;
*/
	select sum(summa01) into lnDeebet from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn
		and (
		ltrim(rtrim(konto)) in ('60','79','80')
		);

	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(750,'','','90','Puhas rahavoog',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 
--Eelmise per saldoandmikust (sum konto 100* deebet - konto 100* kreedit) + (sum konto 101100 deebet - konto 101100 kreedit)

			select sum(db)-sum(kr)  into lnKreedit 
			from saldoandmik
			where aasta = lnDb2 and kuu = lnDb3  
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			left(ltrim(rtrim(saldoandmik.konto)),3) = ('100') or left(ltrim(rtrim(saldoandmik.konto)),6) = ('101100')
			);

			raise notice 'Raha eelmised %',lnKreedit;
			
	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(760,'','','91','Raha ja selle ekvivalendid perioodi alguses',ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0); 
--Jooksva per saldoandmikust (sum konto 100* deebet - konto 100* kreedit) + (sum konto 101100 deebet - konto 101100 kreedit)

			select sum(db)-sum(kr)  into lnDeebet 
			from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			left(ltrim(rtrim(saldoandmik.konto)),3) = ('100') or left(ltrim(rtrim(saldoandmik.konto)),6) = ('101100')
			);
			raise notice 'Raha kaes %',lnDeebet;
/*
			for v_test in
			select konto, db, kr from saldoandmik
			where aasta =  year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (
			left(ltrim(rtrim(saldoandmik.konto)),3) = ('100') or left(ltrim(rtrim(saldoandmik.konto)),6) = ('101100')
			)
			loop
				raise notice 'v_test.konto %',v_test.konto;
				raise notice 'v_test.db %',v_test.db;
				raise notice 'v_test.kr %',v_test.kr;
			end loop;

*/
	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(770,'','','92','Raha ja selle ekvivalendid perioodi lõpus',ifnull(lnDeebet,0),tdKpv, tnRekvId,lcReturn, 0); 
--= jooksva per summa (eelmine rida) - eelmise per summa (üleeelmine rida)
			
	insert into  tmp_sk_aruanned (jrnr,grupp, grupp2,konto,nimetus, summa01,  kpv, rekvid, timestamp, tyyp) values
			(780,'','','93','Raha ja selle ekvivalentide muutus',ifnull(lnDeebet,0)-ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0); 

	delete from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcReturn and round(summa01/15.6466,2) = 0;

--rahavoog lõpp

end if;

if tnLiik = 4 then
-- Kond pikk tulem

	raise notice 'Pikk tulem';
	raise notice 'Arvestan..';

	if tnRekvId = 63 and tnSvod = 1 then
		lnrekvId = 999;
	else
		lnrekvId = tnRekvId;
	end if; 
	insert into  tmp_sk_aruanned (konto, summa01,  kpv, rekvid, timestamp, tyyp) 
			select saldoandmik.konto, sum(kr) - sum(db),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),1)) >= 3 and val(left(konto,1)) < 9
			group by saldoandmik.konto
			order by saldoandmik.konto;

	insert into  tmp_sk_aruanned (konto, summa01,  kpv, rekvid, timestamp, tyyp) 
			select saldoandmik.konto, sum(kr) + sum(db),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),1)) >= 9 and  val(left(konto,3)) <= 920
			group by saldoandmik.konto
			order by saldoandmik.konto;

	insert into  tmp_sk_aruanned (konto, summa01,  kpv, rekvid, timestamp, tyyp) 
			select saldoandmik.konto, sum(db) - sum(kr),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),3)) > 920 and val(left(konto,2)) < 93
			group by saldoandmik.konto
			order by saldoandmik.konto;

	insert into  tmp_sk_aruanned (konto, summa01,  kpv, rekvid, timestamp, tyyp) 
			select saldoandmik.konto, sum(db) + sum(kr),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),2)) >= 93 
			group by saldoandmik.konto
			order by saldoandmik.konto;


	raise notice 'Lisan nimetused..';
	
	for v_saldo in 
		select id, konto from tmp_sk_aruanned where timestamp = lcreturn
	loop
		select nimetus into lcString from library where kood = v_saldo.konto and library = 'KONTOD';
		UPDATE tmp_sk_aruanned set nimetus = ifnull(lcString,space(1)) where id = v_saldo.id;
	end loop;
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3', 'Tegevustulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),1) = '3';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '30', 'Maksud ja sotsiaalkindlustusmaksed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '30';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '300', 'Tulumaks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '300';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3000', 'Füüsilise isiku tulumaks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3000';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3001', 'Juriidilise isiku tulumaks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3001';

	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '302', 'Sotsiaalmaks ja sotsiaalkindlustusmaksed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '302';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3020', 'Sotsiaalmaks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3020';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '30200', 'Sotsiaalmaks pensionikindlustuseks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '30200';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '30201', 'Sotsiaalmaks ravikindlustuseks ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '30201';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3025', 'Töötuskindlustusmaksed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and left(ltrim(rtrim(konto)),4) = '3025';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3025', 'Töötuskindlustusmaksed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and left(ltrim(rtrim(konto)),4) = '3025';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3026', 'Kogumispension',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and left(ltrim(rtrim(konto)),4) = '3026';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '303', 'Omandimaksud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and left(ltrim(rtrim(konto)),3) = '303';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '304', 'Maksud kaupadelt ja teenustelt',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '304';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3042', 'Aktsiisimaks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3042';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '30420', 'Alkoholiaktsiis',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '30420';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '30422', 'Kütuseaktsiis',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '30422';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3043', 'Hasartmängumaks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3043';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '305', 'Maksud väliskaubanduselt ja tehingutelt',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '305';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '32', 'Kaupade ja teenuste müük',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '32';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '320', 'Riigilõivud ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '320';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '322', 'Tulud majandustegevusest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '322';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3220', 'Tulud haridusalasest tegevusest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3220';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3221', 'Tulud kultuuri- ja kunstialasest tegevusest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3221';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3222', 'Tulud sprodi- ja puhkealasest tegevusest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3222';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3223', 'Tulud tervishoiust',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3223';
	insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3224', 'Tulud sotsiaalabialasest tegevusest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3224';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3225', 'Elamu- ja kommunaaltegevuse tulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3225';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3227', 'Tulud korrakaitsest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3227';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '323', 'Tulud majandustegevusest (järg)',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '323';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3230', 'Tulud transpordi- ja sidealasest tegevusest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3230';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3232', 'Tulud muudelt majandusaladelt',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3232';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3233', 'Üür ja rent',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3233';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3237', 'Õiguste müük',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3237';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3238', 'Muu toodete ja teenuste müük',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3238';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '35', 'Saadud toetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '35';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '350', 'Saadud sihtfinantseerimine ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '350';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3500', 'Saadud sihtfinantseerimine tegevuskuludeks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3500';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3502', 'Saadud sihtfinantseerimine põhivara soetuseks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3502';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '351', 'Põhivara soetamiseks saadud sihtfinantseerimise amortisatsioon',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '351';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '352', 'Saadud mittesihtotstarbeline finantseerimine',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '352';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38', 'Muud tulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '38';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '381', 'Kasum/kahjum põhivara ja varude müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '381';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3810', 'Kasum/kahjum kinnisvarainvesteeringute müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3810';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3811', 'Kasum/kahjum materiaalse põhivara müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3811';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38110', 'Kasum/kahjum maa müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38110';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38111', 'Kasum/kahjum hoonete müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38111';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38112', 'Kasum/kahjum rajatiste müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38112';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38113', 'Kasum/kahjum kaitseotstarbelise põhivara müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38113';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38114', 'Kasum/kahjum masinate ja seadmete müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38114';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38115', 'Kasum/kahjum info- ja kommunikatsioonitehnoloogia seadmete müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38115';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38116', 'Kasum/kahjum muu amortiseeruva materiaalse põhivara müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38116';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38117', 'Kasum/kahjum mitteamortiseeruvate põhivarade müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38117';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38118', 'Kasum/kahjum lõpetamata ehituse müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38118';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3813', 'Kasum/kahjum immateriaalse põhivara müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3813';


		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38130', 'Kasum/kahjum tarkvara müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38130';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38132', 'Kasum/kahjum õiguste ja litsentside müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38132';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '38136', 'Kasum/kahjum muu immateriaalse põhivara müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '38136';


		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3814', 'Kasum/kahjum bioloogiliste varade müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3814';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3818', 'Kasum/kahjum varude müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3818';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '382', 'Muud tulud varadelt',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '382';


		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3823', 'Võlalt arvestatud intressitulu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3823';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3825', 'Tulud loodusressursside kasutamisest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3825';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '388', 'Muud tulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '388';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3880', 'Trahvid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3880';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3882', 'Saastetasud ja keskkonnale tekitatud kahju hüvitis',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3882';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '3888', 'Eespool nimetamata muud tulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '3888';

--Saldoandmikust (Sum: Kontod 4*kuni 64* Kreedit) - (Sum: Kontod 4* kuni 64* Deebet)

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp,tegev) 
			select '*', 'Tegevuskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0,'399999' 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),1)) >= 4 and val(left(ltrim(rtrim(konto)),2)) <= 64;

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4', 'Antud toetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),1) = '4';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '40', 'Subsiidiumid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '40';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '41', 'Sotsiaaltoetused ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '41';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '410', 'Sotsiaalkindlustustoetused ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '410';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4100', 'Pensionikindlustustoetused sotsiaalmaksutuludest ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4100';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4102', 'Pensionikindlustustoetused mitte sotsiaalmaksutuludest ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4102';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4105', 'Ravikindlustustoetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4105';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4108', 'Töötuskindlustustoetused ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4108';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '413', 'Sotsiaalabitoetused ja muud toetused füüsilistele isikutele',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '413';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4130', 'Peretoetused ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4130';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4132', 'Toetused töötutele',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4132';
			
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4133', 'Toetused puudega inimestele ja nende hooldajatele',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4133';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4134', 'Õppetoetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4134';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4138', 'Muud sotsiaalabitoetused ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4138';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4139', 'Preemiad ja stipendiumid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4139';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '414', 'Sotsiaaltoetused avaliku sektori töövõtjatele ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '414';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '45', 'Muud toetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '45';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '450', 'Antud sihtfinantseerimine',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '450';
			
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4500', 'Antud sihtfinantseerimine tegevuskuludeks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4500';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '4502', 'Antud sihtfinantseerimine põhivara soetuseks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '4502';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '452', 'Antud mittesihtotstarbeline finantseerimine',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '452';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5', 'Tegevuskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),1) = '5';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50', 'Tööjõukulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '50';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '500', 'Töötasu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '500';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5000', 'Valitavate ja ametisse nimetatud ametnikud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5000';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5001', 'Avaliku teenistuse ametnikud (va kaitseväelased, piirivalve-, politseiametnikud)',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5001';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50010', 'Kõrgemad ametnikud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50010';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50014', 'Vanemametnikud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50014';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50015', 'Nooremametnikud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50015';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5002', 'Töötajate töötasu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5002';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50020', 'Nõukogude ja juhatuste liikmed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50020';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50021', 'Juhid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50021';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50024', 'Tippspetsialistid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50024';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50025', 'Keskastme spetsialistid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50025';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50026', 'Õpetajad',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50026';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '50028', 'Töölised ja abiteenistujad',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '50028';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5008', 'Muud koosseisuvälised töötasud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5008';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '505', 'Erisoodustused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '505';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '506', 'Maksud ja sotsiaalkindlustusmaksed',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '506';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '507', 'Tööjõukulude kapitaliseerimine',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '507';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55', 'Majandamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '55';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5500', 'Administreerimiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5500';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5503', 'Lähetuskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5503';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55030', 'Lühiajalised lähetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55030';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55031', 'Pikaajalised lähetused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55031';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5504', 'Koolituskulud ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5504';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5511', 'Kinnistute, hoonete ja ruumide majandamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5511';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55110', 'Kinnistute, hoonete, ruumide majandamiskulud (va kinnisvarainvesteeringud)',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55110';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55112', 'Kinnisvarainvesteeringute haldamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55112';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55113', 'Üürile ja rendile antud kinnistute, hoonete, ruumide majandamiskulud (va kinnisvarainvesteeringud)',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55113';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5512', 'Rajatiste majandamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5512';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5513', 'Sõidukite majandamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5513';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55130', 'Maismaasõidukid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55130';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55131', 'Õhusõidukid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55131';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '55132', 'Veesõidukid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),5) = '55132';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5514', 'Info- ja kommunikatsioonitehnoloogia kulud ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5514';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5515', 'Inventari majandamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5515';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5516', 'Töömasinate ja seadmete majandamiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5516';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5521', 'Toiduained ja toitlustusteenused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5521';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5522', 'Meditsiinikulud ja hügieenikulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5522';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5523', 'Teavikute ja kunstiesemete kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5523';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5524', 'Õppevahendite ja koolituse kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5524';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5525', 'Kommunikatsiooni-, kultuuri- ja vaba aja sisustamise kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5525';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5526', 'Sotsiaalteenused',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5526';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5529', 'Tootmiskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5529';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5531', 'Kaitseotstarbeline varustus ja materjalid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5531';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5532', 'Eri- ja vormiriietus (va kaitseotstarbelised kulud)',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5532';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5539', 'Muu erivarustus ja materjalid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5539';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '5540', 'Mitmesugused majanduskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '5540';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6', 'Muud kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),1) = '6';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '60', 'Muud tegevuskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '60';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '600', 'Riigisaladusega seotud kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '600';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '601', 'Maksu-, lõivu- ja trahvikulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '601';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6010', 'Maksud, lõivud, trahvid ',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6010';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6012', 'Ebatõenäoliselt laekuvad maksu-, lõivu- ja trahvinõuded',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6012';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6015', 'Edasiantud maksud, lõivud, trahvid',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6015';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '605', 'Ebatõenäoliselt laekuvad nõuded',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '605';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '608', 'Muud tegevuskulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '608';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '61', 'Põhivara amortisatsioon ja ümberhindlus',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '61';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '611', 'Materiaalse põhivara amortisatsioon',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '611';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6110', 'Hoonete ja rajatiste amortisatsioon',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6110';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6114', 'Masinate ja seadmete amortisatsioon',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6114';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '613', 'Immateriaalse põhivara amortisatsioon',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '613';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '614', 'Kasum/kahjum bioloogiliste varade ümberhindamisest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '614';

--Saldoandmikust (Sum: Kontod 3*kuni 64* Kreedit) - (Sum: Kontod 3* kuni 64* Deebet)
			
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp, tegev) 
			select '*', 'Aruandeperioodi tegevustulem',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0,'614999' 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),1)) >= 3 and val(left(ltrim(rtrim(konto)),2)) <= 64;
			
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '65', 'Finantstulud ja -kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '65';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '650', 'Intressikulu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '650';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '652', 'Tulem osalustelt',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '652';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '655', 'Tulu hoiustelt ja väärtpaberitelt',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '655';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6550', 'Intressitulu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6550';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6552', 'Kasum/kahjum finantsinvesteeringute müügist',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6552';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6554', 'Kasum/kahjum finantsinvesteeringute ümberhindamisest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6554';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '658', 'Muud finantstulud ja -kulud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '658';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6580', 'Intressitulu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6580';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '6589', 'Muu finantstulu ja -kulu',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '6589';
--Saldoandmikust (Sum: Kontod 3*kuni 6* Kreedit) - (Sum: Kontod 3* kuni 6* Deebet)
/*

select * from rekv where id = 27
select * from saldoandmik where rekvid = 27 and aasta = 2010 and kuu = 12 
update rekv set parentid = 9999 where id = 27
			select '*', 'Aruandeperioodi tulem',ifnull(sum(kr),0) - ifnull(sum(db),0)
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta =2010 and kuu = (12) 
			and (saldoandmik.rekvid in (27)	)		
			and val(left(ltrim(rtrim(konto)),1)) >= 3 and val(left(ltrim(rtrim(konto)),1)) <= 6;

*/			
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp, tegev) 
			select '*', 'Aruandeperioodi tulem',ifnull(sum(kr),0) - ifnull(sum(db),0),tdKpv, tnRekvId,lcReturn, 0,'699999' 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),1)) >= 3 and val(left(ltrim(rtrim(konto)),1)) <= 6;

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '7', 'Netofinantseerimine eelarvest',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),1) = '7';

		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '70', 'Saadud siirded',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '70';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '71', 'Antud siirded',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),2) = '71';
--Saldoandmikust (Sum: Kontod 3*kuni 7* Kreedit) - (Sum: Kontod 3* kuni 7* Deebet)
			
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp,tegev) 
			select '*', 'Aruandeperioodi tulem ja siirded kokku',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 ,'719999'
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and val(left(ltrim(rtrim(konto)),1)) >= 3 and val(left(ltrim(rtrim(konto)),1)) <= 7;
			
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '9', 'Täiendav informatsioon aruande koostamiseks',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),1) = '9';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '900', 'Töötajate arv',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),3) = '900';
		insert into  tmp_sk_aruanned (konto, nimetus, summa01,  kpv, rekvid, timestamp, tyyp) 
			select '9002', 'Avaliku teenistuse ametnikud',ifnull(sum(kr) - sum(db),0),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto AND library.library = 'KONTOD')
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)			
			and left(ltrim(rtrim(konto)),4) = '9002';

		delete from tmp_sk_aruanned where summa01 = 0 and timestamp = lcReturn;

--koostame järjekord
		update 	tmp_sk_aruanned set tegev = konto where timestamp = lcReturn and not empty(konto) and empty (tegev);	


--	tulemiaruanne lõpp

end if;



if tnLiik = 3 then
-- Kond pikk bilanss

	raise notice 'Pikk bilanss';
	raise notice 'Arvestan..';

	if tnRekvId = 63 and tnSvod = 1 then	
		lnRekvId = 999;
	else
		lnRekvId = tnRekvId;
	end if;


	insert into  tmp_sk_aruanned (konto, summa03, summa04, kpv, rekvid, timestamp, tyyp) 
			select saldoandmik.konto, sum(ifnull(db,0)), sum(ifnull(kr,0)),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik 
			where saldoandmik.aasta = year(tdKpv) and saldoandmik.kuu = month(tdKpv) 
			and val(left(ltrim(rtrim(saldoandmik.konto)),1)) < 3
			and (saldoandmik.rekvid in (SELECT distinct id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) 
				or  saldoandmik.rekvid = lnRekvId)
			group by saldoandmik.konto
			order by saldoandmik.konto;
/*
			select saldoandmik.konto, sum(db), sum(kr),tdKpv, tnRekvId,lcReturn, 0 
			from saldoandmik inner join library on (library.kood = saldoandmik.konto and library.library = 'KONTOD')
			where aasta = year(tdKpv) and 'kuu = month(tdKpv) 
			and saldoandmik.rekvid in (SELECT distinct id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId
			and val(left(ltrim(rtrim(saldoandmik.konto)),1)) < 3
			group by saldoandmik.konto
			order by saldoandmik.konto;
*/

--	select summa03 into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn ;


	raise notice 'Lisan nimetused..';

	select sum(summa03) into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn and konto = '100100';
	raise notice 'pank 1:%',lnDeebet;
	raise notice 'tdKpv%',tdKpv;


	
	for v_saldo in 
		select id, konto from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = lcreturn
	loop
		select nimetus,tun5 into lcString,lnDb31 from library where kood = v_saldo.konto and library = 'KONTOD';
		if lnDb31 = 1 or lnDb31 = 3 then			
			UPDATE tmp_sk_aruanned set nimetus = ifnull(lcString,space(1)),
				summa01 = ifnull(summa03,0) - ifnull(summa04,0)	
			where id = v_saldo.id;
		else
			UPDATE tmp_sk_aruanned set nimetus = ifnull(lcString,space(1)),
				summa01 = ifnull(summa04,0) - ifnull(summa03,0)	
			where id = v_saldo.id;
		end if;
	end loop;

--	select sum(summa03) into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn and konto = '100100';
--	raise notice 'lnDeebet %',lnDeebet;

	raise notice 'arvestan kondid';

	select sum(db),sum(kr) into lnDeebet, lnKreedit from saldoandmik 
	where aasta = year(tdKpv) and kuu = month(tdKpv) 
	and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
	and konto = '103500';

--	raise notice 'D 103500 %',lnDeebet;
--	raise notice 'K 103500 %',lnKreedit;

	update tmp_sk_aruanned set summa01 = ifnull(lnKreedit,0) - ifnull(lnDeebet,0) where timestamp = lcReturn and ltrim(rtrim(konto)) = '103500';
	
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '10', 'Käibevara' ,ifnull(sum(db) - sum(kr),0) - ifnull(lnDeebet,0) + ifnull(lnKreedit,0),tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like '10%'; 

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '103', 'Muud nouded ja ettemaksed' ,ifnull(sum(db) - sum(kr),0)-ifnull(lnDeebet,0)+ifnull(lnKreedit,0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like '103%';
			

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '100', 'Raha ja pangakontod' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like '100%'; 
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '101', 'Finantsinvesteeringud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like  '101%';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1011', 'Kauplemisportfelli väärtpaberid' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like '1011%';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1012', 'Tähtajani hoitavad väärtpaberid' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like '1012%';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1019', 'Muud finantsinvesteeringud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1019';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '102', 'Maksu-, lõivu- ja trahvinõuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '102';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1020', 'Maksu-, lõivu ja trahvinõuded (bruto)' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1020';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1021', 'Ebatõenäoliselt laekuvad maksu-, lõivu ja trahvinõuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1021';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1030', 'Nouded ostjate vastu' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1030';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1031', 'Viitlaekumised' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1031';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1032', 'Laenu- ja liisingnõuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1032';

--Saldoandmikust (Sum: Kontod 1035* Deebet) - (Sum: Kontod 1035* Kreedit) - konto 103500 deebet + konto 103500 kreedit
			
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1035', 'Nõuded toetuste ja siirete eest' ,ifnull(sum(db) - sum(kr),0) - IFNULL(lnDeebet,0) + IFNULL(lnKreedit,0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1035';
			
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1036', 'Muud nõuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1036';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1037', 'Maksude, lõivude, trahvide ettemaksed ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1037';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1038', 'Ettemakstud toetused' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1038';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1039', 'Ettemakstud tulevaste perioodide kulud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1039';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '108', 'Varud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '108';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1080', 'Strateegilised varud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1080';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1089', 'Üle andmata varud ja ettemaksed varude eest' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1089';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '109', 'Müügiootel põhivara' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '109';
			
			select sum(db),sum(kr) into lnDb31,lnKr31  from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(konto)),2) = '15';

			
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp)  values 
			('15', 'Pohivara' ,ifnull(lndb31,0) - ifnull(lnkr31,0), tdKpv, tnRekvId,lcReturn, 0);
			
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '150', 'Osalused avaliku sektori ja sidusüksustes' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '150';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1502', 'Osalused tütar- ja sidusettevõtjates' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1502';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '151', 'Finantsinvesteeringud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '151';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1511', 'Investeerimisportfelli väärtpaberid' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1511';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1512', 'Tähtajani hoitavad võlakirjad ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1512';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1519', 'Muud finantsinvesteeringud' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1519';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '152', 'Maksu-, lõivu- ja trahvinõuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '152';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1520', 'Maksu-, lõivu ja trahvinõuded (bruto)' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1520';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1521', 'Ebatõenäoliselt laekuvad maksu-, lõivu ja trahvinõuded ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1521';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '153', 'Muud nõuded ja ettemaksed' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '153';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1530', 'Nõuded ostjate vastu' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1530';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1532', 'Laenu- ja liisingnõuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1532';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1535', 'Nõuded toetuste eest' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1535';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1536', 'Muud pikaajalised nõuded' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1536';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1537', 'Antud sihtfinantseerimine' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1537';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '154', 'Kinnisvarainvesteeringud ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '154';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '155', 'Materiaalne põhivara ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '155';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1551', 'Hooned ja rajatised ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1551';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '15510', 'Hooned ja rajatised soetusmaksumuses ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,5) = '15510';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '15511', 'Hoonete ja rajatiste kogunenud kulum ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,5) = '15511';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1553', 'Kaitseotstarbeline põhivara ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1553';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1554', 'Masinad ja seadmed ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1554';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '15540', 'Masinad ja seadmed soetusmaksumuses ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,5) = '15540';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '15541', 'Masinate ja seadmete kogunenud kulum ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,5) = '15541';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1555', 'Info- ja kommunikatsioonitehnoloogia seadmed ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1555';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1556', 'Muu amortiseeruv materiaalne põhivara' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1556';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1559', 'Kasutusele võtmata varad ja ettemaksed' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1559';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '156', 'Immateriaalne põhivara' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '156';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1560', 'Tarkvara' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1560';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1562', 'Õigused ja litsentsid' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1562';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1564', 'Arenguväljaminekud ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1564';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1565', 'Firmaväärtus ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1565';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1566', 'Muu immateriaalne põhivara  ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1566';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1569', 'Kasutusele võtmata varad ja ettemaksed ' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '1569';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '157', 'Bioloogilised varad' ,ifnull(sum(db) - sum(kr),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '157';


--Saldoandmikust (Sum: Kontod 2* Kreedit) - (Sum: Kontod 7* Deebet) + konto 103500 kreedit - konto 130500 deebet
/*
			select sum(db) into lnDb7  from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(konto)),1) = '7';

raise notice 'db 7 %',lnDb7;
*/
			select sum(kr), sum(db) into lnKr2,lnDb2  from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(konto)),1) = '2';

--raise notice 'kr 2 %',lnKr2;-
--raise notice 'db 2 %',lnKr2;
--raise notice 'deebet 103500 %',lnDeebet;
--raise notice 'kr 103500 %',lnKreedit;

--	select sum(summa03) into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn and konto = '100100';
--	raise notice 'pank %',lnDeebet;


/*
			select sum(db) into lnDb31  from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(ltrim(rtrim(konto)),6) = '103500';
*/

--Saldoandmikust (Sum: Kontod 2* Kreedit) - (Sum: Kontod 2* Deebet) + konto 103500 kreedit - konto 103500 deebet
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) values
			('2', 'Kohustused ja netovara' ,ifnull(lnKr2,0) - ifnull(lnDb2,0) + ifnull(lnKreedit,0) - ifnull(lnDeebet,0), tdKpv, tnRekvId,lcReturn, 0);

	select sum(db),sum(kr) into lnDb2035,lnKr2035 from saldoandmik 
	where aasta = year(tdKpv) and kuu = month(tdKpv) 
	and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
	and konto = '203500';

	lnKr2035 = ifnull(lnKr2035,0);
	lnDb2035 = ifnull(lnDb2035,0);

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '20', 'Luhiajalised kohustused' ,ifnull(sum(kr) - sum(db),0)-ifnull(lnKr2035,0) + ifnull(lnDb2035,0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like  '20%';

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '200', 'Saadud maksude, lõivude ja trahvide ettemaksed' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '200';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '201', 'Võlad tarnijatele' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '201';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '202', 'Võlad töötajatele' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '202';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '203', 'Muud kohustused ja saadud ettemaksed' ,ifnull(sum(kr) - sum(db),0) - ifnull(LnKr2035,0)+ifnull(lnDb2035,0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and konto like '203%';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2030', 'Maksu-, lõivu- ja trahvikohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2030';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2032', 'Viitvõlad' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2032';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2035', 'Toetuste ja siirete kohustused' ,ifnull(sum(kr) - sum(db),0)-lnKr2035+lnDb2035, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2035';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2036', 'Muud kohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2036';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2038', 'Toetusteks saadud ettemaksed' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2038';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2039', 'Muud saadud ettemaksed ja tulevaste perioodide tulud' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2039';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '206', 'Eraldised' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '206';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '208', 'Laenukohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '208';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2080', 'Emiteeritud võlakirjad' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2080';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2081', 'Laenud' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2081';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2083', 'Faktooringkohustused ' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2083';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '25', 'Pikaajalised kohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,2) = '25';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '250', 'Võlad tarnijatele' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '250';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '253', 'Muud kohustusd ja saadud ettemaksed' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '253';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2530', 'Maksu-, lõivu- ja trahvikohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2530';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2535', 'Toetuste andmise kohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2535';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2536', 'Muud kohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2536';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2538', 'Ettemaksed ja tulevaste perioodide tulud' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2538';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '256', 'Eraldised' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '256';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '257', 'Sihtfinantseerimine' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '257';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '258', 'Laenukohustused' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '258';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2580', 'Emiteeritud võlakirjad' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2580';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '2581', 'Laenud' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,4) = '2581';
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp, tegev) values
			( '*', 'Eelarvesse kuuluv netovara' ,ifnull(lnKreedit,0) - ifnull(lnDeebet,0)+ifnull(lnKr2035,0)-ifnull(lnDb2035,0), tdKpv, tnRekvId,lcReturn, 0, '2582');

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '290', 'Reservid' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '290';

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '291', 'Aktsia- või osakapital ja ülekurss' ,ifnull(sum(kr) - sum(db),0), tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,3) = '291';

	select sum(db),sum(kr) into lnDeebet,lnKreedit from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,1) in ('3','4','5','6','7') ;

--Saldoandmikust (Sum: Kontod 3*kuni 6* Kreedit) - (Sum: Kontod 3* kuni 6* Deebet)


	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) values
			( '299000', 'Aruandeperioodi tulem' ,ifnull(lnKreedit,0) - ifnull(lnDeebet,0), tdKpv, tnRekvId,lcReturn, 0 ) ;


			select sum(summa01) into lnDb3 from tmp_sk_aruanned where timestamp = lcReturn and (konto like '298%' or konto like '299%');

/*
			select sum(db) into lnDb3 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and (val(left(konto,3)) = 298 or val(left(konto,3)) = 299) ;

			select sum(db) into lnDb31 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and val(left(konto,2)) > 29 and val(left(konto,1)) <= 7;
*/
	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) values
			( '29', 'Netovara' , ifnull(lnDb3,0), tdKpv, tnRekvId,lcReturn, 0 ) ;
				


--Saldoandmikust (Sum: Kontod 1* Deebet) - (Sum: Kontod 1* Kreedit) - konto 103500 deebet + konto 103500 kreedit

	insert into  tmp_sk_aruanned (konto,nimetus,summa01,  kpv, rekvid, timestamp, tyyp) 
			select '1', 'Varad' ,sum(db) - sum(kr) ,tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
			and left(konto,1) = '1' and ltrim(rtrim(konto)) <> '103500'; 

	select sum(db), sum(kr) into lnDeebet, lnKreedit
		from saldoandmik 
		where aasta = year(tdKpv) and kuu = month(tdKpv) 
		and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
		and left(konto,5) = '29800';
--	raise notice 'pank %',lnDeebet;

--Saldoandmikust (Sum: Konto 29800* Kreedit) - (Sum: Konto 29800* Deebet)
	update 	tmp_sk_aruanned set summa01 = ifnull(lnKreedit,0) - ifnull(lnDeebet,0) where konto = '298000' and timestamp = lcReturn;	

	delete from tmp_sk_aruanned where  timestamp = lcReturn and summa01 = 0;


-- kustutame null tulemused
	update 	tmp_sk_aruanned set summa01 = ifnull(summa01,0) where timestamp = lcReturn and not empty(konto);	

	select sum(summa03) into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn and konto = '100100';
	raise notice 'pank %',lnDeebet;

--koostame järjekord


	update 	tmp_sk_aruanned set tegev = konto where timestamp = lcReturn and not empty(konto);	
	update 	tmp_sk_aruanned set tegev = '298001' where timestamp = lcReturn and konto = '*';	
	update 	tmp_sk_aruanned set tegev = '298002' where timestamp = lcReturn and konto = '103500';	
	update 	tmp_sk_aruanned set tegev = '298003' where timestamp = lcReturn and konto = '203500';	


--	select sum(summa03) into lnDeebet from tmp_sk_aruanned where timestamp = lcReturn and konto = '100100';
--	raise notice 'pank %',lnDeebet;

--Saldoandmikust (Sum: Kontod 3*kuni 7* Kreedit) - (Sum: Kontod 3* kuni 7* Deebet)
-- bilanss kõik

end if;

if tnLiik = 2 then
-- Kond saldoaruanne
	delete from tmp_saldoandmik where rekvid = tnrekvId;

	if tnrekvId <> 63 or tnSvod <> 1 then

		raise notice 'Tavaline select ';
		lnRekvId = tnRekvId;
			
		INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
		SELECT nimetus, sum(db) , sum(kr), konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
		from  saldoandmik
		where aasta = year(tdKpv) and kuu = month(tdKpv)
		and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId)
		group by nimetus, konto, tegev, tp, allikas, rahavoo
		order by konto, tp, tegev, allikas, rahavoo;


	else


	if tnSvod = 1 and tnRekvId = 63 and (select count(*) from saldoandmik where rekvid = 999 and aasta = year(tdKpv) and kuu = month(tdKpv)) > 0 then
		-- tellitud kond aruanne, teeme select ja tagastame 

		raise notice 'Kond select ';
		lnRekvId = 999;
			
		INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
		SELECT nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
		from  saldoandmik
		where aasta = year(tdKpv) and kuu = month(tdKpv)
		and (saldoandmik.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, lnRekvId) > lnTase) or  saldoandmik.rekvid = lnRekvId);

	else

		raise notice 'Kond puudub, teeme uuesti ';


		for v_omatp in 
				select distinct omatp from saldoandmik 
					where aasta = year(tdKpv) and kuu = month(tdKpv) 
					and left(omatp,4) = left(lcOmatp,4)
		loop	

				raise notice 'omaTP: %',v_omatp.omatp;


				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
				SELECT saldoandmik.nimetus, 
					CASE WHEN kontod.tun5 = 1 or kontod.tun5 = 3 then saldoandmik.db - saldoandmik.kr else 0::numeric  end as db,
					CASE WHEN kontod.tun5 = 2 or kontod.tun5 = 4 then saldoandmik.kr - saldoandmik.db else 0::numeric  end as kr,
					saldoandmik.konto , saldoandmik.tegev , saldoandmik.tp , saldoandmik.allikas, saldoandmik.rahavoo, lcReturn, date(), tnrekvId
				from  saldoandmik left outer join library kontod on (kontod.kood = saldoandmik.konto and kontod.library = 'KONTOD') 
				where saldoandmik.aasta = year(tdKpv) and saldoandmik.kuu = month(tdKpv)
				and ltrim(rtrim(saldoandmik.omatp)) = ltrim(rtrim(v_omatp.omatp));	

--				group by nimetus, konto , tegev , tp , allikas, rahavoo;


			for v_tp in 
					select distinct tp from saldoandmik 
						where aasta = year(tdKpv) and kuu = month(tdKpv) 
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_omatp.omatp))
						and ltrim(rtrim(tp)) <> ltrim(rtrim(omatp)) and left(ltrim(rtrim(tp)),4) = left(ltrim(rtrim(lcOmatp)),4)
			loop	

				-- kirjutame miinus summad 
				-- deebet

				raise notice 'arvestan tp.%',v_tp.tp;
				
				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
						from  saldoandmik
						where aasta = year(tdKpv) and kuu = month(tdKpv)
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_omatp.OmaTp))
						and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
						and left(konto,1) = '1';

				INSERT INTO tmp_sd (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
						from  saldoandmik
						where aasta = year(tdKpv) and kuu = month(tdKpv)
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_omatp.OmaTp))
						and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
						and left(konto,1) = '1';

				-- kreedit
				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
						from  saldoandmik
						where aasta = year(tdKpv) and kuu = month(tdKpv) 
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
						and left(omatp,4) = left(lcOmatp,4)
						and ltrim(rtrim(tp)) = ltrim(rtrim(v_omatp.omatp))
						and left(konto,1) = '2';

				INSERT INTO tmp_sd (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
						from  saldoandmik
						where aasta = year(tdKpv) and kuu = month(tdKpv) 
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
						and left(omatp,4) = left(lcOmatp,4)
						and ltrim(rtrim(tp)) = ltrim(rtrim(v_omatp.omatp))
						and left(konto,1) = '2';


				-- (võrreldava saldoandmik (kõik kontod algusega 4 kuni 6, mille esitaja kood on TP kood on aruande koostaja kood (deebet miinus kreedit, 
				--	välja arvatud kontod 601000 ja 601001, mida ei võeta üldse arvesse olenemata TP koodist)))
				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
					from  saldoandmik
					where aasta = year(tdKpv) and kuu = month(tdKpv) 
					and ltrim(rtrim(omatp)) = ltrim(rtrim(v_omatp.OmaTp))
					and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
					and left(konto,1) in ('4','5','6') and konto not in ('601000','601001');

				INSERT INTO tmp_sd (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
					from  saldoandmik
					where aasta = year(tdKpv) and kuu = month(tdKpv) 
					and ltrim(rtrim(omatp)) = ltrim(rtrim(v_omatp.OmaTp))
					and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
					and left(konto,1) in ('4','5','6') and konto not in ('601000','601001');


				--(esitaja saldoandmik sum (kõik kontod algusega 3, mille TP kood on võrreldava kood (kreedit miinus deebet)))

				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
						from  saldoandmik
						where aasta = year(tdKpv) and kuu = month(tdKpv) 
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp))
						and left(omatp,4) = left(lcOmatp,4)
						and ltrim(rtrim(tp)) = ltrim(rtrim(v_omatp.omatp))
						and left(konto,1) = '3';
						
				INSERT INTO tmp_sd (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
						from  saldoandmik
						where aasta = year(tdKpv) and kuu = month(tdKpv) 
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp))
						and left(omatp,4) = left(lcOmatp,4)
						and ltrim(rtrim(tp)) = ltrim(rtrim(v_omatp.omatp))
						and left(konto,1) = '3';

				--(esitaja saldoandmik sum (kõik kontod algusega 7, mille TP kood on võrreldava kood (deebet miinus kreedit)))
				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
					from  saldoandmik
					where aasta = year(tdKpv) and kuu = month(tdKpv) 
					and ltrim(rtrim(omatp)) = ltrim(rtrim(v_omatp.OmaTp))
					and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
					and left(konto,2) = '70';

				INSERT INTO tmp_sd (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
					from  saldoandmik
					where aasta = year(tdKpv) and kuu = month(tdKpv) 
					and ltrim(rtrim(omatp)) = ltrim(rtrim(v_omatp.OmaTp))
					and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
					and left(konto,2) = '70';
					
				--(võrreldava saldoandmik (kõik kontod algusega 7, mille TP kood on aruande koostaja kood (kreedit miinus deebet)))
				INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
						from  saldoandmik
						where aasta = year(tdKpv) and kuu = month(tdKpv) 
						and left(omatp,4) = left(lcOmatp,4)
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp))
						and ltrim(rtrim(tp)) = ltrim(rtrim(v_omatp.omatp))
						and left(konto,2) = '71';

				INSERT INTO tmp_sd (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid) 
					SELECT nimetus, kr , db, konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId
						from  saldoandmik
						where aasta = year(tdKpv) and kuu = month(tdKpv) 
						and left(omatp,4) = left(lcOmatp,4)
						and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp))
						and ltrim(rtrim(tp)) = ltrim(rtrim(v_omatp.omatp))
						and left(konto,2) = '71';



			end loop;
		end loop;

			

			select sum(db) into lnDeebet from tmp_saldoandmik 
				where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcreturn)) and tyyp = 0 
				and left(tp,4) = left(lcOmatp,4) and left(konto,1) = '7'; 
			select sum(kr) into lnKreedit from tmp_saldoandmik 
				where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcreturn)) and tyyp = 0 
				and left(tp,4) = left(lcOmatp,4) and left(konto,1) = '7'; 

			if round(lnDeebet) = round(lnKreedit) then
--				lcRetElim = ltrim(rtrim(lcreturn))+'EL';
--				update tmp_saldoandmik set timestamp = lcRetElim where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcreturn)) and left(konto,1) = '7';		
				delete from tmp_saldoandmik where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcreturn)) and left(konto,1) = '7';		
			end if;
			
			-- parandame kassa nimetus sest need oli tehtud 3 erinevad
			update tmp_saldoandmik set nimetus = 'Kassa' where konto = '100000' and ltrim(rtrim(timestamp)) = ltrim(rtrim(lcreturn));

			INSERT INTO tmp_saldoandmik (nimetus, db , kr, konto , tegev , tp , allikas, rahavoo, timestamp, kpv, rekvid, tyyp) 
			SELECT nimetus, SUM(db) , SUM(kr), konto , tegev , tp , allikas, rahavoo, lcReturn, date(), tnrekvId,1
				from  tmp_saldoandmik
				where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcreturn)) and tyyp = 0
				group by nimetus, konto , tegev , tp , allikas, rahavoo;

			delete from tmp_saldoandmik where rekvid = tnRekvId and tyyp <> 1 or (db - kr = 0);


		if tnSvod = 1 and tnRekvId = 63 and (select count(*) from saldoandmik where rekvid = 0 and aasta = year(tdKpv) and kuu = month(tdKpv)) = 0 then
			-- salvestame kond saldoandmik
			raise notice 'salvestame kond saldoandmik ';
			
				insert into saldoandmik (nimetus, db,kr,konto,tegev,tp,	allikas,rahavoo ,kpv,aasta,kuu, rekvid,omatp,tyyp)
				select nimetus, sum(db), sum(kr), konto, tegev, tp, allikas,rahavoo, tdkpv, year(tdKpv), month(tdKpv), 999,lcOmatp,0 
				from (
				select ltrim(rtrim(tmp_saldoandmik.nimetus)) as nimetus, 
					case when kontod.tun5 = 1 or kontod.tun5 = 3 then tmp_saldoandmik.db - tmp_saldoandmik.kr else 0::numeric end as db,
					case when kontod.tun5 = 2 or kontod.tun5 = 4 then tmp_saldoandmik.kr - tmp_saldoandmik.db else 0::numeric end as kr,
					ltrim(rtrim(tmp_saldoandmik.konto)) as konto, ltrim(rtrim(tmp_saldoandmik.tegev)) as tegev, 
					ltrim(rtrim(tmp_saldoandmik.tp)) as tp, ltrim(rtrim(tmp_saldoandmik.allikas)) as allikas,
					ltrim(rtrim(tmp_saldoandmik.rahavoo)) as rahavoo ,tdkpv, year(tdKpv), month(tdKpv), 999,lcOmatp,0 
				from tmp_saldoandmik left outer join library kontod on (kontod.kood = tmp_saldoandmik.konto and kontod.library = 'KONTOD') 
				where timestamp = lcreturn and tmp_saldoandmik.rekvid = tnRekvId
				) tmp 
				group by konto, nimetus, tegev, tp, allikas, rahavoo;

		end if;

	end if;
	end if;
end if;

if tnLiik = 1 then

	-- Saldode vordlemine
	raise notice 'Saldode vordlemine ';
	if tnSvod = 1 then
		cOmaTp = '%';
	else
		cOmaTp = ltrim(rtrim(lcOmatp))+'%';
	end if;

	for v_omatp in 
		select distinct omatp from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and left(omatp,4) = '1851'
			and omatp like cOmaTp	
	loop	

		raise notice 'algus, omaTP: %',v_omatp.omatp;
		lcOmaTp = ltrim(rtrim(v_omatp.omatp));

	raise notice 'algus, omaTP: %',v_omatp.omatp;
	raise notice 'algus, lcomaTP: %',lcOmaTp;

	update tmp_sk_aruanned set tyyp = 2 where tyyp = 1 and timestamp = lcReturn;

	for v_tp in 
		select distinct tp from saldoandmik where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(saldoandmik.tp)) <> ltrim(rtrim(saldoandmik.omatp)) and left(ltrim(rtrim(saldoandmik.tp)),4) = left(ltrim(rtrim(lcomatp)),4)
	loop	

		raise notice 'V-tp.tp %',v_tp.tp;

		-- tp parnerid
		-- (esitaja saldoandmik sum (kõik kontod algusega 1, mille TP kood on võrreldava kood (deebet miinus kreedit)))
		insert into tmp_sk_aruanned (omaTp, tp, summa01, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db - kr, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(saldoandmik.omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(saldoandmik.tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(saldoandmik.konto)),1) = '1';


		-- (võrreldava saldoandmik (kõik kontod algusega 2, mille TP kood on aruande koostaja kood (kreedit miinus deebet)))

		insert into tmp_sk_aruanned (omaTp, tp, summa02,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr - db, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
			and ltrim(rtrim(tp)) = ltrim(rtrim(lcomatp))
			and left(ltrim(rtrim(konto)),1) = '2';

	
		-- (võrreldava saldoandmik (kõik kontod algusega 1, mille TP kood on aruande koostaja kood (deebet miinus kreedit)))

		insert into tmp_sk_aruanned (omaTp, tp, summa03,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db - kr, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp))
			and ltrim(rtrim(tp)) = lcomatp
			and left(ltrim(rtrim(konto)),1) = '1';




		-- (esitaja saldoandmik sum (kõik kontod algusega 2, mille TP kood on võrreldava kood (kreedit miinus deebet)))

		insert into tmp_sk_aruanned (omaTp, tp, summa04, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr - db, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) = '2';




		-- (võrreldava saldoandmik (kõik kontod algusega 4 kuni 6, mille esitaja kood on TP kood on aruande koostaja kood (deebet miinus kreedit, 
		--	välja arvatud kontod 601000 ja 601001, mida ei võeta üldse arvesse olenemata TP koodist)))
		insert into tmp_sk_aruanned (omaTp, tp, summa05,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db - kr, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
			and ltrim(rtrim(tp)) = ltrim(rtrim(lcomatp))
			and left(ltrim(rtrim(konto)),1) in ('4','5','6') and ltrim(rtrim(konto)) not in ('601000','601001');

		--(esitaja saldoandmik sum (kõik kontod algusega 3, mille TP kood on võrreldava kood (kreedit miinus deebet)))

		insert into tmp_sk_aruanned (omaTp, tp, summa06, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr - db, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) = '3';

		--(esitaja saldoandmik sum (kõik kontod algusega 4-6, mille TP kood on võrreldava kood (deebet miinus kreedit), 
		--välja arvatud kontod 601000 ja 601001, mida ei võeta üldse arvesse, olenemata TP koodist))

		insert into tmp_sk_aruanned (omaTp, tp, summa07, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db-kr, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) in ('4','5','6') and ltrim(rtrim(konto)) not in ('601000','601001');

		--(võrreldava saldoandmik (kõik kontod algusega 3, mille mille TP kood on aruande koostaja kood (kreedit miinus deebet)))
		insert into tmp_sk_aruanned (omaTp, tp, summa08,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr-db, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
			and ltrim(rtrim(tp)) = ltrim(rtrim(lcomatp))
			and left(ltrim(rtrim(konto)),1) = '3';
		--(esitaja saldoandmik sum (kõik kontod algusega 7, mille TP kood on võrreldava kood (deebet miinus kreedit)))
		insert into tmp_sk_aruanned (omaTp, tp, summa09, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db-kr, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) = '7';
		--(võrreldava saldoandmik (kõik kontod algusega 7, mille TP kood on aruande koostaja kood (kreedit miinus deebet)))
		insert into tmp_sk_aruanned (omaTp, tp, summa10,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr-db, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
			and ltrim(rtrim(tp)) = ltrim(rtrim(lcomatp))
			and left(ltrim(rtrim(konto)),1) = '7';

		--(esitaja saldoandmik sum (kõik kontod algusega 1 kuni 7, mille TP kood on võrreldava kood (deebet miinus kreedit) 
		-- välja arvatud kontod 601000 ja 601001, mida ei võeta üldse arvesse olenemata TP koodist))

		insert into tmp_sk_aruanned (omaTp, tp, summa11, kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), db-kr, tdKpv, tnRekvId, lcreturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(lcomatp))
			and ltrim(rtrim(tp)) = ltrim(rtrim(v_tp.tp))
			and left(ltrim(rtrim(konto)),1) in ('1','2','3','4','5','6','7') and ltrim(rtrim(konto)) not in ('601000','601001');
		--(võrreldava saldoandmik (kõik kontod algusega 1-7, mille TP kood on aruande koostaja kood (kreedit miinus deebet) 
		--välja arvatud kontod 601000 ja 601001, mida ei võeta üldse arvesse olenemata TP koodist))
		insert into tmp_sk_aruanned (omaTp, tp, summa12,  kpv, rekvid, timestamp, tyyp) 
			select ltrim(rtrim(lcomatp)), ltrim(rtrim(v_tp.tp)), kr-db, tdKpv, tnRekvId,lcReturn, 0 from saldoandmik 
			where aasta = year(tdKpv) and kuu = month(tdKpv) 
			and ltrim(rtrim(omatp)) = ltrim(rtrim(v_tp.tp)) 
			and ltrim(rtrim(tp)) = ltrim(rtrim(lcomatp))
			and left(ltrim(rtrim(konto)),1) in ('1','2','3','4','5','6','7') and ltrim(rtrim(konto)) not in ('601000','601001');

	end loop;
	-- Teeme kond

	insert into tmp_sk_aruanned (omaTp, tp, summa01, summa02, summa03,summa04,summa05, summa06, kpv, rekvid, timestamp, tyyp) 
		select omaTp, tp, sum(summa01-summa02), sum(summa03-summa04),sum(summa05-summa06), sum(summa07-summa08),sum(summa09-summa10),sum(summa11-summa12),
			Kpv, RekvId,timestamp,1 from tmp_sk_aruanned 
			where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcReturn))
			and tyyp = 0
			group by omatp, tp, kpv, rekvid, timestamp
			order by omatp, tp, kpv, rekvid;

	delete from tmp_sk_aruanned where ltrim(rtrim(timestamp)) = ltrim(rtrim(lcReturn)) and tyyp = 0;


	end loop;

end if;


RETURN lcReturn;


end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_saldoandmik_aruanned(integer, date, integer, integer, integer, integer) TO saldoandmikkoostaja;
