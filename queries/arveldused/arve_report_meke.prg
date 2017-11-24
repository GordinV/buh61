Parameter cWhere
If Isdigit(Alltrim(cWhere))
	cWhere = Val(Alltrim(cWhere))
Endif
tnId = Str(cWhere,9)
*!*	cQuery = 'print_arv1'
*!*	oDb.Use(cQuery,'arve_report1')

leRror = odB.Exec("sp_printarv1 ",tnId,"tmpPrintArv1")
If Used('tmpPrintArv1')
	tcTimestamp = Alltrim(tmpPrintArv1.sp_printarv1)
	lcString = "select * from TMP_PRINTARV where rekvid = "+Str(grEkv)+" and timestamp = '"+tcTimestamp+"'"
	leRror = odB.exEcsql(lcString,'arve_report1')
	If  .Not. Empty(leRror) .And. Used('arve_report1')
		Select arve_report1

	Endif
Else
	Select 0
	Return .F.
Endif
