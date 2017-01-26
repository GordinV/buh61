Parameter tcWhere
if vartype(oDb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
if !used('fltrPuudumine')
	return .f.
endif
select curPuudumine
tdKpv1_1 = iif (empty (fltrPuudumine.kpv1_1), date (yeAR(date()),1,1),fltrPuudumine.kpv1_1)
tdKpv1_2 = iif (empty (fltrPuudumine.kpv1_2),date(),fltrPuudumine.kpv1_2)
tdKpv2_1 = iif (empty (fltrPuudumine.kpv2_1), date (yeAR(date()),1,1),fltrPuudumine.kpv2_1)
tdKpv2_2 = iif (empty (fltrPuudumine.kpv2_2),date()+30,fltrPuudumine.kpv2_2)
tnpaevad1 = iif (empty (fltrPuudumine.paevad1),0,fltrPuudumine.paevad1)
tnpaevad2 = iif (empty (fltrPuudumine.paevad2),9999,fltrPuudumine.paevad2)
tcAmet = '%'+ltrim(rtrim(fltrPuudumine.amet))+'%'
tcisik = '%'+ltrim(rtrim(fltrPuudumine.isik))+'%'
tcPohjus = '%'+ltrim(rtrim(fltrPuudumine.pohjus))+'%'
tcLiik = '%'+ltrim(rtrim(fltrPuudumine.liik))+'%'
oDb.use ('curPuudumine','puudumine_report1')
select puudumine_report1
