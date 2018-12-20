
CREATE OR REPLACE FUNCTION fnc_calc_tm(tnSumma numeric, tnMVT numeric, tnTKI numeric, tnPM numeric, tcTuluLiik varchar(20))
  RETURNS numeric AS
$BODY$


declare 
	lnTM numeric = 0;
	l_tm_maar numeric(14,2) = coalesce((select tun1 from library where kood = tcTuluLiik::varchar(20) and library = 'MAKSUKOOD'),20)::numeric / 100;
	v_rec record;
BEGIN

lnTM = round((tnSumma - tnMVT - tnTKI - tnPM) * l_tm_maar,2);


if tnSumma > 0 and lnTM < 0 then
	-- check for minus
	lnTM = 0;
end if;


raise notice ' fnc_calc_tm lnTM %,tnSumma %, tnMVT %, tnTKI % tnPM %', lnTM, tnSumma , tnMVT, tnTKI , tnPM;

RETURN lnTM;


end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
  

GRANT EXECUTE ON FUNCTION fnc_calc_tm(tnSumma numeric, tnMVT numeric, tnTKI numeric, tnPM numeric, tcTuluLiik varchar(20)) TO dbkasutaja;


select fnc_calc_tm(-15.23,0,  -0.24, -0.3, '10');
select fnc_calc_tm(1400.99,388.34, 22.42,28.02, '10');

/*
select * from library where kood = '10' and library = 'MAKSUKOOD'
select tun1 from library where kood = '10'::varchar(20) and library = 'MAKSUKOOD'
select tun1 from library where ltrim(rtrim(kood)) = ltrim(rtrim('10')) and ltrim(rtrim(library)) like 'MAKSUKOOD%'
*/