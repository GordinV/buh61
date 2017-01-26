gnHandle = SQLCONNECT('hooldekodu','vlad')
IF gnHandle < 0
	MESSAGEBOX('Viga, uhendus')
	return
ENDIF
gnHandle2012 = SQLCONNECT('sahooldekodu2012','vlad')
IF gnHandle2012 < 0
	MESSAGEBOX('Viga, uhendus')
	return
ENDIF
lcString = "select * from palk_jaak where aasta = 2012 and kuu = 12"
lnError = SQLEXEC(gnHandle2012, lcString,'qryjaak')
IF lnError < 0 
	_cliptext = lcstring
	MESSAGEBOX('Viga')
	return
ENDIF

SELECT qryJaak
SCAN
	WAIT WINDOW STR(RECNO('qryJaak'))+'/'+STR(RECCOUNT('qryJaak')) nowait
	lcString = "update palk_jaak set jaak = "+STR(qryJaak.jaak/15.6466,16,4)+;
		" where lepingid = "+STR(qryJaak.lepingid)+" and kuu = 12 and aasta = 2012"
	lnError = SQLEXEC(gnHandle,lcString)
	IF lnError < 0
		_cliptext = lcstring
		MESSAGEBOX('Viga')
		exit
	ENDIF		
ENDSCAN


=SQLDISCONNECT(gnHandle)
=SQLDISCONNECT(gnHandle2012)