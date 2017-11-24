/*

select fnc_currentvaluuta(date())

select dateasint(date())

*/

CREATE OR REPLACE FUNCTION dateasint(date)
  RETURNS integer AS
$BODY$

DECLARE 
	tdKpv alias for $1;
	lnDate int;
	lcKuu varchar(2);
	lcPaev varchar(2);
begin
	lnDate = 0;
	if month(tdKpv) < 10 then
		lcKuu = '0'+str(month(tdKpv),1); 
	else
		lcKuu = str(month(tdKpv),2); 
	end if;
	if day(tdKpv) < 10 then
		lcPaev = '0'+str(day(tdKpv),1);
	else
		lcPaev = str(day(tdKpv),2);
	end if;
	if not empty(tdKpv) then
		lnDate = val(str(year(tdKpv),4)+lcKuu+lcPaev);
	end if;

	
	return lnDate;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION dateasint(date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION dateasint(date) TO public;
