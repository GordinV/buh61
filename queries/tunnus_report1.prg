Parameter cWhere
tcKood = '%'+ltrim(rtrim(fltrTunnus.kood))+'%'
tcNimetus = '%'+ltrim(rtrim(fltrTunnus.nimetus))+'%'
cQuery = 'curTunnus'
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
oDb.use (cQuery, 'Tunnus_report1')
select Tunnus_report1