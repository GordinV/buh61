-- Function: sp_calc_vanemtasu_jaak(integer, integer)

select sp_calc_vanemtasu_jaak(9, vanemtasu1.id) from vanemtasu1

-- DROP FUNCTION sp_calc_vanemtasu_jaak(integer, integer);

CREATE OR REPLACE FUNCTION sp_calc_vanemtasu_jaak(integer, integer)
  RETURNS numeric AS
$BODY$
DECLARE tnRekvid alias for $1;	tnisikid alias for $2;
	qryLapsed1 record;	lnCount int;
begin		lnCount := 0;	for qryLapsed1  in 		SELECT   sum( CASE WHEN vanemtasu3.opt = 1 THEN vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1) ELSE 0::numeric END) AS kassa, 		 sum( CASE WHEN vanemtasu3.opt = 2 THEN vanemtasu4.summa * ifnull(dokvaluuta1.kuurs,1) ELSE 0::numeric END) AS fakt, 		vanemtasu3.tunnus, vanemtasu4.isikId		FROM vanemtasu3 INNER JOIN vanemtasu4 ON vanemtasu3.id = vanemtasu4.parentid
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)				WHERE vanemtasu3.rekvId = tnrekvId		and vanemtasu4.isikid = tnIsikid			GROUP BY vanemtasu3.tunnus, vanemtasu4.isikId
	loop
		UPDATE vanemtasu2 SET jaak = (qryLapsed1.fakt - qryLapsed1.kassa) / fnc_currentkuurs(date()) 			WHERE isikId = qrylapsed1.isikId AND tunnus = qryLapsed1.tunnus and rekvid = tnrekvId;		lnCount := lnCount +1;
	END loop;
	if lnCount = 0 then		-- tühi		UPDATE vanemtasu2 SET jaak = 0 WHERE isikId = tnIsikId and rekvid = tnrekvId;	end if;	return 1;end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_vanemtasu_jaak(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_vanemtasu_jaak(integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_vanemtasu_jaak(integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_vanemtasu_jaak(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_vanemtasu_jaak(integer, integer) TO dbpeakasutaja;
