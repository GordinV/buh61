Parameter cWhere
tcKood = '%'+ltrim(rtrim(fltrObjekt.kood))+'%'
tcNimetus = '%'+ltrim(rtrim(fltrObjekt.nimetus))+'%'
cQuery = 'curObjekt'
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
oDb.use(cQuery,'objekt_report1')
*!*	use (cQuery) in 0 alias objekt_report1 nodata
*!*	select objekt_report1
*!*	=requery('objekt_report1')
select objekt_report1