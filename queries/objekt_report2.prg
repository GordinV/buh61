Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif
tnId = cWhere
cQuery = 'v_library'
&&use (cQuery) in 0 alias 'objekt_report1'
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
oDb.use(cQuery,'objekt_report1')
select objekt_report1