Parameter tcWhere
if !used('fltrPalkOper')
	return .f.
endif
tcNimetus = +'%'+ltrim(rtrim(fltrPalkOper.nimetus))+'%'
tcIsik = '%'+ltrim(rtrim(fltrPalkOper.isik))+'%'
tcLiik = '%'+ltrim(rtrim(fltrPalkOper.liik))+'%'
tcTund = '%'+ltrim(rtrim(fltrPalkOper.tund))+'%'
tcMaks = '%'+ltrim(rtrim(fltrPalkOper.Maks))+'%'
dKpv1 = iif(empty(fltrPalkOper.kpv1),date(year(date()),month(date()),1),fltrPalkOper.kpv1)
dKpv2 = iif(empty(fltrPalkOper.kpv2),date(year(date()),month(date())+1,1),fltrPalkOper.kpv2)
tnSumma1 = fltrPalkOper.Summa1
tnSumma2 = iif(empty(fltrPalkOper.Summa2),999999999,fltrPalkOper.Summa2)
tcValuuta = '%'

oDb.use('curPalkOper','PalkOper_report1')
select palkoper_report1
DELETE FROM palkoper_report1 WHERE summa = 0
index on upper (left (isik,40)) tag isik
set order to isik
