Parameter tnId
local lError
if empty(tnId)
	return .f.
endif
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
with oDb
	.use('v_pv_oper', 'cursor1')
	select cursor1
	delete next 1
	lError = .cursorUpdate('cursor1','v_pv_oper')
endwith
if lError = .t. and used ('v_pv_oper')
	select v_pv_oper
	delete next 1
endif
use in cursor1
return .t.