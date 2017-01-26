Parameter tcWhere
* TSD 2015 lisa 1b

Local lcString, tdKpv1, tdKpv2, l_parent
tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2
l_parent = Iif(Empty(fltrAruanne.kond),999999,gRekv)
l_1480 = 0

Create Cursor tsd_report (isikukood c(20), nimi c(254), v1320 c(20), v1330 N(14,2) , v1340 int,;
	v1350 int, v1360 c(20) DEFAULT '', v1370 N(14,2) , v1380 N(14,2) , v1390 N(14,2) , ;
	v1400 N(14,2) , v1410 N(14,2) ,	v1420 N(14,2) , v1430 N(14,2) , v1440 N(14,2) , ;
	v1450 n(14,2) , v1460 c(20), v1470_610 N(14,2) , v1470_620 N(14,2) , v1470_630 N(14,2) , v1470_640 N(14,2) ,;
	v1470 N(14,2) , v1480 n(14,2) ,  v1500 N(14,2) , v1510 N(14,2) , v1520 N(14,2) ,;
	v1530 N(14,2) , v1540 N(14,2) , v1550 N(14,2)  )
	


TEXT TO lcString NOSHOW
select a.regkood as isikukood, a.nimetus as isik,
	sum(summa) as summa, sum(tulumaks) as tm, sum(sotsmaks) as sm, sum(tootumaks) as tki, sum(pensmaks) as pm, sum(tka) as tka, sum(tulubaas) as tulubaas,
	pl.tululiik,pl.liik,
	coalesce(l.tun1,0) as tm_maar, coalesce(l.tun4,0) as tk_arv, coalesce(l.tun5,0) as pm_arv, coalesce(l.tun1,0) as tm_arv, coalesce(l.tun2,0) as sm_arv,
	sum(case when tasuliik = 2 then t.palk else 0 end ) as palk_maar, t.riik, po.period, po.pohjus
	from tooleping t
	inner join asutus a on a.id = t.parentid
	inner join palk_oper po on po.lepingid = t.id
	inner join palk_lib pl on pl.parentid = po.libId
	inner join rekv on rekv.id = po.rekvid
	left outer join library l on l.kood = pl.tululiik and l.library = 'MAKSUKOOD'
	where po.kpv >= ?tdKpv1 and po.kpv <= ?tdKpv2
	and period is not null
	and (rekv.id = ?gRekv or rekv.parentId = ?l_parent)
	group by a.regkood, a.nimetus, pl.tululiik, l.tun1, l.tun4, l.tun5, l.tun1, l.tun2, t.riik, pl.liik, po.period, po.pohjus
ENDTEXT

lnError = SQLEXEC(gnhandle, lcString,'qryTSD')
If lnError < 0 Then
	Wait Window 'Viga' Nowait
	Do err
Else
	Select isikukood, isik, Sum(Summa) As Summa, Sum(tm) As tm, Sum(sm) As sm, Sum(tki) As tki, Sum(tka) As tka,;
		sum(pm) As pm, Sum(tulubaas) As tulubaas, tululiik, palk_maar, riik, sm_arv, tk_arv, period, pohjus ;
		FROM qryTsd ;
		WHERE !Isnull(qryTsd.tululiik) And  qryTsd.tululiik <> '';
		GROUP By isikukood, isik, tululiik, palk_maar, riik, sm_arv, tk_arv, period, pohjus ;
		INTO Cursor curTSD
	Select curTSD
	Scan
* 1090
		Select Sum(qryTsd.sm) As sm From qryTsd Where qryTsd.liik = 5 And isikukood = curTSD.isikukood And Isnull(qryTsd.period) Into Cursor tmpMaksud

		l_1090 = Iif(Reccount('tmpMaksud') > 0, tmpMaksud.sm, 0)
* 1200, 1210, 1220
		Select Sum(Summa *  curTSD.sm_arv) As Summa, Sum(qryTsd.sm) As sm, Sum(qryTsd.tm) As tm, Sum(qryTsd.tki) As tki, ;
			sum(qryTsd.tka) As tka, Sum(qryTsd.pm) As pm ;
			FROM qryTsd Where qryTsd.liik = 1 And isikukood = curTSD.isikukood Into Cursor tmpMaksud

		l_1480 = (ABS(curTSD.summa) -  ABS(curTSD.pm) - ABS(curTSD.tki)) * 0.20

		INSERT INTO tsd_report (isikukood, nimi,v1320, v1330, v1340, v1350, v1360, v1370,;
			v1380, v1390, v1400, v1410, v1420, v1430,;
			v1440, v1450, v1460, v1470, v1480, ;
			v1500, v1510, v1520, v1530, v1540, v1550) ;
			values (curTSD.isikukood, curTSD.isik,curTSD.tululiik, curTSD.summa, Year(curTSD.period), MONTH(curTSD.period),curTsd.pohjus, curTSD.Summa * curTSD.sm_arv,;
			Iif(curTSD.Summa < 0,ABS(curTSD.Summa),0), Iif(curTSD.Summa > 0,ABS(curTSD.Summa),0), ABS(l_1090), ABS(curTSD.sm), ABS(curTSD.pm), ABS(curTSD.summa) * curTSD.tk_arv,;
			ABS(curTSD.tki), ABS(curTSD.tka), '610', ABS(curTSD.tulubaas), l_1480, ;
			ABS(tmpMaksud.summa), ABS(tmpMaksud.sm), ABS(tmpMaksud.pm), ABS(tmpMaksud.tki), ABS(tmpMaksud.tka), l_1480)

	Endscan

Endif


If Used('qryTSD')
	Use In qryTsd
Endif



Select tsd_report
*brow
