 -- Function: sp_eelproj_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer)
/*
			select eelarve.rekvId, rekv.nimetus, rekv.parentId, sum(summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId from eelarve
			inner join rekv on rekv.id = eelarve.rekvId
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			JOIN faktkulud ON ltrim(rtrim(eelarve.kood4::text)) ~~ ltrim(rtrim(faktkulud.kood::text))			
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.kood2 in ('LE-P') and eelarve.aasta = year(tdKpv2)
			and left(kood4,1) <> '3' and kood4 not in ('2080.5','2081.5')
			group by eelarve.rekvId, rekv.nimetus, rekv.parentid;

*/
-- DROP FUNCTION sp_eelproj_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer);

CREATE OR REPLACE FUNCTION sp_eelproj_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer)
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

	v_eelaruanne record;

begin


	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_EELPROJ_ARUANNE1';



	if ifnull(lnCount,0) < 1 then



		raise notice ' lisamine  ';

	

		create table tmp_eelproj_aruanne1 ( id int, konto varchar(20), 
			RekvIdSub int not null default 0, RekvIdAll int not null default 0, 
			AllAsutus varchar(254) not null default space(1),
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
if tnLiik = 1 or tnLiik = 2 then
		raise notice 'Lisa 2';
		-- 1.	lisa 2
		
		--  Põhieelarve  LE-P, LE-RF  		
/*
		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, AllAsutus, RekvIdAll,summa1,timestamp,rekvid)
			select eelarve.rekvId, rekv.nimetus, rekv.parentId, sum(summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId from eelarve
			inner join rekv on rekv.id = eelarve.rekvId
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			inner join library kulud on (eelarve.kood4 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.kood2 in ('LE-P') and eelarve.aasta = year(tdKpv2)
			group by eelarve.rekvId, rekv.nimetus, rekv.parentid;
*/
		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, AllAsutus, RekvIdAll,eelarve, summa1,timestamp,rekvid)
			select taotlus.rekvId, rekv.nimetus, rekv.parentId, taotlus1.kood5,sum(summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId 
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join rekv on rekv.id = taotlus.rekvId
			inner join tmprekv on taotlus.rekvId = tmprekv.id
			inner join library kulud on (taotlus1.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus1.kood2 in ('LE-P') and taotlus.aasta = year(tdKpv2)
			and taotlus.staatus in (1,3)
			group by taotlus.rekvId, rekv.nimetus, rekv.parentid, taotlus1.kood5;


--			JOIN faktkulud ON ltrim(rtrim(eelarve.kood4::text)) ~~ ltrim(rtrim(faktkulud.kood::text))			

		-- Laenu arvelt LE-LA
/*
		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, AllAsutus, RekvIdAll, summa2,	timestamp,rekvid)
			select eelarve.rekvId, rekv.nimetus, rekv.parentId, sum(summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId from eelarve
			inner join rekv on rekv.id = eelarve.rekvId
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			inner join library kulud on (eelarve.kood4 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.kood2 in ('LE-LA') and eelarve.aasta = year(tdKpv2)
			group by eelarve.rekvId, rekv.nimetus , rekv.parentid;

*/
		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, AllAsutus, RekvIdAll,eelarve, summa2,	timestamp,rekvid)
			select taotlus.rekvId, rekv.nimetus, rekv.parentId, taotlus1.kood5, sum(summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId 
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join rekv on rekv.id = taotlus.rekvId
			inner join tmprekv on taotlus.rekvId = tmprekv.id
			inner join library kulud on (taotlus1.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus1.kood2 in ('LE-LA') and taotlus.aasta = year(tdKpv2)
			and taotlus.staatus in (1,3)
			group by taotlus.rekvId, rekv.nimetus , rekv.parentid, taotlus1.kood5;


		-- Riigieelarvest  RE-HK, RE-KL, RE-ST, RE-TT, RE-TH 
/*
		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, AllAsutus, RekvIdAll,summa3,	timestamp,rekvid)
			select eelarve.rekvId, rekv.nimetus, rekv.parentId, sum(summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId 
			from eelarve
			inner join rekv on rekv.id = eelarve.rekvId
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			inner join library kulud on (eelarve.kood4 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.kood2 in ('RE-HK','RE-KL','RE-ST','RE-TT','RE-TH') and eelarve.aasta = year(tdKpv2)
			group by eelarve.rekvId, rekv.nimetus, rekv.parentid;
*/
		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, AllAsutus, RekvIdAll,eelarve, summa3,	timestamp,rekvid)
			select taotlus.rekvId, rekv.nimetus, rekv.parentId, taotlus1.kood5, sum(summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId 
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join rekv on rekv.id = taotlus.rekvId
			inner join tmprekv on taotlus.rekvId = tmprekv.id
			inner join library kulud on (taotlus1.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus1.kood2 in ('RE-HK','RE-KL','RE-ST','RE-TT','RE-TH') and taotlus.aasta = year(tdKpv2)
			and taotlus.staatus in (1,3)
			group by taotlus.rekvId, rekv.nimetus, rekv.parentid, taotlus1.kood5;

		--sihtotstarbelised toetused   LE-Muud, 60
/*
		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub,AllAsutus, RekvIdAll,summa4,	timestamp,rekvid)
			select eelarve.rekvId, rekv.nimetus, rekv.parentId, sum(summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId 
			from eelarve
			inner join rekv on rekv.id = eelarve.rekvId
			inner join tmprekv on eelarve.rekvId = tmprekv.id
			inner join library kulud on (eelarve.kood4 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = eelarve.id and dokvaluuta1.dokliik = 8)
			where eelarve.kood2 in ('LE-Muud', '60') and eelarve.aasta = year(tdKpv2)
			group by eelarve.rekvId, rekv.nimetus, rekv.parentid;
*/

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub,AllAsutus, RekvIdAll,kood5, summa4,	timestamp,rekvid)
			select taotlus.rekvId, rekv.nimetus, rekv.parentId, taotlus1.kood5, sum(summa * ifnull(dokvaluuta1.kuurs,1)), lcreturn, tnrekvId 
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join rekv on rekv.id = taotlus.rekvId
			inner join tmprekv on taotlus.rekvId = tmprekv.id
			inner join library kulud on (taotlus1.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus1.kood2 in ('LE-Muud', '60') and taotlus.aasta = year(tdKpv2)
			and taotlus.staatus in (1,3)
			group by taotlus.rekvId, rekv.nimetus, rekv.parentid, taotlus1.kood5;

		-- RF

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub,AllAsutus, RekvIdAll, summa1, timestamp,rekvid)
			select 9999, ' Reservfond ', tnrekvId,  ifnull(sum(summa * ifnull(dokvaluuta1.kuurs,1)),0), lcreturn, tnrekvId 
			from taotlus inner join taotlus1 on taotlus.id = taotlus1.parentid
			inner join tmprekv on taotlus.rekvId = tmprekv.id
			inner join library kulud on (taotlus1.kood5 = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
			left outer join dokvaluuta1 on (dokvaluuta1.dokid = taotlus1.id and dokvaluuta1.dokliik = 14)
			where taotlus1.kood2 in ('LE-RF') and taotlus.aasta = year(tdKpv2) and taotlus.staatus in (1,3);

		if tnLiik = 2 then
			--Lisa 2 taitmine
			INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, AllAsutus,eelarve, summa5,	timestamp,rekvid)
				select curkassakuludetaitmine.rekvId, rekv.nimetus,curkassakuludetaitmine.kood,  sum(summa), lcreturn, tnrekvId 
				from curkassakuludetaitmine
				inner join rekv on rekv.id = curkassakuludetaitmine.rekvId
				inner join tmprekv on curkassakuludetaitmine.rekvId = tmprekv.id
				inner join library kulud on (curkassakuludetaitmine.kood = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
				where curkassakuludetaitmine.aasta = year(tdKpv2)
				AND curkassakuludetaitmine.KOOD2 <> 'LE-RF'
				group by curkassakuludetaitmine.rekvId, rekv.nimetus, curkassakuludetaitmine.kood;

			-- RF

			INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, AllAsutus,eelarve, summa5, timestamp,rekvid)
				select 9999, ' Reservfond ', curkassakuludetaitmine.kood, IFNULL(sum(summa),0), lcreturn, tnrekvId 
				from curkassakuludetaitmine
				inner join rekv on rekv.id = curkassakuludetaitmine.rekvId
				inner join tmprekv on curkassakuludetaitmine.rekvId = tmprekv.id
				inner join library kulud on (curkassakuludetaitmine.kood = kulud.kood and kulud.library = 'TULUDEALLIKAD' and kulud.tun5 = 2)
				where curkassakuludetaitmine.aasta = year(tdKpv2)
				AND curkassakuludetaitmine.kood2 = 'LE-RF'
				group by curkassakuludetaitmine.rekvId, rekv.nimetus, curkassakuludetaitmine.kood;


		end if;

		-- final, kokkuvõtte

		INSERT into tmp_eelproj_aruanne1 ( RekvIdSub, AllAsutus,summa1,summa2,summa3,summa4,summa5, timestamp,rekvid)
			select RekvIdSub,AllAsutus ,sum(summa1),sum(summa2),sum(summa3),sum(summa4),sum(summa5), lcreturn+'LOPP', tnrekvId 
			from tmp_eelproj_aruanne1 
			where timestamp = lcreturn
			group by RekvIdSub, AllAsutus,  timestamp,rekvid
			order by RekvIdSub;

			

end if;

-- kustutame temp.andmed
delete from tmp_eelproj_aruanne1 where timestamp = lcreturn;
		
lcReturn = LCRETURN+'LOPP';

	

	return LCRETURN;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_eelproj_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_eelproj_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_eelproj_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_eelproj_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO eelaktsepterja;
GRANT EXECUTE ON FUNCTION sp_eelproj_aruanne1(integer, date, date, integer, character varying, character varying, character varying, character varying, character varying, integer, integer) TO dbpeakasutaja;
