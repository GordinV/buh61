select * from arv where rekvid in (select id from rekv where id = 119 or parentid = 119) and kpv = date(2015,01,09) and asutusid = 178

select * from curJournal where id = 6084379

select * from arvtasu where arvid = 287838

select * from asutus where nimetus ilike '%Kulgu Puit%'

select * from ettemaksud where asutusid = 22545 
and selg ilike '%parandus%'

update ettemaksud set summa = summa - 67.20 where id = 3177

select sp_recalc_rekljaak(2437)

select * from aasta where rekvid = 28 and aasta = 2014 and kuu = 9

select * from luba where parentid = 36587
select * from toiming where lubaid = 2437 and id = 20820;

update aasta set kinni = 0 where id = 5751;
update toiming set staatus = 1 where id = 20820;
select sp_recalc_rekljaak(2437);
update aasta set kinni = 1 where id = 5751;


