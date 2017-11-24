-- Function: dk(character varying, integer, date, date)
/*
select dk('113',1,date(2010,05,01),date())

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) from journal1 left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where deebet like ltrim(rtrim('113'))+'%'
		and parentid in (select id from journal where rekvId = 1 and kpv >= date(2010,05,01) and kpv <= date());


select rekvId, konto, sum(deebet) as deebet, sum(kreedit) as kreedit from 
curSaldo where kpv >= ?tdKpv1 and kpv <=  ?tdKpv2 and konto like ?tcKonto and asutusid >= ?tnAsutusId1 and asutusId <= ?tnAsutusId2 and rekvId = ?gRekv group by rekvid, konto


*/

-- DROP FUNCTION dk(character varying, integer, date, date);

CREATE OR REPLACE FUNCTION dk(character varying, integer, date, date)
  RETURNS numeric AS
$BODY$

DECLARE tcKontogrupp alias for $1;
	tnrekvid alias for $2;
	tdKpv1 alias for $3;
	tdKpv2 alias for $4;
	lnDb numeric (12,4);
begin	

	-- arv. deebet kaibed
	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnDb from journal1 left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where deebet like ltrim(rtrim(tcKontogrupp))+'%'
		and parentid in (select id from journal where rekvId = tnRekvId and kpv >= tdKpv1 and kpv <= tdKpv2);

/*
	-- arv. kreedit kaibed
	select sum(summa) into lnKr from journal1 
		where kreedit like ltrim(rtrim(tcKontogrupp))+'%'
		and parentid in (select id from journal where rekvId = tnRekvId and kpv >= tdKpv1 and kpv <= tdKpv2);
*/

	return ifnull(lnDb,0);
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION dk(character varying, integer, date, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION dk(character varying, integer, date, date) TO vlad;
GRANT EXECUTE ON FUNCTION dk(character varying, integer, date, date) TO public;
GRANT EXECUTE ON FUNCTION dk(character varying, integer, date, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION dk(character varying, integer, date, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION dk(character varying, integer, date, date) TO dbadmin;
GRANT EXECUTE ON FUNCTION dk(character varying, integer, date, date) TO dbvaatleja;
