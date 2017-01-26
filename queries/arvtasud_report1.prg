Lparameter tcWhere
If used ('fltrArvTasud')
	tcDok = '%'+ltrim(rtrim(fltrArvTasud.dok))+'%'
	tcAsutus = '%'+ltrim(rtrim(fltrArvTasud.asutus))+'%'
	tcNumber = ltrim(rtrim(fltrArvTasud.number))+'%'
	tnSumma1 = iif(empty(fltrArvTasud.summa1),-999999999,fltrArvTasud.summa1)
	tnSumma2 = iif(empty(fltrArvTasud.summa2),999999999,fltrArvTasud.summa2)
	tdKpv1 = iif(empty(fltrArvTasud.kpv1),date(year(date()),1,1),fltrArvTasud.kpv1)
	tdKpv2 = iif(empty(fltrArvTasud.kpv2),date(year(date()),12,31),fltrArvTasud.kpv2)
Else
	If used ('fltrAruanne')
		tcDok = '%'
		tcAsutus = '%'
		If !empty (fltrAruanne.asutusId)
			Select comAsutusRemote
			Locate for id = fltrAruanne.asutusId
			If found ()
				tcAsutus = ltrim(rtrim(comAsutusRemote.nimetus)) + '%'
			Endif
		Endif
		tcNumber = '%'
		tnSumma1 = -999999999
		tnSumma2 = 999999999
		tdKpv1 = iif(empty(fltrAruanne.kpv1),date(year(date()),1,1),fltrAruanne.kpv1)
		tdKpv2 = iif(empty(fltrAruanne.kpv2),date(year(date()),12,31),fltrAruanne.kpv2)
	Endif
Endif
oDb.use('curArvTasud','ArvTasud_report1')
Select ArvTasud_report1
Index on kpv tag kpv
Set order to kpv
