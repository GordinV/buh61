/*
select fnc_valkehtivus('EUR', date(2011,01,01))
select * from library where library = 'VALUUTA'

select count(id) from library where library = 'VALUUTA' and kood = 'EUR' 
			and (empty(library.tun4) or library.tun4 <= dateasint(date(2011,01,01))) 
			and  (empty(library.tun5) or library.tun5 >= dateasint(date(2011,01,01)))
*/

CREATE OR REPLACE FUNCTION fnc_valkehtivus(varchar, date)
  RETURNS numeric AS
$BODY$

DECLARE 
	tcValuuta alias for $1;
	tdKpv alias for $2;
	lnreturn int;
	inId int;
begin
	-- pohi tingimused
	lnReturn = 0;
	
	if year(tdKpv) < 2011 and tcValuuta = 'EEK' then
		lnReturn = 1;
	else
		-- otsime valuuta
		if (select count(id) from library where library = 'VALUUTA' and kood = tcValuuta 
			and (empty(library.tun4) or library.tun4 <= dateasint(tdKpv)) 
			and  (empty(library.tun5) or library.tun5 >= dateasint(tdKpv))) > 0 then
			lnReturn = 1;
		end if;
	end if;	
	return lnReturn;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_valkehtivus(varchar, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_valkehtivus(varchar, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_valkehtivus(varchar, date) TO dbkasutaja;
