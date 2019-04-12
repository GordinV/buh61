
drop function if exists get_saldo(konto text, rv text);
drop function if exists get_saldo(formula text, konto text, rv text);
drop function if exists get_saldo(formula text, konto text, rv text, tegev text);

drop table if exists tmp_andmik;
create temporary table tmp_andmik (idx text, tyyp integer, tegev varchar(20), artikkel varchar(20), rahavoog varchar(20), nimetus varchar(254), 
	eelarve numeric(14,2), tegelik numeric(14,2), kassa numeric(14,2), saldoandmik numeric(14,2), db numeric(14,2), kr numeric(14,2), aasta integer, kuu integer);

CREATE OR REPLACE FUNCTION get_saldo(formula text, konto text, rv text, tegevus text)
                                                 returns numeric
as 
$$
select coalesce((SELECT sum(case 
	when $1 like '%KD' then (kr - db) when $1 like '%DK' then (db - kr) 
	else  saldoandmik end) 
			from tmp_andmik s,
			(select min(aasta) as eelmine_aasta, max(aasta) as aasta, min(kuu) as eelmine_kuu, max(kuu) as kuu from tmp_andmik) aasta			
			where s.tyyp = 2
			and s.aasta = case when left($1,1) = 'M' then aasta.eelmine_aasta else  aasta.aasta end
--			and s.kuu = case when left($1,1) = 'M' then aasta.eelmine_kuu else  aasta.kuu end
			and ($2 is null or s.artikkel like trim($2::text ||  '%'))
			 and ($3 is null or trim(s.rahavoog) = $3)
			 and ($4 is null or trim(s.tegev) = $4)),0);
$$
  LANGUAGE sql VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION get_saldo(formula text, konto text, rv text, text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION get_saldo(formula text, konto text, rv text, text) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION get_saldo(formula text, konto text, rv text, text) TO eelaktsepterja;
GRANT EXECUTE ON FUNCTION get_saldo(formula text, konto text, rv text, text) TO dbvaatleja;


/*

SELECT *
FROM eelarve_andmik(DATE(2019,01,31), 63, 0)
where (not empty(tegev) or not empty(artikkel))




SELECT * from tmp_andmik
where tyyp = 2
and artikkel like trim('30'::text ||  '%')


SELECT get_saldo_sql('30',null) 
*/