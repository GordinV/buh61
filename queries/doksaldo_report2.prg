Parameter cWhere
create cursor doksaldo_report1 (number c(20), kpv d, asutus c(120),;
	tahtaeg d, tasud d null, tasudok c(20) null, summa y, arv int, saldo y, opt int)
if !empty (cWhere) and isdigit(alltrim(cWhere))
	tnid = val(alltrim(cWhere))
else
	if used ('curAsutused')
		tnId = curAsutused.id
	endif
ENDIF
SET STEP ON 
oDb.use ('v_asutus','qryAsutus')
tcAsutus = ltrim(rtrim(qryAsutus.nimetus))+'%'
tcNumber = '%%'
tdKpv1 = gomonth(date(year(date()),1,1),-1200)
tdKpv2 = gomonth(date(year(date()),1,1),1200)
tdTaht1 = gomonth(date(year(date()),1,1),-1200)
tdTaht2 = gomonth(date(year(date()),1,1),1200)
tnSumma1 = -9999999999
tnSumma2 = 999999999
tdTasud1 = gomonth(date(year(date()),1,1),-1200)
tdTasud2 = gomonth(date(year(date()),1,1),1200)
oDb.use('curArved','qryArv')
select qryArv
scan
	insert into doksaldo_report1 (number, kpv, asutus, tahtaeg, tasud, tasudok, summa, opt);
		values (qryarv.number, qryarv.kpv, qryAsutus.nimetus, qryarv.tahtaeg, qryarv.tasud, qryarv.tasudok, qryarv.summa, 1)
endscan
tcDok = '%%'
tcAsutus = ltrim(rtrim(qryAsutus.nimetus))+'%'
tcNumber = '%%'
tnSumma1 = -99999999999
tnSumma2 = 99999999999
tdKpv1 = date(year(date())-10,1,1)
tdKpv2 = date(year(date())+10,12,31)
oDb.use('curArvTasud','qryArvTasud')
select qryArvTasud
scan
	insert into doksaldo_report1 (number, kpv, asutus,  summa, opt);
		values (qryArvTasud.dok, qryArvTasud.kpv, qryAsutus.nimetus,  qryArvTasud.summa, 2)
endscan
use in qryArvTasud
use in qryArv
use in qryAsutus
select doksaldo_report1
sum summa for opt = 1 to lnDeebet
sum summa for opt = 2 to lnKreedit
update doksaldo_report1 set saldo = lnDeebet - lnKreedit
select doksaldo_report1
