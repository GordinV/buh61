Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif
tnId = cWhere
cQuery = 'print_arv1'
create cursor arve_report1 (number c(20), kpv d,omanik c(254), aadress c(254), nomnimi c(254), reamuud m,;
	 kogus n(12,3), summa y, hind y, tasud y, volg y, kokku y, maksta y, journalid int  )
with oDb
	.use(cQuery,'arve_report')
	go top
	tdKpv2 = arve_report.kpv
	tnAsutus = arve_report.asutusId
	.use('curSummaTasud')
endwith
select arve_report
scan
	insert into arve_report1 (number, kpv ,omanik , aadress, nomnimi, reamuud,hind, kogus , summa, journalid)  values ;
		(arve_report.number, arve_report.kpv, arve_report.asutus, arve_report.aadress, arve_report.nomnimi,;
		arve_report.reamuud, arve_report.hind, arve_report.kogus, arve_report.summa, arve_report.journalid)
	lnArvid = arve_report.id
endscan
select sum (summa) as summa, sum (arvsumma) as arvsumma from curSummaTasud ;
	where arvid <> lnArvId;
	into cursor qryJaak
	
select sum (summa) as summa from curSummaTasud ;
	where arvid = arve_report.id;
	into cursor qryTasud
select arve_report
sum summa to lnKokku

lnJaak =  qryJaak.arvsumma - qryJaak.summa
lnTasud = qryTasud.summa

use in qryJaak
use in qryTasud
use in arve_report 

replace tasud with lnTasud,;
	volg with lnJaak,;
	kokku with lnKokku,;
	maksta with lnKokku + lnJaak - lnTasud in arve_report1
	
select arve_report1