/*

select fnc_currentvaluuta(date(1900,01,01))


*/

CREATE OR REPLACE FUNCTION fnc_currentvaluuta(date)
  RETURNS character varying AS
$BODY$

DECLARE 
	tdKpv alias for $1;
	lcValuuta varchar(20);
	lcPohiValuuta varchar(20);
begin
	-- pohi tingimused
	
	if year(tdKpv) < 2011 then
		lcValuuta = 'EEK';
	else
		lcValuuta = 'EUR';
	end if;
	-- otsime pohivaluuta
	select kood into lcPohiValuuta from library where library = 'VALUUTA' and tun1 = 1 
		and (tun4 <= dateasint(tdKpv) or empty(tun4)) 
		and (tun5 >= dateasint(tdKpv) or empty(tun5));

	lcValuuta = ifnull(lcPohiValuuta,lcValuuta);
	
	return lcValuuta;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_currentvaluuta(date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_currentvaluuta(date) TO public;
GRANT EXECUTE ON FUNCTION fnc_currentvaluuta(date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_currentvaluuta(date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_currentvaluuta(date) TO dbvaatleja;
