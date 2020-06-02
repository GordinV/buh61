Parameter tcKey
_Screen.WindowState = 2
Public gnHandle,gnHandleAsync, gcWindow, gRekv,gUserId, oPrintform2, oFinder, gReturn, oAsutused, oUserid,;
	oArved, oDokLausend, oNomenklatuur, oKontod, oAllikad, oArtikkel, oTegev,;
	oObjekt, oTunnus,oJournal, oSaldo, oAsutused, oUserid, oRekv, oLausendid, oKlsaldo, oDok, oTasud,;
	oLepingud, cKasutaja, oDb, oPohivara, oPvGruppid, oOsakonnad, oAmetid, oPalklib, oPalkOper, oTaabel1, oPeriod,;
	oHoliday, gnKuu, gnAasta, gdKpv, oPalkJaak, oMaksuKoodid,;
	oGruppid, oLaduOper, oVarad, oLaduJaak, oLaduArved,;
	gVersia, gcDatabase, glError, oEelarve, oTuludeAllikad, oTulutaitm, oKuluTaitm, gcHelp, oTeenused,;
	tcAllikas, tcArtikkel, tcObjekt, tcTegev, tcEelAllikas, oToograafik, eETSD, tcTunnus, gcProgNimi, omk, oTood,;
	oPuudumised, oEtsd,tcOsakond, tnOsakondId1, tnOsakondId2,gnPaev,tnParentRekvId,;
	oTpr, oRahavoodid, oMenu, oConnect, oKorderID, gcKey, oVanemtasu, gcAmetnik, oLahetuskulud, oLapsed,;
	oEeltaotlus, oEelVariandid,oDokumendid,;
	oProjektid, oUritused, tcProj, tcUritus, tcgrupp, oValuuta,gcCurrentValuuta, glMvt
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
cCaption = _Screen.Caption
tcAllikas = '%'
tcArtikkel = '%'
tcObjekt = '%'
tcProj = '%'
tcUritus = '%'
tcgrupp = '%'

tcTegev = '%'
tcEelAllikas = '%'
glError = .F.
gVersia = 'MSSQL'
gdKpv = Date()
cKasutaja = ''
gnHandle = 0
gUserId = 0
gRekv = 0
glMvt = .T.
*!*	grekv = 1
*!*	gUserid = 1
Local lError
Close Data All
Set Udfparms To Value
On Shutdown Quit
Set Resource Off
Set Hours To 24
Set Compatible Off
Set Null Off
Set Autosave On
Set Point To '.'
Set Help On
Set Lock On
Set Exclusive Off
Set Multilock On
Set Century On
Set Talk Off
Set Console Off
Set Notify Off
Set Safety Off
Set Delete On
Set Ansi On
Set Exact On
Set Console Off
Set Date To German
Set Memowidth To 8000
cFile = 'buh60.chm'
If File(cFile)
	On Key Label F1 Do fHelp
	Set Help To buh60.CHM
	gcHelp = .T.
Else
	Set Help Off
	gcHelp = .F.
Endif

Create Cursor curprinter (Id Int, objekt c(40), nimetus1 c(120), nimetus2 c(120), procfail c(120), reportfail c(120),;
	reportvene c(120), Parameter m)


cFile = 'EELARVE\curPrinter.DBF'
If File (cFile)
	Use (cFile) In 0 Alias curPrinter0
Else
	Use curprinter In 0 Alias curPrinter0
Endif

* uuendamine curPrinter
cFileUuend = 'TMP\tmpPrinter.dbf'
cFileUuendFpt = 'TMP\tmpPrinter.fpt'
If File(cFileUuend)
	Use (cFileUuend) In 0 Alias tmpPrinter
	Select tmpPrinter
	Scan
		Select curPrinter0
		Locate For Id = tmpPrinter.Id And Alltrim(Upper(curPrinter0.objekt)) = Alltrim(Upper(tmpPrinter.objekt))
		If !Found()
			Insert Into curPrinter0 (Id, objekt, nimetus1, nimetus2, procfail, reportfail, reportvene, Parameter) ;
				VALUES (tmpPrinter.Id, tmpPrinter.objekt, tmpPrinter.nimetus1, tmpPrinter.nimetus2, tmpPrinter.procfail, ;
				tmpPrinter.reportfail, tmpPrinter.reportvene, tmpPrinter.Parameter)
		Endif
	Endscan
	Use In tmpPrinter
	Erase (cFileUuend)
	Erase (cFileUuendFpt)
Endif



Select curprinter
Append From Dbf('curPrinter0')

Use In curPrinter0

cFile = 'palk\curPrintertsd.DBF'
If File (cFile)
	Use (cFile) In 0 Alias curPrinter1
	Select curprinter
	Append From Dbf('curPrinter1')
	Use In curPrinter1
Endif



cFile = 'EELARVE\saldoandmik\curPrinter.DBF'
If File (cFile)
	Use (cFile) In 0 Alias curPrinter1
Else
	Use curprinter In 0 Alias curPrinter1
Endif
Select curprinter
Append From Dbf('curPrinter1')

Use In curPrinter1

cFile = 'ladu\curPrinter.DBF'
If File (cFile)
	Use (cFile) In 0 Alias curPrinter2
	Select curprinter
	Append From Dbf('curPrinter2')
	Use In curPrinter2
Endif

cFile1 = 'EELPROJ\curPrinter.DBF'
If File (cFile1)
	Use (cFile1) In 0 Alias curPrinter3
	Select curprinter
	Append From Dbf('curPrinter3')
	Use In curPrinter3
Endif

cFile1 = 'ERI\curPrinter.DBF'
If File (cFile1)
	Use (cFile1) In 0 Alias curPrinter4
	Select curprinter
	Append From Dbf('curPrinter4')
	Use In curPrinter4
Endif


Use config In 0
Select config
=CursorSetProp('buffering',3)

If File ('KEY.DBF')
	Use Key In 0
Endif

If !Used('v_roles')
	Create Cursor v_roles (	nimetus c(120) Default 'Raamatupidaja', asutusid Int, nomid Int, nomidkassa Int,nomidpank Int, kbmnomidkassa Int,;
		kassaid Int, aaid Int, alus c(120),kassanr c(20),arvnr c(20), ;
		dokpropidarvvalju Int, dokpropidsorder Int, dokpropidpank Int, tunnusid Int)
Endif


Create Cursor comkey (Id Int, omanik c(120))
Select Id, Left(decrypt(f_key(),Mline(omanik,1)),120) As omanik From Key Into Cursor qryComkey
Select comkey
Append From Dbf ('qryComkey')
Use In qryComkey

Select comkey
=secure('OFF')

lQuit = .F.
If !Empty (config.reserved1) And File ('updater1.exe')
	lresult = checkuuendused(config.reserved1)
	If Used ('ajalugu')
		Use In ajalugu
	Endif
	If Used ('uuendus')
		Use In uuendus
	Endif
	If lresult = .T.
		lnResult = Messagebox (Iif(config.keel = 2,'Kas uuenda programm?','Обновить приложение?'),1+32+0,'Uuendamine')
		If lnResult = 1
			! /N updater1.Exe
			lQuit = .T.
		Endif
	Endif
Endif
If lQuit = .F.
	Set Sysmenu To
	Set Sysmenu Automatic

	Set Classlib To Classlib
	Set Proc To classes\login
	oLogin = Createobject('login', tcKey)
	oLogin.Show()


	Set Classlib To toolseelarve Additive
	oTools = Createobject('Toolseelarve')

	oTools.translate()

&&	Do createmenu with 'MAIN',iif(config.keel = 1,.f.,.t.),.f.
	If !Empty(config.background)
		_Screen.Picture = Trim(config.background)
	Endif
*!*		Set classlib to checkKontoIntegrity additive
*!*		oRI = createobject('checkKontoIntegrity')
	Do Case
		Case config.Debug = 0
			On Error Do err With Program(), Lineno(1)
		Case config.Debug = 1
			On Error
		Case config.Debug = 2
			On Error Do Ferr
	Endcase

	If !Empty(tcKey) And tcKey = '-m'
		Do valirekv
	Endif


	Read Events
Endif
Set Proc To
If gnHandle >0 And gVersia <> 'VFP'
	=sqldisconnect(gnHandle)
	gnHandle = 0
Endif
_Screen.Caption = cCaption
&&set help to
On Key
Set Sysmenu To Default
_Screen.Picture = ''
Clear All
On Error

Procedure Ferr
Endproc

