-- Function: fnc_aasta_kontrol(integer, date)

-- DROP FUNCTION fnc_aasta_kontrol(integer, date);

CREATE OR REPLACE FUNCTION fnc_aasta_kontrol(integer, date)
  RETURNS integer AS
$BODY$

declare 

	tnRekvid alias for $1;

	tdKpv alias for $2;
	
	lnresult int;	

begin

	lnresult = 1;

	if (select count(id) from aasta where kuu = month(tdkpv) and aasta = year(tdkpv) and rekvid = tnrekvId and kinni = 1) = 1 or year(tdKpv) < 2008 then
		raise notice 'Ei tohi selles periodis töötada';
		lnresult = 0;
	end if;

         return  lnresult;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_aasta_kontrol(integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_aasta_kontrol(integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION fnc_aasta_kontrol(integer, date) TO public;
