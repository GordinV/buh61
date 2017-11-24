-- Function: sp_eelproj_aruanne2(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer)

-- DROP FUNCTION sp_eelproj_aruanne2(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer);

CREATE OR REPLACE FUNCTION sp_eelproj_aruanne2(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer)
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
	lcTegev varchar;
	lcAllikas varchar;
	lcEelarve varchar;
	lcEelarve1 varchar;

	lnrekvid1 int;
	lnrekvid2 int;

	LNcOUNT int;
	lnSumma numeric(12,2);

	lnPlaan numeric(12,2);
	lnTaitm numeric(12,2);

	v_eelaruanne record;

begin


	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_EELPROJ_ARUANNE2';



	if ifnull(lnCount,0) < 1 then



		raise notice ' lisamine  ';

	

		create table tmp_eelproj_aruanne2 ( id int, konto varchar(20), 
			RekvIdSub int not null default 0, AllAsutus varchar(254) not null default space(1),
			summa1 numeric(14,2) not null default 0, 
			summa2 numeric(14,2) not null default 0, 
			summa3 numeric(14,2) not null default 0, 
			summa4 numeric(14,2) not null default 0, 
			summa5 numeric(14,2) not null default 0, 
			summa6 numeric(14,2) not null default 0, 
			summa7 numeric(14,2) not null default 0, 
			summa8 numeric(14,2) not null default 0, 
			summa9 numeric(14,2) not null default 0, 
			summa10 numeric(14,2) not null default 0, 
			tunnus varchar(20) not null default space(20),
			allikas varchar(20) not null default space(20),
			tegev varchar(20) not null default space(20),
			eelarve varchar(20) not null default space(20),
			rahavoo varchar(20) not null default space(20),
			projekt varchar(20) not null default space(20),
			objekt varchar(20) not null default space(20),
			nimetus varchar(254) null,
			timestamp varchar(20) not null , kpv date not null default date(), rekvid int not null  )  ;

		

		GRANT ALL ON TABLE tmp_eelproj_aruanne2 TO GROUP public;



	else
		delete from tmp_eelproj_aruanne2 where kpv < date() and rekvid = tnrekvId;

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


if tnLiik = 1 then
	--Narva linna 2009.a eelarve eelnõu kulude ja finantseerimistehingute osas asutuste lõikes
		raise notice 'Narva linna 2009.a eelarve eelnõu kulude ja finantseerimistehingute osas asutuste lõikes';

	--  Narva Linnavalitsuse  Kultuuriosakond   		
	lnrekvId1 = 119;
	lnrekvId2 = 119;

		INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, Eelarve, Nimetus, summa1,timestamp,rekvid)
			select lnRekvid1, 
			taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus1.kood2 not in ('LE-RF')
			and (rekv.id = lnRekvid1 or rekv.parentid = lnRekvid2)
			and taotlus.staatus = 3;

		INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, Eelarve, Nimetus, summa11,timestamp,rekvid)
			select lnRekvid1, 
			taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus1.kood2 not in ('LE-RF')
			and (rekv.id = lnRekvid1 or rekv.parentid = lnRekvid2)
			and taotlus.staatus = 1;


	--   Narva Linna  Sotsiaalabiamet
   		
	lnrekvId1 = 64;
	lnrekvId2 = 64;

		INSERT into tmp_eelproj_aruanne2 ( Eelarve, Nimetus, summa2, timestamp,rekvid)
			select taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus1.kood2 not in ('LE-RF')
			and (rekv.id = lnRekvid1 or rekv.parentid = lnRekvid2)
			and taotlus.staatus = 3;

		INSERT into tmp_eelproj_aruanne2 ( Eelarve, Nimetus, summa12, timestamp,rekvid)
			select taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus1.kood2 not in ('LE-RF')
			and (rekv.id = lnRekvid1 or rekv.parentid = lnRekvid2)
			and taotlus.staatus = 1;


	--   Narva Linnavalitsuse Linnavara -ja majandusamet
   		
	lnrekvId1 = 6;
	lnrekvId2 = 6;

		INSERT into tmp_eelproj_aruanne2 ( Eelarve, Nimetus, summa3, timestamp,rekvid)
			select 	taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and (rekv.id = lnRekvid1 or rekv.parentid = lnRekvid2)
			and taotlus1.kood2 not in ('LE-RF')
			and taotlus.staatus = 3;

		INSERT into tmp_eelproj_aruanne2 ( Eelarve, Nimetus, summa13, timestamp,rekvid)
			select 	taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and (rekv.id = lnRekvid1 or rekv.parentid = lnRekvid2)
			and taotlus1.kood2 not in ('LE-RF')
			and taotlus.staatus = 1;

	--   Narva Linnavolikogu Kantselei
	lnrekvId1 = 10;
	lnrekvId2 = 10;

		INSERT into tmp_eelproj_aruanne2 (Eelarve, Nimetus, summa4,timestamp,rekvid)
			select 	taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus1.kood2 not in ('LE-RF')
			and (rekv.id = lnRekvid1 or rekv.parentid = lnRekvid2)
			and taotlus.staatus = 3;

		INSERT into tmp_eelproj_aruanne2 (Eelarve, Nimetus, summa14,timestamp,rekvid)
			select 	taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus1.kood2 not in ('LE-RF')
			and (rekv.id = lnRekvid1 or rekv.parentid = lnRekvid2)
			and taotlus.staatus = 1;

	--   Narva Linnakantselei ( sh Linna Arhiiv ja Linnaarstiteenistus )
	lnrekvId1 = 3;
	lnrekvId2 = 3;

		INSERT into tmp_eelproj_aruanne2 ( Eelarve, Nimetus, summa5, timestamp,rekvid)
			select 	taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus1.kood2 not in ('LE-RF')
			and (rekv.id = lnRekvid1 or rekv.parentid = lnRekvid2)
			and taotlus.staatus = 3;

		INSERT into tmp_eelproj_aruanne2 ( Eelarve, Nimetus, summa15, timestamp,rekvid)
			select 	taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus1.kood2 not in ('LE-RF')
			and (rekv.id = lnRekvid1 or rekv.parentid = lnRekvid2)
			and taotlus.staatus = 1;

--	 Narva Linnavalitsuse Rahandusamet sh laenude tagastamine ja intressi tasumine
   		
	lnrekvId1 = 63;
	lnrekvId2 = 63;

		INSERT into tmp_eelproj_aruanne2 ( Eelarve, Nimetus, summa6,timestamp,rekvid)
			select 	taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus1.kood2 not in ('LE-RF')
			and (rekv.id = lnRekvid1)
			and taotlus.staatus = 3;

		INSERT into tmp_eelproj_aruanne2 ( Eelarve, Nimetus, summa16,timestamp,rekvid)
			select 	taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus1.kood2 not in ('LE-RF')
			and (rekv.id = lnRekvid1)
			and taotlus.staatus = 1;

--	  Narva Linnavalitsuse  Arhitektuuri- ja Linnaplaneerimise Amet
   		
	lnrekvId1 = 29;
	lnrekvId2 = 29;

		INSERT into tmp_eelproj_aruanne2 ( Eelarve, Nimetus, summa7,timestamp,rekvid)
			select 	taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus1.kood2 not in ('LE-RF')
			and (rekv.id = lnRekvid1 or rekv.parentid = lnRekvid2)
			and taotlus.staatus = 3;

		INSERT into tmp_eelproj_aruanne2 ( Eelarve, Nimetus, summa17,timestamp,rekvid)
			select 	taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus1.kood2 not in ('LE-RF')
			and (rekv.id = lnRekvid1 or rekv.parentid = lnRekvid2)
			and taotlus.staatus = 1;

--	  Narva Linna Arenduse ja Ökonoomika Amet
   		
	lnrekvId1 = 28;
	lnrekvId2 = 28;

		INSERT into tmp_eelproj_aruanne2 ( Eelarve, Nimetus, summa8,timestamp,rekvid)
			select taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus1.kood2 not in ('LE-RF')
			and (rekv.id = lnRekvid1 or rekv.parentid = lnRekvid2)
			and taotlus.staatus = 3;
			
		INSERT into tmp_eelproj_aruanne2 ( Eelarve, Nimetus, summa18,timestamp,rekvid)
			select taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			inner join rekv on taotlus.rekvid = rekv.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus1.kood2 not in ('LE-RF')
			and (rekv.id = lnRekvid1 or rekv.parentid = lnRekvid2)
			and taotlus.staatus = 1;

--	  RF

		INSERT into tmp_eelproj_aruanne2 (Eelarve, Nimetus, summa9,timestamp,rekvid)
			select taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 3
			and taotlus1.kood2 in ('LE-RF');

--			and taotlus1.kood1 = '01114' 
--			and taotlus1.kood5 = '608'
			

		INSERT into tmp_eelproj_aruanne2 (Eelarve, Nimetus, summa19,timestamp,rekvid)
			select taotlus1.kood5, library.nimetus, (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),lcreturn, tnrekvId from taotlus1 
			inner join library on (library.kood = taotlus1.kood5 and library.library = 'TULUDEALLIKAD' and library.tun5 = 2)
			inner join taotlus on taotlus.id = taotlus1.parentid
			inner join eelproj on taotlus1.eelprojid = eelproj.id
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus.aasta = year(tdKpv2)+1
			and taotlus.staatus = 1
			and taotlus1.kood2 in ('LE-RF');

--			and taotlus1.kood1 = '01114' 
--			and taotlus1.kood5 = '608'


		INSERT into tmp_eelproj_aruanne2 (Eelarve, Nimetus,  summa1, summa2, summa3, summa4, summa5, summa6, summa7,summa8,summa9,
			summa11, summa12, summa13, summa14, summa15, summa16, summa17,summa18,summa19, timestamp,rekvid)
		select eelarve, nimetus, sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa5), sum(summa6),sum(summa7),sum(summa8),sum(summa9), 
			sum(summa11), sum(summa12), sum(summa13), sum(summa14), sum(summa15), sum(summa16),sum(summa17),sum(summa18),sum(summa19),
		lcreturn+'LOPP', tnrekvId from tmp_eelproj_aruanne2 
		where timestamp = lcReturn
		group by eelarve, nimetus
		order by eelarve;

		delete from tmp_eelproj_aruanne2 where timestamp = lcReturn;

		lcReturn = lcReturn + 'LOPP';

end if;
	

if tnLiik = 2 then
	-- 2009.aasta eelarve eelnõu kulude ja finantseerimistehingute jaotus tegevusalde lõikes 

		raise notice '2009.aasta eelarve eelnõu kulude ja finantseerimistehingute jaotus tegevusalde lõikes ';

	--  Narva Linnavalitsuse  Kultuuriosakond   		
	lnrekvId1 = 119;
	lnrekvId2 = 119;
	LNcOUNT = 0;

	FOR lnCount IN 1..10
	loop
	
		lcTegev = '0'+ltrim(rtrim(lnCount::varchar))+'%';

		if lnCount = 10 then
			lcTegev = ltrim(rtrim(lnCount::varchar))+'%';
		end if;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 like '+quote_literal(lcTegev);

		execute lcString;
		
 		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount+12)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 like '+quote_literal(lcTegev);

		execute lcString;

	end loop;

--		lcTegev = '01114';
		lcEelarve = '608';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa11,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa23,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;
		

--LA
		lcTegev = '01700';
		lcEelarve = '6501.8';
		lcEelarve1 = '2081.6.8';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa12,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 = '+quote_literal(lcTegev)+
			' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';

		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa24,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 = '+quote_literal(lcTegev)+
			' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';

		execute lcString;

	--   Narva Linna  Sotsiaalabiamet
   		
	lnrekvId1 = 64;
	lnrekvId2 = 64;

	LNcOUNT = 0;

	FOR lnCount IN 1..10
	loop
	
		lcTegev = '0'+ltrim(rtrim(lnCount::varchar))+'%';

		if lnCount = 10 then
			lcTegev = ltrim(rtrim(lnCount::varchar))+'%';
		end if;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 like '+quote_literal(lcTegev);

		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount+12)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 like '+quote_literal(lcTegev);

		execute lcString;

--			raise notice 'lcString %',lcString;

	end loop;


--		lcTegev = '01114';
		lcEelarve = '608';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa11,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3  and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa23,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;

--LA
		lcTegev = '01700';
		lcEelarve = '6501.8';
		lcEelarve1 = '2081.6.8';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa12,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 = '+quote_literal(lcTegev)+' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';


		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa24,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 = '+quote_literal(lcTegev)+' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';


		execute lcString;

	--   Narva Linnavalitsuse Linnavara -ja majandusamet
   		
	lnrekvId1 = 6;
	lnrekvId2 = 6;

	LNcOUNT = 0;

	FOR lnCount IN 1..10
	loop
	
		lcTegev = '0'+ltrim(rtrim(lnCount::varchar))+'%';

		if lnCount = 10 then
			lcTegev = ltrim(rtrim(lnCount::varchar))+'%';
		end if;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 like '+quote_literal(lcTegev);


		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount+12)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 like '+quote_literal(lcTegev);


		execute lcString;

--			raise notice 'lcString %',lcString;


	end loop;

--		lcTegev = '01114';
		lcEelarve = '608';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa11,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa23,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;


--LA
		lcTegev = '01700';
		lcEelarve = '6501.8';
		lcEelarve1 = '2081.6.8';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa12,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 = '+quote_literal(lcTegev)+' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';


		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa24,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 = '+quote_literal(lcTegev)+' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';

		execute lcString;

	--   Narva Linnavolikogu Kantselei
	lnrekvId1 = 10;
	lnrekvId2 = 10;

	LNcOUNT = 0;

	FOR lnCount IN 1..10
	loop
	
		lcTegev = '0'+ltrim(rtrim(lnCount::varchar))+'%';

		if lnCount = 10 then
			lcTegev = ltrim(rtrim(lnCount::varchar))+'%';
		end if;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 like '+quote_literal(lcTegev);


		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount+12)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 like '+quote_literal(lcTegev);


		execute lcString;

--			raise notice 'lcString %',lcString;

	end loop;

--		lcTegev = '01114';
		lcEelarve = '608';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa11,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3  and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;
		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa23,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;


--LA
		lcTegev = '01700';
		lcEelarve = '6501.8';
		lcEelarve1 = '2081.6.8';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa12,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+',(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 = '+quote_literal(lcTegev)+' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';


		execute lcString;
		
		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa24,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+',(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 = '+quote_literal(lcTegev)+' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';


		execute lcString;


	--   Narva Linnakantselei ( sh Linna Arhiiv ja Linnaarstiteenistus )
	lnrekvId1 = 3;
	lnrekvId2 = 3;


	LNcOUNT = 0;

	FOR lnCount IN 1..10
	loop
	
		lcTegev = '0'+ltrim(rtrim(lnCount::varchar))+'%';

		if lnCount = 10 then
			lcTegev = ltrim(rtrim(lnCount::varchar))+'%';
		end if;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 like '+quote_literal(lcTegev);

		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount+12)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 like '+quote_literal(lcTegev);

		execute lcString;



--			raise notice 'lcString %',lcString;

	end loop;

--		lcTegev = '01114';
		lcEelarve = '608';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa11,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa23,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;

--LA
		lcTegev = '01700';
		lcEelarve = '6501.8';
		lcEelarve1 = '2081.6.8';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa12,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+',(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 = '+quote_literal(lcTegev)+' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';


		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa24,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+',(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 = '+quote_literal(lcTegev)+' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';


		execute lcString;


--	 Narva Linnavalitsuse Rahandusamet sh laenude tagastamine ja intressi tasumine
   		
	lnrekvId1 = 63;
	lnrekvId2 = 63;

	LNcOUNT = 0;

	FOR lnCount IN 1..10
	loop
	
		lcTegev = '0'+ltrim(rtrim(lnCount::varchar))+'%';

		if lnCount = 10 then
			lcTegev = ltrim(rtrim(lnCount::varchar))+'%';
		end if;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 like '+quote_literal(lcTegev);


		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount+12)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 like '+quote_literal(lcTegev);


		execute lcString;


--			raise notice 'lcString %',lcString;

	end loop;


--		lcTegev = '01114';
		lcEelarve = '608';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa11,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa23,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;

--LA
		lcTegev = '01700';
		lcEelarve = '6501.8';
		lcEelarve1 = '2081.6.8';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa12,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 = '+quote_literal(lcTegev)+' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';


		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa24,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 = '+quote_literal(lcTegev)+' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';


		execute lcString;


--	  Narva Linnavalitsuse  Arhitektuuri- ja Linnaplaneerimise Amet
   		
	lnrekvId1 = 29;
	lnrekvId2 = 29;


	LNcOUNT = 0;

	FOR lnCount IN 1..10
	loop
	
		lcTegev = '0'+ltrim(rtrim(lnCount::varchar))+'%';

		if lnCount = 10 then
			lcTegev = ltrim(rtrim(lnCount::varchar))+'%';
		end if;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 like '+quote_literal(lcTegev);


		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount+12)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 like '+quote_literal(lcTegev);


		execute lcString;

--			raise notice 'lcString %',lcString;

	end loop;


--		lcTegev = '01114';
		lcEelarve = '608';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa11,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+',(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa23,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+',(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;

--LA
		lcTegev = '01700';
		lcEelarve = '6501.8';
		lcEelarve1 = '2081.6.8';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa12,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 = '+quote_literal(lcTegev)+' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';


		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa24,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+', (taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 = '+quote_literal(lcTegev)+' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';


		execute lcString;

--	  Narva Linna Arenduse ja Ökonoomika Amet
   		
	lnrekvId1 = 28;
	lnrekvId2 = 28;


	LNcOUNT = 0;

	FOR lnCount IN 1..10
	loop
	
		lcTegev = '0'+ltrim(rtrim(lnCount::varchar))+'%';

		if lnCount = 10 then
			lcTegev = ltrim(rtrim(lnCount::varchar))+'%';
		end if;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+',(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 like '+quote_literal(lcTegev);


		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( RekvIdSub, summa'+ltrim(rtrim(str(lnCount+12)))+',timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+',(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 like '+quote_literal(lcTegev);


		execute lcString;

--			raise notice 'lcString %',lcString;

	end loop;


--		lcTegev = '01114';
		lcEelarve = '608';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa11,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+',(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa23,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+',(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood5 = '+quote_literal(lcEelarve);

		execute lcString;

--LA
		lcTegev = '01700';
		lcEelarve = '6501.8';
		lcEelarve1 = '2081.6.8';

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa12,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+',(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 3 and taotlus1.kood1 = '+quote_literal(lcTegev)+' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';


		execute lcString;

		lcString = 'INSERT into tmp_eelproj_aruanne2 ( rekvidsub, summa24,timestamp,rekvid) '+
			' select '+str(lnRekvid1,9)+',(taotlus1.summa * ifnull(dokvaluuta1.kuurs,1)),'+quote_literal(lcreturn)+',' +str(tnrekvId)+' from taotlus1'+ 
			' inner join taotlus on taotlus.id = taotlus1.parentid '+
			' inner join eelproj on taotlus1.eelprojid = eelproj.id '+
			' inner join rekv on taotlus.rekvid = rekv.id '+
			' inner join library on (library.kood = taotlus1.kood5 and library.tun5 = 2 and library.library = ''TULUDEALLIKAD'' ) '+
			' left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14) '+
			' where taotlus.aasta = '+str(year(tdKpv2)+1) +
			' and (rekv.id = '+str(lnRekvid1,9)+' or rekv.parentid = '+str(lnRekvid2,9)+')'+
			' and taotlus.staatus = 1 and taotlus1.kood1 = '+quote_literal(lcTegev)+' and (taotlus1.kood5 = '+quote_literal(lcEelarve) + 
			' or taotlus1.kood5 = '+quote_literal(lcEelarve1)+')';


		execute lcString;

		INSERT into tmp_eelproj_aruanne2 (rekvidsub, nimetus, summa1, summa2, summa3, summa4, summa5, summa6, summa7,summa8,summa9,summa10,summa11,summa12,
		summa13, summa14, summa15, summa16, summa17, summa18, summa19,summa20,summa21,summa22,summa23,summa24,
		 timestamp,rekvid)
		select rekvidsub,rekv.nimetus, sum(summa1), sum(summa2), sum(summa3), sum(summa4), sum(summa5), sum(summa6),sum(summa7),sum(summa8),sum(summa9), 
		sum(summa10), sum(summa11), sum(summa12),sum(summa13), sum(summa14), sum(summa15), sum(summa16), sum(summa17), sum(summa18),sum(summa19),
		sum(summa20),sum(summa21), sum(summa22), sum(summa23), sum(summa24),
		lcreturn+'LOPP', tnrekvId from tmp_eelproj_aruanne2 inner join rekv on tmp_eelproj_aruanne2.rekvidsub = rekv.id
		where timestamp = lcReturn
		group by rekvidsub, rekv.nimetus
		order by rekvidsub desc;

		delete from tmp_eelproj_aruanne2 where timestamp = lcReturn;
	
		lcReturn = lcReturn + 'LOPP';
		
end if;


return LCRETURN;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_eelproj_aruanne2(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_eelproj_aruanne2(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_eelproj_aruanne2(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_eelproj_aruanne2(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO eelaktsepterja;
GRANT EXECUTE ON FUNCTION sp_eelproj_aruanne2(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_eelproj_aruanne2(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO dbkasutaja;
