-- Function: fnc_arv_volg(integer, date, integer)

-- DROP FUNCTION fnc_arv_volg(integer, date, integer);

/*
select * from arv where number = '466r12'
select fncArvViimaneSaldo(179953)

*/
CREATE OR REPLACE FUNCTION fncArvViimaneSaldo(integer)
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

	select summa * ifnull(dokvaluuta1.kuurs,1) into lnTasuSumma 
		from arvtasu left outer join dokvaluuta1 on (arvtasu.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 21)
		where arvid = tnArvId order by kpv desc limit 1;

	lnJaak = ifnull(lnTasuSumma ,0);
	if lnJaak = 0 then
		lnJaak = lnArvSumma;
	end if;	


RETURN lnJaak;


end;




$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fncArvViimaneSaldo(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fncArvViimaneSaldo(integer) TO dbvaatleja;
GRANT EXECUTE ON FUNCTION fncArvViimaneSaldo(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncArvViimaneSaldo(integer) TO dbpeakasutaja;

