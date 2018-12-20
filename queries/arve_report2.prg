Parameter cWhere
tcAsutus = '%'+rtrim(ltrim(fltrArved.asutus))+'%'
tcNumber = '%'+ltrim(rtrim(fltrArved.number))+'%'
tdKpv1 = iif(empty(fltrArved.kpv1),date(year(date()),1,1),fltrArved.kpv1)
tdKpv2 = iif(empty(fltrArved.kpv2),date(year(date()),12,31),fltrArved.kpv2)
tdTaht1 = iif(empty(fltrArved.taht1),date(year(date())-10,1,1),fltrArved.taht1)
tdTaht2 = iif(empty(fltrArved.taht2),date()+365*10,fltrArved.taht2)
tnSumma1 = fltrArved.Summa1
tnSumma2 = iif(empty(fltrArved.Summa2),999999999,fltrArved.Summa2)
tdTasud1 = iif(empty(fltrArved.Tasud1), date(year(date())-2,1,1),fltrArved.Tasud1)
tdTasud2 = iif(empty(fltrArved.Tasud2),date()+365*10,fltrArved.Tasud2)
tcAmetnik = '%'+LTRIM(RTRIM(fltrArved.ametnik))+'%'
tnLiik  = fltrArved.liik
cQuery = 'printarved'
oDb.use(cQuery,'arve_report2')
SELECT arve_report2
index on id tag id
index on number tag number additive
index on kpv tag kpv additive
index on left(upper(asutus),40) tag asutus additive
index on summa tag summa additive
index on tasud tag tasud additive
index on tahtaeg tag tahtaeg additive
set order to kpv
&&use (cQuery) in 0 alias arve_report2

IF USED('curArved')
	SELECT curArved
	lcTag = TAG()
	select arve_report2

	IF !EMPTY(lcTag) AND lcTag <> 'JAAK'
		set order to (lcTag)
	endif
endif