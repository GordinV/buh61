Parameter tcWhere
If !Used('fltrPalkJaak')
	Return .F.
Endif
tnKuu1 = Iif(Empty(fltrPalkJaak.kuu1),-999999999,fltrPalkJaak.kuu1)
tnKuu2 = Iif(Empty(fltrPalkJaak.kuu2),999999999,fltrPalkJaak.kuu2)
tnAasta1 = Iif(Empty(fltrPalkJaak.aasta1),-999999999,fltrPalkJaak.aasta1)
tnAasta2 = Iif(Empty(fltrPalkJaak.aasta2),999999999,fltrPalkJaak.aasta2)
tnArv1 = Iif(Empty(fltrPalkJaak.arv1),-999999999,fltrPalkJaak.arv1)
tnArv2 = Iif(Empty(fltrPalkJaak.arv2),999999999,fltrPalkJaak.arv2)
tnKinni1 = Iif(Empty(fltrPalkJaak.kinni1),-999999999,fltrPalkJaak.kinni1)
tnKinni2 = Iif(Empty(fltrPalkJaak.kinni2),999999999,fltrPalkJaak.kinni2)
tnTulu1 = Iif(Empty(fltrPalkJaak.Tulu1),-999999999,fltrPalkJaak.Tulu1)
tnTulu2 = Iif(Empty(fltrPalkJaak.Tulu2),999999999,fltrPalkJaak.Tulu2)
tnSots1 = Iif(Empty(fltrPalkJaak.Sots1),-999999999,fltrPalkJaak.Sots1)
tnSots2 = Iif(Empty(fltrPalkJaak.Sots2),999999999,fltrPalkJaak.Sots2)
tnJaak1 = Iif(Empty(fltrPalkJaak.Jaak1),-999999999,fltrPalkJaak.Jaak1)
tnJaak2 = Iif(Empty(fltrPalkJaak.Jaak2),999999999,fltrPalkJaak.Jaak2)
tdKpv1 = Date(tnAasta1, tnKuu1, 1)
tdKpv2 = Gomonth(Date(tnAasta2, tnKuu2, 1),1) - 1
tcNimetus = '%'+Rtrim(Ltrim(fltrPalkJaak.nimetus))+'%'
tnParent = 3

lcOsakond = ''
If !Empty(fltrPalkJaak.osakond)
	Select comTunnusRemote
	Locate For Alltrim(Upper(kood)) = Alltrim(Upper(fltrPalkJaak.osakond))
	If Found()
		lcOsakond = Ltrim(Rtrim(comTunnusRemote.nimetus))
	Endif

Endif

Create Cursor palkJaak_report1 (isikid int, isik c(254), isikukood c(20), period c(30) Default Dtoc(tdKpv1)+".a. - "+Dtoc(tdKpv2)+".a.",;
	arv Y, tasu Y, tulumaks Y,  tki Y, muud Y, sots Y, tka Y, jaak Y, kinni Y, kKinni Y, pm Y, tunnus c(254) Default lcOsakond )
Index On Left(Upper(isik),40) Tag isik
Set Order To isik
Select palkJaak_report1
tcAmet = '%'
tcisik = '%'+Rtrim(Ltrim(fltrPalkJaak.nimetus))+'%'
tcOsakond = '%'+Rtrim(Ltrim(fltrPalkJaak.osakond))+'%'
oDb.Use('curpalkOper3')
SELECT curPalkOper3
tnParentRekvId = 9

oDb.Use(Iif(Empty (fltrPalkJaak.Status),'curPalkJaak','curPalkJaak2'),'qryPalkJaak')
Select Distinct isik, isikukood, isikId From curPalkoper3 Into Cursor qryisik
Select palkJaak_report1
Append From Dbf('qryisik')

Scan
	Select curPalkoper3
	Sum (Summa) For liik = 1 And isikId = palkJaak_report1.isikId To lnSumma
	If lnSumma <> 0
		Replace arv With lnSumma In palkJaak_report1
	Endif
	Sum (Summa) For liik = 2 And isikid = palkJaak_report1.isikId To lnSumma
	If lnSumma <> 0
		Replace kinni With lnSumma In palkJaak_report1
	Endif
	Sum (Summa) For liik = 3 And isikId = palkJaak_report1.isikId To lnSumma
	If lnSumma <> 0
		Replace muud With lnSumma In palkJaak_report1
	Endif
	Sum (Summa) For liik = 4 And isikId = palkJaak_report1.isikId To lnSumma
	If lnSumma <> 0
		Replace tulumaks With lnSumma In palkJaak_report1
	Endif
	Sum (Summa) For liik = 5 And isikId = palkJaak_report1.isikId To lnSumma
	If lnSumma <> 0
		Replace sots With lnSumma In palkJaak_report1
	Endif
	Sum (Summa) For liik = 6 And isikId = palkJaak_report1.isikId To lnSumma
	If lnSumma <> 0
		Replace tasu With lnSumma In palkJaak_report1
	Endif
	Sum (Summa) For liik = 8 And isikId = palkJaak_report1.isikId To lnSumma
	If lnSumma <> 0
		Replace pm With lnSumma In palkJaak_report1
	Endif
	Sum (Summa) For liik = 7 And asutusest = 0 And isikId = palkJaak_report1.isikId To lnSumma
	If lnSumma <> 0
		Replace tki With lnSumma In palkJaak_report1
	Endif
	Sum (Summa ) For liik = 7 And asutusest = 1 And isikId = palkJaak_report1.isikId To lnSumma
	If lnSumma <> 0
		Replace tka With lnSumma In palkJaak_report1
	ENDIF
	Select qryPalkJaak
	Sum jaak For (qryPalkJaak.regkood) = palkJaak_report1.isikukood AND kuu = tnKuu2 AND aasta = tnAasta2 To lnSumma

*	LOCATE FOR qryPalkJaak.regkood = palkJaak_report1.isikukood AND kuu = tnKuu2 AND aasta = tnAasta2
	Replace jaak With lnSumma In palkJaak_report1
	Replace kKinni With palkJaak_report1.kinni+palkJaak_report1.tulumaks+palkJaak_report1.tasu+palkJaak_report1.pm+palkJaak_report1.tki In palkJaak_report1
Endscan
Use In qryisik
Select palkJaak_report1
