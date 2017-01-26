-- Function: kk(character varying, integer, date, date)

-- DROP FUNCTION kk(character varying, integer, date, date);

/*

select kk('122',1,date(2010,05,01),date())
 
*/

CREATE OR REPLACE FUNCTION kk(character varying, integer, date, date)
  RETURNS numeric AS
$BODY$

DECLARE tcKontogrupp alias for $1;
	tnrekvid alias for $2;
	tdKpv1 alias for $3;
	tdKpv2 alias for $4;
	lnKr numeric (12,4);
begin	

	-- arv. kreedit kaibed
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnKr from journal1 left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where kreedit like ltrim(rtrim(tcKontogrupp))+'%'
		and parentid in (select id from journal where rekvId = tnRekvId and kpv >= tdKpv1 and kpv <= tdKpv2);

	return ifnull(lnKr,0);
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION kk(character varying, integer, date, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION kk(character varying, integer, date, date) TO vlad;
GRANT EXECUTE ON FUNCTION kk(character varying, integer, date, date) TO public;
GRANT EXECUTE ON FUNCTION kk(character varying, integer, date, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION kk(character varying, integer, date, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION kk(character varying, integer, date, date) TO dbadmin;
GRANT EXECUTE ON FUNCTION kk(character varying, integer, date, date) TO dbvaatleja;
