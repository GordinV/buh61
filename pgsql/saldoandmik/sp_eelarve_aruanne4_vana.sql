/*
select -1*((d71-k71)-(k70-d70)) from (
select sum(d71) as d71, sum(k71) as k71, sum(k70) as k70, sum(d70) as d70 from (
select sum(summa)  as D71, 0.00 as K71, 0.00 as K70, 0.00 as D70 from curJournal where rekvid = 63 and aasta = 2012 and deebet = '710000'
union all
select 0.00 as d71, sum(summa) as k71, 0.00 as K70, 0.00 as D70 from curJournal where rekvid = 63 and aasta = 2012 and kreedit = '710000'
union all
select 0.00 as d71, 0.00 as k71, sum(summa) as k70, 0.00 as d70 from curJournal where rekvid = 63 and aasta = 2012 and kreedit = '700000'
union all
select 0.00 as d71, 0.00 as k71, 0.00 as k70, sum(summa) as d70 from curJournal where rekvid = 63 and aasta = 2012 and deebet = '700000'
) qry7
) qry4500

select * from aa where arve = 'TP'

select rekvid, sum(summa) from curJournal where deebet like '100%' and kood5 like '3502.92%'  and aasta = 2012 group by rekvid

select * from library where kood like '30%' and library = 'TULUDEALLIKAD'

delete from tmp_eelproj_aruanne1


select rekvid, deebet, sum(summa), kood5 from curJournal 
where  kood5 like '4502.01%' and aasta = 2012 and kreedit like '100%'
group by kood5, deebet, rekvid
order by kood5

and rekvid in (select id from rekv where parentid = 119 or id = 119)


select * from rekv where id in (127,128)


order by kreedit

 select sp_eelarve_aruanne4(63, date(2012,12,31), '%', '%', '%', 1, 1)

select * from library where kood = '40' 


select kood1, kood5, nimetus,sum(summa1/15.6466) as eelarve,sum(summa2/15.6466) as taitmine 
		 from tmp_eelproj_aruanne1 where timestamp = '201303183055824KOKKU'
		 and kood5 like '20.5%'
		 group by kood1,kood5, nimetus
		 order by kood1,kood5

select kood5, summa1, summa2 from tmp_eelproj_aruanne1 where timestamp = '201303181347591KOKKU'
and kood5 like '15%'
		 
select * from eelarve where aasta = 2012 and kood4 = '3502.00'

		

select sum(summa2/15.6466)  from tmp_eelproj_aruanne1 
where timestamp = '201303135657402KOKKU'
		 and (kood5 like '3500%' or kood5 like '32%')


select deebet,sum(summa) from curJournal where kpv >= date(2012,01,01) and kpv <= date(2012,12,31)  
and kood5 like '15%'
and kreedit like '100%'
group by deebet

		 group by kood1,kood5, nimetus

		select kassatulu.kood,ifnull(library.nimetus,space(254)) as nimetus, sum(summa) as summa
				from (
				SELECT journal.rekvid,journal1.deebet, journal1.kreedit, sum(journal1.summa ) AS summa, journal1.kood5 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				where journal.kpv <= date(2012,12,31) and not empty (journal1.kood5) 
				and  kood5 like '15%'
				and kreedit like '100%'
				GROUP BY journal.rekvid, journal1.kood5, journal1.deebet,journal1.kreedit 
				) kassatulu
			inner join library on (library.kood = kassatulu.kood and library.library = 'TULUDEALLIKAD' and tun5 = 2)
			where kassatulu.rekvid = 3
			group by kassatulu.kood, nimetus
			order by kood;

				and and kreedit like '7%'



select kood1,kood5, nimetus, summa1, summa2 from tmp_eelproj_aruanne1 where timestamp = '201303062752058KOKKU' 
order by tunnus, kood1, kood5

select * from kassakulud

and (ltrim(rtrim(kood5)) like '3500%' or ltrim(rtrim(kood5)) like '352%') and tunnus <> '0013521'

*/
CREATE OR REPLACE FUNCTION sp_eelarve_aruanne4(integer, date, character varying, character varying, character varying,  integer, integer)
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

	lcReturn varchar;
	lcString varchar;

	v_eelaruanne record;
	lnTase integer;
	lnSumma1 numeric(18,6);
	lnSumma2 numeric(18,6);
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
	insert into tmp_eelproj_aruanne1 (kood5, nimetus, summa1, timestamp, kpv, rekvid, tunnus)
		select  kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid, '001'+left(ltrim(rtrim(kood4)),3)::varchar(20)
			from eelarve 
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1 and left(library.kood,1) <>'2')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where tunnus = 0
			and aasta = year(tdKpv)
			and (eelarve.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  eelarve.rekvid = tnRekvId)
			and eelarve.kood1 like tcTegev
			and eelarve.kood2 like tcAllikas
			and eelarve.kood4 like tcEelarve  
			group by kood4, library.nimetus;

-- salvestame eelarve (art loikes) kooskolastatud (KULUD)
	insert into tmp_eelproj_aruanne1 (kood5, nimetus, summa1, timestamp, kpv, rekvid, tunnus)
		select  kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid, '010'+left(ltrim(rtrim(kood4)),3)::varchar(20)
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
	insert into tmp_eelproj_aruanne1 (kood1, nimetus, summa1, timestamp, kpv, rekvid, tunnus)
		select  kood1, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid,'100'+left(ltrim(rtrim(kood1)),3)::varchar(20)
			from eelarve 
			left outer join library on (library.kood = eelarve.kood1 and library.library = 'TEGEV')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where tunnus = 0
			and aasta = year(tdKpv)
			and (eelarve.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  eelarve.rekvid = tnRekvId)
			and eelarve.kood1 like tcTegev
			and eelarve.kood2 like tcAllikas
			and eelarve.kood4 like tcEelarve 
			group by kood1, library.nimetus;


if tnTapsestatud > 0 then
-- salvestame eelarve (art loikes) tapsestatud eelarve (tulud)
	insert into tmp_eelproj_aruanne1 (kood5, nimetus, summa1, timestamp, kpv, rekvid, tunnus)
		select  kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid,'001'+left(ltrim(rtrim(kood4)),3)::varchar(20)
			from eelarve 
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1 and left(library.kood,1) <>'2')					
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
		select  kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid,'010'+left(ltrim(rtrim(kood4)),3)::varchar(20)
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
			and eelarve.kood1 like tcTegev
			and eelarve.kood2 like tcAllikas
			and eelarve.kood4 like tcEelarve 
			group by kood1, library.nimetus;

end if;
-- kassatulud (art.jargi), kulud
	insert into tmp_eelproj_aruanne1 (kood5, nimetus, summa2, timestamp, kpv, rekvid, tunnus)
		select kassatulu.kood,ifnull(library.nimetus,space(254)) as nimetus, sum(summa) as summa,
			lcReturn, date(), tnRekvid,'001'+left(ltrim(rtrim(kassatulu.kood)),3)::varchar(20)
				from (
				SELECT journal.rekvid, sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood5 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				JOIN kassatulud ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
				where journal.kpv <= tdKpv and not empty (journal1.kood5) 
				and journal1.kood1 like tcTegev
				and journal1.kood2 like tcAllikas
				and journal1.kood5 like tcEelarve 
				GROUP BY journal.rekvid, journal1.kood5) kassatulu
			inner join library on (library.kood = kassatulu.kood and library.library = 'TULUDEALLIKAD' and tun5 = 1)
			group by  kassatulu.kood, nimetus;
--where (kassatulu.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  kassatulu.rekvid = tnRekvId)
-- kassatulud (art.jargi) miinus
	insert into tmp_eelproj_aruanne1 (kood5, nimetus, summa2, timestamp, kpv, rekvid, tunnus)
		select kassakulu.kood,ifnull(library.nimetus,space(254)) as nimetus, -1* sum(summa) as summa,
			lcReturn, date(), tnRekvid,'010'+left(ltrim(rtrim(kassakulu.kood)),3)::varchar(20)
				from (
				SELECT journal.rekvid, sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood5 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				JOIN kassakulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
				where journal.kpv <= tdKpv and not empty (journal1.kood5) 
				and journal1.kood1 like tcTegev
				and journal1.kood2 like tcAllikas
				and journal1.kood5 like tcEelarve 
				GROUP BY journal.rekvid, journal1.kood5) kassakulu
			inner join library on (library.kood = kassakulu.kood and library.library = 'TULUDEALLIKAD' and tun5 = 1)
			where (kassakulu.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  kassakulu.rekvid = tnRekvId)
			group by kassakulu.kood, nimetus;



-- kassakulud (art.jargi), kulud
	insert into tmp_eelproj_aruanne1 (kood5, nimetus, summa2, timestamp, kpv, rekvid, tunnus)
		select kassakulu.kood,ifnull(library.nimetus,space(254)) as nimetus, sum(summa) as summa,
			lcReturn, date(), tnRekvid,'010'+left(ltrim(rtrim(kassakulu.kood)),3)::varchar(20)
				from (
				SELECT journal.rekvid, sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood5 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				JOIN kassakulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
				where journal.kpv <= tdKpv and not empty (journal1.kood5) 
				and journal1.kood1 like tcTegev
				and journal1.kood2 like tcAllikas
				and journal1.kood5 like tcEelarve 
				GROUP BY journal.rekvid, journal1.kood5) kassakulu
			inner join library on (library.kood = kassakulu.kood and library.library = 'TULUDEALLIKAD' and tun5 = 2)
			where (kassakulu.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  kassakulu.rekvid = tnRekvId)
			group by kassakulu.kood, nimetus;


-- kassatulud (art.jargi), kulud
	insert into tmp_eelproj_aruanne1 (kood5, nimetus, summa2, timestamp, kpv, rekvid, tunnus)
		select kassatulu.kood,ifnull(library.nimetus,space(254)) as nimetus, -1*sum(summa) as summa,
			lcReturn, date(), tnRekvid,'001'+left(ltrim(rtrim(kassatulu.kood)),3)::varchar(20)
				from (
				SELECT journal.rekvid, sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood5 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				JOIN kassatulud ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
				where journal.kpv <= tdKpv and not empty (journal1.kood5) 
				and journal1.kood1 like tcTegev
				and journal1.kood2 like tcAllikas
				and journal1.kood5 like tcEelarve 
				GROUP BY journal.rekvid, journal1.kood5) kassatulu
			inner join library on (library.kood = kassatulu.kood and library.library = 'TULUDEALLIKAD' and tun5 = 2)
			where (kassatulu.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  kassatulu.rekvid = tnRekvId)
			group by kassatulu.kood, nimetus;


-- kassakulud (tegev.jargi)
	insert into tmp_eelproj_aruanne1 (kood1, nimetus, summa2, timestamp, kpv, rekvid, tunnus)
		select kassakulud.kood,ifnull(library.nimetus,space(254)) as nimetus, sum(summa) as summa,
			lcReturn, date(), tnRekvid,'100'+left(ltrim(rtrim(kassakulud.kood)),3)::varchar(20)
				from (
				SELECT journal.rekvid, sum(journal1.summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) AS summa, journal1.kood1 AS kood 
				FROM journal
				JOIN journal1 ON journal1.parentid = journal.id
				JOIN kassakulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				LEFT JOIN dokvaluuta1 ON journal1.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 1
				where journal.kpv <= tdKpv and not empty (journal1.kood1) 
				and journal1.kood1 like tcTegev
				and journal1.kood2 like tcAllikas
				and journal1.kood5 like tcEelarve 
				GROUP BY journal.rekvid, journal1.kood1) kassakulud
			inner join library on (library.kood = kassakulud.kood and library.library = 'TEGEV')
			where (kassakulud.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  kassakulud.rekvid = tnRekvId)
			group by kassakulud.kood, nimetus;

-- kondid
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		select '','','POHITEGEVUSE TULUD KOKKU',sum(summa1),sum(summa2), lcreturn,date(),tnrekvId,'0'::varchar from tmp_eelproj_aruanne1
				where kood5 in (select kood from library where library = 'TULUDEALLIKAD' and tun5 = 1) and timestamp = lcreturn;

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		select '','30','Maksutulud',sum(summa1),sum(summa2), lcreturn,date(),tnrekvId,'00130'::varchar from tmp_eelproj_aruanne1
				where  timestamp = lcreturn
				and left(ltrim(rtrim(kood5)),2)='30';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		select '','32','Tulud kaupade ja teenuste muugist',sum(summa1),sum(summa2),lcreturn,date(),tnrekvId,'00132'::varchar from tmp_eelproj_aruanne1
				where  timestamp = lcreturn
				and kood5 like '32%';
		delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and kood5 like '32%' and kood5 <> '32'; 		

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		select '','3520','Saadud toetused tegevuskuludeks',sum(summa1),sum(summa2),lcreturn,date(),tnrekvId,'001352'::varchar from tmp_eelproj_aruanne1
				where  timestamp = lcreturn
				and ltrim(rtrim(kood5)) like '352.0%';


	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		select '','3500;352','Muud saadud toetused tegevuskuludeks',sum(summa1),sum(summa2),lcreturn,date(),tnrekvId,'0013521'::varchar from tmp_eelproj_aruanne1
				where  timestamp = lcreturn
				and (ltrim(rtrim(kood5)) like '3500%' or ltrim(rtrim(kood5)) like '352.00.17%');

--	delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and (ltrim(rtrim(kood5)) like '350%' or ltrim(rtrim(kood5)) like '352%') 
--		and (tunnus <> '0013521' or tunnus <> '001352') and LTRIM(RTRIM(kood5)) <> '3500;352'

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		select '','382.388','Muud tegevustulud ',sum(summa1),sum(summa2),lcreturn,date(),tnrekvId,'001380'::varchar from tmp_eelproj_aruanne1
				where  timestamp = lcreturn
				and ltrim(rtrim(kood5)) IN ('3880','3823','3818','3888'); 
				
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		select '','3825;3882','Muud tegevustulud ',sum(summa1),sum(summa2),lcreturn,date(),tnrekvId,'00138'::varchar from tmp_eelproj_aruanne1
				where  timestamp = lcreturn
				and (kood5 = '382.388' or kood5 like '3825%' or kood5 like '3882%');



-- kustutame read

--	delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and ltrim(rtrim(kood5)) IN ('3880','3823','3818','3888')  
--		and LTRIM(RTRIM(kood5)) <> '382.388';

--PÕHITEGEVUSE KULUD KOKKU
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2
	from tmp_eelproj_aruanne1
	where  timestamp = lcreturn
	and (kood5 like '40%' or kood5 like '413%' or kood5 like '4500%' or kood5 like '452%'); 
				
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','40, 41, 4500, 452','Antud toetused tegevuskuludeks ',ifnull(lnSumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'010');

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
	and (nimetus = 'Antud toetused tegevuskuludeks' or nimetus = 'Muud tegevuskulud');
		
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','PÕHITEGEVUSE KULUD KOKKU',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'010'); 

	select summa1, summa2 into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn and nimetus = 'POHITEGEVUSE TULUD KOKKU';
	
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','PÕHITEGEVUSE TULEM',ifnull(lnsumma1,0)- ifnull(lnsummaK1,0),ifnull(lnsumma2,0)-ifnull(lnsummaK2,0),lcreturn,date(),tnrekvId,'015'); 
		
	update tmp_eelproj_aruanne1 set kood5 = space(1) where ifnull(kood5,'null') = 'null' and timestamp = lcreturn; 
	update tmp_eelproj_aruanne1 set kood1 = space(1) where ifnull(kood1,'null') = 'null' and timestamp = lcreturn; 

--Põhivara müük (+)
--Kokku381: 3810+3811+3812+3813+3814

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and ltrim(rtrim(kood5)) in ('3810','3811','3812','3813','3814');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','381','Põhivara müük (+)',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'016'); 
	delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and ltrim(rtrim(kood5)) in ('3810','3811','3812','3813','3814');
--Põhivara soetus (-)
--kokku kõik art 15
	
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '15%';
	lnSumma1 = ifnull(lnsumma1,0);
	lnSumma2 = ifnull(lnsumma2,0);
	RAISE NOTICE 'Põhivara soetus ';
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','15','Põhivara soetus (-)',-1*ifnull(lnsumma1,0),-1*ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'017'); 
	RAISE NOTICE 'lnSumma2= %',lnSumma2;

--Põhivara soetuseks saadav sihtfinantseerimine(+) 
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '3502%';
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','3502','Põhivara soetuseks saadav sihtfinantseerimine(+) ',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'018'); 
--Põhivara soetuseks antav sihtfinantseerimine(-)
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '4502%';
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','4502','Põhivara soetuseks antav sihtfinantseerimine(-) ',-1*ifnull(lnsumma1,0),-1*ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'018'); 		
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
		values( '','1501','Osaluste soetus (-) ',-1*ifnull(lnsumma1,0),-1*ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0190'); 
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
		values( '','1511','Muude aktsiate ja osade soetus (-)',-1*ifnull(lnsumma1,0),-1*ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0192'); 
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
		values( '','1531','Antavad laenud (-)',-1*ifnull(lnsumma1,0),-1*ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0194'); 
--Finantstulud (+)
--Kokku655: 652+655+658
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 in ('3820','3820.8','3823');

--	and (kood5 like '652%' or kood5 like '655%' or kood5 like '658%');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','655','Finantstulud (+)',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0200'); 
--Finantstkulud (-)
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '650%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','650','Finantstkulud (-)',-1*ifnull(lnsumma1,0),-1*ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0202'); 

--EELARVE TULEM (ÜLEJÄÄK (+) / PUUDUJÄÄK (-))
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and (nimetus = 'PÕHITEGEVUSE TULEM' or nimetus = 'INVESTEERIMISTEGEVUS KOKKU');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','EELARVE TULEM (ÜLEJÄÄK (+) / PUUDUJÄÄK (-))',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'021'); 
--Kohustuste võtmine (+)
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '2585%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','2585','Kohustuste võtmine (+)',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0210'); 

--Kohustuste tasumine (-)
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood5 like '2586%';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','2586','Kohustuste tasumine (-)',-1*ifnull(lnsumma1,0),-1*ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0211'); 


--FINANTSEERIMISTEGEVUS
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and ltrim(rtrim(kood5)) in ('2586','2585') and ltrim(rtrim(tunnus)) in ('0210','0211')  ;

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','FINANTSEERIMISTEGEVUS',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'021'); 
--LIKVIIDSETE VARADE MUUTUS (+ suurenemine, - vähenemine)
---	select summa1, summa2 into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
--	where timestamp = lcReturn 
--	and ltrim(rtrim(kood5)) in ('2586','2585') and ltrim(rtrim(tunnus)) in ('0210','0211')  ;
lnSumma1 = 0;
lnSumma2 = 0;
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','100','LIKVIIDSETE VARADE MUUTUS (+ suurenemine, - vähenemine)',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'022'); 

--NÕUETE JA KOHUSTUSTE SALDODE MUUTUS (tekkepõhise e/a korral) (+/-)
	select  sum(summa2) into  lnSumma1 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and ltrim(rtrim(kood5))= '100' and ltrim(rtrim(tunnus)) = '022'  ;


	select  sum(summa2) into  lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and (nimetus = 'EELARVE TULEM (ÜLEJÄÄK (+) / PUUDUJÄÄK (-))' or nimetus = 'FINANTSEERIMISTEGEVUS');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','NÕUETE JA KOHUSTUSTE SALDODE MUUTUS (tekkepõhise e/a korral) (+/-)',0,ifnull(lnsumma1,0)- ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'023'); 


-- tegevusallad
--PÕHITEGEVUSE KULUDE JA INVESTEERIMISTEGEVUSE VÄLJAMINEKUTE JAOTUS TEGEVUSALADE JÄRGI
--Ülalnimetamata üldised valitsussektori kulud kokku
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and ltrim(rtrim(kood1)) in ('01110','01120','01800'); 

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Ülalnimetamata üldised valitsussektori kulud kokku',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0101'); 

--Üldised valitsussektori teenused

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and (ltrim(rtrim(kood1)) in ('01111','01112','01114','01600','01700')
	or nimetus = 'Ülalnimetamata üldised valitsussektori kulud kokku'); 

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Üldised valitsussektori teenused',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0100'); 

-- kustutame read, mis ei eole vaja

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and ltrim(kood1) in ('01110','01120','01800');

--Riigikaitse
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '02';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Riigikaitse',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0102'); 
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and left(ltrim(rtrim(kood1)),2) = '02';

--Avalik kord ja julgeolek
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '03';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Avalik kord ja julgeolek',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0103'); 
--	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and left(ltrim(rtrim(kood1)),2) = '02';
--Muu avalik kord ja julgeolek kokku
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood1 in ('03101','03300','03400','03500','03600');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Muu avalik kord ja julgeolek kokku',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0103'); 
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood1 in ('03101','03300','03400','03500','03600');

--Majandus
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '04';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Majandus',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0104'); 
--Üldmajanduslikud arendusprojektid
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood1 in ('04110','04310','04320','04330','04340','04410','04420','04430','04530','04550','04720','04810','04820','04830','04840','04850','04860','04870');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Üldmajanduslikud arendusprojektid',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'01040'); 
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood1 in ('04110','04310','04320','04330','04340','04410','04420','04430','04530','04550','04720','04810','04820','04830','04840','04850','04860','04870');
--Keskkonnakaitse
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '05';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Keskkonnakaitse',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0105'); 
--Muu keskkonnakaitse
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood1 in ('05500','05600');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Muu keskkonnakaitse',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'01050'); 
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood1 in ('05500','05600');
--Elamu- ja kommunaalmajandus
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '06';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Elamu- ja kommunaalmajandus',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0106'); 
--Tervishoid
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '07'
	and kood1 not in ('07120','07130','07500');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Tervishoid',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'0107'); 
--Ambulatoorsed teenused 
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),3) = '072';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Ambulatoorsed teenused',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'01072'); 
		
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and left(ltrim(rtrim(kood1)),3) = '072';
--Haiglateenused
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),3) = '073';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Haiglateenused',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'01073'); 
		
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and left(ltrim(rtrim(kood1)),3) = '073';
--Ülalnimetamata tervishoid kokku
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and kood1 in ('07120','07130','07500');

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Ülalnimetamata tervishoid kokku',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'01074'); 
		
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and kood1 in ('07120','07130','07500');
-- Vaba aeg, kultuur ja religioon

	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '08';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Vaba aeg, kultuur ja religioon',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'01078'); 

--Haridus
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '09';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Haridus',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'01078'); 

--Sotsiaalne kaitse
	select sum(summa1), sum(summa2) into lnSumma1, lnSumma2 from tmp_eelproj_aruanne1
	where timestamp = lcReturn 
	and left(ltrim(rtrim(kood1)),2) = '10';

	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
		values( '','','Sotsiaalne kaitse',ifnull(lnsumma1,0),ifnull(lnsumma2,0),lcreturn,date(),tnrekvId,'01010'); 

	
-- kokkuvote
	insert into tmp_eelproj_aruanne1 (kood1, kood5, nimetus, summa1, summa2, timestamp, kpv, rekvid, tunnus)
	select kood1, kood5, nimetus, sum(summa1), sum(summa2), lcReturn+'KOKKU', date(), tnRekvid, tunnus
	from tmp_eelproj_aruanne1
	where timestamp = lcReturn
	group by kood1, kood5, nimetus, tunnus;
-- kustutame ajutised read

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn;
	lcReturn = lcReturn + 'KOKKU';

return LCRETURN;

end;

$BODY$
  LANGUAGE 'plpgsql' 
  COST 100;
ALTER FUNCTION sp_eelarve_aruanne4(integer, date, character varying, character varying, character varying,  integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne4(integer, date, character varying, character varying, character varying, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne4(integer, date, character varying, character varying, character varying, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne4(integer, date, character varying, character varying, character varying, integer, integer) TO dbvaatleja;

