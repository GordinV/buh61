Set Step On
gnhandle = SQLConnect('njlvpg','vlad','490710')
If gnhandle < 0
	Messagebox('Viga uhenduses')
	Set Step On
	Return
Endif

tcFile = 'C:\avpsoft\files\buh60\temp\kontoplaan2005.xls'
tcSheet = 'kontoplaan'
lcCursor = Juststem(tcFile)


If !Empty(tcSheet)
	Import From (tcFile) Type Xl8 Sheet (tcSheet)
Else
	Import From  ? Type Xl8
Endif
Set Step On

lcString = "select kood from library where library = 'KONTOD'"
lError = SQLEXEC(gnhandle,lcString,'qryKonto')

lcString = "select kood from library where library = 'TP'"
lError = SQLEXEC(gnhandle,lcString,'qryTP')


lError = SQLEXEC(gnhandle,'begin work')

If lError > 0

	Select (lcCursor)
	Scan For !Empty(kontoplaan2005.b) AND !EMPTY(kontoplaan2005.C)
		Wait Window 'Import kontoplaan: kokku read:'+Str(Recno(lcCursor),9)+'-'+Str(Reccount(lcCursor),9) Nowait
* TAOTLEJA
* KONTROL
		Select qryKonto
		Locate For Alltrim(kood) = Alltrim(STR(kontoplaan2005.b,6))
		If !Found()
			Wait Window 'Konto puudub:'+STR(kontoplaan2005.b) Nowait
			lcString = "insert into library (rekvid, kood, nimetus, tun1, tun2, tun3, tun4, tun5, library) values (2,'"+;
				LTRIM(Rtrim(STR(kontoplaan2005.b,9)))+"','"+Ltrim(Rtrim(kontoplaan2005.c))+"',"+;
				IIF(!Empty(kontoplaan2005.d),"1","0")+","+;
				IIF(!Empty(kontoplaan2005.e),"1","0")+","+;
				IIF(!Empty(kontoplaan2005.F),"1","0")+","+;
				IIF(!Empty(kontoplaan2005.g),"1","0")+",0,'KONTOD')"

			lError = SQLEXEC(gnhandle,lcString,'qryId')
			If lError < 0
				Set Step On
				Exit
			Endif

		Endif

	Endscan
Endif

If lError > 0
	tcFile = 'C:\avpsoft\files\buh60\temp\kontoplaan2005.xls'
	tcSheet = 'tehingupartnerid'
	lcCursor = Juststem(tcFile)


	If !Empty(tcSheet)
		Import From (tcFile) Type Xl8 Sheet (tcSheet)
	Else
		Import From  ? Type Xl8
	Endif
	Select (lcCursor)
	SCAN For !Empty(kontoplaan2005.D) AND !EMPTY(kontoplaan2005.g)
		Select qryTP
		Locate For Alltrim(kood) = Alltrim(kontoplaan2005.d)
		If !Found()
			Wait Window 'tp puudub:'+kontoplaan2005.d Nowait
			lcString = "insert into library (rekvid, kood, nimetus, tun1, tun2, tun3, tun4, tun5,library) values (2,'"+;
				LTRIM(Rtrim(kontoplaan2005.d))+"','"+Ltrim(Rtrim(kontoplaan2005.g))+","+;
					kontoplaan2005.f+"',0,0,0,0,0,'TP')"

			lError = SQLEXEC(gnhandle,lcString,'qryId')
			If lError < 0
				Set Step On
				Exit
			Endif

		Endif
	Endscan


Endif
Set Step On

If lError > 0
	lError = SQLEXEC(gnhandle,'commit')
Else
	lError = SQLEXEC(gnhandle,'rollback')
Endif


