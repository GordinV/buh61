Parameter cWhere
tcOper = '%'+rtrim(ltrim(fltrLaduArved.oper))+'%'
tcKood = '%'+rtrim(ltrim(fltrLaduArved.kood))+'%'
tcNumber = '%'+rtrim(ltrim(fltrLaduArved.number))+'%'
tcAsutus = '%'+rtrim(ltrim(fltrLaduArved.asutus))+'%'
tdKpv1 = iif(empty(fltrLaduArved.kpv1),date(year(date()),1,1),fltrLaduArved.kpv1)
tdKpv2 = iif(empty(fltrLaduArved.kpv2),date(year(date()),12,31),fltrLaduArved.kpv2)
tnKogus1 = fltrLaduArved.Summa1
tnKogus2 = iif(empty(fltrLaduArved.Summa2),999999999,fltrLaduArved.Summa2)
tnSumma1 = fltrLaduArved.Summa1
tnSumma2 = iif(empty(fltrLaduArved.Summa2),999999999,fltrLaduArved.Summa2)
tnLiik = 1
oDb.use('curLaduArved','Laduraamat_reportS')
&&use (cQuery) in 0 alias arve_report2
tnLiik = 2
select curLaduArved
oDb.use('curLaduArved','Laduraamat_reportV')

SELECT kood, nimetus, uhik, asutus, tunnus, number, kpv, summa as ssumma, 000000000.00 as vsumma, kogus as skogus, 000000000.00 as vkogus,;
	hind as shind, 000000000.00 as vhind from Laduraamat_reportS;
union all;
SELECT kood, nimetus, uhik, asutus, tunnus, number, kpv, 000000000.00 as ssumma, summa as vsumma, 000000000.00 as skogus, kogus as vkogus,;
	000000000.00 as shind, hind as vhind from Laduraamat_reportV;
into CURSOR Laduraamat_report 

select * from Laduraamat_report ORDER BY kood, kpv INTO CURSOR Laduraamat_report1

USE IN Laduraamat_reportS
USE IN Laduraamat_reportv
USE IN Laduraamat_report

SELECT Laduraamat_report1