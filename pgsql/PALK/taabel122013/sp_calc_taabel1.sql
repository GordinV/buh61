-- Function: sp_calc_taabel1(integer, integer, integer, integer)

-- DROP FUNCTION sp_calc_taabel1(integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_calc_taabel1(integer, integer, integer, integer)
  RETURNS numeric AS
$BODY$
declare
	tnid alias for $1;
	tnkuu alias for $2;
	tnAasta alias for $3;
	tnToograf alias for $4;
	lnHours numeric(18,4);
	lnreturn int;
	lnHoliday int;
	v_tooleping record;
	lnPuhkus int;
	lnHaigus int;
	lnMuud numeric(16,8);
	lnPaevad int=0;
	lnTunnid int=0;
	lnWorkdays int=0;
	npaev int;
	lnLoppPaev int;
	l_str text='';
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

	-- arv haiguse paevad
	lnHaigus := check_haigus(tnid, tnKuu, tnAasta);

	-- arv muud paevad
	lnMuud := check_muud(tnid, tnKuu, tnAasta);
	-- tunnid
	lnTunnid = (lnMuud - floor(lnMuud)) * 10 ^ (position('.' in lnMuud::text) - 1);
	lnMuud = floor(lnMuud);	
	if lnTunnid > 0 then
		-- vottame tunnid
		lnMuud = 0;
	end if;
--	raise notice 'lnMuud %,lnTunnid %, lnPuhkus %, lnHaigus %',lnMuud,lnTunnid, lnPuhkus, lnHaigus;

end if;
if ifnull(lnHours,0) = 0 then
	lnWorkDays := sp_workdays(nPaev, tnKuu, tnAasta, lnLoppPaev, tnId)::INT4;
	raise notice 'lnWorkDays %',lnWorkDays;
	lnHours := (lnworkdays - (ifnull(lnPuhkus,0) + ifnull(lnhaigus,0) + lnMuud)) * v_Tooleping.toopaev - lnTunnid;

	raise notice 'lnHours %',lnHours;
	lnHours := lnHours - sp_calc_tahtpaevad(v_tooleping.rekvId, tnKuu);
	raise notice 'lnHours parandus%',lnHours;

end if;

Return ifnull(lnHours,0);
end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION sp_calc_taabel1(integer, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_taabel1(integer, integer, integer, integer) TO taabel;

select sp_calc_taabel1(138252, 12, 2013, 0)