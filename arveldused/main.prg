Parameter tcKey
if empty (tcKey)
	tcKey = ''
endif

_Screen.windowstate = 2
public gnHandle,gnHandleAsync, gcWindow, gRekv,gUserId, oPrintform2, oFinder, gReturn, oAsutused, oUserid,;
	oArved, oDokLausend, oNomenklatuur, oSorder, oVorder, oKontod, oAllikad, oArtikkel, oTegev,;
	oObjekt, oTunnus,oJournal, oSaldo, oAsutused, oUserid, oRekv, oLausendid, oKlsaldo, oDok, oTasud,;
	oLepingud, cKasutaja, oDb,  oPeriod,oTeenused,oNomenklatuur,;
	gnKuu, gnAasta, gdKpv,cCaption,omk,oMenu, oConnect,;
	gVersia, gcDatabase, glError, oRI, gcHelp, gcWinName, oTeenused, oetsd, oToograafik, oTood,tcTunnus, gcProgNimi,;
	gcAmetnik, 	oProjektid, oUritused, oValuuta, gcValuuta, gcCurrentValuuta, oPaketid, oMotted, gcKey

gcProgNimi = 'ARVELDUSED.EXE'
cCaption = _screen.caption
gcWinName = ''
glError = .f.
gVersia = 'MSSQL'
gdKpv = date()
cKasutaja = ''
gnHandle = 0
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
SET AUTOSAVE ON 
set point to '.'
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
Set date to german
SET EXACT ON 
set memowidth to 8000

&&SET HELP TO lepingud.CHM
Use config in 0
Select config
=cursorsetprop('buffering',3)

select config
=cursorsetprop('buffering',3)
*!*	if file ('key.fxp')
*!*		&& новая организация
*!*		do key with f_key()
*!*		erase key.fxp
*!*	endif
*!*	if !empty (tcKey) and vartype(tckey) = 'C' and tcKey = '/K'
*!*		do form genkey
*!*	endif
IF FILE ('KEY.DBF')
	use key in 0
ENDIF

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

	create cursor curprinter (id int, objekt c(40), nimetus1 c(120), nimetus2 c(120), procfail c(120), reportfail c(120),;
		reportvene c(120), parameter m)


*!*		cFile = 'EELARVE\curPrinter.DBF'
*!*		If file (cFile)
*!*			Use (cFile) in 0 alias curPrinter0
*!*		Else
*!*			Use curPrinter in 0 alias curPrinter0
*!*		Endif

*!*		select curprinter
*!*		append from dbf('curPrinter0')	 

*!*		use in curPrinter0


	cFile = 'arveldused\curPrinter.DBF'
	If file (cFile)
		Use (cFile) in 0 alias curPrinter1
	Else
		Use curPrinter in 0 alias curPrinter1
	Endif
	select curprinter
	append from dbf('curPrinter1')	 

	use in curPrinter1


	Set Sysmenu To
	Set Sysmenu Automatic

	Set classlib to classlib
	Set proc to classes\login
	oLogin = createobject('login', tcKey)
	oLogin.show()
	If !empty(config.background)
		_Screen.picture = trim(config.background)
	Endif
	Set classlib to toolsarv additive
	oTools = createobject('Tools')
	
	oTools.translate()
	oTools.show()
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
tnid = gRekv
If file ('buh50viga.log') and ;
		used ('qryRekv') AND !empty (qryRekv.email) ;
		and !empty (mline(qryRekv.muud,1)) and;
		!isnull(qryRekv.muud) and !empty (config.reserved3)
	Create cursor mail (smtpto c(254), cclist c(254), bcclist c(254), subject c(50),;
		attachment c(254), message m)
	cAttach = sys(5)+sys(2003)+'\buh50viga.log'
	Insert into mail (smtpto, subject, attachment);
		values (ltrim(rtrim(config.reserved3)),'Raamatupidamine 5.0 Viga',cAttach)
	Set classlib to email
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
Set sysmenu to default
_Screen.caption = cCaption
_Screen.picture = ''
Release oTools
