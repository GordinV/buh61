gnHandle =  SQLCONNECT('narvalvpg','vlad','490710')
IF gnhandle < 1
	Messagebox ('Viga uhend.')
	return
endif
TEXT 
* library
WAIT WINDOW 'SELECTING KONTOD'

lcString = "select * from library where library = 'KONTOD'"
lcTbl = 'qryKontod'
lError = SQLEXEC(gnHandle,lcString)

IF lError < 1
	MESSAGEBOX('Viga')
	return
ENDIF

lcstring = "SELECT * from sqlresult INTO TABLE "+lctbl
&lcString

WAIT WINDOW 'SELECTING ALLIKAD'

lcString = "select * from library where library = 'ALLIKAD'"
lcTbl = 'qryALLIKAD'
lError = SQLEXEC(gnHandle,lcString)

IF lError < 1
	MESSAGEBOX('Viga')
	return
ENDIF

lcstring = "SELECT * from sqlresult INTO TABLE "+lctbl
&lcString

WAIT WINDOW 'SELECTING TEGEV'

lcString = "select * from library where library = 'TEGEV'"
lcTbl = 'qryTEGEV'
lError = SQLEXEC(gnHandle,lcString)

IF lError < 1
	MESSAGEBOX('Viga')
	return
ENDIF

lcstring = "SELECT * from sqlresult INTO TABLE "+lctbl
&lcString

WAIT WINDOW 'SELECTING TP'

lcString = "select * from library where library = 'TP'"
lcTbl = 'qryTP'
lError = SQLEXEC(gnHandle,lcString)

IF lError < 1
	MESSAGEBOX('Viga')
	return
ENDIF

lcstring = "SELECT * from sqlresult INTO TABLE "+lctbl
&lcString


WAIT WINDOW 'SELECTING TULUDEALLIKAD'

lcString = "select * from library where library = 'TULUDEALLIKAD'"
lcTbl = 'qryTULUDEALLIKAD'
lError = SQLEXEC(gnHandle,lcString)

IF lError < 1
	MESSAGEBOX('Viga')
	return
ENDIF

lcstring = "SELECT * from sqlresult INTO TABLE "+lctbl
&lcString

WAIT WINDOW 'SELECTING PALK'

lcString = "select * from library where library = 'PALK' and rekvid = 1"
lcTbl = 'qryPALK'
lError = SQLEXEC(gnHandle,lcString)

IF lError < 1
	MESSAGEBOX('Viga')
	return
ENDIF

lcstring = "SELECT * from sqlresult INTO TABLE "+lctbl
&lcString

ENDTEXT

WAIT WINDOW 'SELECTING PALK_LIB'

lcString = "select * from palk_lib  where parentid in (select id from library where rekvid = 1 and library = 'PALK')"
lcTbl = 'qryPALK_LIB'
lError = SQLEXEC(gnHandle,lcString)

IF lError < 1
	MESSAGEBOX('Viga')
	return
ENDIF

lcstring = "SELECT * from sqlresult INTO TABLE "+lctbl
&lcString


WAIT WINDOW 'SELECTING nomenklatuur'

lcString = "select * from nomenklatuur where rekvid = 1"
lcTbl = 'qryNom'
lError = SQLEXEC(gnHandle,lcString)

IF lError < 1
	MESSAGEBOX('Viga')
	return
ENDIF

lcstring = "SELECT * from sqlresult INTO TABLE "+lctbl
&lcString


WAIT WINDOW 'SELECTING dok'

lcString = "select * from library where rekvid = 1 and library = 'DOK'"
lcTbl = 'qrydok'
lError = SQLEXEC(gnHandle,lcString)

IF lError < 1
	MESSAGEBOX('Viga')
	return
ENDIF

lcstring = "SELECT * from sqlresult INTO TABLE "+lctbl
&lcString



WAIT WINDOW 'SELECTING holidays'

lcString = "select * from holidays where rekvid = 1"
lcTbl = 'qryholidays'
lError = SQLEXEC(gnHandle,lcString)

IF lError < 1
	MESSAGEBOX('Viga')
	return
ENDIF

lcstring = "SELECT * from sqlresult INTO TABLE "+lctbl
&lcString


=SQLDISCONNECT(gnHandle)


