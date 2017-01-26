-- Function: sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer)

-- DROP FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer);

CREATE OR REPLACE FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE 
	tnrekvid alias for $1;
	tdKpv1 alias for $2;
	tdKpv2 alias for $3;
	tnRekvidSub alias for $4;
	tcTunnus alias for $5;
	tcKonto alias for $6;
	tcAllikas alias for $7;
	tcTegev alias for $8;
	tcEelarve alias for $9;
	tcProjekt alias for $10;
	tcTp alias for $11;
	tnLiik alias for $12;
	tnSvod alias for $13;

	lcReturn varchar;
	lcString varchar;

	lnrekvid1 int;
	lnrekvid2 int;

	LNcOUNT int;
	lnSumma numeric(12,4);

	v_eelaruanne record;

begin


	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_EELARVE_ARUANNE1';



	if ifnull(lnCount,0) < 1 then



	raise notice ' lisamine  ';

	

		create table tmp_eelarve_aruanne1 ( id int, konto varchar(20), 
			RekvIdSub int not null default 0, AllAsutus varchar(254) not null default space(1),
			db numeric(14,2) not null default 0, tp_db varchar(20) not null default space(20), 
			kr numeric(14,2) not null default 0, tp_kr varchar(20) not null default space(20),
			tunnus varchar(20) not null default space(20),
			allikas varchar(20) not null default space(20),
			tegev varchar(20) not null default space(20),
			eelarve varchar(20) not null default space(20),
			rahavoo varchar(20) not null default space(20),
			projekt varchar(20) not null default space(20),
			timestamp varchar(20) not null , kpv date not null default date(), rekvid int not null  )  ;

		

		GRANT ALL ON TABLE tmp_eelarve_aruanne1 TO GROUP public;



	else
		delete from tmp_eelarve_aruanne1 where kpv < date() and rekvid = tnrekvId;

	end if;


	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_EELPROJ_ARUANNE1';


	if ifnull(lnCount,0) < 1 then

		raise notice ' lisamine  ';


		create table tmp_eelproj_aruanne1 ( id int, konto varchar(20), 
			RekvIdSub int not null default 0, AllAsutus varchar(254) not null default space(1),
			summa1 numeric(14,2) not null default 0, 
			summa2 numeric(14,2) not null default 0, 
			summa3 numeric(14,2) not null default 0, 
			summa4 numeric(14,2) not null default 0, 
			summa5 numeric(14,2) not null default 0, 
			summa6 numeric(14,2) not null default 0, 
			summa7 numeric(14,2) not null default 0, 
			summa8 numeric(14,2) not null default 0, 
			tunnus varchar(20) not null default space(20),
			allikas varchar(20) not null default space(20),
			tegev varchar(20) not null default space(20),
			eelarve varchar(20) not null default space(20),
			rahavoo varchar(20) not null default space(20),
			projekt varchar(20) not null default space(20),
			objekt varchar(20) not null default space(20),
			nimetus varchar(254) null,
			timestamp varchar(20) not null , kpv date not null default date(), rekvid int not null  )  ;

		

		GRANT ALL ON TABLE tmp_eelproj_aruanne1 TO GROUP public;



	else
		delete from tmp_eelproj_aruanne1 where kpv < date() and rekvid = tnrekvId;

	end if;




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


	lcreturn := to_char(now(), 'YYYYMMDDMISSSS');
	raise notice 'tnLiik %',tnLiik;
	raise notice 'tcEelarve %',tcEelarve;





	if tnLiik = 101 or tnLiik = 102 or tnLiik = 111 or tnLiik = 112  then
		-- 1.	Eelarve tulude jaotus allikate lõikes    
		
		if tnRekvIdSub = 0 then
			lnRekvid1 = 0;
			lnrekvid2 = 999999;
		else
			lnRekvid1 = tnRekvIdSub;
			lnrekvid2 = tnRekvIdSub;
		end if;

		raise notice 'eelarve tulud kinnitatud';

		insert into tmp_eelproj_aruanne1 (  RekvIdSub, SUMMA1, eelarve, rekvid, timestamp, tunnus)	
			SELECT  eelarve.rekvid,  (eelarve.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, eelarve.kood4, tnRekvid, lcreturn, ifnull(library.kood,space(20))::character varying
				FROM eelarve 
				inner join library kulud on (kulud.kood = eelarve.kood4 and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 1)
				left outer join dokvaluuta1 on (eelarve.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 8)
				left outer join library on library.id = eelarve.tunnusId
				inner join tmprekv on eelarve.rekvId = tmprekv.id
				WHERE Eelarve.aasta = year(tdKpv2)   
				and eelarve.tunnus = 0
				and empty(eelarve.kpv)
				AND eelarve.kood1 LIKE tcTegev+'%'   
				AND eelarve.kood2 LIKE tcAllikas+'%'   
				AND eelarve.kood4 LIKE tcEelarve+'%'; 

		if tnLiik = 102 or tnLiik = 112 then
		-- eelarve Tapsastatud:

		insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA2, eelarve, rekvid, timestamp)	
			SELECT ifnull(t.kood, space(20))::character varying, eelarve.rekvid,  (eelarve.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, eelarve.kood4,tnRekvId, lcReturn
				FROM eelarve 
				inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1)
				left outer join dokvaluuta1 on (eelarve.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 8)
				inner join tmprekv on eelarve.rekvId = tmprekv.id
				LEFT JOIN library t ON t.id = eelarve.tunnusid
				WHERE Eelarve.aasta = year(tdKpv2)   
				AND kood1 LIKE tcTegev   
				AND kood2 LIKE tcAllikas
				and eelarve.tunnus = 1 
				and eelarve.kpv <= tdKpv2 
				AND kood4 LIKE tcEelarve; 
		end if;

		-- eelarve Taitmine:
		
		if tnLiik = 101 or tnLiik = 102 then
			-- kassa


			insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA3, eelarve, rekvid, timestamp)	
			SELECT  journal1.tunnus, journal.rekvid, (journal1.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, journal1.kood5, tnRekvId, lcreturn   
				FROM journal inner join journal1 on journal.id = journal1.parentid
				left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
				inner join tmprekv on journal.rekvId = tmprekv.id
				JOIN kassatulud ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassatulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				WHERE journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2  
				AND journal1.kood1 LIKE tcTegev +'%'  
				AND journal1.kood2 LIKE tcAllikas +'%'  
				AND journal1.kood5 LIKE tcEelarve +'%'; 
		end if;
	

		if tnLiik = 111 or tnLiik = 112 then
			-- fakt

			insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA3, eelarve, rekvid, timestamp)	
			SELECT  journal1.tunnus, journal.rekvid, (journal1.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, journal1.kood5, tnRekvId, lcreturn  
				FROM journal inner join journal1 on journal.id = journal1.parentid
				left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
				inner join tmprekv on journal.rekvId = tmprekv.id
				JOIN fakttulud ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(fakttulud.kood::text))
				WHERE journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2    
				AND journal1.kood1 LIKE tcTegev +'%'  
				AND journal1.kood2 LIKE tcAllikas +'%'  
				AND journal1.kood5 LIKE tcEelarve +'%'; 

		end if;

		-- kokkuvõtte

		insert into tmp_eelproj_aruanne1 (RekvIdSub, summa1, summa2, summa3, eelarve, rekvid, timestamp)	
			select RekvIdSub, sum(summa1) , sum(summa2), sum(summa3), eelarve, tnRekvId, lcReturn+'LOPP'
				from tmp_eelproj_aruanne1
				where rekvid = tnRekvId
				and tmp_eelproj_aruanne1.tunnus like tcTunnus+'%'
				and timestamp = lcReturn
				group by RekvIdSub, eelarve
				order by RekvIdSub, eelarve;

		delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and rekvid = tnRekvId;

		lcReturn = lcReturn + 'LOPP';
	end if;


	if tnLiik > 200  and tnLiik <= 612 then
		-- 1.	Eelarve kulud   
		
		if tnRekvIdSub = 0 then
			lnRekvid1 = 0;
			lnrekvid2 = 999999;
		else
			lnRekvid1 = tnRekvIdSub;
			lnrekvid2 = tnRekvIdSub;
		end if;

		-- eelarve kulud kinnitatud
		raise notice 'eelarve kulud kinnitatud, ilma LE-LA';

		insert into tmp_eelproj_aruanne1 (  RekvIdSub, SUMMA1, allikas, tegev, eelarve, rekvid, timestamp, tunnus)	
			SELECT  eelarve.rekvid,  (eelarve.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, eelarve.kood2, eelarve.kood1, eelarve.kood4,
				tnRekvid, lcreturn, 
				ifnull(t.kood,space(20))::character varying
				FROM eelarve 
				inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
				left outer join dokvaluuta1 on (eelarve.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 8)
				left outer join library t on t.id = eelarve.tunnusId
				inner join tmprekv on eelarve.rekvId = tmprekv.id
				WHERE Eelarve.aasta = year(tdKpv2)   
				and empty(eelarve.kpv)
				and eelarve.tunnus = 0
				and eelarve.kood2 not in ('LE-LA')
				AND eelarve.kood1 LIKE tcTegev+'%'   
				AND eelarve.kood2 LIKE tcAllikas+'%'   
				AND eelarve.kood4 LIKE tcEelarve+'%'; 

		raise notice 'eelarve kulud kinnitatud, koos LE-LA';


		insert into tmp_eelproj_aruanne1 (  RekvIdSub, SUMMA4, allikas, tegev, eelarve, rekvid, timestamp, tunnus)	
			SELECT  eelarve.rekvid,  (eelarve.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, eelarve.kood2, eelarve.kood1, eelarve.kood4, tnRekvid, lcreturn, 
				ifnull(t.kood,space(20))::character varying
				FROM eelarve 
				inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
				left outer join dokvaluuta1 on (eelarve.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 8)
				left outer join library t on t.id = eelarve.tunnusId
				inner join tmprekv on eelarve.rekvId = tmprekv.id
				WHERE Eelarve.aasta = year(tdKpv2)   
				and eelarve.tunnus = 0
				and empty(eelarve.kpv)
				and eelarve.kood2 in ('LE-LA')
				AND eelarve.kood1 LIKE tcTegev+'%'   
				AND eelarve.kood2 LIKE tcAllikas+'%'   
				AND eelarve.kood4 LIKE tcEelarve+'%'; 

		if tnLiik = 202 or tnLiik = 212 or tnLiik = 302 or tnLiik = 312 or tnLiik = 402 or tnLiik = 412 or tnLiik = 502 or tnLiik = 512 
			or tnLiik = 602 or tnLiik = 612 then
		-- eelarve Tapsastatud, ilma LE-LA:

			raise notice 'tapsestatud ';

			insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA2, allikas, tegev, eelarve, rekvid, timestamp)	
				SELECT ifnull(t.kood, space(20))::character varying, eelarve.rekvid,  (eelarve.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, 
				eelarve.kood2, eelarve.kood1, eelarve.kood4,tnRekvId, lcReturn
				FROM eelarve 
				inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
				left outer join dokvaluuta1 on (eelarve.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 8)
				inner join tmprekv on eelarve.rekvId = tmprekv.id
				LEFT JOIN library t ON t.id = eelarve.tunnusid
				WHERE Eelarve.aasta = year(tdKpv2)  
				and eelarve.kood2 not in ('LE-LA') 
				AND kood1 LIKE tcTegev +'%' 
				AND kood2 LIKE tcAllikas +'%'
				and eelarve.tunnus = 1 
				and eelarve.kpv <= tdKpv2 
				AND kood4 LIKE tcEelarve +'%'; 

			-- eelarve Tapsastatud, koos LE-LA:

			insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA5, allikas, tegev, eelarve, rekvid, timestamp)	
				SELECT ifnull(t.kood, space(20))::character varying, eelarve.rekvid,  (eelarve.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, 
				eelarve.kood2, eelarve.kood1, eelarve.kood4,tnRekvId, lcReturn
				FROM eelarve 
				inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
				left outer join dokvaluuta1 on (eelarve.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 8)
				inner join tmprekv on eelarve.rekvId = tmprekv.id
				LEFT JOIN library t ON t.id = eelarve.tunnusid
				WHERE Eelarve.aasta = year(tdKpv2)  
				and eelarve.kood2  in ('LE-LA') 
				AND kood1 LIKE tcTegev +'%'  
				AND kood2 LIKE tcAllikas +'%'
				and eelarve.tunnus = 1 
				and eelarve.kpv <= tdKpv2 
				AND kood4 LIKE tcEelarve +'%'; 
		end if;



		-- eelarve Taitmine:
		
		if tnLiik = 201 or tnLiik = 202 or tnLiik = 301 or tnLiik = 302  or tnLiik = 401 or tnLiik = 402 or tnLiik = 501 or
			tnLiik = 601 or tnLiik = 602 then
			-- kassa


			insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA3, allikas, tegev, eelarve, rekvid, timestamp)	
				SELECT  journal1.tunnus, journal.rekvid, (journal1.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, 
				journal1.kood2, journal1.kood1, journal1.kood5, tnRekvId, lcreturn   
				FROM journal inner join journal1 on journal.id = journal1.parentid
				left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
				inner join tmprekv on journal.rekvId = tmprekv.id
				inner join library on (library.kood = journal1.kood5 and library.library = 'TULUDEALLIKAD')
				JOIN kassakulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(kassakulud.kood::text))
				JOIN kassakontod ON ltrim(rtrim(journal1.kreedit::text)) ~~ ltrim(rtrim(kassakontod.kood::text))
				WHERE journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2  
				AND journal1.kood1 LIKE tcTegev +'%'  
				AND journal1.kood2 LIKE tcAllikas +'%'  
				AND journal1.kood5 LIKE tcEelarve +'%'; 
		end if;
	

		if tnLiik = 211 or tnLiik = 212 or tnLiik = 311 or tnLiik = 312 or tnLiik = 411 or tnLiik = 412 or tnLiik = 511 or tnLiik = 512  then
			-- fakt

			insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA3, allikas, tegev, eelarve, rekvid, timestamp)	
			SELECT  journal1.tunnus, journal.rekvid, (journal1.summa*inull(dokvaluuta1.kuurs,1))::numeric as summa, 
				journal1.kood2, journal1.kood1, journal1.kood5, tnRekvId, lcreturn  
				FROM journal inner join journal1 on journal.id = journal1.parentid
				left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
				inner join tmprekv on journal.rekvId = tmprekv.id
				JOIN faktkulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(faktkulud.kood::text))
				WHERE journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2    
				AND journal1.kood1 LIKE tcTegev +'%'  
				AND journal1.kood2 LIKE tcAllikas +'%'  
				AND journal1.kood5 LIKE tcEelarve +'%'; 

		end if;

		if tnLiik > 600 and tnLiik <= 612 then
			-- fakt

			insert into tmp_eelproj_aruanne1 (tunnus, RekvIdSub, SUMMA6, allikas, tegev, eelarve, rekvid, timestamp)	
			SELECT  journal1.tunnus, journal.rekvid, (journal1.summa*ifnull(dokvaluuta1.kuurs,1))::numeric as summa, 
				journal1.kood2, journal1.kood1, journal1.kood5, tnRekvId, lcreturn  
				FROM journal inner join journal1 on journal.id = journal1.parentid
				left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
				inner join tmprekv on journal.rekvId = tmprekv.id
				inner join library on (library.kood = journal1.kood5 and library.library = 'TULUDEALLIKAD')				
				JOIN faktkulud ON ltrim(rtrim(journal1.deebet::text)) ~~ ltrim(rtrim(faktkulud.kood::text))
				WHERE journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2    
				AND journal1.kood1 LIKE tcTegev +'%'  
				AND journal1.kood2 LIKE tcAllikas +'%'  
				AND journal1.kood5 LIKE tcEelarve +'%'; 

		end if;
 

		-- kokkuvõtte
		if tnLiik >= 201 and tnLiik <= 212 then
			-- majandus
			insert into tmp_eelproj_aruanne1 (RekvIdSub, summa1, summa2, summa3, eelarve, rekvid, timestamp)	
				select RekvIdSub, sum(summa1)+sum(summa4) , sum(summa2)+sum(summa5), sum(summa3), eelarve, tnRekvId, lcReturn+'LOPP'
				from tmp_eelproj_aruanne1
				where rekvid = tnRekvId
				and tmp_eelproj_aruanne1.tunnus like tcTunnus+'%'
				and timestamp = lcReturn
				group by RekvIdSub, eelarve
				order by RekvIdSub, eelarve;

		end if;
		if tnLiik >= 301 and tnLiik <= 312 then
			-- tegev
			insert into tmp_eelproj_aruanne1 (RekvIdSub, summa1, summa2, summa3, tegev, rekvid, timestamp)	
				select RekvIdSub, sum(summa1)+sum(summa4) , sum(summa2)+sum(summa5), sum(summa3), tegev, tnRekvId, lcReturn+'LOPP'
				from tmp_eelproj_aruanne1
				where rekvid = tnRekvId
				and tmp_eelproj_aruanne1.tunnus like tcTunnus+'%'
				and timestamp = lcReturn
				group by RekvIdSub, tegev
				order by RekvIdSub, tegev;

		end if;
		if tnLiik >= 401 and tnLiik <= 412 then
			-- allikas, tegev, eelarve, LE-LA eraldi
			insert into tmp_eelproj_aruanne1 (RekvIdSub, summa1, summa2, summa3,summa4, summa5, allikas,  tegev, eelarve, rekvid, timestamp)	
				select RekvIdSub, sum(summa1), sum(summa2),  sum(summa3),sum(summa4), sum(summa5), allikas, tegev, eelarve, tnRekvId, lcReturn+'LOPP'
				from tmp_eelproj_aruanne1
				where rekvid = tnRekvId
				and tmp_eelproj_aruanne1.tunnus like tcTunnus+'%'
				and timestamp = lcReturn
				group by RekvIdSub, allikas, tegev, eelarve
				order by RekvIdSub, allikas, tegev, eelarve;

		end if;
		if tnLiik >= 501 and tnLiik <= 512 then
			-- tunnus, eelarve
			insert into tmp_eelproj_aruanne1 (RekvIdSub, summa1, summa2, summa3,tunnus, eelarve, rekvid, timestamp)	
				select RekvIdSub, sum(summa1)+sum(summa4) , sum(summa2)+sum(summa5), sum(summa3), tunnus, eelarve, tnRekvId, lcReturn+'LOPP'
				from tmp_eelproj_aruanne1
				where rekvid = tnRekvId
				and tmp_eelproj_aruanne1.tunnus like tcTunnus+'%'
				and timestamp = lcReturn
				group by RekvIdSub, tunnus, eelarve
				order by RekvIdSub, tunnus, eelarve;

		end if;
		if tnLiik >= 601 and tnLiik <= 612 then
			-- tegev, eelarve, kassa ja tegelik
			insert into tmp_eelproj_aruanne1 (RekvIdSub, summa1, summa2, summa3, summa6, tegev, eelarve, rekvid, timestamp)	
				select RekvIdSub, sum(summa1)+sum(summa4) , sum(summa2)+sum(summa5), sum(summa3), sum(summa6), tegev, eelarve, tnRekvId, lcReturn+'LOPP'
				from tmp_eelproj_aruanne1
				where rekvid = tnRekvId
				and tmp_eelproj_aruanne1.tunnus like tcTunnus+'%'
				and timestamp = lcReturn
				group by RekvIdSub, tegev, eelarve
				order by RekvIdSub, tegev, eelarve;

		end if;

		delete from tmp_eelproj_aruanne1 where timestamp = lcReturn and rekvid = tnRekvId;

		lcReturn = lcReturn + 'LOPP';


	end if;


	if tnLiik = 1 then
		-- 1.	KONTODE KÄIBED PARTNERI KOODIDE LÕIKES
		
		if tnRekvIdSub = 0 then
			lnRekvid1 = 0;
			lnrekvid2 = 999999;
		else
			lnRekvid1 = tnRekvIdSub;
			lnrekvid2 = tnRekvIdSub;
		end if;

		-- db

		insert into tmp_eelarve_aruanne1 (konto, RekvIdSub, AllAsutus, db, tp_db, tunnus, tegev,eelarve, projekt, rekvid, timestamp)
			select journal1.deebet, journal.rekvid, rekv.nimetus, sum(journal1.summa*ifnull(dokvaluuta1.kuurs,1)), 
				journal1.lisa_d, journal1.tunnus, journal1.kood1,journal1.kood5,
				journal1.proj, tnrekvid, lcreturn
			from journal inner join journal1 on journal.id = journal1.parentid
				inner join rekv on journal.rekvid = rekv.id
				inner join tmprekv on journal.rekvId = tmprekv.id
				left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)

			where journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2
				and journal1.deebet like ltrim(rtrim(tcKonto))+'%'
				and journal1.lisa_d like ltrim(rtrim(tcTp))+'%'
				and journal.rekvId >= lnrekvid1 and journal.rekvid <= lnrekvid2
				and journal1.tunnus like ltrim(rtrim(tcTunnus))+'%'
				and journal1.kood1 like ltrim(rtrim(tcTegev))+'%'
				and journal1.kood2 like ltrim(rtrim(tcAllikas))+'%'
				and journal1.kood5 like ltrim(rtrim(tcEelarve))+'%'
				and journal1.proj like ltrim(rtrim(tcProjekt))+'%'
				and journal.rekvid in (select distinct id from tmprekv)

			group by journal1.deebet, journal.rekvid, rekv.nimetus, journal1.lisa_d, journal1.tunnus, journal1.kood1,journal1.kood5,journal1.proj ;


		-- kr

		insert into tmp_eelarve_aruanne1 (konto, RekvIdSub, AllAsutus, kr, tp_kr, tunnus, tegev,eelarve, projekt, rekvid, timestamp)
			select journal1.kreedit, journal.rekvid, rekv.nimetus, sum(journal1.summa*ifnull(dokvaluuta1.kuurs,1)), journal1.lisa_k, journal1.tunnus, journal1.kood1,journal1.kood5,
				journal1.proj, tnrekvid, lcreturn 
			from journal inner join journal1 on journal.id = journal1.parentid
				inner join rekv on journal.rekvid = rekv.id
				inner join tmprekv on journal.rekvId = tmprekv.id
				left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)

			where journal.kpv >= tdKpv1 and journal.kpv <= tdKpv2
				and journal1.kreedit like ltrim(rtrim(tcKonto))+'%'
				and journal1.lisa_k like ltrim(rtrim(tcTp))+'%'
				and journal.rekvId >= lnrekvid1 and journal.rekvid <= lnrekvid2
				and journal1.tunnus like ltrim(rtrim(tcTunnus))+'%'
				and journal1.kood1 like ltrim(rtrim(tcTegev))+'%'
				and journal1.kood2 like ltrim(rtrim(tcAllikas))+'%'
				and journal1.kood5 like ltrim(rtrim(tcEelarve))+'%'
				and journal1.proj like ltrim(rtrim(tcProjekt))+'%'
				and journal.rekvid in (select distinct id from tmprekv)
			group by journal1.kreedit, journal.rekvid, rekv.nimetus, journal1.lisa_k, journal1.tunnus, journal1.kood1,journal1.kood5,journal1.proj ;



	end if;



	return LCRETURN;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer) TO dbpeakasutaja;
