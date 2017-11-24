Parameter cWhere
if !used ('fltrKorder')
	select 0
	return .f.
endif
tcNumber = '%'+rtrim(ltrim(fltrKorder.number))+'%'
tcNimi = '%'+rtrim(ltrim(fltrKorder.nimi))+'%'
tcKassa = '%'+ltrim(rtrim(fltrKorder.kassa))+'%'
tdKpv1 = fltrKorder.kpv1
tdKpv2 = iif(empty(fltrKorder.kpv2),date()+365*10,fltrKorder.kpv2)
tnSumma1 = fltrKorder.Summa1
tnSumma2 = iif(empty(fltrKorder.Summa2),999999999,fltrKorder.Summa2)
cQuery = 'print_korder2'
oDb.use(cQuery,'sorder_report2')
select sorder_report2
