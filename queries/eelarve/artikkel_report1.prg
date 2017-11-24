Parameter cWhere
tcKood = '%'+ltrim(rtrim(fltrArtikkel.kood))+'%'
tcNimetus = '%'+ltrim(rtrim(fltrArtikkel.nimetus))+'%'
cQuery = 'curArtikkel'
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
oDb.use(cQuery,'artikkel_report1')
&&use (cQuery) in 0 alias Artikkel_report1 nodata
select Artikkel_report1
&&=requery('Artikkel_report1')
