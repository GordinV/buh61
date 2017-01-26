Parameter cWhere
if empty(cWhere) 
	return .f.
endif
if vartype(cWhere) = 'C'
	tnId = val(alltrim(cWhere))
else
	tnId = cWhere
endif
cQuery = 'printArvtasu'
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
oDb.use (cQuery,'tasud_report1') 
select tasud_report1