Clear All

Set Safety Off

If !Used ('config')
	Use config In 0
Endif

Create Cursor curKey (versia m)
Append Blank
Replace versia With 'EELARVE' In curKey
Create Cursor v_account (admin Int Default 1)
Append Blank
*gnhandle = sqlconnect ('buhdata5zur','zinaida','159')
*gnhandle = SQLConnect ('mssql60')
*,'vladislav','490710')
*!*	*!*	*!*	*!*	*!*	&&,'zinaida','159')
*gversia = 'MSSQL'
*grekv = 2
*!*	grekv = 1
*!*	gnHandle = 1
*!*	gversia = 'VFP'

gnhandle = SQLConnect ('narvalvpg','vlad','490710')
If gnhandle < 0
	Messagebox('Viga connection','Kontrol')
	Set Step On
	Return
Endif
grekv = 6
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

	lError = pv_varaamet_import()
	Return lError
Endfunc

Function pv_varaamet_import
	lnrekvid = 6
*	lnvastIsikId = 45
	lnvastIsikId = 3556


&& kontrol
	Wait Window mssqlgrupplib.nimetus Nowait
	lcString = "select id from library where UPPER(KOOD) = 'TARK156000' and rekvid =6"
	lError = sqlexec(gnhandle, lcString,'qryPvG')
	If lError < 1
		Messagebox("Viga "+lcString,'Kontrol')
		Set Step On
		Exit
	Endif
	If Reccount('qryPvG') < 1
		lcString = " insert into library (rekvid,kood,nimetus,library) values ("+;
			"6,'TARK156000','TARKVARA','PVGRUPP')"

		lError = sqlexec(gnhandle, lcString)
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			_Cliptext = lcString
			Return lError
		Endif
		If lError > 0
			lcString = " select id from library where rekvid = 6 order by id desc limit 1"
			lError = sqlexec(gnhandle, lcString,'qryLastid')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Return lError
			Endif
			lnGruppId = qryLastId.id
		Endif
	Else
		lnGruppId =  qryPvG.Id
	Endif

	If lError < 0
		Return lError
	Endif


*	Use (lcFile) In 0 Alias v_pvvara

	Select qryKaart
	Scan For Val(Alltrim(n1)) > 0
		Wait Window qryKaart.n1 Nowait
		Select mssqlgrupplib
		Locate For Upper(Alltrim(kood)) = Upper(Alltrim(qryKaart.n7))
* kontrolime inv.number
		lcInv = 'TARK-'+Alltrim(qryKaart.n1)
		lcString = "select id from curPohivara where kood = '"+Trim(lcInv)+"' and rekvid = 6"

		lError = sqlexec(gnhandle, lcString,'qryInvKontrol')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			_Cliptext = lcString
			Exit
			Return lError
		Endif

* ���� ���. ����
		lcString = "select id from asutus where UPPER(nimetus) = '"+Upper(Trim(qryKaart.n5))+"'"

		lError = sqlexec(gnhandle, lcString,'qryAsuKontrol')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			_Cliptext = lcString
			Exit
			Return lError
		Endif

		If Reccount('qryAsuKontrol') < 1
* ��� � ����

			lcString = " insert into asutus (rekvid,regkood,nimetus,tp) values ("+;
				Str(6)+",'','"+;
				LTRIM(Rtrim(qryKaart.n5))+"','800699')"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
				Return lError
			Endif

			lcString = " select id from asutus where rekvid = 6 order by id desc limit 1"
			lError = sqlexec(gnhandle, lcString,'qryLastid')
			lnvastIsik = qryLastid.Id
		Else
			lnvastIsik = qryAsuKontrol.Id
		Endif


		If Reccount('qryInvKontrol') < 1
*  uus pv
			lcMark = Iif(!Empty(qryKaart.n8),Ltrim(Rtrim(qryKaart.n8))+Space(1)+;
				LTRIM(Rtrim(qryKaart.n9))+'-'+Ltrim(Rtrim(qryKaart.n10))+Chr(13),'')
			lcMark = lcMark + Iif(!Empty(qryKaart.n12),'Kinnistus registri osa nr.'+ Ltrim(Rtrim(qryKaart.n12))+Chr(13),'')
			lcMark = lcMark + Iif(!Empty(qryKaart.n13),'M�tlemine osa '+ Ltrim(Rtrim(qryKaart.n13))+Chr(13),'')
			lcMark = lcMark + Iif(!Empty(qryKaart.n14),'Katastritunnus '+ Ltrim(Rtrim(qryKaart.n14)),'')

			lcString = " insert into library (rekvid,kood,nimetus,library, muud) values ("+;
				Str(lnrekvid)+",'"+Ltrim(Rtrim(lcInv))+"','"+;
				LTRIM(Rtrim(qryKaart.n3))+"','POHIVARA','"+ lcMark+"')"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
				Return lError
			Endif

			lcString = " select id from library where rekvid = 6 order by id desc limit 1"
			lError = sqlexec(gnhandle, lcString,'qryLastid')

*			lcSoet = Str(Val(Alltrim(qryKaart.n17)),14,2)
			lcSoet = transdigit(qryKaart.n17)
			DO case
				case LEN(ALLTRIM(qryKaart.n11)) = 8
					IF '.' $ right(ALLTRIM(qryKaart.n11),3)
						lcSoetKpv = 'date('+Iif(Val(Right(Alltrim(qryKaart.n11),2)) > 10,'19','20')+ Right(Alltrim(qryKaart.n11),2)+','+Substr(Alltrim(qryKaart.n11),4,2)+','+Left(qryKaart.n11,2)+')'
					ELSE
						* 4 digit year
						lcSoetKpv = 'date('+Right(Alltrim(qryKaart.n11),4)+','+'0'+Substr(Alltrim(qryKaart.n11),3,1)+','+'0'+Left(qryKaart.n11,1)+')'
					ENDIF
					
				CASE LEN(ALLTRIM(qryKaart.n11)) = 10
					lcSoetKpv = 'date('+Right(Alltrim(qryKaart.n11),4)+','+Substr(Alltrim(qryKaart.n11),4,2)+','+Left(qryKaart.n11,2)+')'
				CASE LEN(ALLTRIM(qryKaart.n11)) = 9
					lcSoetKpv = 'date('+Right(Alltrim(qryKaart.n11),4)+','+Substr(Alltrim(qryKaart.n11),4,2)+','+Left(qryKaart.n11,1)+')'
			ENDCASE
			lcSoetKpv = 'date(2003,07,01)'
			IF EMPTY(qryKaart.n11)
				lcSoetKpv = 'date(2004,01,01)'
			ENDIF
			
*!*				lcAlgKulum = Str(Val(Alltrim(qryKaart.n18)+'.'+Iif(Len(Alltrim(qryKaart.n18)) > 3,Right(Alltrim(qryKaart.n18),2),'0')),14,2)
*!*				lcKulumQ = Str(Val(Alltrim(qryKaart.n19)+'.'+Iif(Len(Alltrim(qryKaart.n19)) > 3,Right(Alltrim(qryKaart.n19),2),'0')),14,2)
*!*				lcKulumP = Str(Val(Alltrim(qryKaart.n20)+'.'+Iif(Len(Alltrim(qryKaart.n20)) > 3,Right(Alltrim(qryKaart.n20),2),'0')),14,2)
			
			lcAlgkulum = transdigit(ALLTRIM(qryKaart.n18))	
			lcKulumQ = transdigit(ALLTRIM(qryKaart.n19))
			lcKulumP = transdigit(ALLTRIM(qryKaart.n20))
			
			lcNomId = '476'


			lcString = " insert into pv_kaart (parentid,  vastisikid,  soetmaks,soetkpv,  kulum ,  algkulum ,"+;
				" gruppid,  tunnus, MUUD, konto) values ("+;
				Str( qryLastid.Id)+","+Str(lnvastIsik)+","+;
				lcSoet+","+lcSoetKpv+","+lcKulumP+","+lcAlgKulum+","+;
				STR(lnGruppId)+",1,'"+Ltrim(Rtrim(qryKaart.N4))+"','"+Ltrim(Rtrim(qryKaart.N6))+"')"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
				Return lError
			ENDIF
			
			lcString = " insert into pv_oper (parentid,  nomid, liik, kpv, summa, muud ) values ("+;
					Str( qryLastid.Id)+",452,1,DATE(2004,01,01),"+;
					lcSoet+",SPACE(1))"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
				Return lError
			ENDIF

			
			

			If Val(lcKulumQ) > 0
				lcString = " insert into pv_oper (parentid,  nomid, liik, kpv, summa, muud ) values ("+;
					Str( qryLastid.Id)+","+lcNomId+",2,DATE(2004,03,31),"+;
					lcKulumQ+", SPACE(1))"

				lError = sqlexec(gnhandle, lcString)
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					_Cliptext = lcString
					Exit
					Return lError
				Endif
			Endif
		Endif
	Endscan

	Return lError
Endfunc



Function pv_varaamet_import_1111
	lcFile = 'c:\temp\vara\PVVara1111.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	lnrekvid = 6
	lnvastIsikId = 12

	Create Cursor mssqlgrupplib(Id Int,rekvId Int ,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)

	Append Blank
	Replace rekvId With lnrekvid,;
		kood With '1101',;
		nimetus With 'Maa  ',;
		library With 'PVGRUPP' In mssqlgrupplib


	Select mssqlgrupplib
&& kontrol
	Wait Window mssqlgrupplib.nimetus Nowait
	lcString = "select id from library where KOOD = '"+Trim(mssqlgrupplib.kood)+;
		"' and rekvid = "+Str(lnrekvid)
	lError = sqlexec(gnhandle, lcString,'qryPvG')
	If lError < 1
		Messagebox("Viga "+lcString,'Kontrol')
		Set Step On
		Exit
	Endif
	If Reccount('qryPvG') < 1
		lcString = " insert into library (rekvid,kood,nimetus,library,muud) values ("+;
			Str(mssqlgrupplib.rekvId)+",'"+Ltrim(Rtrim(mssqlgrupplib.kood))+"','"+;
			LTRIM(Rtrim(mssqlgrupplib.nimetus))+"','"+Ltrim(Rtrim(mssqlgrupplib.Library))+"','"+mssqlgrupplib.muud+"')"

		lError = sqlexec(gnhandle, lcString)
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			_Cliptext = lcString
			Exit
		Endif
		If lError > 0
			lcString = " select id from library order by id desc limit 1"
			lError = sqlexec(gnhandle, lcString,'qryLastid')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
			Replace mssqlgrupplib.Id With qryLastid.Id In mssqlgrupplib
		Endif
	Else
		Replace mssqlgrupplib.Id With qryPvG.Id In mssqlgrupplib
	Endif

	If lError < 0
		Return lError
	Endif


	Use (lcFile) In 0 Alias v_pvvara


	Create Cursor mssqllibrary(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)

	Select lnrekvid As rekvId, '1111/'+Alltrim(v_pvvara.n1)+'-'+Alltrim(v_pvvara.n2) As kood,;
		TRIM(v_pvvara.n3)+Space(1)+ Trim(v_pvvara.N4) As nimetus, ;
		'POHIVARA' As Library,;
		'bilansi votmise kpv:'+v_pvvara.n5;
		From v_pvvara Into Cursor qryLib

	Select mssqllibrary
	Append From Dbf('qryLib')

	Select n17 As soetmaks, Date(2004,01,01) As soetkpv, n6 As kulum,'1111/'+Alltrim(v_pvvara.n1)+'-'+Alltrim(v_pvvara.n2) As invnum,;
		n18 As algkulum, mssqlgrupplib.Id As gruppid, 1 As tunnus, lnvastIsikId As vastisikid, n19 As muud;
		FROM v_pvvara Into Cursor qryPvKaart



	Create Cursor mssqlpvkaart(Id Int,  parentid Int,  vastisikid Int,  soetmaks N(12,4),  ;
		soetkpv c(10),  kulum N(12,4),  algkulum N(12,4),  gruppid Int,  konto c(20),  tunnus Int, ;
		mahakantud c(10),  otsus m,  muud m, invnum c(20))


	Select mssqllibrary
	Scan
&& kontrol
		Wait Window mssqllibrary.nimetus Nowait
		lcString = "select id from library where rekvid  = "+Str(lnrekvid) + " and "+;
			" kood = '"+Trim(mssqllibrary.kood)+"'"
		lError = sqlexec(gnhandle, lcString,'qryPv')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryPv') < 1
			lcString = " insert into library (rekvid,kood,nimetus,library,muud) values ("+;
				Str(mssqllibrary.rekvId)+",'"+Ltrim(Rtrim(mssqllibrary.kood))+"','"+;
				LTRIM(Rtrim(mssqllibrary.nimetus))+"','"+Ltrim(Rtrim(mssqllibrary.Library))+"','"+mssqllibrary.muud+"')"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif

			lcString = " select id from library order by id desc limit 1"
			lError = sqlexec(gnhandle, lcString,'qryLastid')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
			Replace mssqllibrary.Id With qryLastid.Id In mssqllibrary

			Select mssqlpvkaart
			Append From Dbf('qryPvKaart') For Alltrim(invnum) = Alltrim(mssqllibrary.kood)


			lcString = " insert into pv_kaart (parentid,  vastisikid,  soetmaks,soetkpv,  kulum ,  algkulum ,"+;
				" gruppid,  tunnus, MUUD ) values ("+;
				Str( mssqllibrary.Id)+",12,"+;
				STR(mssqlpvkaart.soetmaks,14,2)+",DATE(2004,01,01),"+;
				STR(mssqlpvkaart.kulum,14,2)+" ,"+  Str(mssqlpvkaart.algkulum,14,2)+" ,"+;
				STR(mssqlgrupplib.Id)+","+ Str(mssqlpvkaart.tunnus)+",'"+mssqlpvkaart.muud+"')"

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




Function pv_varaamet_import_1101
	lcFile = 'c:\temp\vara\PVVara1101.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	lnrekvid = 6
	lnvastIsikId = 12

	Create Cursor mssqlgrupplib(Id Int,rekvId Int ,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)

	Append Blank
	Replace rekvId With lnrekvid,;
		kood With '1101',;
		nimetus With 'Maa  ',;
		library With 'PVGRUPP' In mssqlgrupplib


	Select mssqlgrupplib
&& kontrol
	Wait Window mssqlgrupplib.nimetus Nowait
	lcString = "select id from library where KOOD = '"+Trim(mssqlgrupplib.kood)+;
		"' and rekvid = "+Str(lnrekvid)
	lError = sqlexec(gnhandle, lcString,'qryPvG')
	If lError < 1
		Messagebox("Viga "+lcString,'Kontrol')
		Set Step On
		Exit
	Endif
	If Reccount('qryPvG') < 1
		lcString = " insert into library (rekvid,kood,nimetus,library,muud) values ("+;
			Str(mssqlgrupplib.rekvId)+",'"+Ltrim(Rtrim(mssqlgrupplib.kood))+"','"+;
			LTRIM(Rtrim(mssqlgrupplib.nimetus))+"','"+Ltrim(Rtrim(mssqlgrupplib.Library))+"','"+mssqlgrupplib.muud+"')"

		lError = sqlexec(gnhandle, lcString)
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			_Cliptext = lcString
			Exit
		Endif
		If lError > 0
			lcString = " select id from library order by id desc limit 1"
			lError = sqlexec(gnhandle, lcString,'qryLastid')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
			Replace mssqlgrupplib.Id With qryLastid.Id In mssqlgrupplib
		Endif
	Else
		Replace mssqlgrupplib.Id With qryPvG.Id In mssqlgrupplib
	Endif

	If lError < 0
		Return lError
	Endif


	Use (lcFile) In 0 Alias v_pvvara


	Create Cursor mssqllibrary(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)

	Select lnrekvid As rekvId, '1101/'+Alltrim(v_pvvara.n1)+'-'+Alltrim(v_pvvara.n2) As kood,;
		TRIM(v_pvvara.n3)+Space(1)+ Trim(v_pvvara.N4)+Space(1)+Trim(Str(v_pvvara.n5))+Space(1)+Trim(v_pvvara.n6) As nimetus, ;
		'POHIVARA' As Library,;
		'bilansi votmise kpv:'+v_pvvara.n7+Chr(13)+;
		'kinnistu registri osa nr.'+v_pvvara.n8+Chr(14);
		From v_pvvara Into Cursor qryLib

	Select mssqllibrary
	Append From Dbf('qryLib')

	Select n17 As soetmaks, Date(2004,01,01) As soetkpv, 20 As kulum,'1101/'+Alltrim(v_pvvara.n1)+'-'+Alltrim(v_pvvara.n2) As invnum,;
		n18 As algkulum, mssqlgrupplib.Id As gruppid, 1 As tunnus, lnvastIsikId As vastisikid, n19 As muud;
		FROM v_pvvara Into Cursor qryPvKaart



	Create Cursor mssqlpvkaart(Id Int,  parentid Int,  vastisikid Int,  soetmaks N(12,4),  ;
		soetkpv c(10),  kulum N(12,4),  algkulum N(12,4),  gruppid Int,  konto c(20),  tunnus Int, ;
		mahakantud c(10),  otsus m,  muud m, invnum c(20))


	Select mssqllibrary
	Scan
&& kontrol
		Wait Window mssqllibrary.nimetus Nowait
		lcString = "select id from library where rekvid  = "+Str(lnrekvid) + " and "+;
			" kood = '"+Trim(mssqllibrary.kood)+"'"
		lError = sqlexec(gnhandle, lcString,'qryPv')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryPv') < 1
			lcString = " insert into library (rekvid,kood,nimetus,library,muud) values ("+;
				Str(mssqllibrary.rekvId)+",'"+Ltrim(Rtrim(mssqllibrary.kood))+"','"+;
				LTRIM(Rtrim(mssqllibrary.nimetus))+"','"+Ltrim(Rtrim(mssqllibrary.Library))+"','"+mssqllibrary.muud+"')"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif

			lcString = " select id from library order by id desc limit 1"
			lError = sqlexec(gnhandle, lcString,'qryLastid')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
			Replace mssqllibrary.Id With qryLastid.Id In mssqllibrary

			Select mssqlpvkaart
			Append From Dbf('qryPvKaart') For Alltrim(invnum) = Alltrim(mssqllibrary.kood)


			lcString = " insert into pv_kaart (parentid,  vastisikid,  soetmaks,soetkpv,  kulum ,  algkulum ,"+;
				" gruppid,  tunnus, MUUD ) values ("+;
				Str( mssqllibrary.Id)+",12,"+;
				STR(mssqlpvkaart.soetmaks,14,2)+",DATE(2004,01,01),"+;
				STR(mssqlpvkaart.kulum,14,2)+" ,"+  Str(mssqlpvkaart.algkulum,14,2)+" ,"+;
				STR(mssqlgrupplib.Id)+","+ Str(mssqlpvkaart.tunnus)+",'"+mssqlpvkaart.muud+"')"

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



Function pv_varaamet_import_1091
	lcFile = 'c:\temp\vara\PVVara1091.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	lnrekvid = 6
	lnvastIsikId = 12

	Create Cursor mssqlgrupplib(Id Int,rekvId Int ,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)

	Append Blank
	Replace rekvId With lnrekvid,;
		kood With '1091',;
		nimetus With 'Muu immateriaalne pohivara  ',;
		library With 'PVGRUPP' In mssqlgrupplib


	Select mssqlgrupplib
&& kontrol
	Wait Window mssqlgrupplib.nimetus Nowait
	lcString = "select id from library where KOOD = '"+Trim(mssqlgrupplib.kood)+;
		"' and rekvid = "+Str(lnrekvid)
	lError = sqlexec(gnhandle, lcString,'qryPvG')
	If lError < 1
		Messagebox("Viga "+lcString,'Kontrol')
		Set Step On
		Exit
	Endif
	If Reccount('qryPvG') < 1
		lcString = " insert into library (rekvid,kood,nimetus,library,muud) values ("+;
			Str(mssqlgrupplib.rekvId)+",'"+Ltrim(Rtrim(mssqlgrupplib.kood))+"','"+;
			LTRIM(Rtrim(mssqlgrupplib.nimetus))+"','"+Ltrim(Rtrim(mssqlgrupplib.Library))+"','"+mssqlgrupplib.muud+"')"

		lError = sqlexec(gnhandle, lcString)
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			_Cliptext = lcString
			Exit
		Endif
		If lError > 0
			lcString = " select id from library order by id desc limit 1"
			lError = sqlexec(gnhandle, lcString,'qryLastid')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
			Replace mssqlgrupplib.Id With qryLastid.Id In mssqlgrupplib
		Endif
	Else
		Replace mssqlgrupplib.Id With qryPvG.Id In mssqlgrupplib
	Endif

	If lError < 0
		Return lError
	Endif


	Use (lcFile) In 0 Alias v_pvvara


	Create Cursor mssqllibrary(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)

	Select lnrekvid As rekvId, '1091/'+Alltrim(v_pvvara.n2) As kood,;
		TRIM(v_pvvara.n3) As nimetus, 'POHIVARA' As Library From v_pvvara Into Cursor qryLib

	Select mssqllibrary
	Append From Dbf('qryLib')

	Select n17 As soetmaks, Date(2004,01,01) As soetkpv, 20 As kulum,'1091/'+Alltrim(v_pvvara.n2) As invnum,;
		n18 As algkulum, mssqlgrupplib.Id As gruppid, 1 As tunnus, lnvastIsikId As vastisikid, n19 As muud;
		FROM v_pvvara Into Cursor qryPvKaart



	Create Cursor mssqlpvkaart(Id Int,  parentid Int,  vastisikid Int,  soetmaks N(12,4),  ;
		soetkpv c(10),  kulum N(12,4),  algkulum N(12,4),  gruppid Int,  konto c(20),  tunnus Int, ;
		mahakantud c(10),  otsus m,  muud m, invnum c(20))


	Select mssqllibrary
	Scan
&& kontrol
		Wait Window mssqllibrary.nimetus Nowait
		lcString = "select id from library where rekvid  = "+Str(lnrekvid) + " and "+;
			" kood = '"+Trim(mssqllibrary.kood)+"'"
		lError = sqlexec(gnhandle, lcString,'qryPv')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryPv') < 1
			lcString = " insert into library (rekvid,kood,nimetus,library,muud) values ("+;
				Str(mssqllibrary.rekvId)+",'"+Ltrim(Rtrim(mssqllibrary.kood))+"','"+;
				LTRIM(Rtrim(mssqllibrary.nimetus))+"','"+Ltrim(Rtrim(mssqllibrary.Library))+"','"+mssqllibrary.muud+"')"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif

			lcString = " select id from library order by id desc limit 1"
			lError = sqlexec(gnhandle, lcString,'qryLastid')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
			Replace mssqllibrary.Id With qryLastid.Id In mssqllibrary

			Select mssqlpvkaart
			Append From Dbf('qryPvKaart') For Alltrim(invnum) = Alltrim(mssqllibrary.kood)


			lcString = " insert into pv_kaart (parentid,  vastisikid,  soetmaks,soetkpv,  kulum ,  algkulum ,"+;
				" gruppid,  tunnus, MUUD ) values ("+;
				Str( mssqllibrary.Id)+",12,"+;
				STR(mssqlpvkaart.soetmaks,14,2)+",DATE(2004,01,01),"+;
				STR(mssqlpvkaart.kulum,14,2)+" ,"+  Str(mssqlpvkaart.algkulum,14,2)+" ,"+;
				STR(mssqlgrupplib.Id)+","+ Str(mssqlpvkaart.tunnus)+",'"+mssqlpvkaart.muud+"')"

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


Function pv_varaamet_import_1141
	lcFile = 'c:\temp\vara\PVVara1141.dbf'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	lnrekvid = 6
	lnvastIsikId = 12

	Create Cursor mssqlgrupplib(Id Int,rekvId Int ,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)

	Append Blank
	Replace rekvId With lnrekvid,;
		kood With '1041',;
		nimetus With 'Ostetud litsentsid ',;
		library With 'PVGRUPP' In mssqlgrupplib


	Select mssqlgrupplib
&& kontrol
	Wait Window mssqlgrupplib.nimetus Nowait
	lcString = "select id from library where KOOD = '"+Trim(mssqlgrupplib.kood)+;
		"' and rekvid = "+Str(lnrekvid)
	lError = sqlexec(gnhandle, lcString,'qryPvG')
	If lError < 1
		Messagebox("Viga "+lcString,'Kontrol')
		Set Step On
		Exit
	Endif
	If Reccount('qryPvG') < 1
		lcString = " insert into library (rekvid,kood,nimetus,library,muud) values ("+;
			Str(mssqlgrupplib.rekvId)+",'"+Ltrim(Rtrim(mssqlgrupplib.kood))+"','"+;
			LTRIM(Rtrim(mssqlgrupplib.nimetus))+"','"+Ltrim(Rtrim(mssqlgrupplib.Library))+"','"+mssqlgrupplib.muud+"')"

		lError = sqlexec(gnhandle, lcString)
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			_Cliptext = lcString
			Exit
		Endif
		If lError > 0
			lcString = " select id from library order by id desc limit 1"
			lError = sqlexec(gnhandle, lcString,'qryLastid')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
			Replace mssqlgrupplib.Id With qryLastid.Id In mssqlgrupplib
		Endif
	Else
		Replace mssqlgrupplib.Id With qryPvG.Id In mssqlgrupplib
	Endif

	If lError < 0
		Return lError
	Endif


	Use (lcFile) In 0 Alias v_pvvara


	Create Cursor mssqllibrary(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)

	Select lnrekvid As rekvId, '1041/'+Alltrim(Str(v_pvvara.n1)) As kood,;
		TRIM(v_pvvara.n3) As nimetus, 'POHIVARA' As Library From v_pvvara Into Cursor qryLib

	Select mssqllibrary
	Append From Dbf('qryLib')

	Select n17 As soetmaks, Date(2004,01,01) As soetkpv, 20 As kulum,'1041/'+Alltrim(Str(v_pvvara.n1)) As invnum,;
		n18 As algkulum, mssqlgrupplib.Id As gruppid, 1 As tunnus, lnvastIsikId As vastisikid, n19 As muud;
		FROM v_pvvara Into Cursor qryPvKaart



	Create Cursor mssqlpvkaart(Id Int,  parentid Int,  vastisikid Int,  soetmaks N(12,4),  ;
		soetkpv c(10),  kulum N(12,4),  algkulum N(12,4),  gruppid Int,  konto c(20),  tunnus Int, ;
		mahakantud c(10),  otsus m,  muud m, invnum c(20))


	Select mssqllibrary
	Scan
&& kontrol
		Wait Window mssqllibrary.nimetus Nowait
		lcString = "select id from library where rekvid  = "+Str(lnrekvid) + " and "+;
			" kood = '"+Trim(mssqllibrary.kood)+"'"
		lError = sqlexec(gnhandle, lcString,'qryPv')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryPv') < 1
			lcString = " insert into library (rekvid,kood,nimetus,library,muud) values ("+;
				Str(mssqllibrary.rekvId)+",'"+Ltrim(Rtrim(mssqllibrary.kood))+"','"+;
				LTRIM(Rtrim(mssqllibrary.nimetus))+"','"+Ltrim(Rtrim(mssqllibrary.Library))+"','"+mssqllibrary.muud+"')"

			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif

			lcString = " select id from library order by id desc limit 1"
			lError = sqlexec(gnhandle, lcString,'qryLastid')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
			Replace mssqllibrary.Id With qryLastid.Id In mssqllibrary

			Select mssqlpvkaart
			Append From Dbf('qryPvKaart') For invnum = mssqllibrary.kood


			lcString = " insert into pv_kaart (parentid,  vastisikid,  soetmaks,soetkpv,  kulum ,  algkulum ,"+;
				" gruppid,  tunnus, MUUD ) values ("+;
				Str( mssqllibrary.Id)+","+  Str(mssqlpvkaart.vastisikid)+","+;
				STR(mssqlpvkaart.soetmaks,14,2)+",DATE(2004,01,01),"+;
				STR(mssqlpvkaart.kulum,14,2)+" ,"+  Str(mssqlpvkaart.algkulum,14,2)+" ,"+;
				STR(mssqlgrupplib.Id)+","+ Str(mssqlpvkaart.tunnus)+",'"+mssqlpvkaart.muud+"')"

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

Function kassalib_import
	lcFile = 'c:\avpsoft\files\buh60\temp\eelarve.dbf'
	If File(lcFile)
		Use (lcFile) Alias qryLib In 0
	Else
		Messagebox('Viga, fail'+lcFile+' ei elidnud')
		Return .F.
	Endif
*	lcstring = "SELECT kood, id, nimetus from library WHERE LEN(LTRIM(RTRIM(kood))) = 4 and library = 'KONTOD'"
	Select qryLib
	Scan
		Wait Window qryLib.n2 Nowait
		If Isdigit(Alltrim(qryLib.n2)) And Len(Alltrim(qryLib.n2))>2
			lcString = "select id from library where kood = '"+Ltrim(Rtrim(qryLib.n2))+"' and library = 'TULUDEALLIKAD'"
			lError = sqlexec(gnhandle, lcString, 'qryLIBid')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
			If Reccount('qryLibId') < 1
				lcString = "insert into library (rekvid, kood, nimetus, library) valueS ("+;
					"2,'"+qryLib.n2+"','"+Ltrim(Rtrim(qryLib.n3))+"','TULUDEALLIKAD')"
				lError = sqlexec(gnhandle, lcString)
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					_Cliptext = lcString
					Exit
				Endif
			Endif
		Endif

	Endscan
	Return lError
Endfunc


Function rugodiv_import
	lcFile = 'c:\avpsoft\files\buh60\temp\rugodiv.dbf'
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
	Set Step On
	Select kultuur
	Scan
&& kontrol
		Wait Window Str(Recno())+'-'+Str(Reccount()) Nowait
&& Osakond
		lcNimetus  = kultuur.n6
		lckood = kultuur.n7
&& check for kood
		lcString = "select id from library where kood = '"+lckood+ "' and library = 'OSAKOND' and rekvid = 27"
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
				Str(27)+",'"+Ltrim(Rtrim(lckood))+"','"+;
				lcNimetus+"','OSAKOND')"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
&& check for kood
			lcString = "select id from library where kood = '"+lckood+"' and library = 'OSAKOND' and rekvid = 27"
			lError = sqlexec(gnhandle, lcString, 'qryOsakondId')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
&& Amet
		lcAmet = Ltrim(Rtrim(kultuur.n3))
		lcAkood = Left(lcAmet,20)
		lcString = "select id from library where nimetus = '"+lcAmet+"' and library = 'AMET' and rekvid = 27"
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
				Str(27)+",'"+Ltrim(Rtrim(lcAkood))+"','"+;
				lcAmet+"','AMET')"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
			lcString = "select id from library where nimetus = '"+lcAmet+"' and library = 'AMET' and rekvid = 27"
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
				"27,"+Str(qryOsakondId.Id)+","+Str(qryAmetId.Id)+")"

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
		lcIsikKood = Ltrim(Rtrim(Str(kultuur.n2,14)))
		lcNimetus = Ltrim(Rtrim(kultuur.n1))
		lcAadress = ''
*		lcPank = Iif(Empty(kultuur.pangakood),'0',kultuur.pangakood)
		lcAa = Ltrim(Rtrim(Str(kultuur.n10)))
		lcPank = '0'
		Do Case
			Case !Empty(lcAa) And Left(lcAa,4) = '1056'
				lcPank = '401'
			Case !Empty(lcAa) And Left(lcAa,2) = '33'
				lcPank = '720'
			Otherwise
				If !Empty(lcAa)
					lcPank = '767'
				Endif
		Endcase
		lnPohikoht = 1
		lcresident = '1'
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
				" 27, '"+lcIsikKood+"','"+lcNimetus+"','"+lcAadress +"','800699')"

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
		lcpalk = Str(kultuur.N4,12,2)
		If Reccount('qryToolepingId') < 1
			lcString = " INSERT INTO tooleping (parentId, osakondId, ametid, rekvid, algab, toopaev,palk, pohikoht,  pank, aa) VALUES ("+;
				STR(qryAsutusId.Id)+","+Str(qryOsakondId.Id)+","+Str(qryAmetId.Id)+",27,"+;
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


Function volikogu_import
	lcFile = 'c:\avpsoft\files\buh60\temp\volikogu.dbf'
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
	Set Step On
	Select kultuur
	Scan
&& kontrol
		Wait Window Str(Recno())+'-'+Str(Reccount()) Nowait
&& Osakond
		lcNimetus  = 'Narva Linnavolikogu'
		lckood = 'Volikogu'
&& check for kood
		lcString = "select id from library where kood = '"+lckood+ "' and library = 'OSAKOND' and rekvid = 10"
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
				Str(10)+",'"+Ltrim(Rtrim(lckood))+"','"+;
				lcNimetus+"','OSAKOND')"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
&& check for kood
			lcString = "select id from library where kood = '"+lckood+"' and library = 'OSAKOND' and rekvid = 10"
			lError = sqlexec(gnhandle, lcString, 'qryOsakondId')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
&& Amet
		lcAmet = Ltrim(Rtrim(kultuur.n5))
		lcAkood = Left(lcAmet,20)
		lcString = "select id from library where nimetus = '"+lcAmet+"' and library = 'AMET' and rekvid = 10"
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
				Str(10)+",'"+Ltrim(Rtrim(lcAkood))+"','"+;
				lcAmet+"','AMET')"
			lError = sqlexec(gnhandle, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
			lcString = "select id from library where nimetus = '"+lcAmet+"' and library = 'AMET' and rekvid = 10"
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
				"10,"+Str(qryOsakondId.Id)+","+Str(qryAmetId.Id)+")"

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
		lcIsikKood = Ltrim(Rtrim(Str(kultuur.n3,14)))
		lcNimetus = Ltrim(Rtrim(kultuur.n2))
		lcAadress = Ltrim(Rtrim(kultuur.N4))
*		lcPank = Iif(Empty(kultuur.pangakood),'0',kultuur.pangakood)
		lcAa = Ltrim(Rtrim(kultuur.n6))
		lcPank = '0'
		Do Case
			Case !Empty(lcAa) And Left(lcAa,4) = '1056'
				lcPank = '401'
			Case !Empty(lcAa) And Left(lcAa,2) = '33'
				lcPank = '720'
			Otherwise
				If !Empty(lcAa)
					lcPank = '767'
				Endif
		Endcase
		lnPohikoht = 1
		lcresident = '1'
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
				" 10, '"+lcIsikKood+"','"+lcNimetus+"','"+lcAadress +"','800699')"

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
		lcpalk = '0'
		If Reccount('qryToolepingId') < 1
			lcString = " INSERT INTO tooleping (parentId, osakondId, ametid, rekvid, algab, toopaev,palk, pohikoht,  pank, aa) VALUES ("+;
				STR(qryAsutusId.Id)+","+Str(qryOsakondId.Id)+","+Str(qryAmetId.Id)+",10,"+;
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
			lcSumma = Left(Alltrim(kultuur.tegelik_pa),Len(Alltrim(kultuur.tegelik_pa))-3)
			lcKoma = Right(	Alltrim(kultuur.tegelik_pa),2)
			lcpalk = Alltrim(lcSumma)+'.'+lcKoma
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
	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_palk_asutus.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif

	Create Cursor mssqlpalkAsutus(Id Int,rekvId Int,osakondid Int, ametId Int, kogus N(12,2), vaba N(12,2),;
		palgamaar Int, muud m, tunnusid Int)

	Append From (Ltrim(Rtrim(lcFile))) Type Csv
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
	lcString = " select * from pg_tables where tableowner = 'vlad' and left (tablename,2) <> 'pg' AND SCHEMANAME='public'"
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
	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_pohivara.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor mssqllibrary(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)

	Append From (Ltrim(Rtrim(lcFile))) Type Csv

	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_pvgrupp.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor mssqlgrupplib(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)

	Append From (Ltrim(Rtrim(lcFile))) Type Csv


	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_pvkaart.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor mssqlpvkaart(Id Int,  parentid Int,  vastisikid Int,  soetmaks N(12,4),  ;
		soetkpv c(10),  kulum N(12,4),  algkulum N(12,4),  gruppid Int,  konto c(20),  tunnus Int, ;
		mahakantud c(10),  otsus m,  muud m)

	Append From (Ltrim(Rtrim(lcFile))) Type Csv

	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_pvoper.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor mssqlpvoper(Id Int,  parentid Int,  nomid Int,  doklausid Int,  lausendid Int ,;
		journalid Int,  journal1id Int,  liik Int,  kpv c(10),  Summa N(12,4))

	Append From (Ltrim(Rtrim(lcFile))) Type Csv


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
					LEFT(mssqlpvkaart.soetkpv,4)+","+Substr(mssqlpvkaart.soetkpv,6,2)+","+Right(mssqlpvkaart.soetkpv,2)+"),"+;
					STR(mssqlpvkaart.kulum,14,2)+" ,"+  Str(mssqlpvkaart.algkulum,14,2)+" ,"+;
					STR(mssqlpvkaart.gruppid)+",'"+  mssqlpvkaart.konto+"',"+ Str(mssqlpvkaart.tunnus)+","+;
					IIF(Left(mssqlpvkaart.mahakantud,4) = '1900' Or Left(mssqlpvkaart.mahakantud,4) = 'NULL',;
					"NULL","date("+Left(mssqlpvkaart.mahakantud,4)+","+Substr(mssqlpvkaart.mahakantud,6,2)+","+;
					RIGHT(mssqlpvkaart.mahakantud,2)+")")+",'"+mssqlpvkaart.otsus +"','"+  mssqlpvkaart.muud+"')"

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
					LEFT(mssqlpvoper.kpv,4)+","+Substr(mssqlpvoper.kpv,6,2)+","+Right(mssqlpvoper.kpv,2)+"),"+;
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
	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_amet.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor mssqllibrary(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)
	Append From (Ltrim(Rtrim(lcFile))) Type Csv
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
	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_osakond.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor mssqllibrary(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)
	Append From (Ltrim(Rtrim(lcFile))) Type Csv

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
	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_palk.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor mssqllibrary(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m,tun1 Int,;
		tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)
	Append From (Ltrim(Rtrim(lcFile))) Type Csv

	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_palklib.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor mssqlpalk_lib(Id Int,  parentid Int,  liik Int,  tund Int,  maks Int,  palgafond Int,;
		asutusest Int,  lausendid Int,  algoritm c(10),  muud m,  Round N(12,4),  sots Int, konto c(20))

	Append From (Ltrim(Rtrim(lcFile))) Type Csv
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
	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_tooleping.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif

	Create Cursor mssqltooleping(Id Int, parentid Int, osakondid Int,ametId Int, algab c(10), lopp c(10),;
		toopaev Int,palk N(12,4) ,  palgamaar Int, pohikoht Int,  koormus Int,ametnik Int,tasuliik Int,;
		pank Int,  aa c(16),  muud m, rekvId Int)
	Append From (Ltrim(Rtrim(lcFile))) Type Csv


	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_palkkaart.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif

	Create Cursor mssqlpalkkaart(  Id Int,  parentid Int ,  lepingid Int ,  libid Int,  Summa N(12,4),;
		percent_ Int,  tulumaks Int,  tulumaar Int,  Status Int, muud m, alimentid Int,  tunnusid Int)

	Append From (Ltrim(Rtrim(lcFile))) Type Csv

	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_palktaabel.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif

	Create Cursor mssqlpalktaabel(Id Int,  toolepingid Int,  kokku Int,  too Int,  paev Int,;
		ohtu Int,  oo Int,  tahtpaev Int,  puhapaev Int,  kuu Int,  aasta Int,  muud m)


	Append From (Ltrim(Rtrim(lcFile))) Type Csv

	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_puudumine.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif


	Create Cursor mssqlpuudumine(Id Int,  lepingid Int,  kpv1 c(10),  kpv2 c(10),  paevad Int,  Summa N(12,4),;
		tunnus Int,  tyyp Int,  muud m,  libid Int)

	Append From (Ltrim(Rtrim(lcFile))) Type Csv


	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_palkoper.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif



	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_palkoper.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif



	Create Cursor mssqlpalkoper(Id Int,  rekvId Int,  libid Int,  lepingid Int,  kpv c(10),  Summa N(12,4),;
		doklausid Int)
	Append From (Ltrim(Rtrim(lcFile))) Type Csv


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
				STR(mssqltooleping.ametId)+",DATE("+Left(mssqltooleping.algab,4)+","+Substr(mssqltooleping.algab,6,2)+","+;
				right(mssqltooleping.algab,2)+"),"+Iif(Left(mssqltooleping.lopp,4) ='1900',"NULL",;
				"DATE("+Left(mssqltooleping.lopp,4)+","+Substr(mssqltooleping.lopp,6,2)+","+;
				right(mssqltooleping.lopp,2)+")")+","+Str(mssqltooleping.toopaev)+","+Str(mssqltooleping.palk,12,4)+","+;
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
					LEFT(mssqlpuudumine.kpv1,4)+","+Substr(mssqlpuudumine.kpv1,6,2)+","+Right(mssqlpuudumine.kpv1,2)+"),DATE("+;
					LEFT(mssqlpuudumine.kpv2,4)+","+Substr(mssqlpuudumine.kpv2,6,2)+","+Right(mssqlpuudumine.kpv2,2)+"),"+;
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
					STR(mssqlpalkoper.lepingid)+" ,DATE("+  Left(mssqlpalkoper.kpv,4)+","+Substr(mssqlpalkoper.kpv,6,2)+","+;
					RIGHT(mssqlpalkoper.kpv,2)+"),"+  Str(mssqlpalkoper.Summa,12,4) +","+Str(mssqlpalkoper.doklausid)+")"

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
	lcFile = 'c:\avpsoft\files\buh60\pgsql\userid\buh50_narva_nomenklatuur.CSV'
	If !File(lcFile)
		Messagebox("File not found "+lcFile,'Kontrol')
		Return
	Endif
	Create Cursor mssqlnom (Id Int,  rekvId Int, doklausid Int, dok c(20),kood c(20) , ;
		nimetus c(254),  uhik c(20),  hind N(12,4), muud m,  ulehind N(12,4),kogus N(12,3),  formula m)

	Append From (Ltrim(Rtrim(lcFile))) Type Csv

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
			lcString = " insert into nomenklatuur (id,rekvid , doklausid, dok,kood,	nimetus,  uhik,  hind, muud ,  ulehind,kogus,  formula) values ("+;
				STR(mssqlnom.Id)+","+Str(mssqlnom.rekvId)+","+Str(mssqlnom.doklausid)+",'"+Ltrim(Rtrim(mssqlnom.dok))+"','"+Ltrim(Rtrim(mssqlnom.kood))+"','"+;
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
	Select * From mssqlUserid Into Table mssqlUseridtbl
	Return lError

Endfunc

Function rekv_import
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
				STR(qryasutus.Id)+","+Str(qryasutus.rekvId)+",'"+qryasutus.regkood+"','"+qryasutus.nimetus+"','"+;
				qryasutus.omvorm+"','"+qryasutus.aadress+"','"+qryasutus.kontakt+"','"+;
				qryasutus.tel+"','"+qryasutus.faks+"','"+qryasutus.email+"','"+;
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
	Scan For Not Empty(N4)
		Wait Window qrytp.n7 Nowait
		lcString = " select id from library where kood = '"+Alltrim(qrytp.N4)+"' and library = 'TP'"
		lError = sqlexec(gnhandle, lcString,'QRYTPKONTROL')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('QRYTPKONTROL')	< 1
			lcString = " insert into library (rekvId, kood, nimetus, library) values ("+;
				"2,'"+qrytp.N4+"','"+Ltrim(Rtrim(qrytp.n7))+"','TP')"
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
					lcString = " update asutus set tp = '"+qrytp.N4+"' where regkood = '"+qrytp.n6+"'"
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
			Case !Empty(qryKonto.N4)
				lckood = qryKonto.N4
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
		Wait Window qryAllikad.N4 Nowait
		lcString = " select id from library where kood = '"+Alltrim(qryAllikad.n3)+"' and library = 'ALLIKAD'"
		lError = sqlexec(gnhandle, lcString,'QRYTTKONTROL')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('QRYTTKONTROL')	< 1
			lcString = " insert into library (rekvId, kood, nimetus, library) values ("+;
				"2,'"+qryAllikad.n3+"','"+Ltrim(Rtrim(qryAllikad.N4))+"','ALLIKAD')"
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

Function transdigit
	Lparameters tcString
	tcString = ALLTRIM(tcString)
	lnQuota = At(',',tcString)
	lcKroon = Left(tcString,lnQuota-1)
	lcCent = Right(tcString,2)
	If At(Space(1),lcKroon) > 0
* on probel
		lcKroon = Stuff(lcKroon,At(Space(1),lcKroon),1,'')
	ENDIF
	If At(Space(1),lcKroon) > 0
* on probel
		lcKroon = Stuff(lcKroon,At(Space(1),lcKroon),1,'')
	ENDIF

	IF EMPTY(lcKroon)
		lcKroon = '0'
	endif
	lcreturn = lcKroon+'.'+lcCent
	IF lcReturn = '0.0'
		lcreturn = '0'
	endif
	Return lcreturn
Endfunc
