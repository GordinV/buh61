If !Used ('config')
	Use config In 0
Endif

*!*	Create Cursor curKey (versia m)
*!*	Append Blank
*!*	Replace versia With 'EELARVE' In curKey
*!*	Create Cursor v_account (admin Int Default 1)
*!*	Append Blank
*!*	*!*	gnhandle = SQLConnect ('buhdata5zur','zinaida','159')
*!*	*gnhandle = sqlconnect ('NARVA','vladislav','490710')
*!*	*!*	*!*	*!*	*!*	*!*	&&,'zinaida','159')
*!*	*!*	grekv = 1

*!*	grekv = 1
*!*	gnHandle = 1
*!*	gversia = 'VFP'

*gnhandle = sqlconnect ('NarvaLvPg','vlad','490710')
*gversia = 'PG'
Local lError

*!*	If v_account.admin < 1
*!*		Return .T.
*!*	Endif
If !Used ('key')
	Use Key In 0
Endif
Select Key
lnFields = Afields (aObjekt)
Create Cursor qryKey From Array aObjekt
Select qryKey
Append From Dbf ('key')
Use In Key
=secure('OFF')
&& обновляем параметры отчетов

	IF USED('curprinter')
		USE IN curPrinter
	ENDIF

	lcFile = 'eelarve\curprinter.dbf'
	USE (lcFile) IN 0 ALIAS curPrinter

	SELECT curPrinter
	LOCATE FOR LOWER(objekt) = 'avans' AND id = 1
	IF !FOUND()
		* avans, lisamine
		APPEND BLANK
		replace id WITH 1,;
			objekt WITH 'Avans',;
			nimetus1 WITH 'Авансовый отчет',;
			nimetus2 WITH 'Avansiarunne',;
			procfail WITH 'avans_report1',;
			reportfail WITH 'avans_report1',;
			reportvene WITH 'avans_report1' IN curprinter
	ENDIF

	SELECT curPrinter
	LOCATE FOR LOWER(objekt) = 'lahetuskulud' AND id = 1
	IF !FOUND()
		* avans, lisamine
		APPEND BLANK
		replace id WITH 1,;
			objekt WITH 'Lahetuskulud',;
			nimetus1 WITH 'Авансовый отчет',;
			nimetus2 WITH 'Avansiarunne',;
			procfail WITH 'avans_report1',;
			reportfail WITH 'avans_report1',;
			reportvene WITH 'avans_report1' IN curprinter
	ENDIF

	LOCATE FOR LOWER(objekt) = 'lahetuskulud' AND id = 2
	IF !FOUND()
		* avans, lisamine
		APPEND BLANK
		replace id WITH 2,;
			objekt WITH 'Lahetuskulud',;
			nimetus1 WITH 'Авансовые отчеты',;
			nimetus2 WITH 'Avansiarunned',;
			procfail WITH 'avans_report2',;
			reportfail WITH 'avans_report2',;
			reportvene WITH 'avans_report2' IN curprinter
	ENDIF

	LOCATE FOR LOWER(objekt) = 'lahetuskulud' AND id = 3
	IF !FOUND()
		* avans, lisamine
		APPEND BLANK
		replace id WITH 3,;
			objekt WITH 'Lahetuskulud',;
			nimetus1 WITH 'Авансовый отчет (Ведомость)',;
			nimetus2 WITH 'Avansiarunne (andmik)',;
			procfail WITH 'avans_report3',;
			reportfail WITH 'avans_report3',;
			reportvene WITH 'avans_report3' IN curprinter
	ENDIF

	LOCATE FOR LOWER(objekt) = 'aruanne' AND id = 26
	IF !FOUND()
		APPEND BLANK
		replace id WITH 26,;
			objekt WITH 'Aruanne',;
			nimetus1 WITH 'Кассовая книга',;
			nimetus2 WITH 'Kassaraamat',;
			procfail WITH 'kassaraamat_report1',;
			reportfail WITH 'kassaraamat_report1',;
			reportvene WITH 'kassaraamat_report1' IN curprinter
	ENDIF


	USE IN curPrinter

	lcFile = 'curprinter.dbf'
	USE (lcFile) IN 0 ALIAS curPrinter

	SELECT curPrinter
	LOCATE FOR LOWER(objekt) = 'avans' AND id = 1
	IF !FOUND()
		* avans, lisamine
		APPEND BLANK
		replace id WITH 1,;
			objekt WITH 'Avans',;
			nimetus1 WITH 'Авансовый отчет',;
			nimetus2 WITH 'Avansiarunne',;
			procfail WITH 'avans_report1',;
			reportfail WITH 'avans_report1',;
			reportvene WITH 'avans_report1' IN curprinter
	ENDIF

	SELECT curPrinter
	LOCATE FOR LOWER(objekt) = 'lahetuskulud' AND id = 1
	IF !FOUND()
		* avans, lisamine
		APPEND BLANK
		replace id WITH 1,;
			objekt WITH 'Lahetuskulud',;
			nimetus1 WITH 'Авансовый отчет',;
			nimetus2 WITH 'Avansiarunne',;
			procfail WITH 'avans_report1',;
			reportfail WITH 'avans_report1',;
			reportvene WITH 'avans_report1' IN curprinter
	ENDIF

	LOCATE FOR LOWER(objekt) = 'lahetuskulud' AND id = 2
	IF !FOUND()
		* avans, lisamine
		APPEND BLANK
		replace id WITH 2,;
			objekt WITH 'Lahetuskulud',;
			nimetus1 WITH 'Авансовые отчеты',;
			nimetus2 WITH 'Avansiarunned',;
			procfail WITH 'avans_report2',;
			reportfail WITH 'avans_report2',;
			reportvene WITH 'avans_report2' IN curprinter
	ENDIF

	LOCATE FOR LOWER(objekt) = 'lahetuskulud' AND id = 3
	IF !FOUND()
		* avans, lisamine
		APPEND BLANK
		replace id WITH 3,;
			objekt WITH 'Lahetuskulud',;
			nimetus1 WITH 'Авансовый отчет (Ведомость)',;
			nimetus2 WITH 'Avansiarunne (andmik)',;
			procfail WITH 'avans_report3',;
			reportfail WITH 'avans_report3',;
			reportvene WITH 'avans_report3' IN curprinter
	ENDIF

	LOCATE FOR LOWER(objekt) = 'aruanne' AND id = 26
	IF !FOUND()
		APPEND BLANK
		replace id WITH 26,;
			objekt WITH 'Aruanne',;
			nimetus1 WITH 'Кассовая книга',;
			nimetus2 WITH 'Kassaraamat',;
			procfail WITH 'kassaraamat_report1',;
			reportfail WITH 'kassaraamat_report1',;
			reportvene WITH 'kassaraamat_report1' IN curprinter
	ENDIF


	USE IN curPrinter

	IF !USED('aruanne')
		USE aruanne IN 0
	endif
	SELECT aruanne
	LOCATE FOR id = 26
	IF !FOUND()
		APPEND BLANK
	ENDIF
	replace id WITH 26,;
			objekt WITH 'Aruanne',;
			kpv1 WITH 1,;
			kpv2 WITH 1,;
			tunnus WITH 0,;
			konto WITH 0,;
			kood1 WITH 0,;
			kood2 WITH 0,;
			kood3 WITH 0,;
			kood4 WITH 0,;
			kood5 WITH 0


Do Case
	Case gversia = 'VFP'
		lcdefault = Sys(5)+Sys(2003)
		Select qryKey
		Scan For Mline(qryKey.Connect,1) = 'FOX'
			lcdata = Mline(qryKey.vfp,1)
			If File (lcdata)
				lcdataproc = lcdefault+'\tmp\2605proc.prn'
				If file (lcdataproc)
*					Append proc from (lcdataproc) overwrite
					IF DBUSED('buhdata5')
						SET DATABASE TO buhdata5
						CLOSE DATABASES 
					ENDIF
					IF USED('buhdata5')
						USE IN buhdata5
					endif
					USE (lcData) in 0 exclusive
					SELECT buhdata5	
					LOCATE FOR objectid = 3
					APPEND MEMO buhdata5.code FROM (lcDataproc) overwrite					
					USE 

				Endif
				Open Data (lcdata) EXCLUSIVE 
				COMPILE DATABASE (lcData)
				SET DATABASE TO buhdata5
				Set Default To Justpath (lcdata)
				lError =  _alter_vfp()
				Close Data
				Set Default To (lcdefault)
			Endif
		Endscan
		Use In qryKey
	Case gversia = 'PG'
		=sqlexec (gnHandle,'begin transaction')
		lError = _alter_pg ()
		If Vartype (lError ) = 'N'
			lError = Iif( lError = 1,.T.,.F.)
		Endif
		If lError = .F.
			=sqlexec (gnHandle,'rollback')
		Else
			=sqlexec (gnHandle,'commit')
		Endif
Endcase

*!*	If lError = .f.
*!*		Messagebox ('Viga')
*!*	Endif
If gversia <> 'VFP'
	=sqldisconnect (gnHandle)
*!*	else
*!*		set data to buhdata5
*!*		close data
Endif
Return lError

Function _alter_vfp

	lnObj = Adbobjects(laObj,'TABLE')
	
	lnresult = Ascan(laObj,'TUNNUSINF')
	If lnresult = 0
		Create Table tunnusinf (Id Int Autoinc Primary Key, tunnusid Int, kontoid Int, rekvid Int, algsaldo Y Default 0, muud m)
		Index On tunnusid Tag tunnusid
		Index On kontoid Tag kontoid
		Index On rekvid Tag rekvid

		If !Used('library')
			Use Library In 0
		Endif
		Select Library
		Scan For Library = 'TUNNUS'
			Select tunnusinf
			Count To lnCount For tunnusid = Library.Id
			If lnCount = 0
				Insert Into tunnusinf (tunnusid,kontoid, rekvid ) ;
					SELECT Library.Id, kontod.Id, Library.rekvid From Library kontod Where Library = 'KONTOD'
			Endif
		Endscan
	Endif
	
	

	lnresult = Ascan(laObj,'AVANS1')
	If lnresult = 0
		Create Table avans1 (Id Int Autoinc Primary Key, rekvid Int, Userid Int, asutusId Int, kpv d Default Date(),;
			number c(20) Default Space(1), selg m Default Space(1), journalid Int Default 0, muud m, ;
			dokpropId Int Default 0)
		Index On rekvid Tag rekvid
		Index On asutusId Tag asutusId
		Index On journalid Tag journalid
	Endif

	If !Used('avans1')
		Use avans1 In 0
	Endif
	Select avans1
	lnObj = Afields(aObj)
	Use In avans1
	If lnObj < 1
		Return .F.
	Endif

	lnElement = Ascan(aObj,Upper('DOKPROPID'))
	If lnElement < 1
		Alter Table avans1 Add Column dokpropId Int Default 0
	Endif

	lnElement = Ascan(aObj,Upper('USERID'))
	If lnElement < 1
		Alter Table avans1 Add Column Userid Int Default 0
	Endif


	lnresult = Ascan(laObj,'AVANS2')
	If lnresult = 0
		Create Table avans2 (Id Int Autoinc Primary Key, parentid Int, nomid Int, ;
			konto c(20), kood1 c(20), kood2 c(20), kood3 c(20), kood4 c(20), kood5 c(20),;
			tunnus c(20),;
			Summa Y, kbm Y, kokku Y, muud m)
		Index On parentid Tag parentid
		Index On nomid Tag nomid
	Endif

* родительская плата
	lnresult = Ascan(laObj,'TULUD1')
	If lnresult = 0
		Create Table tulud1 (Id Int Autoinc Primary Key, rekvid Int, kpv d Default Date(), journalid Int,Summa Y,;
			dokpropId Int,  muud m)
		Index On dokpropId Tag dokpropId
		Index On rekvid Tag rekvid
		Index On kpv Tag kpv
		Index On journalid Tag journalid
	Endif
	lnresult = Ascan(laObj,'TULUD2')
	If lnresult = 0
		Create Table tulud2 (Id Int Autoinc Primary Key, parentid Int, isikukood1 c(20), isik1 c(254), ;
			isikukood2 c(20), isik2 c(254), Summa Y, konto c(20),;
			tunnus c(20), kood1 c(20), kood2 c(20),	kood3 c(20), kood4 c(20), kood5 c(20), muud m)
		Index On parentid Tag parentid

	Endif


	If !Used('tulud1')
		Use tulud1 In 0
	Endif
	Select tulud1
	lnObj = Afields(aObj)
	Use In tulud1
	If lnObj < 1
		Return .F.
	Endif
	lnElement = Ascan(aObj,Upper('LIIK'))
	If lnElement < 1
		Alter Table tulud1 Add Column liik Int Default 1
	Endif

	lnElement = Ascan(aObj,Upper('KONTO'))
	If lnElement < 1
		Alter Table tulud1 Add Column konto c(20) Default '100100'
	Endif
	lnElement = Ascan(aObj,Upper('USERID'))
	If lnElement < 1
		Alter Table tulud1 Add Column Userid Int Default 0
	Endif

	If Used('tulud1')
		Use In tulud1
	Endif


	If !Used('palk_jaak')
		Use palk_jaak In 0
	Endif
	Select palk_jaak
	lnObj = Afields(aObj)
	Use In palk_jaak
	If lnObj < 1
		Return .F.
	Endif
	lnElement = Ascan(aObj,Upper('G31'))
	If lnElement < 1
		Alter Table palk_jaak Add Column g31 y Not Null Default 1400
	Endif
	If Used('palk_jaak')
		Use In palk_jaak
	Endif



	CREATE SQL VIEW curpalkoper3_ AS  ;
		SELECT palk_oper.summa, palk_oper.kpv, palk_oper.rekvid, asutus.nimetus AS isik, asutus.regkood AS isikukood, ;
		palk_lib.liik, palk_lib.asutusest, osakond.kood AS okood, amet.kood AS akood   ;
		FROM palk_oper   INNER JOIN palk_lib ON palk_oper.libid = palk_lib.parentid  ;
		INNER JOIN tooleping ON palk_oper.lepingid = tooleping.id   ;
		INNER JOIN asutus ON tooleping.parentid = asutus.id  ;
		INNER JOIN library osakond ON osakond.id = tooleping.osakondid  ;
		INNER JOIN library amet ON amet.id = tooleping.ametid


	Create Sql View curPalkJaak_;
		AS;
		SELECT Asutus.regkood, Asutus.nimetus, Asutus.aadress, Asutus.tel,;
		Palk_jaak.kuu, Palk_jaak.aasta, Palk_jaak.Id, Palk_jaak.jaak,;
		Palk_jaak.arvestatud, Palk_jaak.kinni, Palk_jaak.tki, Palk_jaak.tka,;
		Palk_jaak.pm, Palk_jaak.tulumaks, Palk_jaak.sotsmaks, Palk_jaak.muud,;
		Asutus.rekvid, Palk_jaak.g31;
		FROM ;
		Palk_jaak ;
		INNER Join Tooleping ;
		ON  Palk_jaak.lepingid = Tooleping.Id ;
		INNER Join Asutus ;
		ON  Tooleping.parentid = Asutus.Id


	Create Sql View qrySaldoAruanne;
		AS;
		SELECT deebet As konto, kreedit As korkonto, lisa_d As tp, kood1 As tegev, kood2 As allikas, kood3 As rahavoo,;
		VAL(Str(Summa,12,2)) As deebet, Val('000000000.00') As kreedit, rekvid, tunnus, kpv, kood5 ;
		FROM curJournal_ ;
		UNION All;
		SELECT kreedit As konto, deebet As korkonto, lisa_k As tp, kood1 As tegev, kood2 As allikas, kood3 As rahavoo, ;
		VAL('000000000.00')  As deebet,  Val(Str(Summa,12,2)) As kreedit, rekvid, tunnus, kpv, kood5 ;
		FROM curJournal_

	Create Sql View curJournal_;
		AS;
		SELECT Journal.Id, Journal.rekvid, Journal.kpv, Journal.asutusId,;
		MONTH(Journal.kpv) As kuu, Year(Journal.kpv) As aasta,;
		LEFT(Mline(Journal.selg,1),254) As selg, Journal.dok, Journal1.Summa,;
		Journal1.valsumma, Journal1.valuuta, Journal1.kuurs, Journal1.kood1,;
		Journal1.kood2, Journal1.kood3, Journal1.kood4, Journal1.kood5,;
		Journal1.tunnus, Journal1.deebet, Journal1.kreedit, Journal1.lisa_d,;
		Journal1.lisa_k,;
		IIF(Isnull(Asutus.Id),Space(120),Left(Rtrim(Asutus.nimetus)+Space(1)+Rtrim(Asutus.omvorm),120)) As Asutus,;
		journalid.Number, Left(Mline(Journal.muud,1),254) As muud, Left(Userid.ametnik,120) As kasutaja;
		FROM  buhdata5!Journal  INNER Join buhdata5!Journal1 On  Journal.Id = Journal1.parentid ;
		INNER Join buhdata5!journalid On  Journal.Id = ( journalid ) ;
		INNER Join buhdata5!Userid On  Journal.Userid = Userid.Id ;
		LEFT Outer Join Asutus  On  Journal.asutusId = Asutus.Id


	=setpropview()

* menu records

	If !Used('menumodul')
		Use menumodul In 0
	Endif
	If !Used('menupohi')
		Use menupohi In 0 Order Id
	Endif
	If !Used('menuisik')
		Use menuisik In 0
	Endif

	Select menupohi
	Locate For Pad = 'File' And Bar = '4'
	If !Found()
		lcOmandus = 'RUS CAPTION=Авансовые отчеты'+Chr(13)+'EST CAPTION=Lahetuskulud'
		lcproc = "oLahetuskulud = nObjekt('lahetuskulud','oLahetuskulud')"

		Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
			('File','4',lcproc, lcOmandus, 1)

		Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)


		lcOmandus = 'RUS CAPTION=Авансовые отчеты'+Chr(13)+'EST CAPTION=Lahetuskulud'
		lcproc = "oLahetuskulud = nObjekt('lahetuskulud','oLahetuskulud')"


		Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
			('Lahetuskulud','','', lcOmandus, 2)

		Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)


		lcOmandus = 'RUS CAPTION=Добавить запись'+Chr(13)+'EST CAPTION=Lisamine'+Chr(13)+'KeyShortCut=CTRL+A'
		lcproc = 'gcWindow.add'

		Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
			('Lahetuskulud','1',lcproc, lcOmandus, 2)

		Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)

		lcOmandus = 'RUS CAPTION=Внести изменения'+Chr(13)+'EST CAPTION=Muutmine'+Chr(13)+'KeyShortCut=CTRL+E'
		lcproc = 'gcWindow.edit'

		Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
			('Lahetuskulud','2',lcproc, lcOmandus, 2)

		Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)

		lcOmandus = 'RUS CAPTION=Удалить запись'+Chr(13)+'EST CAPTION=Kustutamine'+Chr(13)+'KeyShortCut=CTRL+DEL'
		lcproc = 'gcWindow.delete'

		Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
			('Lahetuskulud','3',lcproc, lcOmandus, 2)

		Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)

		lcOmandus = 'RUS CAPTION=Печать'+Chr(13)+'EST CAPTION=Trьkkimine'+Chr(13)+'KeyShortCut=CTRL+P'
		lcproc = 'gcWindow.print'

		Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
			('Lahetuskulud','4',lcproc, lcOmandus, 2)

		Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
		Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)

	Endif



	Return

Function setpropview
	Set Data To buhdata5
	lnViews = Adbobject (laView,'VIEW')
	For i = 1 To lnViews
		lError = DBSetProp(laView(i),'View','FetchAsNeeded',.T.)
	Endfor
	Return


Function _alter_pg

Endfunc




Function _alter_mssql


*!*		cString = "sp_help"
*!*		lError = sqlexec (gnHandle,cString)
*!*		If lError > 0
*!*			If Used ('sqlresult')
*!*				Select sqlresult
*!*				Locate For Upper(Name) = 'PALK_TMPL' And object_type = 'user table'
*!*				If !Found ()
*!*					cString = 'create table dbo.palk_tmpl (id int IDENTITY (1, 1) NOT NULL  PRIMARY KEY,'+;
*!*						'parentid int NOT NULL default 0, libId int NOT NULL default 0, summa money NOT NULL default 100,'+;
*!*						'percent_  int NOT NULL default 1,'+;
*!*						'tulumaks int NOT NULL default 1, tulumaar int NOT NULL default 26, tunnusid int NOT NULL default 0)'

*!*					lError = sqlexec(gnHandle, cString)

*!*					cString = 'GRANT  SELECT ,  UPDATE ,  INSERT,  DELETE  ON dbo.palk_tmpl  TO dbkasutaja'
*!*					= sqlexec(gnHandle, cString)
*!*					cString = 'GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON dbo.palk_tmpl  TO dbpeakasutaja'
*!*					= sqlexec(gnHandle, cString)
*!*					cString = 'GRANT  SELECT  ON dbo.palk_tmpl  TO dbadmin'
*!*					= sqlexec(gnHandle, cString)

*!*				Endif

*!*			Endif
*!*		Endif

*!*		If Used ('sqlresult')
*!*			Use In sqlresult
*!*		Endif
*!*		If lError < 0
*!*			Return .F.
*!*		Endif
Endproc



Function secure
	Lparameters LCENCR
	maxno=100
	LCENCR=Upper(Allt(LCENCR))
	If LCENCR<>'ON' And LCENCR<>'OFF'
		Return Messagebox("Pass ON or OFF for encryption/decryption!")
	Endif
&&SET PROC TO securedata ADDI
* loop through all fields in a table
	lnFields=Fcount()
	For J = 1 To lnFields
		LCFIELD=Field(J)
		Do Case
			Case Type(LCFIELD) $ 'CM'
* replace the all the contents of this particular field
				Repl All &LCFIELD With CONVRT(LCENCR,&LCFIELD)
		Endcase
	Endfor



Procedure CONVRT
	Lparameters lcencrypt,lcString
	If Parameters()<2
		Messagebox('Pass two arguments, [On Off] and string')
		Return
	Endif
	lcencrypt=Upper(Allt(lcencrypt))
* encrypt data
* take a string and shift the data to the right one place
	If lcencrypt='ON'
		lnlen=Len(Allt(lcString))
		lcnewstring=''
* convert the string to the value of the current string + the position
* number of the char in the string.  A string of "ABC" would be converted
* to "BDF"

		For i = 1 To lnlen
* asc(substring(lcstring,i,1)) for a "d" is 100
* so if the "d" were in the 1st position it would be converted
* to "e" via the following line
			If i<maxno
				lcchar=Chr(Asc(Substr(lcString,i,1))+i)
			Else
				lcchar=Chr(Asc(Substr(lcString,i,1))+1)
			Endif
*build new string from converted characters
			lcnewstring=lcnewstring+lcchar
		Endfor
		RETVAL=lcnewstring
	Else
		lnlen=Len(Allt(lcString))
		lcnewstring=''
		For i = 1 To lnlen
* asc(substring(lcstring,i,1)) for a "d" is 100
* so if the "d" were in the 1st position it would be converted
* to "e" via the following line
			If i<maxno
				lcchar=Chr(Asc(Substr(lcString,i,1))-i)
			Else
				lcchar=Chr(Asc(Substr(lcString,i,1))-1)
			Endif

*build new string from converted characters
			lcnewstring=lcnewstring+lcchar
		Endfor
		RETVAL=lcnewstring
	Endif
	Return (RETVAL)



