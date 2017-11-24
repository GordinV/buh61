-- Function: sd(character varying, integer, date)

-- DROP FUNCTION sd(character varying, integer, date);

CREATE OR REPLACE FUNCTION sd(character varying, integer, date)
  RETURNS numeric AS
$BODY$
DECLARE tcKontogrupp alias for $1;
	tnrekvid alias for $2;
	tdKpv alias for $3;
	lnAlg numeric (16,6);
	lnDb numeric (16,6);
	lnKr numeric (16,6);
begin
	-- arv algsaldo
--	select sum(algsaldo) into lnAlg from library l inner join kontoinf k on l.id = k.parentId 
--		where k.rekvId = tnRekvId and l.kood = ltrim(rtrim(tcKontogrupp));

	-- arv. deebet kaibed
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnDb from journal1 left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where ltrim(rtrim(deebet)) = ltrim(rtrim(tcKontogrupp))
		and parentid in (select id from journal where rekvId = tnRekvId and kpv <= tdKpv);

	-- arv. kreedit kaibed
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnKr from journal1 left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and  dokvaluuta1.dokliik = 1)
		where ltrim(rtrim(kreedit)) = ltrim(rtrim(tcKontogrupp))
		and parentid in (select id from journal where rekvId = tnRekvId and kpv <= tdKpv);
	return ifnull(lnAlg,0) + ifnull(lnDb,0) - ifnull(lnKr,0);
end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sd(character varying, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sd(character varying, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION sd(character varying, integer, date) TO public;
GRANT EXECUTE ON FUNCTION sd(character varying, integer, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sd(character varying, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sd(character varying, integer, date) TO dbadmin;
GRANT EXECUTE ON FUNCTION sd(character varying, integer, date) TO dbvaatleja;
GRANT EXECUTE ON FUNCTION sd(character varying, integer, date) TO taabel;
GRANT EXECUTE ON FUNCTION sd(character varying, integer, date) TO dbvanemtasu;
