Parameter tnId
If EMPTY(tnId)
	Return .F.
Endif
odB.usE('v_vastisikud','cursor1')
Select cuRsor1
Delete NEXT 1
leRror = odB.cuRsorupdate('cursor1','v_vastisikud')
If leRror=.F.
	Messagebox('Viga', 'Kontrol')
Endif
Return .T.
Endfunc
