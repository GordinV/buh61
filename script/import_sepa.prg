*!*	lcFile = 'Z:\avpsoft\temp\IBAN\meke.dbf'
*!*	USE (lcFile) IN 0 ALIAS meke



*!*	CREATE CURSOR sepa (aa c(30), sepa c(30))
*!*	APPEND FROM dbf('meke') 
*!*	SELECT sepa

SELECT old as aa, new as sepa from meke INTO cursor sepa


gnhandle = SQLCONNECT('meke')
IF gnHandle < 0
	MESSAGEBOX('Viga, uhendus')
	return
ENDIF
lnCount = 0

SELECT sepa
GO top
SET STEP ON 
SCAN FOR !EMPTY(sepa) and aa <> '0' 
	WAIT WINDOW STR(RECNO('sepa'))+'/'+STR(RECCOUNT('sepa')) nowait
	lcString = "select id from asutusaa where aa = '"+ALLTRIM((sepa.aa))+"'"
	lnError = SQLEXEC(gnHandle,lcString,'tmpAa')
	IF lnError > 0 AND RECCOUNT('tmpAa') > 0 
		SELECT tmpAa
		SCAN
*			WAIT 'updating :' + (sepa.aa)+'->'+sepa.sepa nowait
			lcString = "update asutusaa set aa = '"+ALLTRIM(sepa.sepa)+"' where id = " + STR(tmpAa.id)
			lnError = SQLEXEC(gnHandle,lcString)
			IF lnError < 0
				SET STEP ON 
				exit
			endif
		ENDSCAN		
		IF lnError < 0
			exit
		ENDIF
		
	ENDIF
	lnCount = lnCount + 1
*!*		IF lnCount > 3
*!*			exit
*!*		endif
endscan
RETURN

=SQLDISCONNECT(gnHandle)