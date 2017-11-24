-- Function: sp_pv_aruanne2(integer, date, date, character varying, character varying, character varying)

-- DROP FUNCTION sp_pv_aruanne2(integer, date, date, character varying, character varying, character varying);
/*

select sp_pv_aruanne2(6, date(1900,01,01), date(2011,05,31), '', '', '')

select sp_pv_aruanne2(         6, DATE(1900, 1, 1), DATE(2011, 5,31),'%%','%','%%')

delete from tmp_pv_aruanne1

select * from tmp_pv_aruanne1

*/
CREATE OR REPLACE FUNCTION sp_pv_aruanne2(integer, date, date, character varying, character varying, character varying)
  RETURNS character varying AS
$BODY$
DECLARE 
	tnrekvid alias for $1;
	tdKpv1 alias for $2;
	tdKpv2 alias for $3;
	tcKonto alias for $4;
	tcGrupp alias for $5;
	tcVastIsik alias for $6;


	lcReturn varchar;
	lcString varchar;

	LNcOUNT int;
	lnSumma numeric(18,6);
	lnSoetmaks numeric(18,6);
	lnAlgKulum numeric(18,6);
	lnKulum numeric(18,8);
	lnKulumArv numeric(18,6);
	lnParandus numeric(18,6);
	lnMaha numeric(18,6);
	v_pvkaart record;

	ldAlgkpv date;
	lMaha int;
	lnPeriods numeric;
	lnJaak numeric(12,4);
begin

	

	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_PV_ARUANNE1';



	if ifnull(lnCount,0) < 1 then



	raise notice ' lisamine  ';

	

		create table tmp_pv_aruanne1 (id int, kood varchar(20), nimetus varchar(254), konto varchar(20), grupp varchar(254),
			soetkpv date, 
			soetmaks numeric(18,6), algkulum numeric(18,6), kulum numeric(18,6), kulukokku numeric(18,6),
			jaak numeric(18,6), parandus numeric(18,6), mahakantud numeric(18,6), 
			timestamp varchar(20), kpv date default date(), rekvid int, vastisik varchar(254), muud varchar(254))  ;

		

		GRANT ALL ON TABLE tmp_pv_aruanne1 TO GROUP public;



	else
		delete from tmp_pv_aruanne1 where kpv < date() and rekvid = tnrekvId;

	end if;


	lcreturn := to_char(now(), 'YYYYMMDDMISSSS');

	raise notice 'start';
	-- pv list 

	for v_pvkaart in 

	select curPohivara.id, curPohivara.kood, curPohivara.nimetus, curPohivara.konto, curPohivara.grupp, curPohivara.kulum,
		curPohivara.soetkpv, curPohivara.soetmaks, curpohivara.algkulum, curpohivara.TUNNUS, curPohivara.vastisik, curPohivara.rentnik as muud, curPohivara.kuurs
		from curPohivara 
		where rekvid = tnRekvId 
		and upper(curPohivara.konto) like upper(tcKonto)
		and upper(curPohivara.grupp) like upper(tcGrupp)
		and upper(curPohivara.vastisik) like upper(tcvastisik)
		and curPohivara.TUNNUS = 1
		order by curPohivara.grupp, curPohivara.kood, curPohivara.konto

	loop
		lMaha = 0;
		lnSumma = 0;
		lnSoetmaks = 0;
		lnAlgKulum = 0;
		lnKulum = 0;
		lnKulumArv = 0;
		lnParandus = 0;
		lnJaak = 0;
		if v_pvkaart.tunnus = 0 then
			-- mahakantud
			select kpv into ldAlgkpv from pv_oper 
				where parentid = v_pvkaart.id and liik = 4 order by kpv desc limit 1;
			if ldAlgkpv < tdKpv1 then
				lMaha = 1;
			end if;
		end if;

		if lMaha = 0 then

		insert into tmp_pv_aruanne1 (id, rekvid, timestamp, kood , nimetus, konto , grupp , soetkpv, vastisik, muud) 
			values (v_pvkaart.id, tnrekvId, lcreturn, v_pvkaart.kood , v_pvkaart.nimetus, v_pvkaart.konto , 
			v_pvkaart.grupp , v_pvkaart.soetkpv, v_pvkaart.vastisik, v_pvkaart.muud);

		select pv_oper.summa * ifnull(dokvaluuta1.kuurs, 1::numeric), pv_oper.kpv into lnSumma, ldAlgkpv 
			from pv_oper left outer join dokvaluuta1 on dokvaluuta1.dokid = pv_oper.id AND dokvaluuta1.dokliik = 13
			where pv_oper.parentid = v_pvkaart.id and pv_oper.liik = 5 order by pv_oper.kpv desc limit 1;
		if ifnull(lnSumma,0) = 0 then
			lnSoetmaks := v_pvkaart.soetmaks * v_pvkaart.kuurs;
			ldAlgkpv := v_pvkaart.soetkpv;
		else
			lnSoetmaks := lnSumma;
		end if;
		if tdKpv2 < ldAlgkpv then
			lnSoetmaks := v_pvkaart.soetmaks;
			ldAlgkpv := v_pvkaart.soetkpv;
		end if;

		-- kulum
		-- algkulum
		select sum(summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) into lnSumma 
			from pv_oper left outer join dokvaluuta1 on dokvaluuta1.dokid = pv_oper.id AND dokvaluuta1.dokliik = 13
			where pv_oper.liik = 2 and pv_oper.parentId = v_pvkaart.id and pv_oper.kpv > ldAlgkpv  and pv_oper.kpv < tdKpv1;

		lnAlgkulum = ifnull(lnSumma,0);
		if ldAlgkpv = v_pvkaart.soetkpv then
			-- puudu umberhindlus
			lnAlgkulum = lnAlgKulum + (v_pvkaart.algkulum*v_pvkaart.kuurs);
		end if;
		-- kulum
		select sum(summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) into lnSumma 
			from pv_oper left outer join dokvaluuta1 on dokvaluuta1.dokid = pv_oper.id AND dokvaluuta1.dokliik = 13
			where pv_oper.liik = 2 and pv_oper.parentId = v_pvkaart.id 
			and pv_oper.kpv > ldAlgkpv  and pv_oper.kpv >= tdKpv1 and pv_oper.kpv <= tdKpv2;
		lnKulum := ifnull(lnSumma,0);
/*
		-- Kulumi mahakandmine, kui pv oli mahakantud
		-- kas see pv_kaart oli mahakantud

		if (select count(id) from pv_oper where liik = 4 
			and parentId = v_pvkaart.id and kpv > ldAlgkpv  and kpv >= tdKpv1 and kpv <= tdKpv2) > 0 then
			-- kui see kart oli mahakantud, siis kgu kulum oli ka mahakantud

		end if;
*/

		-- parandus
		-- algparandus
		select sum(summa * ifnull(dokvaluuta1.kuurs, 1::numeric) ) into lnSumma 
			from pv_oper left outer join dokvaluuta1 on dokvaluuta1.dokid = pv_oper.id AND dokvaluuta1.dokliik = 13
			where pv_oper.liik = 3 and pv_oper.parentId = v_pvkaart.id and pv_oper.kpv > ldAlgkpv  and pv_oper.kpv < tdKpv1;
		lnSoetmaks := lnSoetmaks + ifnull(lnSumma,0);

		-- parandus
		select sum(summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) into lnSumma 
			from pv_oper left outer join dokvaluuta1 on dokvaluuta1.dokid = pv_oper.id AND dokvaluuta1.dokliik = 13
			where liik = 3 and parentId = v_pvkaart.id and kpv > ldAlgkpv  and kpv >= tdKpv1 and kpv <= tdKpv2;
		lnParandus := ifnull(lnSumma,0);

	
		-- maha
		select sum(summa * ifnull(dokvaluuta1.kuurs, 1::numeric)) into lnSumma 
			from pv_oper left outer join dokvaluuta1 on dokvaluuta1.dokid = pv_oper.id AND dokvaluuta1.dokliik = 13
			where pv_oper.liik = 4 and pv_oper.parentId = v_pvkaart.id and pv_oper.kpv > ldAlgkpv  and pv_oper.kpv >= tdKpv1 and pv_oper.kpv <= tdKpv2;
		lnMaha := ifnull(lnSumma,0);

		-- arvestame kulumi periods

		lnPeriods = 0;
		

		if lnMaha = 0 and v_pvKaart.kulum > 0 then
			lnKulumArv = sp_calc_kulum(v_pvkaart.id);
			if ifnull(lnKulumArv,0) > 0 and ifnull(lnJaak,0) > 0 then
				lnPeriods = lnJaak / lnKulumArv;
			end if;	
--			lnPeriods = ((lnSoetmaks+ lnParandus)-(lnAlgKulum + lnKulum))/((lnSoetmaks+ lnParandus)/v_pvKaart.kulum*12);
--			raise notice 'Periods: %',lnPeriods;
		end if;
		lnJaak = (lnSoetmaks+ lnParandus)-(lnAlgKulum + lnKulum);		
		if ltrim(rtrim(upper(v_pvkaart.kood))) = 'MAA1893' THEN
			
			raise notice 'v_pvkaart.kood %',v_pvkaart.kood ;
			raise notice 'lnSoetmaks %',lnSoetmaks ;
			raise notice 'lnParandus %',lnParandus;
			raise notice 'lnAlgKulum %',lnAlgKulum;
			raise notice 'lnKulum %',lnKulum;
			raise notice 'lnJaak %',lnJaak ;

		END IF;

		update tmp_pv_aruanne1 set soetmaks = lnSoetmaks, 
			algkulum = lnAlgKulum, 
			kulum = lnKulum, 
			kulukokku = lnAlgKulum + lnKulum,
			parandus = lnParandus,
			mahakantud = lnMaha,
			muud = ltrim(rtrim(muud))+', kulumi perioded:'+str(lnPeriods,3), 
			jaak = lnSoetmaks + lnParandus - lnAlgKulum -lnKulum
			where id = v_pvkaart.id and timestamp = LCRETURN;

		end if;

	end loop;



	return LCRETURN;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_pv_aruanne2(integer, date, date, character varying, character varying, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne2(integer, date, date, character varying, character varying, character varying) TO vlad;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne2(integer, date, date, character varying, character varying, character varying) TO public;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne2(integer, date, date, character varying, character varying, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne2(integer, date, date, character varying, character varying, character varying) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne2(integer, date, date, character varying, character varying, character varying) TO dbvaatleja;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne2(integer, date, date, character varying, character varying, character varying) TO taabel;
