drop function if exists calc_mvt(numeric, date);
drop function if exists calc_mvt(numeric, numeric, date);


CREATE OR REPLACE FUNCTION calc_mvt(tulu numeric, mvt numeric, kpv date )
  RETURNS numeric AS
$BODY$

DECLARE 
	lnMVT numeric(14,4) = 0;
	lnMaxLubatatudMVT numeric(14,4) = 500;
	lnTaotlusedMVT numeric(14,4) = coalesce(mvt, 500);
	lnTuluMaxPiir numeric(14,4) = 1200;
	lnTuluMinPiir numeric(14,4) = 900;
	lnMaxMvt numeric(14,4) = lnMaxLubatatudMVT - lnMaxLubatatudMVT / lnTuluMinPiir * (tulu - lnTuluMaxPiir); 	--500 - 500 / 900 × 	(tulu - 1200) 
	lnArvestatudMVT numeric(14,4)  = lnTaotlusedMVT - lnTaotlusedMVT / lnTuluMinPiir * (tulu - lnTuluMaxPiir);

begin
	if lnMaxMvt < mvt and lnArvestatudMVT < lnMaxMvt then
		-- vottame max lubatatud MVT
		lnArvestatudMVT = lnMaxMvt;
	end if;
	if lnArvestatudMVT < mvt then
		lnMVT = lnArvestatudMVT;
	else 
		lnMVT = mvt;
	end if;

	raise notice 'lnMVT: %, lnTaotlusedMVT %, lnTuluMinPiir %, lnMaxMvt %, lnArvestatudMVT %', lnMVT, lnTaotlusedMVT, lnTuluMinPiir, lnMaxMvt, lnArvestatudMVT;

	-- juhl kui «tulu – PM – TKI» < 500 EUR, siis kasutame teine arvestus ja võrdleme tulemus ja taotletud MVT

	if lnMVT >= tulu then 
		lnMVT = tulu;
	end if;

	if (lnMVT > mvt) then
		lnMVT = mvt;
	end if;

	if (lnMVT < 0) then
		lnMVT = 0;	
	end if;
	return lnMVT;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION calc_mvt(numeric, numeric, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION calc_mvt(numeric, numeric, date) TO dbpeakasutaja;

select calc_mvt(1200, 500, date(2018,01,31));



