Parameter cWhere
if !used ('fltrKorder')
	select 0
	return .f.
endif
tcNumber = '%'+Rtrim(Ltrim(fltrKorder.Number))+'%'
tcNimi = '%'+Rtrim(Ltrim(fltrKorder.nimi))+'%'
tcKassa = '%'+Ltrim(Rtrim(fltrKorder.kassa))+'%'
tdKpv1 = fltrKorder.kpv1
tdKpv2 = Iif(Empty(fltrKorder.kpv2),Date()+365*10,fltrKorder.kpv2)
tnDb1 = fltrKorder.db1
tnDb2 = Iif(Empty(fltrKorder.db2),999999999,fltrKorder.db2)
tnKr1 = fltrKorder.kr1
tnKr2 = Iif(Empty(fltrKorder.kr2),999999999,fltrKorder.kr2)
tnTyyp = fltrKorder.tyyp
tcValuuta = UPPER(Ltrim(Rtrim(fltrKorder.kassa)))+'%'
oDb.use('curKorder','sorder_report2')
select sorder_report2
INDEX ON kpv TAG kpv
SET ORDER TO kpv

