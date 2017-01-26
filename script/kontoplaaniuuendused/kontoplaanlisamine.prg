lcFile = 'c:/avpsoft/files/buh61/tmp/ko3.xls'

If !File(lcFile)
	Messagebox('Viga, failid ei leidnud')
	lError = .T.
Endif


Import From (lcFile) TYPE XL8

gnHandle = SQLCONNECT('NarvaLvPg')
IF gnHandle < 0
	MESSAGEBOX('Viga, uhendus')
	return
ENDIF
* kontoplaan
lnError = SQLEXEC(gnHandle,"select id,kood  from library where library like 'KONTO%'",'tmpKonto')
IF lnError < 0
	SET STEP ON 
	=SQLDISCONNECT(gnHandle)
	return
ENDIF


SELECT ko3
* rohkem ei kehti
SCAN FOR !EMPTY(ko3.h)
	lcKonto = LEFT(ALLTRIM(ko3.h),6)+right(ALLTRIM(ko3.h),2)
	WAIT WINDOW 'Uus konto, kood:'+lcKonto nowait
	SELECT tmpKonto
	LOCATE FOR ALLTRIM(kood) = lcKonto
	IF !FOUND()
		lcString = "select sp_salvesta_library(0, 63, '"+lcKonto+"','"+ALLTRIM(ko3.j)+"','KONTOD','',1,1,0,0,3)"
			
		lnError = SQLEXEC(gnHandle,lcString)
		IF lnError < 0
			SET STEP ON 
			EXIT
		ENDIF
	ENDIF	
ENDSCAN

=SQLDISCONNECT(gnHandle)
