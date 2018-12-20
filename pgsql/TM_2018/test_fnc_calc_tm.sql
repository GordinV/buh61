
CREATE OR REPLACE FUNCTION test_fnc_calc_tm()
  RETURNS integer AS
$BODY$

declare 
	lnVaheSumma numeric = 0;
	lnTulemus integer = 1;
BEGIN

lnTulemus = (case 
	when fnc_calc_tm(1400.99, 388.34, 22.42, 28.02, '10') <> 192.44 then 0 
	when fnc_calc_tm(120, 500, 1.92, 2.40, '10') <> 0 then 0 
	when fnc_calc_tm(-15.23, 0, -0.24, -0.3, '10') <> -2.94 then 0 
	when fnc_calc_tm(205.25, -16.84, 3.28, 4.11, '10') <> 42.94 then 0 
	else 1
end);
	 
RETURN lnTulemus;


end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
  


select test_fnc_calc_tm();