Set Step On
*gnhandle = SQLConnect('NarvaLvPg','vlad','490710')
gnhandle = SQLConnect('njlvpg','vlad','490710')
If gnhandle < 0
	Messagebox('Viga uhenduses')
	Set Step On
	Return
Endif

tcFile = 'C:\temp\rahavoog.xls'
*tcSheet = 'kontoplaan'
lcCursor = Juststem(tcFile)


If !Empty(tcFile)
	Import From (tcFile) Type XlS 
Else
	Import From  ? Type XlS
Endif
Set Step On

lcString = "select kood from library where library = 'RAHA'"
lError = SQLEXEC(gnhandle,lcString,'qryKonto')

*!*	lcString = "select kood from library where library = 'TP'"
*!*	lError = SQLEXEC(gnhandle,lcString,'qryTP')


lError = SQLEXEC(gnhandle,'begin work')

If lError > 0

	Select (lcCursor)
	Scan For !Empty(rahavoog.a) AND !EMPTY(rahavoog.b) AND UPPER(rahavoog.a) <> UPPER('kood')
		Wait Window 'Import rahavoog: kokku read:'+Str(Recno(lcCursor),9)+'-'+Str(Reccount(lcCursor),9) Nowait
* TAOTLEJA
* KONTROL
		Select qryKonto
		Locate For Alltrim(kood) = Alltrim(rahavoog.b)
		If !Found()
			Wait Window 'Konto puudub:'+(rahavoog.b) Nowait
			lcString = "insert into library (rekvid, kood, nimetus, tun1, tun2, tun3, tun4, tun5, library) values (2,'"+;
				LTRIM(Rtrim(rahavoog.a))+"','"+Ltrim(Rtrim(rahavoog.b))+"',"+;
				"0,0,0,0,0,'RAHA')"

			lError = SQLEXEC(gnhandle,lcString,'qryId')
			If lError < 0
				Set Step On
				Exit
			Endif

		Endif

	Endscan
Endif

*!*	If lError > 0
*!*		tcFile = 'C:\avpsoft\files\buh60\temp\rahavoog2005.xls'
*!*		tcSheet = 'tehingupartnerid'
*!*		lcCursor = Juststem(tcFile)


*!*		If !Empty(tcSheet)
*!*			Import From (tcFile) Type Xl8 Sheet (tcSheet)
*!*		Else
*!*			Import From  ? Type Xl8
*!*		Endif
*!*		Select (lcCursor)
*!*		SCAN For !Empty(rahavoog2005.D) AND !EMPTY(rahavoog2005.g)
*!*			Select qryTP
*!*			Locate For Alltrim(kood) = Alltrim(rahavoog2005.d)
*!*			If !Found()
*!*				Wait Window 'tp puudub:'+rahavoog2005.d Nowait
*!*				lcString = "insert into library (rekvid, kood, nimetus, tun1, tun2, tun3, tun4, tun5,library) values (2,'"+;
*!*					LTRIM(Rtrim(rahavoog2005.d))+"','"+Ltrim(Rtrim(rahavoog2005.g))+","+;
*!*						rahavoog2005.f+"',0,0,0,0,0,'TP')"

*!*				lError = SQLEXEC(gnhandle,lcString,'qryId')
*!*				If lError < 0
*!*					Set Step On
*!*					Exit
*!*				Endif

*!*			Endif
*!*		Endscan


*!*	Endif
Set Step On

If lError > 0
	lError = SQLEXEC(gnhandle,'commit')
Else
	lError = SQLEXEC(gnhandle,'rollback')
Endif


