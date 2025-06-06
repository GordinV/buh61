gnhandle = SQLConnect ('hooldekodu')

lcString = "select LTRIM(RTRIM(relname::varchar)) as relname from pg_stat_all_tables where schemaname = 'public'"
lError = execute_sql(lcString,'v_tbl')
If lError < 1
	Set Step On
	Return
Endif

Select v_tbl
Scan
	Wait Window v_tbl.relname Nowait
	If !Empty(check_field_pg(v_tbl.relname,'ID'))
		lcString = 'select MAX(id) as id from '+v_tbl.relname
		lError = execute_sql(lcString,'v_id')
		If lError < 1
			Set Step On
			Return
		Endif
		If !Empty(v_id.Id) And !Isnull(v_id.Id)
			lcString = "SELECT setval('"+Alltrim(v_tbl.relname)+"_id_seq'"+","+Alltrim(Str(v_id.Id))+", true)"
			lError = execute_sql(lcString)
			If lError < 1
				Set Step On
				Return
			Endif
		Endif


	Endif

Endscan





=SQLDISCONNECT(gnhandle)



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
	lError = sqlexec (gnhandle,cString,'qryHelp')
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
	lError = sqlexec (gnhandle,cString,'qryFld')
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
		lError = sqlexec(gnhandle,tcString)
	Else
		lError = sqlexec(gnhandle,tcString, tcCursor)
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

*!*		Select curPrinter
*!*		Locate For Lower(objekt) = 'Aruanne' And Id = 120
*!*		If Found()
*!*			Replace procfail With 'eelarve\kbmaruanne_report1',;
*!*				reportfail With 'eelarve\kbmaruanne_report1',;
*!*				reportvene With 'eelarve\kbmaruanne_report1' In curPrinter
*!*		Endif

*!*		Use In curPrinter

	Use aruanne
	Locate For Id = 25
	Replace konto With 1 In aruanne

	Use In aruanne

*!*		lcFile = 'curprinter.dbf'
*!*		Use (lcFile) In 0 Alias curPrinter

*!*		Select curPrinter
*!*		Select curPrinter
*!*		Locate For Lower(objekt) = 'PalkOper ' And Id = 4
*!*		If !Found()
*!*	* lisamine
*!*			Append Blank
*!*			Replace Id With 4,;
*!*				objekt With 'PalkOper ',;
*!*				nimetus1 With 'Palgakaart',;
*!*				nimetus2 With 'Palgakaart',;
*!*				procfail With 'palk_kaart_report1 ',;
*!*				reportfail With 'palgakaart_report1',;
*!*				reportvene With 'palgakaart_report1' In curPrinter
*!*		Endif

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

*!*		Use In curPrinter
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




Function sp_kontoplaaniparandused_20050222
	Lparameters tcKood, tcRegkood, tcNimetus, ttMuud
	Local	lcRet , lcId
	Wait Window 'Parandan tp kood:'+tcKood Nowait
*Library
	Select  *  From Library ;
		WHERE (Ltrim(Rtrim(Upper(Nimetus)))=Ltrim(Rtrim(Upper(tcNimetus))) ;
		or Ltrim(Rtrim(Upper(Kood))) = Ltrim(Rtrim(Upper(tcKood))));
		and Library = 'TP' Into Cursor lrLibr

	If Reccount('lrLibr') > 0
		If Ltrim(Rtrim(Upper(lrLibr.Kood))) <> Ltrim(Rtrim(Upper(tcKood)))
			Update Library Set Kood = tcKood Where Id=lrLibr.Id
		Endif
	Else
		Insert Into Library (rekvid,Kood,Nimetus,Library,muud) Values (1,tcKood,tcNimetus,'TP',ttMuud)
	Endif

*ASUTUS
	Select *  From asutus ;
		WHERE Regkood = tcRegkood;
		INTO Cursor  lrAsutus
	If Reccount('lrAsutus') > 0
		If lrAsutus.tp <> tcKood
			Update asutus Set tp=tcKood Where Id=lrAsutus.Id
		Endif
	Endif
	Clear Window

Endfunc

