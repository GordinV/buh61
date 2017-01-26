Parameter tnId
Local lError
If empty(tnId)
	Return lError
Endif
If vartype(odb) <> 'O'
	Set classlib to classes\classlib
	odb = createobject('db')
Endif
With odb
	.use('v_puudumine', 'cursor1')
	Select cursor1
	Delete next 1
	lError = .cursorupdate('cursor1','v_puudumine')
Endwith
&&use in cursor1
Return lError
