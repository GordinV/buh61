lcCurPrinter1 = 'eelarve\curprinter.dbf'
lcCurPrinter2 = 'curprinter.dbf'
If Used('curprinter')
	Use In curprinter
Endif
* добавляем декларацию об удержаном проф. взносе (отд. Культуры )

If File(lcCurPrinter1)
	Do fnc_ins_report With lcCurPrinter1, 1
Endif

If File(lcCurPrinter2)
	Do fnc_ins_report With lcCurPrinter2, 2
Endif

Procedure fnc_ins_report
	Lparameters tcFile, tnId
	If Used('curprinter')
		Use In curprinter
	Endif
	If File(tcFile)
		Use (tcFile) In 0 Alias curPrint
		Select curPrint
		Locate For Alltrim(Upper(objekt)) = 'PALKOPER' And Id = 3
		If !Found()
			Append Blank
			Replace Id With 3,;
				objekt With 'PalkOper',;
				nimetus1 With 'Справка в профсоюз',;
				nimetus2 With 'Tхend (ametiьhing)',;
				procfail With 'palkoper_report3',;
				reportfail With 'palkoper_report3',;
				reportvene With 'palkoper_report3' In curPrint
		Endif
		If tnId = 1
			Select curPrint
			Locate For Alltrim(Upper(objekt)) = 'EELARVEARUANNE' And Id = 321
			If !Found()
				Append Blank
				Replace Id With 321,;
					objekt With 'EelarveAruanne',;
					nimetus1 With 'Бюджет расходов (по статьям, признакам)',;
					nimetus2 With 'Eelarve kulude majanduliku ja ьksuste sisu jдrgi   ',;
					procfail With 'eelarve\eelarve_report31',;
					reportfail With 'eelarve\eelarve_report31',;
					reportvene With 'eelarve\eelarve_report31' In curPrint
			Endif
			Select curPrint
			Locate For Alltrim(Upper(objekt)) = 'EELARVEARUANNE' And Id = 332
			If !Found()
				Append Blank
				Replace Id With 332,;
					objekt With 'EelarveAruanne',;
					nimetus1 With 'Бюджет расходов (по видам деятельности, признаку)    ',;
					nimetus2 With 'Eelarve kulude tegevusalade ja ьksuste sisu jдrgi   ',;
					procfail With 'eelarve\eelarve_report41',;
					reportfail With 'eelarve\eelarve_report41',;
					reportvene With 'eelarve\eelarve_report41' In curPrint
			Endif

		Endif


		Use In curPrint
	Endif

Endproc




*!*			If !used ('config')
*!*				Use config in 0
*!*			Endif

*!*	Create cursor curKey (versia m)
*!*	Append blank
*!*	Replace versia with 'EELARVE' in curKey
*!*	Create cursor v_account (admin int default 1)
*!*	Append blank
*!*	gnhandle = sqlconnect ('buhdata5zur','zinaida','159')
*!*	*gnhandle = sqlconnect ('NARVA','vladislav','490710')
*!*	*!*	*!*	*!*	*!*	*!*	&&,'zinaida','159')
*!*	gversia = 'MSSQL'
*!*	grekv = 1
*!*	*!*	grekv = 1
*!*	*!*	gnHandle = 1
*!*	*!*	gversia = 'VFP'
*!*	Local lError

*!*	If v_account.admin < 1
*!*		Return .t.
*!*	Endif
*!*	If !used ('key')
*!*		Use key in 0
*!*	Endif
*!*	Select key
*!*	lnFields = afields (aObjekt)
*!*	Create cursor qryKey from array aObjekt
*!*	Select qryKey
*!*	Append from dbf ('key')
*!*	Use in key
*!*	=secure('OFF')

*!*	Do case
*!*		Case gversia = 'VFP'
*!*			lcdefault = sys(5)+sys(2003)
*!*			Select qryKey
*!*			Scan for mline(qryKey.connect,1) = 'FOX'
*!*				lcdata = mline(qryKey.vfp,1)
*!*				If file (lcdata)
*!*					Open data (lcdata)
*!*	*!*					lcdataproc = lcdefault+'\tmp\0909proc.prn'
*!*	*!*					If file (lcdataproc)
*!*	*!*						Append proc from (lcdataproc) overwrite
*!*	*!*					Endif
*!*					Set DEFAULT TO justpath (lcdata)
*!*					lError =  _alter_vfp()
*!*					Close data
*!*					Set default to (lcdefault)
*!*				Endif
*!*			Endscan
*!*			Use in qryKey
*!*		Case gversia = 'PG'
*!*		Case gversia = 'MSSQL'
*!*	*		=sqlexec (gnHandle,'begin transaction')
*!*			lError = _alter_mssql ()
*!*			If vartype (lError ) = 'N'
*!*				lError = iif( lError = 1,.t.,.f.)
*!*			Endif
*!*	*!*			If lError = .f.
*!*	*!*				=sqlexec (gnHandle,'rollback')
*!*	*!*			Else
*!*	*!*				=sqlexec (gnHandle,'commit')
*!*	*!*			Endif
*!*	Endcase

*!*	*!*	If lError = .f.
*!*	*!*		Messagebox ('Viga')
*!*	*!*	Endif
*!*	If gversia <> 'VFP'
*!*		=sqldisconnect (gnHandle)
*!*	*!*	else
*!*	*!*		set data to buhdata5
*!*	*!*		close data
*!*	Endif
*!*	Return lError

Function _alter_vfp
	Local lnObj, lnElement
	lnObj = Adbobjects(laObj,'TABLE')
	If lnObj < 1
		Return .F.
	Endif
	lnElement = Ascan(laObj,Upper('PALK_TMPL'))
	If lnElement > 0
		Return .T.
	Endif
	lcString = "create table palk_tmpl (id int default next_number ('PALK_TMPL') PRIMARY KEY,"+;
		'parentid int default 0, libId int default 0, summa y default 100, percent_  int default 1,'+;
		'tulumaks int default 1, tulumaar int default 26, tunnusid int default 0)'
	&lcString
	If Used ('palk_tmpl')
		Use In palk_tmpl
	Endif

	=setpropview()
	Return

Function setpropview
	Set Data To buhdata5
	lnViews = Adbobject (laView,'VIEW')
	For i = 1 To lnViews
		lError = DBSetProp(laView(i),'View','FetchAsNeeded',.T.)
	Endfor
	Return


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



