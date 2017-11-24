Parameter tnId
If Empty(tnId)
	Return .F.
Endif
oDb.Use('v_eelarve', 'cursor1')
Select cursor1
If cursor1.rekvid = gRekv
	Delete Next 1
	lError = oDb.cursorupdate('cursor1','v_eelarve')
	Use In cursor1
Endif
Return lError
