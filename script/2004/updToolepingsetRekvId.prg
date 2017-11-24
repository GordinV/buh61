SET STEP ON 
gnhandle = SQLConnect('njlvpg','vlad','490710')
If gnhandle < 1
	Messagebox('Viga')
	Return
Endif
lcstring = " select l.rekvid, t.id from asutus a inner join tooleping t on a.id = t.parentid inner join library l on t.ametid = l.id"
lError = SQLEXEC(gnhandle,lcstring,'qryT')
If lError < 1
	Messagebox('Viga'+lcstring)
	_Cliptext = lcstring
	Return
Endif
=SQLEXEC(gnhandle,'begin work')
Select qryT
Scan
	Wait Window Str(Recno('qryT'))+'-'+Str(Reccount('qryT')) Nowait
	lcstring = "update tooleping set rekvId = "+Str(qryT.rekvid)+" where id = "+Str(qryT.Id)
	lError = SQLEXEC(gnhandle,lcstring)
	If lError < 1
		Messagebox('Viga'+lcstring)
		_Cliptext = lcstring
		Exit
	Endif

Endscan
If lError > 0
	=SQLEXEC(gnhandle,'commit work')
	MESSAGEBOX('Ok')
Else
	=SQLEXEC(gnhandle,'rollback work')
	MESSAGEBOX('Viga')
Endif
=SQLDISCONNECT(gnhandle)
