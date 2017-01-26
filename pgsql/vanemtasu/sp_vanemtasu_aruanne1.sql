-- Function: sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character)
/*
select sp_vanemtasu_aruanne1(1, '%', date(2011,02,01), date(2011,02,28), '%', '%')

delete from TMP_VANEMTASU1

select * from TMP_VANEMTASU1

SELECT * FROM  tmp_vanemtasu1  where timestamp = '201102095679017' Order By  TUNNUS, GRUPP, nimi, ISIKKOOD
*/


-- DROP FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character);

CREATE OR REPLACE FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character)
  RETURNS character varying AS
$BODY$
DECLARE tnrekvid alias for $1;
	tcTunnus alias for $2;
	tdKpv1 alias for $3;
	tdKpv2 alias for $4;
	tcgrupp alias for $5;
	tcKonto alias for $6;
	lcReturn varchar;
	lcString varchar;
	lcPnimi varchar;
	lnAlg numeric(14,2);
	lnLopp numeric (14,2);
	LNcOUNT int;
	v_isikud record;
begin



	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_VANEMTASU1';
	if ifnull(lnCount,0) < 1 then
	
		create table tmp_vanemtasu1 (isikid int, isikkood varchar(20), nimi varchar(254), tunnus varchar(20), grupp varchar(40),
			nimetus varchar(254), kood varchar(20), kpv1 date, kpv2 date, algsaldo numeric (14,2) default 0, arv numeric (14,2) default 0, 
			tasu numeric (14,2) default 0, jaak numeric (14,2) default 0, timestamp varchar(20), kpv date default date(), rekvid int)  ;
		
		GRANT ALL ON TABLE tmp_vanemtasu1 TO GROUP public;

	else
		delete from tmp_vanemtasu1 where kpv < date() and rekvid = tnrekvId;

	end if;

	lcreturn := to_char(now(), 'YYYYMMDDMISSSS');

	-- laste list

	insert into tmp_vanemtasu1 (isikid, isikkood, nimi , tunnus , grupp, kpv1 , kpv2, timestamp, rekvid  )
	select vanemtasu1.id, vanemtasu1.isikkood, vanemtasu1.nimi, vanemtasu2.tunnus, vanemtasu2.grupp, tdKpv1, 
	tdKpv2, lcreturn, tnrekvid from vanemtasu1 inner join vanemtasu2 on vanemtasu1.id = vanemtasu2.isikid 
	where vanemtasu2.rekvid = tnrekvid and upper(vanemtasu2.tunnus) like upper(tcTunnus) and loppkpv >= tdKpv1 and upper(vanemtasu2.grupp) like upper(tcGrupp);


	-- algsaldo

	for v_isikud  in 

		SELECT   sum( CASE WHEN vanemtasu3.opt = 1 THEN (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) ELSE 0::numeric END) AS kassa, 
		 sum( CASE WHEN vanemtasu3.opt = 2 THEN (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) ELSE 0::numeric END) AS fakt, 
		vanemtasu3.tunnus, vanemtasu4.isikId
		FROM vanemtasu3 INNER JOIN vanemtasu4 ON vanemtasu3.id = vanemtasu4.parentid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
		WHERE vanemtasu3.rekvId = tnrekvId
		and upper(vanemtasu3.tunnus) like upper(tcTunnus)
		and vanemtasu4.konto like tcKonto
		and vanemtasu3.kpv < tdKpv1
		and vanemtasu4.isikid in (select distinct isikId from vanemtasu2 where rekvid = tnRekvId and upper(grupp) like upper(tcGrupp))
		GROUP BY vanemtasu3.tunnus, vanemtasu4.isikId

	loop

		UPDATE tmp_vanemtasu1 SET algsaldo = v_isikud.fakt - v_isikud.kassa 
			WHERE isikId = v_isikud.isikId AND tunnus = v_isikud.tunnus;


	END loop;

	-- arv

	for v_isikud  in 

		SELECT   sum( vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1) ) AS fakt, 
		vanemtasu3.tunnus, vanemtasu4.isikId
		FROM vanemtasu3 INNER JOIN vanemtasu4 ON vanemtasu3.id = vanemtasu4.parentid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
		WHERE vanemtasu3.rekvId = tnrekvId
		and upper(vanemtasu3.tunnus) like upper(tcTunnus)
		and vanemtasu3.kpv >= tdKpv1
		and vanemtasu3.kpv <= tdKpv2
		and vanemtasu4.konto like tcKonto
		and vanemtasu3.opt = 2
		and vanemtasu4.isikId in (select distinct isikId from vanemtasu2 where rekvid = tnRekvId and upper(grupp) like upper(tcGrupp))
		GROUP BY vanemtasu3.tunnus, vanemtasu4.isikId

	loop

		UPDATE tmp_vanemtasu1 SET arv = v_isikud.fakt  
			WHERE isikId = v_isikud.isikId AND tunnus = v_isikud.tunnus;


	END loop;

	-- tasu

	for v_isikud  in 

		SELECT   sum( vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) AS kassa, 
		vanemtasu3.tunnus, vanemtasu4.isikId
		FROM vanemtasu3 INNER JOIN vanemtasu4 ON vanemtasu3.id = vanemtasu4.parentid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
		WHERE vanemtasu3.rekvId = tnrekvId
		and upper(vanemtasu3.tunnus) like upper(tcTunnus)
		and vanemtasu3.kpv >= tdKpv1
		and vanemtasu3.kpv <= tdKpv2
		and vanemtasu4.konto like tcKonto
		and vanemtasu4.isikId in (select distinct isikId from vanemtasu2 where rekvid = tnRekvId and upper(grupp) like upper(tcGrupp))
		and vanemtasu3.opt = 1
		
		GROUP BY vanemtasu3.tunnus, vanemtasu4.isikId

	loop

		UPDATE tmp_vanemtasu1 SET tasu = v_isikud.kassa  
			WHERE isikId = v_isikud.isikId AND tunnus = v_isikud.tunnus;


	END loop;

	delete from tmp_vanemtasu1 where algsaldo = 0 and arv = 0 and tasu = 0 and timestamp = LCRETURN;

	return LCRETURN;
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character) TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character) TO public;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne1(integer, character varying, date, date, character, character) TO dbpeakasutaja;
