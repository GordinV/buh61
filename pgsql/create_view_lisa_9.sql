
create or replace view lisa_9 AS
select rekv_id,
maksja_regkood,
saaja_regkood,
saaja_tp,
saaja_nimi,
kpv,
sum(summa)::NUMERIC(14, 2)  as summa,
artikkel,
tegev
from (
SELECT j.rekvid::INTEGER            AS rekv_id,
       r.regkood::VARCHAR(20)       AS maksja_regkood,
       a.regkood::VARCHAR(20)       AS saaja_regkood,
       j.lisa_d::VARCHAR(20)            AS saaja_tp,
       a.nimetus::TEXT              AS saaja_nimi,
       j.kpv::DATE                  AS kpv,
       j.summa::NUMERIC(14, 2) AS summa,
       case 
	when ((j.deebet like '208120%' or j.deebet like '20%') and j.kreedit like '100100%' and j.kood5 = '2586' and j.kood3 = '06') then '20' 
	else left(j.kood5,2) 
	end::varchar(20)        AS artikkel,
       j.kood1::VARCHAR(20)         AS tegev

FROM curjournal j
         INNER JOIN rekv r ON r.id = j.rekvid
         INNER JOIN asutus a ON a.id = j.asutusid
WHERE  (j.kreedit LIKE '100%' --
	AND left(j.lisa_d,6) not in ('800699','014001','185101')
	AND left(j.kood5, 2) IN ('15', '20', '25', '41', '45', '50', '55', '65'))
 or ((j.deebet like '208120%' or j.deebet like '20%') and j.kreedit like '100100%' and j.kood5 = '2586' and j.kood3 = '06')
) qry
group by 
rekv_id,
maksja_regkood,
saaja_regkood,
saaja_tp,
saaja_nimi,
kpv,
artikkel,
tegev;



GRANT select ON TABLE lisa_9 TO dbkasutaja;
GRANT select ON TABLE lisa_9 TO dbpeakasutaja;
GRANT select ON TABLE lisa_9 TO dbvaatleja;

SELECT *
FROM lisa_9
where kpv >= '2020-01-31'
and kpv <= '2020-12-31'
--and rekv_id = 3
and saaja_nimi like '%liising%'
--and saaja_tp::text in ('800699','014001','014003')

/*
select * from curJournal 
where deebet like '20%'
and kreedit like '100100%'
and kood5 = '2586'
*/

