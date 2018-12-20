-- Function: sp_calc_palgajaak(integer, date, date, integer, integer)

-- DROP FUNCTION sp_calc_palgajaak(integer, date, date, integer, integer);

CREATE OR REPLACE FUNCTION sp_calc_palgajaak(tnrekvid integer, tdkpv1 date, tdkpv2 date, tnisik1 integer, tnisik2 integer)
  RETURNS smallint AS
$BODY$
declare 
tnid	int4;

ldKpv2 	date;
lnKuu	int4 = month(tdkpv1);
lnAasta int4 = year (tdKpv1) ;
ldKpv1	date = date(lnAasta, lnKuu, 1);
v_tooleping	record;

BEGIN
for v_tooleping in 
select   tooleping.id from asutus inner join tooleping on tooleping.parentId = asutus.id
	where asutus.id >= tnIsik1
	and  asutus.id <= tnIsik2
	and tooleping.rekvid = tnrekvid
	order by id desc
 

loop
-- muudetud 03/01/2004
	while tdkpv2 >= ldKpv1
		loop
			ldKpv1 := date(lnAasta, lnKuu, 1);

			ldkpv2 := ldKpv1 + INTERVAL ' 1 month ' - INTERVAL '1 DAY ';
			perform sp_update_palk_jaak (ldKpv1,ldKpv2, tnRekvId, v_tooleping.id); 					
			lnKuu := lnkuu+1;

			if lnkuu > 12 THEN
				lnkuu := 1; 
				lnaasta := lnaasta + 1;	

			end if;	
		end loop;
		ldKpv1 = date(year (tdKpv1), month(tdkpv1), 1)	;
end loop; 
return 1;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_palgajaak(integer, date, date, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_palgajaak(integer, date, date, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_palgajaak(integer, date, date, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_palgajaak(integer, date, date, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_palgajaak(integer, date, date, integer, integer) TO dbpeakasutaja;
