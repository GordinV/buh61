-- Function: kbm_report1(integer, date, date)

DROP FUNCTION if exists kbm_report1(integer, date, date);

CREATE OR REPLACE FUNCTION kbm_report1(
    IN tnrekvid integer,
    IN tdkpv1 date,
    IN tdkpv2 date,
    OUT rea01 numeric,
    OUT rea011 numeric,
    OUT rea02 numeric,
    OUT rea021 numeric,
    OUT rea03 numeric,
    OUT rea031 numeric,
    OUT rea0311 numeric,
    OUT rea04 numeric,
    OUT rea041 numeric,
    OUT rea05 numeric,
    OUT rea051 numeric,
    OUT rea052 numeric,
    OUT rea12 numeric,
    OUT rea13 numeric)
  RETURNS record AS
$BODY$
declare 
	lcDay varchar(2);
begin
	select 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  into rea01, rea011, rea02, rea021, rea03, rea031, rea0311, rea04, rea041, rea05, rea051, rea052, rea12, rea13 ;
	-- kbm = 20% 322140
	rea01 = (select sum(summa) from curJournal 
		where rekvId = tnRekvId and kpv >= tdKpv1 and kpv <= tdKpv2
		and kreedit in ('322290', '323300', '323340', '323350', '323360','323390', '323890'));

--	rea04 = rea01 * 0.20;

	-- Alvina, 19.02.2018
	rea04 = (select sum(summa) from curJournal 
			where rekvid = tnRekvId and kpv >= tdKpv1 and kpv <= tdKpv2
			and kreedit in ('203000', '203001')
	);

	rea05 = (
		select sum(summa) from curJournal 
			where rekvid = tnRekvId and kpv >= tdKpv1 and kpv <= tdKpv2
			and deebet = '103701'
	);
	
	rea051 = 0;
	rea052 = coalesce((select sum(summa) from curJournal 
		where rekvid = tnRekvId and kpv >= tdKpv1 and kpv <= tdKpv2
		and kreedit = '201010'),0);
	
         return;
end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION kbm_report1(integer, date, date)
  OWNER TO vlad;
GRANT EXECUTE ON FUNCTION kbm_report1(integer, date, date) TO public;
GRANT EXECUTE ON FUNCTION kbm_report1(integer, date, date) TO vlad;
GRANT EXECUTE ON FUNCTION kbm_report1(integer, date, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION kbm_report1(integer, date, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION kbm_report1(integer, date, date) TO dbvaatleja;


select * from kbm_report1(1, date(2018,01,01), date(2018,01,31))