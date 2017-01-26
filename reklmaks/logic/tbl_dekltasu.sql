
-- Function: sp_calc_palgajaak(int4, date, date, int4, int4)

-- DROP FUNCTION sp_calc_palgajaak(int4, date, date, int4, int4);

-- muudetud 03/01/2005

CREATE OR REPLACE FUNCTION sp_calc_palgajaak(int4, date, date, int4, int4)
  RETURNS int2 AS
'
declare 
tnrekvId	ALIAS FOR $1;
tdkpv1	ALIAS FOR $2;
tdkpv2	ALIAS FOR $3;
tnIsik1	ALIAS FOR $4;
tnisik2	ALIAS FOR $5;	
tnid	int4;

ldKpv1	date;
ldKpv2 	date;
lnKuu	int4;
lnAasta int4;
v_tooleping	record;

BEGIN
for v_tooleping in select   tooleping.id from asutus inner join tooleping on tooleping.parentId = asutus.id
	where asutus.id >= tnIsik1
	and  asutus.id <= tnIsik2
	and tooleping.rekvid = tnrekvid
 

loop
	lnKuu := month(tdkpv1);
	lnAasta := year (tdKpv1);
	ldKpv1 := date(lnAasta, lnKuu, 1);
--	raise notice \'start\';
-- muudetud 03/01/2004
	while tdkpv2 >= ldKpv1
		loop
			ldKpv1 := date(lnAasta, lnKuu, 1);
	--		raise notice \'ldKpv1 %\',ldKpv1;

			ldkpv2 := ldKpv1 + INTERVAL \' 1 month \' - INTERVAL \'1 DAY \';
	--		raise notice \'ldKpv2 %\',ldKpv2;
			perform sp_update_palk_jaak (ldKpv1,ldKpv2, tnRekvId, v_tooleping.id); 					
			lnKuu := lnkuu+1;

			if lnkuu > 12 THEN
				lnkuu := 1; 
				lnaasta := lnaasta + 1;	

			end if;	
		end loop;	
end loop; 
return 1;
end;
'
  LANGUAGE 'plpgsql' VOLATILE;
GRANT EXECUTE ON FUNCTION sp_calc_palgajaak(int4, date, date, int4, int4) TO GROUP dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_palgajaak(int4, date, date, int4, int4) TO GROUP dbpeakasutaja;
