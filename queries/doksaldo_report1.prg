Parameter cWhere
create cursor doksaldo_report1 (number c(20), kpv d, asutus c(120),;
	tahtaeg d, tasud d null, tasudok c(20) null, summa y, arv int, saldo y, opt int)
if !empty (cWhere) and isdigit(alltrim(cWhere))
	tnid = val(alltrim(cWhere))
else
	if used ('curArved')
		tnId = curArved.id
	endif
Endif
oDb.use ('v_arv','qryArv')
tnId = qryarv.asutusId
oDb.use ('v_asutus','qryAsutus')
insert into doksaldo_report1 (number, kpv, asutus, tahtaeg, tasud, tasudok, summa, opt);
	values (qryarv.number, qryarv.kpv, qryAsutus.nimetus, qryarv.tahtaeg, qryarv.tasud, qryarv.tasudok, qryarv.summa, 1)

oDb.use('curArvTasud','qryArvTasud',.t.)
tcDok = '%%'
tcAsutus = '%%'
tcNumber = ltrim(rtrim(qryarv.number))
tnSumma1 = -99999999999
tnSumma2 = 99999999999
tdKpv1 = date(year(date())-10,1,1)
tdKpv2 = date(year(date())+10,12,31)
oDb.dbreq('qryArvTasud',gnHandle,'curArvTasud')
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