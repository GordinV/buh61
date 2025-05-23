SET STEP ON 
lcFile = 'c:/avpsoft/files/buh61/dok/kulud2.xls'

*lcFile = GETFILE()

If !File(lcFile)
	Messagebox('Viga, failid ei leidnud')
	lError = .T.
Endif


Import From (lcFile) TYPE XLS SHEET 'Eelarve'

gnHandle = SQLConnect('narvalvpg','vlad')
If gnHandle < 1
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif

*brow
lnstatus = '1'
*tulud

SELECT kulud2
SCAN FOR !EMPTY(a)
	WAIT WINDOW STR(RECNO('kulud2'))+'/'+ STR(RECCOUNT('kulud2')) nowait
	IF a = '4,5,6,15 '
		lnStatus = '2'	
	ENDIF
	lcString = "update library set tun5 = "+lnStatus + " where library = 'TULUDEALLIKAD' and kood = '"+ALLTRIM(kulud2.a)+"'"

	lnError = SQLEXEC(gnHandle,lcString)
	IF lnError < 1
		_cliptext = lcstring
		exit
	ENDIF
	
endscan