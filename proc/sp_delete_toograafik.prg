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
	.use ('V_TOOGRAF')
	Delete all
	lError = .cursorupdate('v_toograf')
	if used ('v_toograf')
		use in v_toograf
	endif
Endwith
Return lError
