-- Function: sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying)

-- DROP FUNCTION sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying);

/*


		SELECT   sum( CASE WHEN vanemtasu3.opt = 1 THEN (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) ELSE 0::numeric END) AS kassa, 
		 sum( CASE WHEN vanemtasu3.opt = 2 THEN (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) ELSE 0::numeric END) AS fakt 	
		FROM vanemtasu3 INNER JOIN vanemtasu4 ON vanemtasu3.id = vanemtasu4.parentid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16) 
		WHERE  vanemtasu3.kpv < date(2011,01,01)
		and vanemtasu4.isikId = 149;


select * from vanemtasu1 where nimi like'Albert Jakonen%'

		SELECT   dokvaluuta1.kuurs,vanemtasu4.*, (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) as summa 
		FROM vanemtasu3 INNER JOIN vanemtasu4 ON vanemtasu3.id = vanemtasu4.parentid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
		WHERE  upper(vanemtasu3.tunnus) = 'LA'
		and vanemtasu4.isikId = 149
		and vanemtasu3.kpv >= date(2011,01,01) and vanemtasu3.kpv <=date(2011,01,31)
		and vanemtasu3.opt = 1;

select  date(2011,01,31)-30

select * from dokvaluuta1 where kuurs = 15.65

update dokvaluuta1 set kuurs =15.6466 where kuurs = 15.65

*/

CREATE OR REPLACE FUNCTION sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying)
  RETURNS character varying AS
$BODY$DECLARE tnrekvid alias for $1;

	tcTunnus alias for $2;

	tcIsikkood alias for $3;

	tcIsiknimi alias for $4;

	tdKpv1 alias for $5;

	tdKpv2 alias for $6;

	tcGrupp alias for $7;

	lcReturn varchar;

	lcString varchar;

	lcPnimi varchar;

	lnAlg numeric(14,2);

	lnLopp numeric (14,2);

	LNcOUNT int;

	v_isikud record;

	v_arved record;

	v_vanemsaldo record;

	v_tasud record;
	
	ldPrevKpv date;

begin

--	ldPrevKpv = date(year(tdKpv1),month(tdKpv1),1)-1;
--	ldPrevKpv = date(year(ldPrevKpv),month(ldPrevKpv),1);

	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_VANEMTASU2';
	if ifnull(lnCount,0) < 1 then
	raise notice ' lisamine  ';

		create table tmp_vanemtasu2 (number varchar(20), dokkpv date, isikid int, isikkood varchar(20), nimi varchar(254), vanemkood varchar(20), vanemnimi varchar(254),
			aadress text, tunnus varchar(20), grupp varchar(40),
			nimetus varchar(254), kood varchar(20), hind numeric (14,2) default 0, kogus numeric (14,4) default 0, 
			summa numeric (14,2) default 0, 
			opt int default 1, algjaak numeric (14,2), tasud numeric (14,2) default 0,
			timestamp varchar(20), kpv date default date(), rekvid int)  ;

		GRANT ALL ON TABLE tmp_vanemtasu2 TO GROUP public;
	else
		delete from tmp_vanemtasu2 where kpv < date() and rekvid = tnrekvId;
	end if;
	lcreturn := to_char(now(), 'YYYYMMDDMISSSS');

	-- arved list


	raise notice ' list  ';

	insert into tmp_vanemtasu2 (number, dokkpv, isikid, isikkood, nimi, vanemkood, vanemnimi,
			aadress, tunnus, grupp,	nimetus, kood, hind, kogus, summa, opt, timestamp, rekvid  )
	select vanemtasu4.number, vanemtasu3.kpv, vanemtasu1.id, vanemtasu1.isikkood, vanemtasu1.nimi, 
		vanemtasu1.vanemkood, vanemtasu1.vanemnimi,
		vanemtasu1.aadress, vanemtasu2.tunnus, vanemtasu2.grupp, 
		nomenklatuur.nimetus, nomenklatuur.kood, (vanemtasu4.hind*ifnull(dokvaluuta1.kuurs,1))::numeric, vanemtasu4.kogus, 
		(vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1))::numeric, 1,
		 lcreturn, tnrekvid 
	from vanemtasu1 inner join vanemtasu2 on vanemtasu1.id = vanemtasu2.isikid 
		inner join vanemtasu4 on vanemtasu4.isikId = vanemtasu1.id
		inner join vanemtasu3 on (vanemtasu3.Id = vanemtasu4.parentid and vanemtasu3.tunnus = vanemtasu2.tunnus)
		inner join nomenklatuur on vanemtasu4.nomId = nomenklatuur.id
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
	where upper(vanemtasu2.tunnus) like upper(tcTunnus) 
		and vanemtasu3.kpv >= tdKpv1
		and vanemtasu3.kpv <= tdKpv2
		and upper(vanemtasu1.isikkood) like upper(tcisikkood)
		and upper(vanemtasu1.nimi) like upper(tcisiknimi)
		and vanemtasu2.rekvid = tnrekvid
		and upper(vanemtasu2.grupp) like upper(tcgrupp)
		and vanemtasu3.opt = 2;

	raise notice ' list ready ';

	-- algsaldo
	for v_arved in 
		select distinct dokkpv, isikId, number, tunnus from tmp_vanemtasu2 where timestamp = lcreturn
	loop
		SELECT   sum( CASE WHEN vanemtasu3.opt = 1 THEN (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) ELSE 0::numeric END) AS kassa, 
		 sum( CASE WHEN vanemtasu3.opt = 2 THEN (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) ELSE 0::numeric END) AS fakt 
		into v_vanemsaldo
		FROM vanemtasu3 INNER JOIN vanemtasu4 ON vanemtasu3.id = vanemtasu4.parentid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16) 
		WHERE vanemtasu3.rekvId = tnrekvId
		and vanemtasu3.tunnus = v_arved.tunnus
		and vanemtasu3.kpv < v_arved.dokkpv
		and vanemtasu4.isikId = v_arved.isikId;


	raise notice ' jaak fakt%',v_vanemsaldo.fakt ;
	raise notice ' jaak kassa%',v_vanemsaldo.kassa ;

	v_vanemsaldo.fakt:= ifnull(v_vanemsaldo.fakt,0);
	v_vanemsaldo.kassa:= ifnull(v_vanemsaldo.kassa,0) ;

		update tmp_vanemtasu2 set algjaak = v_vanemsaldo.fakt - v_vanemsaldo.kassa 
			where number = v_arved.number 
			and isikId = v_arved.isikId
			and tunnus = v_arved.tunnus
			and timestamp = lcreturn;

	--	tasu

		SELECT   sum(vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) as summa into v_tasud
		FROM vanemtasu3 INNER JOIN vanemtasu4 ON vanemtasu3.id = vanemtasu4.parentid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
		WHERE vanemtasu3.rekvId = tnrekvId
		and vanemtasu3.tunnus = v_arved.tunnus
		and vanemtasu4.isikId = v_arved.isikid
		and vanemtasu3.kpv >= tdKpv1 and vanemtasu3.kpv <= tdKpv2
		and vanemtasu3.opt = 1;

		UPDATE tmp_vanemtasu2 SET tasud = ifnull(v_tasud.summa ,0) 
			WHERE isikId = v_arved.isikId 
			AND tunnus = v_arved.tunnus 
			and number = v_arved.number 
			and dokkpv = v_arved.dokkpv
			and timestamp = lcreturn;


	end loop;
	raise notice ' lopp';
	return LCRETURN;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying) TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying) TO public;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne2(integer, character varying, character varying, character varying, date, date, character varying) TO dbpeakasutaja;
