-- Function: fnc_currentkuurs(date)
/*
select fnc_ntod(20120132)

*/
-- DROP FUNCTION fnc_currentkuurs(date);

CREATE OR REPLACE FUNCTION fnc_ntod(integer)
  RETURNS date AS
$BODY$

DECLARE 
	tnKpv alias for $1;
	lnAasta integer;
	lnKuu integer;
	lnPaev integer;
	lcKpv varchar;
	
	ldReturn date;
	inId int;
begin
ldReturn = date(2099,12,31);
	if tnKpv > 19000101 then
		lcKpv = str(tnKpv);
		lnAasta = val(left(lcKpv,4));
		raise notice 'lnAasta %',lnAasta;
		lnPaev = tnKpv - val(left(lcKpv,6))*100;
		raise notice 'lnPaev %',lnPaev;
		lnKuu = val(left(lcKpv,6)) - lnAasta*100;	
		raise notice 'lnKuu %',lnKuu;
		if (lnAasta < 1900 or lnAasta > 2100) or (lnKuu < 1 or lnKuu > 12) or (lnPaev < 1 or lnPaev > 31) then
			ldReturn = date(2099,12,31);
		else		
			ldReturn = date(lnAasta, lnKuu, lnPaev);
		end if;
	end if;
	
	return ldReturn;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_ntod(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_ntod(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_ntod(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_ntod(integer) TO dbvaatleja;
