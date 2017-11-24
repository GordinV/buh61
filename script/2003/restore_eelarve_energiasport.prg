Set Step On
gnHandle = SQLConnect('narva','vladislav','490710')
gnHandle1 = SQLConnect('narvasql')
lcString = 'select * from eelarve where rekvid = 16'
lerror=SQLEXEC(gnHandle,lcString,'qryEelarve')
lerror=SQLEXEC(gnHandle1,lcString,'qryEelarve1')
Select * From qryEelarve1 Where Id Not In (Select Id From qryEElarve) Into Cursor qry2
lerror=SQLEXEC(gnHandle,'begin transaction')
Scan
	lcString = "insert into eelarve (rekvid, allikasid, summa, kood3, kood4, tunnus) values ("+;
		STR(qry2.rekvid)+","+Str(qry2.allikasid)+","+Str(qry2.Summa,14,4)+","+;
		STR(qry2.kood3)+","+Str(qry2.kood4)+","+Str(qry2.tunnus)+")"
	lerror=SQLEXEC(gnHandle,lcString)
	If lerror < 1
		Exit
	Endif
Endscan
If lerror < 1
	lerror=SQLEXEC(gnHandle,'rollback')

Else
	lerror=SQLEXEC(gnHandle,'commit')

Endif
=SQLDISCONNECT(gnHandle)
=SQLDISCONNECT(gnHandle1)
