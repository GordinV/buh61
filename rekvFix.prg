gnArhiiv = SQLCONNECT('narvalv2015')
IF gnArhiiv < 1
	SET STEP ON 
	return	
ENDIF

gnDb = SQLCONNECT('narvaLvPg')

IF gnDb < 1
	SET STEP ON 
	return	
ENDIF


lnError = SQLEXEC(gnDb,'select id, nimetus from rekv where id < 119', 'tmpRekv')

SELECT tmpRekv
SCAN
	lnError = SQLEXEC(gnArhiiv, "update rekv set nimetus = '"  + ALLTRIM(tmpRekv.nimetus) + "' where id = " + STR(tmpRekv.id))
ENDSCAN


SQLDISCONNECT(gnDb)
SQLDISCONNECT(gnArhiiv)
