Parameter tcWhere
LOCAl lcString, tdKpv1, tdKpv2
tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2

Create Cursor tsd_report (aasta Int Default Year(fltrAruanne.kpv2), kuu Int Default Month(fltrAruanne.kpv2),;
	parandus Int Default 0, pohjus c(50), tm N(14,2) Default 0, tm_eri N(14,2) Default 0, sm N(14,2) Default 0,;
	tk N(14,2) Default 0, pm N(14,2) Default 0, tagastus N(14,2) Default 0,;
	reanr c(20), reanimi c(254), Summa N(14,2) Default 0)



TEXT TO lcString NOSHOW 
select sum(po.summa) as arv,
	sum(po.tulumaks) as tm, sum(po.sotsmaks) as sm, sum(po.tootumaks) as tki,  sum(po.pensmaks) as pm, sum(po.tulubaas) as tulubaas, sum(po.tka) as tka
	from palk_oper po
	inner join tooleping t on t.id = po.lepingId
	left outer join library l on l.id = po.libId
	left outer join palk_lib pl on pl.parentId = l.id
	where po.rekvId = ?gRekv
	and po.kpv >= ?tdKpv1 and po.kpv <= ?tdKpv2
	and (not empty(pl.tululiik) or pl.liik = 5)
ENDTEXT

lnError = SQLEXEC(gnhandle, lcString,'qryTSD')
If lnError < 0 Then
	Wait Window 'Viga' Nowait
	Do err
Else
	lnMaksud = 	qryTSD.tm + qryTSD.sm + qryTSD.tki + qryTSD.tka + qryTSD.pm

	Insert Into tsd_report (reanr, reanimi, Summa ) Values ('110', 'Kinnipeetud tulumaks',qryTSD.arv)
	Insert Into tsd_report (reanr, reanimi, Summa ) Values ('114', 'Erijuhtude tulumaks',qryTSD.tm)
	Insert Into tsd_report (reanr, reanimi, Summa ) Values ('115', 'Sotsiaalmaks',qryTSD.sm)
	Insert Into tsd_report (reanr, reanimi, Summa ) Values ('116', 'Töötuskindlustusmakse',qryTSD.tki + qryTSD.tka)
	Insert Into tsd_report (reanr, reanimi, Summa ) Values ('117', 'Kohustusliku kogumispensioni makse',qryTSD.pm)
	Insert Into tsd_report (reanr, reanimi, Summa ) Values ('118', 'Maksukohustus kokku',Iif(lnMaksud >= 0, lnMaksud, 0))
	Insert Into tsd_report (reanr, reanimi, Summa ) Values ('119', 'Kuulub tagastamisele',Iif(lnMaksud < 0, lnMaksud, 0))

Endif
IF USED('qryTSD')
	USE IN qryTSD
ENDIF



Select tsd_report
*brow
