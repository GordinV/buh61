/*
select sum(jaak*ifnull(dokvaluuta1.kuurs,1)) 
from arv left outer join  dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 3)  
where ARV.REKVID = 6 
and asutusid = 20535
and ifnull(arv.tasud,DATE()) <= DATE() 


select * from asutus where nimetus like 'SV Eurokvaliteet%'
*/


CREATE OR REPLACE FUNCTION fnc_arv_volg(integer,date, integer)
  RETURNS numeric AS
$BODY$


declare 
	tnrekvId ALIAS FOR $1;
	tdKpv	ALIAS FOR $2;
	tnAsutusId	ALIAS FOR $3;
	lnJaak numeric;
BEGIN

select sum(jaak*ifnull(dokvaluuta1.kuurs,1)) into lnJaak 
	from arv left outer join  dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 3)  
	where arv.rekvid = tnRekvId and arv.asutusId = tnAsutusId and ifnull(arv.tasud,tdKpv) <= tdKpv;


RETURN lnJaak;


end;




$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_avansijaak(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO public;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO vlad;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_avansijaak(integer) TO dbpeakasutaja;
