/*
drop function if exists fnc_calc_mvt(tnSumma numeric, tnMVT_kokku numeric, tnTKI numeric, tnPM numeric);
drop function if exists fnc_calc_mvt(tnSumma numeric, tnMVT_kokku numeric, tnIsikuMVT numeric, tnTKI numeric, tnPM numeric);
drop function if exists fnc_calc_mvt(tnSumma numeric,  tnTKI numeric, tnPM numeric, tdKpv date);
drop function if exists fnc_calc_mvt(tnSumma numeric,  tnTKI numeric, tnKokkuKasutatudMVT numeric, tnPM numeric, tdKpv date);
drop function if exists fnc_calc_mvt(tnSumma numeric,  tnTKI numeric, tnKokkuKasutatudMVT numeric, tnKokkuArvestatudSumma numeric, tnPM numeric, tdKpv date);
*/

CREATE OR REPLACE FUNCTION fnc_calc_mvt(tnSumma numeric,  tnMVT_kokku numeric, tnKokkuKasutatudMVT numeric, tnKokkuArvestatudSumma numeric, tnTKI numeric, tnPM numeric, tdKpv date)
  RETURNS numeric AS
$BODY$

-- tnMVT_kokku personal taotluse summa
declare 
	lnIsikuMVT numeric =  calc_mvt((case when coalesce(tnKokkuArvestatudSumma,0) > 0 then  tnKokkuArvestatudSumma else tnSumma end) ::numeric, tnMVT_kokku, tdkpv);
	lnMVT numeric = lnIsikuMVT ;

BEGIN
	raise notice 'lnIsikuMVT %', lnIsikuMVT;

	if lnIsikuMVT >  tnSumma then
		-- if tulu summa more then MVT
		lnMVT = tnSumma;
	end if;	
	
	if tnKokkuKasutatudMVT > 0 then
		lnMVT = lnIsikuMVT - tnKokkuKasutatudMVT;
	end if;


	IF lnMVT > (tnSumma - tnTKI - tnPM) THEN
		lnMVT = tnSumma - tnTKI - tnPM;
	END IF;


	if tnSumma < 0 then
		-- if summa < 0 then returning 0
		lnMVT = 0;
		if lnIsikuMVT > tnKokkuKasutatudMVT then
				-- umardamine, miinus summa
			lnMVT = lnIsikuMVT - tnKokkuKasutatudMVT;
		end if;
	end if;

	lnMVT = round(lnMVT,2);
	raise notice 'lnMVT %, lnMVT_kokku %, lnIsikuMVT %, tnKokkuKasutatudMVT %, tnKokkuArvestatudSumma %', lnMVT, tnMVT_kokku, lnIsikuMVT, tnKokkuKasutatudMVT, tnKokkuArvestatudSumma;

RETURN lnMVT;


end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
  

GRANT EXECUTE ON FUNCTION  fnc_calc_mvt(tnSumma numeric,  tnMVT_kokku numeric, tnKokkuKasutatudMVT numeric, tnKokkuArvestatudSumma numeric, tnTKI numeric, tnPM numeric, tdKpv date) TO dbkasutaja;

--select fnc_calc_mvt(335::numeric, 400::numeric, 400::numeric, 1197.5, 5.36, 6.70, date(2018,02,28));

select fnc_calc_mvt(205.25::numeric, 400::numeric, 400::numeric, 1205.07, 5.36, 6.70, date(2018,02,28));
