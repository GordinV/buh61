
cString = "select xtype,name from sysobjects where xtype = 'P' or xtype = 'U'"
lResult = sqlexec(gnHandle,cString,'query1')
If lResult < 1
	_Cliptext = cString
	Messagebox('Viga','Kontrol')
	Return
Endif
Select query1
Scan
	Do case
		Case 'USER' $ alltrim(upper(query1.name))
			If query1.xtype = 'P'
				cString = 'GRANT EXECUTE on '+alltrim(query1.name)+;
					' TO DBADMIN'
			Else
				cString = 'GRANT INSERT, UPDATE, DELETE on '+alltrim(query1.name)+;
					' to DBADMIN'
			Endif
			lResult = sqlexec(gnHandle,cString)
		Case 'LIBRARY' $ alltrim(upper(query1.name))
			If query1.xtype = 'P'
				cString = 'GRANT EXECUTE on '+alltrim(query1.name)+;
					' TO DBPEAKASUTAJA'
			Else
				cString = 'GRANT INSERT, UPDATE, DELETE on '+alltrim(query1.name)+;
					' to DBPEAKASUTAJA'
			Endif
			lResult = sqlexec(gnHandle,cString)
		Otherwise
			If query1.xtype = 'P'
				cString = 'GRANT EXECUTE on '+alltrim(query1.name)+;
					' TO DBKASUTAJA,DBPEAKASUTAJA,DBADMIN'
			Else
				cString = 'GRANT INSERT, UPDATE, DELETE on '+alltrim(query1.name)+;
					' to DBKASUTAJA, DBPEAKASUTAJA'
			Endif
			lResult = sqlexec(gnHandle,cString)
	Endcase
	If lResult < 1
		_Cliptext = cString
		Exit
	Else
		If query1.xtype = 'P'
			cString = 'GRANT EXECUTE on '+alltrim(query1.name)+;
				' to DBKASUTAJA,DBPEAKASUTAJA,DBADMIN'
		Else
			cString = 'GRANT SELECT ON '+alltrim(query1.name)+;
				' to DBKASUTAJA,DBPEAKASUTAJA,DBADMIN'
		Endif
		lResult = sqlexec(gnHandle,cString)
	Endif
Endscan
Use in query1
If lResult > 0
	Messagebox('Ok','Kontrol')
Else
	Messagebox('Viga','Kontrol')
Endif


