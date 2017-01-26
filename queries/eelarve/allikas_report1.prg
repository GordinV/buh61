Parameter cWhere
tcKood = '%'+ltrim(rtrim(fltrAllikad.kood))+'%'
tcNimetus = '%'+ltrim(rtrim(fltrAllikad.nimetus))+'%'
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
oDb.use('curAllikad','allikas_report1')
&&use (cQuery) in 0 alias allikas_report1 nodata
select allikas_report1
&&=requery('allikas_report1')
select allikas_report1