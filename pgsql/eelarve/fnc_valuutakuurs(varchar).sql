-- Function: fnc_currentkuurs(date)

-- DROP FUNCTION fnc_currentkuurs(date);

CREATE OR REPLACE FUNCTION fnc_valuutakuurs(varchar)
  RETURNS numeric AS
$BODY$

DECLARE 
	tcValuuta alias for $1;
	lnKuurs numeric(14,4);
	lnPohiKuurs numeric(14,4);
	inId int;
begin
	-- pohi tingimused

	select valuuta1.kuurs into lnPohiKuurs 
		from library inner join valuuta1 on library.id = valuuta1.parentid
		where library.kood = tcValuuta;

	lnKuurs = ifnull(lnPohiKuurs,lnKuurs);
	
	return lnKuurs;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_valuutakuurs(varchar) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_valuutakuurs(varchar) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_valuutakuurs(varchar) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_valuutakuurs(varchar) TO dbvaatleja;
