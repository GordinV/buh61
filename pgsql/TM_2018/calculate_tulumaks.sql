
drop function if exists calculate_tulumaks(numeric(14,4), numeric(14,4));

CREATE OR REPLACE FUNCTION calculate_tulumaks(tulu numeric(14,4), mvt numeric(14,4))
  RETURNS numeric AS
$BODY$
declare 
	tm numeric(14,4) = 0; -- return value
	tm_maar numeric(6,2) = 20; -- tulumaks %
begin
	
	tm = coalesce(tulu, 0) - coalesce(mvt,0) * tm_maar * 0.01;
	
	if tm < 0 then
		tm = 0;
	end if;
	
        return tm;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
  
ALTER FUNCTION calculate_tulumaks(numeric(14,4), numeric(14,4))  OWNER TO vlad;
GRANT EXECUTE ON FUNCTION calculate_tulumaks(numeric(14,4), numeric(14,4)) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION calculate_tulumaks(numeric(14,4), numeric(14,4)) TO dbpeakasutaja;


select calculate_tulumaks(130 , 55)