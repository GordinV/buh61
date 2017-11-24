-- Function: tsd(character varying, integer, integer, date)

-- DROP FUNCTION tsd(character varying, integer, integer, date);

CREATE OR REPLACE FUNCTION tsd(character varying, integer, integer, date)
  RETURNS numeric AS
$BODY$DECLARE tcKontogrupp alias for $1;
	tnTunnusid alias for $2;
	tnrekvid alias for $3;
	tdKpv alias for $4;
	lnAlg numeric (12,4);
	lnDb numeric (14,4);
	lnKr numeric (14,4);
	lcTunnus varchar;
begin
	select kood into lcTunnus from library where id = tnTunnusId;

	lnDb :=0;
	lnKr :=0;
	-- arv algsaldo
	/*
	select sum(algsaldo) into lnAlg from library l inner join tunnusinf k on l.id = k.kontoId 
		where k.rekvId = tnRekvId and l.kood like ltrim(rtrim(tcKontogrupp)) and k.tunnusid = tnTunnusId;
*/
	-- arv. deebet kaibed


	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnDb from journal1 left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where deebet like ltrim(rtrim(tcKontogrupp))::varchar+'%'
		and parentid in (select id from journal where rekvId = tnRekvId and kpv <= tdKpv)
		and ltrim(rtrim(tunnus)) = ltrim(rtrim(lcTunnus));


	-- arv. kreedit kaibed
	select sum(summa * ifnull(dokvaluuta1.kuurs,1) ) into lnKr from journal1  left outer join dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 1)
		where kreedit like ltrim(rtrim(tcKontogrupp))+'%'
		and parentid in (select id from journal where rekvId = tnRekvId and kpv <= tdKpv)
		and ltrim(rtrim(tunnus)) = ltrim(rtrim(lcTunnus));

	return ifnull(lnAlg,0) + ifnull(lnDb,0) - ifnull(lnKr,0);
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION tsd(character varying, integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION tsd(character varying, integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION tsd(character varying, integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION tsd(character varying, integer, integer, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION tsd(character varying, integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION tsd(character varying, integer, integer, date) TO dbadmin;
GRANT EXECUTE ON FUNCTION tsd(character varying, integer, integer, date) TO dbvaatleja;
