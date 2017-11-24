Parameter tcKey
_Screen.windowstate = 2
public gnHandle,gnHandleAsync, gcWindow, gRekv,gUserId, oPrintform2, oFinder, gReturn, oAsutused, oUserid,;
	oArved, oDokLausend, oNomenklatuur, oSorder, oVorder, oKontod, oAllikad, oArtikkel, oTegev,;
	oObjekt, oTunnus,oJournal, oSaldo, oAsutused, oUserid, oRekv, oLausendid, oKlsaldo, oDok, oTasud,;
	oLepingud, cKasutaja, oDb,oArvedTeen,oAutod, oVastIsikud,oTeenused, ;
	gnKuu, gnAasta, gdKpv, oGruppid, oLaduOper, oVarad, oLaduJaak, oLaduArved,;
	gVersia, gcDatabase, glError, gRekv

gcProgNimi = 'TEEN.EXE'
tcTunnus = '%'
tcAllikas = '%'
tcArtikkel = '%'
tcObjekt = '%'
tcTegev = '%'
tcEelAllikas = '%'
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
set memowidth to 8000
&&SET HELP TO lepingud.CHM
cFile = 'TEEN\MENUBAR.DBF'
if file (cFile)
	use (cFile) in 0 alias menubar
else
	use menubar in 0 
endif
cFile = 'TEEN\MENUITEM.DBF'
if file (cFile)
	use (cFile) in 0 alias menuitem
else
	use menuitem in 0 
endif


Use config in 0
Select config
=cursorsetprop('buffering',3)
Do case
	Case config.debug = 0
&& switch on own debugger
		On error do err with program(), lineno(1)
	Case config.debug = 1
&& switch on vfp debugger
		On error
	Case config.debug = 2
&& turn off vfp debugger
		On error do ferr()
Endcase

If FILE ('KEY.DBF')
	Use key in 0
Else
	Messagebox ('Key fail ei leidnud','Kontrol')
	Cancel
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
	Set classlib to classlib
	Set proc to classes\login
	oLogin = createobject('login', tcKey)
	oLogin.show()
	Do createmenu with 'MAIN',iif(config.keel = 1,.f.,.t.),.f.
	If !empty(config.background)
		_Screen.picture = trim(config.background)
	Endif
	Set classlib to toolsteen additive
	oTools = createobject('Toolsteen')
	oTools.translate()
	oTools.show()
*!*	set classlib to checkKontoIntegrity additive
*!*	oRI = createobject('checkKontoIntegrity')
	Read events
Endif
on key
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
If config.debug = 1
	=systoolbars(1)
	Set help to
	Clear all
	On error
Endif



Procedure ferr
Endproc

