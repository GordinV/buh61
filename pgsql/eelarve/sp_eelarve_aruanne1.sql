-- Function: sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer)
/*
select sp_eelarve_aruanne1(63, date(2012,01,01), date(2012,03,31),0,'','','','','',8,0)
*/
-- DROP FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer);

CREATE OR REPLACE FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer)
  RETURNS character varying AS
$BODY$
DECLARE 
	tnrekvid alias for $1;
	tdKpv1 alias for $2;
	tdKpv2 alias for $3;
	tnRekvidSub alias for $4;
	tcAllikas alias for $5;
	tcTegev alias for $5;
	tcEelarve alias for $7;
	tcProjekt alias for $8;
	tcObjekt alias for $9;
	tnLiik alias for $10;
	tnSvod alias for $11;

	lcReturn varchar;
	lcReturnLopp varchar;
	lcString varchar;

	lnrekvid1 int;
	lnrekvid2 int;

	LNcOUNT int;
	lnSumma numeric(18,4);
	lnSumma2 numeric(18,4);
	lnSumma6 numeric(18,4);
	lnSumma0 numeric(18,4);

	lnPlaan numeric(18,4);
	lnTaitm numeric(18,4);

	v_eelaruanne record;
	v_tegev record;
	lcKood1 varchar;
	lcKood2 varchar;
	lcKood3 varchar;
	lcKood5 varchar;
	lnTase integer;

begin


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
			kood1 varchar(20) not null default space(20),
			kood2 varchar(20) not null default space(20),
			kood3 varchar(20) not null default space(20),
			kood4 varchar(20) not null default space(20),
			kood5 varchar(20) not null default space(20),
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

if tnSvod = 1 then
	lnTase = 3;

else
	lnTase = 9;
end if;

	lcreturn := to_char(now(), 'YYYYMMDDMISSSS');

raise notice 'tnLiik %',tnLiik;

if tnLiik = 8 or tnLiik = 81 then
--KOFS strateegia
-- eelarve
-- tulud


lcKood1 = '0001';
lcKood2 = '30';
lcKood3 = '3';

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			and (eelarve.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  eelarve.rekvid = tnRekvId)
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			and (eelarve.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  eelarve.rekvid = tnRekvId)
			group by kood4, library.nimetus;



	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			left outer join library on (library.kood = eeltaitmine.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and (eeltaitmine.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  eeltaitmine.rekvid = tnRekvId)
			group by kood5, library.nimetus;

--			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			left outer join library on (library.kood = taotlus1.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2
			and taotlus1.kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3
			and (taotlus.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  taotlus.rekvid = tnRekvId)
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			left outer join library on (library.kood = taotlus1.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1
			and (taotlus.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  taotlus.rekvid = tnRekvId)
			group by kood5, library.nimetus;


	select sum(summa1), sum(summa2), sum(summa4), sum(summa5), sum(summa6) into lnPlaan, lnTaitm, lnSumma, lnSumma2, lnSumma6 from tmp_eelproj_aruanne1 
		where kood5 like lcKood2+'%' and timestamp = lcReturn and rekvid = tnRekvId and kpv = date();

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values (lcKood1,lcKood2,lcKood3, lcKood2, 'Maksutulud', ifnull(lnPlaan,0), ifnull(lnTaitm,0), ifnull(lnSumma,0),ifnull(lnSumma2,0),
		ifnull(lnSumma6,0), lcReturn, date(), tnRekvId);

lcKood2 = '32';
if tnLiik = 81 then 
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			and (eelarve.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  eelarve.rekvid = tnRekvId)			
			group by kood4, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			and (eelarve.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  eelarve.rekvid = tnRekvId)			
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			left outer join library on (library.kood = eeltaitmine.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and (eeltaitmine.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  eeltaitmine.rekvid = tnRekvId)			
			group by kood5, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			left outer join library on (library.kood = taotlus1.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3
			and (taotlus.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  taotlus.rekvid = tnRekvId)			
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			left outer join library on (library.kood = taotlus1.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1
			and (taotlus.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, tnRekvId) > lnTase) or  taotlus.rekvid = tnRekvId)			
			group by kood5, library.nimetus;


end if; --tnLiik 81
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
		where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like lcKood2+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
		where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like lcKood2+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;


	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid) 
		values(lcKood1, lcKood2, lcKood3, '32', 'Tulud kaupade ja teenuste müügist' ,ifnull(lnPlaan,0),ifnull(lnTaitm,0),ifnull(lnSumma,0),ifnull(lnSumma2,0),
			ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);

lcKood2 = '35';
if tnLiik = 81 then
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 in (
			select kood from library where library = 'TULUDEALLIKAD' 
				AND (kood in ('352.00.17.1','352.00.17.2') 
				or kood like '3500%' 
				or (kood like '352%' and kood not like '352.0%'))
			)
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 in (
			select kood from library where library = 'TULUDEALLIKAD' 
				AND (kood in ('352.00.17.1','352.00.17.2') 
				or kood like '3500%' 
				or (kood like '352%' and kood not like '352.0%'))
			)
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eeltaitmine.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5  in (
			select kood from library where library = 'TULUDEALLIKAD' 
				AND (kood in ('352.00.17.1','352.00.17.2') 
				or kood like '3500%' 
				or (kood like '352%' and kood not like '352.0%'))
			)
			group by kood5, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = taotlus1.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 in (
			select kood from library where library = 'TULUDEALLIKAD' 
				AND (kood in ('352.00.17.1','352.00.17.2') 
				or kood like '3500%' 
				or (kood like '352%' and kood not like '352.0%'))
			)
			and taotlus.staatus = 3
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = taotlus1.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 in (
			select kood from library where library = 'TULUDEALLIKAD' 
				AND (kood in ('352.00.17.1','352.00.17.2') 
				or kood like '3500%' 
				or (kood like '352%' and kood not like '352.0%'))
			)
			and taotlus.staatus = 1
			group by kood5, library.nimetus;

end if; --tnLiik = 81
if tnLiik = 8 then

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
		where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and kood4 in (
			select kood from library where library = 'TULUDEALLIKAD' 
				AND (kood in ('352.00.17.1','352.00.17.2') 
				or kood like '3500%' 
				or (kood like '352%' and kood not like '352.0%'))
			);


	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
		where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and kood4 in (
			select kood from library where library = 'TULUDEALLIKAD' 
				AND (kood in ('352.00.17.1','352.00.17.2') 
				or kood like '3500%' 
				or (kood like '352%' and kood not like '352.0%'))
			);
/*
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 in (
			select kood from library where library = 'TULUDEALLIKAD' 
				AND (kood in ('352.00.17.1','352.00.17.2') 
				or kood like '3500%' 
				or (kood like '352%' and kood not like '352.0%'))
			);
*/

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 = '3500, 352';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 in (
			select kood from library where library = 'TULUDEALLIKAD' 
				AND (kood in ('352.00.17.1','352.00.17.2') 
				or kood like '3500%' 
				or (kood like '352%' and kood not like '352.0%'))
			);

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 in (
			select kood from library where library = 'TULUDEALLIKAD' 
				AND (kood in ('352.00.17.1','352.00.17.2') 
				or kood like '3500%' 
				or (kood like '352%' and kood not like '352.0%'))
			);



	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3,'3500, 352', 'Saadavad toetused tegevuskuludeks',ifnull(lnPlaan,0),-1*ifnull(lnTaitm,0),ifnull(lnSumma,0), ifnull(lnSumma2,0),
			 ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
		where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like '352.00.17.1%' ;


	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
		where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like '352.00.17.1%' ;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like '352.00.17.1%' ;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like '352.00.17.1%' 
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like '352.00.17.1%' 
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values( lcKood1, lcKood2, lcKood3,'352.00.17.1', 'Tasandusfond (lg 1)' ,ifnull(lnPlaan,0),ifnull(lnTaitm,0),ifnull(lnSumma,0), ifnull(lnSumma2,0),
			ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
		where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like '352.00.17.2%' ;


	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
		where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like '352.00.17.2%' ;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like '352.00.17.2%' ;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like '352.00.17.2%' 
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like '352.00.17.2%' 
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values( lcKood1, lcKood2, lcKood3,'352.00.17.2', 'Tasandusfond (lg 2)' ,ifnull(lnPlaan,0),ifnull(lnTaitm,0),ifnull(lnSumma,0), ifnull(lnSumma2,0),
			 ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);

end if; --tnLiik = 8
	select sum(summa1), sum(summa2), sum(summa4), sum(summa5), sum(summa6) into lnPlaan, lnTaitm, lnSumma, lnSumma2, lnSumma6 from tmp_eelproj_aruanne1 
		where (kood5 like lcKood2+'%' and kood5 not like '3502%')
		and timestamp = lcReturn 
		and rekvid = tnRekvId and kpv = date();

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values (lcKood1,lcKood2,lcKood3,lcKood2, 'Saadavad toetused tegevuskuludeks', ifnull(lnPlaan,0), ifnull(lntaitm,0),ifnull(lnSumma,0), ifnull(lnSumma2,0),
		ifnull(lnSumma6,0), lcReturn, date(), tnRekvId);

lcKood2 = '38';
--382500-382520
if tnLiik = 81 then
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and left(eelarve.kood4,4) in ('3825','3880','3882','3888')
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and left(eelarve.kood4,4) in ('3825','3880','3882','3888')
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eeltaitmine.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and left(kood5,4) in ('3825','3880','3882','3888')
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = taotlus1.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and left(kood5,4) in ('3825','3880','3882','3888')
			and taotlus.staatus = 3
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = taotlus1.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and left(kood5,4) in ('3825','3880','3882','3888')
			and taotlus.staatus = 1
			group by kood5, library.nimetus;

end if; --tnLiik = 81
if tnLiik = 8 then
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and left(ltrim(rtrim(eelarve.kood4)),4) = '3825';


	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and left(ltrim(rtrim(eelarve.kood4)),4) = '3825';
			
--			and val(ltrim(rtrim(eelarve.kood4))) >= 382500 and val(ltrim(rtrim(eelarve.kood4)))<=382520;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and left(ltrim(rtrim(kood5)),4) = '3825';
--			and val(ltrim(rtrim(kood5))) >= 382500 and val(ltrim(rtrim(kood5)))<=382520;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and left(ltrim(rtrim(kood5)),4) = '3825'
			and taotlus.staatus = 3;
--			and val(ltrim(rtrim(kood5))) >= 382500 and val(ltrim(rtrim(kood5)))<=382520

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and left(ltrim(rtrim(kood5)),4) = '3825'
			and taotlus.staatus = 1;
--			and val(ltrim(rtrim(kood5))) >= 382500 and val(ltrim(rtrim(kood5)))<=382520

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values (lcKood1, lcKood2, lcKood3, '3825', '  kaevandamisõiguse tasu, laekumine vee erikasutusest', ifnull(lnPlaan,0),ifnull(lnTaitm,0),ifnull(lnSumma,0),
		 ifnull(lnSumma2,0),ifnull(lnSumma6,0),	lcReturn, date(), tnRekvid);

--382540
--3880, 3888		

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(eelarve.kood4)) in ('3880','3888');
			
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(eelarve.kood4)) in ('3880','3888');

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) in ('3880','3888');

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and ltrim(rtrim(kood5)) in ('3880','3888')
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and ltrim(rtrim(kood5)) in ('3880','3888')
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, '3880,3888', '  Sh muud eelpool nimetamata muud tegevustulud ' ,ifnull(lnPlaan,0),ifnull(lnTaitm,0),
			ifnull(lnSumma,0), ifnull(lnSumma2,0), ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);


--3882			
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(eelarve.kood4)) = '3882';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(eelarve.kood4)) = '3882';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) = '3882';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and ltrim(rtrim(kood5)) = '3882'
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and ltrim(rtrim(kood5)) = '3882'
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, '3882', '  Sh saastetasud ja keskkonnale tekitatud kahju hüvitis' ,ifnull(lnPlaan,0),ifnull(lnTaitm,0),
			ifnull(lnSumma,0), ifnull(lnSumma2,0), ifnull(lnSumma6,0),lcReturn, date(), tnRekvid);

/*
--3888			
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(eelarve.kood4)) = '3888';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(eelarve.kood4)) = '3888';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) = '3888';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and ltrim(rtrim(kood5)) = '3888'
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and ltrim(rtrim(kood5)) = '3888'
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, '3888', 'eelpool nimetamata muud tulud' ,ifnull(lnPlaan,0),ifnull(lnTaitm,0),
			ifnull(lnSumma,0), ifnull(lnSumma2,0),ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);

*/
end if; --tnLiik = 8

	select sum(summa1), sum(summa2), sum(summa4), sum(summa5), sum(summa6) into lnPlaan, lnTaitm, lnSumma, lnSumma2, lnSumma6
		from tmp_eelproj_aruanne1 
		where kood5 like lcKood2+'%' and timestamp = lcReturn and rekvid = tnRekvId and kpv = date();

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values (lcKood1,lcKood2,lcKood3,lcKood2, 'Muud tegevustulud ', ifnull(lnPlaan,0),ifnull(lnTaitm,0), ifnull(lnSumma,0), ifnull(lnSumma2,0),
		ifnull(lnSumma6,0), lcReturn, date(), tnRekvId);

-- tulud kokku
lcKood2 = '3';
if tnLiik = 8 then
	select sum(summa1), sum(summa2), sum(summa4), sum(summa5), sum(summa6) into lnPlaan, lnTaitm, lnSumma, lnSumma2, lnSumma6 from tmp_eelproj_aruanne1 
		where kood5 in ('30','32','35','38') 
		and timestamp = lcReturn and rekvid = tnRekvId and kpv = date();
end if;
if tnLiik = 81 then
	select sum(summa1), sum(summa2),sum(summa4), sum(summa5), sum(summa6) into lnPlaan, lnTaitm, lnSumma, lnSumma2, lnSumma6 from tmp_eelproj_aruanne1 
		where kood5 in ('30','32','35','38') 
		and timestamp = lcReturn and rekvid = tnRekvId and kpv = date();

--		where kood5 in ('30','32','352.00.17.1','352.00.17.2','3500','352','388','382','3500, 352') 

end if;

	insert into tmp_eelproj_aruanne1 (kood1,kood2, kood3,kood5, nimetus, summa1, summa2,summa4, summa5, summa6, timestamp, kpv, rekvid)
		values (lcKood1,'','', '','PÕHITEGEVUSE TULUD KOKKU', ifnull(lnPlaan,0),ifnull(lntaitm,0), ifnull(lnSumma,0), ifnull(lnSumma2,0), 
		ifnull(lnSumma6,0), lcReturn, date(), tnRekvId);


-- kulud
lcKood1 = '0002';

lcKood2 = '40';

lcKood3 = '4';

if tnLiik = 81 then
	lcKood2 = '4';

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,left(kood4,2),lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,left(kood4,2),lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,left(kood5,2),lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eeltaitmine.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,left(kood5,2),lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = taotlus1.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3
			group by kood5,library.nimetus ;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,left(kood5,2),lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = taotlus1.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1
			group by kood5,library.nimetus;

end if; --tnLiik = 81

if tnLiik = 8 then
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 6
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, '40', 'Subsiidiumid ettevõtlusega tegelevatele isikutele',
			ifnull(lnPlaan,0),ifnull(lnTaitm,0),ifnull(lnSumma,0),ifnull(lnSumma2,0), ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);
end if; -- tnLiik = 8

lcKood2 = '413';
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;


	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values( lcKood1, lcKood2, lcKood3, '413', 'Sotsiaalabitoetused ja muud toetused füüsilistele isikutele',
			ifnull(lnPlaan,0), ifnull(lnTaitm,0), ifnull(lnSumma,0), ifnull(lnSumma2,0),ifnull(lnSumma6,0),
			lcReturn, date(), tnRekvid);
if tnLiik = 8 then
lcKood2 = '4500';
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;


	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5,summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, '4500', 'Sihtotstarbelised toetused tegevuskuludeks',ifnull(lnPlaan,0),ifnull(lnTaitm,0),ifnull(lnSumma,0), 
		ifnull(lnSumma2,0), ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);

lcKood2 = '452';
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5,summa6, timestamp, kpv, rekvid)
		values( lcKood1, lcKood2, lcKood3, '452', 'Mittesihtotstarbelised toetused',ifnull(lnPlaan,0),ifnull(lnTaitm,0),ifnull(lnSumma,0), ifnull(lnSumma2,0),
			 ifnull(lnSumma6,0),lcReturn, date(), tnRekvid);

	select sum(summa1), sum(summa2), sum(summa4), sum(summa5), sum(summa6) into lnPlaan, lnTaitm, lnSumma, lnSumma2, lnSumma6 from tmp_eelproj_aruanne1 
	where kood5 in ('40','413','4500','452') 
	 and timestamp = lcReturn and rekvid = tnRekvId and kpv = date();

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values (lcKood1,'4','4','4', 'Antavad toetused tegevuskuludeks ', ifnull(lnPlaan,0), ifnull(lnTaitm,0),ifnull(lnSumma,0), ifnull(lnSumma2,0), 
		ifnull(lnSumma6,0),lcReturn, date(), tnRekvId);

end if; -- tnLiik = 8
lcKood3 = '5';
lcKood2 = '50';
if tnLiik = 81 then
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,left(kood4,2),lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,left(kood4,2),lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,left(kood5,2),lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eeltaitmine.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,left(kood5,2),lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,left(kood5,2),lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1
			group by kood5, library.nimetus;

end if; --tnliik = 81

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';


	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;


	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, '50', 'Personalikulud',ifnull(lnPlaan,0),ifnull(lnTaitm,0), ifnull(lnSumma,0), ifnull(lnSumma2,0),
			ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);

lcKood2 = '55';
if tnLiik = 81 then
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,left(kood4,2),lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,left(kood4,2),lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,left(kood5,2),lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eeltaitmine.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,left(kood5,2),lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,left(kood5,2),lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1
			group by kood5, library.nimetus;

end if; -- tnLiik = 81

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, '55', 'Majandamiskulud' ,ifnull(lnPlaan,0), ifnull(lnTaitm,0), ifnull(lnSumma,0), ifnull(lnSumma2,0),
			ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);

lcKood2 = '60';
if tnLiik = 81 then

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,left(kood4,2),lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,left(kood4,2),lcKood3, kood4, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,left(kood5,2),lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eeltaitmine.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			group by kood5, library.nimetus;
			
	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,left(kood5,2),lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,left(kood5,2),lcKood3, kood5, ifnull(library.nimetus,space(254)) as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1
			group by kood5, library.nimetus;


end if; -- tnLiik = 81
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values( lcKood1, lcKood2, lcKood3, '60', 'Muud kulud',ifnull(lnPlaan,0), ifnull(lnTaitm,0),ifnull(lnSumma,0), ifnull(lnSumma2,0),
			ifnull(lnSumma6,0),lcReturn, date(), tnRekvid);

	select sum(summa1),sum(summa2), sum(summa4), sum(summa5), sum(summa6) into lnPlaan, lntaitm, lnSumma, lnSumma2, lnSumma6
	from tmp_eelproj_aruanne1 where kood5 in ('50','55','60') and timestamp = lcReturn and rekvid = tnRekvId and kpv = date();

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5,summa6, timestamp, kpv, rekvid)
		values (lcKood1,'5','5','5', 'Muud tegevuskulud', ifnull(lnPlaan,0), ifnull(lnTaitm,0), ifnull(lnSumma,0), ifnull(lnSumma2,0),
		ifnull(lnSumma6,0), lcReturn, date(), tnRekvId);


	select sum(summa1),sum(summa2), sum(summa4), sum(summa5), sum(summa6) into lnPlaan, lntaitm, lnSumma, lnSumma2, lnSumma6 from tmp_eelproj_aruanne1
		where kood5 in ('4','5') 
		and timestamp = lcReturn and rekvid = tnRekvId and kpv = date();

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values (lcKood1,'','','', 'PÕHITEGEVUSE KULUD KOKKU', ifnull(lnPlaan,0), ifnull(lnTaitm,0), ifnull(lnSumma,0), ifnull(lnSumma2,0),
		ifnull(lnSumma6,0), lcReturn, date(), tnRekvId);

lcKood1 = '0003';

	select summa1, summa2, summa6 into lnPlaan , lnTaitm, lnSumma6
		from tmp_eelproj_aruanne1 where nimetus = 'PÕHITEGEVUSE KULUD KOKKU' and timestamp = lcReturn and rekvid = tnRekvId and kpv = date();

	select summa1, summa2, summa6 into lnSumma, lnSumma2, lnSumma0
		from tmp_eelproj_aruanne1 where nimetus = 'PÕHITEGEVUSE TULUD KOKKU' and timestamp = lcReturn and rekvid = tnRekvId and kpv = date();


	lnPlaan = ifnull(lnSumma,0) - ifnull(lnPlaan,0);
	lnTaitm = ifnull(lnSumma2,0) - ifnull(lnTaitm,0);
	lnSumma6 = ifnull(lnSumma0,0) - ifnull(lnSumma6,0);
	
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa6, timestamp, kpv, rekvid)
		values (lcKood1,'','000','', 'PÕHITEGEVUSE TULEM', lnPlaan, lnTaitm, lnSumma6, lcReturn, date(), tnRekvId);

	select summa4, summa5 into lnPlaan , lnTaitm
		from tmp_eelproj_aruanne1 where nimetus = 'PÕHITEGEVUSE KULUD KOKKU' and timestamp = lcReturn and rekvid = tnRekvId and kpv = date();

	select summa4, summa5 into lnSumma, lnSumma2
		from tmp_eelproj_aruanne1 where nimetus = 'PÕHITEGEVUSE TULUD KOKKU' and timestamp = lcReturn and rekvid = tnRekvId and kpv = date();

	lnPlaan = ifnull(lnSumma,0) - ifnull(lnPlaan,0);
	lnTaitm = ifnull(lnSumma2,0) - ifnull(lnTaitm,0);

	update tmp_eelproj_aruanne1 set summa4 = lnPlaan, summa5 = lnTaitm where nimetus =  'PÕHITEGEVUSE TULEM'and timestamp = lcReturn and rekvid = tnRekvId and kpv = date();

lcKood1 = '0004';
--INVESTEERIMISTEGEVUS KOKKU

lcKood3 = '0';
lcKood2 = '381';
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		values (lcKood1,'','', '','INVESTEERIMISTEGEVUS KOKKU',0,lcReturn, date(), tnRekvid);

if tnLiik = 81 then
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'(+)',sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood4 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'(+)',sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood4 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(+)'  as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(+)'  as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(+)'  as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1
			group by kood5, library.nimetus;

end if;--tnLiik = 81
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, lcKood2, 'Põhivara müük (+)' ,ifnull(lnPlaan,0), ifnull(lnTaitm,0),ifnull(lnSumma,0), ifnull(lnSumma2,0),
			ifnull(lnSumma6,0),lcReturn, date(), tnRekvid);

lcKood3 = '0';
lcKood2 = '3502';
if tnLiik = 81 then
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'+' as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood4 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'+' as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood4 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(+) '  as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(+)'  as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(+)'  as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1
			group by kood5, library.nimetus;

end if;--tnLiik = 81
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, lcKood2, 'Põhivara soetuseks saadav sihtfinantseerimine(+) ' ,ifnull(lnPlaan,0), ifnull(lnTaitm,0),
			ifnull(lnSumma,0), ifnull(lnSumma2,0), ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);

lcKood3 = '0';
lcKood2 = '4502';
if tnLiik = 81 then

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'(-)' as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			left outer join library on (library.kood = kood4 AND library.library = 'TULUDEALLIKAD')					
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'(-)' as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			left outer join library on (library.kood = kood4 AND library.library = 'TULUDEALLIKAD')					
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(-)'  as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(-)'  as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(-)'  as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1
			group by kood5, library.nimetus;

end if;--tnLiik = 81
	select -1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select -1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select -1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select -1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;

	select -1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, lcKood2, 'Põhivara soetuseks antav sihtfinantseerimine(-) ' ,ifnull(lnPlaan,0), ifnull(lnTaitm,0),
			ifnull(lnSumma,0), ifnull(lnSumma2,0), ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);



lcKood2 = '15';
lcKood3 = '1';

if tnLiik = 81 then
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'(-)' as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood4 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'(-)' as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood4 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(-)'  as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(-)'  as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(-)'  as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1
			group by kood5, library.nimetus;


end if;--tnLiik = 81

	select -1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select -1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select -1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select -1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;

	select -1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, lcKood2, 'Põhivara soetus (-)' ,ifnull(lnPlaan,0), ifnull(lnTaitm,0), ifnull(lnSumma,0), ifnull(lnSumma2,0),
			 ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);


lcKood2 = '101.2.1';
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;
			
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, lcKood2, 'Osaluste müük (+)' ,ifnull(lnPlaan,0), ifnull(lnTaitm,0),ifnull(lnSumma,0), ifnull(lnSumma2,0),
			ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);

lcKood2 = '101.1.1';
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;
			
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, lcKood2, 'Osaluste soetus (-)' ,ifnull(lnPlaan,0), ifnull(lnTaitm,0),ifnull(lnSumma,0), ifnull(lnSumma2,0),
			ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);
 			
lcKood2 = '101.1.2';
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;
			
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, lcKood2, 'Muude aktsiate ja osade soetus (-)' ,ifnull(lnPlaan,0), ifnull(lnTaitm,0), ifnull(lnSumma,0), ifnull(lnSumma2,0),
			ifnull(lnSumma6,0),lcReturn, date(), tnRekvid);

lcKood2 = '1032.2';
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;
			
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, lcKood2, 'Tagasilaekuvad laenud (+)' ,ifnull(lnPlaan,0), ifnull(lnTaitm,0),ifnull(lnSumma,0), ifnull(lnSumma2,0),
			ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);

lcKood2 = '1032.1';
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;
			
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;


	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, lcKood2, 'Antavad laenud (-)' ,ifnull(lnPlaan,0), ifnull(lnTaitm,0),ifnull(lnSumma,0), ifnull(lnSumma2,0),
			ifnull(lnSumma6,0), lcReturn, date(), tnRekvid);

lcKood2 = '382';
lcKood3 = '4';
if tnLiik = 81 then
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'(+)' as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%' and eelarve.kood4 <> '3825'
			group by kood4, library.nimetus;
			
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'(+)' as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%' and eelarve.kood4 <> '3825'
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(+)'  as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eeltaitmine.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like ltrim(rtrim(lcKood2))+'%' and kood5 <> '3825'
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(+)'  as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 like ltrim(rtrim(lcKood2))+'%' and kood5 <> '3825'
			and taotlus.staatus = 3
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(+)'  as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 like ltrim(rtrim(lcKood2))+'%' and kood5 <> '3825'
			and taotlus.staatus = 1
			group by kood5, library.nimetus;

end if;--tnLiik = 81
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and left(kood4,4) in ('3820','3823');

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and left(kood4,4) in ('3820','3823');

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(left(kood5,4))) in ('3820','3823');

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and LEFT(taotlus1.kood5,4) in ('3820','3823')
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and LEFT(taotlus1.kood5,4) in ('3820','3823')
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, lcKood2, 'Finantstulud (+)' ,ifnull(lnPlaan,0), ifnull(lnTaitm,0),ifnull(lnSumma,0),ifnull(lnSumma2,0),
			ifnull(lnSumma6,0),lcReturn, date(), tnRekvid);

lcKood2 = '65';
lcKood3 = '5';
if tnLiik = 81 then
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'(-)' as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'(-)' as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and eelarve.kood4 like ltrim(rtrim(lcKood2))+'%'
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(-)'  as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eeltaitmine.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and kood5 like ltrim(rtrim(lcKood2))+'%'
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(-)'  as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(-)'  as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1
			group by kood5, library.nimetus;
		
end if;--tnLiik = 81
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and ltrim(rtrim(kood4)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and ltrim(rtrim(kood5)) like ltrim(rtrim(lcKood2))+'%';

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and taotlus1.kood5 like ltrim(rtrim(lcKood2))+'%'
			and taotlus.staatus = 1;


if tnLiik = 81 then
--6501
	select sum(summa1) as Summa1, sum(summa2) as Summa2, sum(summa4) as summa4, sum(summa5) as summa5, sum(summa6) as summa6 into v_eelaruanne from tmp_eelproj_aruanne1 
		where timestamp = lcreturn and kpv = date() and rekvid = tnRekvId 
		and kood1 = lcKood1 
		and ltrim(rtrim(kood5)) like '6501%';

	if (select count(*) from tmp_eelproj_aruanne1 where timestamp = lcReturn and kood5 = '6501') = 0 then
		insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid) values 
		(lcKood1,lcKood2,lcKood3,'6501','Intressi-, viivise- ja kohustistasukulud võetud laenudelt (-)',
		ifnull(v_eelaruanne.summa1,0),ifnull(v_eelaruanne.summa2,0),ifnull(v_eelaruanne.summa4,0),ifnull(v_eelaruanne.summa5,0),ifnull(v_eelaruanne.summa6,0),
		lcReturn, date(), tnRekvid);
	else
		update tmp_eelproj_aruanne1 set summa1 =  v_eelaruanne.summa1, 
		summa2 = v_eelaruanne.summa2,
		summa4 = v_eelaruanne.summa4,
		summa5 = v_eelaruanne.summa5,
		summa6 = v_eelaruanne.summa6
		where timestamp = lcreturn and kpv = date() and rekvid = tnRekvId and kood1 = lcKood1 and kood5 = '6501';
	end if;

end if;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, lcKood2, 'Finantstkulud (-)' ,-1*ifnull(lnPlaan,0), -1*ifnull(lnTaitm,0),-1*ifnull(lnSumma,0), -1*ifnull(lnSumma2,0),
			-1*ifnull(lnSumma6,0),lcReturn, date(), tnRekvid);

if tnLiik = 8 then
	select sum(summa1) as Summa1, sum(summa2) as Summa2, sum(summa4) as summa4, sum(summa5) as summa5, sum(summa6) as summa6 into v_eelaruanne from tmp_eelproj_aruanne1 
		where timestamp = lcreturn and kpv = date() and rekvid = tnRekvId 
		and kood1 = lcKood1; 
end if;
if tnLiik = 81 then
	select sum(summa1) as Summa1, sum(summa2) as Summa2, sum(summa4) as summa4, sum(summa5) as summa5, sum(summa6) as summa6 into v_eelaruanne from tmp_eelproj_aruanne1 
		where timestamp = lcreturn and kpv = date() and rekvid = tnRekvId 
		and kood1 = lcKood1 
		and ltrim(rtrim(kood5)) in ('381','382','3502','65');
 
end if;
	update tmp_eelproj_aruanne1 set summa1 =  v_eelaruanne.summa1, 
		summa2 = v_eelaruanne.summa2,
		summa4 = v_eelaruanne.summa4,
		summa5 = v_eelaruanne.summa5,
		summa6 = v_eelaruanne.summa6
		where timestamp = lcreturn and kpv = date() and rekvid = tnRekvId and kood1 = lcKood1 and nimetus = 'INVESTEERIMISTEGEVUS KOKKU';

--EELARVE TULEM (ÜLEJÄÄK (+) / PUUDUJÄÄK (-))
/*	select sum(summa1) as Summa, sum(summa2) as Summa1, sum(summa4) as summa4, sum(summa5) as summa5 into v_eelaruanne from tmp_eelproj_aruanne1 
		where timestamp = lcreturn and kpv = date() and rekvid = tnRekvId and kood1 = lcKood1
		and ltrim(rtrim(kood5)) in ('381','3502','101.2.1','101.2.2','1032.2','382');

	lnPlaan = v_eelaruanne.Summa;
	lnTaitm = v_eelaruanne.Summa1;
	lnSumma = v_eelaruanne.Summa4;
	lnSumma2 = v_eelaruanne.Summa5;
*/	
	select sum(summa1) as Summa1, sum(summa2) as Summa2, sum(summa4) as summa4, sum(summa5) as summa5, sum(summa6) as summa6 into v_eelaruanne from tmp_eelproj_aruanne1 
		where timestamp = lcreturn and kpv = date() and rekvid = tnRekvId 
		and nimetus in ('PÕHITEGEVUSE TULEM','INVESTEERIMISTEGEVUS KOKKU');

--	if ifnull(v_eelaruanne.Summa,0) > 0 and ifnull(v_eelaruanne.Summa1,0) > 0 then
		insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2,summa4, summa5, summa6, timestamp, kpv, rekvid)
			values(lcKood1, lcKood2, '66', '', 'EELARVE TULEM (ÜLEJÄÄK (+) / PUUDUJÄÄK (-))' ,
			ifnull(v_eelaruanne.Summa1,0), ifnull(v_eelaruanne.Summa2,0), ifnull(v_eelaruanne.Summa4,0), ifnull(v_eelaruanne.Summa5,0),
			ifnull(v_eelaruanne.Summa6,0), lcReturn, date(), tnRekvid);
--	end if;
/*
if tnLiik = 81 then
	select sum(summa1), sum(summa2), sum(summa4), sum(summa5) into lnPlaan, lnTaitm, lnSumma, lnSumma2 
		from tmp_eelproj_aruanne1 where timestamp = lcReturn and kood1 = lcKood1;

	update tmp_eelproj_aruanne1 set summa1 = ifnull(lnPlaan,0), summa2 = ifnull(lnTaitm,0), summa4 = ifnull(lnSumma,0), summa5 = ifnull(lnSumma2,0)
		where timestamp = lcReturn and kood1 = lcKood1 and nimetus = 'INVESTEERIMISTEGEVUS KOKKU';
end if;
*/
	-- FINANTSEERIMISTEGEVUS
lcKood1 = '0005';
lcKood2 = '20.5';
lcKood3 = '0';

if tnLiik = 81 then
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'(+)' as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and (eelarve.kood4 like '2080.5%' or eelarve.kood4 like '2081.5%' or eelarve.kood4 like '2082.5%')
			group by kood4, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'(+)' as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and (eelarve.kood4 like '2080.5%' or eelarve.kood4 like '2081.5%' or eelarve.kood4 like '2082.5%')
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(+)'  as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eeltaitmine.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and (eeltaitmine.kood5 like '2080.5%' or eeltaitmine.kood5 like '2081.5%' or eeltaitmine.kood5 like '2082.5%')
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(+)'  as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and (kood5 like '2080.5%' or kood5 like '2081.5%' or kood5 like '2082.5%')
			and taotlus.staatus = 3
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(+)'  as nimetus,sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and (kood5 like '2080.5%' or kood5 like '2081.5%' or kood5 like '2082.5%')
			and taotlus.staatus = 1
			group by kood5, library.nimetus;

end if;--tnLiik = 81
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and (eelarve.kood4 like '2080.5%' or eelarve.kood4 like '2081.5%' or eelarve.kood4 like '2082.5%');

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and (eelarve.kood4 like '2080.5%' or eelarve.kood4 like '2081.5%' or eelarve.kood4 like '2082.5%');

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and (eeltaitmine.kood5 like '2080.5%' or eeltaitmine.kood5 like '2081.5%' or eeltaitmine.kood5 like '2082.5%');

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and (kood5 like '2080.5%' or kood5 like '2081.5%' or kood5 like '2082.5%')
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and (kood5 like '2080.5%' or kood5 like '2081.5%' or kood5 like '2082.5%')
			and taotlus.staatus = 1;


	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, lcKood2, 'Kohustuste võtmine (+)' ,ifnull(lnPlaan,0), ifnull(lnTaitm,0),ifnull(lnSumma,0), ifnull(lnSumma2,0), 
			ifnull(lnSumma6,0),lcReturn, date(), tnRekvid);

lcKood2 = '20.6';
if tnLiik = 81 then
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa6, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'(-)' as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and (eelarve.kood4 like '2080.6%' or eelarve.kood4 like '2081.6%' or eelarve.kood4 like '2082.6%')
			group by kood4, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood4, ifnull(library.nimetus,space(254))+'(-)' as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and (eelarve.kood4 like '2080.6%' or eelarve.kood4 like '2081.6%' or eelarve.kood4 like '2082.6%')
			group by kood4, library.nimetus;


	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa2, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(-)'  as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join library on (library.kood = eeltaitmine.kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and (eeltaitmine.kood5 like '2080.6%' or eeltaitmine.kood5 like '2081.6%' or eeltaitmine.kood5 like '2082.6%')
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa4, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(-)'  as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and (kood5 like '2080.6%' or kood5 like '2081.6%' or kood5 like '2082.6%')
			and taotlus.staatus = 3
			group by kood5, library.nimetus;

	insert into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood5, nimetus, summa5, timestamp, kpv, rekvid)
		select lcKood1,lcKood2,lcKood3, kood5, ifnull(library.nimetus,space(254))+'(-)'  as nimetus,-1*sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa,
			lcReturn, date(), tnRekvid
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join library on (library.kood = kood5 AND library.library = 'TULUDEALLIKAD')					
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and (kood5 like '2080.6%' or kood5 like '2081.6%' or kood5 like '2082.6%')
			and taotlus.staatus = 1
			group by kood5, library.nimetus;


end if;--tnLiik = 81
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and (eelarve.kood4 like '2080.6%' or eelarve.kood4 like '2081.6%' or eelarve.kood4 like '2082.6%');

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and (eelarve.kood4 like '2080.6%' or eelarve.kood4 like '2081.6%' or eelarve.kood4 like '2082.6%');

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
		from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and (eeltaitmine.kood5 like '2080.6%' or eeltaitmine.kood5 like '2081.6%' or eeltaitmine.kood5 like '2082.6%');

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma 
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and (kood5 like '2080.6%' or kood5 like '2081.6%' or kood5 like '2082.6%')
			and taotlus.staatus = 3;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and (kood5 like '2080.6%' or kood5 like '2081.6%' or kood5 like '2082.6%')
			and taotlus.staatus = 1;

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		values(lcKood1, lcKood2, lcKood3, lcKood2, 'Kohustuste tasumine (-)' ,-1*ifnull(lnPlaan,0), -1*ifnull(lnTaitm,0),
			-1*ifnull(lnSumma,0),-1*ifnull(lnSumma2,0),-1*ifnull(lnSumma6,0),
			lcReturn, date(), tnRekvid);

--FINANTSEERIMISTEGEVUS
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		select lcKood1, lcKood2, lcKood3, '', 'FINANTSEERIMISTEGEVUS',sum(summa1) as summa1, sum(summa2) as summa2, sum(summa4) as summa4, sum(summa5) as summa5,
			sum(summa6) as summa6,lcReturn, date(), tnRekvid
		from tmp_eelproj_aruanne1
		where timestamp = lcReturn and kood5 in ('20.6','20.5');
			

--PÕHITEGEVUSE KULUDE JA INVESTEERIMISTEGEVUSE VÄLJAMINEKUTE JAOTUS TEGEVUSALADE JÄRGI

	lcKood1 = '0006';
	for 	v_tegev in
		select distinct ltrim(rtrim(kood)) as kood, nimetus from library where library = 'TEGEV' order by kood 
--		and kood in (select distinct kood1 from eelarve where aasta = year(tdKpv2)) order by kood
	loop
		lnPlaan = 0;
		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where ifnull(eelarve.kpv,tdKpv2) <= tdKpv2
			and aasta = year(tdKpv2)
			and (left(kood4,1) in ('4','5','6') or left(kood4,2) = '15')
			and ltrim(rtrim(kood1)) = v_tegev.kood;

		lnPlaan = ifnull(lnPlaan,0);

		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma6
		from eelarve 
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.tunnus = 0
			and aasta = year(tdKpv2)
			and (left(kood4,1) in ('4','5','6') or left(kood4,2) = '15')
			and ltrim(rtrim(kood1)) = v_tegev.kood;


	raise notice 'Tegevus lnPlaan %',lnPlaan;
	
		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTaitm 
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2) and kuu <= month(tdKpv2)
			and (left(kood5,1) in ('4','5','6') or left(kood5,2) = '15')
			and ltrim(rtrim(kood1)) =  v_tegev.kood;

		lnTaitm = ifnull(lnTaitm,0);


		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and (left(kood5,1) in ('4','5','6') or left(kood5,2) = '15')
			and ltrim(rtrim(kood1)) =  v_tegev.kood
			and taotlus.staatus = 3;

		lnSumma = ifnull(lnSumma,0);

		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma2
		from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id	
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2 
			and ltrim(rtrim(kood1)) =  v_tegev.kood
			and (left(kood5,1) in ('4','5','6') or left(kood5,2) = '15')
			and taotlus.staatus = 1;

		lnSumma2 = ifnull(lnSumma2,0);

		insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
			values(lcKood1, '', '', v_tegev.kood, v_tegev.nimetus ,ifnull(lnPlaan,0), ifnull(lnTaitm,0),ifnull(lnSumma,0), ifnull(lnSumma2,0), 
			ifnull(lnSumma6,0),lcReturn, date(), tnRekvid);

	end loop;
	
	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5, summa6, timestamp, kpv, rekvid)
		select lcKood1, '', '', '', 'PÕHITEGEVUSE KULUDE JA INVESTEERIMISTEGEVUSE VÄLJAMINEKUTE JAOTUS TEGEVUSALADE JÄRGI', 
		sum(summa1), sum(summa2),sum(summa4), sum(summa5),sum(summa6),lcReturn, date(), tnRekvid
		from tmp_eelproj_aruanne1
		where timestamp = lcReturn and kpv = date() and rekvid = tnRekvid and kood1 = lcKood1;
	

	insert into tmp_eelproj_aruanne1 (kood1,kood2,kood3,kood5, nimetus, summa1, summa2, summa4, summa5,summa6, timestamp, kpv, rekvid)
		select kood1, kood2, kood3, kood5, nimetus, sum(summa1), sum(summa2), sum(summa4),sum(summa5),sum(summa6),lcreturn+'LOPP', date(), tnRekvid 
		from tmp_eelproj_aruanne1
		where timestamp = lcReturn and kpv = date() and rekvid = tnRekvid
		group by kood1, kood2, kood3,kood5, nimetus
		order by kood1, kood2, kood3, kood5;

	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn; 
	lcReturn = lcReturn + 'LOPP';
	delete from tmp_eelproj_aruanne1 where timestamp = lcreturn and summa1 = 0 AND summa2 = 0 and summa4 = 0 and summa5 = 0 and summa6 = 0;

end if;

if tnLiik = 7 then
	--Narva linna 2009.a eelarve alaeelarvete kinnitamine asutuste loikes
	--  Pohieelarve   		
		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Tegev, Eelarve, Nimetus, summa1,timestamp,rekvid)
			select taotlus.rekvid, taotlus1.kood1, 
			taotlus1.kood5, library.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id						
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2
			and taotlus.staatus = 3
			and taotlus1.kood2 in ('LE-P', 'LE-RF');
--			inner join eelproj on taotlus1.eelprojid = eelproj.id

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Tegev, Eelarve, Nimetus, summa11,timestamp,rekvid)
			select taotlus.rekvid, taotlus1.kood1, 
			taotlus1.kood5, library.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id						
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2
			and taotlus.staatus =1
			and taotlus1.kood2 in ('LE-P', 'LE-RF');

--			inner join eelproj on taotlus1.eelprojid = eelproj.id
	--  Laenude arvelt   		

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Tegev, Eelarve, Nimetus, summa2,timestamp,rekvid)
			select taotlus.rekvid, taotlus1.kood1, 
			taotlus1.kood5, library.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id			
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2
			and taotlus.staatus = 3
			and taotlus1.kood2 in ('LE-LA');

--			inner join eelproj on taotlus1.eelprojid = eelproj.id


		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Tegev, Eelarve, Nimetus, summa12,timestamp,rekvid)
			select taotlus.rekvid, taotlus1.kood1, 
			taotlus1.kood5, library.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id			
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2
			and taotlus.staatus = 1
			and taotlus1.kood2 in ('LE-LA');

--			inner join eelproj on taotlus1.eelprojid = eelproj.id

	--  	RIIGIEELARVE		

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Tegev, Eelarve, Nimetus, summa3,timestamp,rekvid)
			select taotlus.rekvid,  taotlus1.kood1, 
			taotlus1.kood5, library.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id						
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2
			and taotlus.staatus = 3
			and left(taotlus1.kood2,2) in ('RE');

--			inner join eelproj on taotlus1.eelprojid = eelproj.id


		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Tegev, Eelarve, Nimetus, summa13,timestamp,rekvid)
			select taotlus.rekvid,  taotlus1.kood1, 
			taotlus1.kood5, library.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id						
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2) and taotlus.kpv <= tdKpv2
			and taotlus.staatus = 1
			and left(taotlus1.kood2,2) in ('RE');

--			inner join eelproj on taotlus1.eelprojid = eelproj.id

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, tegev, Eelarve, Nimetus,  summa1, summa2, summa3, summa11, summa12, summa13, timestamp,rekvid)
		select RekvIdSub,  tegev, eelarve, nimetus, 
		 sum(summa1), sum(summa2), sum(summa3), sum(summa11), sum(summa12), sum(summa13),
		lcreturn+'LOPP', tnrekvId from tmp_eelproj_aruanne1  
		where timestamp = lcReturn
		group by RekvIdSub, tegev, eelarve, nimetus
		order by rekvidsub, tegev, eelarve;

		--kond 1

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, tegev, Eelarve, Nimetus,  summa1, summa2, summa3,summa11, summa12, summa13,  timestamp,rekvid)
		select RekvIdSub,  tegev, ' '+left(tmp_eelproj_aruanne1.eelarve,1), library.nimetus, 
		 sum(summa1), sum(summa2), sum(summa3), sum(summa11), sum(summa12), sum(summa13),
		lcreturn+'LOPP', tnrekvId 
		from tmp_eelproj_aruanne1  			
		inner join library on (library.kood = left(tmp_eelproj_aruanne1.eelarve,1) and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
		where timestamp = lcReturn
		group by RekvIdSub, tegev, left(tmp_eelproj_aruanne1.eelarve,1), library.nimetus
		order by rekvidsub, tegev, left(tmp_eelproj_aruanne1.eelarve,1);

		--kond 2

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, tegev, Eelarve, Nimetus,  summa1, summa2, summa3,summa11, summa12, summa13,  timestamp,rekvid)
		select RekvIdSub,  tegev, '  '+left(tmp_eelproj_aruanne1.eelarve,2), library.nimetus,
		 sum(summa1), sum(summa2), sum(summa3), sum(summa11), sum(summa12), sum(summa13),
		lcreturn+'LOPP', tnrekvId 
		from tmp_eelproj_aruanne1  			
		inner join library on (library.kood = left(tmp_eelproj_aruanne1.eelarve,2) and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
		where timestamp = lcReturn
		group by RekvIdSub, tegev, left(tmp_eelproj_aruanne1.eelarve,2), library.nimetus
		order by rekvidsub, tegev, left(tmp_eelproj_aruanne1.eelarve,2);

		--kond 3

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, tegev, Eelarve, Nimetus,  summa1, summa2, summa3, summa11, summa12, summa13, timestamp,rekvid)
		select RekvIdSub,  '999999', '99999', 'Kokku', sum(summa1), sum(summa2), sum(summa3), sum(summa11), sum(summa12), sum(summa13), lcreturn+'LOPP', tnrekvId 
		from tmp_eelproj_aruanne1  			
		where timestamp = lcReturn
		group by RekvIdSub
		order by rekvidsub;

		delete from tmp_eelproj_aruanne1 where timestamp = lcReturn;

		lcReturn = lcReturn + 'LOPP';

end if;




if tnLiik = 6 then
	--Asutuse 2009.a eelarve eelnõu allikate lõikes
		raise notice 'Asutuse 2009.a eelarve eelnõu allikate lõikes';
	--  Põhieelarve   		

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, allikas, Tegev, Eelarve, Nimetus, summa1,timestamp,rekvid)
			select taotlus.rekvid, taotlus1.kood2, taotlus1.kood1, 
			taotlus1.kood5, kulud.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id						
			inner join library kulud on (taotlus1.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 3
			and taotlus1.kood2 in ('LE-P', 'LE-RF');

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, allikas, Tegev, Eelarve, Nimetus, summa11,timestamp,rekvid)
			select taotlus.rekvid, taotlus1.kood2, taotlus1.kood1, 
			taotlus1.kood5, kulud.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id						
			inner join library kulud on (taotlus1.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 1
			and taotlus1.kood2 in ('LE-P', 'LE-RF');



	--  Laenude arvelt   		

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, allikas, Tegev, Eelarve, Nimetus, summa2,timestamp,rekvid)
			select taotlus.rekvid, taotlus1.kood2, taotlus1.kood1, 
			taotlus1.kood5, kulud.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id						
			inner join library kulud on (taotlus1.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 3
			and taotlus1.kood2 in ('LE-LA');

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, allikas, Tegev, Eelarve, Nimetus, summa12,timestamp,rekvid)
			select taotlus.rekvid, taotlus1.kood2, taotlus1.kood1, 
			taotlus1.kood5, kulud.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id						
			inner join library kulud on (taotlus1.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 1
			and taotlus1.kood2 in ('LE-LA');

	--  	RIIGIEELARVE		

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, allikas, Tegev, Eelarve, Nimetus, summa3,timestamp,rekvid)
			select taotlus.rekvid, taotlus1.kood2, taotlus1.kood1, 
			taotlus1.kood5, kulud.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id				
			inner join library kulud on (taotlus1.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 3
			and taotlus1.kood2 in ('RE');
			
		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, allikas, Tegev, Eelarve, Nimetus, summa13,timestamp,rekvid)
			select taotlus.rekvid, taotlus1.kood2, taotlus1.kood1, 
			taotlus1.kood5, kulud.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id				
			inner join library kulud on (taotlus1.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 1
			and taotlus1.kood2 in ('RE');


	--  	Sihtotstarbelised laekumised		

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, allikas, Tegev, Eelarve, Nimetus, summa4,timestamp,rekvid)
			select taotlus.rekvid, taotlus1.kood2, taotlus1.kood1, 
			taotlus1.kood5, kulud.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id			
			inner join library kulud on (taotlus1.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 3
			and taotlus1.kood2 in ('60');
 		
		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, allikas, Tegev, Eelarve, Nimetus, summa14,timestamp,rekvid)
			select taotlus.rekvid, taotlus1.kood2, taotlus1.kood1, 
			taotlus1.kood5, kulud.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id			
			inner join library kulud on (taotlus1.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 1
			and taotlus1.kood2 in ('60');


		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, allikas, tegev, Eelarve, Nimetus, 
			summa1, summa2, summa3, summa4, summa5, summa11, summa12, summa13, summa14, summa15,
		 timestamp,rekvid)
		select RekvIdSub, allikas, tegev, eelarve, nimetus, 
		sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa1+summa2+summa3+summa4+summa5), 
		sum(summa11), sum(summa12), sum(summa13), sum(summa14), sum(summa11+summa12+summa13+summa14+summa15), 
		lcreturn+'LOPP', tnrekvId from tmp_eelproj_aruanne1  
		where timestamp = lcReturn
		group by RekvIdSub, allikas,tegev, eelarve, nimetus
		order by rekvidsub, allikas, tegev, eelarve;

		delete from tmp_eelproj_aruanne1 where timestamp = lcReturn;

		lcReturn = lcReturn + 'LOPP';

end if;


if tnLiik = 5 then
	--Asutuse 2009.a eelarve eelnõu (hallatavate asutuse ja tegevusalade lõikes)
		raise notice 'Asutuse 2009.a eelarve eelnõu (hallatavate asutuse ja tegevusalade lõikes)';
	--  eelmine aasta  eelarve täitmine   		

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, tegev, Eelarve, Nimetus, summa1,timestamp,rekvid)
			select eeltaitmine.rekvid, eeltaitmine.kood1,
			 eeltaitmine.kood5, kulud.nimetus, eeltaitmine.summa * ifnull(dokvaluuta1.kuurs,1), lcreturn, tnrekvId 
			 from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id			
			inner join library kulud on (eeltaitmine.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)						
			where eeltaitmine.aasta = year(tdKpv2)-1;
--			group by  eeltaitmine.rekvid, eeltaitmine.kood5, library.nimetus;

		-- 2007.a. eelarve täitmine (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)      

		INSERT into tmp_eelproj_aruanne1 ( rekvidSub, Tegev, Eelarve, Nimetus, summa2,timestamp,rekvid)
			select eeltaitmine.rekvid, eeltaitmine.kood1,
			eeltaitmine.kood5, kulud.nimetus, eeltaitmine.summa * ifnull(dokvaluuta1.kuurs,1) , lcreturn, tnrekvId 
			from eeltaitmine
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id			
			inner join library kulud on (eeltaitmine.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)						
			where eeltaitmine.aasta = year(tdKpv2)-1
			and (kood2 in ('LE-P','LE-RF') or empty(kood2));

		-- 2008.a. eelarve (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)  

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Tegev, Eelarve, Nimetus, summa3,timestamp,rekvid)
			select eelarve.rekvid, eelarve.kood1,
			eelarve.kood4, kulud.nimetus, eelarve.summa * ifnull(dokvaluuta1.kuurs,1), lcreturn, tnrekvId 
			from eelarve
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id	
			inner join library kulud on (eelarve.kood4 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)											
			where eelarve.aasta = year(tdKpv2)
			and eelarve.tunnus = 0
			and (eelarve.kood2 in ('LE-P','LE-RF') or empty(eelarve.kood2));




		-- 2008.a. täpsustatud eelarve seisuga 30.06.2008.a (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)     

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Tegev, Eelarve, Nimetus, summa4,timestamp,rekvid)
			select eelarve.rekvid, eelarve.kood1,
			eelarve.kood4, kulud.nimetus, eelarve.summa * ifnull(dokvaluuta1.kuurs,1), lcreturn, tnrekvId 
			from eelarve
			inner join library kulud on (eelarve.kood4 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id			
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)											
			where eelarve.aasta = year(tdKpv2)
			and (eelarve.kpv <= tdkpv2 or empty(eelarve.kpv))
			and (eelarve.kood2 in ('LE-P','LE-RF') or empty(eelarve.kood2));

--			JOIN faktkulud ON ltrim(rtrim(eelarve.kood4::text)) ~~ ltrim(rtrim(faktkulud.kood::text))			

		-- 2008.a eelarve täitmine seisuga 30.06.2008.a (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)  

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, tegev, Eelarve, Nimetus, summa5,timestamp,rekvid)
			select curkassaKuludeTaitmine.rekvid, curkassaKuludeTaitmine.tegev,
			curkassakuludetaitmine.kood, library.nimetus, summa,lcreturn, tnrekvId 
			from curkassakuludetaitmine 
			inner join library on (library.kood = curkassakuludetaitmine.kood and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on curkassaKuludeTaitmine.rekvid = tmpRekv.id			
			where curkassakuludetaitmine.aasta = year(tdKpv2)
			and curkassakuludetaitmine.kuu <= month(tdKpv2)
			and (curkassakuludetaitmine.kood2 in ('LE-P','LE-RF') or empty(curkassakuludetaitmine.kood2));

		-- 2009.a. eelarve eelnõu (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta) 


		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Tegev, Eelarve, Nimetus, summa6,timestamp,rekvid)
			select taotlus.rekvid, taotlus1.kood1, 
			taotlus1.kood5, library.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id			
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)											
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 3
			and taotlus1.kood2 in ('LE-P');

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Tegev, Eelarve, Nimetus, summa16,timestamp,rekvid)
			select taotlus.rekvid, taotlus1.kood1, 
			taotlus1.kood5, library.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id			
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)											
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 1
			and taotlus1.kood2 in ('LE-P');

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, tegev, Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6, summa16, timestamp,rekvid)
		select RekvIdSub, tegev, eelarve, nimetus, sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa5), sum(summa6), sum(summa16),
			lcreturn+'LOPP', tnrekvId from tmp_eelproj_aruanne1  
		where timestamp = lcReturn
		group by RekvIdSub, tegev, eelarve, nimetus
		order by rekvidsub, tegev, eelarve;

		delete from tmp_eelproj_aruanne1 where timestamp = lcReturn;

		lcReturn = lcReturn + 'LOPP';

end if;


if tnLiik = 4 then
	--asutuse eelarve eelnõu koos hal
		raise notice 'asutuse eelarve eelnõu koos hal';
	--  eelmine aasta  eelarve täitmine   		

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Eelarve, Nimetus, summa1,timestamp,rekvid)
			select eeltaitmine.rekvid, 
			 eeltaitmine.kood5, library.nimetus, eeltaitmine.summa * ifnull(dokvaluuta1.kuurs,1) , lcreturn, tnrekvId 
			 from eeltaitmine
			inner join library on (library.kood = eeltaitmine.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id			
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)						
			where eeltaitmine.aasta = year(tdKpv2)-1;
--			group by  eeltaitmine.rekvid, eeltaitmine.kood5, library.nimetus;

		-- 2007.a. eelarve täitmine (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)      

		INSERT into tmp_eelproj_aruanne1 ( rekvidSub, Eelarve, Nimetus, summa2,timestamp,rekvid)
			select eeltaitmine.rekvid, 
			eeltaitmine.kood5, library.nimetus, eeltaitmine.summa * ifnull(dokvaluuta1.kuurs,1), lcreturn, tnrekvId 
			from eeltaitmine
			inner join library on (library.kood = eeltaitmine.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id			
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)						
			where eeltaitmine.aasta = year(tdKpv2)-1
			and (kood2 in ('LE-P','LE-RF') or empty(kood2));

		-- 2008.a. eelarve (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)  

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Eelarve, Nimetus, summa3,timestamp,rekvid)
			select eelarve.rekvid, 
			eelarve.kood4, library.nimetus, eelarve.summa * ifnull(dokvaluuta1.kuurs,1), lcreturn, tnrekvId 
			from eelarve
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id			
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)						
			where eelarve.aasta = year(tdKpv2)
			and eelarve.tunnus = 0
			and (eelarve.kood2 in ('LE-P','LE-RF') or empty(eelarve.kood2));

		-- 2008.a. täpsustatud eelarve seisuga 30.06.2008.a (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)     

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Eelarve, Nimetus, summa4,timestamp,rekvid)
			select eelarve.rekvid, 
			eelarve.kood4, library.nimetus, eelarve.summa * ifnull(dokvaluuta1.kuurs,1), lcreturn, tnrekvId 
			from eelarve
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id			
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)						
			where eelarve.aasta = year(tdKpv2)
			and (eelarve.kpv <= tdkpv2 or empty(eelarve.kpv))
			and (eelarve.kood2 in ('LE-P','LE-RF') or empty(eelarve.kood2));

		-- 2008.a eelarve täitmine seisuga 30.06.2008.a (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)  

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Eelarve, Nimetus, summa5,timestamp,rekvid)
			select curkassaKuludeTaitmine.rekvid, 
			curkassakuludetaitmine.kood, library.nimetus, summa,lcreturn, tnrekvId 
			from curkassakuludetaitmine 
			inner join library on (library.kood = curkassakuludetaitmine.kood and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on curKassaKuludeTaitmine.rekvid = tmpRekv.id			
			where curkassakuludetaitmine.aasta = year(tdKpv2)
			and curkassakuludetaitmine.kuu <= month(tdKpv2)
			and (curkassakuludetaitmine.kood2 in ('LE-P','LE-RF') or empty(curkassakuludetaitmine.kood2));

		-- 2009.a. eelarve eelnõu (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta) 


		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Eelarve, Nimetus, summa6,timestamp,rekvid)
			select taotlus.rekvid, 
			taotlus1.kood5, library.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id			
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 3
			and taotlus1.kood2 in ('LE-P');

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Eelarve, Nimetus, summa16,timestamp,rekvid)
			select taotlus.rekvid, 
			taotlus1.kood5, library.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id			
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 1
			and taotlus1.kood2 in ('LE-P');


		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6, summa16, timestamp,rekvid)
		select RekvIdSub, eelarve, nimetus, sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa5), sum(summa6), sum(summa16),lcreturn+'LOPP', tnrekvId from tmp_eelproj_aruanne1  
		where timestamp = lcReturn
		group by RekvIdSub, eelarve, nimetus
		order by rekvidsub, eelarve;

		delete from tmp_eelproj_aruanne1 where timestamp = lcReturn;

		lcReturn = lcReturn + 'LOPP';

end if;

if tnLiik = 3 then
	--asutuse koondeelarve eelnõu
		raise notice 'asutuse koondeelarve eelnõu';

	delete from tmpRekv;
--	truncate TABLE tmpRekv;
	insert into tmpRekv
		SELECT id, parentid, fnc_get_asutuse_staatus(rekv.id, tnrekvid)::int as tase FROM rekv;


	--  eelmine aasta  eelarve täitmine   		

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, kood1, kood2, kood3, kood4, Eelarve, Nimetus, summa1,timestamp,rekvid)
			select case when tmprekv.tase = 2 then tmprekv.parentid else tmpRekv.id end, 
			left(eeltaitmine.kood5,1),left(eeltaitmine.kood5,2),left(eeltaitmine.kood5,3),left(eeltaitmine.kood5,4), 
			eeltaitmine.kood5, library.nimetus, eeltaitmine.summa * ifnull(dokvaluuta1.kuurs,1), lcreturn, tnrekvId 
			from eeltaitmine
			inner join library on (library.kood = eeltaitmine.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)						
			where eeltaitmine.aasta = year(tdKpv2)-1
			and left(eeltaitmine.kood5,1) <> '3' and eeltaitmine.kood5 not in ('2080.5','2081.5');
--			group by  eeltaitmine.rekvid, eeltaitmine.kood5, library.nimetus;

		-- 2007.a. eelarve täitmine (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)      

		INSERT into tmp_eelproj_aruanne1 ( rekvidSub, kood1, kood2, kood3, kood4, Eelarve, Nimetus, summa2,timestamp,rekvid)
			select case when tmprekv.tase = 2 then tmprekv.parentid else tmpRekv.id end, 
			left(eeltaitmine.kood5,1), left(eeltaitmine.kood5,2),left(eeltaitmine.kood5,3),left(eeltaitmine.kood5,4), 
			eeltaitmine.kood5, library.nimetus, eeltaitmine.summa * ifnull(dokvaluuta1.kuurs,1), lcreturn, tnrekvId 
			from eeltaitmine
			inner join library on (library.kood = eeltaitmine.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)						
			where eeltaitmine.aasta = year(tdKpv2)-1
			and left(eeltaitmine.kood5,1) <> '3' and eeltaitmine.kood5 not in ('2080.5','2081.5')
			and (kood2 in ('LE-P','LE-RF') or empty(kood2));

		-- 2008.a. eelarve (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)  

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, kood1, kood2, kood3, kood4, Eelarve, Nimetus, summa3,timestamp,rekvid)
			select case when tmprekv.tase = 2 then tmprekv.parentid else tmpRekv.id end, 
			left(eelarve.kood4,1),left(eelarve.kood4,2),left(eelarve.kood4,3),left(eelarve.kood4,4), 
			eelarve.kood4, library.nimetus, eelarve.summa * ifnull(dokvaluuta1.kuurs,1), lcreturn, tnrekvId from eelarve
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)						
			where eelarve.aasta = year(tdKpv2)
			and eelarve.tunnus = 0
			and left(eelarve.kood4,1) <> '3' and eelarve.kood4 not in ('2080.5','2081.5')
			and (eelarve.kood2 in ('LE-P','LE-RF') or empty(eelarve.kood2));

		-- 2008.a. täpsustatud eelarve seisuga 30.06.2008.a (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)     

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, kood1, kood2, kood3, kood4, Eelarve, Nimetus, summa4,timestamp,rekvid)
			select case when tmprekv.tase = 2 then tmprekv.parentid else tmpRekv.id end, 
			left(eelarve.kood4,1),left(eelarve.kood4,2),left(eelarve.kood4,3),left(eelarve.kood4,4), 
			eelarve.kood4, library.nimetus, eelarve.summa * ifnull(dokvaluuta1.kuurs,1), lcreturn, tnrekvId from eelarve
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)						
			where eelarve.aasta = year(tdKpv2)
			and eelarve.kpv <= tdkpv2
			and left(eelarve.kood4,1) <> '3' and eelarve.kood4 not in ('2080.5','2081.5')
			and (eelarve.kood2 in ('LE-P','LE-RF') or empty(eelarve.kood2));

		-- 2008.a eelarve täitmine seisuga 30.06.2008.a (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)  

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, kood1, kood2, kood3, kood4, Eelarve, Nimetus, summa5,timestamp,rekvid)
			select case when tmprekv.tase = 2 then tmprekv.parentid else tmpRekv.id end, 
			LEFT(curkassakuludetaitmine.kood,1), LEFT(curkassakuludetaitmine.kood,2),LEFT(curkassakuludetaitmine.kood,3),LEFT(curkassakuludetaitmine.kood,4), 
			curkassakuludetaitmine.kood, library.nimetus, summa,lcreturn, tnrekvId from curkassakuludetaitmine 
			inner join library on (library.kood = curkassakuludetaitmine.kood and library.library = 'TULUDEALLIKAD')
			inner join tmpRekv on curkassakuludetaitmine.rekvid = tmpRekv.id
			where curkassakuludetaitmine.aasta = year(tdKpv2)
			and curkassakuludetaitmine.kuu <= month(tdKpv2)
			and left(curkassakuludetaitmine.kood,1) <> '3' and curkassakuludetaitmine.kood not in ('2080.5','2081.5')
			and (kood2 in ('LE-P','LE-RF') or empty(kood2));

		-- 2009.a. eelarve eelnõu (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta) 


		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, KOOD1, KOOD2, KOOD3, KOOD4, Eelarve, Nimetus, summa6,timestamp,rekvid)
			select case when tmprekv.tase = 2 then tmprekv.parentid else tmpRekv.id end, 
			left(taotlus1.kood5,1),left(taotlus1.kood5,2),left(taotlus1.kood5,3),left(taotlus1.kood5,4), 
			taotlus1.kood5, library.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 3
			and left(taotlus1.kood5,1) <> '3' and taotlus1.kood5 not in ('2080.5','2081.5')
			and taotlus1.kood2 in ('LE-P');

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, KOOD1, KOOD2, KOOD3, KOOD4, Eelarve, Nimetus, summa16,timestamp,rekvid)
			select case when tmprekv.tase = 2 then tmprekv.parentid else tmpRekv.id end, 
			left(taotlus1.kood5,1),left(taotlus1.kood5,2),left(taotlus1.kood5,3),left(taotlus1.kood5,4), 
			taotlus1.kood5, library.nimetus, taotlus1.summa * ifnull(dokvaluuta1.kuurs,1),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 1
			and left(taotlus1.kood5,1) <> '3' and taotlus1.kood5 not in ('2080.5','2081.5')
			and taotlus1.kood2 in ('LE-P');



		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6,summa16, timestamp,rekvid)
		select RekvIdSub, eelarve, nimetus, sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa5), sum(summa6), sum(summa16), lcreturn+'LOPP', tnrekvId from tmp_eelproj_aruanne1  
		where timestamp = lcReturn
		and left(eelarve,1) <> '3' and eelarve not in ('2080.5','2081.5')
		group by RekvIdSub, eelarve, nimetus
		order by rekvidsub, eelarve;


		-- kond summad
		-- kond 1

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6, summa16, timestamp,rekvid)
		select RekvIdSub, kood1, library.nimetus, sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa5), sum(summa6), sum(summa16), lcreturn+'LOPP', tnrekvId 
		from tmp_eelproj_aruanne1 inner join library on (library.kood = tmp_eelproj_aruanne1.kood1 and library.library = 'TULUDEALLIKAD')  
		where timestamp = lcReturn 
		and left(eelarve,1) <> '3' and eelarve not in ('2080.5','2081.5')
		group by RekvIdSub,kood1, library.nimetus;
                --and tmp_eelproj_aruanne1.kood1 in ('5','6','4')	

		-- kond 2

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub,Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6, summa16, timestamp,rekvid)
		select RekvIdSub,kood2, library.nimetus, sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa5), sum(summa6), sum(summa16), lcreturn+'LOPP', tnrekvId 
		from tmp_eelproj_aruanne1 inner join library on (library.kood = tmp_eelproj_aruanne1.kood2 and library.library = 'TULUDEALLIKAD')  
		where timestamp = lcReturn 
		and left(eelarve,1) <> '3' and eelarve not in ('2080.5','2081.5')
		group by RekvIdSub,kood2, library.nimetus;

		-- kond 3

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub,Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6, summa16, timestamp,rekvid)
		select RekvIdSub,kood3, library.nimetus, sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa5), sum(summa6), sum(summa16), lcreturn+'LOPP', tnrekvId 
		from tmp_eelproj_aruanne1 inner join library on (library.kood = tmp_eelproj_aruanne1.kood3 and library.library = 'TULUDEALLIKAD')  
		where timestamp = lcReturn 
		and left(eelarve,1) <> '3' and eelarve not in ('2080.5','2081.5')
		group by RekvIdSub,kood3, library.nimetus;

		-- kond 4

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub,Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6, summa16, timestamp,rekvid)
		select RekvIdSub,kood4, library.nimetus, sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa5), sum(summa6), sum(summa16), lcreturn+'LOPP', tnrekvId 
		from tmp_eelproj_aruanne1 inner join library on (library.kood = tmp_eelproj_aruanne1.kood4 and library.library = 'TULUDEALLIKAD')  
		where timestamp = lcReturn 
		and left(eelarve,1) <> '3' and eelarve not in ('2080.5','2081.5')
		group by RekvIdSub, kood4, library.nimetus;


		delete from tmp_eelproj_aruanne1 where timestamp = lcReturn;

		lcReturn = lcReturn + 'LOPP';

end if;

if tnLiik = 2 then
		raise notice 'linna koondeelarve eelnou';
		--  eelmine aasta  eelarve täitmine   		

lcKood1 = ltrim(rtrim(ifnull(tcTegev,'')+'%'));
lcKood2 = ltrim(rtrim(ifnull(tcAllikas,'')+'%'));
lcKood5 = ltrim(rtrim(ifnull(tcEelarve,'')+'%'));

		INSERT into tmp_eelproj_aruanne1 ( kood1, kood2, kood3, kood4, Eelarve, Nimetus, summa1,timestamp,rekvid)
			select left(eeltaitmine.kood5,1),left(eeltaitmine.kood5,2),left(eeltaitmine.kood5,3),left(eeltaitmine.kood5,4), eeltaitmine.kood5, 
			library.nimetus, sum(eeltaitmine.summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId 
			from eeltaitmine
			inner join library on (library.kood = eeltaitmine.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2)-1
			and left(eeltaitmine.kood5,1) <> '3' and eeltaitmine.kood5 not in ('2080.5','2081.5')
			and ltrim(rtrim(kood1)) like lcKood1
			and ltrim(rtrim(kood2)) like lcKood2
			and ltrim(rtrim(kood5)) like lcKood5
			group by  eeltaitmine.kood5, library.nimetus;


		-- 2007.a. eelarve täitmine (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)      

		INSERT into tmp_eelproj_aruanne1 ( kood1, kood2, kood3, kood4, Eelarve, Nimetus, summa2,timestamp,rekvid)
			select left(eeltaitmine.kood5,1),left(eeltaitmine.kood5,2),left(eeltaitmine.kood5,3),left(eeltaitmine.kood5,4),eeltaitmine.kood5, library.nimetus, 
			sum(eeltaitmine.summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId 
			from eeltaitmine
			inner join library on (library.kood = eeltaitmine.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on eeltaitmine.rekvid = tmpRekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eeltaitmine.id and dokvaluuta1.dokliik = 9)
			where eeltaitmine.aasta = year(tdKpv2)-1
			and (kood2 in ('LE-P','LE-RF') or empty(kood2))
			and left(eeltaitmine.kood5,1) <> '3' and eeltaitmine.kood5 not in ('2080.5','2081.5')
			and ltrim(rtrim(kood1)) like lcKood1
			and ltrim(rtrim(kood2)) like lcKood2
			and ltrim(rtrim(kood5)) like lcKood5
			group by  eeltaitmine.kood5, library.nimetus;

		-- 2008.a. eelarve (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)  

		INSERT into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood4, Eelarve, Nimetus, summa3,timestamp,rekvid)
			select left(eelarve.kood4,1),left(eelarve.kood4,2),left(eelarve.kood4,3),left(eelarve.kood4,4), eelarve.kood4, library.nimetus, 
			sum(eelarve.summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId 
			from eelarve
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.aasta = year(tdKpv2)
			and eelarve.tunnus = 0
			and left(eelarve.kood4,1) <> '3' and eelarve.kood4 not in ('2080.5','2081.5')
			and (eelarve.kood2 in ('LE-P','LE-RF') or empty(eelarve.kood2))
			and ltrim(rtrim(kood1)) like lcKood1
			and ltrim(rtrim(kood2)) like lcKood2
			and ltrim(rtrim(kood4)) like lcKood5
			group by  eelarve.kood4, library.nimetus;

		-- 2008.a. täpsustatud eelarve seisuga 30.06.2008.a (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)     

		INSERT into tmp_eelproj_aruanne1 ( kood1, kood2, kood3, kood4, Eelarve, Nimetus, summa4,timestamp,rekvid)
			select left(eelarve.kood4,1),left(eelarve.kood4,2),left(eelarve.kood4,3),left(eelarve.kood4,4),eelarve.kood4, library.nimetus, 
			sum(eelarve.summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId 
			from eelarve
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on eelarve.rekvid = tmpRekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.aasta = year(tdKpv2)
			and (eelarve.kpv <= tdkpv2 or empty(eelarve.kpv))
			and left(eelarve.kood4,1) <> '3' and eelarve.kood4 not in ('2080.5','2081.5')
			and (eelarve.kood2 in ('LE-P','LE-RF') or empty(eelarve.kood2))
			and ltrim(rtrim(kood1)) like lcKood1
			and ltrim(rtrim(kood2)) like lcKood2
			and ltrim(rtrim(kood4)) like lcKood5
			group by  eelarve.kood4, library.nimetus;

		-- 2008.a eelarve täitmine seisuga 30.06.2008.a (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta)  

		INSERT into tmp_eelproj_aruanne1 (kood1, kood2, kood3, kood4,  Eelarve, Nimetus, summa5,timestamp,rekvid)
				select left(curkassakuludetaitmine.kood,1),left(curkassakuludetaitmine.kood,2), left(curkassakuludetaitmine.kood,3),
				left(curkassakuludetaitmine.kood,4), 
				curkassakuludetaitmine.kood, library.nimetus, sum(summa),lcreturn, tnrekvId 
				from curkassakuludetaitmine 
			inner join library on (library.kood = curkassakuludetaitmine.kood and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join tmpRekv on curkassakuludetaitmine.rekvid = tmpRekv.id
			where curkassakuludetaitmine.aasta = year(tdKpv2)
			and curkassakuludetaitmine.kuu <= month(tdKpv2)
			and (kood2 in ('LE-P','LE-RF') or empty(kood2))
			and left(curkassakuludetaitmine.kood,1) <> '3' and curkassakuludetaitmine.kood not in ('2080.5','2081.5')
			and ltrim(rtrim(tegev)) like lcKood1
			and ltrim(rtrim(kood2)) like lcKood2
			and ltrim(rtrim(curkassakuludetaitmine.kood)) like lcKood5
			group by  curkassakuludetaitmine.kood, library.nimetus;

		-- 2009.a. eelarve eelnõu (ilma sihtotstarbeliste laekumiste, riigieelarveta, remondi ja soetusteta, laenuta) 


		INSERT into tmp_eelproj_aruanne1 ( kood1, kood2, kood3, kood4, Eelarve, Nimetus, summa6,timestamp,rekvid)
				select left(taotlus1.kood5,1),left(taotlus1.kood5,2),left(taotlus1.kood5,3),left(taotlus1.kood5,4), taotlus1.kood5, library.nimetus, 
				sum(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId 
				from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id			
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 3
			and left(taotlus1.kood5,1) <> '3' and taotlus1.kood5 not in ('2080.5','2081.5')
			and (taotlus1.kood2 in ('LE-P','LE-RF') or empty(taotlus1.kood2))
			and ltrim(rtrim(kood1)) like lcKood1
			and ltrim(rtrim(kood2)) like lcKood2
			and ltrim(rtrim(kood5)) like lcKood5
			group by  taotlus1.kood5, library.nimetus;
			
		INSERT into tmp_eelproj_aruanne1 ( kood1, kood2, kood3, kood4, Eelarve, Nimetus, summa16,timestamp,rekvid)
				select left(taotlus1.kood5,1),left(taotlus1.kood5,2),left(taotlus1.kood5,3),left(taotlus1.kood5,4), taotlus1.kood5, library.nimetus, 
				sum(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId 
				from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join tmpRekv on taotlus.rekvid = tmpRekv.id			
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 1
			and left(taotlus1.kood5,1) <> '3' and taotlus1.kood5 not in ('2080.5','2081.5')
			and (taotlus1.kood2 in ('LE-P','LE-RF') or empty(taotlus1.kood2))
			and ltrim(rtrim(kood1)) like lcKood1
			and ltrim(rtrim(kood2)) like lcKood2
			and ltrim(rtrim(kood5)) like lcKood5
			group by  taotlus1.kood5, library.nimetus;



		INSERT into tmp_eelproj_aruanne1 ( Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6, summa16, timestamp,rekvid)
		select eelarve, nimetus, sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa5), sum(summa6), sum(summa16), lcreturn+'LOPP', tnrekvId from tmp_eelproj_aruanne1  
		where timestamp = lcReturn
		group by eelarve, nimetus;


		-- kond summad
		-- kond 1

		INSERT into tmp_eelproj_aruanne1 ( Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6, summa16, timestamp,rekvid)
		select kood1, library.nimetus, sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa5), sum(summa6), sum(summa16), lcreturn+'LOPP', tnrekvId 
		from tmp_eelproj_aruanne1 inner join library on (library.kood = tmp_eelproj_aruanne1.kood1 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)  
		where timestamp = lcReturn 
		group by kood1, library.nimetus;
                --and tmp_eelproj_aruanne1.kood1 in ('5','6','4')	

		-- kond 2

		INSERT into tmp_eelproj_aruanne1 ( Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6, summa16, timestamp,rekvid)
		select kood2, library.nimetus, sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa5), sum(summa6), sum(summa16), lcreturn+'LOPP', tnrekvId 
		from tmp_eelproj_aruanne1 inner join library on (library.kood = tmp_eelproj_aruanne1.kood2 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)  
		where timestamp = lcReturn 
		group by kood2, library.nimetus;

		-- kond 3

		INSERT into tmp_eelproj_aruanne1 ( Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6,summa16, timestamp,rekvid)
		select kood3, library.nimetus, sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa5), sum(summa6), sum(summa16), lcreturn+'LOPP', tnrekvId 
		from tmp_eelproj_aruanne1 inner join library on (library.kood = tmp_eelproj_aruanne1.kood3 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)  
		where timestamp = lcReturn 
		group by kood3, library.nimetus;

		-- kond 4

		INSERT into tmp_eelproj_aruanne1 ( Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6, summa16, timestamp,rekvid)
		select kood4, library.nimetus, sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa5), sum(summa6), sum(summa16), lcreturn+'LOPP', tnrekvId 
		from tmp_eelproj_aruanne1 inner join library on (library.kood = tmp_eelproj_aruanne1.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)  
		where timestamp = lcReturn 
		group by kood4, library.nimetus;



		delete from tmp_eelproj_aruanne1 where timestamp = lcReturn;

		lcReturn = lcReturn + 'LOPP';

		INSERT into tmp_eelproj_aruanne1 ( Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6, summa16, timestamp,rekvid)
		select '20.6', 'Kohustuste vähenemine', ifnull(sum(summa1),0), ifnull(sum(summa2),0), ifnull(sum(summa3),0), ifnull(sum(summa4),0), ifnull(sum(summa5),0), 
			ifnull(sum(summa6),0), ifnull(sum(summa16),0), lcreturn, tnrekvId 
		from tmp_eelproj_aruanne1   
		where timestamp = lcReturn
		and (eelarve like '2080.6%' or eelarve like '2081.6%' or eelarve like '2082.6%');

-- Kulud kokku

		INSERT into tmp_eelproj_aruanne1 ( Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6, summa16, timestamp,rekvid)
		select '', 'KULUD KOKKU', ifnull(sum(summa1),0), ifnull(sum(summa2),0), ifnull(sum(summa3),0), ifnull(sum(summa4),0), ifnull(sum(summa5),0), 
			ifnull(sum(summa6),0), ifnull(sum(summa16),0), lcreturn, tnrekvId 
		from tmp_eelproj_aruanne1   
		where timestamp = lcReturn
		and eelarve in ('4','5','6','15','20.6');




end if;


if tnLiik = 1 then
		raise notice 'Narva linna 2008.a. tulude ja finantseerimistehingute eelarve eelnõu';

		--  Põhieelarve   		

		INSERT into tmp_eelproj_aruanne1 ( Eelarve, Nimetus, summa1,timestamp,rekvid)
			select eelarve.kood4, library.nimetus, ifnull(sum(eelarve.summa * ifnull(dokvaluuta1.kuurs,1)),0), lcreturn, tnrekvId from eelarve
			inner join rekv on rekv.id = eelarve.rekvId
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1)
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.aasta = year(tdKpv2)
			and empty(eelarve.kpv)
			group by  eelarve.kood4, library.nimetus;

		--  Põhieelarve eelnou   		

		INSERT into tmp_eelproj_aruanne1 ( Eelarve, Nimetus, summa3,timestamp,rekvid)
			select taotlus1.kood5, library.nimetus, ifnull(sum(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),0), lcreturn, tnrekvId 
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join rekv on rekv.id = taotlus.rekvId
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1)
			inner join tmprekv on taotlus.rekvId = tmprekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)
			and taotlus.staatus = 3
			group by  taotlus1.kood5, library.nimetus;


		--  allikas 80 omatulu    		

		INSERT into tmp_eelproj_aruanne1 ( Eelarve, nimetus, summa2,	timestamp,rekvid)
			select eelarve.kood4,library.nimetus, sum(eelarve.summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId 
			from eelarve
			inner join rekv on rekv.id = eelarve.rekvId
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1)
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.kood2 = '80' and eelarve.aasta = year(tdKpv2)
			group by  eelarve.kood4, library.nimetus;

		INSERT into tmp_eelproj_aruanne1 ( Eelarve, Nimetus, summa4,timestamp,rekvid)
			select taotlus1.kood5, library.nimetus, ifnull(sum(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),0), lcreturn, tnrekvId 
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join rekv on rekv.id = taotlus.rekvId
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1)
			inner join tmprekv on taotlus.rekvId = tmprekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)
			and taotlus1.kood2 = '80'
			and taotlus.staatus = 3
			group by  taotlus1.kood5, library.nimetus;


		--  allikas LE-LA    		

		INSERT into tmp_eelproj_aruanne1 ( eelarve, nimetus, summa1,	timestamp, rekvid)
			select '920', 'Kohustuste suurenemine /laenude võtmine muudelt residentidelt/',
			ifnull(sum(eelarve.summa * ifnull(dokvaluuta1.kuurs,1)),0), lcreturn, tnrekvId 
			from eelarve
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1)
			inner join rekv on rekv.id = eelarve.rekvId
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)			
			where eelarve.kood2 = 'LE-LA' and eelarve.aasta = year(tdKpv2);


		INSERT into tmp_eelproj_aruanne1 ( Eelarve, Nimetus, summa4,timestamp,rekvid)
			select '920', 'Kohustuste suurenemine /laenude võtmine muudelt residentidelt/',
			ifnull(sum(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),0), lcreturn, tnrekvId 
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join rekv on rekv.id = taotlus.rekvId
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1)
			inner join tmprekv on taotlus.rekvId = tmprekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)
			and taotlus1.kood2 = 'LE-LA'
			and taotlus.staatus = 3;

-- Muutus kassas ja hoiustes /vaba jääk,suunatud kulude katteks/
-- Plaan-täitmine. Sellest lahutada 60, RE-HK,RE-KL, RE-ST, RE-TT, RE-TH. Allikas RE-Muud  näidata eraldi real 
		lnPlaan = 0;
		lnTaitm = 0;
                
		select 	sum(eelarve.summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
			from eelarve
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1)
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)						
			where eelarve.kood2 not in ('60', 'RE-HK','RE-KL', 'RE-ST', 'RE-TT', 'RE-TH') 
			and eelarve.aasta = year(tdKpv2);

		lnPlaan = ifnull(lnPlaan,0);
		if lnPlaan = 0 then
			select 	sum(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1)
			inner join tmprekv on taotlus.rekvId = tmprekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus1.kood2 not in ('60', 'RE-HK','RE-KL', 'RE-ST', 'RE-TT', 'RE-TH') 
			and taotlus.aasta = year(tdKpv2)
			and taotlus.staatus = 3;

			lnPlaan = ifnull(lnPlaan,0);

		end if;

		select 	sum(summa) into lnTaitm from curkassatuludetaitmine
			inner join tmprekv on curkassatuludetaitmine.rekvId = tmprekv.id
			where curkassatuludetaitmine.kood2 not in ('60', 'RE-HK','RE-KL', 'RE-ST', 'RE-TT', 'RE-TH') 
			and curkassatuludetaitmine.aasta = year(tdKpv2) and curkassatuludetaitmine.kuu <= month(tdKpv2);
		lnTaitm = ifnull(lnTaitm,0);

		INSERT into tmp_eelproj_aruanne1 ( eelarve, nimetus, summa1,	timestamp,rekvid) values 
			 ('9100', 'Muutus kassas ja hoiustes /vaba jääk,suunatud kulude katteks/', lnPlaan - lnTaitm, lcreturn, tnrekvId);


		select 	sum(eelarve.summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
			from eelarve
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1)
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)						
			where eelarve.kood2 = 'RE-Muud' 
			and eelarve.aasta = year(tdKpv2);
		lnPlaan = ifnull(lnPlaan,0);

		if lnPlaan = 0 then
			select 	sum(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)) into lnPlaan 
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 1)
			inner join tmprekv on taotlus.rekvId = tmprekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)						
			where taotlus1.kood2 = 'RE-Muud' 
			and taotlus.aasta = year(tdKpv2)
			and taotlus.staatus = 3;

			lnPlaan = ifnull(lnPlaan,0);

		end if;


		select 	sum(summa) into lnTaitm from curkassatuludetaitmine
			inner join tmprekv on curkassatuludetaitmine.rekvId = tmprekv.id
			where curkassatuludetaitmine.kood2 =  'RE-Muud' 
			and curkassatuludetaitmine.aasta = year(tdKpv2);
		lnTaitm = ifnull(lnTaitm,0);

		INSERT into tmp_eelproj_aruanne1 ( eelarve, nimetus, summa1,timestamp,rekvid) values 
			 ('91001', 'Muutus kassas ja hoiustes /muud/', lnPlaan - lnTaitm, lcreturn, tnrekvId);


		-- final, kokkuvõtte

		INSERT into tmp_eelproj_aruanne1 ( eelarve, nimetus, summa1,summa2, summa3, summa4 ,timestamp,rekvid)
			select eelarve, nimetus, sum(ifnull(summa1,0)),sum(ifnull(summa2,0)), sum(ifnull(summa3,0)), sum(ifnull(summa4,0)), lcreturn+'LOPP', tnrekvId 
			from tmp_eelproj_aruanne1 where timestamp = lcreturn
			group by eelarve, nimetus, timestamp,rekvid;

		-- kustutame temp.andmed

		delete from tmp_eelproj_aruanne1 where timestamp = lcreturn;
		
		lcReturn = LCRETURN+'LOPP';
			

end if;
	

return LCRETURN;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO eelaktsepterja;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO dbkasutaja;
