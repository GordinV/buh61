-- Function: sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character)

-- DROP FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character);

/*

select * from library where kood = 'Viru 39a - 31'

select * from objekt where libid = 39227

	select fncKorteridSoeVeega(39069,2,'aa');


	select (loppkogus - algkogus) , counter.*
		from counter inner join library on library.id = counter.parentid 
		where library.tun2 in (select library.id from library inner join objekt on library.id = objekt.libid where  Objekt.parentid = 40877) 
				and library.tun3 = 115 
				and month(counter.kpv) = month(date(2011,05,31)) 
				and year(counter.kpv) = year(date(2011,05,31))
				and library.tun1 = 1;

	select sum(loppkogus - algkogus) 
		from counter inner join library on library.id = counter.parentid 
		where library.tun2 in (select library.id from library inner join objekt on library.id = objekt.libid where  Objekt.parentid = 40877) 
				and library.tun3 = 115 
				and month(counter.kpv) = month(date(2011,05,31)) 
				and year(counter.kpv) = year(date(2011,05,31))
				and library.tun1 = 1;

select * from nomenklatuur where id = 115

select * froM library where upper(kood) like upper('Mere 5%') and library = 'OBJEKT'
select sp_arvesta_kutte3(1, '',38616,  date(2011,05,31));


*/

CREATE OR REPLACE FUNCTION sp_arvesta_kutte3(integer, character varying, integer, date)
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
	lnSumma10 numeric(16,4);
	lnSumma11 numeric(16,4);
	lnSumma12 numeric(16,4);
	lnSumma13 numeric(16,4);
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


	lnKutteVanni = 1854;

	select hind into lnVdHind from nomenklatuur where id = lnVdId;
	select hind into lnSvt1Hind from nomenklatuur where id = lnSvt1;
	select hind into lnSvt2Hind from nomenklatuur where id = lnSvt2;
	select hind into lnSvt3Hind from nomenklatuur where id = lnSvt3;
	select hind into lnSvt4Hind from nomenklatuur where id = lnSvt4;

	select hind into lnKutteVanniHind from nomenklatuur where id = lnKutteVanni;
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



	lnSumma01 = fncteenus(lnKorterId, lnKutteSEJId, tdKpv,1,'aaa');

-- ?[vd2
	lnSumma03 = fncteenus(lnKorterId, lnVdId, tdKpv,2,'aaa');

-- vd kogus
	select sum(loppkogus - algkogus) into lnSumma14
		from counter inner join library on library.id = counter.parentid 
		where library.tun2 in (select library.id from library inner join objekt on library.id = objekt.libid where  Objekt.parentid = tnMajaId) 
				and library.tun3 = lnVdId 
				and month(counter.kpv) = month(tdKpv) 
				and year(counter.kpv) = year(tdKpv)
				and library.tun1 = 1;
				
	

	
	
--( ?{kutteSEJ -  ?[vd2  -  ?[fncInim  *  ( ?svt1 +  ?svt2 +  ?svt3 )  -  ?[fncVK  * ?KutteVanni  ) /  ?[fncKorteridSoeVeega

--	raise notice 'summa15 %',lnsumma15;

	--?[fncVK  *  ?KutteVanni		
--	lnSumma16 = fncVKA(ifnull(lnKorterId,0), 2) * lnKutteVanniHind;	
	lnSumma07 = fncVK(lnKorterId, 2);	

--	lnSumma18 = fncmottepaevad(lnKorterId, 2, tdKpv) ;
	lnSumma04 = fncinimised(lnKorterId, 2,'aaa') ;

--  ( ?svt1 +  ?svt2 +  ?svt3 )
	lnSumma05 =  (fncteenus(lnKorterId, lnsvt1, tdKpv,0) * ifnull(lnSvt1Hind,0)+
			fncteenus(lnKorterId, lnsvt2, tdKpv,0) * ifnull(lnSvt2Hind,0) +
			fncteenus(lnKorterId, lnsvt3, tdKpv,0) * ifnull(lnSvt3Hind,0)+
			fncteenus(lnKorterId, lnsvt4, tdKpv,0)* ifnull(lnSvt4Hind,0) ) ;
--			* lnSumma18 / DaysInMonth(tdKpv) ;

	lnSumma13 = fncKorteridSoeVeega(lnKorterId,2,'aa');

	lnsumma06 = lnSumma04 * lnSumma05;
	lnSumma12 = (ifnull(lnSumma01,0)*lnKutteSejHind - lnSumma03 -  (lnSumma07* lnKutteVanniHind) - lnSumma06);
	lnSumma09 = lnSumma07 *lnKutteVanniHind;

	lnSumma10 = 0;
	raise notice 'lnSumma13 %',lnSumma13;
	raise notice 'lnSumma07 %',lnSumma07;
	
	if ifnull(lnSumma13,0) = 0  then
		if ifnull(lnSumma07,0)  > 0 then
			lnSumma10 = ifnull(lnSumma01,0) * lnKutteSejHind / lnSumma07;
		end if;
	else
		lnSumma10 = lnSumma12 / lnSumma13;
	end if;
	
	if ifnull(lnSumma01,0) > 0 then
	
		insert into tmp_Kutte1 (maja, korter , timestamp, rekvid,summa01, summa02, summa03, summa04, summa05, summa06, summa07, 
		summa08, summa09, summa12, summa13, summa14, summa10)
			values (v_maja.kood, v_maja.kood, lcreturn, tnrekvId,
			 ifnull(lnSumma01,0), lnKutteSejHind, ifnull(lnSumma03,0), lnSumma04 , lnSumma05, lnSumma06, lnSumma07, 
			lnKutteVanniHind, lnSumma09, lnSumma12, lnSumma13, ifnull(lnSumma14,0), lnSumma10 );
	end if;

/*


	for v_maja in
			select library.id, library.kood, library.nimetus, maja.kood as maja, maja.nimetus as majaaadress,
			objekt.asutusId, objekt.parentid,
			objekt.nait01,objekt.nait02,objekt.nait03,objekt.nait04,objekt.nait05,objekt.nait06,objekt.nait07,objekt.nait08,objekt.nait09,objekt.nait10
		from library inner join objekt on (library.id = objekt.libid and objekt.parentId > 0)
			inner join library maja on objekt.parentid = maja.id
			where library.rekvid = tnRekvId			
			and objekt.parentid = tnMaJaId 
	loop
		raise notice 'maja: %',v_maja.nimetus;

-- ?[fncInim  * (  ?svt1 + ?svt2 + ?svt3 + ?svt4 )  * ?fncMottePaevad 
	
		lnSumma11 = (fncteenus(v_maja.id, lnsvt1, tdKpv,0) * ifnull(lnSvt1Hind,0)+
			fncteenus(v_maja.id, lnsvt2, tdKpv,0) * ifnull(lnSvt2Hind,0) +
			fncteenus(v_maja.id, lnsvt3, tdKpv,0) * ifnull(lnSvt3Hind,0)+
			fncteenus(v_maja.id, lnsvt4, tdKpv,0)* ifnull(lnSvt4Hind,0)) ;
			
		lnSumma18 = fncmottepaevad(v_maja.id, 0, tdKpv) ;
		lnSumma04 = fncinimised(v_maja.id, 0) ;
		lnSumma17 = lnSumma04 * lnSumma11 * lnSumma18 / DaysInMonth(tdKpv);	
		
		lnSumma03 = fncteenus(v_maja.id, lnVdId, tdKpv,0);
		-- kogus, otsime hind
		select hind into lnVdLepHind from leping2 inner join leping1 on leping1.id = leping2.parentid where leping1.objektId = v_maja.id and leping2.nomid = lnVdId ;
		lnVdLepHind = ifnull(lnVdLepHind,lnVdHind);


-- ?[fncKPindA   *  ?{fncK   * ( ?mop1 + ?mop2 + ?mop3 + ?mop4 +?mop5 )

		lnSumma05 =  fnckpinda(v_maja.id, 0) * lnK *(fncteenus(v_maja.id, lnMop1, tdKpv,0) * ifnull(lnMop1Hind,0) + 
			fncteenus(v_maja.id, lnMop2, tdKpv,0) * ifnull(lnMop2Hind,0) + 
			fncteenus(v_maja.id, lnMop3, tdKpv,0) * ifnull(lnMop3Hind,0) + 
			fncteenus(v_maja.id, lnMop4, tdKpv,0) * ifnull(lnMop4Hind,0) + 
			fncteenus(v_maja.id, lnMop5, tdKpv,0) * ifnull(lnMop5Hind,0));	


	lnSumma06 = fncteenus(ifnull(lnKorterId,0), lnt1, tdKpv,0)* lnK+ 
		fncteenus(ifnull(lnKorterId,0), lnt12, tdKpv,0)* lnK + 
		fncteenus(ifnull(lnKorterId,0), lnt34, tdKpv,0)* lnK + 
		fncteenus(ifnull(lnKorterId,0), lnt114, tdKpv,0)* lnK;

--?fncKPindT
		lnSumma09 = fncKPindT(v_maja.id,0);
--		lnSumma12 = (ifnull(lnSumma01,0)*lnKutteSejHind - lnSumma07 - lnSumma15 - lnSumma04 - lnSumma05 - lnSumma06);

		if lnSumma09 = 0 then
			lnSumma09 = 1;
			lnSumma12 = 0;
		end if;
--HIND:( ?{kutteSEJ  -  ?[vd2  -  ?[fncInim  * (  ?svt1 + ?svt2 + ?svt3 + ?svt4 )  * ?fncMottePaevad  -  ?[fncKPindA   *  ?{fncK   * ( ?mop1 + ?mop2 + ?mop3 + ?mop4 +?mop5 )  - ?[t1  * ?{fncK -  ?[t12  * ?{fncK  -  ?[t34  * ?{fncK  -  ?[t114  * ?{fncK  -  ?[fncVKA  *  ?KutteVanni )  /  ?[fncKPindT  

--?[fncVKA  *  ?KutteVanni		
	lnSumma07 = fncVKA(ifnull( v_maja.id,0), 0);	

		
		insert into tmp_Kutte1 (asutusId, parentid, maja, korter , timestamp, rekvid,
			 summa03, summa04, summa05, summa06, summa07,summa08, summa09, summa10, summa11, summa12, summa13, summa18)
			values ( v_maja.asutusid, v_maja.parentId,v_maja.majaaadress, v_maja.nimetus, lcreturn, tnrekvId,
			ifnull(lnSumma03,0), lnSumma04 , lnSumma05, lnSumma06, lnSumma07, lnVdLepHind, lnSumma09, lnKutteVanniHind, lnSumma11, lnSumma12,lnSumma08,  lnSumma18 );

	end loop;
*/

	return LCRETURN;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_arvesta_kutte3(integer, character varying,  integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_arvesta_kutte3(integer, character varying, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_arvesta_kutte3(integer, character varying, integer, date) TO dbpeakasutaja;
