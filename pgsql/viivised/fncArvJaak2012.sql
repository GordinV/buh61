-- Function: fnc_arv_volg(integer, date, integer)

-- DROP FUNCTION fnc_arv_volg(integer, date, integer);

/*
select fncArvJaak2012(162716)
*/

CREATE OR REPLACE FUNCTION fncArvJaak2012(integer)
  RETURNS numeric AS
$BODY$


declare 
	tnArvId ALIAS FOR $1;
	lnJaak numeric;
	lnArvSumma numeric;
	lnTasuSumma numeric;

BEGIN

	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnArvSumma 
		from arv left outer join  dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 3)  
		where arv.id = tnArvId;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
		from arvtasu left outer join dokvaluuta1 on (arvtasu.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 21)
		where arvid = tnArvId and kpv < date(2012,01,01);

	lnJaak = ifnull(lnArvSumma,0) - ifnull(lnTasuSumma ,0);
		


RETURN lnJaak;


end;




$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fncArvJaak2012(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fncArvJaak2012(integer) TO vlad;
GRANT EXECUTE ON FUNCTION fncArvJaak2012(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncArvJaak2012(integer) TO dbpeakasutaja;

