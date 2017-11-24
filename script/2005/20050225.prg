Set Step On
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

grekv = 1
gnHandle = 1
gversia = 'VFP'

*!*	gnhandle = SQLConnect ('NjlvPg','vlad','490710')
	gnhandle = sqlconnect ('NarvaLvPg','vlad','490710')
*	gnHandle = SQLConnect ('avpsoft2005','vladislav','490710')
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
&& обновляем параметры отчетов

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
				lcdataproc = lcdefault+'\tmp\buhdata5_20050225.sql'
				If File (lcdataproc)
					Append proc from (lcdataproc) overwrite
					If Dbused('buhdata5')
						Set Database To buhdata5
						Close Databases
					Endif
					If Used('buhdata5')
						Use In buhdata5
					Endif
*!*						Use (lcdata) In 0 Exclusive
*!*						Select buhdata5
*!*						Locate For objectid = 3
*!*						Append Memo buhdata5.Code From (lcdataproc) Overwrite
*!*						Use

			Endif
			Open Data (lcdata) Exclusive
			Compile Database (lcdata)
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

*DROP VIEW curPuudumine_


=sp_kontoplaaniparandused_20050222('561502','90007655','SA Valga Sport','Lisatud uus uksus')
=sp_kontoplaaniparandused_20050222('123101','75032325','Tallinna Keskkonnaamet','Lisatud uus uksus')
=sp_kontoplaaniparandused_20050222('113101','75028252','Tallinna Transpordiamet','Nime muutmine (endine Tallinna Transpordi- ja Keskkonnaamet)')
=sp_kontoplaaniparandused_20050222('105102','75008953','Kadrioru Park','Muudetud kood (uus kood 123102. Uksus viidud Tallinna Kommunaalameti haldusalast Tallinna Keskkonnaameti haldusalasse)')
=sp_kontoplaaniparandused_20050222('123102','75008953','Kadrioru Park','Muudetud kood (endine kood 105102. Uksus viidud Tallinna Kommunaalameti haldusalast Tallinna Keskkonnaameti haldusalasse)')
=sp_kontoplaaniparandused_20050222('105103','75027896','Tallinna Kalmistud','Muudetud kood (uus kood 123103. Uksus viidud Tallinna Kommunaalameti haldusalast Tallinna Keskkonnaameti haldusalasse)')
=sp_kontoplaaniparandused_20050222('123103','75027896','Tallinna Kalmistud','Muudetud kood (endine kood 105103. Uksus viidud Tallinna Kommunaalameti haldusalast Tallinna Keskkonnaameti haldusalasse)')
=sp_kontoplaaniparandused_20050222('112102','75021244','Tallinna Botaanikaaed','Muudetud kood (uus kood 123104. Uksus viidud Tallinna Linnaplaneerimise Ameti haldusalast Tallinna Keskkonnaameti haldusalasse)')
=sp_kontoplaaniparandused_20050222('123104','75021244','Tallinna Botaanikaaed','Muudetud kood (endine kood 112102. Uksus viidud Tallinna Linnaplaneerimise Ameti haldusalast Tallinna Keskkonnaameti haldusalasse)')
=sp_kontoplaaniparandused_20050222('117104','75016332','Kristiine Sport','Muudetud kood (uus kood 111106. Uksus viidud Kristiine Linnaosa Valitsuse haldusalast Tallinna Spordi- ja Noorsooameti haldusalasse)')
=sp_kontoplaaniparandused_20050222('111106','75016332','Kristiine Sport','Muudetud kood (endine kood 117104. Uksus viidud Kristiine Linnaosa Valitsuse haldusalast Tallinna Spordi- ja Noorsooameti haldusalasse)')
=sp_kontoplaaniparandused_20050222('007042','70003796','Haapsalu Kutsehariduskeskus','Nime muutmine (endine nimi Taebla Kutsekeskkool)')
=sp_kontoplaaniparandused_20050222('131401','10397808','Kehra Kermot OU','Liidetud OU-ga Velko AV (TP 131402)')
=sp_kontoplaaniparandused_20050222('178401','11001534','OU Kohtla Valla Elamu','Uus uksus')
=sp_kontoplaaniparandused_20050222('651501','74000116','Eesti Liikluskindlustuse Fond','Avalik-oiguslik jur isik lopetab tegevuse, reorganiseeritud erasektori uksuseks (800499)')
=sp_kontoplaaniparandused_20050222('012020','70001515','Harju Teedevalitsus','')
=sp_kontoplaaniparandused_20050222('012020','70007541','Pohja Regionaalne Maanteeamet','Muudetud reg nr ja nimetus')
=sp_kontoplaaniparandused_20050222('596312','90007448','SA Peipsiveere Hooldusravikeskus','Uus uksus')
=sp_kontoplaaniparandused_20050222('446121','75006902','Tartu Annemoisa Kool','Likvideeritud, saldod votab ule 01.01.05 Tartu LV Haridusosakond 446110')
=sp_kontoplaaniparandused_20050222('44614A','75006612','Tartu Teatrilabor','Likvideeritud, saldod votab ule 01.01.05 Tartu LV Kultuuriosakond 446140')
=sp_kontoplaaniparandused_20050222('446401','10802597','AS Anne Turg','Muudud erasektorile')
=sp_kontoplaaniparandused_20050222('011509','90008666','SA Vene Teater','Uus uksus')
=sp_kontoplaaniparandused_20050222('011510','90007715','SA Tehvandi Spordikeskus','Uus uksus')
=sp_kontoplaaniparandused_20050222('011042','70004554','Eesti Riiklik Vene Draamateater','Umberkujundatud sihtasutuseks')
=sp_kontoplaaniparandused_20050222('011050','70000964','Eesti Olumpia Oppetreeningkeskus Tehvandi','Umberkujundatud sihtasutuseks')
=sp_kontoplaaniparandused_20050222('011044','70000993','Rakvere Teater','Umberkujundatud sihtasutuseks')
=sp_kontoplaaniparandused_20050222('015009','70006441','Eesti Tuletorjemuuseum','')
=sp_kontoplaaniparandused_20050222('015001','70006441','Eesti Tuletorjemuuseum','Uhendatud Siseministeeriumi raamatupidamisarvestusse')
=sp_kontoplaaniparandused_20050222('138301','90008614','Kiili Varahalduse SA','Uus uksus')
=sp_kontoplaaniparandused_20050222('312402','10374279','Sauga Vara AS','Likvideeritud')
=sp_kontoplaaniparandused_20050222('545102','75025012','Viiratsi Valla MA Viikom','Lopetatud')
=sp_kontoplaaniparandused_20050222('545401','11062274','OU Viiratsi Veevark','Uus uksus')
=sp_kontoplaaniparandused_20050222('031002','70003075','Aarike Hooldekodu','Reorganiseeritud sihtasutuseks')
=sp_kontoplaaniparandused_20050222('434301','90007709','SA Aarike Hooldekodu','Uus uksus')
=sp_kontoplaaniparandused_20050222('009701','90008494','Riigikaitse Edendamise SA','Uus uksus')
=sp_kontoplaaniparandused_20050222('179115','75006121','Elanike register','Asutus likvideeritakse, tegevus liidetakse uksusesse 179101')
=sp_kontoplaaniparandused_20050222('359401','10085960','Ruusa Teenus OU','')
=sp_kontoplaaniparandused_20050222('359404','10085960','Ruusa Teenus OU','TP koodi parandamine')
=sp_kontoplaaniparandused_20050222('192102','75026483','Vaivara Lasteaed','Tsentraliseeritud TP 192101')
=sp_kontoplaaniparandused_20050222('192103','75015893','Vaivara Pohikool','Tsentraliseeritud TP 192101')
=sp_kontoplaaniparandused_20050222('192104','75010223','Vaivara Huvikeskus','Tsentraliseeritud TP 192101')
=sp_kontoplaaniparandused_20050222('596504','90007572','SA Teaduskeskus AHHAA','Uus uksus')
=sp_kontoplaaniparandused_20050222('100405','10422802','Signaal AS','Muudud erasektorisse (800599)')
=sp_kontoplaaniparandused_20050222('100601','10363229','Rocca-Al-Mare Tivoli AS','Muudud erasektorisse (800599)')
=sp_kontoplaaniparandused_20050222('002301','90007081','Uhiskondliku Leppe SA','Uus uksus')
=sp_kontoplaaniparandused_20050222('002501','90005780','SA Vabariigi Presidendi Kultuurirahastu','Uus uksus')
=sp_kontoplaaniparandused_20050222('009040','70007144','Kaitsevae Ohuvae Staap','Muudetud registreerimisnumber (endine 01313333)')
=sp_kontoplaaniparandused_20050222('596413','11044696','AS Emajoe Veevark','Uus uksus')
=sp_kontoplaaniparandused_20050222('149103','75026218','Juri Gumnaasium','Tsentraliseeritud TP 149101')
=sp_kontoplaaniparandused_20050222('175501','90003315','SA Johvi Haigla','Uus uksus')
=sp_kontoplaaniparandused_20050222('175502','90003446','SA Johvi Toostuspark','Uus uksus')
=sp_kontoplaaniparandused_20050222('011402','10223787','Perioodika AS,Likvideerimisel', 'tegevus ule antud SA-le Kultuurileht (TP 011501)')
=sp_kontoplaaniparandused_20050222('604403','10475135','OU Majaks','Likvideeritud')
=sp_kontoplaaniparandused_20050222('185104','75008386','Narva Linnaarhiiv','Alates 01.02.05 liidetud Narva Linnakantseleiga (185102)')
=sp_kontoplaaniparandused_20050222('007303','90005872','Eesti Infotehnoloogia SA','Ule viidud valitsussektorisse ')
=sp_kontoplaaniparandused_20050222('007304','90008287','Elukestva Oppe Arendamise SA Innove','Ule viidud valitsussektorisse')
=sp_kontoplaaniparandused_20050222('011511','90003278','SA Virumaa Muuseumid','Viidud valja valitsussektorist')
=sp_kontoplaaniparandused_20050222('011305','90006360','Kunstimuuseumi Ehituse SA','Ule viidud valitsussektorisse')



	=setpropview()
* menu records

*!*		If !Used('menumodul')
*!*			Use menumodul In 0
*!*		Endif
*!*		If !Used('menupohi')
*!*			Use menupohi In 0 Order Id
*!*		Endif
*!*		If !Used('menuisik')
*!*			Use menuisik In 0
*!*		Endif

*!*		Select menupohi
*!*		locate For Alltrim(Upper(Pad)) = Alltrim(Upper('Toograafik')) AND bar = '5'
*!*		If !Found()
*!*			lcOmandus = 'RUS CAPTION=Расчет графика рабочего времени'+Chr(13)+'EST CAPTION=Tццgraafik arvestus'
*!*			lcproc = "=nObjekt('do samm_toograf')"

*!*			Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values ;
*!*				('Toograafik','5',lcproc, lcOmandus, 2)
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'EELARVE')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'RAAMA')
*!*			Insert Into menumodul (parentId, Modul) Values (menupohi.Id, 'PALK')
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'KASUTAJA', 1)
*!*			Insert Into menuisik (parentId, gruppid, jah) Values (menupohi.Id, 'PEAKASUTAJA', 1)
*!*		ELSE
*!*			replace level_ WITH 2 IN menupohi
*!*		Endif

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


		lcFile = 'tmp/fnc_muudatused20050225.txt'

		If File(lcFile)
			Wait Window 'Db parandus:'+lcFile Nowait
			Create Cursor pg_proc (Proc m)
			Append Blank
			Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
			lcString = pg_proc.Proc
			If execute_sql(lcString) < 0
				Return .F.
			Endif
		Endif
	Endif

*!*
*!*		lcFile = 'tmp/gen_palkoper.sql'
*!*		Wait Window 'Db parandus:'+lcFile Nowait
*!*		If File(lcFile)
*!*			Create Cursor pg_proc (Proc m)
*!*			Append Blank
*!*			Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
*!*			lcString = pg_proc.Proc
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif
*!*		Endif



*!*		lcString = " select id from menupohi where UPPER(pad) = UPPER('Toograafik') and bar = '5'"
*!*		lError = sqlexec(gnHandle,lcString,'qrymenupohi')

*!*		If Reccount('qrymenupohi') < 1

*!*			lcOmandus = 'RUS CAPTION=Расчет графика рабочего времени'+Chr(13)+'EST CAPTION=Tццgraafik arvestus'
*!*			lcproc = [=nObjekt("do samm_toograf")]

*!*			lcString = "Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values "+;
*!*				"('Toograafik','5','"+lcproc+"','"+lcOmandus+"', 2)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif
*!*			lcString = " select id from menupohi where UPPER(pad) = 'TOOGRAAFIK' and bar = '5'"
*!*			lError = sqlexec(gnHandle,lcString,'qrymenupohi')

*!*			lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'EELARVE')"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'RAAMA')"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'PALK')"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*		Endif

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
*!*			nimetus1 With 'Родительская плата (ведомость)',;
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
*!*			nimetus1 With 'счета',;
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
*!*			nimetus1 With 'Список',;
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
*!*			nimetus1 With 'Должники',;
*!*			nimetus2 With 'Vхlnikud',;
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
*!*			nimetus1 With 'Расчет пени',;
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
*!*			nimetus1 With 'Родительская плата (ведомость)',;
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
*!*			nimetus1 With 'счета',;
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
*!*			nimetus1 With 'Список',;
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
*!*			nimetus1 With 'Должники',;
*!*			nimetus2 With 'Vхlnikud',;
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
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblasutus','Организация:','Asutus:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblKpv','Дата:','Kuupдev:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblviivis','Пеня (%):','Viivis (%):')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblkood','Код:','Kood:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.btnArvesta','Расчет','Arvesta')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.btnUusArve','Счет','Arve')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.lblKokku','Итого:','Kokku:')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column1.header1','Счет','Konto')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column2.header1','Пояснение','Selgitus')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column3.header1','Номер','Number')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column4.header1','Сумма','Summa')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column5.header1','Срок','Tдhtaeg')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column6.header1','Оплачено','Makstud')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column7.header1','Долг','Vхlg')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column8.header1','Пени','Viivis')
		Insert Into tolk (objektid, objekt, captionorg, captionsub) Values ('viivis','.grid1.column9.header1','Кол-во дней','Pдevade arv')
	Endif


Endfunc




FUNCTION sp_kontoplaaniparandused_20050222 
LPARAMETERS tcKood, tcRegkood, tcNimetus, ttMuud 
local	lcRet , lcId 	
WAIT WINDOW 'Parandan tp kood:'+tcKood nowait
*Library
	SELECT  *  FROM library ;
		WHERE (ltrim(rtrim(upper(Nimetus)))=ltrim(rtrim(upper(tcNimetus))) ;
		or ltrim(rtrim(upper(Kood))) = ltrim(rtrim(upper(tcKood))));
		and library = 'TP' INTO CURSOR lrLibr
	
	IF RECCOUNT('lrLibr') > 0 
		IF ltrim(rtrim(upper(lrLibr.Kood))) <> ltrim(rtrim(upper(tcKood))) 
			UPDATE library SET Kood = tcKood WHERE Id=LrLibr.id
		Endif
	else
		INSERT INTO library (rekvid,kood,nimetus,library,muud) VALUES (1,tcKood,tcNimetus,'TP',ttMuud)
	endif
	
*ASUTUS
	SELECT *  FROM asutus ;
		WHERE Regkood = tcRegkood;
		INTO CURSOR  lrAsutus
	if RECCOUNT('lrAsutus') > 0
		IF lrAsutus.tp <> tcKood
			UPDATE asutus SET tp=tcKood WHERE Id=LrAsutus.id
		endif
	endif
CLEAR WINDOW 

ENDFUNC

