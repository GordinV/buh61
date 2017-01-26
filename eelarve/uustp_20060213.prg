Set Step On
*gnhandle = SQLConnect('NarvaLvPg','vlad','490710')
gnhandle = SQLConnect('njlvpg','vlad','490710')
If gnhandle < 0
	Messagebox('Viga uhenduses')
	Set Step On
	Return
Endif

tcFile = 'C:\temp\tp.xls'
*tcSheet = 'kontoplaan'
lcCursor = Juststem(tcFile)


If !Empty(tcFile)
	Import From (tcFile) Type XlS 
Else
	Import From  ? Type XlS
Endif
Set Step On

lcString = "select kood from library where library = 'TP'"
lError = SQLEXEC(gnhandle,lcString,'qryKonto')

*!*	lcString = "select kood from library where library = 'TP'"
*!*	lError = SQLEXEC(gnhandle,lcString,'qryTP')


lError = SQLEXEC(gnhandle,'begin work')

If lError > 0

	Select (lcCursor)
	Scan For !Empty(TP.a) AND !EMPTY(TP.b) 
		Wait Window 'Import TP: kokku read:'+Str(Recno(lcCursor),9)+'-'+Str(Reccount(lcCursor),9) Nowait
* TAOTLEJA
* KONTROL
		Select qryKonto
		lcTp = Alltrim(STR(TP.A))
		IF LEN(lcTp) = 5
			lcTp = '0'+lcTp
		ENDIF
		
		Locate For Alltrim(kood) = Alltrim(lcTp)
		If !Found()
			Wait Window 'Konto puudub:'+(lcTp) Nowait
			lcString = "insert into library (rekvid, kood, nimetus, tun1, tun2, tun3, tun4, tun5, library) values (2,'"+;
				LTRIM(Rtrim(lcTp))+"','"+Ltrim(RTRIM(STR(TP.B)))+","+Ltrim(Rtrim(TP.c))+"',"+;
				"0,0,0,0,0,'TP')"

			lError = SQLEXEC(gnhandle,lcString,'qryId')
			If lError < 0
				Set Step On
				Exit
			Endif

		Endif

	Endscan
Endif

*!*	If lError > 0
*!*		tcFile = 'C:\avpsoft\files\buh60\temp\TP2005.xls'
*!*		tcSheet = 'tehingupartnerid'
*!*		lcCursor = Juststem(tcFile)


*!*		If !Empty(tcSheet)
*!*			Import From (tcFile) Type Xl8 Sheet (tcSheet)
*!*		Else
*!*			Import From  ? Type Xl8
*!*		Endif
*!*		Select (lcCursor)
*!*		SCAN For !Empty(TP2005.D) AND !EMPTY(TP2005.g)
*!*			Select qryTP
*!*			Locate For Alltrim(kood) = Alltrim(TP2005.d)
*!*			If !Found()
*!*				Wait Window 'tp puudub:'+TP2005.d Nowait
*!*				lcString = "insert into library (rekvid, kood, nimetus, tun1, tun2, tun3, tun4, tun5,library) values (2,'"+;
*!*					LTRIM(Rtrim(TP2005.d))+"','"+Ltrim(Rtrim(TP2005.g))+","+;
*!*						TP2005.f+"',0,0,0,0,0,'TP')"

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


