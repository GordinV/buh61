
CREATE OR REPLACE FUNCTION sp_koosta_parandus(integer, date default date())
  RETURNS smallint AS
$BODY$

declare 

	tnId alias for $1;
	tdKpv alias for $2;
	v_luba record;
	v_dekl record;
	lnresult int;
	lcAlus varchar;
	l_number integer;
begin
	lnresult = 0;
	select * into v_luba from luba where id = tnId;

	if v_luba.staatus = 0 then
		raise exception 'Luba anulleritud';
		return 0;
	end if;

	lcAlus = 'Dekl. number:'+ltrim(rtrim(v_luba.number))+space(1)+tdkpv::varchar +' nt maksumaksja avaldus ';

	select max(number)+1 into l_number from toiming where lubaId = v_luba.id and tyyp = 'PARANDUS';
	lnresult =  sp_salvesta_toiming(0, v_luba.parentid,v_luba.id, date(), lcAlus, space(1), tdKpv, 0, 0, 'PARANDUS', space(1), 0, 0, coalesce(l_number,1),fnc_currentvaluuta(date()),fnc_currentkuurs(date()));
	Return lnresult;

end; 

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
ALTER FUNCTION sp_koosta_parandus(integer, date)
  OWNER TO vlad;
/*
select sp_koosta_parandus(     2603)
select * from toiming where id = 20722
select max(number)+1  from toiming where lubaId = 2603 and tyyp = 'PARANDUS';
*/