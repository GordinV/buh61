-- Function: sp_eelproj_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer)

-- DROP FUNCTION sp_eelproj_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer);

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
	lnSumma numeric(12,4);

	lnPlaan numeric(12,4);
	lnTaitm numeric(12,4);

	v_eelaruanne record;

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
if tnLiik = 1 then
		raise notice 'Narva linna 2008.a. tulude ja finantseerimistehingute eelarve eelnõu';

		--  Põhieelarve   		

		INSERT into tmp_eelproj_aruanne1 ( Eelarve, Nimetus, summa1,timestamp,rekvid)
			select eelarve.kood4, library.nimetus, sum(summa), lcreturn, tnrekvId from eelarve
			inner join rekv on rekv.id = eelarve.rekvId
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			where left(eelarve.kood4,1) = '3' and eelarve.aasta = year(tdKpv2)
			group by  eelarve.kood4, library.nimetus;

		--  allikas 80 omatulu    		

		INSERT into tmp_eelproj_aruanne1 ( Eelarve, nimetus, summa2,	timestamp,rekvid)
			select eelarve.kood4,library.nimetus, sum(summa), lcreturn, tnrekvId from eelarve
			inner join rekv on rekv.id = eelarve.rekvId
			inner join library on (library.kood = eelarve.kood4 and library.library = 'TULUDEALLIKAD')
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			where left(eelarve.kood4,1) = '3' and eelarve.kood2 = '80' and eelarve.aasta = year(tdKpv2)
			group by  eelarve.kood4, library.nimetus;


		--  allikas LE-LA    		

		INSERT into tmp_eelproj_aruanne1 ( eelarve, nimetus, summa1,	timestamp, rekvid)
			select '20', 'Kohustuste suurenemine /laenude võtmine muudelt residentidelt/',
			sum(summa), lcreturn, tnrekvId from eelarve
			inner join rekv on rekv.id = eelarve.rekvId
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			where left(eelarve.kood4,1) = '3' and eelarve.kood2 = 'LE-LA' and eelarve.aasta = year(tdKpv2);

-- Muutus kassas ja hoiustes /vaba jääk,suunatud kulude katteks/
-- Plaan-täitmine. Sellest lahutada 60, RE-HK,RE-KL, RE-ST, RE-TT, RE-TH. Allikas RE-Muud  näidata eraldi real 
		lnPlaan = 0;
		lnTaitm = 0;
                
		select 	sum(summa) into lnPlaan from eelarve
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			where left(eelarve.kood4,1) = '3' 
			and eelarve.kood2 not in ('60', 'RE-HK','RE-KL', 'RE-ST', 'RE-TT', 'RE-TH') 
			and eelarve.aasta = year(tdKpv2);
		lnPlaan = ifnull(lnPlaan,0);


		select 	sum(summa) into lnTaitm from curkassatuludetaitmine
			inner join tmprekv on curkassatuludetaitmine.rekvId = tmprekv.id
			where curkassatuludetaitmine not in ('60', 'RE-HK','RE-KL', 'RE-ST', 'RE-TT', 'RE-TH') 
			and curkassatuludetaitmine.aasta = year(tdKpv2);
		lnTaitm = ifnull(lnTaitm,0);

		INSERT into tmp_eelproj_aruanne1 ( eelarve, nimetus, summa1,	timestamp,rekvid) values 
			 ('100', 'Muutus kassas ja hoiustes /vaba jääk,suunatud kulude katteks/', lnPlaan - lnTaitm, lcreturn, tnrekvId);


		select 	sum(summa) into lnPlaan from eelarve
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			where left(eelarve.kood4,1) = '3' 
			and eelarve.kood2 = 'RE-Muud' 
			and eelarve.aasta = year(tdKpv2);
		lnPlaan = ifnull(lnPlaan,0);


		select 	sum(summa) into lnTaitm from curkassatuludetaitmine
			inner join tmprekv on curkassatuludetaitmine.rekvId = tmprekv.id
			where curkassatuludetaitmine.kood2 =  'RE-Muud' 
			and curkassatuludetaitmine.aasta = year(tdKpv2);
		lnTaitm = ifnull(lnTaitm,0);

		INSERT into tmp_eelproj_aruanne1 ( eelarve, nimetus, summa1,timestamp,rekvid) values 
			 ('100', 'Muutus kassas ja hoiustes /muud/', lnPlaan - lnTaitm, lcreturn, tnrekvId);


		-- final, kokkuvõtte

		INSERT into tmp_eelproj_aruanne1 ( eelarve, nimetus, summa1,summa2 ,timestamp,rekvid)
			select eelarve, nimetus, sum(summa1),sum(summa2), lcreturn+'LOPP', tnrekvId 
			from tmp_eelproj_aruanne1 where timestamp = lcreturn
			group by eelarve, nimetus, timestamp,rekvid;

		-- kustutame temp.andmed

		delete from tmp_eelproj_aruanne1 where timestamp = lcreturn;
		
		lcReturn = LCRETURN+'LOPP';
			

end if;
	

return LCRETURN;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO eelaktsepterja;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_eelarve_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO dbkasutaja;
