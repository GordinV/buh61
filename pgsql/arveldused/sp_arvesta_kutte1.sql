-- Function: sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character)

-- DROP FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character);

/*

select leping1.objektid, leping2.* from leping1 inner join leping2 on leping1.id = leping2.parentid where objektid in (select libid from objekt where parentid = 41176) and nomid = 115

select fnckpinda(41943, 2)

select * from nomenklatuur where id = 115
kood like 'kutte%' order by kood
select fncTeenus(42502, 132,date(2011,02,28),1)
select fncteenus(ifnull(40978,0), 115, date(2011,02,28),2);

select objekt.parentid from objekt where libid = 42502;

select * from library where id = 42502

select * froM library where upper(kood) like upper('Gagarini 35%') and library = 'OBJEKT'
select *from counter where parentid = 47595

select fncmottepaevad(ifnull(41024,0), 2, date(2011,02,28)) ;


delete from tmp_kutte1;
select sp_arvesta_kutte(1, '',41176,  date(2011,02,28));

select * from tmp_kutte1;

select  fncinimised(41024, 0) 

(fncteenus(v_maja.id, lnsvt1, tdKpv,0) * ifnull(lnSvt1Hind,0)+
			fncteenus(v_maja.id, lnsvt2, tdKpv,0) * ifnull(lnSvt2Hind,0) +
			fncteenus(v_maja.id, lnsvt3, tdKpv,0) * ifnull(lnSvt3Hind,0)+
			fncteenus(v_maja.id, lnsvt4, tdKpv,0)* ifnull(lnSvt4Hind,0)) ;

*/

CREATE OR REPLACE FUNCTION sp_arvesta_kutte(integer, character varying, integer, date)
  RETURNS character varying AS
$BODY$
DECLARE tnrekvid alias for $1;
	tcReturn alias for $2;
	tnMajaId alias for $3;
	tdKpv alias for $4;
	lcReturn varchar;
	lnCount integer;
	lcString varchar;
	v_maja record;
	
	lnKutteSEJId integer; 
	lnKutteSejHind numeric(16,4);
	lnVdId integer; 
	lnVdHind numeric(16,4); 
	lnVdLepHind numeric(16,4); 
	lnSvt1 integer; 
	lnSvt2 integer; 
	lnSvt3 integer; 
	lnSvt4 integer; 
	
	lnSvt1Hind numeric(16,4); 
	lnSvt2Hind numeric(16,4); 
	lnSvt3Hind numeric(16,4); 
	lnSvt4HInd numeric(16,4); 

	lnMop1 integer;
	lnMop2 integer;
	lnMop3 integer;
	lnMop4 integer;
	lnMop5 integer;
	lnMop1Hind numeric(16,4);
	lnMop2Hind numeric(16,4);
	lnMop3Hind numeric(16,4);
	lnMop4Hind numeric(16,4);
	lnMop5Hind numeric(16,4);

	lnT1 integer;
	lnT12 integer;
	lnT114 integer;
	lnT34 integer;

	lnKutteVanni integer;
	lnKutteVanniHind numeric(16,4);
	
	lnKorterId integer;
	lnK numeric(16,4);

	lnFncInim integer;
	lnSumma01 numeric(16,4);
	lnSumma03 numeric(16,4);
	lnSumma04 numeric(16,4);
	lnSumma05 numeric(16,4);
	lnSumma06 numeric(16,4);
	lnSumma07 numeric(16,4);
	lnSumma08 numeric(16,4);
	lnSumma09 numeric(16,4);
	lnSumma11 numeric(16,4);
	lnSumma12 numeric(16,4);
	lnSumma14 numeric(16,4);
	lnSumma15 numeric(16,4);
	lnSumma16 numeric(16,4);
	lnSumma17 numeric(16,4);
	lnSumma18 numeric(16,4);
	lnSumma19 numeric(16,4);
	lnSumma20 numeric(16,4);
	lnSumma21 numeric(16,4);
	lnSumma22 numeric(16,4);

begin

	lnKutteSEJId = 132;
	lnVdId = 115;
	lnSvt1 = 1851;
	lnSvt2 = 1852;
	lnSvt3 = 1853;
	lnSvt4 = 1860;

	lnMop1 = 1855;
	lnMop2 = 1856;
	lnMop3 = 1857;
	lnMop4 = 1858;
	lnMop5 = 1858;

	lnT1 = 1849;
	lnT12 = 131;
	lnT114 = 1864;
	lnT34 = 894;

	lnKutteVanni = 1854;

	select hind into lnVdHind from nomenklatuur where id = lnVdId;

	select hind into lnKutteVanniHind from nomenklatuur where id = lnKutteVanni;
	select hind into lnSvt1Hind from nomenklatuur where id = lnSvt1;
	select hind into lnSvt2Hind from nomenklatuur where id = lnSvt2;
	select hind into lnSvt3Hind from nomenklatuur where id = lnSvt3;
	select hind into lnSvt4Hind from nomenklatuur where id = lnSvt4;
	select hind into lnMop1Hind from nomenklatuur where id = lnMop1;
	select hind into lnMop2Hind from nomenklatuur where id = lnMop2;
	select hind into lnMop3Hind from nomenklatuur where id = lnMop3;
	select hind into lnMop4Hind from nomenklatuur where id = lnMop4;
	select hind into lnMop5Hind from nomenklatuur where id = lnMop5;

	select hind into lnKutteSejHind from nomenklatuur where id = lnKutteSEJId;
	lnKutteSejHind = ifnull(lnKutteSejHind,0);

	-- Esimine korter selles majas


	select libid into lnKorterId from objekt where parentid = tnMajaId order by id limit 1;

	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_KUTTE1';
	if ifnull(lnCount,0) < 1 then
	
		create table tmp_kutte1 (asutusid int default 0, parentid int default 0, maja varchar(254), korter varchar(254),
			  summa01 numeric (16,4) default 0, summa02 numeric (16,4) default 0, summa03 numeric (16,4) default 0,
			  summa04 numeric (16,4) default 0, summa05 numeric (16,4) default 0,
			  summa06 numeric (16,4) default 0, summa07 numeric (16,4) default 0,
			  summa08 numeric (16,4) default 0, summa09 numeric (16,4) default 0,
 			  summa10 numeric (16,4) default 0, summa11 numeric (16,4) default 0,summa12 numeric (16,4) default 0,
			  summa13 numeric (16,4) default 0, summa14 numeric (16,4) default 0,
			  summa15 numeric (16,4) default 0, summa16 numeric (16,4) default 0,
			  summa17 numeric (16,4) default 0, summa18 numeric (16,4) default 0,
			  summa19 numeric (16,4) default 0, summa20 numeric (16,4) default 0,
 			  summa21 numeric (16,4) default 0, summa22 numeric (16,4) default 0,
			 timestamp varchar(20), kpv date default date(), rekvid int)  ;
		
		GRANT ALL ON TABLE tmp_kutte1 TO GROUP public;

	else
		delete from tmp_kutte1 where kpv < date() and rekvid = tnrekvId;

	end if;
	lcreturn = tcReturn;
	if empty(tcReturn) then
		lcreturn := to_char(now(), 'YYYYMMDDMISSSS');
	end if;

	-- majade nimikiri

	select library.id, library.kood, library.nimetus,
		objekt.asutusId, objekt.parentid,
		objekt.nait01,objekt.nait02,objekt.nait03,objekt.nait04,objekt.nait05,objekt.nait06,objekt.nait07,objekt.nait08,objekt.nait09,objekt.nait10 into v_maja
		from library inner join objekt on library.id = objekt.libid
			where library.rekvid = tnRekvId			
			and library.id = tnMaJaId ;


	lnSumma01 = fncteenus(lnKorterId, lnKutteSEJId, tdKpv,1);

-- ?[vd2
	lnSumma03 = fncteenus(lnKorterId, lnVdId, tdKpv,2);
-- vd2 kogus

	select sum((loppkogus - algkogus) )  into lnSumma14
		from counter inner join library on library.id = counter.parentid 
		where library.tun2 in (
			select library.id from library INNER join objekt on library.id = objekt.libid 
			where library = 'OBJEKT' and parentid = tnMajaId
			) 
			and library.tun3 = lnVdId 
			and month(counter.kpv) = month(tdKpv) 
			and year(counter.kpv) = year(tdKpv)
			and library.tun1 = 1;

	lnSumma14 = ifnull(lnSumma14,0);
	if lnSumma14 = 0 then
		lnSumma14 = 1;
		lnSumma03 = 0;
	end if;

--	raise notice 'summa15 %',lnsumma15;
--?[t1  * ?{fncK -  ?[t12  * ?{fncK  -  ?[t34  * ?{fncK  -  ?[t114  * ?{fncK  - 
	lnK = fnck(lnKorterId, 1);
	lnSumma22 = fncteenus(lnKorterId, lnt1, tdKpv,2)* lnK+ 
		fncteenus(lnKorterId, lnt12, tdKpv,2)* lnK + 
		fncteenus(lnKorterId, lnt34, tdKpv,2)* lnK + 
		fncteenus(lnKorterId, lnt114, tdKpv,2)* lnK;

--?[fncVKA  *  ?KutteVanni		
--	lnSumma16 = fncVKA(ifnull(lnKorterId,0), 2) * fncteenus(ifnull(lnKorterId,0), lnKutteVanni, tdKpv,2) *  lnKutteVanniHind;	
--	lnSumma16 = fncVKA(ifnull(lnKorterId,0), 2) * lnKutteVanniHind;	
	lnSumma07 = fncVKA(lnKorterId, 2);	

-- ?[fncKPindT
	lnSumma08 = fncKPindT(lnKorterId, 2);	

-- ?[fncInim  * (  ?svt1 + ?svt2 + ?svt3 + ?svt4 )  * ?fncMottePaevad 

	lnSumma18 = fncmottepaevad(lnKorterId, 2, tdKpv) ;
	lnSumma04 = fncinimised(lnKorterId, 2) ;


	lnSumma19 = (fncteenus(lnKorterId, lnsvt1, tdKpv,0) * ifnull(lnSvt1Hind,0)+
			fncteenus(lnKorterId, lnsvt2, tdKpv,0) * ifnull(lnSvt2Hind,0) +
			fncteenus(lnKorterId, lnsvt3, tdKpv,0) * ifnull(lnSvt3Hind,0)); 
--			* lnSumma18 / DaysInMonth(tdKpv) ;
	lnSumma11 = lnSumma04 * lnSumma19;

	

-- ?[fncKPindA   *  ?{fncK   * ( ?mop1 + ?mop2 + ?mop3 + ?mop4 +?mop5 )

	lnSumma05 =  fnckpinda(lnKorterId, 2) * lnK *(fncteenus(lnKorterId, lnMop1, tdKpv,0) * ifnull(lnMop1Hind,0) + 
			fncteenus(lnKorterId, lnMop2, tdKpv,0) * ifnull(lnMop2Hind,0) + 
			fncteenus(lnKorterId, lnMop3, tdKpv,0) * ifnull(lnMop3Hind,0) + 
			fncteenus(lnKorterId, lnMop4, tdKpv,0) * ifnull(lnMop4Hind,0) + 
			fncteenus(lnKorterId, lnMop5, tdKpv,0) * ifnull(lnMop5Hind,0));	

	raise notice 'MOP %',lnSumma05;

--?[t1  * ?{fncK -  ?[t12  * ?{fncK  -  ?[t34  * ?{fncK  -  ?[t114  * ?{fncK 

	lnSumma06 = fncteenus(ifnull(lnKorterId,0), lnt1, tdKpv,2)* lnK+ 
		fncteenus(ifnull(lnKorterId,0), lnt12, tdKpv,2)* lnK + 
		fncteenus(ifnull(lnKorterId,0), lnt34, tdKpv,2)* lnK + 
		fncteenus(ifnull(lnKorterId,0), lnt114, tdKpv,2)* lnK;


	lnSumma12 = (ifnull(lnSumma01,0)*lnKutteSejHind - (lnSumma07* lnKutteVanniHind) - lnSumma03 - lnSumma11 - lnSumma05 - lnSumma06);

		insert into tmp_Kutte1 (maja, korter , timestamp, rekvid,summa01, summa02, summa03, summa04, summa05, summa06, summa07, 
		summa08, summa09, summa10, summa11,summa12, summa13, summa14, summa18, summa19)
			values (v_maja.kood, v_maja.kood, lcreturn, tnrekvId,
			 ifnull(lnSumma01,0), lnKutteSejHind, ifnull(lnSumma03,0), lnSumma04 , lnSumma05, lnSumma06, lnSumma07, 
			lnSumma08, lnSumma09, lnKutteVanniHind, lnSumma11, lnSumma12, lnSumma12/lnSumma09, lnSumma14, lnSumma18,lnSumma19 );



	return LCRETURN;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_arvesta_kutte(integer, character varying,  integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_arvesta_kutte(integer, character varying, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_arvesta_kutte(integer, character varying, integer, date) TO dbpeakasutaja;
