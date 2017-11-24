select * from luba where number = '02/2011-401'


select * from toiming where lubaid = 1939
and number = 2
and staatus < 3 


update toiming set staatus = 3 where id = 16304

select * from dekltasu where deklid = 13915

update dekltasu set summa = summa * 15.6466 where id = 5181

update dekltasu set summa = 55.28 * 15.6466 where id = 5386


update dekltasu set summa = 0 where id in(5385)


SELECT * FROM ASUTUS WHERE upper(NIMETUS) like '%VEELMAA%'

select * from luba where parentid = 22722

select asutus.id, asutus.regkood, asutus.nimetus from asutus 
where  asutus.id in (select parentId from luba where  luba.rekvid = 28 and luba.staatus = 0) and ltrim(rtrim(upper(asutus.nimetus))) like  trim(rtrim(upper('%' ))) 
and asutus.regkood like '11335028%' 
ORDER BY upper(asutus.nimetus)

SELECT * FROM curJournal where rekvid = 28 and number = 2642

update journal set asutusid = 4634 where asutusid = 19296 and id = 

