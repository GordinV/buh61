/*
select  sp_eelarve_aruanne4(63, date(2013,09,30), '%', '%', '%', 1, 1, 1)

select kood5,nimetus, summa1, summa2, tunnus from tmp_eelproj_aruanne1 where timestamp = '201401205953984KOKKU'
and kood5 like ('382%') 
and summa2 <> 0
order by abs(summa2)

4633868.150000;4633868.150000
-2757243.000000;10041086.560000
1876625.150000;5407218.410000


4633868.150000;4633868.150000
-2757243.000000;10041086.560000
1876625.150000;5407218.410000


	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 in ('2580','2585','2586') ;


select * from curJournal where left(kreedit,3) in ('208','258') and kood3 = '05' and rekvid = 63

select sum(summa) from (
select sum(summa) as summa from curJournal where 
rekvid in (select id from rekv where id = 63 ) 
and deebet like '100%'  and kood5 = '3502' and kpv >= date(2013,01,01) and kpv <= date(2013,09,30)
union all
select sum(summa) as summa from curJournal where 
rekvid in (select id from rekv where id = 63 ) 
and deebet like '999999%' and kood5 = '3502' and kpv >= date(2013,01,01) and kpv <= date(2013,09,30)
union all
select sum( -1 * summa) as summa from curJournal where 
rekvid in (select id from rekv where id = 63 ) 
and deebet like '710000%'  and kpv >= date(2013,01,01) and kpv <= date(2013,09,30)

) qry

select * from rekv where id = 28 or parentid = 28

select * from curJournal where rekvid in (select id from rekv where id = 63) 
and (deebet like '100%' or deebet like '9%') and kood5 = '3500'

select * from curJournal where rekvid in (select id from rekv where id = 63) 
and (deebet like '710000%') and kood5 = '3500'

 or deebet like '100%' or deebet like '9%') and kood5 = '3500' and kpv >= date(2013,01,01) and kpv <= date(2013,09,30)

select sum(summa) as summa from curJournal where (kreedit like '208%' or kreedit like '258%') and kpv < date(2013,01,01)


select * from curJournal where kood5 in ('1501', '1502', '1512', '1511', '1532', '1531')


select deebet, kreedit, summa, kpv from curJournal where (deebet = '100080' or kreedit = '100080') 
and rekvid in (28, 127, 128, 129)

select * from aa 
where tp = '18510107'

select EXTRACT (MONTH FROM now())

select * from curJournal where number = 9963 and rekvid = 29

*/

CREATE OR REPLACE FUNCTION sp_eelarve_aruanne4(integer, date, character varying, character varying, character varying, integer, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE 

	tnrekvid alias for $1;
	tdKpv alias for $2;
	tcAllikas alias for $3;
	tcTegev alias for $4;
	tcEelarve alias for $5;
	tnTapsestatud alias for $6;
	tnSvod alias for $7;
	tnEl alias for $8;

	lcReturn varchar;
	lcString varchar;

	v_eelaruanne record;
	lnTase integer;
	lnSumma1 numeric(18,6);
	lnSumma2 numeric(18,6);
	lnSumma3 numeric(18,6);
	lnSummaK1 numeric(18,6);
	lnSummaK2 numeric(18,6);

begin

delete from tmp_eelproj_aruanne1 where kpv < date() and rekvid = tnrekvId;

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

if tnSvod = 1 then
	lnTase = 3;

else
	lnTase = 9;
end if;
lcreturn := to_char(now(), 'YYYYMMDDMISSSS');

-- salvestame eelarve (art loikes) kooskolastatud (TULUD)
	insert into tmp_eelproj_aruanne1 (allasutus,kood5, nimetus, summa1, timestamp, kpv, rekvid, tunnus)
		select  'salvestame eelarve (art loikes) kooskolastatud (TULUD)',kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid, '001'+ltrim(rtrim(kood4))::varchar(20)
			from eelarve 
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1 )					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where tunnus = 0
			and aasta = year(tdKpv)
			and (eelarve.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  eelarve.rekvid = tnRekvId)
			and eelarve.kood1 like tcTegev
			and eelarve.kood2 like tcAllikas
			and eelarve.kood4 like tcEelarve  
			group by kood4, library.nimetus;

-- salvestame eelarve (art loikes) kooskolastatud (KULUD)
	insert into tmp_eelproj_aruanne1 (allasutus, kood5, nimetus, summa1, timestamp, kpv, rekvid, tunnus)
		select  'salvestame eelarve (art loikes) kooskolastatud (KULUD)',kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(-1* summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid, '010'+(ltrim(rtrim(kood4)))::varchar(20)
			from eelarve 
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where tunnus = 0
			and aasta = year(tdKpv)
			and (eelarve.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  eelarve.rekvid = tnRekvId)
			and eelarve.kood1 like tcTegev
			and eelarve.kood2 like tcAllikas
			and eelarve.kood4 like tcEelarve 
			group by kood4, library.nimetus;

-- salvestame eelarve (tegev.loikes) kooskolastatud
	insert into tmp_eelproj_aruanne1 (allasutus, kood1, nimetus, summa1, timestamp, kpv, rekvid, tunnus)
		select  'salvestame eelarve (tegev.loikes) kooskolastatud',kood1, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid,'100'+ltrim(rtrim(kood1))::varchar(20)
			from eelarve 
			left outer join library on (library.kood = eelarve.kood1 and library.library = 'TEGEV')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where tunnus = 0
			and aasta = year(tdKpv)
			and (eelarve.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  eelarve.rekvid = tnRekvId)
			and eelarve.kood4 in (select kood from library where library = 'TULUDEALLIKAD' and library.tun5 = 2)
			and eelarve.kood4 not in ('2585','2586')
			and eelarve.kood1 like tcTegev
			and eelarve.kood2 like tcAllikas
			and eelarve.kood4 like tcEelarve 
			group by kood1, library.nimetus;


if tnTapsestatud > 0 then
-- salvestame eelarve (art loikes) tapsestatud eelarve (tulud)
	insert into tmp_eelproj_aruanne1 (kood5, nimetus, summa1, timestamp, kpv, rekvid, tunnus)
		select  kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid,'001'+(ltrim(rtrim(kood4)))::varchar(20)
			from eelarve 
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1)					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where tunnus = 1 and kpv <= tdKpv
			and aasta = year(tdKpv)
			and (eelarve.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  eelarve.rekvid = tnRekvId)
			and eelarve.kood1 like tcTegev
			and eelarve.kood2 like tcAllikas
			and eelarve.kood4 like tcEelarve 
			group by kood4, library.nimetus;

-- salvestame eelarve (art loikes) tapsestatud eelarve (kulud)
	insert into tmp_eelproj_aruanne1 (kood5, nimetus, summa1, timestamp, kpv, rekvid, tunnus)
		select  kood4, ifnull(library.nimetus,space(254)) as nimetus, -1* sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid,'010'+(ltrim(rtrim(kood4)))::varchar(20)
			from eelarve 
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where tunnus = 1 and kpv <= tdKpv
			and aasta = year(tdKpv)
			and (eelarve.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  eelarve.rekvid = tnRekvId)
			and eelarve.kood1 like tcTegev
			and eelarve.kood2 like tcAllikas
			and eelarve.kood4 like tcEelarve 
			group by kood4, library.nimetus;

-- salvestame eelarve (tegev loikes) tapsestatud eelarve

	insert into tmp_eelproj_aruanne1 (kood1, nimetus, summa1, timestamp, kpv, rekvid, tunnus)
		select  kood1, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid,'100'+rtrim(ltrim(kood1))::varchar(20)
			from eelarve 
			left outer join library on (library.kood = eelarve.kood1 and library.library = 'TEGEV')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where tunnus = 1 and kpv <= tdKpv
			and aasta = year(tdKpv)
			and (eelarve.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  eelarve.rekvid = tnRekvId)
			and eelarve.kood4 in (select kood from library where library = 'TULUDEALLIKAD' and library.tun5 = 2)
			and eelarve.kood4 not in ('2585','2586')
			and eelarve.kood1 like tcTegev
			and eelarve.kood2 like tcAllikas
			and eelarve.kood4 like tcEelarve 
			group by kood1, library.nimetus;

end if;



-- kassatulud (art.jargi), tulud
	insert into tmp_eelproj_aruanne1 (allasutus, kood5, nimetus, summa2, timestamp, kpv, rekvid, tunnus, rekvidsub)
		select 'kassatulud (art.jargi), tulud',kassatulu.kood,ifnull(library.nimetus,space(254)) as nimetus, sum(summa) as summa,
			lcReturn, date(), tnRekvid,'001'+(ltrim(rtrim(kassatulu.kood)))::varchar(20), kassatulu.rekvid
				from (
				SELECT journal.rekvid, sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood5 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				JOIN kassatulud ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
				where journal.kpv <= tdKpv and year(journal.kpv) = year(tdKpv) and not empty (journal1.kood5) 
				and journal1.kood1 like tcTegev
				and journal1.kood2 like tcAllikas
				and journal1.kood5 like tcEelarve 
				GROUP BY journal.rekvid, journal1.kood5) kassatulu
			inner join library on (library.kood = kassatulu.kood and library.library = 'TULUDEALLIKAD' and tun5 = 1)
			where (kassatulu.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  kassatulu.rekvid = tnRekvId)
			group by  kassatulu.kood, nimetus,kassatulu.rekvid ;

-- kassatulud (art.jargi) miinus
	insert into tmp_eelproj_aruanne1 (allasutus, kood5, nimetus, summa2, timestamp, kpv, rekvid, tunnus, rekvidsub)
		select 'kassakulud (art.jargi) miinus',kassakulu.kood,ifnull(library.nimetus,space(254)) as nimetus, -1* sum(summa) as summa,
			lcReturn, date(), tnRekvid,'010'+(ltrim(rtrim(kassakulu.kood)))::varchar(20), kassakulu.rekvid
				from (
				SELECT journal.rekvid, sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood5 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				JOIN kassakulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
				where journal.kpv <= tdKpv and year(journal.kpv) = year(tdKpv) and not empty (journal1.kood5) 
				and journal1.kood1 like tcTegev
				and journal1.kood2 like tcAllikas
				and journal1.kood5 like tcEelarve 
				GROUP BY journal.rekvid, journal1.kood5) kassakulu
			inner join library on (library.kood = kassakulu.kood and library.library = 'TULUDEALLIKAD' and tun5 = 1)
			where (kassakulu.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  kassakulu.rekvid = tnRekvId)
			group by kassakulu.kood, nimetus, kassakulu.rekvid;



-- kassakulud (art.jargi), kulud
	insert into tmp_eelproj_aruanne1 (allasutus, kood5, nimetus, summa2, timestamp, kpv, rekvid, tunnus, rekvidsub)
		select 'kassakulud (art.jargi), kulud',kassakulu.kood,ifnull(library.nimetus,space(254)) as nimetus, -1* sum(summa) as summa,
			lcReturn, date(), tnRekvid,'010'+(ltrim(rtrim(kassakulu.kood)))::varchar(20), kassakulu.rekvid
				from (
				SELECT journal.rekvid, sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood5 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				JOIN kassakulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
				where journal.kpv <= tdKpv and year(journal.kpv) = year(tdKpv) and not empty (journal1.kood5) 
				and journal1.kood1 like tcTegev
				and journal1.kood2 like tcAllikas
				and journal1.kood5 like tcEelarve 
				GROUP BY journal.rekvid, journal1.kood5) kassakulu
			inner join library on (library.kood = kassakulu.kood and library.library = 'TULUDEALLIKAD' and tun5 = 2)
			where (kassakulu.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  kassakulu.rekvid = tnRekvId)
			group by kassakulu.kood, nimetus, kassakulu.rekvid;


-- kassatulud (art.jargi), kulud
	insert into tmp_eelproj_aruanne1 (allasutus, kood5, nimetus, summa2, timestamp, kpv, rekvid, tunnus, rekvidsub)
		select 'kassatulud (art.jargi), tulud',kassatulu.kood,ifnull(library.nimetus,space(254)) as nimetus, -1*sum(summa) as summa,
			lcReturn, date(), tnRekvid,'001'+(ltrim(rtrim(kassatulu.kood)))::varchar(20), kassatulu.rekvid
				from (
				SELECT journal.rekvid, sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood5 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				JOIN kassatulud ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
				where journal.kpv <= tdKpv and year(journal.kpv) = year(tdKpv) and not empty (journal1.kood5) 
				and journal1.kood1 like tcTegev
				and journal1.kood2 like tcAllikas
				and journal1.kood5 like tcEelarve 
				GROUP BY journal.rekvid, journal1.kood5) kassatulu
			inner join library on (library.kood = kassatulu.kood and library.library = 'TULUDEALLIKAD' and tun5 = 2)
			where (kassatulu.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  kassatulu.rekvid = tnRekvId)
			group by kassatulu.kood, nimetus, kassatulu.rekvid;


-- kassakulud (tegev.jargi)
	insert into tmp_eelproj_aruanne1 (kood1, nimetus, summa2, timestamp, kpv, rekvid, tunnus)
		select kassakulud.kood,ifnull(library.nimetus,space(254)) as nimetus, sum(summa) as summa,
			lcReturn, date(), tnRekvid,'100'+ltrim(rtrim(kassakulud.kood))::varchar(20)
				from (
				SELECT journal.rekvid, sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood1 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				JOIN kassakulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
				where journal.kpv <= tdKpv and year(journal.kpv) = year(tdKpv) and not empty (journal1.kood1)
				and journal1.kood5 in (select kood from library where library = 'TULUDEALLIKAD' and tun5 = 2) 
				and journal1.kood5 not in ('2586','2585')
				and journal1.kood1 like tcTegev
				and journal1.kood2 like tcAllikas
				and journal1.kood5 like tcEelarve 
				GROUP BY journal.rekvid, journal1.kood1) kassakulud
			inner join library on (library.kood = kassakulud.kood and library.library = 'TEGEV')
			where (kassakulud.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  kassakulud.rekvid = tnRekvId)
			group by kassakulud.kood, nimetus;

/*
if tnsvod = 1 and tnrekvid = 63 then
	delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and kood5 in ('3044', '3045') and ifnull(rekvidsub,0) = 63;
end if;
*/


if not empty(tnEl) then
	lnSumma3 = 0;
	lnSumma2 = 0;
	raise notice 'start 3500';
		select sum(summa) into lnSumma2 from ( 
			select summa from journal inner join journal1 on journal.id = journal1.parentid
				where (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
				and (left(journal1.deebet,3) = '100' or left(journal1.deebet,6) = '999999' ) and (left(journal1.kood5 ,4) = '3500') 
				and year(kpv) = year(kpv) and journal.kpv <= tdKpv 
			union all
			select -1 * summa from journal inner join journal1 on journal.id = journal1.parentid
				where (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
				and (left(journal1.deebet,6) = '710000' ) and (left(journal1.kood5 ,4) = '3500') 
				and year(kpv) = year(kpv) and journal.kpv <= tdKpv 
			
			) qry;

		raise notice '3500 lnSumma2  %',lnSumma2;
		
	if tnrekvid = 63 then

		select sum(summa) into lnSumma3 from (
		select sum(summa) as summa
			from journal inner join journal1 on journal.id = journal1.parentid
			where rekvid = tnrekvid and left(journal1.deebet,6) = '710000'  and year(kpv) = year(tdKpv) and journal.kpv <= tdKpv
		union all
		select sum(-1 * summa) as summa
			from journal inner join journal1 on journal.id = journal1.parentid
			where rekvid = tnrekvid and left(journal1.kreedit,6) = '710000'  and year(kpv) = year(tdKpv) and journal.kpv <= tdKpv) qry;

--		raise notice 'lnSumma1 %',lnSumma1;
	else
		lnSumma3 = 0;
	end if;	
		raise notice '3500 lnSumma2  %, lnSumma3 %',lnSumma2, lnSumma3;
	
	lnSumma2 =  ifnull(lnSumma2,0) + -1 * ifnull(lnSumma3,0);


	
	/*
		select sum(summa) into lnSumma2 
			from journal inner join journal1 on journal.id = journal1.parentid
			where rekvid = tnrekvid and left(journal1.deebet,3) = '100' and left(kreedit,6) = '710000' and year(kpv) = year(tdKpv) and journal.kpv <= tdKpv;

		raise notice 'lnSumma2 %',lnSumma2;

			

		raise notice '3500 lnSumma3 %',lnSumma3;

		lnSumma2 = -1 * (ifnull(lnSumma1,0) -ifnull(lnSumma2,0) - ifnull(lnSumma3,0));
--		lnSumma1 = (ifnull(lnSumma1,0) -ifnull(lnSumma2,0) - ifnull(lnSumma3,0));
		raise notice '3500 lnSumma1 %',lnSumma2;

		if tnSvod = 1 then
			-- lisame teiste osakonn tulud
			select sum(summa2) into lnSummaK1 
				from tmp_eelproj_aruanne1 
				where timestamp = lcreturn
				and ltrim(rtrim(kood5)) like '3500%';

			raise notice '3500 kond summa lnSummaK1 %',lnSummaK1;
				
			lnSumma1 = lnSumma1 + ifnull(lnSummak1,0);
		end if;
		-- J.Tsekanina
		select sum(summa2) into lnSumma2 
			from tmp_eelproj_aruanne1 
			where timestamp = lcreturn
			and ltrim(rtrim(kood5)) like '352%'
			and ltrim(rtrim(kood5)) not in ('35200','35201');

			and journal.rekvid <> 63


	else
		lnSumma2 = lnSumma3;
	
	end if;	-- svod
*/

	select sum(summa1) INTO lnSumma1 from tmp_eelproj_aruanne1
		where  timestamp = lcreturn
		and (kood5 = '3500');

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 = '3500';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','3500','Muud saadud toetused tegevuskuludeks',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0013500'::varchar);

	-- arvestan 2585

	select sum(summa1) into lnSumma1 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '2585%';	


	select sum(summa) into lnsumma2 
		from curJournal where left(kreedit,3) in ('208','258') and kood3 = '05' 
		and (curJournal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or curJournal.rekvid = tnRekvId);
		
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '2585%';


	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','2585','Kohustuste võtmine',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0012585'::varchar);

	-- arvestan 2586

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '2586%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '2586%';


	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','2586','Kohustuste tasumine',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0012586'::varchar);

-- Parandus. J.tsekanina, 31.10
--1501, 1502, 1512, 1511, 1532, 1531. 

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '1501%';	

	delete from tmp_eelproj_aruanne1 where kood5 like '1501%' and  timestamp = lcreturn;

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','1501','Põhivara soetus',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'00115'::varchar);

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '1502%';	

	delete from tmp_eelproj_aruanne1 where kood5 like '1502%' and  timestamp = lcreturn;

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','1502','Osalused tütar- ja sidusettevõtjates ',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'00115'::varchar);

	raise notice '1502 lnSumma1 %, lnSumma2 %',lnSumma1, lnSumma2;

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '1512%';	

	delete from tmp_eelproj_aruanne1 where kood5 like '1512%' and  timestamp = lcreturn;

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','1512','Tähtajani hoitavad võlakirjad ',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'00115'::varchar);

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '1511%';	

	delete from tmp_eelproj_aruanne1 where kood5 like '1511%' and  timestamp = lcreturn;

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','1511','Investeerimisportfelli väärtpaberid ',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'00115'::varchar);


	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '1532%';	

	delete from tmp_eelproj_aruanne1 where kood5 like '1532%' and  timestamp = lcreturn;

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','1532','Laenu- ja liisingnõuete pikaajaline osa ',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'00115'::varchar);

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '1531%';	

	delete from tmp_eelproj_aruanne1 where kood5 like '1531%' and  timestamp = lcreturn;

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','1531','Nõuded ostjate vastu ',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'00115'::varchar);


	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '15%' and kood5 not in ('1501', '1502', '1512', '1511', '1532', '1531');	

	delete from tmp_eelproj_aruanne1 where kood5 like '15%' and kood5 not in ('1501', '1502', '1512', '1511', '1532', '1531') and  timestamp = lcreturn;

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','15','Põhivara soetus.',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'00115'::varchar);


	-- arvestan 3044

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '3044%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '3044%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','3044','Reklaamimaks',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0013044'::varchar);

	-- arvestan 3045

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '3045%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '3045%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','3045','Teede ja tänavate sulgemise maks',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0013045'::varchar);
	-- arvestan 32

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '32%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '32%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','32','Tulud kaupade ja teenuste muugist',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'00132'::varchar);


	-- arvestan 3502

	select sum(summa1) into lnSumma1 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '3502%';	

	raise notice 'start 3502';
		select sum(summa) into lnSumma2 from ( 
			select summa from journal inner join journal1 on journal.id = journal1.parentid
				where (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
				and (left(journal1.deebet,3) = '100' or left(journal1.deebet,6) = '999999' ) and (left(journal1.kood5 ,4) = '3502') 
				and year(kpv) = year(kpv) and journal.kpv <= tdKpv 
			union all
			select -1 * summa from journal inner join journal1 on journal.id = journal1.parentid
				where (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
				and (left(journal1.deebet,6) = '710000' ) and (left(journal1.kood5 ,4) = '3502') 
				and year(kpv) = year(kpv) and journal.kpv <= tdKpv 
			
			) qry;

		raise notice '3500 lnSumma3  %',lnSumma3;

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '3502%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','3502','Põhivara soetuseks saadav sihtfinantseerimine',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0013502'::varchar);


	
	-- arvestan 352

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '352%';	

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','352','Mittesihtotstarbelised toetused',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'001352'::varchar);


	-- arvestan 381

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and (kood5 like '381%') and kood5 <> '3818';	


	-- 3818
	lnSummaK1 = 0;
	lnSummaK2 = 0;
	select sum(summa1), sum(summa2) into lnSummaK1, lnSummaK2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '3818%' ;

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '381%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','381','Põhivara müük',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'001381'::varchar);

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','3818','Kasum/kahjum varude müügist  ',ifnull(lnsummaK1,0), ifnull(lnsummaK2,0),lcreturn,date(),tnrekvId,'022'); 

/*	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','3811','Põhivara müük',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'001381'::varchar);
*/
	-- arvestan 382

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '382%' and kood5 <> '38254';	

	-- 38254
	lnSummaK1 = 0;
	lnSummaK2 = 0;
	select sum(summa1), sum(summa2) into lnSummaK1, lnSummaK2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '38254%' ;


	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '382%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','38254','Laekumine vee erikasutusest   ',ifnull(lnsummaK1,0), ifnull(lnsummaK2,0),lcreturn,date(),tnrekvId,'022'); 

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','382','Tulud varude müügist',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'001382'::varchar);


	-- arvestan 3880

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '3880%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '3880%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','3880','Muud tulud varadelt',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0013880'::varchar);

	-- arvestan 3888

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '3888%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '3888%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','3888','Muud tulud',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0013888'::varchar);

	-- arvestan 413

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '413%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '413%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','413','Sotsiaalabitoetused ja muud toetused füüsilistele isikuteled',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'001413'::varchar);

	-- arvestan 4500

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '4500%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '4500%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','4500','Sotsiaalabitoetused ja muud toetused füüsilistele isikuteled',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0014500'::varchar);


	-- arvestan 4502

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '4502%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '4502%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','4502','Sotsiaalabitoetused ja muud toetused füüsilistele isikuteled',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0014502'::varchar);

	-- arvestan 452

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '452%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '452%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','452','Sotsiaalabitoetused ja muud toetused füüsilistele isikuteled',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'001452'::varchar);

	-- arvestan 50

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '50%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '50%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','50','Tööjõukulud',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'00150'::varchar);


	-- arvestan 55

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '55%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '55%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','55','Majandamiskulud',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'00155'::varchar);

	-- arvestan 60

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '60%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '60%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','60','Muud kulud',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'00160'::varchar);

	-- arvestan 650

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '650%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '650%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','650','Finantstkulud',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'001650'::varchar);

	-- arvestan 655

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn
	and kood5 like '655%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '655%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','655','Finantstulud',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'001655'::varchar);


-- 100
-- label

--LIKVIIDSETE VARADE MUUTUS (+ suurenemine, - vähenemine)
---	select summa1, summa2 into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
--	where timestamp = lcReturn 
--	and ltrim(rtrim(kood5)) in ('2586','2585') and ltrim(rtrim(tunnus)) in ('0210','0211')  ;
lnSumma1 = 0;
lnSumma2 = 0;

-- muudame + -> -
	update tmp_eelproj_aruanne1 set summa1 = -1 * summa1 where timestamp = lcReturn and kood5 = '1001.';

/*
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '100%' ;

*/
-- saldo seisuga 31.12.2012
	select sum(summa) into lnSumma1 from (
		select sum(summa) as summa 
			from curJournal c 
			where deebet like '100%' and kpv <= date(year(tdkpv)-1,12,31) 
			and deebet not like '100080%'
			and (c.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  c.rekvid = tnRekvId)
		union all
		select -1* sum(summa) as summa 
			from curJournal c
			where kreedit like '100%' 
			and kreedit not like '100080%'
			and kpv <= date(year(kpv)-1,12,31)
			and (c.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  c.rekvid = tnRekvId)
			) qry;

	select sum(summa1) into lnSummak1 from 	tmp_eelproj_aruanne1 where timestamp = lcReturn and kood5 like '1000%';	

	delete from tmp_eelproj_aruanne1 where kood5 like '1000%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','1000','Saldo seisuga'+date(year(tdkpv)-1,12,31)::text,ifnull(lnSumma1,0), ifnull(lnsumma1,0),lcreturn,date(),tnrekvId,'0011000'); 

-- saldo seisuga tdKpv
	select sum(summa) into lnSumma2 from (
		select sum(summa) as summa 
			from curJournal c 
			where deebet like '100%' and kpv <= tdKpv 
			and deebet not like '100080%'
			and (c.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  c.rekvid = tnRekvId)
		union all
		select -1* sum(summa) as summa 
			from curJournal c
			where kreedit like '100%' 
			and kreedit not like '100080%'
			and kpv <= tdKpv
			and (c.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  c.rekvid = tnRekvId)
			) qry;

	select sum(summa1) into lnSummak1 from 	tmp_eelproj_aruanne1 where timestamp = lcReturn and kood5 like '1001%';	

	delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and kood5 like '1001%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','1001','Saldo seisuga '+tdkpv::text,ifnull(lnSummaK1,0), ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0011001'); 

-- parandame rea '100.
	select sum(summa1) into lnSummaK1 from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '100%';

--	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 == '100';

	lnSumma2 = ifnull(lnSumma2,0) - ifnull(lnSumma1,0);
	
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','100','Likviidsete varade muutus (+ suurenemine, - vahenemine)'+tdkpv::text, ifnull(lnsummaK1,0), ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'001100'); 
	

	
--	update tmp_eelproj_aruanne1 set kood5 = '100' , summa2 = lnSumma2, tunnus = '0011001' where timestamp = lcreturn and kood5 like '1001.%';

	select summa2 into lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 ='100';
	raise notice 'Kontrol 100 1 %',lnSumma2;


-- 2580
	select sum(summa) into lnSumma1 from curJournal
	where kpv < date(year(tdKpv),01,01)
	and (kreedit like '208%' or kreedit like '258%') 
	and (curJournal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  curJournal.rekvid = tnRekvId);

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','2580','Emiteeritud võlakirjad  ',ifnull(lnsumma1,0), ifnull(lnsumma1,0),lcreturn,date(),tnrekvId,'022'); 

-- 2581
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 in ('2580','2585','2586') ;

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','2581','Laenud  ',ifnull(lnsumma1,0), ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'022'); 
end if;




if empty(tnEl) then
	select sum(summa1),sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
			where  timestamp = lcreturn
				and left(ltrim(rtrim(kood5)),2)='30';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','30','Maksutulud',ifnull(lnsumma1,0),ifnull(lnsumma2,0), lcreturn,date(),tnrekvId,'00130'); 

	select sum(summa1),sum(summa2) INTO lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
				where  timestamp = lcreturn
				and kood5 like '32%' and ltrim(rtrim(kood5)) <> '32';


	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus) values
		('','32','Tulud kaupade ja teenuste muugist',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'00132'::varchar );

		delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and kood5 like '32%' and kood5 <> '32'; 		


--rea 3500,352
	if tnrekvid = 63 then

		select sum(summa) into lnSumma1
			from journal inner join journal1 on journal.id = journal1.parentid
			where rekvid = tnrekvid and left(journal1.deebet,6) = '710000'  and year(kpv) = year(tdKpv) and journal.kpv <= tdKpv;

		raise notice 'lnSumma1 %',lnSumma1;
		
		select sum(summa) into lnSumma2 
			from journal inner join journal1 on journal.id = journal1.parentid
			where rekvid = tnrekvid and left(journal1.deebet,3) = '100' and left(kreedit,6) = '710000' and year(kpv) = year(tdKpv) and journal.kpv <= tdKpv;

		raise notice 'lnSumma2 %',lnSumma2;

			
		select sum(summa) into lnSumma3 from journal inner join journal1 on journal.id = journal1.parentid
			where rekvid = tnrekvid and left(journal1.deebet,3) = '100' and journal1.kood5 = '3500' and year(kpv) = year(kpv) and journal.kpv <= tdKpv;

		raise notice 'lnSumma3 %',lnSumma3;

		lnSumma1 = -1 * (ifnull(lnSumma1,0) -ifnull(lnSumma2,0) - ifnull(lnSumma3,0));
--		lnSumma1 = (ifnull(lnSumma1,0) -ifnull(lnSumma2,0) - ifnull(lnSumma3,0));
		raise notice 'lnSumma1 %',lnSumma1;

		select sum(summa2) into lnSumma2 
			from tmp_eelproj_aruanne1 
			where timestamp = lcreturn
			and ltrim(rtrim(kood5)) like '352%'
			and ltrim(rtrim(kood5)) not in ('35200','35201');

		lnSumma2 = lnSumma1+ifnull(lnSumma2,0);
	else
		select  sum(summa*kuurs) into lnSumma2 
			from curJournal
			where  year(kpv) = year(tdKpv) and kpv <= tdKpv
			and (rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  rekvid = tnRekvId)
		and kood1 like tcTegev
		and kood2 like tcAllikas
		and kood5 like '3500%'  
		and deebet like '100%';
	
	end if;	-- svod
	
	select sum(summa1) INTO lnSumma1 from tmp_eelproj_aruanne1
		where  timestamp = lcreturn
		and (kood5 = '3500' or kood5 like '352%')
		and kood5 not in ('35200','35201') ;


	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values ( '','3500;352','Muud saadud toetused tegevuskuludeks',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0013521'::varchar);

		select sum(summa1),sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
				where  timestamp = lcreturn
				and ltrim(rtrim(kood5)) in ('352.00.17.1','352.00.17.2','35200','35201','3500;352');

raise notice 'Saadavad toetused tegevuskuludeks';
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','3520','Saadavad toetused tegevuskuludeks',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'001352');	
/*
		select sum(summa1),sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
				where  timestamp = lcreturn
				and ltrim(rtrim(kood5)) in ('352.00.17.1','35200');
*/
		select sum(summa1),sum(summa2) INTO lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
				where  timestamp = lcreturn
				and ltrim(rtrim(kood5)) IN ('3880','3823','3818','3888'); 

--Kokku: 3880+3823+3818+3888
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','382.388','Muud tegevustulud ',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0013899');
		
	select sum(summa1),sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
				where  timestamp = lcreturn
				and kood5 in ('38250','38251','38252','38254','3882', '3880','3823','3818','3888');
-- 38250+38251+38252+38254+3882+3880+3823+3818+3888		
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','3825;3882','Muud tegevustulud ',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'00138');
		

-- kondid
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
				where kood5 in ('30','32','3520','3825;3882') and timestamp = lcreturn;

	lnSumma1 = ifnull(lnSumma1,0);
	lnSumma2 = ifnull(lnSumma2,0);
				
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
	values ('','','POHITEGEVUSE TULUD KOKKU',lnSumma1,lnSumma2, lcreturn,date(),tnrekvId,'0');


--PÕHITEGEVUSE KULUD KOKKU

	lnSummaK1 = ifnull(lnSumma1,0);
	lnSummaK2 = ifnull(lnSumma2,0);
/*
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
				where  timestamp = lcreturn
				and kood5 like '40%'; 
		
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','40','Subsiidiumid ettevõtlusega tegelevatele isikutele ',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'010');
*/
	lnSummaK1 = lnSummaK1 + ifnull(lnSumma1,0);
	lnSummaK2 = lnSummaK2 + ifnull(lnSumma2,0);

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 
				where  timestamp = lcreturn
				and ltrim(rtrim(kood5)) like '413%'; 
				
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','413','Sotsiaalabitoetused ja muud toetused füüsilistele isikutele ',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'010'); 
	lnSummaK1 = lnSummaK1 + ifnull(lnSumma1,0);
	lnSummaK2 = lnSummaK2 + ifnull(lnSumma2,0);

	delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and kood5 like '40%' and ltrim(rtrim(kood5)) <> '40';
	delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and kood5 like '413%' and ltrim(rtrim(kood5)) <> '413';

-- Sihtotstarbelised toetused tegevuskuludeks
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 
				where  timestamp = lcreturn
				and ltrim(rtrim(kood5)) like '4500%'; 
	delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and kood5 like '4500%';
				
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','4500','Sihtotstarbelised toetused tegevuskuludeks ',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'010'); 

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 
				where  timestamp = lcreturn
				and ltrim(rtrim(kood5)) like '452%'; 
				
	delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and kood5 like '452%';
				
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','452','Mittesihtotstarbelised toetused ',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'010'); 


	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2
	from tmp_eelproj_aruanne1
	where  timestamp = lcreturn
	and (kood5 like '40%' or kood5 like '413%' or kood5 like '4500%' or kood5 like '452%'); 
				
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','40, 41, 4500, 452','Antud toetused tegevuskuludeks ',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'010');

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 
				where  timestamp = lcreturn
				and left(ltrim(rtrim(kood5)),2) = '50'; 


	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','50','Tööjõukulud',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0111'); 

	lnSummaK1 = lnSummaK1 + ifnull(lnSumma1,0);
	lnSummaK2 = lnSummaK2 + ifnull(lnSumma2,0);

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 
				where  timestamp = lcreturn
				and left(ltrim(rtrim(kood5)),2) = '55'; 

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','55','Majandamiskulud',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0112'); 
	lnSummaK1 = lnSummaK1 + ifnull(lnSumma1,0);
	lnSummaK2 = lnSummaK2 + ifnull(lnSumma2,0);

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 
				where  timestamp = lcreturn
				and left(ltrim(rtrim(kood5)),2) = '60'; 

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','60','Muud kulud',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0113'); 
	lnSummaK1 = lnSummaK1 + ifnull(lnSumma1,0);
	lnSummaK2 = lnSummaK2 + ifnull(lnSumma2,0);


	delete from tmp_eelproj_aruanne1 where timestamp = lcReturn 
		and left(ltrim(rtrim(kood5)),2) in ('50','55','60') 
		and ltrim(rtrim(kood5)) not in  ('50','55','60');


--Muud tegevuskulud
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1 
				where  timestamp = lcreturn
				and kood5 in ('50','55','60') ; 

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','50,55,60','Muud tegevuskulud',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0110'); 
	lnSummaK1 = lnSummaK1 + ifnull(lnSumma1,0);
	lnSummaK2 = lnSummaK2 + ifnull(lnSumma2,0);


	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcreturn
	and kood5 in('40, 41, 4500, 452','50,55,60');
		
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','PÕHITEGEVUSE KULUD KOKKU',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'010'); 

	lnsummaK1 = ifnull(lnsumma1,0);
	lnsummaK2 = ifnull(lnsumma2,0);

	select summa1, summa2 into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn and nimetus = 'POHITEGEVUSE TULUD KOKKU';
	
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','PÕHITEGEVUSE TULEM',ifnull(lnsumma1,0) + ifnull(lnsummaK1,0),ifnull(lnsumma2,0)+ifnull(lnsummaK2,0),lcreturn,date(),tnrekvId,'015'); 
	
	update tmp_eelproj_aruanne1 set kood5 = space(1) where ifnull(kood5,'null') = 'null' and timestamp = lcreturn; 
	update tmp_eelproj_aruanne1 set kood1 = space(1) where ifnull(kood1,'null') = 'null' and timestamp = lcreturn; 

--Põhivara müük (+)
--Kokku381: 3810+3811+3812+3813+3814

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 IN ('3810','3811','3812','3813','3814');

	delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and ltrim(rtrim(kood5)) in ('3810','3811','3812','3813','3814');


	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','381','Põhivara müük (+)',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0160'); 
--Põhivara soetus (-)
--kokku kõik art 15
	
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '15%';
	lnSumma1 = ifnull(lnsumma1,0);
	lnSumma2 = ifnull(lnsumma2,0);

	raise notice 'kustutan 15 = %',lnsumma2;

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '15%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','15','Põhivara soetus (-)',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'017'); 


--Põhivara soetuseks saadav sihtfinantseerimine(+) 
	select sum(summa1) into lnSumma1 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '3502%';

		select sum(summa) into lnSumma2 from ( 
			select summa from journal inner join journal1 on journal.id = journal1.parentid
				where (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
				and journal.rekvid <> 63
				and (left(journal1.deebet,3) = '100' or left(journal1.deebet,6) = '999999' ) and (left(journal1.kood5 ,4) = '3502') 
				and year(kpv) = year(kpv) and journal.kpv <= tdKpv 
			union all
			select -1 * summa from journal inner join journal1 on journal.id = journal1.parentid
				where (journal.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  journal.rekvid = tnRekvId)
				and journal.rekvid <> 63
				and (left(journal1.deebet,6) = '710000' ) and (left(journal1.kood5 ,4) = '3502') 
				and year(kpv) = year(kpv) and journal.kpv <= tdKpv 
			
			) qry;



	delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and (ltrim(rtrim(kood5)) like '350%' ) 
		and (tunnus <> '0013521' or tunnus <> '001352') and LTRIM(RTRIM(kood5)) <> '3500;352';
	
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','3502','Põhivara soetuseks saadav sihtfinantseerimine(+) ',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'018'); 

-- Parandamine, projekt CO2

	select sum(summa*kuurs) into lnSumma2 
		from curJournal
		where kreedit = '103556' and kood5 like '15%' 
		and year(kpv) = year(tdKpv) and kpv <= tdKpv  
		and (rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  rekvid = tnRekvId)
		and kood1 like tcTegev
		and kood2 like tcAllikas
		and kood5 like tcEelarve;

	lnSumma2 = ifnull(lnsumma2,0);
--	raise notice '15pluus  = %',lnsumma2;

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','15','Põhivara soetus (-)',0,-1*ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'017'); 
/*
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','3502','Põhivara soetuseks saadav sihtfinantseerimine(+) ',0,ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'018'); 
*/
		
--Põhivara soetuseks antav sihtfinantseerimine(-)
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '4502%';

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '4502%';
	
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','4502','Põhivara soetuseks antav sihtfinantseerimine(-) ',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'018'); 		
--Osaluste müük (+)
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '1502%';
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','1502','Osaluste müük (+) ',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'019'); 		
--Osaluste soetus (-)
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '1501%';
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','1501','Osaluste soetus (-) ',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0190'); 
--Muude aktsiate ja osade müük (+)				
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '1512%';
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','1512','Muude aktsiate ja osade müük (+) ',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0191'); 
--Muude aktsiate ja osade soetus (-)
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '1511%';
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','1511','Muude aktsiate ja osade soetus (-)',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0192'); 
--Tagasilaekuvad laenud (+)
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '1532%';
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','1532','Tagasilaekuvad laenud (+)',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0193'); 
--Antavad laenud (-)
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '1531%';
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','1531','Antavad laenud (-)',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0194'); 
--Finantstulud (+)
--Kokku655: 652+655+658
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood5)),3) in ('655','652','658');

--	and (kood5 in ('3820','3820.8','3823')

--	and (kood5 like '652%' or kood5 like '655%' or kood5 like '658%');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','655','Finantstulud (+)',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0200'); 
--Finantstkulud (-)
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '650%';

	delete from  tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 like '650%';
	
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','650','Finantstkulud (-)',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0202'); 

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		select '','','INVESTEERIMISTEGEVUS KOKKU',sum(summa1),sum(summa2),lcreturn,date(),tnrekvId,'016' 
		from tmp_eelproj_aruanne1
		where timestamp = lcReturn
		and left(ltrim(rtrim(tunnus)),3) in('016','017','018','019','020');

		
--EELARVE TULEM (ÜLEJÄÄK (+) / PUUDUJÄÄK (-))
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and (nimetus = 'PÕHITEGEVUSE TULEM' or nimetus = 'INVESTEERIMISTEGEVUS KOKKU');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','EELARVE TULEM (ÜLEJÄÄK (+) / PUUDUJÄÄK (-))',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0210'); 
--Kohustuste võtmine (+)
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '2585%';

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 = '2585';

	raise notice '2585 %',lnsumma1;

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','2585','Kohustuste võtmine (+)',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0210'); 

--Kohustuste tasumine (-)
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '2586%';

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 = '2586';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','2586','Kohustuste tasumine (-)',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0211'); 


--FINANTSEERIMISTEGEVUS
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and ltrim(rtrim(kood5)) in ('2586','2585') and ltrim(rtrim(tunnus)) in ('0210','0211')  ;

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','FINANTSEERIMISTEGEVUS',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0210'); 
--LIKVIIDSETE VARADE MUUTUS (+ suurenemine, - vähenemine)
---	select summa1, summa2 into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
--	where timestamp = lcReturn 
--	and ltrim(rtrim(kood5)) in ('2586','2585') and ltrim(rtrim(tunnus)) in ('0210','0211')  ;
lnSumma1 = 0;
lnSumma2 = 0;
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '100%' ;


-- saldo seisuga 31.12.2012
	select sum(summa) into lnSumma2 from (
		select sum(summa) as summa 
			from curJournal c 
			where deebet like '100%' and kpv <= date(year(tdkpv)-1,12,31) 
			and (c.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  c.rekvid = tnRekvId)
		union all
		select -1* sum(summa) as summa 
			from curJournal c
			where kreedit like '100%' 
			and kpv <= date(year(kpv)-1,12,31)
			and (c.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  c.rekvid = tnRekvId)
			) qry;

-- saldo seisuga tdKpv
	select sum(summa) into lnSummaK2 from (
		select sum(summa) as summa 
			from curJournal c 
			where deebet like '100%' and kpv <= tdKpv 
			and (c.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  c.rekvid = tnRekvId)
		union all
		select -1* sum(summa) as summa 
			from curJournal c
			where kreedit like '100%' 
			and kpv <= tdKpv
			and (c.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  c.rekvid = tnRekvId)
			) qry;

	lnSumma2 = ifnull(lnSumma2,0) - ifnull(lnSummaK2,0);
	raise notice 'LIKVIIDSETE VARADE MUUTUS lnSumma2 %',lnSumma2;

	delete from tmp_eelproj_aruanne1 where 	timestamp = lcReturn  and kood5 like '100%';
	
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','100','LIKVIIDSETE VARADE MUUTUS (+ suurenemine, - vähenemine)',-1*ifnull(lnsumma1,0), ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'022'); 

--NÕUETE JA KOHUSTUSTE SALDODE MUUTUS (tekkepõhise e/a korral) (+/-)

	select  sum(summa2) into  lnSumma1 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and ltrim(rtrim(kood5)) = '100';


	select  sum(summa2) into  lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and (
	nimetus = 'EELARVE TULEM (ÜLEJÄÄK (+) / PUUDUJÄÄK (-))' 
	or nimetus = 'FINANTSEERIMISTEGEVUS'
	);

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','NÕUETE JA KOHUSTUSTE SALDODE MUUTUS (tekkepõhise e/a korral) (+/-)',0,ifnull(lnsumma1,0)- ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'023'); 


	select summa2 into lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 ='100';
	raise notice 'Kontrol 100 2 %',lnSumma2;

-- kustutame ebavajaliku andmed
 delete from tmp_eelproj_aruanne1 
	where timestamp = lcreturn 
	and (
	kood5 in ('1032.1.','1551','20.5','2036', '156','3820')	
	or (kood5 like '3500%' and kood5 <> '3500;352')
	);

	delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and ltrim(rtrim(kood5)) IN ('3880','3823','3818','3888')  
		and LTRIM(RTRIM(kood5)) <> '382.388';

	delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and kood5 IN ('6550','1001.', '6501'); 


--or ltrim(rtrim(kood5)) like '352%'
-- tegevusallad
--PÕHITEGEVUSE KULUDE JA INVESTEERIMISTEGEVUSE VÄLJAMINEKUTE JAOTUS TEGEVUSALADE JÄRGI
--Ülalnimetamata üldised valitsussektori kulud kokku
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and ltrim(rtrim(kood1)) in ('01110','01120','01800'); 

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Ülalnimetamata üldised valitsussektori kulud kokku',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'101'); 

--Üldised valitsussektori teenused

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and (ltrim(rtrim(kood1)) in ('01111','01112','01114','01600','01700')
	or nimetus = 'Ülalnimetamata üldised valitsussektori kulud kokku'); 

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Üldised valitsussektori teenused',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'100'); 

-- kustutame read, mis ei eole vaja



	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and ltrim(kood1) in ('01110','01120','01800');

--Riigikaitse
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '02';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Riigikaitse',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'102'); 
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and left(ltrim(rtrim(kood1)),2) = '02';

--Avalik kord ja julgeolek
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '03';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Avalik kord ja julgeolek',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'103'); 
--	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and left(ltrim(rtrim(kood1)),2) = '02';
--Muu avalik kord ja julgeolek kokku
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood1 in ('03101','03300','03400','03500','03600');

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood1 in ('03101','03300','03400','03500','03600');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '03600','','Muu avalik kord ja julgeolek kokku',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'10003600'); 

--Majandus
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '04';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Majandus',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'104'); 
--Üldmajanduslikud arendusprojektid
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood1 in ('04110','04310','04320','04330','04340','04410','04420','04430','04530','04550','04720','04810','04820','04830','04840','04850','04860','04870');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Üldmajanduslikud arendusprojektid',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'1040'); 
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood1 in ('04110','04310','04320','04330','04340','04410','04420','04430','04530','04550','04720','04810','04820','04830','04840','04850','04860','04870');
--Keskkonnakaitse
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '05';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Keskkonnakaitse',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'105'); 
--Muu keskkonnakaitse
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood1 in ('05500','05600');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Muu keskkonnakaitse',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'1050'); 
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood1 in ('05500','05600');
--Elamu- ja kommunaalmajandus
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '06';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Elamu- ja kommunaalmajandus',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'106'); 
--Tervishoid
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '07'
	and kood1 not in ('07120','07130','07500');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '07','','Tervishoid',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'1061'); 
--Ambulatoorsed teenused 
/*
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),3) = '072';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Ambulatoorsed teenused',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'10007200'); 
		
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and left(ltrim(rtrim(kood1)),3) = '072';
*/
--Haiglateenused
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),3) = '073';

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and left(ltrim(rtrim(kood1)),3) = '073';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '07300','','Haiglateenused',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'10007300'); 
		
--Ülalnimetamata tervishoid kokku
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood1 in ('07120','07130','07500');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Ülalnimetamata tervishoid kokku',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'1074'); 
		
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood1 in ('07120','07130','07500');
-- Vaba aeg, kultuur ja religioon

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '08';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Vaba aeg, kultuur ja religioon',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'1078'); 

--Haridus
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '09';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Haridus',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'1078'); 

--Sotsiaalne kaitse
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '10';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Sotsiaalne kaitse',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'1010'); 
end if;

		select summa2 into lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 ='100';
	raise notice 'Kontrol 100 3 %',lnSumma2;

-- kokkuvote

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
	select kood1, kood5, nimetus, sum(summa1), sum(summa2), left(lcReturn+'KOKKU',20), date(), tnRekvid, tunnus
	from tmp_eelproj_aruanne1
	where timestamp = lcReturn
	group by kood1, kood5, nimetus, tunnus;
-- kustutame ajutised read
	select summa2 into lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 ='100';
	raise notice 'Kontrol 100 %',lnSumma2;

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn ;
	lcReturn = LEFT(lcReturn + 'KOKKU',20);
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and summa1 = 0 and summa2 = 0;

-- parandame null .
	update tmp_eelproj_aruanne1 set kood1 = space(1) where timestamp = lcreturn and ifnull(kood1,'null') = 'null';
	update tmp_eelproj_aruanne1 set kood5 = space(1) where timestamp = lcreturn and ifnull(kood5,'null') = 'null';
		select summa2 into lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 ='100';
	raise notice 'Kontrol 100 %',lnSumma2;


	-- kustutame . koodist
	lcString = '';
	for v_eelaruanne in 
	select kood5 from tmp_eelproj_aruanne1 where timestamp = lcreturn and not empty(kood5) and kood5 like '%.%'
	loop
		lcString = v_eelaruanne.kood5;
		lcString = left(lcString, position('.' in lcString)-1) + substring(lcString from position('.' in lcString) +1 for 5);
		update tmp_eelproj_aruanne1 set kood5 = lcstring where timestamp = lcreturn and kood5 = v_eelaruanne.kood5;
	end loop;
	select summa2 into lnSumma2 from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood5 ='100';
	raise notice 'Kontrol 100 %',lnSumma2;

	-- kustatame (J.tsekanina)
	delete from tmp_eelproj_aruanne1 where kood5 in ('1554','352');


return LCRETURN;

end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sp_eelarve_aruanne4(integer, date, character varying, character varying, character varying, integer, integer, integer)
  OWNER TO vlad;
