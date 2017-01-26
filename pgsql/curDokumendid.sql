--DROP VIEW curDokumendid
/*
SELECT asutus.regkood, asutus.nimetus as asutus, rekv.nimetus as rekv, lausend, arved, palk, pv, kassa, mk, reklaam, vanemtasu, curDokumendid.muud 
from curDokumendid inner join asutus on asutus.id = curDokumendid.asutusId inner join rekv on rekv.id = curDokumendid.rekvid 
where (rekv.id in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, 1) > 3) or  rekv.id = 1) 
and (upper(asutus.nimetus) like upper('%N%') OR ASUTUS.REGKOOD LIKE '1%')
and upper(rekv.nimetus) like upper('%A%')


SELECT asutus.id, asutus.regkood, asutus.nimetus as asutus, rekv.nimetus as rekv,  lausend, arved, palk, pv, kassa, mk, reklaam, vanemtasu, curDokumendid.muud  from curDokumendid inner join asutus on asutus.id = curDokumendid.asutusId inner join rekv on rekv.id = curDokumendid.rekvid  where (rekv.id in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, 1 ) > 3) or  rekv.id = 1) and (upper(asutus.nimetus) like upper('%OKSANA BLINOVA%') OR ASUTUS.REGKOOD LIKE 'OKSANA BLINOVA %')  and upper(rekv.nimetus) like upper('%%')
*/

CREATE OR REPLACE VIEW curDokumendid AS 
select rekvid, asutusId, sum(lausend) as lausend, sum(arved) as arved, sum(palk) as palk, sum(pv) as pv, sum(kassa) as kassa, sum(mk) as mk, sum(reklaam) as reklaam, sum(vanemtasu) as vanemtasu, sum(muud) as muud from (
select asutusid, count(id)::integer as lausend,0 as arved, 0 as palk, 0 as pv, 0 as kassa, 0 as mk, 0 as reklaam, 0 as vanemtasu, 0 as muud, rekvid  from journal group by rekvid, asutusId
union all
select asutusid, 0 as lausend, count(id)::integer as arved, 0 as palk, 0 as pv, 0 as kassa, 0 as mk, 0 as reklaam, 0 as vanemtasu, 0 as muud, rekvid  from arv group by rekvid, asutusId
union all
select isikid as asutusId, 0 as lausend, 0 as arved, count(id)::integer as palk, 0 as pv, 0 as kassa, 0 as mk, 0 as reklaam, 0 as vanemtasu, 0 as muud, rekvid  from curPalkoper group by rekvid,isikId
union all
select asutusId, 0 as lausend, 0 as arved, 0 as palk, count(pv_oper.id)::integer as pv, 0 as kassa, 0 as mk, 0 as reklaam, 0 as vanemtasu, 0 as muud, library.rekvid  from pv_oper inner join library on library.id = pv_oper.parentid group by library.rekvid, asutusId
union all
select asutusId, 0 as lausend, 0 as arved, 0 as palk, 0 as pv, count(id)::integer as kassa, 0 as mk, 0 as reklaam, 0 as vanemtasu, 0 as muud, rekvid  from korder1 group by rekvid,asutusId
union all
select asutusId, 0 as lausend, 0 as arved, 0 as palk, 0 as pv, 0 as kassa, count(mk1.id)::integer as mk, 0 as reklaam, 0 as vanemtasu, 0 as muud, mk.rekvid  from mk1 inner join mk on mk.id = mk1.parentid group by mk.rekvid, asutusId
union all
select toiming.parentid as asutusId, 0 as lausend, 0 as arved, 0 as palk, 0 as pv, 0 as kassa, 0 as mk, count(toiming.id)::integer as reklaam, 0 as vanemtasu, 0 as muud, luba.rekvid  from toiming inner join luba on luba.id = toiming.lubaid group by luba.rekvid, toiming.parentid
union all
select isikid as asutusId, 0 as lausend, 0 as arved, 0 as palk, 0 as pv, 0 as kassa, 0 as mk, 0 as reklaam, count(vanemtasu4.id)::integer as vanemtasu, 0 as muud, vanemtasu3.rekvid  from vanemtasu4 inner join vanemtasu3 on vanemtasu3.id = vanemtasu4.parentid group by vanemtasu3.rekvid, isikid
) tmpDokumendid
group by rekvid,asutusId
order by asutusId, rekvid



