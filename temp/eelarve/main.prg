Parameter tcKey
_Screen.windowstate = 2
Public gnHandle,gnHandleAsync, gcWindow, gRekv,gUserId, oPrintform2, oFinder, gReturn, oAsutused, oUserid,;
	oArved, oDokLausend, oNomenklatuur, oKontod, oAllikad, oArtikkel, oTegev,;
	oObjekt, oTunnus,oJournal, oSaldo, oAsutused, oUserid, oRekv, oLausendid, oKlsaldo, oDok, oTasud,;
	oLepingud, cKasutaja, oDb, oPohivara, oPvGruppid, oOsakonnad, oAmetid, oPalklib, oPalkOper, oTaabel1, oPeriod,;
	oHoliday, gnKuu, gnAasta, gdKpv, oPalkJaak, oGruppid, oLaduOper, oVarad, oLaduJaak, oLaduArved,;
	gVersia, gcDatabase, glError, oEelarve, oTuludeAllikad, oTulutaitm, oKuluTaitm, gcHelp, oTeenused,;
	tcAllikas, tcArtikkel, tcObjekt, tcTegev, tcEelAllikas, oToograafik, eETSD, tcTunnus, gcProgNimi, omk, oTood,;
	oPuudumised, oEtsd,tcOsakond, tnOsakondId1, tnOsakondId2,gnPaev,;
	oTpr, oRahavoodid, oMenu, oConnect, oKorderID, gcKey, oVanemtasu, gcAmetnik, oLahetuskulud, oLapsed,;
	oProjektid, oUritused, tcProj, tcUritus, tcgrupp
gnPaev = 0
gcAmetnik = ''
tcKasutaja = '%'
tcMuud = '%'
tcOsakond = '%'
tnOsakondId1 = 0
tnOsakondId2 = 999999999
gcKey = tcKey
gcProgNimi = 'EELARVE.EXE'
tcTunnus = '%'
cCaption = _screen.caption
tcAllikas = '%'
tcArtikkel = '%'
tcObjekt = '%'
tcproj = '%'
tcUritus = '%'
tcgrupp = '%'

tcTegev = '%'
tcEelAllikas = '%'
glError = .f.
gVersia = 'MSSQL'
gdKpv = date()
cKasutaja = ''
gnHandle = 0
guserid = 0
gRekv = 0
*!*	grekv = 1
*!*	gUserid = 1
Local lError
Close data all
Set UDFPARMS TO VALUE
On SHUTDOWN quit
Set resource off
Set HOURS TO 24
Set compatible off
Set null off
Set AUTOSAVE ON
Set point to '.'
Set help on
Set lock on
Set exclusive off
Set multilock on
Set century on
Set talk off
Set console off
Set notify off
Set safety off
Set delete on
SET ANSI ON
SET EXACT on
Set date to german
Set memowidth to 8000
cFile = 'buh60.chm'
If file(cFile)
	On key label F1 do fHelp
	Set HELP TO buh60.CHM
	gcHelp = .t.
Else
	Set help off
	gcHelp = .f.
Endif
*!*	cFile = 'EELARVE\MENUBAR.DBF'
*!*	If file (cFile)
*!*		Use (cFile) in 0 alias menubar
*!*	Else
*!*		Use menubar in 0
*!*	Endif
*!*	cFile = 'EELARVE\MENUITEM.DBF'
*!*	If file (cFile)
*!*		Use (cFile) in 0 alias menuitem
*!*	Else
*!*		Use menuitem in 0
*!*	Endif
cFile = 'EELARVE\curPrinter.DBF'
If file (cFile)
	Use (cFile) in 0 alias curPrinter
Else
	Use curPrinter in 0
Endif

Use config in 0
Select config
=cursorsetprop('buffering',3)
*!*	if file ('key.fxp')
*!*		&& новая организация
*!*		do key with f_key()
*!*		erase key.fxp
*!*	endif
*!*	if !empty (tcKey) and vartype(tckey) = 'C' and tcKey = '/K'
*!*		do form genkey
*!*	endif
If FILE ('KEY.DBF')
	Use key in 0
Endif

Create cursor comkey (id int, omanik c(120))
Select id, left(decrypt(f_key(),mline(omanik,1)),120) as omanik from key into cursor qryComkey
Select comkey
Append from dbf ('qryComkey')
Use in qryComkey
Select comkey
=secure('OFF')
lQuit = .f.
If !empty (config.reserved1) and file ('updater.exe')
	lresult = checkuuendused(config.reserved1)
	If used ('ajalugu')
		Use in ajalugu
	Endif
	If used ('uuendus')
		Use in uuendus
	Endif
	If lresult = .t.
		lnResult = messagebox (iif(config.keel = 2,'Kas uuenda programm?','Обновить приложение?'),1+32+0,'Uuendamine')
		If lnResult = 1
			! /N updater.exe
			lQuit = .t.
		Endif
	Endif
Endif
If lQuit = .f.
	Set Sysmenu To
	Set Sysmenu Automatic

	Set classlib to classlib
	Set proc to classes\login
	oLogin = createobject('login', tcKey)
	oLogin.show()
&&	Do createmenu with 'MAIN',iif(config.keel = 1,.f.,.t.),.f.
	If !empty(config.background)
		_Screen.picture = trim(config.background)
	Endif
	Set classlib to toolseelarve additive
	oTools = createobject('Toolseelarve')
	
	oTools.translate()
	oTools.show()
*!*		Set classlib to checkKontoIntegrity additive
*!*		oRI = createobject('checkKontoIntegrity')
	Do case
		Case config.debug = 0
			On error do err with program(), lineno(1)
		Case config.debug = 1
			On error
		Case config.debug = 2
			On error do ferr
	ENDCASE
	
	IF !EMPTY(tckey) AND tckey = '-m'
		DO valirekv
	ENDIF
	
	
	Read events
Endif
If file ('buh50viga.log') and ;
		used ('qryRekv') and !empty (qryRekv.email) ;
		and !empty (mline(qryRekv.muud,1)) and;
		!isnull(qryRekv.muud) and !empty (config.reserved3)
	Create cursor mail (smtpto c(254), cclist c(254), bcclist c(254), subject c(50),;
		attachment c(254), message m)
	cAttach = sys(5)+sys(2003)+'\buh50viga.log'
	Insert into mail (smtpto, subject, attachment);
		values (ltrim(rtrim(config.reserved3)),'Raamatupidamine 5.0 Viga',cAttach)
	Set classlib to classe\email
	oEmail = createobject('email')
	With oEmail
		.SmtpFrom = ltrim(rtrim(qryRekv.email))
		.SmtpReply = ltrim(rtrim(qryRekv.email))
		.SmtpServer = ltrim(rtrim(mline (qryRekv.muud,1)))
		lError = .send()
		If lError = .t.
			Erase (cAttach)
		Endif
	Endwith
	Use in mail
	Release oEmail
Endif
Set proc to
If gnHandle >0 and gVersia <> 'VFP'
	=sqldisconnect(gnHandle)
	gnHandle = 0
Endif
_Screen.caption = cCaption
&&set help to
On key
Set sysmenu to default
_Screen.picture = ''
Clear all
On error

Procedure ferr
Endproc

