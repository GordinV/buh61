Parameter tnId
If empty(tnId)
	Return .f.
Endif
If vartype(odb) <> 'O'
	Set classlib to classes\classlib
	odb = createobject('db')
Endif
With odb
	.use('v_teenused')
	Select v_teenused
	Delete next 1
	.cursorupdate('v_teenused')
Endwith
Use in v_teenused
Return .t.
