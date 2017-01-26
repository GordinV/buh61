		If !used ('config')
			Use config in 0
		Endif

Create cursor curKey (versia m)
Append blank
Replace versia with 'EELARVE' in curKey
Create cursor v_account (admin int default 1)
Append blank
gnhandle = sqlconnect ('buhdata5zur','zinaida','159')
*gnhandle = sqlconnect ('NARVA','vladislav','490710')
*!*	*!*	*!*	*!*	*!*	&&,'zinaida','159')
gversia = 'MSSQL'
grekv = 1
*!*	grekv = 1
*!*	gnHandle = 1
*!*	gversia = 'VFP'
Local lError

If v_account.admin < 1
	Return .t.
Endif
If !used ('key')
	Use key in 0
Endif
Select key
lnFields = afields (aObjekt)
Create cursor qryKey from array aObjekt
Select qryKey
Append from dbf ('key')
Use in key
=secure('OFF')

Do case
	Case gversia = 'VFP'
		lcdefault = sys(5)+sys(2003)
		Select qryKey
		Scan for mline(qryKey.connect,1) = 'FOX'
			lcdata = mline(qryKey.vfp,1)
			If file (lcdata)
				Open data (lcdata)
*!*					lcdataproc = lcdefault+'\tmp\0909proc.prn'
*!*					If file (lcdataproc)
*!*						Append proc from (lcdataproc) overwrite
*!*					Endif
				Set DEFAULT TO justpath (lcdata)
				lError =  _alter_vfp()
				Close data
				Set default to (lcdefault)
			Endif
		Endscan
		Use in qryKey
	Case gversia = 'MSSQL'
*		=sqlexec (gnHandle,'begin transaction')
		lError = _alter_mssql ()
		If vartype (lError ) = 'N'
			lError = iif( lError = 1,.t.,.f.)
		Endif
*!*			If lError = .f.
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
	LOCAL lnObj, lnElement
	lnObj = ADBOBJECTS(laObj,'TABLE')
	IF lnObj < 1
		RETURN .f.
	ENDIF
	lnElement = ASCAN(laObj,UPPER('PALK_TMPL'))
	IF lnElement > 0
		RETURN .t.
	endif
	lcString = "create table palk_tmpl (id int default next_number ('PALK_TMPL') PRIMARY KEY,"+;
		'parentid int default 0, libId int default 0, summa y default 100, percent_  int default 1,'+;
		'tulumaks int default 1, tulumaar int default 26, tunnusid int default 0)'
	&lcString	
	If used ('palk_tmpl')
		Use IN palk_tmpl 
	Endif

	=setpropview()
	Return

Function setpropview
	Set data to buhdata5
	lnViews = adbobject (laView,'VIEW')
	For i = 1 to lnViews
		lError = dbsetprop(laView(i),'View','FetchAsNeeded',.t.)
	Endfor
	Return


Function _alter_mssql


	cString = "sp_help"
	lError = sqlexec (gnHandle,cString)
	If lError > 0
		If used ('sqlresult') 
			Select sqlresult
			Locate for upper(name) = 'PALK_TMPL' AND object_type = 'user table'
			If !found ()
				cString = 'create table dbo.palk_tmpl (id int IDENTITY (1, 1) NOT NULL  PRIMARY KEY,'+;
					'parentid int NOT NULL default 0, libId int NOT NULL default 0, summa money NOT NULL default 100,'+;
					'percent_  int NOT NULL default 1,'+;
					'tulumaks int NOT NULL default 1, tulumaar int NOT NULL default 26, tunnusid int NOT NULL default 0)'

				lError = sqlexec(gnHandle, cString)

				cString = 'GRANT  SELECT ,  UPDATE ,  INSERT,  DELETE  ON dbo.palk_tmpl  TO dbkasutaja'
				 = sqlexec(gnhandle, cString)
				cString = 'GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON dbo.palk_tmpl  TO dbpeakasutaja'
				 = sqlexec(gnhandle, cString)
				cString = 'GRANT  SELECT  ON dbo.palk_tmpl  TO dbadmin'
				 = sqlexec(gnhandle, cString)
					
			Endif

		Endif
	Endif

	If used ('sqlresult')
		Use in sqlresult
	Endif	
	If lError < 0
		Return .f.
	endif
Endproc



Function secure
	Lparameters LCENCR
	maxno=100
	LCENCR=UPPER(ALLT(LCENCR))
	If LCENCR<>'ON' AND LCENCR<>'OFF'
		Return MESSAGEBOX("Pass ON or OFF for encryption/decryption!")
	Endif
&&SET PROC TO securedata ADDI
* loop through all fields in a table
	lnFields=FCOUNT()
	For J = 1 TO lnFields
		LCFIELD=FIELD(J)
		Do CASE
			Case TYPE(LCFIELD) $ 'CM'
* replace the all the contents of this particular field
				Repl ALL &LCFIELD WITH CONVRT(LCENCR,&LCFIELD)
		Endcase
	Endfor



Procedure CONVRT
	Lparameters lcencrypt,lcString
	If parameters()<2
		Messagebox('Pass two arguments, [On Off] and string')
		Return
	Endif
	lcencrypt=upper(allt(lcencrypt))
* encrypt data
* take a string and shift the data to the right one place
	If lcencrypt='ON'
		lnlen=len(allt(lcString))
		lcnewstring=''
* convert the string to the value of the current string + the position
* number of the char in the string.  A string of "ABC" would be converted
* to "BDF"

		For i = 1 to lnlen
* asc(substring(lcstring,i,1)) for a "d" is 100
* so if the "d" were in the 1st position it would be converted
* to "e" via the following line
			If i<maxno
				lcchar=chr(asc(substr(lcString,i,1))+i)
			Else
				lcchar=chr(asc(substr(lcString,i,1))+1)
			Endif
*build new string from converted characters
			lcnewstring=lcnewstring+lcchar
		Endfor
		RETVAL=lcnewstring
	Else
		lnlen=len(allt(lcString))
		lcnewstring=''
		For i = 1 to lnlen
* asc(substring(lcstring,i,1)) for a "d" is 100
* so if the "d" were in the 1st position it would be converted
* to "e" via the following line
			If i<maxno
				lcchar=chr(asc(substr(lcString,i,1))-i)
			Else
				lcchar=chr(asc(substr(lcString,i,1))-1)
			Endif

*build new string from converted characters
			lcnewstring=lcnewstring+lcchar
		Endfor
		RETVAL=lcnewstring
	Endif
	Return (RETVAL)



