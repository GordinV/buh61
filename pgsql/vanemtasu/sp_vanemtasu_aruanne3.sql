-- Function: sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying)

-- DROP FUNCTION sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying)
  RETURNS character varying AS
$BODY$DECLARE tnrekvid alias for $1;
	tcTunnus alias for $2;
	tcIsikkood alias for $3;
	tcIsiknimi alias for $4;
	tcVanemkood alias for $5;
	tcVanemnimi alias for $6;
	tdKpv1 alias for $7;
	tdKpv2 alias for $8;
	tnOpt alias for $9;
	tcGrupp alias for $10;
	tcKonto alias for $11;
	lcReturn varchar;
	lcString varchar;
	LNcOUNT int;
begin



	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_VANEMTASU3';

	if ifnull(lnCount,0) < 1 then

	raise notice ' lisamine  ';
	
		create table tmp_vanemtasu3 (number varchar(20), dokkpv date, isikid int, isikkood varchar(20), nimi varchar(254), vanemkood varchar(20), vanemnimi varchar(254),
			aadress text, tunnus varchar(20), grupp varchar(40),
			nimetus varchar(254) default space(254), kood varchar(20) default space(20) , hind numeric (14,2) default 0, kogus numeric (14,4) default 0, 
			deebet numeric (14,2) default 0, kreedit numeric (14,2) default 0 , lausend int default 0,
			opt int default 1, algjaak numeric (14,2) default 0, tasud numeric (14,2) default 0, korkonto varchar(20) default space(20),
			konto varchar(20) default space(20), kood1 varchar(20) default space(20), kood2 varchar(20) default space(20),
			kood3 varchar(20) default space(20), kood4 varchar(20) default space(20), kood5 varchar(20) default space(20),
			timestamp varchar(20), kpv date default date(), rekvid int)  ;
		
		GRANT ALL ON TABLE tmp_vanemtasu3 TO GROUP public;

	else
		delete from tmp_vanemtasu3 where kpv < date() and rekvid = tnrekvId;

	end if;

	lcreturn := ltrim(rtrim(str(tnRekvid)))+to_char(now(), 'YYYYMMDDMISSSS');

	-- arved list

	raise notice ' list  ';

	insert into tmp_vanemtasu3 (number, dokkpv, isikid, isikkood, nimi, vanemkood, vanemnimi,
			aadress, tunnus, grupp,	nimetus, hind, kogus, deebet, kreedit, opt, timestamp, rekvid, 
			korkonto, konto, kood1, kood2, kood3, kood4, kood5, lausend )

	select vanemtasu4.number, vanemtasu3.kpv, vanemtasu1.id, vanemtasu1.isikkood, vanemtasu1.nimi, 
		vanemtasu4.maksjakood, vanemtasu4.maksjanimi,
		vanemtasu1.aadress, vanemtasu2.tunnus, vanemtasu2.grupp,
		case when vanemtasu3.opt = 1 then 'tasu' else nomenklatuur.nimetus end, 
		vanemtasu4.hind, vanemtasu4.kogus, 
		case when vanemtasu3.opt = 1 then (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) else 0:: numeric(12,4) end, 
		case when vanemtasu3.opt = 2 then (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) else 0:: numeric(12,4) end, 
		tnOpt, 	 lcreturn, tnrekvid ,
		vanemtasu3.konto, vanemtasu4.konto, vanemtasu4.kood1, vanemtasu4.kood2, vanemtasu4.kood3, vanemtasu4.kood4, 
		vanemtasu4.kood5, ifnull(journalid.number,0) 
	from vanemtasu1 inner join vanemtasu2 on vanemtasu1.id = vanemtasu2.isikid 
		inner join vanemtasu4 on vanemtasu4.isikId = vanemtasu1.id
		inner join vanemtasu3 on (vanemtasu3.Id = vanemtasu4.parentid and vanemtasu3.tunnus = vanemtasu2.tunnus)
		left outer join nomenklatuur on (vanemtasu4.nomId = nomenklatuur.id and nomenklatuur.rekvid = tnRekvId)
		left outer join journalid on vanemtasu3.journalid = journalid.journalid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
	where upper(vanemtasu2.tunnus) like upper(tcTunnus) 
		and vanemtasu3.kpv >= tdKpv1
		and vanemtasu3.kpv <= tdKpv2
		and vanemtasu4.konto like tcKonto
		and upper(vanemtasu1.isikkood) like upper(tcisikkood)
		and upper(vanemtasu1.nimi) like upper(tcisiknimi)
		and upper(vanemtasu4.maksjakood) like upper(tcVanemkood)
		and upper(vanemtasu4.maksjanimi) like upper(tcVanemnimi)
		and upper(vanemtasu2.grupp) like upper(tcGrupp)
		and vanemtasu3.rekvid = tnrekvid;



	raise notice ' list ready ';


	raise notice ' lopp';

	return LCRETURN;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying) TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying) TO public;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne3(integer, character varying, character varying, character varying, character varying, character varying, date, date, integer, character varying, character varying) TO dbpeakasutaja;
