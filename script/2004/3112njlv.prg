Set Safety Off

*!*	If !Used ('config')
*!*		Use config In 0
*!*	Endif

Create Cursor curKey (versia m)
Append Blank
Replace versia With 'EELARVE' In curKey
Create Cursor v_account (admin Int Default 1)
Append Blank

gnhandle = SQLConnect ('njlvpg')
If gnhandle < 0
	Messagebox('Viga connection','Kontrol')
	Set Step On
	Return
Endif
grekv = 1
gversia = 'PG'


Local lError
=sqlexec (gnhandle,'begin work')
Set Step On
lError = _alter_pg ()
If Vartype (lError ) = 'N'
	lError = Iif( lError = 1,.T.,.F.)
Endif
If lError = .F.
	=sqlexec (gnhandle,'ROLLBACK WORK')
Else
	=sqlexec (gnhandle,'COMMIT WORK')
*!*		Wait Window 'Grant access to views' Nowait
*!*		lError =pg_grant_views()
*!*		Wait Window 'Grant access to tables' Nowait
*!*		lError = pg_grant_tables()
Endif
=SQLDISCONNECT(gnhandle)
If Used('qryLog')
	Copy Memo qryLog.Log To Buh60Dblog.Log
	Use In qryLog
Endif

Function _alter_pg







* 2. kontrol syst user

&& import asutused
	lError = 1
*!*		lError = kasutajad_import()
*!*		If lError > 0
*!*			lError=rekv_import()
*!*		Endif
*!*		If lError > 0
*!*			lError=userid_import()
*!*		Endif
*!*		If lError > 0
*!*			lError = nom_import()
*!*		Endif
*!*			IF lError > 0
*!*				lError = palkamet_import()
*!*			ENDif
*!*			IF lError > 0
*!*				lError = palkosakond_import()
*!*			ENDif

*!*		If lError > 0
*!*			lError=palklib_import()
*!*		Endif

*!*		If lError > 0
*!*			lError=asutus_import()
*!*		Endif
*!*		If lError > 0
*!*			lError=pv_import()
*!*		Endif
*!*		If lError > 0
*!*			lError=palk_import()
*!*		Endif
*!*		If lError > 0
*!*			lError = palk_asutus_import()
*!*		Endif
*!*		If lError > 0
*!*			lError = set_serials()
*!*		Endif

	If lError > 0
		lError=tp_import()
	Endif
	If lError > 0
		lError=kontoplaan_import()
	Endif
	If lError > 0
		lError=tt_import()
	Endif
	If lError > 0
		lError = allikad_import()
	Endif
	If lError > 0
		lError = rv_import()
	Endif
	If lError > 0
		lError = kontoplaan_KORREGEIMINE()
	Endif
*!*		If lError > 0
*!*			Set Step On
*!*			lError = Kultuuriosakond_import()
*!*		Endif
	Return lError
Endfunc

Function Kultuuriosakond_import
	lcFile = 'c:\avpsoft\files\buh60\temp\kultuurdbf.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Use (lcFile) In 0 Alias kultuur
*!*		Create Cursor mssqllib(	osakond c(120), osakkood c(20), pohikont int, resident c(40), aadress c(254),;
*!*			pangakood c(3), pangakonto c(20), isikukood c(11), nimetus c(254) , amet c(120), ametiliik c(20), koormus n(12,4),;
*!*			palgmaar n(12,4), palk n(12,4))
*!*		Append From (Ltrim(Rtrim(lcFile))) Type CSV DELIMITED WITH CHARACTER  ';'
*!*		brow

	Select kultuur
	Scan
&& kontrol
		Wait Window Str(Recno())+'-'+Str(Reccount()) Nowait
&& Osakond
		lcNimetus  = Ltrim(Rtrim(kultuur.osakond))
		lckood = Ltrim(Rtrim(kultuur.osakonna_k))
&& check for kood
		lcString = "select id from library where kood = '"+lckood+ "' and library = 'OSAKOND' and rekvid = 13"
		lError = sqlexec(gnhandle, lcString, 'qryOsakondId')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			_Cliptext = lcString
			Exit
		Endif
		If Reccount('qryOsakondId') < 1
&& uus osakond
			lcString = " insert into library (rekvid,kood,nimetus,library) values ("+;
				Str(13)+",'"+Ltrim(Rtrim(lckood))+"','"+;
				lcNimetus+"','OSAKOND')"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
&& check for kood
			lcString = "select id from library where kood = '"+lckood+"' and library = 'OSAKOND' and rekvid = 13"
			lError = sqlexec(gnhandle, lcString, 'qryOsakondId')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
&& Amet
		lcAmet = Ltrim(Rtrim(kultuur.amet))
		If Empty(lcAmet)
			lcAmet = Ltrim(Rtrim(kultuur.palga_liik))
		Endif
		lcAkood = Left(lcAmet,20)
		lcString = "select id from library where nimetus = '"+lcAmet+"' and library = 'AMET' and rekvid = 13"
		lError = sqlexec(gnhandle, lcString, 'qryAmetId')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			_Cliptext = lcString
			Exit
		Endif
		If Reccount('qryAmetId') < 1
&& ins amet
			lcString = " insert into library (rekvid,kood,nimetus,library) values ("+;
				Str(13)+",'"+Ltrim(Rtrim(lcAkood))+"','"+;
				lcAmet+"','AMET')"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
			lcString = "select id from library where nimetus = '"+lcAmet+"' and library = 'AMET' and rekvid = 13"
			lError = sqlexec(gnhandle, lcString, 'qryAmetId')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif

&& palk_asutus
		lcString = "select id from palk_asutus where osakondid = "+Str(qryOsakondId.Id)+;
			" and ametId = " + Str(qryAmetId.Id)

		lError = sqlexec(gnhandle, lcString, 'qryPalkAsutusId')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			_Cliptext = lcString
			Exit
		Endif
		If Reccount('qryPalkAsutusId') < 1
&& ins amet

			lcString = " insert into palk_asutus (rekvid,osakondid,ametid) values ("+;
				"13,"+Str(qryOsakondId.Id)+","+Str(qryAmetId.Id)+")"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
			lcString = "select id from palk_asutus where osakondid = "+Str(qryOsakondId.Id)+;
				" and ametId = " + Str(qryAmetId.Id)

			lError = sqlexec(gnhandle, lcString, 'qryPalkAsutusId')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
&& isik
		lcIsikKood = Ltrim(Rtrim(kultuur.isikukood))
		lcNimetus = Ltrim(Rtrim(kultuur.nimi))
		lcAadress = Ltrim(Rtrim(kultuur.aadress))
		lcPank = Iif(Empty(kultuur.pangakood),'0',kultuur.pangakood)
		lcAa = kultuur.pangakonto
		lnPohikoht = Val(Alltrim(kultuur.vorm_tsd__))
		lcresident = Iif(!Empty(kultuur.resident_m),'1','0')
		If !Empty(lcIsikKood)
			lcString = "select id from asutus where UPPER(regkood) = '"+Upper(lcIsikKood)+"'"
		Else
			lcString = "select id from asutus where UPPER(nimetus) = '"+Upper(lcNimetus)+"'"
		Endif

		lError = sqlexec(gnhandle, lcString,'qryAsutusId')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryAsutusId') < 1

			lcString = " insert into asutus (rekvid, regkood,nimetus, aadress, tp) values ("+;
				" 13, '"+lcIsikKood+"','"+lcNimetus+"','"+lcAadress +"','800699')"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif

			lcString = "select id from asutus where UPPER(nimetus) = '"+Upper(lcNimetus)+"'"
			lError = sqlexec(gnhandle, lcString,'qryAsutusId')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
		Endif
&& Tooleping
		lcString = " select id from tooleping where parentid = "+Str(qryAsutusId.Id)+;
			" and  osakondid = "+Str(qryOsakondId.Id)+ " and ametid = "+Str(qryAmetId.Id)
		lError = sqlexec(gnhandle, lcString,'qryToolepingId')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If !Empty(kultuur.tegelik_pa)
			lcsumma = Left(Alltrim(kultuur.tegelik_pa),Len(Alltrim(kultuur.tegelik_pa))-3)
			lcKoma = Right(	Alltrim(kultuur.tegelik_pa),2)
			lcpalk = Alltrim(lcsumma)+'.'+lcKoma
		Else
			lcpalk = '0'
		Endif
		If Reccount('qryToolepingId') < 1
			lcString = " INSERT INTO tooleping (parentId, osakondId, ametid, algab, toopaev,palk, pohikoht,  pank, aa) VALUES ("+;
				STR(qryAsutusId.Id)+","+Str(qryOsakondId.Id)+","+Str(qryAmetId.Id)+","+;
				"date (2004,01,01),8,"+lcpalk+","+Str(lnPohikoht)+","+;
				lcPank+",'"+lcAa+"')"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Else
			lcString = " update tooleping set palk = "+lcpalk +" where id = "+Str(qryToolepingId.Id)
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
		If !Empty(lcPank) And !Empty(lcAa)
			lcString = "insert into asutusaa (parentid, pank, aa) values ("+;
				STR(qryAsutusId.Id)+",'"+lcPank+"','"+lcAa+"')"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif

		Use In qryAsutusId
	Endscan
	Return lError
Endfunc



Function kontoplaan_KORREGEIMINE
	lcFile = 'c:\avpsoft\files\buh60\temp\kontoplaan.dbf'
	If !File(lcFile)
		Messagebox('Viga:'+lcFile)
		Return - 1
	Endif
	Use (lcFile) In 0 Alias qryKonto
	Select qryKonto
	Scan For !Empty(n6) And Len(Alltrim(n6)) = 6
		Wait Window qryKonto.n9 Nowait
*!*			Do Case
*!*				Case !Empty(qryKonto.n4)
*!*					lcKood = qryKonto.n4
*!*				Case !Empty(qryKonto.n6)
*!*					lcKood = qryKonto.n6
*!*			Endcase
		lckood = qryKonto.n6
		lcNimetus = Ltrim(Rtrim(qryKonto.n9))
		If !Empty(lckood) And !Empty(lcNimetus)
			lcString = " select id from library where kood = '"+lckood+"' and library = 'KONTOD'"
			lError = sqlexec(gnhandle, lcString,'QRYKONTOKONTROL')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
			If Reccount('QRYKONTOKONTROL')	< 1
				lcTun1 = Iif(!Empty(qryKonto.n10),'1','0')
				lcTun2 = Iif(!Empty(qryKonto.n11),'1','0')
				lcTun3 = Iif(!Empty(qryKonto.n12),'1','0')
				lcTun4 = Iif(!Empty(qryKonto.n13),'1','0')
				lcTun5 = '1'
				Do Case
					Case Left(lckood,1) = "1"
						lcTun5 = '1'
					Case Left(lckood,1) = "2"
						lcTun5 = '2'
					Case Left(lckood,1) = "3"
						lcTun5 = '4'
					Case Left(lckood,1) = "4"
						lcTun5 = '3'
					Case Left(lckood,1) = "5"
						lcTun5 = '3'
					Case Left(lckood,1) = "7"
						lcTun5 = '3'
					Case Left(lckood,1) = "8"
						lcTun5 = '3'
				Endcase
				lcString = " insert into library (rekvId, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5) values ("+;
					"2,'"+lckood+"','"+Ltrim(Rtrim(lcNimetus))+"','KONTOD',"+lcTun1+","+lcTun2+","+lcTun3+","+lcTun4+","+lcTun5+")"
				lError = sqlexec(gnhandle, lcString)
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					Exit
				Endif
				lcString = " select id from library order by id desc limit 1 "
				lError = sqlexec(gnhandle, lcString, 'qryLibId')
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					Exit
				Endif
				Select qryMssqlrekv
				Scan
					Select qryLibId
					lcString = "insert into kontoinf (parentid, aasta, algsaldo,rekvId) values ("+;
						STR(qryLibId.Id)+",2004,0,"+Str(qryMssqlrekv.Id)+")"
					lError = sqlexec(gnhandle, lcString, 'qryLibId')
					If lError < 1
						Messagebox("Viga "+lcString,'Kontrol')
						Set Step On
						Exit
					Endif
				Endscan
				If lError < 0
					Exit
				Endif
			Endif
		Endif
	Endscan
	Return lError
Endfunc

Function palk_asutus_import
	Create Cursor mssqlpalkAsutus(Id Int,rekvId Int,osakondid Int, ametId Int, kogus N(12,2), vaba N(12,2),;
		palgamaar Int, muud m, tunnusid Int)

	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\palk_asutus.dbf'
	Select mssqlpalkAsutus
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dbkl\palk_asutus.dbf'
	Select mssqlpalkAsutus
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\palk_asutus.dbf'
	Select mssqlpalkAsutus
	Append From (Ltrim(Rtrim(lcFile)))

	Select mssqlpalkAsutus
	Scan
&& kontrol
		Wait Window 'palkasutus: '+Str(Recno('mssqlpalkAsutus'))+'/' + Str(Reccount('mssqlpalkAsutus'))  Nowait
		lcString = "select id from palk_asutus where id = "+Str(mssqlpalkAsutus.Id)
		lError = sqlexec(gnhandle, lcString,'qryPa')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryPa') < 1
			lcString = " insert into palk_asutus (Id ,rekvId ,osakondid , ametId , kogus , vaba , palgamaar, tunnusid) values ("+;
				STR(mssqlpalkAsutus.Id)+" ,"+Str(mssqlpalkAsutus.rekvId)+ ","+Str(mssqlpalkAsutus.osakondid)+" , "+;
				STR(mssqlpalkAsutus.ametId)+" ,"+Str(mssqlpalkAsutus.kogus,12,2)+" , "+Str(mssqlpalkAsutus.vaba,12,2)+" ,"+;
				STR(mssqlpalkAsutus.palgamaar)+" ,"+Str(mssqlpalkAsutus.tunnusid)+")"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan
	Return lError
Endfunc


Function set_serials
	Set Step On
	Wait Window 'setting seq. value' Nowait
	lcString = " select * from pg_tables where tableowner = 'vlad' and left (tablename,2) <> 'pg'"
	lError = sqlexec(gnhandle, lcString,'qryTbl')
	If lError < 1
		Messagebox("Viga "+lcString,'Kontrol')
		Set Step On
		Exit
	Endif
	Select qryTbl
	Scan For Upper(qryTbl.tablename) <> Upper('lncount')
		lcString = "select id from "+Ltrim(Rtrim(qryTbl.tablename)) +" order by id desc limit 1"
		lError = sqlexec(gnhandle, lcString,'qryTblId')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryTblId') > 0 And qryTblId.Id > 0
			lcString = " SELECT SETVAL('"+Ltrim(Rtrim(qryTbl.tablename))+"_id_seq',"+Str(qryTblId.Id)+")"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
		Endif

	Endscan
	Return lError
Endfunc


Function pv_import
	Create Cursor mssqllibrary(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)

	Create Cursor mssqlgrupplib(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)


	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\library.dbf'

	Select mssqllibrary
	Append From (Ltrim(Rtrim(lcFile))) For Library = 'POHIVARA'

	Select mssqlgrupplib
	Append From (Ltrim(Rtrim(lcFile))) For Library = 'PVGRUPP'


	lcFile = 'c:\avpsoft\files\buh60\temp\dbkl\library.dbf'
	Select mssqllibrary
	Append From (Ltrim(Rtrim(lcFile))) For Library = 'POHIVARA'
	Select mssqlgrupplib
	Append From (Ltrim(Rtrim(lcFile))) For Library = 'PVGRUPP'


	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\library.dbf'
	Select mssqllibrary
	Append From (Ltrim(Rtrim(lcFile))) For Library = 'POHIVARA'
	Select mssqlgrupplib
	Append From (Ltrim(Rtrim(lcFile))) For Library = 'PVGRUPP'



	Create Cursor mssqlpvkaart(Id Int,  parentid Int,  vastisikid Int,  soetmaks N(12,4),  ;
		soetkpv d,  kulum N(12,4),  algkulum N(12,4),  gruppid Int,  konto c(20),  tunnus Int, ;
		mahakantud d,  otsus m,  muud m)

	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\pv_kaart.dbf'

	Select mssqlpvkaart
	Append From (Ltrim(Rtrim(lcFile)))
	lcFile = 'c:\avpsoft\files\buh60\temp\dbkl\pv_kaart.dbf'
	Select mssqlpvkaart
	Append From (Ltrim(Rtrim(lcFile)))
	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\pv_kaart.dbf'
	Select mssqlpvkaart
	Append From (Ltrim(Rtrim(lcFile)))

	Create Cursor mssqlpvoper(Id Int,  parentid Int,  nomid Int,  doklausid Int,  lausendid Int ,;
		journalid Int,  journal1id Int,  liik Int,  kpv d,  Summa N(12,4))

	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\pv_oper.dbf'
	Select mssqlpvoper
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dbkl\pv_oper.dbf'
	Select mssqlpvoper
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\pv_oper.dbf'
	Select mssqlpvoper
	Append From (Ltrim(Rtrim(lcFile)))

	Select mssqllibrary
	Scan
&& kontrol
		Wait Window mssqllibrary.nimetus Nowait
		lcString = "select id from library where id = "+Str(mssqllibrary.Id)
		lError = sqlexec(gnhandle, lcString,'qryPv')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryPv') < 1
			lcString = " insert into library (id,rekvid,kood,nimetus,library,muud) values ("+;
				STR(mssqllibrary.Id)+","+Str(mssqllibrary.rekvId)+",'"+Ltrim(Rtrim(mssqllibrary.kood))+"','"+;
				LTRIM(Rtrim(mssqllibrary.nimetus))+"','"+Ltrim(Rtrim(mssqllibrary.Library))+"','"+mssqllibrary.muud+"')"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan
	If lError > 0
		Select mssqlgrupplib
		Scan
&& kontrol
			Wait Window mssqlgrupplib.nimetus Nowait
			lcString = "select id from library where id = "+Str(mssqlgrupplib.Id)
			lError = sqlexec(gnhandle, lcString,'qryPvG')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
			If Reccount('qryPvG') < 1
				lcString = " insert into library (id,rekvid,kood,nimetus,library,muud) values ("+;
					STR(mssqlgrupplib.Id)+","+Str(mssqlgrupplib.rekvId)+",'"+Ltrim(Rtrim(mssqlgrupplib.kood))+"','"+;
					LTRIM(Rtrim(mssqlgrupplib.nimetus))+"','"+Ltrim(Rtrim(mssqlgrupplib.Library))+"','"+mssqlgrupplib.muud+"')"

				lError = sqlexec(gnhandle, lcString)
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					_Cliptext = lcString
					Exit
				Endif
			Endif
		Endscan
	Endif

	If lError > 0
		Select mssqlpvkaart
		Scan
&& kontrol
			Wait Window 'mssqlpvkaart:'+Str(Recno('mssqlpvkaart'))+'/'+Str(Reccount('mssqlpvkaart')) Nowait
			lcString = "select id from pv_kaart where id = "+Str(mssqlpvkaart.Id)
			lError = sqlexec(gnhandle, lcString,'qryPvK')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
			If Reccount('qryPvK') < 1
				lcString = " insert into pv_kaart (Id,  parentid,  vastisikid,  soetmaks,soetkpv,  kulum ,  algkulum ,"+;
					" gruppid,  konto,  tunnus, mahakantud,  otsus ,  muud ) values ("+;
					STR(mssqlpvkaart.Id)+","+  Str(mssqlpvkaart.parentid)+","+  Str(mssqlpvkaart.vastisikid)+","+;
					STR(mssqlpvkaart.soetmaks,14,2)+",DATE("+;
					STR(Year(mssqlpvkaart.soetkpv),4)+","+Str(Month(mssqlpvkaart.soetkpv),2)+","+;
					STR(Day(mssqlpvkaart.soetkpv),2)+"),"+;
					STR(mssqlpvkaart.kulum,14,2)+" ,"+  Str(mssqlpvkaart.algkulum,14,2)+" ,"+;
					STR(mssqlpvkaart.gruppid)+",'"+  mssqlpvkaart.konto+"',"+ Str(mssqlpvkaart.tunnus)+","+;
					IIF(Empty(mssqlpvkaart.mahakantud) ,"NULL","date("+Str(Year(mssqlpvkaart.mahakantud),4)+","+;
					STR(Month(mssqlpvkaart.mahakantud),2)+","+;
					STR(Day(mssqlpvkaart.mahakantud),2)+")")+",'"+mssqlpvkaart.otsus +"','"+  mssqlpvkaart.muud+"')"

				lError = sqlexec(gnhandle, lcString)
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					_Cliptext = lcString
					Exit
				Endif
			Endif
		Endscan

	Endif

	If lError > 0

		Select mssqlpvoper
		Scan
&& kontrol
			Wait Window 'mssqlpvoper:'+Str(Recno('mssqlpvoper'))+'/'+Str(Reccount('mssqlpvoper')) Nowait
			lcString = "select id from pv_oper where id = "+Str(mssqlpvoper.Id)
			lError = sqlexec(gnhandle, lcString,'qryPvO')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
			If Reccount('qryPvO') < 1
				lcString = " insert into pv_oper (id,  parentid,  nomid,  doklausid, liik,  kpv,  summa) values ("+;
					STR(mssqlpvoper.Id)+","+  Str(mssqlpvoper.parentid)+","+  Str(mssqlpvoper.nomid)+","+;
					STR(mssqlpvoper.doklausid)+","+ Str(mssqlpvoper.liik)+",DATE("+;
					STR(Year(mssqlpvoper.kpv),4)+","+Str(Month(mssqlpvoper.kpv),2)+","+Str(Day(mssqlpvoper.kpv),2)+"),"+;
					STR( mssqlpvoper.Summa,14,2)+")"
				lError = sqlexec(gnhandle, lcString)
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					_Cliptext = lcString
					Exit
				Endif
			Endif
		Endscan

	Endif


	Return lError
Endfunc

Function palkamet_import
	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\library.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor mssqllibrary(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)

	Append From (Ltrim(Rtrim(lcFile))) For Library = 'AMET'

	lcFile = 'c:\avpsoft\files\buh60\temp\dbKL\library.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif

	Select mssqllibrary
	Append From (Ltrim(Rtrim(lcFile))) For Library = 'AMET'

	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\library.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Select mssqllibrary
	Append From (Ltrim(Rtrim(lcFile))) For Library = 'AMET'


	Select mssqllibrary
	Scan
&& kontrol
		Wait Window 'library: '+Ltrim(Rtrim(mssqllibrary.nimetus)) Nowait
		lcString = "select id from library where id = "+Str(mssqllibrary.Id)
		lError = sqlexec(gnhandle, lcString,'qryLib')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryLib') < 1
			lcString = " insert into library (id,rekvid,kood,nimetus,library,muud) values ("+;
				STR(mssqllibrary.Id)+","+Str(mssqllibrary.rekvId)+",'"+Ltrim(Rtrim(mssqllibrary.kood))+"','"+;
				LTRIM(Rtrim(mssqllibrary.nimetus))+"','"+Ltrim(Rtrim(mssqllibrary.Library))+"','"+mssqllibrary.muud+"')"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan
	Return lError
Endfunc

Function palkosakond_import
	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\library.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor mssqllibrary(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)
	Append From (Ltrim(Rtrim(lcFile))) For Library = 'OSAKOND'

	lcFile = 'c:\avpsoft\files\buh60\temp\dbkl\library.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Select mssqllibrary
	Append From (Ltrim(Rtrim(lcFile))) For Library = 'OSAKOND'

	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\library.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Select mssqllibrary
	Append From (Ltrim(Rtrim(lcFile))) For Library = 'OSAKOND'

	Select mssqllibrary
	Scan
&& kontrol
		Wait Window 'library: '+Ltrim(Rtrim(mssqllibrary.nimetus)) Nowait
		lcString = "select id from library where id = "+Str(mssqllibrary.Id)
		lError = sqlexec(gnhandle, lcString,'qryLib')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryLib') < 1
			lcString = " insert into library (id,rekvid,kood,nimetus,library,muud) values ("+;
				STR(mssqllibrary.Id)+","+Str(mssqllibrary.rekvId)+",'"+Ltrim(Rtrim(mssqllibrary.kood))+"','"+;
				LTRIM(Rtrim(mssqllibrary.nimetus))+"','"+Ltrim(Rtrim(mssqllibrary.Library))+"','"+mssqllibrary.muud+"')"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan
	Return lError
Endfunc


Function palklib_import
	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\library.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor mssqllibrary(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)
	Append From (Ltrim(Rtrim(lcFile))) For Library = 'PALK'

	lcFile = 'c:\avpsoft\files\buh60\temp\dbkl\library.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif

	Append From (Ltrim(Rtrim(lcFile))) For Library = 'PALK'

	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\library.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif

	Append From (Ltrim(Rtrim(lcFile))) For Library = 'PALK'


	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\palk_lib.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor mssqlpalk_lib(Id Int,  parentid Int,  liik Int,  tund Int,  maks Int,  palgafond Int,;
		asutusest Int,  lausendid Int,  algoritm c(10),  muud m,  Round N(12,4),  sots Int, konto c(20))

	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dbkl\palk_lib.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif

	Select mssqlpalk_lib
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\palk_lib.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif

	Select mssqlpalk_lib

	Append From (Ltrim(Rtrim(lcFile)))

	lError = 1

	Select mssqllibrary
	Scan
&& kontrol
		Wait Window 'library: '+Ltrim(Rtrim(mssqllibrary.nimetus)) Nowait
		lcString = "select id from library where id = "+Str(mssqllibrary.Id)
		lError = sqlexec(gnhandle, lcString,'qryLib')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryLib') < 1
			lcString = " insert into library (id,rekvid,kood,nimetus,library,muud) values ("+;
				STR(mssqllibrary.Id)+","+Str(mssqllibrary.rekvId)+",'"+Ltrim(Rtrim(mssqllibrary.kood))+"','"+;
				LTRIM(Rtrim(mssqllibrary.nimetus))+"','"+Ltrim(Rtrim(mssqllibrary.Library))+"','"+mssqllibrary.muud+"')"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan
	If Empty(lError) Or lError < 1
		Return -1
	Endif

	Select mssqlpalk_lib
	Scan
&& kontrol
		Wait Window 'palk_lib: '+Str(Recno('mssqlpalk_lib'))+'/'+Str(Reccount('mssqlpalk_lib')) Nowait
		lcString = "select id from palk_lib where id = "+Str(mssqlpalk_lib.Id)
		lError = sqlexec(gnhandle, lcString,'qryPLib')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryPLib') < 1
			lcString = " insert into palk_lib (id,  parentid ,  liik ,  tund ,  maks,   palgafond,"+;
				" asutusest, algoritm ,  round ,  sots , konto ) values ("+;
				STR(mssqlpalk_lib.Id)+","+  Str(mssqlpalk_lib.parentid)+","+Str(mssqlpalk_lib.liik)+","+;
				STR(mssqlpalk_lib.tund)+","+  Str(mssqlpalk_lib.maks)+","+  Str(mssqlpalk_lib.palgafond)+","+;
				STR(mssqlpalk_lib.asutusest)+",'"+mssqlpalk_lib.algoritm +"',"+Str(mssqlpalk_lib.Round,12,4)+","+;
				STR(mssqlpalk_lib.sots)+" ,'"+mssqlpalk_lib.konto+"')"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan

	Return lError
Endfunc


Function palk_import

	Create Cursor mssqltooleping(Id Int, parentid Int, osakondid Int,ametId Int, algab d, lopp d,;
		toopaev Int,palk N(12,4) ,  palgamaar Int, pohikoht Int,  koormus Int,ametnik Int,tasuliik Int,;
		pank Int,  aa c(16),  muud m, rekvId Int)

	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\tooleping.dbf'
	Select mssqltooleping
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dbkl\tooleping.dbf'
	Select mssqltooleping
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\tooleping.dbf'
	Select mssqltooleping
	Append From (Ltrim(Rtrim(lcFile)))

	Create Cursor mssqlpalkkaart(  Id Int,  parentid Int ,  lepingid Int ,  libid Int,  Summa N(12,4),;
		percent_ Int,  tulumaks Int,  tulumaar Int,  Status Int, muud m, alimentid Int,  tunnusid Int)

	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\palk_kaart.dbf'
	Select mssqlpalkkaart
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dbkl\palk_kaart.dbf'
	Select mssqlpalkkaart
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\palk_kaart.dbf'
	Select mssqlpalkkaart
	Append From (Ltrim(Rtrim(lcFile)))


	Create Cursor mssqlpalktaabel(Id Int,  toolepingid Int,  kokku Int,  too Int,  paev Int,;
		ohtu Int,  oo Int,  tahtpaev Int,  puhapaev Int,  kuu Int,  aasta Int,  muud m)

	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\palk_taabel1.dbf'
	Select mssqlpalktaabel
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dbkl\palk_taabel1.dbf'
	Select mssqlpalktaabel
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\palk_taabel1.dbf'
	Select mssqlpalktaabel
	Append From (Ltrim(Rtrim(lcFile)))

	Create Cursor mssqlpuudumine(Id Int,  lepingid Int,  kpv1 d,  kpv2 d,  paevad Int,  Summa N(12,4),;
		tunnus Int,  tyyp Int,  muud m,  libid Int)

	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\puudumine.dbf'
	Select mssqlpuudumine
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dbkl\puudumine.dbf'
	Select mssqlpuudumine
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\puudumine.dbf'
	Select mssqlpuudumine
	Append From (Ltrim(Rtrim(lcFile)))


	Create Cursor mssqlpalkoper(Id Int,  rekvId Int,  libid Int,  lepingid Int,  kpv d,  Summa N(12,4),;
		doklausid Int)

	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\palk_oper.dbf'
	Select mssqlpalkoper
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dbkl\palk_oper.dbf'
	Select mssqlpalkoper
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\palk_oper.dbf'
	Select mssqlpalkoper
	Append From (Ltrim(Rtrim(lcFile)))


	lError = 1

	Select mssqltooleping
	Scan
&& kontrol
		Wait Window 'tooleping:'+Str(Recno('mssqltooleping'))+'/'+Str(Reccount('mssqltooleping')) Nowait
		lcString = "select id from tooleping where id = "+Str(mssqltooleping.Id)
		lError = sqlexec(gnhandle, lcString,'qryTooL')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryTooL') < 1
			lcString = " insert into tooleping (id , parentid , osakondid ,ametid,  algab , lopp ,"+;
				" toopaev ,palk ,  palgamaar , pohikoht ,  koormus ,ametnik ,tasuliik ,pank ,  aa ,  muud , rekvid ) values (" +;
				str(mssqltooleping.Id)+","+Str(mssqltooleping.parentid) +","+ Str(mssqltooleping.osakondid)+" ,"+;
				STR(mssqltooleping.ametId)+",DATE("+Str(Year(mssqltooleping.algab),4)+","+Str(Month(mssqltooleping.algab),2)+","+;
				STR(Day(mssqltooleping.algab),2)+"),"+Iif(Empty(mssqltooleping.lopp),"NULL",;
				"DATE("+Str(Year(mssqltooleping.lopp),4)+","+Str(Month(mssqltooleping.lopp),2)+","+;
				STR(Day(mssqltooleping.lopp),2)+")")+","+Str(mssqltooleping.toopaev)+","+Str(mssqltooleping.palk,12,4)+","+;
				STR(mssqltooleping.palgamaar)+","+ Str(mssqltooleping.pohikoht)+","+ Str(mssqltooleping.koormus)+","+;
				STR(mssqltooleping.ametnik)+","+Str(mssqltooleping.tasuliik)+","+Str(mssqltooleping.pank)+",'"+;
				mssqltooleping.aa +"','"+mssqltooleping.muud+"',"+Str(mssqltooleping.rekvId)+")"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
			lcString = " update asutus set tp = '800699' where asutus.id = "+Str(mssqltooleping.Id)
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan

	If lError > 0

		Select mssqlpalkkaart
		Scan
&& kontrol
			Wait Window 'Palkkaart:'+Str(Recno('mssqlpalkkaart'))+'/'+Str(Reccount('mssqlpalkkaart')) Nowait
			lcString = "select id from palk_kaart where id = "+Str(mssqlpalkkaart.Id)
			lError = sqlexec(gnhandle, lcString,'qryPKaart')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
			If Reccount('qryPkaart') < 1
				lcString = " insert into palk_kaart (id,  parentid  ,  lepingid  ,  libid,  summa,"+;
					" percent_ ,  tulumaks ,  tulumaar ,  status , alimentid ,  tunnusid) values ("+;
					STR(mssqlpalkkaart.Id)+","+  Str(mssqlpalkkaart.parentid)+"  ,"+  Str(mssqlpalkkaart.lepingid)+","+;
					STR(mssqlpalkkaart.libid)+","+  Str(mssqlpalkkaart.Summa,12,4)+","+ Str(mssqlpalkkaart.percent_)+" ,"+;
					STR(mssqlpalkkaart.tulumaks)+" ,"+  Str(mssqlpalkkaart.tulumaar)+" ,"+Str(mssqlpalkkaart.Status)+" ,"+;
					STR(mssqlpalkkaart.alimentid)+" ,"+Str(mssqlpalkkaart.tunnusid)+")"

				lError = sqlexec(gnhandle, lcString)
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					_Cliptext = lcString
					Exit
				Endif
			Endif
		Endscan

	Endif

	If lError > 0

		Select mssqlpalktaabel
		Scan
&& kontrol
			Wait Window 'Palktaabel:'+Str(Recno('mssqlpalktaabel'))+'/'+Str(Reccount('mssqlpalktaabel')) Nowait
			lcString = "select id from palk_taabel1 where id = "+Str(mssqlpalktaabel.Id)
			lError = sqlexec(gnhandle, lcString,'qryPTab')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
			If Reccount('qryPtab') < 1
				lcString = " insert into palk_taabel1 (id ,  toolepingid ,  kokku ,  too ,  paev , ohtu ,  oo ,  tahtpaev,  puhapaev,  kuu,  aasta) values ("+;
					STR(mssqlpalktaabel.Id)+" ,"+  Str(mssqlpalktaabel.toolepingid)+" ,"+  Str(mssqlpalktaabel.kokku)+" ,"+;
					STR(mssqlpalktaabel.too)+" ,"+  Str(mssqlpalktaabel.paev)+" ,"+ Str(mssqlpalktaabel.ohtu)+" ,"+;
					STR(mssqlpalktaabel.oo)+" ,"+  Str(mssqlpalktaabel.tahtpaev)+","+  Str(mssqlpalktaabel.puhapaev)+","+;
					STR(mssqlpalktaabel.kuu)+","+  Str(mssqlpalktaabel.aasta)+")"

				lError = sqlexec(gnhandle, lcString)
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					_Cliptext = lcString
					Exit
				Endif
			Endif
		Endscan
	Endif

	If lError > 0

		Select mssqlpuudumine
		Scan
&& kontrol
			Wait Window 'Puudumine:'+Str(Recno('mssqlpuudumine'))+'/'+Str(Reccount('mssqlpuudumine')) Nowait
			lcString = "select id from puudumine where id = "+Str(mssqlpuudumine.Id)
			lError = sqlexec(gnhandle, lcString,'qryPuud')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
			If Reccount('qryPuud') < 1
				lcString = " insert into puudumine (id ,lepingid ,kpv1,kpv2,paevad ,summa ,tunnus ,tyyp,libid) values ("+;
					STR(mssqlpuudumine.Id)+" ,"+Str(mssqlpuudumine.lepingid)+" , DATE("+;
					STR(Year(mssqlpuudumine.kpv1),4)+","+Str(Month(mssqlpuudumine.kpv1),2)+","+Str(Day(mssqlpuudumine.kpv1),2)+"),DATE("+;
					STR(Year(mssqlpuudumine.kpv2),4)+","+Str(Month(mssqlpuudumine.kpv2),2)+","+Str(Day(mssqlpuudumine.kpv2),2)+"),"+;
					STR(mssqlpuudumine.paevad)+" ,"+Str(mssqlpuudumine.Summa,12,4)+" ,"+Str(mssqlpuudumine.tunnus)+" ,"+;
					STR(mssqlpuudumine.tyyp)+","+Str(mssqlpuudumine.libid)+")"
				lError = sqlexec(gnhandle, lcString)
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					_Cliptext = lcString
					Exit
				Endif
			Endif
		Endscan
	Endif



	If lError > 0

		Select mssqlpalkoper
		Scan
&& kontrol
			Wait Window 'Palkoper:'+Str(Recno('mssqlpalkoper'))+'/'+Str(Reccount('mssqlpalkoper')) Nowait
			lcString = "select id from palk_oper where id = "+Str(mssqlpalkoper.Id)
			lError = sqlexec(gnhandle, lcString,'qryPOper')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
			If Reccount('qryPOper') < 1
				lcString = " insert into palk_oper (id,  rekvid ,  libid ,  lepingid ,  kpv,  summa ,doklausid ) values ("+;
					STR(mssqlpalkoper.Id)+","+  Str(mssqlpalkoper.rekvId)+" ,"+  Str(mssqlpalkoper.libid)+" ,"+;
					STR(mssqlpalkoper.lepingid)+" ,DATE("+ Str(Year(mssqlpalkoper.kpv),4)+","+Str(Month(mssqlpalkoper.kpv),2)+","+;
					STR(Day(mssqlpalkoper.kpv),2)+"),"+  Str(mssqlpalkoper.Summa,12,4) +","+Str(mssqlpalkoper.doklausid)+")"

				lError = sqlexec(gnhandle, lcString)
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					_Cliptext = lcString
					Exit
				Endif
			Endif
		Endscan

	Endif


	Return lError
Endfunc


Function nom_import
	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\nomenklatuur.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor mssqlnom (Id Int,  rekvId Int, doklausid Int, dok c(20),kood c(20) , ;
		nimetus c(254),  uhik c(20),  hind N(12,4), muud m,  ulehind N(12,4),kogus N(12,3),  formula m)

	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dbkl\nomenklatuur.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif

	Select mssqlnom
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\nomenklatuur.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Select mssqlnom
	Append From (Ltrim(Rtrim(lcFile)))


	Select mssqlnom
	Scan
&& kontrol
		Wait Window mssqlnom.nimetus Nowait
		lcString = "select id from nomenklatuur where id = "+Str(mssqlnom.Id)
		lError = sqlexec(gnhandle, lcString,'qryNom')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryNom') < 1
			lcString = " insert into nomenklatuur (id,rekvid ,  dok,kood,	nimetus,  uhik,  hind, muud ,  ulehind,kogus,  formula) values ("+;
				STR(mssqlnom.Id)+","+Str(mssqlnom.rekvId)+",'"+Ltrim(Rtrim(mssqlnom.dok))+"','"+Ltrim(Rtrim(mssqlnom.kood))+"','"+;
				LTRIM(Rtrim(mssqlnom.nimetus))+"','"+;
				LTRIM(Rtrim(mssqlnom.uhik))+"',"+Str(mssqlnom.hind,12,2)+",'"+mssqlnom.muud+"',"+Str(mssqlnom.ulehind,12,2)+","+;
				STR(mssqlnom.kogus,12,4)+",'" +mssqlnom.formula+"')"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan
	Return lError
Endfunc


Function kasutajad_import
&& kasutajad
* 1. import
	Create Cursor mssqlUserid (Id Int, rekvId Int, kasutaja c(40), ametnik c(254), ;
		kasutaja_ Int, peakasutaja_ Int, admin_ Int, muud m, Password c(10))
	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\userid.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
&& NJLV
	Select mssqlUserid
	Append From (Ltrim(Rtrim(lcFile)))
&& Kool
	lcFile = 'c:\avpsoft\files\buh60\temp\dbkool\userid.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Use (lcFile) In 0 Alias userkool
*!*		SELECT userkool
*!*		UPDATE userkool SET id = id * 100,;
*!*			rekvid = rekvid * 10
	Select mssqlUserid
	Append From Dbf('userkool')
	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\userid.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif

	Use (lcFile) In 0 Alias userlast
	Select userlast
*!*		UPDATE userlast SET id = id * 50,;
*!*			rekvid = rekvid * 5
	Select mssqlUserid
	Append From Dbf('userkool')

	Brow


	Select Distinct kasutaja From mssqlUserid Into Cursor pgSysUserid
	Select pgSysUserid
	lcString = 'select * from pg_user'
	lError = sqlexec(gnhandle, lcString,'qryPgUserid')
	If lError < 1
		Messagebox("Viga "+lcString,'Kontrol')
		Set Step On
		Return
	Endif

	Select pgSysUserid
	Scan
		Wait Window pgSysUserid.kasutaja Nowait
		Select qryPgUserid
		Locate For Upper(usename) =  Upper(pgSysUserid.kasutaja)
		If !Found()
&& uus user
			lcPassword = Lower(Right(Sys(2015),9))
			Update mssqlUserid Set Password = lcPassword Where kasutaja = pgSysUserid.kasutaja
			lcGrupp = 'KASUTAJA'
			lcString = 'CREATE USER "'+ Ltrim(Rtrim(pgSysUserid.kasutaja))+'"'+;
				" PASSWORD '"+lcPassword +"' NOCREATEDB NOCREATEUSER in group dbkasutaja "

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
			lcString = "CREATE USER "+ Ltrim(Rtrim(pgSysUserid.kasutaja))+;
				" PASSWORD '"+lcPassword +"' NOCREATEDB NOCREATEUSER in group dbkasutaja "

		Endif
	Endscan
	Select * From mssqlUserid Into Table mssqlNjLvUseridtbl
	Return lError

Endfunc

Function rekv_import
&& Rekv

	lcFile = 'c:\avpsoft\files\buh60\temp\dbnjlv\rekv.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor qryMssqlrekv(  Id Int,  parentid Int , regkood c(20),  nimetus c(254),  kbmkood c(20);
		, aadress m,  haldus c(254),  tel c(120),  faks c(120),  email c(120) ,  juht c(120), raama c(120),;
		muud m,  recalc Int )

	Append From (Ltrim(Rtrim(lcFile)))


&& Kool
	lcFile = 'c:\avpsoft\files\buh60\temp\dbkool\rekv.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Use (lcFile) In 0 Alias rekvkool
	Select rekvkool
*	UPDATE rekvkool SET id = id * 10
	Select qryMssqlrekv
	Append From Dbf('rekvkool')
	lcFile = 'c:\avpsoft\files\buh60\temp\dblasteaeg\rekv.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif

	Use (lcFile) In 0 Alias rekvlast
	Select rekvlast
*	UPDATE rekvlast SET id = id * 5
	Select qryMssqlrekv
	Append From Dbf('rekvlast')

	Brow

	Select qryMssqlrekv
	Scan
&& kontrol
		lcString = "select id from rekv where id = "+Str(qryMssqlrekv.Id)
		lError = sqlexec(gnhandle, lcString,'qryrekv')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryRekv') < 1
			lcString = " insert into rekv (id,  parentid,regkood,nimetus,kbmkood,aadress,haldus,tel,faks, email,juht, raama, "+;
				" muud,  recalc ) values ("+;
				STR(qryMssqlrekv.Id)+","+Str(qryMssqlrekv.parentid)+",'"+qryMssqlrekv.regkood+"','"+qryMssqlrekv.nimetus+"','"+;
				qryMssqlrekv.kbmkood+"','"+qryMssqlrekv.aadress+"','"+qryMssqlrekv.haldus+"','"+qryMssqlrekv.tel+"','"+;
				qryMssqlrekv.faks+"','"+qryMssqlrekv.email+"','"+qryMssqlrekv.juht+"','"+;
				qryMssqlrekv.raama+"','"+qryMssqlrekv.muud+"',"+Str(qryMssqlrekv.recalc)+")"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
		Endif

	Endscan
	Return lError
Endfunc

Function userid_import
&& import userid
	Select mssqlUserid
	Scan
*!*		Create Cursor mssqlUserid (lnRowid Int, rekvId Int, kasutaja c(40), ametnik c(254), ;
*!*			kasutaja_ Int, peakasutaja_ Int, admin_ Int, muud m, Password c(10))
		Wait Window mssqlUserid.ametnik Nowait
		lcString = " select id from userid where id = "+Str(mssqlUserid.Id)
		lError = sqlexec(gnhandle, lcString,'qryUserId')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryUserId') < 1
			lcString = " insert into userid (id, rekvid, kasutaja, ametnik, kasutaja_, peakasutaja_,admin) values ("+;
				STR(mssqlUserid.Id)+","+Str(mssqlUserid.rekvId)+",'"+mssqlUserid.kasutaja+"','"+;
				mssqlUserid.ametnik+"',"+Str(mssqlUserid.kasutaja_)+","+Str(mssqlUserid.peakasutaja_)+","+;
				STR(mssqlUserid.admin_)+")"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
		Endif
	Endscan
	Return lError
Endfunc

Function asutus_import
	Create Cursor qryasutus( Id Int,rekvId Int,regkood c(20),nimetus c(254), omvorm c(20),;
		aadress m, kontakt m,  tel c(20),  faks c(60), email c(60),  muud m,  tp c(20))

	lcFile = 'c:\avpsoft\files\buh60\TEMP\DBNJLV\asutus.dbf'
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\TEMP\DBkl\asutus.dbf'
	Append From (Ltrim(Rtrim(lcFile)))

	lcFile = 'c:\avpsoft\files\buh60\TEMP\DBlasteaeg\asutus.dbf'
	Append From (Ltrim(Rtrim(lcFile)))

	Select 	qryasutus
	Scan
		Wait Window qryasutus.nimetus Nowait
		lcString = " select id from asutus where id = "+Str(qryasutus.Id)

		lError = sqlexec(gnhandle, lcString,'qryAsut')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryAsut') < 1
			lcString = " insert into asutus (id,rekvid,regkood,nimetus,omvorm,aadress, kontakt,tel,faks,email,muud, tp) values ("+;
				STR(qryasutus.Id)+","+Str(qryasutus.rekvId)+",'"+Ltrim(Rtrim(qryasutus.regkood))+"','"+Ltrim(Rtrim(qryasutus.nimetus))+"','"+;
				LTRIM(Rtrim(qryasutus.omvorm))+"','"+Ltrim(Rtrim(qryasutus.aadress))+"','"+Ltrim(Rtrim(qryasutus.kontakt))+"','"+;
				LTRIM(Rtrim(qryasutus.tel))+"','"+Ltrim(Rtrim(qryasutus.faks))+"','"+Ltrim(Rtrim(qryasutus.email))+"','"+;
				qryasutus.muud+"','800599')"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
		Endif
	Endscan
	Return lError
Endfunc

Function tp_import
	lcFile = 'c:\avpsoft\files\buh60\temp\tp.dbf'
	If !File(lcFile)
		Messagebox('Viga:'+lcFile)
		Exit
	Endif
	Use (lcFile) In 0 Alias qrytp
	Select qrytp
	Scan For Not Empty(n4)
		Wait Window qrytp.n7 Nowait
		lcString = " select id from library where kood = '"+Alltrim(qrytp.n4)+"' and library = 'TP'"
		lError = sqlexec(gnhandle, lcString,'QRYTPKONTROL')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('QRYTPKONTROL')	< 1
			lcString = " insert into library (rekvId, kood, nimetus, library) values ("+;
				"2,'"+qrytp.n4+"','"+Ltrim(Rtrim(qrytp.n7))+"','TP')"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
			If !Empty(qrytp.n6)
				lcString = " select id from asutus where regkood = '"+qrytp.n6+"'"
				lError = sqlexec(gnhandle, lcString,'QRYasutusKONTROL')
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					Exit
				Endif
				If Reccount('QRYasutusKONTROL') > 0
					lcString = " update asutus set tp = '"+qrytp.n4+"' where regkood = '"+qrytp.n6+"'"
					lError = sqlexec(gnhandle, lcString)
					If lError < 1
						Messagebox("Viga "+lcString,'Kontrol')
						Set Step On
						Exit
					Endif
				Endif
			Endif
		Endif
	Endscan
	Return lError
Endfunc

Function kontoplaan_import
	lcFile = 'c:\avpsoft\files\buh60\temp\kontoplaan.dbf'
	If !File(lcFile)
		Messagebox('Viga:'+lcFile)
		Return - 1
	Endif
	Use (lcFile) In 0 Alias qryKonto
	Select qryKonto
	Scan For !Empty(n9)
		Wait Window qryKonto.n9 Nowait
		Do Case
			Case !Empty(qryKonto.n4)
				lckood = qryKonto.n4
			Case !Empty(qryKonto.n6)
				lckood = qryKonto.n6
		Endcase
		lcNimetus = Ltrim(Rtrim(qryKonto.n9))
		If !Empty(lckood) And !Empty(lcNimetus)
			lcString = " select id from library where kood = '"+lckood+"' and library = 'KONTOD'"
			lError = sqlexec(gnhandle, lcString,'QRYKONTOKONTROL')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
			If Reccount('QRYKONTOKONTROL')	< 1
				lcTun1 = Iif(!Empty(qryKonto.n10),'1','0')
				lcTun2 = Iif(!Empty(qryKonto.n11),'1','0')
				lcTun3 = Iif(!Empty(qryKonto.n12),'1','0')
				lcTun4 = Iif(!Empty(qryKonto.n13),'1','0')
				lcTun5 = '1'
				Do Case
					Case Left(lckood,1) = "1"
						lcTun5 = '1'
					Case Left(lckood,1) = "2"
						lcTun5 = '2'
					Case Left(lckood,1) = "3"
						lcTun5 = '4'
					Case Left(lckood,1) = "4"
						lcTun5 = '3'
					Case Left(lckood,1) = "5"
						lcTun5 = '3'
					Case Left(lckood,1) = "7"
						lcTun5 = '3'
					Case Left(lckood,1) = "8"
						lcTun5 = '3'
				Endcase
				lcString = " insert into library (rekvId, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5) values ("+;
					"2,'"+lckood+"','"+Ltrim(Rtrim(lcNimetus))+"','KONTOD',"+lcTun1+","+lcTun2+","+lcTun3+","+lcTun4+","+lcTun5+")"
				lError = sqlexec(gnhandle, lcString)
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					Exit
				Endif
				lcString = " select id from library order by id desc limit 1 "
				lError = sqlexec(gnhandle, lcString, 'qryLibId')
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					Exit
				Endif
				If !Used('qryMssqlrekv')
					lcString = 'select * from rekv'
					lError = sqlexec(gnhandle, lcString, 'qryMssqlrekv')
					If lError < 1
						Messagebox("Viga "+lcString,'Kontrol')
						Set Step On
						Exit
					Endif
				Endif
				Select qryMssqlrekv
				Scan
					Select qryLibId
					lcString = "insert into kontoinf (parentid, aasta, algsaldo,rekvId) values ("+;
						STR(qryLibId.Id)+",2004,0,"+Str(qryMssqlrekv.Id)+")"
					lError = sqlexec(gnhandle, lcString, 'qryLibId')
					If lError < 1
						Messagebox("Viga "+lcString,'Kontrol')
						Set Step On
						Exit
					Endif
				Endscan
				If lError < 0
					Exit
				Endif
			Endif
		Endif
	Endscan
	Return lError
Endfunc


Function tt_import
	lcFile = 'c:\avpsoft\files\buh60\temp\tt.dbf'
	If !File(lcFile)
		Messagebox('Viga:'+lcFile)
		Exit
	Endif
	Use (lcFile) In 0 Alias qrytt
	Select qrytt
	Scan For Not Empty(n5)
		Wait Window qrytt.n8 Nowait
		lcString = " select id from library where kood = '"+Alltrim(qrytt.n5)+"' and library = 'TEGEV'"
		lError = sqlexec(gnhandle, lcString,'QRYTTKONTROL')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('QRYTTKONTROL')	< 1
			lcString = " insert into library (rekvId, kood, nimetus, library) values ("+;
				"2,'"+qrytt.n5+"','"+Ltrim(Rtrim(qrytt.n8))+"','TEGEV')"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
		Endif
	Endscan
	Return lError
Endfunc

Function allikad_import
	lcFile = 'c:\avpsoft\files\buh60\temp\allikad.dbf'
	If !File(lcFile)
		Messagebox('Viga:'+lcFile)
		Exit
	Endif
	Use (lcFile) In 0 Alias qryAllikad
	Select qryAllikad
	Scan For Not Empty(n3)
		Wait Window qryAllikad.n4 Nowait
		lcString = " select id from library where kood = '"+Alltrim(qryAllikad.n3)+"' and library = 'ALLIKAD'"
		lError = sqlexec(gnhandle, lcString,'QRYTTKONTROL')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('QRYTTKONTROL')	< 1
			lcString = " insert into library (rekvId, kood, nimetus, library) values ("+;
				"2,'"+qryAllikad.n3+"','"+Ltrim(Rtrim(qryAllikad.n4))+"','ALLIKAD')"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
		Endif
	Endscan
	Return lError
Endfunc

Function rv_import
	lcFile = 'c:\avpsoft\files\buh60\temp\rv.dbf'
	If !File(lcFile)
		Messagebox('Viga:'+lcFile)
		Exit
	Endif
	Use (lcFile) In 0 Alias qryRv
	Select qryRv
	Scan For Not Empty(n2)
		Wait Window qryRv.n2 Nowait
		lcString = " select id from library where kood = '"+Alltrim(qryRv.n1)+"' and library = 'RAHA'"
		lError = sqlexec(gnhandle, lcString,'QRYRVKONTROL')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('QRYrvKONTROL')	< 1
			lcString = " insert into library (rekvId, kood, nimetus, library) values ("+;
				"2,'"+qryRv.n1+"','"+Ltrim(Rtrim(qryRv.n2))+"','RAHA')"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
		Endif
	Endscan
	Return lError
Endfunc
