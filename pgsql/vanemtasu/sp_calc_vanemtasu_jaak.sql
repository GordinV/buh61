﻿-- Function: sp_calc_vanemtasu_jaak(integer, integer)

select sp_calc_vanemtasu_jaak(9, vanemtasu1.id) from vanemtasu1

-- DROP FUNCTION sp_calc_vanemtasu_jaak(integer, integer);

CREATE OR REPLACE FUNCTION sp_calc_vanemtasu_jaak(integer, integer)
  RETURNS numeric AS
$BODY$
DECLARE tnRekvid alias for $1;
	qryLapsed1 record;
begin	
		left outer join dokvaluuta1 on (vanemtasu4.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 16)		
	loop
		UPDATE vanemtasu2 SET jaak = (qryLapsed1.fakt - qryLapsed1.kassa) / fnc_currentkuurs(date()) 
	END loop;
	if lnCount = 0 then
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_vanemtasu_jaak(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_vanemtasu_jaak(integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_vanemtasu_jaak(integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_vanemtasu_jaak(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_vanemtasu_jaak(integer, integer) TO dbpeakasutaja;