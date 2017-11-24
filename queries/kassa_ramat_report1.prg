Parameter cWhere
if !used ('fltrSorder')
	select 0
	return .f.
endif
tcNumber = '%'
tcNimi = '%'
tcKassa = '%'
tdKpv1 = date(1900,1,1)
tdKpv2 = fltrAruanne.kpv1 - 1
tnSumma1 = 0
tnSumma2 = 999999999
cQuery = 'print_kassa_ramat'
&&use (cQuery) in 0 alias sorder_report2
oDb.use(cQuery,'kassa_ramat_report1')
select kassa_ramat_report1
