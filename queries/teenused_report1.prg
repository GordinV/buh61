Parameter cWhere
If !Used('curTeenused')
	tnliik = fltrTeenused.liik
	tcNimetus = '%'+Rtrim(Ltrim(fltrTeenused.nimetus))+'%'
	tcRegnum = '%'+Rtrim(Ltrim(fltrTeenused.regnum))+'%'
	tcKood = '%'+Rtrim(Ltrim(fltrTeenused.kood))+'%'
	tcAsutus = '%'+Rtrim(Ltrim(fltrTeenused.asutus))+'%'
	tcNumber = Ltrim(Rtrim(fltrTeenused.Number))+'%'
	tdKpv1 = Iif(Empty(fltrTeenused.kpv1),Date(Year(Date()),Month(Date()),1),fltrTeenused.kpv1)
	tdKpv2 = Iif(Empty(fltrTeenused.kpv2),Date(),fltrTeenused.kpv2)
	tnSumma1 = fltrTeenused.Summa1
	tnSumma2 = Iif(Empty(fltrTeenused.Summa2),999999999,fltrTeenused.Summa2)
	tcUritus = '%'+Rtrim(Ltrim(fltrTeenused.uritus))+'%'
	tcProj = '%'+Rtrim(Ltrim(fltrTeenused.proj))+'%'
	tcValuuta = Rtrim(Ltrim(fltrTeenused.valuuta))+'%'	
	tcKbm = Rtrim(Ltrim(fltrTeenused.kbm))+'%'
	Select curTeenused
	cQuery = 'curTeenused'
	oDb.Use(cQuery,'teenused_report1')
Else	
	SELECT * from curTeenused INTO CURSOR teenused_report1
Endif


Select teenused_report1
