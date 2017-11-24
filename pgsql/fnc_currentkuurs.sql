/*

select fnc_currentkuurs(date())
 
select library.id, kood, valuuta1.* 
from library inner join valuuta1 on library.id = valuuta1.parentid
where alates <= date() and kuni >= date()

*/

CREATE OR REPLACE FUNCTION fnc_currentkuurs(date)
  RETURNS numeric AS
$BODY$

DECLARE 
	tdKpv alias for $1;
	lnKuurs numeric(14,4);
	lnPohiKuurs numeric(14,4);
	inId int;
begin
	-- pohi tingimused
	
	if year(tdKpv) < 2011 then
		lnKuurs = 1;
	else
		lnKuurs = 15.6466;
	end if;
	-- otsime pohivaluuta

	select valuuta1.kuurs into lnPohiKuurs 
		from library inner join valuuta1 on library.id = valuuta1.parentid
		where valuuta1.alates <= tdKpv and valuuta1.kuni >= tdKpv and 
		library.kood = fnc_currentvaluuta(tdKpv);

	lnKuurs = ifnull(lnPohiKuurs,lnKuurs);
	
	return lnKuurs;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_currentkuurs(date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_currentkuurs(date) TO public;
GRANT EXECUTE ON FUNCTION fnc_currentkuurs(date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_currentkuurs(date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_currentkuurs(date) TO dbvaatleja;
