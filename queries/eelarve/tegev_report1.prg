Parameter cWhere
tcKood = '%'+ltrim(rtrim(fltrTegev.kood))+'%'
tcNimetus = '%'+ltrim(rtrim(fltrTegev.nimetus))+'%'
cQuery = 'curTegev'
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
oDb.use (cQuery, 'tegev_report1')
select tegev_report1