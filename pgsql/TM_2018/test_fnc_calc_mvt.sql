
CREATE OR REPLACE FUNCTION test_fnc_calc_mvt()
  RETURNS integer AS
$BODY$

declare 
	lnVaheSumma numeric = 0;
	lnTulemus integer = 1;
BEGIN

lnTulemus = (case 
	when fnc_calc_mvt(1400.99,  500, 0, 0, 22.42, 28.02, date(2018,02,28)) <> 388.34 then 0 
	when fnc_calc_mvt(1400.99,  300, 0, 0, 22.42, 28.02, date(2018,02,28)) <> 300 then 0 
	when fnc_calc_mvt(300, 300,  0, 0, 4.8, 6, date(2018,02,28)) <> 289.20 then 0 
	when fnc_calc_mvt(1200, 0,  0, 0, 4.8, 6, date(2018,02,28)) <> 0 then 0 
	when fnc_calc_mvt(1300, 500,  0, 0, 20.8, 26, date(2018,02,28)) <> 444.44 then 0 
	when fnc_calc_mvt(1300, 500,  400, 0, 20.8, 26, date(2018,02,28)) <> 44.44 then 0 
	when fnc_calc_mvt(1300, 500,  500, 0, 20.8, 26, date(2018,02,28)) <> -55.56 then 0 
	when fnc_calc_mvt(1400.99, 400,  388.34, 0, 22.42, 28.02, date(2018,02,28)) <> 0 then 0 
	when fnc_calc_mvt(335.00, 400.00,  400.00, 862, 22.42, 28.02, date(2018,02,28)) <> 0 then 0 
	when fnc_calc_mvt(62.00, 400.00,  400.00, 1197.5, 22.42, 28.02, date(2018,02,28)) <> 0 then 0 
	when fnc_calc_mvt(-15.23, 400.00,  400.00, 1197.5,0, 0, date(2018,02,28)) <> 0 then 0 
	when fnc_calc_mvt(205.25, 400.00,  400.00, 1410.32,0, 0, date(2018,02,28)) <> -16.84 then 0 
	when fnc_calc_mvt(-9.33, 400.00,  383.15, 1400.99,0, 0, date(2018,02,28)) <> 5.19 then 0 
	when fnc_calc_mvt(1400.99, 400.00,  388.34, 1400.99,22.42, 28.02, date(2018,02,28)) <> 0 then 0 
	else 1
end);
	 
RETURN lnTulemus;


end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
  


select test_fnc_calc_mvt();