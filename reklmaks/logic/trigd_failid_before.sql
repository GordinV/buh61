-- Function: public.check_haigus(int4, int4, int4)

-- DROP FUNCTION public.check_haigus(int4, int4, int4);

CREATE OR REPLACE FUNCTION public.check_haigus(int4, int4, int4)
  RETURNS int4 AS
'
declare
	tnId alias for $1;
	tnKuu alias for $2;
	tnAasta alias for $3;
	lnStartKpv int;
	lnLoppKpv int;
	lResult int;
	lwhour numeric;
	qryPuhkused record;
begin

lresult := 0;
--raise notice \'result %\',lresult;

for qryPuhkused in SELECT * from puudumine 
	WHERE lepingid = tnId 
	and ((month(kpv1) = tnKuu and year (kpv1) = tnAasta) 
	or  (month(kpv2) = tnKuu and year (kpv2) = tnAasta))
	AND TUNNUS = 2
loop
--	raise notice \'loop \';
	If month (qryPuhkused.kpv1) = tnKuu and year (qryPuhkused.kpv1) = tnAasta then
		lnStartKpv := day (qryPuhkused.kpv1);
	Else
		lnStartKpv := 1;
	End if;
--	raise notice \'lnStartKpv %\',lnStartKpv;
	If month (qryPuhkused.kpv2) = tnKuu and year (qryPuhkused.kpv2) = tnAasta then
		lnLoppKpv := day (qryPuhkused.kpv2);
	Else
		lnLoppKpv := day(gomonth(date(tnAasta, tnKuu,1),1) - 1);
	End if;
--	raise notice \'lnLOPPKpv %\',lnLoppKpv;
	lwhour := sp_workdays(lnStartKpv, tnKuu, tnAasta, lnLoppKpv, tnid);
--	raise notice \'work hours %\',lwhour;
	lresult := lresult + lwhour;
--	raise notice \'result %\',lresult;

End loop;
Return lresult;

end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
