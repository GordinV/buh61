If !Used ('config')
	Use config In 0
Endif

Create Cursor curKey (versia m)
Append Blank
Replace versia With 'EELARVE' In curKey
Create Cursor v_account (admin Int Default 1)
Append Blank
*!*	gnhandle = SQLConnect ('buhdata5zur','zinaida','159')
*gnhandle = sqlconnect ('NARVA','vladislav','490710')
*!*	*!*	*!*	*!*	*!*	&&,'zinaida','159')
*!*	gversia = 'MSSQL'
*!*	grekv = 1

grekv = 1
gnHandle = 1

gnhandle = sqlconnect ('NarvaLvPg','vlad','490710')
gversia = 'PG'
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

*!*		IF USED('curprinter')
*!*			USE IN curPrinter
*!*		ENDIF

*!*		lcFile = 'eelarve\curprinter.dbf'
*!*		USE (lcFile) IN 0 ALIAS curPrinter

*!*		SELECT curPrinter
*!*		LOCATE FOR LOWER(objekt) = 'eelarvearuanne' AND id = 381
*!*		IF !FOUND()
*!*			* koolitus tasu, lisamine 
*!*			APPEND BLANK
*!*			replace id WITH 381,;
*!*				objekt WITH 'EelarveAruanne',;
*!*				nimetus1 WITH 'Главная книга в разрезе доходов и расходов',;
*!*				nimetus2 WITH 'Pearaamat tulude ja kulude sisu jдrgi',;
*!*				procfail WITH 'eelarve\pearaamat_report2',;
*!*				reportfail WITH 'eelarve\pearaamat_report2',;
*!*				reportvene WITH 'eelarve\pearaamat_report2' IN curprinter
*!*		ENDIF
*!*		IF !USED('aruanne')
*!*			USE aruanne IN 0 
*!*		endif
*!*		SELECT aruanne
*!*		LOCATE FOR id = 38
*!*		IF !FOUND()
*!*			APPEND BLANK
*!*		ENDIF	
*!*		replace id WITH 38,;
*!*				objekt WITH 'EelarveAruanne',;
*!*				kpv1 WITH 0,;
*!*				kpv2 WITH 1,;
*!*				tunnus WITH 1,;
*!*				konto WITH 1,;
*!*				kood1 WITH 1,;
*!*				kood2 WITH 1,;
*!*				kood3 WITH 1,;
*!*				kood4 WITH 1,;
*!*				kood5 WITH 1			


Do Case
	Case gversia = 'VFP'
		lcdefault = Sys(5)+Sys(2003)
		Select qryKey
		Scan For Mline(qryKey.Connect,1) = 'FOX'
			lcdata = Mline(qryKey.vfp,1)
			If File (lcdata)
				Open Data (lcdata)
*!*					lcdataproc = lcdefault+'\tmp\0909proc.prn'
*!*					If file (lcdataproc)
*!*						Append proc from (lcdataproc) overwrite
*!*					Endif
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
		If lError = .f.
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

	* добавляем таблицы на сальдо по Rahavoo, Allikad
	
&& создание новых таблиц
* сальдо по признакам

	
	lnObj = Adbobjects(laObj,'TABLE')
	lnresult = Ascan(laObj,'EELARVEINF')
	If lnresult = 0
		Create Table eelarveinf (Id Int Autoinc Primary Key, AllikadId Int DEFAULT 0, RahavooId Int DEFAULT 0, kontoid Int, rekvid Int, algsaldo Y Default 0, muud m)
		Index On allikadid Tag allikadid
		Index On Rahavooid Tag Rahavooid
		Index On kontoid Tag kontoid
		Index On rekvid Tag rekvid

		If !Used('library')
			Use Library In 0
		Endif

	IF !USED('qryRekv')
		SELECT * from rekv INTO CURSOR qryrekv
	ENDIF
	IF !USED('qryAllikad')
		SELECT * from library WHERE library = 'ALLIKAD' INTO CURSOR qryAllikad
	ENDIF
	IF !USED('qryRahavoo')
		SELECT * from library WHERE library = 'RAHA' INTO CURSOR qryRahavoo
	ENDIF
	
		Select Library
*		Count To lnCount For LIBRARY = 'KONTOD' OR LIBRARY = 'RAHA' OR LIBRARY = 'ALLIKAD'
		SCAN FOR library = 'KONTOD'	
			lnKontoId = RECNO('library')
			lnLibId = library.id		
			SELECT qryRekv	
			scan	
				* kontrol for allikad
				SELECT allikadId, id FROM eelarveinf ;
					WHERE kontoid = lnLibid AND rekvid = qryrekv.id AND allikadId > 0;
					INTO CURSOR qryEel
				
				SELECT id FROM qryAllikad ;
					WHERE id NOT in (select allikadId FROM qryEel WHERE kontoid = lnLibid AND rekvid = qryRekv.id) INTO CURSOR qryEel2
				
				SELECT qryEel2 
				scan
					Insert Into eelarveinf (allikadid,kontoid, rekvid ) VALUES (;
						qryEel2.Id, lnLibid, qryRekv.id )
				endscan

				* kontrol for rahavoo
				SELECT RahavooId, id FROM eelarveinf WHERE kontoid = lnLibid AND rekvid = qryrekv.id AND RahavooId > 0;
				INTO CURSOR qryRaha
				SELECT id FROM qryRahavoo WHERE id NOT in (select RahavooId FROM qryRaha WHERE kontoid = lnLibid AND rekvid = qryRekv.id) INTO CURSOR qryRaha2
				SELECT qryRaha2 
				scan
					Insert Into eelarveinf (rahavooid,kontoid, rekvid ) VALUES (;
						qryRaha2.Id, lnLibid, qryRekv.id )
				endscan
				USE IN qryEel
				USE IN qryEEl2
				USE IN qryRaha
				USE IN qryRaha2
				
			ENDSCAN
			SELECT library
			GO lnKontoId
		Endscan
	Endif


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
		scan For Alltrim(Upper(Pad)) = 'DOKLAUSEND'
			SELECT menumodul
			LOCATE FOR parentid = menupohi.id AND 'MODUL' = 'RAAMA'
			IF !FOUND()
				INSERT INTO menumodul (parentid, modul) VALUES (menupohi.id, 'RAAMA')
			ENDIF
			SELECT menuisik
			LOCATE FOR parentid = menupohi.id AND 'GRUPPID' = 'KASUTAJA'
			IF !FOUND()
				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
			ENDIF
			
		ENDSCAN
		Select menupohi
		scan For Alltrim(Upper(Pad)) = 'OSAKONNAD'
			SELECT menumodul
			LOCATE FOR parentid = menupohi.id AND 'MODUL' = 'PALK'
			IF !FOUND()
				INSERT INTO menumodul (parentid, modul) VALUES (menupohi.id, 'PALK')
			ENDIF
			SELECT menuisik
			LOCATE FOR parentid = menupohi.id AND 'GRUPPID' = 'KASUTAJA'
			IF !FOUND()
				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
			ENDIF
			
		ENDSCAN
		Select menupohi
		scan For Alltrim(Upper(Pad)) = 'TEENUSED'
			SELECT menumodul
			LOCATE FOR parentid = menupohi.id AND 'MODUL' = 'RAAMA'
			IF !FOUND()
				INSERT INTO menumodul (parentid, modul) VALUES (menupohi.id, 'RAAMA')
			ENDIF
			SELECT menuisik
			LOCATE FOR parentid = menupohi.id AND 'GRUPPID' = 'KASUTAJA'
			IF !FOUND()
				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
			ENDIF
			
		ENDSCAN
		
*!*		If !Found()
*!*			Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
*!*				('RUS CAPTION=Расходы на обучение'+Chr(13)+'EST CAPTION=Koolitus kulud',;
*!*				"oVanemtasu = nObjekt('vanemtasu','oVanemtasu',0)", 1,'File','39')

*!*			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)


*!*			Insert Into menupohi (omandus, level_, Pad ) Values ;
*!*				('RUS CAPTION=Родительская плата'+CHR(13)+'EST CAPTION=Koolituse tulud',;
*!*				 2,'VANEMTASU')


*!*			Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
*!*				('RUS CAPTION=Добавить запись'+CHR(13)+'EST CAPTION=Lisamine'+CHR(13)+'KeyShortCut=CTRL+A',;
*!*				"gcWindow.add()", 2,'VANEMTASU','1')
*!*			Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
*!*				('RUS CAPTION=Внести изменения'+CHR(13)+'EST CAPTION=Muutmine'+CHR(13)+'KeyShortCut=CTRL+E',;
*!*				"gcWindow.edit()", 2,'VANEMTASU','2')
*!*			Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
*!*				('RUS CAPTION=Удалить запись'+CHR(13)+'EST CAPTION=Kustutamine'+CHR(13)+'KeyShortCut=CTRL+DEL',;
*!*				"gcWindow.delete()", 2,'VANEMTASU','3')
*!*			Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
*!*				('RUS CAPTION=Печать'+CHR(13)+'EST CAPTION=Trьkk'+CHR(13)+'KeyShortCut=CTRL+P',;
*!*				"gcWindow.print()", 2,'VANEMTASU','4')



		

	Set Default To (lcdefault)

	CREATE CURSOR comKontodRemote (id int, KOOD C(20), NIMETUS C(254), TUN1 INT, TUN2 INT, tun3 int, tun4 int, tun5 int)
	INSERT INTO comKontodRemote (id, KOOD, NIMETUS, TUN1, TUN2, tun3, tun4, tun5);
	select id, kood, nimetus, tun1, tun2, tun3, tun4, tun5 from library where library = 'KONTOD'
	
	IF FILE('kontoplaan.dbf')
		* Правим план.счетов
		IF USED('kontoplaan')
			USE IN kontoplaan
		ENDIF
		
		USE kontoplaan IN 0
		SELECT kontoplaan
		SCAN FOR !EMPTY(n6)
			WAIT WINDOW 'Kontrolin konto :'+kontoplaan.n6 nowait
			lnTun1 = IIF(EMPTY(kontoplaan.n10),0,1)
			lnTun2 = IIF(EMPTY(kontoplaan.n11),0,1)
			lnTun3 = IIF(EMPTY(kontoplaan.n12),0,1)
			lnTun4 = IIF(EMPTY(kontoplaan.n13),0,1)

			SELECT comKontodRemote
			LOCATE FOR ALLTRIM(kood) = ALLTRIM(kontoplaan.n6)
			IF !FOUND()
				INSERT into library (rekvid, kood, nimetus, tun5, library) VALUES (grekv, ;
					ALLTRIM(kontoplaan.n6), LTRIM(RTRIM(kontoplaan.n9)), ;
					IIF(LEFT(ALLTRIM(kontoplaan.n6),1)='2' OR LEFT(ALLTRIM(kontoplaan.n6),1)='3',2,1),'KONTOD') 
				INSERT INTO comKontodRemote (id, KOOD, NIMETUS, tun5) VALUES (;
					library.id, ALLTRIM(kontoplaan.n6), LTRIM(RTRIM(kontoplaan.n9)), ;
					IIF(LEFT(ALLTRIM(kontoplaan.n6),1)='2' OR LEFT(ALLTRIM(kontoplaan.n6),1)='3',2,1)) 
				
				INSERT INTO kontoinf (parentid, rekvid);
					SELECT library.id, rekv.ID FROM rekv 

				INSERT INTO tunnusinf (kontoid, rekvid, tunnusid);
					SELECT library.id, tunnus.rekvID, tunnus.id FROM library tunnus WHERE library = 'TUNNUS' 
										
			ENDIF
				IF EMPTY(comKontodRemote.tun1) AND !EMPTY(lnTun1)
					update library SET tun1 = 1 WHERE id = comKontodRemote.id
				ENDIF
				IF EMPTY(comKontodRemote.tun2) AND !EMPTY(lnTun2)
					update library SET tun2 = 1 WHERE id = comKontodRemote.id
				ENDIF
				IF EMPTY(comKontodRemote.tun3) AND !EMPTY(lnTun3)
					update library SET tun3 = 1 WHERE id = comKontodRemote.id
				ENDIF
				IF EMPTY(comKontodRemote.tun4) AND !EMPTY(lnTun4)
					update library SET tun4 = 1 WHERE id = comKontodRemote.id
				ENDIF
				IF !EMPTY(comKontodRemote.tun1) AND EMPTY(lnTun1)
					update library SET tun1 = 0 WHERE id = comKontodRemote.id
				ENDIF
				IF !EMPTY(comKontodRemote.tun2) AND EMPTY(lnTun2)
					update library SET tun2 = 0 WHERE id = comKontodRemote.id
				ENDIF
				IF !EMPTY(comKontodRemote.tun3) AND EMPTY(lnTun3)
					update library SET tun3 = 0 WHERE id = comKontodRemote.id
				ENDIF
				IF !EMPTY(comKontodRemote.tun4) AND EMPTY(lnTun4)
					update library SET tun4 = 0 WHERE id = comKontodRemote.id
				ENDIF

		endscan

	ENDIF
	


*!*		Create Sql View qrySaldoAruanne;
*!*			AS;
*!*			SELECT deebet As konto, kreedit as korkonto, lisa_d As tp, kood1 As tegev, kood2 As allikas, kood3 As rahavoo,;
*!*			VAL(Str(Summa,12,2)) As deebet, Val('000000000.00') As kreedit, rekvid, tunnus, kpv, KOOD5 ;
*!*			FROM curJournal_ ;
*!*			UNION All;
*!*			SELECT kreedit As konto, deebet as korkonto, lisa_d As tp, kood1 As tegev, kood2 As allikas, kood3 As rahavoo, ;
*!*			VAL('000000000.00')  As deebet,  Val(Str(Summa,12,2)) As kreedit, rekvid, tunnus, kpv, KOOD5 ;
*!*			FROM curJournal_




&& создание новых таблиц
* сальдо по признакам

*!*		lnObj = Adbobjects(laObj,'TABLE')
*!*		lnresult = Ascan(laObj,'TUNNUSINF')
*!*		If lnresult = 0
*!*			Create Table tunnusinf (Id Int Autoinc Primary Key, tunnusid Int, kontoid Int, rekvid Int, algsaldo Y Default 0, muud m)
*!*			Index On tunnusid Tag tunnusid
*!*			Index On kontoid Tag kontoid
*!*			Index On rekvid Tag rekvid

*!*			If !Used('library')
*!*				Use Library In 0
*!*			Endif
*!*			Select Library
*!*			Scan For Library = 'TUNNUS'
*!*				Select tunnusinf
*!*				Count To lnCount For tunnusid = Library.Id
*!*				If lnCount = 0
*!*					Insert Into tunnusinf (tunnusid,kontoid, rekvid ) ;
*!*						SELECT Library.Id, kontod.Id, Library.rekvid From Library kontod Where Library = 'KONTOD'
*!*				Endif
*!*			Endscan
*!*		Endif



*!*	* под.отчетники
*!*		lnresult = Ascan(laObj,'AVANS1')
*!*		If lnresult = 0
*!*			Create Table avans1 (Id Int Autoinc Primary Key, rekvid Int, asutusId Int, kpv d Default Date(),;
*!*				number c(20) Default Space(1), selg m Default Space(1), journalid Int Default 0, muud m)
*!*			Index On rekvid Tag rekvid
*!*			Index On asutusId Tag asutusId
*!*			Index On journalid Tag journalid
*!*		Endif
*!*		lnresult = Ascan(laObj,'AVANS2')
*!*		If lnresult = 0
*!*			Create Table avans2 (Id Int Autoinc Primary Key, parentid Int, nomid Int, Summa Y, kbm Y, kokku Y, muud m)
*!*			Index On parentid Tag parentid
*!*			Index On nomid Tag nomid
*!*		Endif

*!*	* родительская плата
*!*		lnresult = Ascan(laObj,'TULUD1')
*!*		If lnresult = 0
*!*			Create Table tulud1 (Id Int Autoinc Primary Key, rekvid Int, kpv d Default Date(), journalid Int,Summa Y,;
*!*			dokpropid int,  muud m)
*!*			Index On dokpropid Tag dokpropid
*!*			Index On rekvid Tag rekvid
*!*			Index On kpv Tag kpv
*!*			Index On journalid Tag journalid
*!*		Endif
*!*		lnresult = Ascan(laObj,'TULUD2')
*!*		If lnresult = 0
*!*			Create Table tulud2 (Id Int Autoinc Primary Key, parentid Int, isikukood1 c(20), isik1 c(254), ;
*!*				isikukood2 c(20), isik2 c(254), Summa Y, konto c(20),;
*!*				tunnus c(20), kood1 c(20), kood2 c(20),	kood3 c(20), kood4 c(20), kood5 c(20), muud m)
*!*			INDEX ON parentid TAG parentid

*!*		Endif



*!*	&& обновляем параметры отчетов
*!*		Set Default To (lcdefault)

*!*		IF USED('curprinter')
*!*			USE IN curPrinter
*!*		ENDIF

*!*		lcFile = 'eelarve\curprinter.dbf'
*!*		USE (lcFile) IN 0 ALIAS curPrinter

*!*		SELECT curPrinter
*!*		LOCATE FOR LOWER(objekt) = 'vanemtasu' AND id = 1
*!*		IF !FOUND()
*!*			* koolitus tasu, lisamine 
*!*			APPEND BLANK
*!*			replace id WITH 1,;
*!*				objekt WITH 'vanemtasu',;
*!*				nimetus1 WITH 'Родительская плата',;
*!*				nimetus2 WITH 'Koolitustulud',;
*!*				procfail WITH 'eelarve\koolitus_report1',;
*!*				reportfail WITH 'eelarve\koolitus_report1',;
*!*				reportvene WITH 'eelarve\koolitus_report1' IN curprinter
*!*		ENDIF
*!*		
*!*		SELECT curPrinter
*!*		LOCATE FOR LOWER(objekt) = lower('EelarveAruanne') AND id = 39
*!*		IF !FOUND()
*!*			* inf3, lisamine 
*!*			APPEND BLANK
*!*			replace id WITH 39,;
*!*				objekt WITH 'EelarveAruanne',;
*!*				nimetus1 WITH 'Декларация INF3',;
*!*				nimetus2 WITH 'Deklaratsioon INF3',;
*!*				procfail WITH 'eelarve\inf3_report1',;
*!*				reportfail WITH 'eelarve\inf3_report1',;
*!*				reportvene WITH 'eelarve\inf3_report1' IN curprinter
*!*		ENDIF


*!*		Use In curprinter



*!*		If !Used('aruanne')
*!*			Use aruanne In 0
*!*		Endif
*!*		Select aruanne
*!*		LOCATE FOR id = 39
*!*		IF !FOUND()
*!*			APPEND BLANK
*!*			replace id WITH 39,;
*!*				objekt WITH 'EelarveAruanne',;
*!*				tunnus WITH 1,;
*!*				kpv1 WITH 1,;
*!*				kpv2 WITH 1 IN aruanne
*!*		ENDIF
*!*		
*!*		
*!*		Scan
*!*			Do Case
*!*				Case Id = 38
*!*					Replace konto With 1,;
*!*						kood1 With 1,;
*!*						kood2 With 1,;
*!*						kood3 With 1,;
*!*						kood4 With 1,;
*!*						kood5 With 1,;
*!*						asutus With 1,;
*!*						tunnus With 1 In aruanne
*!*				Case Id = 31
*!*					Replace konto With 1,;
*!*						kood1 With 1,;
*!*						kood2 With 1,;
*!*						kood3 With 1,;
*!*						kood4 With 0,;
*!*						kood5 With 1,;
*!*						tunnus With 1 In aruanne
*!*				Case Id = 32
*!*					Replace konto With 1,;
*!*						kood1 With 1,;
*!*						kood2 With 1,;
*!*						kood3 With 1,;
*!*						kood4 With 0,;
*!*						kood5 With 1,;
*!*						tunnus With 1 In aruanne
*!*				Case Id = 33
*!*					Replace konto With 1,;
*!*						kood1 With 1,;
*!*						kood2 With 1,;
*!*						kood3 With 1,;
*!*						kood4 With 0,;
*!*						kood5 With 1,;
*!*						tunnus With 1 In aruanne
*!*				Case Id = 331
*!*					Replace konto With 1,;
*!*						kood1 With 1,;
*!*						kood2 With 1,;
*!*						kood3 With 1,;
*!*						kood4 With 0,;
*!*						kood5 With 1,;
*!*						tunnus With 1 In aruanne
*!*				Case Id = 321
*!*					Replace konto With 1,;
*!*						kood1 With 1,;
*!*						kood2 With 1,;
*!*						kood3 With 1,;
*!*						kood4 With 0,;
*!*						kood5 With 1,;
*!*						tunnus With 1 In aruanne
*!*				Case Id = 322
*!*					Replace konto With 1,;
*!*						kood1 With 1,;
*!*						kood2 With 1,;
*!*						kood3 With 1,;
*!*						kood4 With 0,;
*!*						kood5 With 1,;
*!*						tunnus With 1 In aruanne
*!*			Endcase

*!*		ENDSCAN
*!*		
*!*		USE IN aruanne
*!*		

*!*	* создаем представление на curSaldoTunnus

*!*		Create Sql View curSaldoTunnus ;
*!*			as ;
*!*			Select Date(2000,01,01) As kpv, tunnusinf.rekvid, Library.kood As konto,;
*!*			IIF( tunnusinf.algsaldo >= 0, Val(Str(tunnusinf.algsaldo,12,4)), Val(Str(000000000.0000,12,4))) As deebet,;
*!*			IIF( tunnusinf.algsaldo < 0 , Val(Str(-1 * tunnusinf.algsaldo,12,4)), Val(Str(000000000.0000,12,4))) As kreedit,;
*!*			1 As OPT, tunnusid ;
*!*			from Library INNER Join tunnusinf On Library.Id = tunnusinf.kontoid;
*!*			union All ;
*!*			SELECT kpv, curJournal_.rekvid, deebet As konto, Val(Str(Summa,12,4)) As deebet,  ;
*!*			VAL(Str(000000000.0000,12,4)) As kreedit, 4 As OPT, T.Id As tunnusid ;
*!*			from curJournal_ INNER Join Library T On curJournal_.tunnus = T.kood;
*!*			where !Empty(curJournal_.tunnus);
*!*			union All ;
*!*			SELECT kpv, curJournal_.rekvid, kreedit As konto, Val(Str(000000000.0000,12,4)) As deebet,;
*!*			VAL(Str(Summa,12,4))  As kreedit, 4 As OPT, T.Id As tunnusid;
*!*			from curJournal_ INNER Join Library T On curJournal_.tunnus = T.kood;
*!*			where !Empty(curJournal_.tunnus)


*!*	*!*				 Select date(IIF(EMPTY(aasta),1999,aasta), IIF(EMPTY(kuu),1,kuu),1) as kpv, rekvid, konto, ;
*!*	*!*				 VAL(STR(dbkaibed,12,4))  As deebet, VAL(STR(krkaibed,12,4)) As kreedit,;
*!*	*!*				 3 as opt, tunnus AS tunnusId ;
*!*	*!*				 from saldo ;
*!*	*!*				 where tunnusId > 0;
*!*	*!*				 union all ;


*!*	&& создаем представление на сальдовую ведомость

*!*		Create Sql View qrySaldoAruanne;
*!*			AS;
*!*			SELECT deebet As konto, lisa_d As tp, kood1 As tegev, kood2 As allikas, kood3 As rahavoo,;
*!*			VAL(Str(Summa,12,2)) As deebet, Val('000000000.00') As kreedit, rekvid, tunnus, kpv ;
*!*			FROM curJournal_ ;
*!*			UNION All;
*!*			SELECT kreedit As konto, lisa_d As tp, kood1 As tegev, kood2 As allikas, kood3 As rahavoo, ;
*!*			VAL('000000000.00')  As deebet,  Val(Str(Summa,12,2)) As kreedit, rekvid, tunnus, kpv ;
*!*			FROM curJournal_

*!*		Create Sql View curkassakuludetaitmine_;
*!*			AS;
*!*			SELECT kuu, aasta, curJournal_.rekvid, Sum(Summa) As Summa, curJournal_.kood5 As kood, Space(1) As eelarve,;
*!*			curJournal_.kood1 As tegev, curJournal_.tunnus As tun, curJournal_.kood2   ;
*!*			FROM curJournal_   Join kassakulud On Trim(deebet) Like Rtrim(kassakulud.kood);
*!*			INNER  Join kassakontod On Rtrim(curJournal_.kreedit) Like Rtrim(kassakontod.kood);
*!*			GROUP By aasta, kuu, curJournal_.rekvid, curJournal_.deebet, curJournal_.kood1, curJournal_.tunnus,;
*!*			curJournal_.kood5, curJournal_.kood2

*!*		Create Sql View curKassaTuludeTaitmine_;
*!*			as;
*!*			select kuu, aasta, curJournal_.rekvid, curJournal_.tunnus As tun, Sum(Summa) As Summa,;
*!*			curJournal_.kood5 As kood, curJournal_.kood5 As eelarve, curJournal_.kood1 As tegev, curJournal_.kood2;
*!*			from curJournal_ ;
*!*			INNER Join kassatulud On Ltrim(Rtrim(curJournal_.kreedit)) Like Ltrim(Rtrim(kassatulud.kood));
*!*			INNER Join kassakontod On Ltrim(Rtrim(curJournal_.deebet)) Like Ltrim(Rtrim(kassakontod.kood));
*!*			group By aasta, kuu , curJournal_.rekvid, curJournal_.kood1, curJournal_.kood2, curJournal_.kood5, curJournal_.tunnus;
*!*			order By aasta, kuu , curJournal_.rekvid, curJournal_.kood1, curJournal_.kood2,  curJournal_.kood5, curJournal_.tunnus;

*!*		=setpropview()



*!*		If !Used('menumodul')
*!*			Use menumodul In 0
*!*		Endif
*!*		If !Used('menupohi')
*!*			Use menupohi In 0 Order Id
*!*		Endif
*!*		If !Used('menuisik')
*!*			Use menuisik In 0
*!*		Endif

*!*		Delete From menupohi Where Pad = 'Aruanne' And Bar = '35'

*!*		Select menupohi
*!*		Locate For Alltrim(Upper(Pad)) = 'ARUANNE' AND bar = '39'
*!*		IF !FOUND()
*!*			Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
*!*				('RUS CAPTION=Декларация INF3'+Chr(13)+'EST CAPTION=Deklaratsioon INF3',;
*!*				"=nObjekt('do form eelarvearuanne with 39')", 1,'Aruanne','39')
*!*			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)

*!*		ENDIF
*!*		

*!*		Select menupohi
*!*		Locate For Alltrim(Upper(Pad)) = 'VANEMTASU'
*!*		If !Found()
*!*			Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
*!*				('RUS CAPTION=Расходы на обучение'+Chr(13)+'EST CAPTION=Koolitus kulud',;
*!*				"oVanemtasu = nObjekt('vanemtasu','oVanemtasu',0)", 1,'File','39')

*!*			Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*			Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)


*!*			Insert Into menupohi (omandus, level_, Pad ) Values ;
*!*				('RUS CAPTION=Родительская плата'+CHR(13)+'EST CAPTION=Koolituse tulud',;
*!*				 2,'VANEMTASU')


*!*			Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
*!*				('RUS CAPTION=Добавить запись'+CHR(13)+'EST CAPTION=Lisamine'+CHR(13)+'KeyShortCut=CTRL+A',;
*!*				"gcWindow.add()", 2,'VANEMTASU','1')
*!*			Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
*!*				('RUS CAPTION=Внести изменения'+CHR(13)+'EST CAPTION=Muutmine'+CHR(13)+'KeyShortCut=CTRL+E',;
*!*				"gcWindow.edit()", 2,'VANEMTASU','2')
*!*			Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
*!*				('RUS CAPTION=Удалить запись'+CHR(13)+'EST CAPTION=Kustutamine'+CHR(13)+'KeyShortCut=CTRL+DEL',;
*!*				"gcWindow.delete()", 2,'VANEMTASU','3')
*!*			Insert Into menupohi (omandus, proc_, level_, Pad, Bar) Values ;
*!*				('RUS CAPTION=Печать'+CHR(13)+'EST CAPTION=Trьkk'+CHR(13)+'KeyShortCut=CTRL+P',;
*!*				"gcWindow.print()", 2,'VANEMTASU','4')



*!*		Endif

*!*		Select menupohi
*!*		Scan For Upper(Pad) = 'VANEMTASU'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan


*!*		Select menupohi
*!*		Scan For Upper(Pad) = 'MK1'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan

*!*		Scan For Upper(Pad) = 'KORDERID'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan

*!*		Scan For Upper(Pad) = 'ARVED'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan

*!*		Scan For Upper(Pad) = 'PUUDUMISED'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'PALK')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan
*!*		Scan For Upper(Pad) = 'TOOGRAAFIK'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'PALK')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan
*!*		Scan For Upper(Pad) = 'PALKJAAK'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'PALK')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan
*!*		Scan For Upper(Pad) = 'ASUTUSED'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'PALK')
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'POHIVARA')
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'LADU')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan
*!*		Scan For Upper(Pad) = 'NOMENKLATUUR'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'PALK')
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'POHIVARA')
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'LADU')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan
*!*		Scan For Upper(Pad) = 'POHIVARA'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'POHIVARA')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan
*!*		Scan For Upper(Pad) = 'PVGRUPPID'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'POHIVARA')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan
*!*		Scan For Upper(Pad) = 'DOK'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'PALK')
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'POHIVARA')
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'LADU')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan
*!*		Scan For Upper(Pad) = 'GRUPPID'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'LADU')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan
*!*		Scan For Upper(Pad) = 'LADUARVED'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'LADU')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan
*!*		Scan For Upper(Pad) = 'LADUJAAK'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'LADU')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan
*!*		Scan For Upper(Pad) = 'KULUTAITM'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan

*!*		Scan For Upper(Pad) = 'EELARVE'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan

*!*		Scan For Upper(Pad) = 'TUNNUS'
*!*			Select menumodul

*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'RAAMA')
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'EELARVE')
*!*				Insert Into menumodul (parentid, Modul) Values (menupohi.Id, 'PALK')
*!*			Endif
*!*			Select menuisik
*!*			Locate For parentid =  menupohi.Id
*!*			If !Found()
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'ADMIN', 1)
*!*				Insert Into menuisik (parentid, gruppid, jah) Values (menupohi.Id, 'VAATLEJA', 1)
*!*			Endif
*!*		Endscan



*!*		Use In menuisik
*!*		Use In menumodul
*!*		Use In menupohi

*!*		If !Used('palk_jaak')
*!*			Use palk_jaak In 0
*!*		Endif
*!*		Select palk_jaak
*!*		lnObj = Afields(aObj)
*!*		Use In palk_jaak
*!*		If lnObj < 1
*!*			Return .F.
*!*		Endif
*!*		lnElement = Ascan(aObj,Upper('G31'))
*!*		If lnElement < 1
*!*			Alter Table palk_jaak Add Column g31 y Not Null Default 1400
*!*		Endif
*!*		If Used('palk_jaak')
*!*			Use In palk_jaak
*!*		Endif


*!*		If !Used('korder2')
*!*			Use korder2 In 0
*!*		Endif
*!*		Select korder2
*!*		lnObj = Afields(aObj)
*!*		Use In korder2
*!*		If lnObj < 1
*!*			Return .F.
*!*		Endif
*!*		lnElement = Ascan(aObj,Upper('TUNNUS'))
*!*		If lnElement < 1
*!*			Alter Table korder2 Add Column tunnus c(20) Not Null Default Space(1)
*!*		Endif
*!*		If Used('korder2')
*!*			Use In korder2
*!*		Endif


*!*		If !Used('leping2')
*!*			Use leping2 In 0
*!*		Endif
*!*		Select leping2
*!*		lnObj = Afields(aObj)
*!*		Use In leping2
*!*		If lnObj < 1
*!*			Return .F.
*!*		Endif
*!*		lnElement = Ascan(aObj,Upper('KBM'))
*!*		If lnElement < 1
*!*			Alter Table leping2 Add Column kbm Int Not Null Default 1
*!*		Endif
*!*		If Used('leping2')
*!*			Use In leping2
*!*		Endif

*!*		If !Used('palk_lib')
*!*			Use palk_lib In 0
*!*		Endif
*!*		Select palk_lib
*!*		lnFields = Afields(aObj)
*!*		Use In palk_lib
*!*		If lnFields < 1
*!*			Return .F.
*!*		Endif
*!*		lnElement = Ascan(aObj,Upper('ELATIS'))
*!*		If lnElement < 1
*!*			Alter Table palk_lib Add Column elatis Int Not Null Default 0
*!*		Endif
*!*		lnElement = Ascan(aObj,Upper('TULULIIK'))
*!*		If lnElement < 1
*!*			Alter Table palk_lib Add Column tululiik c(6) Not Null Default Space(1)
*!*		Endif

*!*		If Used('palk_lib')
*!*			Use In palk_lib
*!*		Endif

*!*		If !Used('tooleping')
*!*			Use tooleping In 0
*!*		Endif
*!*		Select tooleping
*!*		lnFields = Afields(aObj)
*!*		Use In tooleping
*!*		If lnFields < 1
*!*			Return .F.
*!*		Endif
*!*		lnElement = Ascan(aObj,Upper('TOEND'))
*!*		If lnElement < 1
*!*			Alter Table tooleping Add Column toend Date Not Null Default {}
*!*		Endif

*!*		lnElement = Ascan(aObj,Upper('RESIDENT'))
*!*		If lnElement < 1
*!*			Alter Table tooleping Add Column resident Int Not Null Default 1
*!*		Endif

*!*		lnElement = Ascan(aObj,Upper('RIIK'))
*!*		If lnElement < 1
*!*			Alter Table tooleping Add Column riik c(3) Not Null Default Space(1)
*!*		Endif

*!*		If Used('tooleping')
*!*			Use In tooleping
*!*		Endif

*!*		If !Used('palk_taabel1')
*!*			Use palk_taabel1 In 0
*!*		Endif
*!*		Select palk_taabel1
*!*		lnFields = Afields(aObj)
*!*		Use In palk_taabel1
*!*		If lnFields < 1
*!*			Return .F.
*!*		Endif
*!*		lnElement = Ascan(aObj,Upper('ULEAJATOO'))
*!*		If lnElement < 1
*!*			Alter Table palk_taabel1 Add Column uleajatoo Int Not Null Default 0
*!*		Endif

*!*		If Used('palk_taabel1')
*!*			Use In palk_taabel1
*!*		Endif

*!*		lnDbObj = Adbobjects(laView,'VIEW')
*!*		If lnDbObj < 1
*!*			Return .F.
*!*		Endif


*!*	*!*		lnElement = Ascan(laView,Upper('curladuJaak_'))
*!*	*!*		If lnElement > 0
*!*	*!*			Drop View  curladuJaak_
*!*	*!*		Endif

*!*		Create Sql View curladuJaak_;
*!*			AS;
*!*			SELECT ladu_jaak.rekvid, ladu_jaak.hind, ladu_jaak.jaak As jaak, ladu_jaak.kpv, nomenklatuur.kood, ;
*!*			nomenklatuur.nimetus,  nomenklatuur.uhik, grupp.nimetus As grupp, nomenklatuur.kogus As minjaak ;
*!*			FROM ladu_jaak  INNER Join nomenklatuur On  ladu_jaak.nomid = nomenklatuur.Id  ;
*!*			INNER Join ladu_grupp On ladu_grupp.nomid = nomenklatuur.Id ;
*!*			INNER Join Library grupp On grupp.Id = ladu_grupp.parentid


*!*	*!*		lnElement = Ascan(laView,Upper('curPohivara_'))
*!*	*!*		If lnElement > 0
*!*	*!*			Drop View  curPohivara_
*!*	*!*		Endif

*!*		Create Sql View curPohivara_;
*!*			AS;
*!*			SELECT Library.Id, Library.kood, Library.nimetus, Library.rekvid,;
*!*			Pv_kaart.vastisikid, asutus.nimetus As vastisik, Pv_kaart.algkulum,Pv_kaart.kulum,;
*!*			Pv_kaart.soetmaks, Pv_kaart.soetkpv, grupp.nimetus As grupp,;
*!*			Pv_kaart.konto, Pv_kaart.gruppid, Pv_kaart.tunnus, Pv_kaart.mahakantud,;
*!*			IIF(Pv_kaart.kulum > 0,"Pohivara","Vaikevahendid") As liik, Left(Mline(Pv_kaart.muud,1),254) As rentnik;
*!*			FROM ;
*!*			buhdata5!Library ;
*!*			INNER Join buhdata5!Pv_kaart ;
*!*			ON  Library.Id = Pv_kaart.parentid ;
*!*			INNER Join buhdata5!asutus ;
*!*			ON  Pv_kaart.vastisikid = asutus.Id ;
*!*			INNER Join buhdata5!Library grupp ;
*!*			ON  Pv_kaart.gruppid = grupp.Id


*!*	*!*		lnElement = Ascan(laView,Upper('curKulum_'))
*!*	*!*		If lnElement > 0
*!*	*!*			Drop View  curKulum_
*!*	*!*		Endif


*!*		Create Sql View curKulum_;
*!*			AS;
*!*			SELECT Library.Id, pv_oper.liik, pv_oper.Summa, pv_oper.kpv, Library.rekvid,;
*!*			grupp.nimetus As grupp, ;
*!*			nomenklatuur.kood, nomenklatuur.nimetus As opernimi,;
*!*			Pv_kaart.soetmaks, Pv_kaart.soetkpv,;
*!*			Pv_kaart.kulum, Pv_kaart.algkulum,;
*!*			Pv_kaart.gruppid, Pv_kaart.konto, ;
*!*			Pv_kaart.tunnus, asutus.nimetus As vastisik,;
*!*			library.kood As ivnum,     Library.kood As invnum,;
*!*			library.nimetus As pohivara;
*!*			FROM Library INNER Join  pv_oper On   Library.Id = pv_oper.parentid ;
*!*			INNER Join   Pv_kaart On Library.Id = Pv_kaart.parentid ;
*!*			INNER Join Library grupp On    Pv_kaart.gruppid = grupp.Id ;
*!*			INNER Join asutus On Pv_kaart.vastisikid = asutus.Id ;
*!*			INNER Join nomenklatuur On pv_oper.nomid = nomenklatuur.Id


*!*	*!*		lnElement = Ascan(laView,Upper('cursaldo'))
*!*	*!*		If lnElement > 0
*!*	*!*			Drop View  cursaldo
*!*	*!*		Endif

*!*		Create Sql View cursaldo As  ;
*!*			Select Date(2000,01,01) As kpv, kontoinf.rekvid, Library.kood As konto, ;
*!*			IIF( kontoinf.algsaldo >= 0, Val(Str(kontoinf.algsaldo,12,4)), Val(Str(000000000.0000,12,4))) As deebet, ;
*!*			IIF( kontoinf.algsaldo < 0 , Val(Str(-1 * kontoinf.algsaldo,12,4)), Val(Str(000000000.0000,12,4))) As kreedit, ;
*!*			1 As OPT, 000000000 As asutusId  From Library INNER Join kontoinf On Library.Id = kontoinf.parentid ;
*!*			where algsaldo <> 0;
*!*			union All  ;
*!*			Select Date(Iif(Empty(aasta),1999,aasta), Iif(Empty(kuu),1,kuu),1) As kpv, rekvid, konto,  ;
*!*			VAL(Str(dbkaibed,12,4))  As deebet, Val(Str(krkaibed,12,4)) As kreedit, 3 As OPT, asutusId  ;
*!*			from saldo  Where saldo.asutusId > 0 And !Empty(kuu) And !Empty(aasta);
*!*			AND dbkaibed <> 0 And krkaibed <> 0;
*!*			union All  ;
*!*			SELECT kpv, rekvid, deebet As konto, Val(Str(Summa,12,4)) As deebet,  Val(Str(000000000.0000,12,4)) As kreedit,;
*!*			4 As OPT, asutusId  From curJournal_  ;
*!*			union All  ;
*!*			SELECT kpv, rekvid, kreedit As konto, ;
*!*			VAL(Str(000000000.0000,12,4)) As deebet, Val(Str(Summa,12,4))  As kreedit, 4 As OPT, asutusId ;
*!*			from curJournal_


*!*	*!*		lnElement = Ascan(laView,Upper('cursaldoasutus'))
*!*	*!*		If lnElement > 0
*!*	*!*			Drop View  cursaldoasutus
*!*	*!*		Endif

*!*		Create Sql View cursaldoasutus As  ;
*!*			SELECT Date(2000, 1, 1) As kpv, subkonto.rekvid, Library.kood As konto,;
*!*			IIF(subkonto.algsaldo >= 0, Val(Str(subkonto.algsaldo,12,2)),Val(Str(0,12,2))) As deebet,;
*!*			IIF(subkonto.algsaldo < 0, - 1 * Val(Str(subkonto.algsaldo,12,2)),Val(Str(0,12,2))) As kreedit,;
*!*			2 As OPT, subkonto.asutusId   From Library  INNER Join subkonto On Library.Id = subkonto.kontoid ;
*!*			WHERE algsaldo <> 0;
*!*			UNION All  ;
*!*			SELECT Iif(Empty(saldo.aasta),{},Date(saldo.aasta, saldo.kuu, 1)) As kpv, saldo.rekvid, saldo.konto,;
*!*			VAL(Str(saldo.dbkaibed,12,2)) As deebet,;
*!*			VAL(Str(saldo.krkaibed,12,2)) As kreedit, 3 As OPT, saldo.asutusId   ;
*!*			FROM saldo  Where saldo.asutusId > 0 And !Empty(kuu) And !Empty(aasta);
*!*			AND dbkaibed <> 0 And krkaibed <> 0;
*!*			UNION All  ;
*!*			SELECT kpv, rekvid, deebet As konto, Val(Str(Summa,12,2)) As deebet,;
*!*			VAL(Str(0,12,2)) As kreedit, 4 As OPT, asutusId   From curJournal_;
*!*			UNION All  ;
*!*			SELECT kpv, rekvid, kreedit As konto, Val(Str(0,12,2)) As deebet, Val(Str(Summa,12,2)) As kreedit, 4 As OPT, asutusId ;
*!*			FROM curJournal_

*!*	*!*		lnElement = Ascan(laView,Upper('qryKassaTulutaitm_'))
*!*	*!*		If lnElement > 0
*!*	*!*			Drop View  qryKassaTulutaitm_
*!*	*!*		Endif


*!*		Create Sql View qryKassaTulutaitm_  As ;
*!*			SELECT  curJournal_.kpv, curJournal_.rekvid, rekv.nimetus, curJournal_.tunnus As tun, Summa, ;
*!*			curJournal_.kood5 As kood,;
*!*			space(1) As eelarve, curJournal_.kood1 As tegev;
*!*			fROM curJournal_  INNER  Join kassatulud On Trim(curJournal_.kreedit) Like Trim(kassatulud.kood)+'%';
*!*			INNER Join kassakontod On Trim(curJournal_.deebet) Like Trim(kassakontod.kood)+'%';
*!*			JOIN rekv On curJournal_.rekvid = rekv.Id

*!*		lError = DBSetProp('qryKassaTulutaitm_ ','View','FetchAsNeeded',.T.)

*!*	*!*		lnElement = Ascan(laView,Upper('CURPALKOPER_'))
*!*	*!*		If lnElement > 0
*!*	*!*			Drop View  curpalkoper_
*!*	*!*		Endif

*!*		Create Sql View curpalkoper_;
*!*			AS;
*!*			SELECT  Library.tun1, Library.tun2, Library.tun3, Library.tun4, Library.tun5, ;
*!*			library.nimetus, asutus.nimetus As isik, asutus.Id As isikId,;
*!*			iif(Isnull(journalid.Number),000000000,journalid.Number) As journalid, palk_oper.journal1Id, palk_oper.kpv,;
*!*			palk_oper.Summa, palk_oper.Id, palk_oper.libId, palk_oper.rekvid, tooleping.pank, tooleping.aa, ;
*!*			iif (liik = 1,'+', Iif (liik = 2 Or liik = 6 Or liik = 4 Or liik = 8, '-', ;
*!*			iif (liik = 7 And asutusest = 0,'-', '%'))) As liik,;
*!*			iif (tund = 1, 'KOIK', ;
*!*			iif (tund = 2, 'PAEV', Iif (tund = 3, 'OHT', Iif (tund = 4,'OO',;
*!*			iif (tund = 5, 'PUHKUS', 'PUHA'))))) As tund, ;
*!*			iif (maks = 1, 'JAH', 'EI ') As maks ;
*!*			FROM buhdata5!palk_oper ;
*!*			INNER Join    buhdata5!Library On  palk_oper.libId = Library.Id  ;
*!*			INNER Join buhdata5!palk_lib On palk_lib.parentid = Library.Id  ;
*!*			INNER Join buhdata5!tooleping On palk_oper.Lepingid = tooleping.Id  ;
*!*			INNER Join buhdata5!asutus On tooleping.parentid = asutus.Id;
*!*			LEFT Outer Join buhdata5!journalid On palk_oper.journalid = journalid.journalid

*!*		lError = DBSetProp('curPalkOper_','View','FetchAsNeeded',.T.)

*!*	*!*		lnElement = Ascan(laView,Upper('CURTSD_'))
*!*	*!*		If lnElement > 0
*!*	*!*			Drop View curtsd_
*!*	*!*		Endif

*!*		Create Sql View curtsd_;
*!*			as;
*!*			Select  palk_oper.Id, palk_oper.rekvid, asutus.regkood As isikukood, asutus.nimetus As isik,;
*!*			tooleping.pohikoht As pohikoht, tooleping.osakondId As tooleping, tooleping.resident As resident,;
*!*			tooleping.riik As riik, tooleping.toend As toend, tooleping.osakondId As osakondId, ;
*!*			palk_lib.liik, palk_lib.asutusest, palk_lib.algoritm, ;
*!*			palk_oper.kpv, palk_oper.Summa, Str(palk_lib.liik,1)+'-'+Str(palk_kaart.tulumaar,2) As Form,;
*!*			iif (palk_lib.liik = 1,  palk_oper.Summa, 000000000.00 ) As palk26,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '02', palk_oper.Summa, 000000000.00) As palk_02,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '03', palk_oper.Summa, 000000000.00) As palk_03,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '04', palk_oper.Summa, 000000000.00) As palk_04,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '05', palk_oper.Summa, 000000000.00) As palk_05,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '06', palk_oper.Summa, 000000000.00) As palk_06,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '07', palk_oper.Summa, 000000000.00) As palk_07,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '08', palk_oper.Summa, 000000000.00) As palk_08,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '09', palk_oper.Summa, 000000000.00) As palk_09,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '10', palk_oper.Summa, 000000000.00) As palk_10,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '11', palk_oper.Summa, 000000000.00) As palk_11,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '12', palk_oper.Summa, 000000000.00) As palk_12,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '13', palk_oper.Summa, 000000000.00) As palk_13,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '14', palk_oper.Summa, 000000000.00) As palk_14,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '15', palk_oper.Summa, 000000000.00) As palk_15,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '16', palk_oper.Summa, 000000000.00) As palk_16,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '17', palk_oper.Summa, 000000000.00) As palk_17,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '18', palk_oper.Summa, 000000000.00) As palk_18,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '19', palk_oper.Summa, 000000000.00) As palk_19,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '19a', palk_oper.Summa, 000000000.00) As palk_19a,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '20', palk_oper.Summa, 000000000.00) As palk_20,;
*!*			iif (palk_lib.liik = 1 And palk_lib.tululiik = '21', palk_oper.Summa, 000000000.00) As palk_21,;
*!*			iif (palk_lib.liik = 1 And palk_kaart.tulumaar >= 15 And palk_kaart.tulumaar < 26, palk_oper.Summa, 000000000.00) As palk15,;
*!*			iif (palk_lib.liik = 1 And palk_kaart.tulumaar >= 10 And palk_kaart.tulumaar < 15, palk_oper.Summa, 000000000.00) As palk10,;
*!*			iif (palk_lib.liik = 1 And palk_kaart.tulumaar > 0 And palk_kaart.tulumaar < 10, palk_oper.Summa, 000000000.00) As palk5,;
*!*			iif (palk_lib.liik = 1 And palk_kaart.tulumaar = 0, palk_oper.Summa, 000000000.00) As palk0,;
*!*			iif (palk_lib.liik = 7 And palk_lib.asutusest = 0,palk_oper.Summa, 000000000.00) As tm,;
*!*			iif (palk_lib.liik = 7 And palk_lib.asutusest = 1 , palk_oper.Summa , 000000000.00) As atm,;
*!*			iif (palk_lib.liik = 8, palk_oper.Summa, 0000000000.00) As pm,;
*!*			iif (palk_lib.liik = 4, palk_oper.Summa, 0000000000.00) As tulumaks, ;
*!*			iif (palk_lib.liik = 5,  palk_oper.Summa,  000000000.00) As sotsmaks, ;
*!*			IIF (palk_lib.elatis = 1 And palk_lib.liik = 2, palk_oper.Summa, 000000000.00) As elatis, ;
*!*			iif (palk_lib.liik = 1 And palk_lib.sots = 1, palk_oper.Summa, 0000000000.00) As palksots;
*!*			FROM buhdata5!comTooleping_ INNER Join buhdata5!palk_oper On comTooleping_.Id = palk_oper.Lepingid  ;
*!*			INNER Join buhdata5!asutus On asutus.Id = comTooleping_.parentid ;
*!*			INNER Join buhdata5!palk_lib On palk_oper.libId = palk_lib.parentid ;
*!*			INNER Join buhdata5!palk_kaart On palk_kaart.Lepingid = comTooleping_.Id


*!*	*!*		Local lnObj, lnElement
*!*	*!*		lnObj = Adbobjects(laObj,'TABLE')
*!*	*!*		If lnObj < 1
*!*	*!*			Return .F.
*!*	*!*		Endif
*!*	*!*		lnElement = Ascan(laObj,Upper('PALK_TMPL'))
*!*	*!*		If lnElement > 0
*!*	*!*			Return .T.
*!*	*!*		Endif
*!*	*!*		lcString = "create table palk_tmpl (id int default next_number ('PALK_TMPL') PRIMARY KEY,"+;
*!*	*!*			'parentid int default 0, libId int default 0, summa y default 100, percent_  int default 1,'+;
*!*	*!*			'tulumaks int default 1, tulumaar int default 26, tunnusid int default 0)'
*!*	*!*		&lcString
*!*	*!*		If Used ('palk_tmpl')
*!*	*!*			Use In palk_tmpl
*!*	*!*		Endif
*!*		lError = DBSetProp('curTsd_','View','FetchAsNeeded',.T.)

	=setpropview()
	Return

Function setpropview
	Set Data To buhdata5
	lnViews = Adbobject (laView,'VIEW')
	For i = 1 To lnViews
		lError = DBSetProp(laView(i),'View','FetchAsNeeded',.T.)
	Endfor
	Return


FUNCTION _alter_pg
		SET STEP ON 
		lcString = " select id from menupohi where UPPER(pad) = 'TEENUSED'"
		lError = SQLEXEC(gnHandle,lcString,'qrymenupohi')
		Select qrymenupohi
		scan 
			lcstring = " SELECT id FROM menumodul WHERE parentid = "+STR(qrymenupohi.id)
			lError = SQLEXEC(gnHandle,lcString,'qrymenumodul')
			IF RECCOUNT('qrymenumodul') < 1			
				lcString = "INSERT INTO menumodul (parentid, modul) VALUES ("+STR(qrymenupohi.id)+", 'RAAMA')"
				lError = SQLEXEC(gnHandle,lcString)
				IF lError < 1
					exit
				endif
			ENDIF
			lcstring = " SELECT id FROM menuisik WHERE parentid = "+STR(qrymenupohi.id)
			lError = SQLEXEC(gnHandle,lcString,'qrymenuisik')
			IF RECCOUNT('qrymenuisik') < 1			
				lcString = "INSERT INTO menuisik (parentid,gruppid,jah) VALUES ("+STR(qrymenupohi.id)+", 'KASUTAJA',1)"
				lError = SQLEXEC(gnHandle,lcString)
				IF lError < 1
					exit
				endif
				lcString = "INSERT INTO menuisik (parentid,gruppid,jah) VALUES ("+STR(qrymenupohi.id)+", 'PEAKASUTAJA',1)"
				lError = SQLEXEC(gnHandle,lcString)
				IF lError < 1
					exit
				endif
				lcString = "INSERT INTO menuisik (parentid,gruppid,jah) VALUES ("+STR(qrymenupohi.id)+", 'VAATLEJA',1)"
				lError = SQLEXEC(gnHandle,lcString)
				IF lError < 1
					exit
				endif
				lcString = "INSERT INTO menuisik (parentid,gruppid,jah) VALUES ("+STR(qrymenupohi.id)+", 'ADMIN',1)"
				lError = SQLEXEC(gnHandle,lcString)
				IF lError < 1
					exit
				endif
			ENDIF
		ENDSCAN


	CREATE CURSOR comKontodRemote (id int, KOOD C(20), NIMETUS C(254), TUN1 INT, TUN2 INT, tun3 int, tun4 int, tun5 int)
	lcString = "select id, kood, nimetus, tun1, tun2, tun3, tun4, tun5 from library where library = 'KONTOD'"
	lerror = SQLEXEC(gnhandle,lcString,'qryKontod')
	lerror = SQLEXEC(gnhandle,'begin work')
	SET STEP ON 
	INSERT INTO comKontodRemote (id, KOOD, NIMETUS, TUN1, TUN2, tun3, tun4, tun5);
	select id, kood, nimetus, tun1, tun2, tun3, tun4, tun5 from qryKontod 
	
	IF FILE('kontoplaan.dbf')
		* Правим план.счетов
		IF USED('kontoplaan')
			USE IN kontoplaan
		ENDIF
		
		USE kontoplaan IN 0
		SELECT kontoplaan
		SCAN FOR !EMPTY(n6)
			WAIT WINDOW 'Kontrolin konto :'+kontoplaan.n6 nowait
			lnTun1 = IIF(EMPTY(kontoplaan.n10),0,1)
			lnTun2 = IIF(EMPTY(kontoplaan.n11),0,1)
			lnTun3 = IIF(EMPTY(kontoplaan.n12),0,1)
			lnTun4 = IIF(EMPTY(kontoplaan.n13),0,1)

			SELECT comKontodRemote
			LOCATE FOR ALLTRIM(kood) = ALLTRIM(kontoplaan.n6)
			IF FOUND()
*!*					lcString = " INSERT into library (rekvid, kood, nimetus, tun5, library) VALUES ("+STR(grekv)+",'"+ ;
*!*						ALLTRIM(kontoplaan.n6)+"','"+ LTRIM(RTRIM(kontoplaan.n9))+"',"+ ;
*!*						IIF(LEFT(ALLTRIM(kontoplaan.n6),1)='2' OR LEFT(ALLTRIM(kontoplaan.n6),1)='3','2','1')+",'KONTOD')"
*!*					lerror = SQLEXEC(gnhandle,lcString)
*!*					IF lError < 1
*!*						exit
*!*					endif
*!*						 
*!*					INSERT INTO comKontodRemote (id, KOOD, NIMETUS, tun5) VALUES (;
*!*						library.id, ALLTRIM(kontoplaan.n6), LTRIM(RTRIM(kontoplaan.n9)), ;
*!*						IIF(LEFT(ALLTRIM(kontoplaan.n6),1)='2' OR LEFT(ALLTRIM(kontoplaan.n6),1)='3',2,1)) 
*!*					
*!*					lcString = " INSERT INTO kontoinf (parentid, rekvid) SELECT library.id, rekv.ID FROM rekv "
*!*					lerror = SQLEXEC(gnhandle,lcString)
*!*					IF lError < 1
*!*						exit
*!*					endif

*!*					lcString = "INSERT INTO tunnusinf (kontoid, rekvid, tunnusid) SELECT library.id, tunnus.rekvID, tunnus.id FROM library tunnus WHERE library = 'TUNNUS'" 
*!*					lerror = SQLEXEC(gnhandle,lcString)
*!*					IF lError < 1
*!*						exit
*!*					endif
*!*											
*!*				ENDIF
			
				IF EMPTY(comKontodRemote.tun1) AND !EMPTY(lnTun1)
					lcString = " update library SET tun1 = 1 WHERE id = "+STR(comKontodRemote.id)	
					lerror = SQLEXEC(gnhandle,lcString)
					IF lError < 1
						exit
					endif
			
				ENDIF
				IF EMPTY(comKontodRemote.tun2) AND !EMPTY(lnTun2)
					lcString = " update library SET tun2 = 1 WHERE id = " + STR(comKontodRemote.id)
					lerror = SQLEXEC(gnhandle,lcString)
					IF lError < 1
						exit
					endif
				ENDIF
				IF EMPTY(comKontodRemote.tun3) AND !EMPTY(lnTun3)
					lcString = " update library SET tun3 = 1 WHERE id = " +STR(comKontodRemote.id)
					lerror = SQLEXEC(gnhandle,lcString)
					IF lError < 1
						exit
					endif
				ENDIF
				IF EMPTY(comKontodRemote.tun4) AND !EMPTY(lnTun4)
					lcString = " update library SET tun4 = 1 WHERE id = " +STR(comKontodRemote.id)
					lerror = SQLEXEC(gnhandle,lcString)
					IF lError < 1
						exit
					endif
				ENDIF
				IF !EMPTY(comKontodRemote.tun1) AND EMPTY(lnTun1)
					lcString = " update library SET tun1 = 0 WHERE id = " +STR(comKontodRemote.id)
					lerror = SQLEXEC(gnhandle,lcString)
					IF lError < 1
						exit
					endif
				ENDIF
				IF !EMPTY(comKontodRemote.tun2) AND EMPTY(lnTun2)
					lcString = " update library SET tun2 = 0 WHERE id = " +STR(comKontodRemote.id)
					lerror = SQLEXEC(gnhandle,lcString)
					IF lError < 1
						exit
					endif
				ENDIF
				IF !EMPTY(comKontodRemote.tun3) AND EMPTY(lnTun3)
					lcString = " update library SET tun3 = 0 WHERE id = " +STR( comKontodRemote.id)
					lerror = SQLEXEC(gnhandle,lcString)
					IF lError < 1
						exit
					endif
				ENDIF
				IF !EMPTY(comKontodRemote.tun4) AND EMPTY(lnTun4)
					lcString = " update library SET tun4 = 0 WHERE id = " + STR(comKontodRemote.id)
					lerror = SQLEXEC(gnhandle,lcString)
					IF lError < 1
						exit
					endif
				ENDIF
*!*					lcString = "INSERT INTO tunnusinf (kontoid, rekvid, tunnusid) SELECT library.id, tunnus.rekvID, tunnus.id FROM library tunnus WHERE library = 'TUNNUS'" 
*				lerror = SQLEXEC(gnhandle,lcString)
				IF lError < 1
					exit
				endif
			ENDIF
			
		endscan
		IF lError  < 1
			=SQLEXEC(gnHandle,'ROLLBACK WORK')
		ELSE
			=SQLEXEC(gnHandle,'COMMIT WORK')		
		ENDIF
	ENDIF
	
ENDFUNC




Function _alter_mssql


	cString = "sp_help"
	lError = sqlexec (gnHandle,cString)
	If lError > 0
		If Used ('sqlresult')
			Select sqlresult
			Locate For Upper(Name) = 'PALK_TMPL' And object_type = 'user table'
			If !Found ()
				cString = 'create table dbo.palk_tmpl (id int IDENTITY (1, 1) NOT NULL  PRIMARY KEY,'+;
					'parentid int NOT NULL default 0, libId int NOT NULL default 0, summa money NOT NULL default 100,'+;
					'percent_  int NOT NULL default 1,'+;
					'tulumaks int NOT NULL default 1, tulumaar int NOT NULL default 26, tunnusid int NOT NULL default 0)'

				lError = sqlexec(gnHandle, cString)

				cString = 'GRANT  SELECT ,  UPDATE ,  INSERT,  DELETE  ON dbo.palk_tmpl  TO dbkasutaja'
				= sqlexec(gnHandle, cString)
				cString = 'GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON dbo.palk_tmpl  TO dbpeakasutaja'
				= sqlexec(gnHandle, cString)
				cString = 'GRANT  SELECT  ON dbo.palk_tmpl  TO dbadmin'
				= sqlexec(gnHandle, cString)

			Endif

		Endif
	Endif

	If Used ('sqlresult')
		Use In sqlresult
	Endif
	If lError < 0
		Return .F.
	Endif
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



