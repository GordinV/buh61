SET STEP ON 
If !Used ('config')
	Use config In 0
Endif

Create Cursor curKey (versia m)
Append Blank
Replace versia With 'EELARVE' In curKey
Create Cursor v_account (admin Int Default 1)
Append Blank
*!*	*!*	*!*	gnhandle = SQLConnect ('buhdata5zur','zinaida','159')
*gnhandle = sqlconnect ('NarvaLvPg','vlad','490710')
*!*	*!*	*!*	*!*	*!*	*!*	&&,'zinaida','159')

*!*	grekv = 1
*!*	gnHandle = 1
*!*	gversia = 'VFP'

gnhandle = SQLConnect ('NjlvPg','vlad','490710')
*!*	gnhandle = sqlconnect ('NarvaLvPg','vlad','490710')
*!*	gnHandle = SQLConnect ('datelviru','vladislav','490710')
gversia = 'PG'

Local lError

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
&& ��������� ��������� �������

*=update_curprinter()
*update_tolk()

lcFile = 'eelarve/curprinter.dbf'
Use (lcFile) In 0 Alias curPrinter

Select curPrinter
Locate For Lower(objekt) = LOWER('Palkaruanne') And Id = 813
If !Found()
* lisamine
	Append Blank
	Replace Id With 813,;
		objekt With 'Palkaruanne',;
		nimetus1 With 'Palgastatistika, 1 tbl.',;
		nimetus2 With 'Palgastatistika, 1 tbl.',;
		procfail With 'palkstat_report11',;
		reportfail With 'palkstat_report11',;
		reportvene With 'palkstat_report11' In curPrinter
Endif

Locate For Lower(objekt) = LOWER('Palkaruanne') And Id = 814
If !Found()
* lisamine
	Append Blank
	Replace Id With 814,;
		objekt With 'Palkaruanne',;
		nimetus1 With 'Palgastatistika, 2 tbl.',;
		nimetus2 With 'Palgastatistika, 2 tbl.',;
		procfail With 'palkstat_report12',;
		reportfail With 'palkstat_report12',;
		reportvene With 'palkstat_report12' In curPrinter
ENDIF

Locate For Lower(objekt) = LOWER('Palkaruanne') And Id = 815
If !Found()
* lisamine
	Append Blank
	Replace Id With 815,;
		objekt With 'Palkaruanne',;
		nimetus1 With 'Palgastatistika, 3 tbl.',;
		nimetus2 With 'Palgastatistika, 3 tbl.',;
		procfail With 'palkstat_report13',;
		reportfail With 'palkstat_report13',;
		reportvene With 'palkstat_report13' In curPrinter
Endif


Use In curPrinter

lcFile = 'curprinter.dbf'
Use (lcFile) In 0 Alias curPrinter

Select curPrinter
Locate For Lower(objekt) = LOWER('Palkaruanne') And Id = 813
If !Found()
* lisamine
	Append Blank
	Replace Id With 813,;
		objekt With 'Palkaruanne',;
		nimetus1 With 'Palgastatistika, 1 tbl.',;
		nimetus2 With 'Palgastatistika, 1 tbl.',;
		procfail With 'palkstat_report11',;
		reportfail With 'palkstat_report11',;
		reportvene With 'palkstat_report11' In curPrinter
Endif

Locate For Lower(objekt) = LOWER('Palkaruanne') And Id = 814
If !Found()
* lisamine
	Append Blank
	Replace Id With 814,;
		objekt With 'Palkaruanne',;
		nimetus1 With 'Palgastatistika, 2 tbl.',;
		nimetus2 With 'Palgastatistika, 2 tbl.',;
		procfail With 'palkstat_report12',;
		reportfail With 'palkstat_report12',;
		reportvene With 'palkstat_report12' In curPrinter
ENDIF

Locate For Lower(objekt) = LOWER('Palkaruanne') And Id = 815
If !Found()
* lisamine
	Append Blank
	Replace Id With 815,;
		objekt With 'Palkaruanne',;
		nimetus1 With 'Palgastatistika, 3 tbl.',;
		nimetus2 With 'Palgastatistika, 3 tbl.',;
		procfail With 'palkstat_report13',;
		reportfail With 'palkstat_report13',;
		reportvene With 'palkstat_report13' In curPrinter
ENDIF

USE IN curPrinter


Do Case
	Case gversia = 'VFP'
		lcdefault = Sys(5)+Sys(2003)
		Select qryKey
		Scan For Mline(qryKey.Connect,1) = 'FOX'
			lcdata = Mline(qryKey.vfp,1)
			If File (lcdata)
*			lcdataproc = lcdefault+'\tmp\0811proc.prn'
*			If File (lcdataproc)
*					Append proc from (lcdataproc) overwrite
				If Dbused('buhdata5')
					Set Database To buhdata5
					Close Databases
				Endif
*!*						If Used('buhdata5')
*!*							Use In buhdata5
*!*						Endif
*!*						Use (lcdata) In 0 Exclusive
*!*						Select buhdata5
*!*						Locate For objectid = 3
*!*						Append Memo buhdata5.Code From (lcdataproc) Overwrite
*!*						Use

*			Endif
*			Open Data (lcdata) Exclusive
*			Compile Database (lcdata)
				Open Data (lcdata)
				Set Database To buhdata5
				Set Default To Justpath (lcdata)
				lError =  _alter_vfp()
				Close Data
				Set Default To (lcdefault)
			Endif
		Endscan
		Use In qryKey
	Case gversia = 'PG'
*		=sqlexec (gnHandle,'begin transaction')
		lError = _alter_pg ()
		If Vartype (lError ) = 'N'
			lError = Iif( lError = 1,.T.,.F.)
		Endif
*!*			If lError = .F.
*!*				=sqlexec (gnHandle,'rollback')
*!*			Else
*!*				=sqlexec (gnHandle,'commit')
*!*			Endif
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

	DROP VIEW curPalkoper_ 
	
	Create 	Sql View curpalkoper_ As;
		SELECT Library.tun1, Library.tun2, Library.tun3, Library.tun4,;
		Library.tun5, Library.nimetus, Asutus.nimetus As isik,;
		Asutus.Id As isikid,;
		IIF(Isnull(Journalid.Number),0,Journalid.Number) As Journalid,;
		Palk_oper.journal1id, Palk_oper.kpv, Palk_oper.Summa, Palk_oper.Id,;
		Palk_oper.libid, Palk_oper.rekvid, Tooleping.pank, Tooleping.aa, Tooleping.osakondid,;
		IIF(liik=1,"+",Iif(liik=2.Or.liik=6.Or.liik=4.Or.liik=8,"-",Iif(liik=7.And.asutusest=0,"-","%"))) As liik,;
		IIF(tund=1,"KOIK",Iif(tund=2,"PAEV",Iif(tund=3,"OHT",Iif(tund=4,"OO",Iif(tund=5,"PUHKUS",Iif(tund=6,"PUHA","ULETOO")))))) As tund,;
		IIF(maks=1,"JAH","EI ") As maks;
		FROM ;
		buhdata5!Palk_oper ;
		INNER Join buhdata5!Library ;
		ON  Palk_oper.libid = Library.Id ;
		INNER Join buhdata5!palk_lib ;
		ON  palk_lib.parentid = Library.Id ;
		INNER Join buhdata5!Tooleping ;
		ON  Palk_oper.lepingid = Tooleping.Id ;
		INNER Join buhdata5!Asutus ;
		ON  Tooleping.parentid = Asutus.Id ;
		LEFT Outer Join buhdata5!Journalid ;
		ON  Palk_oper.Journalid = Journalid.Journalid

DROP VIEW curPalkoper3_ 

Create 	Sql View curpalkoper3_ As;
SELECT Palk_oper.summa, Palk_oper.kpv, Palk_oper.rekvid,;
  asutus.id as isikid, Asutus.nimetus AS isik, Asutus.regkood AS isikukood, Palk_lib.liik,;
  Palk_lib.asutusest, Osakond.kood AS okood, Amet.kood AS akood;
 FROM ;
     palk_oper ;
    INNER JOIN palk_lib ;
   ON  Palk_oper.libid = Palk_lib.parentid ;
    INNER JOIN tooleping ;
   ON  Palk_oper.lepingid = Tooleping.id ;
    INNER JOIN asutus ;
   ON  Tooleping.parentid = Asutus.id ;
    INNER JOIN library Osakond ;
   ON  Osakond.id = Tooleping.osakondid ;
    INNER JOIN library Amet ;
   ON  Amet.id = Tooleping.ametid



Create 	Sql View cupuudumine_ As;
 SELECT puudumine.id, puudumine.lepingid, puudumine.kpv1, puudumine.kpv2, puudumine.paevad, puudumine.summa, ;
 puudumine.tunnus, puudumine.tyyp, amet.nimetus AS amet, amet.rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik,;
 IIF(puudumine.tunnus = 1, 'PUHKUS','HAIGUS') AS pohjus,;
 iif(alltrim(str(puudumine.tunnus)) + '-' + alltrim(str(puudumine.tunnus)) = '1-1','PEAPUHKUS',;  
 iif(alltrim(str(puudumine.tunnus)) + '-' + alltrim(str(puudumine.tunnus)) = '1-2','STAAZ',;
 iif(alltrim(str(puudumine.tunnus)) + '-' + alltrim(str(puudumine.tunnus)) = '1-3','LASTEPUHKUS',;
 iif(alltrim(str(puudumine.tunnus)) + '-' + alltrim(str(puudumine.tunnus)) = '1-4','OMAARVEL',;
 iif(alltrim(str(puudumine.tunnus)) + '-' + alltrim(str(puudumine.tunnus)) = '1-5','�PPEPUHKUS',;
 iif(alltrim(str(puudumine.tunnus)) + '-' + alltrim(str(puudumine.tunnus)) = '2-1','HAIGUS',;
 iif(alltrim(str(puudumine.tunnus)) + '-' + alltrim(str(puudumine.tunnus)) = '2-2','HOOLDUS',SPACE(20))))))))  AS liik;
 FROM ;
     buhdata5!puudumine ;
    INNER JOIN buhdata5!tooleping ;
   ON  Puudumine.lepingid = Tooleping.id ;
    INNER JOIN buhdata5!library Amet ;
   ON  Tooleping.ametid = Amet.id ;
    INNER JOIN buhdata5!asutus ;
   ON  Tooleping.parentid = Asutus.id 


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
	locate For Alltrim(Upper(Pad)) = Alltrim(Upper('Journal')) AND bar = '6'
	If !Found()
		lcOmandus = 'RUS CAPTION=����������'+Chr(13)+'EST CAPTION=Kooperi'
		lcproc = "=nObjekt('gcWindow.kooperi(gcWindow.lastnum)')"

		Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
			('Journal','6',lcproc, lcOmandus, 2)
		Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
		Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
		Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
		Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
	ELSE
		replace level_ WITH 2 IN menupohi
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

	If v_account.admin < 1
		Return .T.
	Endif


	Wait Window 'Db parandus' Nowait
	lcFile = 'tmp/fnc_muudatused20041201.sql'
	If File(lcFile)

		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif


	lcString = " select id from menupohi where UPPER(pad) = 'JOURNAL' and bar = '6'"
	lError = SQLEXEC(gnhandle,lcString,'qrymenupohi')

	If Reccount('qrymenupohi') < 1

		lcOmandus = 'RUS CAPTION=����������'+Chr(13)+'EST CAPTION=Kooperi'
		lcproc = [=nObjekt("gcWindow.kooperi(gcWindow.lastnum)")]

		lcString = "Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values "+;
			"('Journal','6','"+lcproc+"','"+lcOmandus+"', 2)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = " select id from menupohi where UPPER(pad) = 'JOURNAL' and bar = '6'"
		lError = SQLEXEC(gnhandle,lcString,'qrymenupohi')

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'ADMIN', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'VAATLEJA', 1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif


	Endif

Endfunc

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




Function CHECK_obj_pg
	Parameters tcObjType, tcObjekt
	Do Case
		Case Upper(tcObjType) = 'TABLE'
			cString = "select relid from pg_stat_all_tables where UPPER(relname) = '"+;
				UPPER(tcObjekt)+"'"
		Case Upper(tcObjType) = 'GROUP'
			cString = "select groName from pg_group where UPPER(groName) = '"+;
				UPPER(tcObjekt)+"'"
		Case Upper(tcObjType) = 'VIEW'
			cString = "select viewname from pg_views where UPPER(viewname) = '"+;
				UPPER(tcObjekt)+"'"

		Case Upper(tcObjType) = 'PROC'
			cString = "select proname from pg_proc where UPPER(proname) = '"+;
				UPPER(tcObjekt)+"'"

	Endcase
	lError = SQLEXEC (gnHandle,cString,'qryHelp')
	If Reccount('qryhelp') < 1
		Return .F.
	Else
		Return .T.
	Endif
Endfunc


Function check_field_pg
	Parameters tcTable, tcObjekt
	Local lnFields, lnElement
	If Empty(tcTable) Or Empty(tcObjekt)
		Return .T.
	Endif
	cString = "select * from "+tcTable+" order by id limit 1"
	lError = SQLEXEC (gnHandle,cString,'qryFld')
	If lError < 1
		Return .F.
	Endif
	Select qryFld
	lnFields = Afields(atbl)
	lnElement = Ascan(atbl,Upper(tcObjekt))
	Use In qryFld
	If lnElement > 0
		lnCol = Asubscript(atbl, lnElement,2)
		If lnCol <> 1
			Return .F.
		Endif
		lnRaw = Asubscript(atbl, lnElement,1)
		Return atbl(lnRaw,2)
	Else
		Return .F.
	Endif
Endfunc

Function execute_sql
	Parameters tcString, tcCursor
	If !Used('qryLog')
		Create Cursor qryLog (Log m)
		Append Blank
	Endif

	If Empty(tcCursor)
		lError = SQLEXEC(gnHandle,tcString)
	Else
		lError = SQLEXEC(gnHandle,tcString, tcCursor)
	Endif
	lcError = ' OK'
	If lError < 1
		Set Step On
		lnErr = Aerror(err)
		If lnErr > 0
			lcError = err(1,3)
		Endif
	Endif
	Replace qryLog.Log With tcString +lcError+Chr(13) Additive In qryLog
	Return lError


Function update_curprinter

	lcFile = 'eelarve\curprinter.dbf'
	Use (lcFile) In 0 Alias curPrinter

	Select curPrinter
	Locate For Lower(objekt) = 'aruanne' And Id = 200
	If !Found()
* lisamine
		Append Blank
		Replace Id With 200,;
			objekt With 'Aruanne ',;
			nimetus1 With '��������� ��������� �� ��������� (Tunnus)          ',;
			nimetus2 With 'Kliendikaibeandmik   (tunnus)          ',;
			procfail With 'kaibeAsutusandmik_report2 ',;
			reportfail With 'kaibeAsutusandmik_report2 ',;
			reportvene With 'kaibeAsutusandmik_report2 ' In curPrinter
	Endif

	Use In curPrinter

	lcFile = 'curprinter.dbf'
	Use (lcFile) In 0 Alias curPrinter

	Select curPrinter
	Locate For Lower(objekt) = 'aruanne' And Id = 200
	If !Found()
* lisamine
		Append Blank
		Replace Id With 200,;
			objekt With 'Aruanne ',;
			nimetus1 With '��������� ��������� �� ��������� (Tunnus)          ',;
			nimetus2 With 'Kliendikaibeandmik   (tunnus)          ',;
			procfail With 'kaibeAsutusandmik_report2 ',;
			reportfail With 'kaibeAsutusandmik_report2 ',;
			reportvene With 'kaibeAsutusandmik_report2 ' In curPrinter
	Endif

*!*	Locate For Lower(objekt) = 'vanemtasu' And Id = 2
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 2,;
*!*			objekt With 'vanemtasu',;
*!*			nimetus1 With '������������ ����� (���������)',;
*!*			nimetus2 With 'Laste vanematetasu andmik',;
*!*			procfail With 'vanemtasu_report1',;
*!*			reportfail With 'vanemtasu_report1',;
*!*			reportvene With 'vanemtasu_report1' In curPrinter
*!*	Endif

*!*	Locate For Lower(objekt) = 'vanemtasu' And Id = 3
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 3,;
*!*			objekt With 'vanemtasu',;
*!*			nimetus1 With '�����',;
*!*			nimetus2 With 'Arved',;
*!*			procfail With 'vanemtasu_report2',;
*!*			reportfail With 'vanemtasu_report2',;
*!*			reportvene With 'vanemtasu_report2' In curPrinter
*!*	Endif


*!*	Locate For Lower(objekt) = 'lapsed' And Id = 1
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 1,;
*!*			objekt With 'lapsed',;
*!*			nimetus1 With '������',;
*!*			nimetus2 With 'Laste nimikiri',;
*!*			procfail With 'lapsed_report1',;
*!*			reportfail With 'lapsed_report1',;
*!*			reportvene With 'lapsed_report1' In curPrinter
*!*	Endif

*!*	Locate For Lower(objekt) = 'lapsed' And Id = 2
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 2,;
*!*			objekt With 'lapsed',;
*!*			nimetus1 With '��������',;
*!*			nimetus2 With 'V�lnikud',;
*!*			procfail With 'lapsed_report2',;
*!*			reportfail With 'lapsed_report2',;
*!*			reportvene With 'lapsed_report2' In curPrinter
*!*	Endif


*!*	Use In curPrinter

*!*	lcFile = 'curprinter.dbf'
*!*	Use (lcFile) In 0 Alias curPrinter

*!*	Select curPrinter
*!*	Locate For Lower(objekt) = 'viivis' And Id = 1
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 1,;
*!*			objekt With 'viivis',;
*!*			nimetus1 With '������ ����',;
*!*			nimetus2 With 'Viivise arvestamine',;
*!*			procfail With 'viivis_report1',;
*!*			reportfail With 'viivis_report1',;
*!*			reportvene With 'viivis_report1' In curPrinter
*!*	ENDIF

*!*	Locate For Lower(objekt) = 'vanemtasu' And Id = 2
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 2,;
*!*			objekt With 'vanemtasu',;
*!*			nimetus1 With '������������ ����� (���������)',;
*!*			nimetus2 With 'Laste vanematetasu andmik',;
*!*			procfail With 'vanemtasu_report1',;
*!*			reportfail With 'vanemtasu_report1',;
*!*			reportvene With 'vanemtasu_report1' In curPrinter
*!*	Endif

*!*	Locate For Lower(objekt) = 'vanemtasu' And Id = 3
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 3,;
*!*			objekt With 'vanemtasu',;
*!*			nimetus1 With '�����',;
*!*			nimetus2 With 'Arved',;
*!*			procfail With 'vanemtasu_report2',;
*!*			reportfail With 'vanemtasu_report2',;
*!*			reportvene With 'vanemtasu_report2' In curPrinter
*!*	Endif


*!*	Locate For Lower(objekt) = 'lapsed' And Id = 1
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 1,;
*!*			objekt With 'lapsed',;
*!*			nimetus1 With '������',;
*!*			nimetus2 With 'Laste nimikiri',;
*!*			procfail With 'lapsed_report1',;
*!*			reportfail With 'lapsed_report1',;
*!*			reportvene With 'lapsed_report1' In curPrinter
*!*	Endif

*!*	Locate For Lower(objekt) = 'lapsed' And Id = 2
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 2,;
*!*			objekt With 'lapsed',;
*!*			nimetus1 With '��������',;
*!*			nimetus2 With 'V�lnikud',;
*!*			procfail With 'lapsed_report2',;
*!*			reportfail With 'lapsed_report2',;
*!*			reportvene With 'lapsed_report2' In curPrinter
*!*	Endif

	Use In curPrinter
Endfunc


Function update_tolk
	If !Used('tolk')
		Use tolk In 0
	Endif
	Select tolk
	Count To lnCount For objektid = 'viivis'
	If lnCount < 16
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblasutus','�����������:','Asutus:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblKpv','����:','Kuup�ev:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblviivis','���� (%):','Viivis (%):')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblkood','���:','Kood:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.btnArvesta','������','Arvesta')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.btnUusArve','����','Arve')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblKokku','�����:','Kokku:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column1.header1','����','Konto')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column2.header1','���������','Selgitus')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column3.header1','�����','Number')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column4.header1','�����','Summa')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column5.header1','����','T�htaeg')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column6.header1','��������','Makstud')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column7.header1','����','V�lg')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column8.header1','����','Viivis')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column9.header1','���-�� ����','P�evade arv')
	Endif


Endfunc