gnHandle = SQLCONNECT('njlv2011')

IF gnHandle < 0
	MESSAGEBOX('Viga, uhenduses')
	return
ENDIF

* asutuste nimekiri subkontodes
lcString = "select id from library where kood = '203570' and library = 'KONTOD'"
lnError = SQLEXEC(gnHandle,lcString,'tmp')

IF lnError < 0 OR !USED('tmp') OR RECCOUNT('tmp') < 1
	SET STEP ON 
	return
ENDIF

lnKontoId = tmp.id

lcString = "select asutusId from subkonto where kontoid = "+STR(lnKontoId,9)

lnError = SQLEXEC(gnHandle,lcString,'tmpAsutus')



=SQLDISCONNECT(gnHandle)
