-- Function: sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date)

-- DROP FUNCTION sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date);

CREATE OR REPLACE FUNCTION sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date)
  RETURNS character varying AS
$BODY$DECLARE tnrekvid alias for $1;
	tcTunnus alias for $2;
	tcgrupp alias for $3;
	tdKpv1 alias for $4;
	tdKpv2 alias for $5;
	lcReturn varchar;
	lcString varchar;
	LNcOUNT int;
begin



	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'TMP_VANEMTASU4';

	if ifnull(lnCount,0) < 1 then

	raise notice ' lisamine  ';
	
		create table tmp_vanemtasu4 (tunnus varchar(20), grupp varchar(40),
			nimetus varchar(254) default space(254), kood varchar(20) default space(20) , 
			hind numeric (14,2) default 0, kogus numeric (14,4) default 0, 
			deebet numeric (14,2) default 0, kreedit numeric (14,2) default 0 ,  
			tasud numeric (14,2) default 0, korkonto varchar(20) default space(20),
			konto varchar(20) default space(20), kood1 varchar(20) default space(20), kood2 varchar(20) default space(20),
			kood3 varchar(20) default space(20), kood4 varchar(20) default space(20), kood5 varchar(20) default space(20),
			timestamp varchar(20), kpv date default date(), rekvid int)  ;
		
		GRANT ALL ON TABLE tmp_vanemtasu4 TO GROUP public;

	else
		delete from tmp_vanemtasu4 where kpv < date() and rekvid = tnrekvId;

	end if;

	lcreturn := ltrim(rtrim(str(tnRekvid)))+to_char(now(), 'YYYYMMDDMISSSS');

	-- arved list

	raise notice ' Asutuste nimekirje ja gruppid iga toodele   ';

	insert into tmp_vanemtasu4 (tunnus, grupp, nimetus, kogus, deebet, kreedit, timestamp, rekvid)

select tunnus, grupp, nimetus, sum(kogus) as kogus,sum(deebet), sum(kreedit), lcreturn, tnrekvid
from ( 
	select  vanemtasu2.tunnus, vanemtasu2.grupp,
		case when vanemtasu3.opt = 1 then 'tasu' else nomenklatuur.nimetus end, 
		 vanemtasu4.kogus, 
		case when vanemtasu3.opt = 1 then (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) else 0:: numeric(12,4) end as deebet, 
		case when vanemtasu3.opt = 2 then (vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1)) else 0:: numeric(12,4) end as kreedit
		
	from vanemtasu1 inner join vanemtasu2 on vanemtasu1.id = vanemtasu2.isikid 
		inner join vanemtasu4 on vanemtasu4.isikId = vanemtasu1.id
		inner join vanemtasu3 on (vanemtasu3.Id = vanemtasu4.parentid and vanemtasu3.tunnus = vanemtasu2.tunnus)
		left outer join nomenklatuur on (vanemtasu4.nomId = nomenklatuur.id and nomenklatuur.rekvid = tnrekvid)
		left outer join journalid on vanemtasu3.journalid = journalid.journalid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)
	where upper(vanemtasu2.tunnus) like upper(tcTunnus) 
		and upper(vanemtasu2.grupp) like upper(tcGrupp) 
		and vanemtasu3.kpv >= tdKpv1
		and vanemtasu3.kpv <= tdKpv2
		and vanemtasu3.rekvid = tnrekvid
) vkaibed group by tunnus, grupp, nimetus;



	return LCRETURN;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date) TO public;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_vanemtasu_aruanne4(integer, character varying, character varying, date, date) TO dbpeakasutaja;
