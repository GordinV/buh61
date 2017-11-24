drop function if exists kbm_report1(integer, date, date);

CREATE OR REPLACE FUNCTION kbm_report1(IN tnRekvId integer, IN tdKpv1 date, In tdKpv2 date, 
	OUT rea01 numeric(14,4), OUT rea011 numeric(14,4),
	OUT rea02 numeric(14,4), OUT rea021 numeric(14,4),
	OUT rea03 numeric(14,4), OUT rea031 numeric(14,4), OUT rea0311 numeric(14,4),
	OUT rea04 numeric(14,4), OUT rea041 numeric(14,4),
	OUT rea051 numeric(14,4), OUT rea052 numeric(14,4), 
	OUT rea12 numeric(14,4), OUT rea13 numeric(14,4))
as 
$$
declare 
	lcDay varchar(2);
begin
	select 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  into rea01, rea011, rea02, rea021, rea03, rea031, rea0311, rea04, rea041, rea051, rea052, rea12, rea13 ;
	-- kbm = 20% 322140
	rea01 = (select sum(summa) from curJournal 
		where rekvId = tnRekvId and kpv >= tdKpv1 and kpv <= tdKpv2
		and kreedit in ('322290', '323300', '323340', '323350', '323360','323390', '323890'));

	rea04 = rea01 * 0.20;

	rea051 = 0;
	rea052 = coalesce((select sum(summa) from curJournal 
		where rekvid = tnRekvId and kpv >= tdKpv1 and kpv <= tdKpv2
		and kreedit = '201010'),0);
	
         return;
end; 
$$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  GRANT EXECUTE ON FUNCTION kbm_report1(integer, date, date) TO dbkasutaja;
  GRANT EXECUTE ON FUNCTION kbm_report1(integer, date, date) TO dbpeakasutaja;
  GRANT EXECUTE ON FUNCTION kbm_report1(integer, date, date) TO dbvaatleja;

select * from   kbm_report1(1, date(2017,09,01), date(2017,09,30));
