Close Data All
grekv = 16
gVersia = 'PG'
gnhandle = SQLConnect('narvaLvPg','vlad','490710')
gnHandleAsync = gnhandle
glError = .F.
&&cData = 'c:\buh50\dbavpsoft\buhdata5.dbc'
*!*	cData = 'c:\dbase\buhdata5.dbc'
*!*	SET DATABASE TO BUHDATA5
&&OPEN data (cData)
*!*	USE menuitem IN 0
*!*	USE menubar IN 0
Use config In 0

Set Classlib To classes\Classlib
oDb = Createobject('db')
With oDb
	.login = 'VLAD'
	.Pass = ''

	tnid = grekv
	.Use ('v_rekv','qryRekv')
Endwith
Create Cursor curKey (versia m)
Append Blank
Replace versia With 'RAAMA, EELARVE' In curKey
Create Cursor v_account (admin Int Default 1)

Do Proc\open_lib

Create Cursor fltrAruanne (kpv1 d Default Date (Year (Date()),Month (Date()),1),;
	kpv2 d Default Gomonth (fltrAruanne.kpv1,1) - 1,konto c(20), deebet c(20),;
	kreedit c(20), asutusId Int, kood1 Int, kood2 Int,;
	kood3 Int, kood4 Int, tunnus Int)

Append Blank
&&set procedure to proc\analise_formula
tcCursor = 'CursorAlgSaldo_'
cKonto = '201000%'
TcKonto = cKonto
tnAsutusId1 = 0
tnAsutusId2 = 99999999
tdKpv1 = Date(1999,1,1)
tdKpv2 = Date(2003,12,31)
oDb.Use ('qrySaldo2',tcCursor)
tdKpv1 = Date(2004,01,01)
tdKpv2 = Date(2004,01,31)
tcCursor = 'CursorKaibed_'
oDb.Use ('qrySaldo2',tcCursor)

lcKonto = cKonto
tnid = 24194
oDb.Use ('v_subkonto','qrySubkonto')
Select qrySubKonto

*SELECT * from qrysubkonto WHERE asutusid NOT in (select asutusid FROM cursoralgsaldo_)
Select * From qrySubKonto Where asutusId Not In (Select asutusId From cursorkaibed_) Into Cursor qryK

Select qryK
Scan
	lcString = 'select * from curJournal where asutusId = '+Str(qrySubKonto.asutusId)+' and ('+;
		" deebet = '201000' or kreedit = '201000'"
	lError = SQLEXEC(gnhandle,lcString,'qryA')
	If lError > 0 And Reccount('qryA') > 1
		Brow
	ENDIF
	IF lError < 1
		SET STEP ON 
	ENDIF
	exit

Endscan


=SQLDISCONNECT(gnhandle)
Release oDb

*!*	REPORT form reports\kaibeandmik_report1 prev
*!*	IF !used ('curPrinter')
*!*		USE curprinter in 0
*!*	ENDIF

*!*	SELECT curprinter
*!*	LOCATE for 	procfail = 'kaibeandmik_report1'
*!*	IF !found ()
*!*		MESSAGEBOX ('Viga, ei leida paring curprinter tabelis')
*!*	ENDIF
