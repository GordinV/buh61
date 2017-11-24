Parameter tnId
if empty(tnId)
	return .f.
endif
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
oDb.use('v_library', 'cursor1')
select cursor1
delete next 1
oDb.cursorupdate('cursor1','v_library')
&&use in cursor1
return .t.