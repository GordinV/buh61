gnHandle = SQLCONNECT('narvalvpg','vlad')
IF gnHandle < 0
	MESSAGEBOX('Conn viga')
	return
ENDIF

lcString = 'select id from rekv where parentid <> 9999'

lnResult = SQLEXEC(gnHandle,lcString,'tmpRekv')
IF lnresult < 0 
	SET STEP on
	MESSAGEBOX('Viga p�ringus')
	return	
ENDIF


SELECT tmprekv
SCAN
	WAIT WINDOW STR(tmprekv.id)+'/'+STR(RECNO('tmpRekv'))+'-'+STR(RECCOUNT('tmpRekv')) nowait
	lcString = 'select sp_koosta_saldoandmik('+STR(tmpRekv.id,9)+',DATE(2010,06,30),2010,1)'
	lnResult = SQLEXEC(gnHandle,lcString)
	IF lnresult > 0
		WAIT WINDOW  STR(tmprekv.id)+'-Ok' TIMEOUT 2
	ELSE
		SET STEP ON 		
	endif
ENDSCAN


=SQLDISCONNECT(gnHandle)
