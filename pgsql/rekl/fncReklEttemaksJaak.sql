DROP FUNCTION if exists fncreklettemaksjaak(integer, date);

CREATE OR REPLACE FUNCTION fncreklettemaksjaak(in tnAsutusId integer, in tdKpv date)
  RETURNS numeric AS
$BODY$

declare
	lnSumma numeric(18,6);
	
begin
lnSumma = 0;

select sum(summa) into lnSumma from ettemaksud where asutusId = tnAsutusId and kpv <= tdKpv;
lnSumma = ifnull(lnSumma,0);

return lnSumma;
end;


$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
