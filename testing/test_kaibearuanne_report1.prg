CLOSE data all
grekv = 1
gVersia = 'VFP'
gnhandle = 1
glError = .f.
&&cData = 'c:\buh50\dbavpsoft\buhdata5.dbc'
cData = 'c:\dbase\buhdata5.dbc'
SET DATABASE TO BUHDATA5 
&&OPEN data (cData)
*!*	USE menuitem IN 0
*!*	USE menubar IN 0
USE config IN 0

SET classlib to classes\classlib
oDb = createobject('db')
WITH oDb
	.login = 'VLAD'
	.pass = ''

	tnid = grekv
	.use ('v_rekv','qryRekv')
	CREATE cursor qryAaRekv (aa m)
	APPEND blank
	.use ('v_aa')
	SELECT v_aA
	SCAN for kassapank = 1
		REPLACE aa with left(v_aA.arve,20) + space(1)+;
			str (v_aA.pank,3)+space(1)+left(v_aA.nimetus,60)+chr(13) in qryAaRekv
	ENDSCAN
ENDWITH
CREATE cursor curKey (versia m)
APPEND blank
REPLACE versia with 'RAAMA' in curKey
CREATE cursor v_account (admin int default 1)

DO proc\open_lib

CREATE cursor fltrAruanne (kpv1 d default date (year (date()),month (date()),1),;
	kpv2 d default gomonth (fltrAruanne.kpv1,1) - 1,konto c(20), deebet c(20),;
	kreedit c(20), asutusId int, kood1 int, kood2 int,;
	kood3 int, kood4 int, tunnus int)

APPEND blank
&&set procedure to proc\analise_formula
SET step on
cKonto = '300000'
lError = oDb.Exec ("sp_saldo1 ",Str(gRekv)+",1, '"+DTOC(fltrAruanne.kpv1,1)+"','"+;
			 Dtoc(fltrAruanne.kpv1,1)+"','"+cKonto+"%'",'CursorAlgSaldo')

SET proc to
IF !empty (alias())
	BROW
ENDIF
*!*	REPORT form reports\kaibeandmik_report1 prev
*!*	IF !used ('curPrinter')
*!*		USE curprinter in 0
*!*	ENDIF

*!*	SELECT curprinter
*!*	LOCATE for 	procfail = 'kaibeandmik_report1'
*!*	IF !found ()
*!*		MESSAGEBOX ('Viga, ei leida paring curprinter tabelis')
*!*	ENDIF
