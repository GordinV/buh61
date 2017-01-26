-- Function: "month"()
/*
select DaysInMonth(date(2011,02,01))
*/
-- DROP FUNCTION "month"();

CREATE OR REPLACE FUNCTION DaysInMonth(date)
  RETURNS integer AS
$BODY$
DECLARE tdKpv alias for $1;
	ldKpv1 date;
	ldKpv2 date;
begin
	ldKpv1 = date(YEAR(tdKpv),month(tdKpv),1);
	ldKpv2 = gomonth(ldKpv1,1);


         return  ldKpv2 - ldKpv1;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION DaysInMonth(date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION DaysInMonth(date) TO public;
