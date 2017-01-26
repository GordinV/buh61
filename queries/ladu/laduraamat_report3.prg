Parameter cWhere

CREATE CURSOR Laduraamat_report1 (nomid int,kood c(20), nimetus c(254), uhik c(20), asutus c(254),tunnus c(20),;
	number c(20), kpv d, akogus n(14,2), asumma n(14,2), ssumma n(18,2), skogus n(12,4), shind n(14,2),;
	vsumma n(18,2), vkogus n(12,4), vhind n(14,2), lsumma n(14,2), lkogus n(14,2), tunnimi c(254) )

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
tnLiik = oladuArved.pageframe1.activepage
oDb.use('curLaduArved','Laduraamat_report1')
&&use (cQuery) in 0 alias arve_report2


INDEX ON LEFT(ALLTRIM(tunnus)+ALLTRIM(kood),40) TAG tunnus

SELECT Laduraamat_report1

SCAN FOR !empty(tunnus)
	SELECT comTunnusRemote
	LOCATE FOR kood = Laduraamat_report1.tunnus
	IF FOUND()
		replace Laduraamat_report1.tunnimi WITH comTunnusRemote.nimetus IN Laduraamat_report1
	ENDIF
	
ENDSCAN
SELECT Laduraamat_report1