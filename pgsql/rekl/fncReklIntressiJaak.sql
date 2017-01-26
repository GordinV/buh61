
DROP FUNCTION if exists fncreklintressijaak(integer, date);

CREATE OR REPLACE FUNCTION fncreklintressijaak(in tnAsutusId integer, in tdKpv date)
  RETURNS numeric AS
$BODY$

declare
	lnIntressiSumma numeric(18,6);
	lnTasuSumma numeric(18,6);
begin
lnIntressiSumma = 0;

select sum(jaak) into lnIntressiSumma from (
select fncDeklJaak(id) as jaak from toiming where parentid = tnAsutusId and tyyp = 'INTRESS' and kpv >= date(2011,01,01) and kpv <= tdKpv and staatus > 0
) tmpJaak;

lnIntressiSumma = ifnull(lnIntressiSumma,0);

return lnIntressiSumma;
--- lnTasuSumma;
end;


$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
