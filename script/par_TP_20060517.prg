Set Step On
If !Used ('config')
	Use config In 0
Endif

Create Cursor curKey (versia m)
Append Blank
Replace versia With 'EELARVE' In curKey
Create Cursor v_account (admin Int Default 1)
Append Blank
gnhandle = sqlconnect ('NarvaLvPg','vlad')

grekv = 1
*!*	gnHandle = 1
*!*	gversia = 'VFP'

*gnhandle = SQLConnect ('NjlvPg','vlad','490710')
*!*	*!*	*!*	gnhandle = sqlconnect ('NarvaLvPg','vlad','490710')
*!*	gnHandle = SQLConnect ('datelviru','vladislav','490710')
*gnHandle = SQLConnect ('kaevandus','vlad','490710')
gversia = 'PG'

IF gnHandle < 1
	MESSAGEBOX('Viga')
	return
ENDIF


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
&& îáíîâëÿåì ïàðàìåòðû îò÷åòîâ

=update_curprinter()
*update_tolk()
Do Case
	Case gversia = 'VFP'
		lcdefault = Sys(5)+Sys(2003)
		Select qryKey
		Scan For Mline(qryKey.Connect,1) = 'FOX'
			lcdata = Mline(qryKey.vfp,1)

			If File (lcdata)
				Open Data (lcdata) Exclusive
*!*					lcdataproc = lcdefault+'\tmp\buhdata5_20060216.sql'
*!*						Append proc from (lcdataproc) overwrite
*!*						If Dbused('buhdata5')
*!*							Set Database To buhdata5
*!*							Close Databases
*!*						Endif
*!*						If Used('buhdata5')
*!*							Use In buhdata5
*!*						Endif
*!*						Use (lcdata) In 0 Exclusive
*!*						Select buhdata5
*!*						Locate For objectid = 3
*!*						Append Memo buhdata5.Code From (lcdataproc) Overwrite
*!*						Use

*!*					Open Data (lcdata) Exclusive
*!*					Compile Database (lcdata)
*!*					Open Data (lcdata)
*!*					Set Database To buhdata5
				Set Default To Justpath (lcdata)
				lError =  _alter_vfp()
				Close Data
			Endif

			Set Default To (lcdefault)
*!*				Endif
		Endscan
		Use In qryKey
	Case gversia = 'PG'
		=sqlexec (gnHandle,'begin transaction')
		Select qryKey
*!*			Scan For Mline(qryKey.Connect,1) = 'PG'

		lError = _alter_pg ()
		If Vartype (lError ) = 'N'
			lError = Iif( lError = 1,.T.,.F.)
		Endif
		If lError = .F.
			=sqlexec (gnHandle,'rollback')
		Else
			=sqlexec (gnHandle,'commit')
		Endif

*		Endif

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
	=fnc_check_tp('016015','','Põhja-Eesti Verekeskus','70003483')
	=fnc_check_tp('135103','','Keila Tervisekeskuse Haldamise Asutus','75014439')
	=fnc_check_tp('005301','005501','SA Eesti Õiguskeskus','90001411')
	=fnc_check_tp('007306','007501','SA Archimedes','70003483')
	=fnc_check_tp('007307','007503','SA Eesti Kutsehariduse Reform','90000722')
	=fnc_check_tp('011306','011502','Eesti Laulu- ja Tantsupeo SA','90005188')
	=fnc_check_tp('011307','011503','SA UNESCO Eesti Rahvuslik Komisjon','90005797')
	=fnc_check_tp('011308','011506','SA Narva Aleksandri Kirik','90003350')
	=fnc_check_tp('015303','015501','Mitte-eestlaste Integratsiooni SA','90000788')
	=fnc_check_tp('017301','017501','SA Eesti Välispoliitika Instituut','90006087')
	=fnc_check_tp('015304','024501','SA A.H.Tammsaare Muuseum Vargamäel','90006963')
	=fnc_check_tp('015305','025501','SA Läänemaa Arenduskeskus','90000506')
	=fnc_check_tp('015306','030501','Saaremaa Ettevõtluse Edendamise SA','90004071')
	=fnc_check_tp('015307','033501','SA Viljandimaa Arenduskeskus','90004214')
	=fnc_check_tp('015308','034501','SA Võrumaa Arenguagentuur','90001581')
	=fnc_check_tp('015309','034502','SA Erametsakeskus','90005449')


Function fnc_check_tp
	Lparameters tcTP, tcvanaTP, tcNimetus, tcRegkood
	Local lnResult
	lnResult = 0
	If Empty(tcvanaTP)
		tcvanaTP = tcTP
	Endif

	Wait Window 'Kontrolin:' + tcTP Nowait

	Update asutus Set tp = tcTP Where regkood = tcRegkood And tp <> tcTP


	Select Id From Library Where kood = tcvanaTP And Library = 'TP' Into Cursor tmpTP

	If Used('tmpTP') And Reccount('tmpTP') = 0
		Insert Into Library (kood, nimetus, Library, rekvid, muud) Values (tcTP, tcNimetus, 'TP',1, tcRegkood)
		lnResult = 1
		Wait Window 'Kontrolin:' + tcTP + 'lisatud' Timeout 1
	Else
		If tcTP <> tcvanaTP
			Update Library Set kood = tcTP Where Id = tmpTP.Id
			Wait Window 'Kontrolin:' + tcTP + 'parandatud' Timeout 1
		Endif

	Endif

	Return lnResult

	=setpropview()
	Return

Function setpropview
	Set Data To buhdata5
	lnViews = Adbobject (laView,'VIEW')
	For i = 1 To lnViews
		lError = DBSetProp(laView(i),'View','FetchAsNeeded',.T.)
	Endfor
	Return


Function _alter_pg

	If v_account.admin > 0 Or v_account.peakasutaja > 0

		=fnc_check_tp('016015','','Põhja-Eesti Verekeskus','70003483')
		=fnc_check_tp('135103','','Keila Tervisekeskuse Haldamise Asutus','75014439')
		=fnc_check_tp('005301','005501','SA Eesti Õiguskeskus','90001411')
		=fnc_check_tp('007306','007501','SA Archimedes','70003483')
		=fnc_check_tp('007307','007503','SA Eesti Kutsehariduse Reform','90000722')
		=fnc_check_tp('011306','011502','Eesti Laulu- ja Tantsupeo SA','90005188')
		=fnc_check_tp('011307','011503','SA UNESCO Eesti Rahvuslik Komisjon','90005797')
		=fnc_check_tp('011308','011506','SA Narva Aleksandri Kirik','90003350')
		=fnc_check_tp('015303','015501','Mitte-eestlaste Integratsiooni SA','90000788')
		=fnc_check_tp('017301','017501','SA Eesti Välispoliitika Instituut','90006087')
		=fnc_check_tp('015304','024501','SA A.H.Tammsaare Muuseum Vargamäel','90006963')
		=fnc_check_tp('015305','025501','SA Läänemaa Arenduskeskus','90000506')
		=fnc_check_tp('015306','030501','Saaremaa Ettevõtluse Edendamise SA','90004071')
		=fnc_check_tp('015307','033501','SA Viljandimaa Arenduskeskus','90004214')
		=fnc_check_tp('015308','034501','SA Võrumaa Arenguagentuur','90001581')
		=fnc_check_tp('015309','034502','SA Erametsakeskus','90005449')

	ENDIF
ENDFUNC
	
	
Function fnc_check_tp
	Lparameters tcTP, tcvanaTP, tcNimetus, tcRegkood
	Local lnResult
	lnResult = 0
	If Empty(tcvanaTP)
		tcvanaTP = tcTP
	Endif

	Wait Window 'Kontrolin:' + tcTP Nowait

	lcString = "UPDATE asutus SET tp = '" + tcTP +"' WHERE regkood = '" + tcRegkood +"' AND tp <> '" +tcTP+"'"
	If execute_sql(lcString) < 0
		Return .F.
	Endif


	lcString = "SELECT id FROM library WHERE kood = '" + tcvanaTP +"' AND library = 'TP' "
	If execute_sql(lcString,'tmpTP') < 0
		Return .F.
	Endif

	If Used('tmpTP') And Reccount('tmpTP') = 0
		lcString = " INSERT INTO library (kood, nimetus, library, rekvid, muud) VALUES ('"+;
			tcTP +"','"+ tcNimetus+"','TP',1,'"+tcRegkood+"')"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lnResult = 1
		Wait Window 'Kontrolin:' + tcTP + 'lisatud' Timeout 1
	Else
		If tcTP <> tcvanaTP
			lcString = "UPDATE library SET kood = '"+tcTP +"' WHERE id = " + Str(tmpTP.Id)
			If execute_sql(lcString) < 0
				Return .F.
			Endif
			Wait Window 'Kontrolin:' + tcTP + 'parandatud' Timeout 1
		Endif

	Endif

	Return lnResult
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
	ENDFOR
ENDFUNC


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
	lError = sqlexec (gnHandle,cString,'qryHelp')
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
	lError = sqlexec (gnHandle,cString,'qryFld')
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
		lError = sqlexec(gnHandle,tcString)
	Else
		lError = sqlexec(gnHandle,tcString, tcCursor)
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
	Locate For Lower(objekt) = 'PalkOper ' And Id = 4
	If !Found()
* lisamine
		Append Blank
		Replace Id With 4,;
			objekt With 'PalkOper ',;
			nimetus1 With 'Palgakaart',;
			nimetus2 With 'Palgakaart',;
			procfail With 'palk_kaart_report1 ',;
			reportfail With 'palgakaart_report1',;
			reportvene With 'palgakaart_report1' In curPrinter
	Endif

	Use In curPrinter

	lcFile = 'curprinter.dbf'
	Use (lcFile) In 0 Alias curPrinter

	Select curPrinter
	Select curPrinter
	Locate For Lower(objekt) = 'PalkOper ' And Id = 4
	If !Found()
* lisamine
		Append Blank
		Replace Id With 4,;
			objekt With 'PalkOper ',;
			nimetus1 With 'Palgakaart',;
			nimetus2 With 'Palgakaart',;
			procfail With 'palk_kaart_report1 ',;
			reportfail With 'palgakaart_report1',;
			reportvene With 'palgakaart_report1' In curPrinter
	Endif

*!*	Locate For Lower(objekt) = 'vanemtasu' And Id = 2
*!*	If !Found()
*!*	* lisamine
*!*		Append Blank
*!*		Replace Id With 2,;
*!*			objekt With 'vanemtasu',;
*!*			nimetus1 With 'Ðîäèòåëüñêàÿ ïëàòà (âåäîìîñòü)',;
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
*!*			nimetus1 With 'ñ÷åòà',;
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
*!*			nimetus1 With 'Ñïèñîê',;
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
*!*			nimetus1 With 'Äîëæíèêè',;
*!*			nimetus2 With 'Võlnikud',;
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
*!*			nimetus1 With 'Ðàñ÷åò ïåíè',;
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
*!*			nimetus1 With 'Ðîäèòåëüñêàÿ ïëàòà (âåäîìîñòü)',;
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
*!*			nimetus1 With 'ñ÷åòà',;
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
*!*			nimetus1 With 'Ñïèñîê',;
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
*!*			nimetus1 With 'Äîëæíèêè',;
*!*			nimetus2 With 'Võlnikud',;
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
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblasutus','Îðãàíèçàöèÿ:','Asutus:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblKpv','Äàòà:','Kuupäev:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblviivis','Ïåíÿ (%):','Viivis (%):')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblkood','Êîä:','Kood:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.btnArvesta','Ðàñ÷åò','Arvesta')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.btnUusArve','Ñ÷åò','Arve')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblKokku','Èòîãî:','Kokku:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column1.header1','Ñ÷åò','Konto')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column2.header1','Ïîÿñíåíèå','Selgitus')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column3.header1','Íîìåð','Number')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column4.header1','Ñóììà','Summa')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column5.header1','Ñðîê','Tähtaeg')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column6.header1','Îïëà÷åíî','Makstud')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column7.header1','Äîëã','Võlg')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column8.header1','Ïåíè','Viivis')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column9.header1','Êîë-âî äíåé','Päevade arv')
	Endif


Endfunc
