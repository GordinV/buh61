Parameter tnId
Local lError
If empty(tnId)
	Return .f.
Endif
If vartype(odb) <> 'O'
	Set classlib to classes\classlib
	odb = createobject('db')
Endif
With odb
	.use ('queryOsakonnad')
	If reccount ('queryOsakonnad') > 0
		lError = .f.
	Else
		lError = .t.
	Endif
	If used ('queryOsakonnad')
		Use in queryOsakonnad
	Endif
	If lError = .t.
		.use('v_library', 'cursor1')
		Select cursor1
		Delete all
		lError = .cursorupdate('cursor1','v_library')
	Endif
Endwith
Return lError
