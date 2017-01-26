select * from curJournal where rekvId = 13 
and ltrim(rtrim(kreedit)) in ('202002','202003','202004')
and tunnus LIKE '0820601%'
and kood2 like '60%'
and kood5 like ('500%')
and ltrim(rtrim(deebet)) in ('202000')
and kuu in (1,2,3,4,5,6,7,8,10,11,12)

update journal1 set kood2 = '' 
where parentid in (
select id from curJournal where rekvId = 13 
and kuu in (1,2,3,4,5,6,7,8,10,11,12))
and ltrim(rtrim(kreedit)) in ('202002','202003','202004')
and tunnus LIKE '0820601%'
and kood2 like '60%'
and kood5 like ('500%')
and ltrim(rtrim(deebet)) in ('202000')






select journalid.number, palk_oper.* from palk_oper inner join journalId on palk_oper.journalId = journalid.journalid 
where palk_oper.rekvId = 31 and palk_oper.kpv = date(2004,12,31) 
and libId in (select parentid from palk_lib where liik = 6)
and kood1 = '09110'



delete from palk_oper where id in (
select palk_oper.id from palk_oper inner join journalId on palk_oper.journalId = journalid.journalid 
where palk_oper.rekvId = 31 and palk_oper.kpv = date(2004,12,31) 
and libId in (select parentid from palk_lib where liik = 6)
and kood1 = '09110'
)


select journalid.number, palk_oper.* from palk_oper inner join journalId on palk_oper.journalId = journalid.journalid 
where palk_oper.rekvId = 31 and palk_oper.kpv = date(2004,12,30)
and libId in (select parentid from palk_lib where liik = 5)
and ltrim(rtrim(kood1)) = '09110'


delete from palk_oper where id in (
select palk_oper.id from palk_oper 
where palk_oper.rekvId = 31 and palk_oper.kpv = date(2004,12,30)
and libId in (select parentid from palk_lib where liik = 7)
and ltrim(rtrim(kood1)) = '09110'
)


delete from palk_oper where id in (
select palk_oper.id from palk_oper inner join journalId on palk_oper.journalId = journalid.journalid 
where palk_oper.rekvId = 31 and palk_oper.kpv = date(2004,12,30)
and libId in (select parentid from palk_lib where liik = 7 and asutusest = 1)
and ltrim(rtrim(kood1)) = '09110'
)

update journal1 set kood2 = '' 
where parentid in (
select id from curJournal where rekvid = 31 and month(kpv) = 7
and asutusId <> 15422
and kpv = date(2004,07,31)
) 
and  kood1 = '08107' and tunnus = '0810799'
and deebet in ('500500','202000') 
and kreedit in ('202000','202002','202003','202004')
and kood5 = '5005'
and kood2 = '60'


select * from asutus where upper(nimetus) like upper('%Kibkalo%')


