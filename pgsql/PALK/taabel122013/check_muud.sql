drop function if exists check_muud(integer, integer, integer);


CREATE OR REPLACE FUNCTION check_muud(integer, integer, integer)
  RETURNS numeric AS
$BODY$
declare
	tnId alias for $1;
	tnKuu alias for $2;
	tnAasta alias for $3;
	lnStartKpv int;
	lnLoppKpv int;
	lnResult numeric(12,8);
	lnTunnid numeric;
	qryPuhkused record;
	l_str text;
begin

lnresult := 0;

for qryPuhkused in SELECT * from puudumine 
	WHERE lepingid = tnId 
	and ((month(kpv1) = tnKuu and year (kpv1) = tnAasta) 
	or  (month(kpv2) = tnKuu and year (kpv2) = tnAasta))
	AND TUNNUS = 4 and tyyp > 1
loop
	If month (qryPuhkused.kpv1) = tnKuu and year (qryPuhkused.kpv1) = tnAasta then
		lnStartKpv := day (qryPuhkused.kpv1);
	Else
		lnStartKpv := 1;
	End if;
	If month (qryPuhkused.kpv2) = tnKuu and year (qryPuhkused.kpv2) = tnAasta then
		lnLoppKpv := day (qryPuhkused.kpv2);
	Else
		lnLoppKpv := day(gomonth(date(tnAasta, tnKuu,1),1) - 1);
	End if;
	-- paevad
	lnresult := lnresult + sp_workdays(lnStartKpv, tnKuu, tnAasta, lnLoppKpv, tnid);
End loop;
	-- arvestame tunnid
	select sum(summa) into lnTunnid from puudumine 
		WHERE lepingid = tnId 
		and ((month(kpv1) = tnKuu and year (kpv1) = tnAasta) 
		or  (month(kpv2) = tnKuu and year (kpv2) = tnAasta))
		AND TUNNUS = 4 and tyyp > 1;
	if lnTunnid > 0 then		
		lnTunnid = lnTunnid / 10 ^ (position('.' in lnTunnid::text) - 1);
		lnResult = lnResult + lnTunnid;
	end if;
Return lnresult;

end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION check_muud(integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION check_muud(integer, integer, integer) TO taabel;
GRANT EXECUTE ON FUNCTION check_muud(integer, integer, integer) TO dbvanemtasu;

/*
select * from asutus where id in (select * from tooleping where rekvid = 63 and parentid = 167)

select check_muud(138252, 12, 2013)

select floor(1.6)
	select *from puudumine 
		WHERE lepingid = 138252
		and ((month(kpv1) = 12 and year (kpv1) = 2013) 
		or  (month(kpv2) = 12 and year (kpv2) = 2013))
		AND TUNNUS = 4;

		select sp_workdays(30, 12, 2013, 30, 138252)

update puudumine set summa = 6 where id = 88058
		

*/
