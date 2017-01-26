-- Function: sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying)

-- DROP FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying)
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
	lnSumma numeric(18,8);
	lnSoetmaks numeric(18,8);
	lnAlgKulum numeric(18,8);
	lnKulum numeric(18,8);
	lnParandus numeric(18,8);
	lnMaha numeric(18,8);
	v_pvkaart record;

	ldAlgkpv date;
	lMaha int;

begin

	

	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_PV_ARUANNE1';



	if ifnull(lnCount,0) < 1 then



	raise notice ' lisamine  ';

	

		create table tmp_pv_aruanne1 (id int, kood varchar(20), nimetus varchar(254), konto varchar(20), grupp varchar(254),
			soetkpv date, 
			soetmaks numeric(14,2), algkulum numeric(14,2), kulum numeric(14,2), kulukokku numeric(14,2),
			jaak numeric(14,2), parandus numeric(14,2), mahakantud numeric(14,2), 
			timestamp varchar(20), kpv date default date(), rekvid int, vastisik varchar(254), muud varchar(254))  ;

		

		GRANT ALL ON TABLE tmp_pv_aruanne1 TO GROUP public;



	else
		delete from tmp_pv_aruanne1 where kpv < date() and rekvid = tnrekvId;

	end if;


	lcreturn := to_char(now(), 'YYYYMMDDMISSSS');


	-- pv list 

	for v_pvkaart in 

	select curPohivara.id, curPohivara.kood, curPohivara.nimetus, curPohivara.konto, curPohivara.grupp, 
		curPohivara.soetkpv, curPohivara.soetmaks * curPohivara.kuurs as soetmaks, curpohivara.algkulum * curPohivara.kuurs as algkulum, 
		curpohivara.TUNNUS, curPohivara.vastisik, curPohivara.rentnik as muud
		from curPohivara 
		where rekvid = tnRekvId 
		and upper(curPohivara.konto) like upper(tcKonto)
		and upper(curPohivara.grupp) like upper(tcGrupp)
		and upper(curPohivara.vastisik) like upper(tcvastisik)
		and curpohivara.kulum > 0
		and (empty(curpohivara.mahakantud) or curPohivara.mahakantud > tdKpv2)
		order by curPohivara.grupp, curPohivara.kood, curPohivara.konto

	loop
		lMaha = 0;
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
			values (v_pvkaart.id, tnrekvId, lcreturn, v_pvkaart.kood , v_pvkaart.nimetus, v_pvkaart.konto , v_pvkaart.grupp , v_pvkaart.soetkpv, v_pvkaart.vastisik, v_pvkaart.muud);

		select summa * ifnull(dokvaluuta1.kuurs,1), kpv into lnSumma, ldAlgkpv 
			from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where parentid = v_pvkaart.id and liik = 5 order by kpv desc limit 1;
		if ifnull(lnSumma,0) = 0 then
			lnSoetmaks := v_pvkaart.soetmaks;
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
		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where liik = 2 and parentId = v_pvkaart.id and kpv > ldAlgkpv  and kpv < tdKpv1;

		lnAlgkulum = ifnull(lnSumma,0);
		if ldAlgkpv = v_pvkaart.soetkpv then
			-- puudu umberhindlus
			lnAlgkulum = lnAlgKulum + v_pvkaart.algkulum;
		end if;
		-- kulum
		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where liik = 2 and parentId = v_pvkaart.id 
			and kpv > ldAlgkpv  and kpv >= tdKpv1 and kpv <= tdKpv2;
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
		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where liik = 3 and parentId = v_pvkaart.id and kpv > ldAlgkpv  and kpv < tdKpv1;
		lnSoetmaks := lnSoetmaks + ifnull(lnSumma,0);
		-- parandus
		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where liik = 3 and parentId = v_pvkaart.id and kpv > ldAlgkpv  and kpv >= tdKpv1 and kpv <= tdKpv2;
		lnParandus := ifnull(lnSumma,0);

	
		-- maha
		select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnSumma from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where liik = 4 and parentId = v_pvkaart.id and kpv > ldAlgkpv  and kpv >= tdKpv1 and kpv <= tdKpv2;
		lnMaha := ifnull(lnSumma,0);


		

		update tmp_pv_aruanne1 set soetmaks = lnSoetmaks, 
			algkulum = lnAlgKulum, 
			kulum = lnKulum, 
			kulukokku = lnAlgKulum + lnKulum,
			parandus = lnParandus,
			mahakantud = lnMaha,
			jaak = lnSoetmaks + lnParandus - lnAlgKulum -lnKulum
			where id = v_pvkaart.id and timestamp = LCRETURN;

		end if;

	end loop;



	return LCRETURN;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying) TO vlad;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying) TO public;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying) TO dbvaatleja;
GRANT EXECUTE ON FUNCTION sp_pv_aruanne1(integer, date, date, character varying, character varying, character varying) TO taabel;
