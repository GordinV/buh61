Parameter tcKey
_Screen.windowstate = 2
public gnHandle,gnHandleAsync, gcWindow, gRekv,gUserId, oPrintform2, oFinder, gReturn, oUserid,;
	oAllikad, oArtikkel, oTegev,;
	oObjekt, cKasutaja, oDb, oEelSvod,;
	gnKuu, gnAasta, gdKpv,;
	gVersia, gcDatabase, glError, oTuludeAllikad, oTulutaitm, oKuluTaitm, gcHelp	
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
set ansi on
Set date to german
set memowidth to 8000
cFile = 'buh52.chm'
if file(cFile) 
	on key label F1 do fHelp
	SET HELP TO buh52.CHM
	gcHelp = .t.
else
	set help off
	gcHelp = .f.
endif
cFile = 'EELARVE\EELARVESVOD\MENUBAR.DBF'
if file (cFile)
	use (cFile) in 0 alias menubar
else
	use menubar in 0 
endif
cFile = 'EELARVE\EELARVESVOD\MENUITEM.DBF'
if file (cFile)
	use (cFile) in 0 alias menuitem
else
	use menuitem in 0 
endif

Use config in 0
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

select id, left(decrypt(f_key(),mline(omanik,1)),120) as omanik from key into cursor comkey

set classlib to classlib
set proc to classes\login
oLogin = createobject('login')
oLogin.show()
Do createmenu with 'MAIN',iif(config.keel = 1,.f.,.t.),.f.
If !empty(config.background)
	_Screen.picture = trim(config.background)
Endif
set classlib to toolseelsvod additive
oTools = createobject('Toolseelsvod')
oTools.translate()
oTools.show()
if config.debug = 0
	on error do err
endif
Read events
set proc to
If gnHandle >0 and gversia <> 'VFP'
	=sqldisconnect(gnHandle)
	gnHandle = 0
Endif
set help to
on key
Set sysmenu to default
_Screen.picture = ''
Clear all
On error

Procedure err
endproc
