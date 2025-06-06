LOCAL lcFile, cInvNumber, lnConnect, lnError, lnCount
cInvNumber = ''
lnConnect = 0
lnCount = 0

lcFile = 'c:\avpsoft\buh61\temp\VARA.xls'

IMPORT FROM (lcFile) TYPE XLS

TEXT TO lcString NOSHOW
	select relocatePV(?cInvNumber)
ENDTEXT
lnConnect = SQLCONNECT('NarvaLvPg')
IF lnConnect < 1 
	MESSAGEBOX('Viga')
	SET STEP ON 
	RETURN 
ENDIF


	
SELECT vara
SCAN
	WAIT WINDOW 'Import : ' + ALLTRIM(vara.c) + ' ' + ALLTRIM(STR(RECNO('vara'))) + '/' + ALLTRIM(STR(RECCOUNT('vara'))) nowait
	cInvNumber = ALLTRIM(vara.c)
	IF !EMPTY(cInvNumber) 
		lnError = SQLEXEC(lnConnect, lcString)
		
		IF lnError < 0 
			MESSAGEBOX('Viga')
			_cliptext = lcString
			SET STEP ON 
			exit
		ENDIF
		lnCount = lnCount + 1
		
	ENDIF

ENDSCAN

=SQLDISCONNECT(lnConnect)

MESSAGEBOX('Kokku import: ' + STR(lnCount))
