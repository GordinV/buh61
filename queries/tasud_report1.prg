Parameter cWhere
tcDok = '%'+ltrim(rtrim(fltrArvTasud.dok))+'%'
tcAsutus = '%'+ltrim(rtrim(fltrArvTasud.asutus))+'%'
tcNumber = ltrim(rtrim(fltrArvTasud.number))
tnSumma1 = iif(empty(fltrArvTasud.summa1),-999999999,fltrArvTasud.summa1)
tnSumma2 = iif(empty(fltrArvTasud.summa2),999999999,fltrArvTasud.summa2)
tdKpv1 = iif(empty(fltrArvTasud.kpv1),date(year(date()),1,1),fltrArvTasud.kpv1)
tdKpv2 = iif(empty(fltrArvTasud.kpv2),date(year(date()),12,31),fltrArvTasud.kpv2)
cQuery = 'printArvtasud'
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
oDb.use (cQuery,'tasud_report1')
select tasud_report1