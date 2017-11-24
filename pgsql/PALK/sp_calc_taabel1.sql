-- Function: sp_calc_taabel1(integer, integer, integer, integer)
/*
select * from asutus where regkood = '39010160214'
select * from tooleping where rekvid = 63 and parentid = 36154

select sp_calc_taabel1(137100, 7, 2012, 0)
select sp_workdays(9, 07, 2012, 27, 137100)

select * from raamat where dokid = 137100
*/
-- DROP FUNCTION sp_calc_taabel1(137100, 7, 2012, 0);

CREATE OR REPLACE FUNCTION sp_calc_taabel1(integer, integer, integer, integer)
  RETURNS numeric AS
$BODY$
declare
	tnid alias for $1;
	tnkuu alias for $2;
	tnAasta alias for $3;
	tnToograf alias for $4;
	lnHours decimal;
	lnreturn int;
	lnHoliday int;
	v_tooleping record;
	lnPuhkus int;
	lnHaigus int;
	lnWorkdays int;
	npaev int;
	lnLoppPaev int;
begin

lnHours := 0;
lnreturn := 0;
lnHoliday := 0;
lnLoppPaev = 31;
--raise notice 'start';
select * into v_tooleping  from tooleping where id = tnid;

If month (v_Tooleping.algab ) = TnKuu and year (v_Tooleping.algab) = Tnaasta then
	nPaev := day (v_Tooleping.algab);
Else
	nPaev := 1;
End if;

if not empty(v_Tooleping.lopp) and month(v_Tooleping.lopp) = tnKuu and year(v_Tooleping.lopp) = tnAasta then
	lnLoppPaev = day(v_Tooleping.lopp);
end if;

raise notice 'npaev %',npaev;
raise notice 'lnLoppPaev %',lnLoppPaev;


SELECT tund into lnHours FROM Toograf WHERE lepingid = tnId AND kuu = tnKuu AND aasta = tnAasta;
raise notice 'lnHours %',lnHours;


if tnToograf = 0 and ifnull(lnHours,0) = 0 then

	-- arv puhkuse paevad
	lnPuhkus := check_puhkus(tnid, tnKuu, tnAasta);
	raise notice 'lnPuhkus %',lnPuhkus;

	-- arv haiguse paevad
	lnHaigus := check_haigus(tnid, tnKuu, tnAasta);
	raise notice 'lnHaigus %',lnHaigus;
end if;
if ifnull(lnHours,0) = 0 then
	lnWorkDays := sp_workdays(nPaev, tnKuu, tnAasta, lnLoppPaev, tnId)::INT4;
	raise notice 'lnWorkDays %',lnWorkDays;
	lnHours := (lnworkdays - (ifnull(lnPuhkus,0) + ifnull(lnhaigus,0))) * v_Tooleping.toopaev::int4;

	raise notice 'lnHours %',lnHours;
	lnHours := lnHours - sp_calc_tahtpaevad(v_tooleping.rekvId, tnKuu);
	raise notice 'lnHours parandus%',lnHours;

end if;

Return ifnull(lnHours,0);
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_taabel1(integer, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_taabel1(integer, integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_taabel1(integer, integer, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_taabel1(integer, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_taabel1(integer, integer, integer, integer) TO taabel;
