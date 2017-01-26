-- Function: fnc_arv_volg(integer, date, integer)

-- DROP FUNCTION fnc_arv_volg(integer, date, integer);

/*
select * from arv where number = '466r12'
select fncArvJaakSeisuga(179953,date(2012,06,30))
*/

CREATE OR REPLACE FUNCTION fncArvJaakSeisuga(integer, date)
  RETURNS numeric AS
$BODY$


declare 
	tnArvId ALIAS FOR $1;
	tdKpv ALIAS FOR $2;
	lnJaak numeric;
	lnArvSumma numeric;
	lnTasuSumma numeric;

BEGIN

	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnArvSumma 
		from arv left outer join  dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 3)  
		where arv.id = tnArvId;

	select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
		from arvtasu left outer join dokvaluuta1 on (arvtasu.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 21)
		where arvid = tnArvId and kpv < tdKpv;

	lnJaak = ifnull(lnArvSumma,0) - ifnull(lnTasuSumma ,0);
		


RETURN lnJaak;


end;




$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fncArvJaakSeisuga(integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fncArvJaakSeisuga(integer, date) TO dbvaatleja;
GRANT EXECUTE ON FUNCTION fncArvJaakSeisuga(integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncArvJaakSeisuga(integer, date) TO dbpeakasutaja;

