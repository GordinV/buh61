CREATE OR REPLACE FUNCTION sp_puudumise_paevad(date, integer)
  RETURNS integer AS
$BODY$
declare 
	tdKpv	ALIAS FOR $1;
	tnLepingid alias for $2;
	qryTooleping record;
	v_puudumine record;
	l_paevad integer = 0;
BEGIN
-- toopaevad - puhkused

select t.*  into qryTooleping
	from tooleping t 
	where t.id = tnLepingId;

for v_puudumine in
	select coalesce(kpv1,date(year(tdKpv),month(tdKpv),1)) as kpv1, coalesce(kpv2,tdKpv) as kpv2 from puudumine p
		where lepingId = tnLepingId
		and ((year(kpv2) = year(tdKpv) and month(kpv2) = month(tdKpv))  or (month(kpv1) = month(tdKpv) and year(kpv1) = year(tdKpv)))
		and (tunnus = 1 and tyyp in (1,2,3) or tunnus = 2 and tyyp = 1)
		order by kpv1, kpv2
loop
	if v_puudumine.kpv1 < date(year(tdKpv), month(tdKpv),1) then
		v_puudumine.kpv1 = date(year(tdKpv), month(tdKpv),1);
	end if;
	if v_puudumine.kpv2 > tdKpv then
		v_puudumine.kpv2 = tdKpv;
	end if;
-- paevad
	l_paevad = l_paevad + (v_puudumine.kpv2 - v_puudumine.kpv1) + 1;
end loop;		

RETURN l_paevad;
end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


--  select * from puudumine order by id desc limit 10
