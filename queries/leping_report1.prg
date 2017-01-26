Parameter cWhere
	if vartype(oDb) <> 'O'
		set classlib to classes\classlib
		oDb = createobject('db')
	endif
tcNumber = '%'+ltrim(rtrim(fltrLepingud.number))+'%'
tcSelgitus = '%'+ltrim(rtrim(fltrLepingud.selgitus))+'%'
tcAsutus = '%'+ltrim(rtrim(fltrLepingud.asutus))+'%'
dKpv1 = iif(empty(fltrLepingud.kpv1),date(year(date()),1,1),fltrLepingud.kpv1)
dKpv2 = iif(empty(fltrLepingud.kpv2),date(year(date()),12,31),fltrLepingud.kpv2)
oDb.use('curLepingud','Leping_report1')
select Leping_report1
