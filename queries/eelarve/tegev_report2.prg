Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif
tnId = cWhere
cQuery = 'v_library'
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
oDb.use (cQuery,'tegev_report1')
select tegev_report1