Local lError
Clear All

*lcFile1 = 'c:\avpsoft\haridus\palk2.dbf'
lcFile1 = 'c:\avpsoft\haridus\palk1.dbf'
*lcFile1 = 'c:\avpsoft\haridus\pank01.dbf'
*lcFile3 = 'c:\avpsoft\haridus\pank03.dbf'
*lcFile2 = 'c:\avpsoft\files\buh60\temp\haridus\tp2004.dbf'
If !File(lcFile1)
	Messagebox('Viga, failid ei leidnud')
	lError = .T.
Endif
Use (lcFile1) In 0 Alias qryHO
*!*	Use ('c:\avpsoft\haridus\pank02asutus.dbf') In 0 Alias qryAsu

*!*	Select Val(Alltrim(lausend.n11)) As asutusId, Val(Alltrim(asutused.n1)) As Id, asutused.n5 As nimetus, asutused.n6 As regkood, ;
*!*		lausend.* From lausend Left Outer Join asutused On Val(Alltrim(asutused.n1)) = lausend.asutusId;
*!*		INTO Cursor qryHO
*!*	SET STEP ON
*!*	scan
*!*		lcSumma = transdigit(ltrim(RTRIM(qryHo.n9)))
*!*	ENDSCAN
*!*	return

gnHandle = SQLConnect('narvalvpg','vlad','490710')
If gnHandle < 1
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif

lnSumma = 0
lnrec = 0

*!*	Select qryHO
*!*	Scan
*!*		Wait Window Str(Recno('qryHo'))+'-'+Str(Reccount('qryHo')) Nowait
*!*		lcErr = ''

*!*	* otsime asutusId
*!*		lcregkood = Ltrim(Rtrim(Str(qryHO.reg_kood,11)))
*!*		If lcregkood = '100004252'
*!*			lcregkood = '10004252'
*!*		Endif

*!*		lcString = "select id from asutus where regkood = '"+lcregkood+"'"
*!*		lnresult = SQLEXEC(gnHandle,lcString, 'qryId')
*!*		If Reccount('qryid') <  1
*!*	*!*			lcString = " insert into asutus (regkood, nimetus, rekvId, tp) values ( "+;
*!*	*!*				"'"+LTRIM(RTRIM(STR(qryHo.reg_kood))) +"','"+LTRIM(RTRIM(qryHo.nimi_tp))+"',11,'"+;
*!*	*!*				LEFT(LTRIM(RTRIM(STR(qryHo.tp))),6)+"')"

*!*	*!*			lnresult = SQLEXEC(gnHandle,lcString)
*!*	*!*			If lnresult < 1
*!*	*!*				exit
*!*	*!*			ENDIF
*!*			lnResult = -1
*!*			Set Step On
*!*			exit
*!*		Endif

*!*	Endscan
*!*	=SQLDISCONNECT(gnHandle)

*!*	Return


=SQLEXEC(gnHandle,'begin work')

* select ametikohad

Create Cursor v_ametid (OsakondId Int, Osakond c(20), AmetId Int, kood c(20), nimetus c(254))
Insert Into v_ametid (Osakond, kood, nimetus);
	SELECT Distinct Left(n1,7) As Osakond, Iif(Empty(n69),'MUUD',Left(n69,20)) As kood, ;
	Iif(Empty(n69),'muud',n69) As nimetus From qryHO




Select v_ametid
Scan
	Wait Window v_ametid.Osakond Nowait
* lisame ametid asutuste struktuurisse
	lcString = " SELECT * FROM LIBRARY WHERE REKVID = 31 AND LIBRARY = 'OSAKOND' and kood = '"+v_ametid.Osakond+"'"
	lnresult = SQLEXEC(gnHandle,lcString, 'qryId')
	If lnresult < 1 Or Reccount('qryid') < 1
		Set Step On
		Exit
	Endif
	Replace v_ametid.OsakondId With qryid.Id In v_ametid
	Use In qryid

* otsime amet, ja kui puudub insert

	Wait Window v_ametid.Osakond + v_ametid.kood Nowait

	lcString = "SELECT id from library where library = 'AMET' and rekvid = 31 and kood = '"+Alltrim(v_ametid.kood)+"'"
	lnresult = SQLEXEC(gnHandle,lcString, 'qryId')
	If lnresult < 1
		Set Step On
		Exit
	Endif


	If  Reccount('qryid') < 1
		lcString = " INSERT INTO LIBRARY (REKVID, KOOD, NIMETUS, LIBRARY) VALUES (31,'"+;
			LTRIM(Rtrim(v_ametid.kood))+"','"+Ltrim(Rtrim(v_ametid.nimetus))+"','AMET')"
		lnresult = SQLEXEC(gnHandle,lcString)
		If lnresult < 1
			Set Step On
			Exit
		Else
			lcString = "SELECT id from library where library = 'AMET' and rekvid = 31 and kood = '"+Alltrim(v_ametid.kood)+"'"
			lnresult = SQLEXEC(gnHandle,lcString, 'qryId')
			If lnresult < 1 Or Reccount('qryId') < 1
				Set Step On
				Exit
			Endif

			lcString = " insert into palk_asutus (rekvid, osakondId, ametid, kogus) values (31,"+;
				STR(v_ametid.OsakondId)+","+Str(qryid.Id)+",1)"
			lnresult = SQLEXEC(gnHandle,lcString)
			If lnresult < 1
				Set Step On
				Exit
			Endif

		Endif
		Replace v_ametid.AmetId With qryid.Id In v_ametid
	Else
		Replace v_ametid.AmetId With qryid.Id In v_ametid
		lcString = "select id from palk_asutus where rekvId = 31 and osakondid = " + Str(v_ametid.OsakondId) +;
			" and ametid = "+Str(v_ametid.AmetId)

		lnresult = SQLEXEC(gnHandle,lcString, 'qryid')
		If lnresult < 1
			Set Step On
			Exit
		Endif
		If Reccount('qryid') < 1
			lcString = " insert into palk_asutus (rekvid, osakondId, ametid, kogus) values (31,"+;
				STR(v_ametid.OsakondId)+","+Str(qryid.Id)+",1)"
			lnresult = SQLEXEC(gnHandle,lcString)
			If lnresult < 1
				Set Step On
				Exit
			Endif


		Endif

	Endif



	Select n3 As nimetus, n73 As pank, n74 As aa, n72 As isikukood, n75 As algkpv, n71 As aadress, n5 As palk From qryHO ;
		WHERE Alltrim(Left(n1,7)) = Alltrim(v_ametid.Osakond) ;
		AND Alltrim(Iif(Empty(n69),'MUUD',Left(n69,20))) = Alltrim(v_ametid.kood);
		INTO Cursor qryIsikud
	Select qryIsikud
	If Reccount('qryisikud') < 1
		Set Step On
		lnresult = -1
		Exit
	Endif
	Scan
		Wait Window v_ametid.Osakond + v_ametid.kood + qryIsikud.nimetus Nowait

		lcString = " select id from asutus where regkood = '"+qryIsikud.isikukood+"'"
		lnresult = SQLEXEC(gnHandle,lcString, 'qryId')
		If lnresult < 1
			Set Step On
			Exit
		Endif
		If Reccount('qryId') < 1
			Wait Window 'Insert '+qryIsikud.nimetus Nowait
			lcString = " INSERT INTO asutus (rekvid, regkood, nimetus, omvorm, aadress, tp) values (31,'"+;
				qryIsikud.isikukood+"','"+qryIsikud.nimetus+"','ISIK','"+qryIsikud.aadress+"','800699')"

			lnresult = SQLEXEC(gnHandle,lcString)
			If lnresult < 1
				Set Step On
				Exit
			Endif

			lcString = " select id from asutus where regkood = '"+qryIsikud.isikukood+"'"
			lnresult = SQLEXEC(gnHandle,lcString, 'qryId')
			If lnresult < 1 Or Reccount('qryId') < 1
				lnresult = -1
				Set Step On
				Exit
			Endif
		Endif
		lnAsutusid = qryid.Id


		If lnresult > 0

			lcString = " select id from tooleping where rekvid = 31 and parentId = "+Str(lnAsutusid)+;
				" and osakondId = "+Str(v_ametid.OsakondId)+" and ametId = " + Str(v_ametid.AmetId)

			lnresult = SQLEXEC(gnHandle,lcString, 'qryId')
			If lnresult < 1
				Set Step On
				Exit
			Endif
			If Reccount('qryId') < 1 And lnresult > 0

				lcDate = " DATE("+Str(Year(qryIsikud.algkpv),4)+","+Str(Month(qryIsikud.algkpv),2)+","+Str(Day(qryIsikud.algkpv),2)+")"

				lcString = " INSERT INTO TOOLEPING (rekvid, resident, tasuliik, toopaev, pohikoht, koormus, ametnik, "+;
					" parentid, OsakondId, AmetId, algab, pank, aa ) Values (31, 1, 1, 8, 1, 100, 0, "+;
					STR(qryid.Id)+","+Str(v_ametid.OsakondId)+","+Str(v_ametid.AmetId)+", "+lcDate+","+qryIsikud.pank+","+qryIsikud.aa+")"

				lnresult = SQLEXEC(gnHandle,lcString)
				If lnresult < 1
					Set Step On
					Exit
				Else
					Wait Window 'Insert '+qryIsikud.nimetus +' done ' Nowait
				Endif
			Else
				If lnresult > 0
					lcString = "Update tooleping set palk = "+Str(qryIsikud.palk,14,2) + " where id = "+Str(qryid.Id)
					lnresult = SQLEXEC(gnHandle,lcString)
					If lnresult < 1
						Set Step On
						Exit
					Endif
				Endif
			Endif
		Endif

		If lnresult > 0 And !Empty(qryIsikud.aa)
			lcString = " select id from asutusaa where parentid = "+Str(lnAsutusid)
			lnresult = SQLEXEC(gnHandle,lcString, 'qryId')
			If lnresult < 1
				Set Step On
				Exit
			Endif
			If Reccount('qryid') < 1
				lcString = " insert into asutusaa (parentid, aa, pank) values ("+;
					STR(lnAsutusid)+",'"+qryIsikud.aa+"','"+qryIsikud.pank+"')"

				lnresult = SQLEXEC(gnHandle,lcString)
				If lnresult < 1
					Set Step On
					Exit
				Endif
			Endif

		Endif


		If Used('qryId')
			Use In qryid
		Endif
	Endscan

Endscan



*!*	SCAN FOR YEAR(qryHO.data_toend) = 2004
*!*		Wait Window Str(Recno('qryHo'))+'-'+Str(Reccount('qryHo')) Nowait
*!*		lcErr = ''

*!*	* otsime asutusId

*!*		lcAsutusId = ''
*!*		IF USED('qryId')
*!*			USE IN qryId
*!*		ENDIF
*!*		IF !EMPTY(qryHO.reg_kood)
*!*			lcregkood = Ltrim(Rtrim(Str(qryHO.reg_kood,11)))
*!*		ELSE
*!*			SELECT qryAsu
*!*			LOCATE FOR n1 = qryHo.tarnija_ko
*!*			lcregkood = ALLTRIM(qryAsu.n6)
*!*		ENDIF
*!*
*!*
*!*		If lcregkood = '100004252'
*!*			lcregkood = '10004252'
*!*		Endif

*!*		lcString = "select id from asutus where regkood = '"+lcregkood+"'"
*!*		lnresult = SQLEXEC(gnHandle,lcString, 'qryId')

*!*		If lnresult > 0
*!*			If Reccount('qryid') <  1
*!*				lnresult = -1
*!*			ENDIF
*!*
*!*	* Ei leidnud, insertime

*!*	*!*			lcString = " insert into asutus (regkood, nimetus, rekvId, tp) values ( "+;
*!*	*!*				"'"+LTRIM(RTRIM(STR(qryHo.reg_kood))) +"','"+LTRIM(RTRIM(qryHo.nimi_tp))+"',11,'"+;
*!*	*!*				LEFT(LTRIM(RTRIM(STR(qryHo.tp))),6)+"')"

*!*	*!*			lnresult = SQLEXEC(gnHandle,lcString)
*!*	*!*			If lnresult < 1
*!*	*!*				SET STEP on
*!*	*!*
*!*	*!*				exit
*!*	*!*			Endif
*!*	*!*			lcString = "select id from asutus order by id desc limit 1"
*!*	*!*			lnresult = SQLEXEC(gnHandle,lcString, 'qryId')
*!*	*!*			If lnresult < 1
*!*	*!*				SET STEP ON
*!*	*!*				exit
*!*	*!*			Endif

*!*		Endif
*!*		If !Used('qryId') OR lnResult < 1 OR RECCOUNT('qryId') < 1
*!*	*!*			SET STEP ON
*!*	*!*			Exit
*!*			lcAsutusid = "4576"
*!*		else
*!*			lcAsutusId = Str(qryId.Id)
*!*		Endif

*!*
*!*		lcdate = 'date('+Str(Year(qryHO.data_toend),4)+','+Str(Month(qryHO.data_toend),2)+','+Str(Day(qryHO.data_toend),2)+')'

*!*		lcuserId = '199'

*!*		lcSelg = Ltrim(Rtrim(qryHO.Text))+Space(1)+Ltrim(Rtrim(qryHO.eelarve_va))+'Pank '
*!*		lcDok = Ltrim(Rtrim(qryHO.n________2))
*!*		lcMuud = ''
*!*		lcUksus = ''

*!*		lcDeebet = Left(Ltrim(Rtrim(Str(qryHO.d_t))),6)
*!*		lcKreedit = Left(Ltrim(Rtrim(Str(qryHO.k_t))),6)

*!*		lcDeebet = Iif(lcDeebet = '2020001','202000',lcDeebet)
*!*		lcDeebet = Iif(lcDeebet = '202091','202090',lcDeebet)
*!*		lcDeebet = Iif(lcDeebet = '202092','202090',lcDeebet)
*!*		lcDeebet = Iif(lcDeebet = '382080','382090',lcDeebet)
*!*		lcDeebet = Iif(lcDeebet = '70010','700010',lcDeebet)

*!*		lcKreedit = Iif(lcKreedit = '2020001','202000',lcKreedit)
*!*		lcKreedit = Iif(lcKreedit = '202091','202090',lcKreedit)
*!*		lcKreedit = Iif(lcKreedit = '202092','202090',lcKreedit)
*!*	*	lcKreedit = Iif(lcKreedit = '382080','382090',lcKreedit)
*!*		lcKreedit = Iif(lcKreedit = '70010','700010',lcKreedit)


*!*		lcTpd = Ltrim(Rtrim(Str(qryHO.tp_d_t)))
*!*		lcTpk = Ltrim(Rtrim(Str(qryHO.tp_k_t)))
*!*		lcSumma = Alltrim(Str(qryHO.Summa,14,2))
*!*	*	transdigit(Ltrim(Rtrim(qryHO.n9)))
*!*		lcKood1 = Ltrim(Rtrim(qryHO.tegevussal))
*!*		lcKood2 = ''
*!*		lcKood3 = ''
*!*		lcKood4 = ''
*!*		lcKood5 = Ltrim(Rtrim(qryHO.allikas))
*!*		lcKood1 = Iif('vv' $ lcKood1,'',lcKood1)
*!*		lcKood5 = Iif('vv' $ lcKood5,'',lcKood5)

*!*		lcKood5 = Iif('3500.00.17' $ lcKood5,'3500.00',lcKood5)
*!*		lcKood5 = Iif('352.00.17' $ lcKood5,'352.00',lcKood5)
*!*		lcTunnus = Alltrim(Str(qryHO.n_________))
*!*		lcUksus = Iif(Len(lcTunnus) < 3,'0'+lcTunnus,lcTunnus)

*!*	* kontrol

*!*		lcString = " SELECT id from library where library = 'KONTOD' AND kood = '"+lcDeebet+"'"
*!*		lnresult = SQLEXEC(gnHandle,lcString, 'qryKontoId')
*!*		If lnresult > 0
*!*			If Reccount('qryKontoid') <  1
*!*				Set Step On
*!*				lnresult = -1
*!*				lcErr = lcDeebet
*!*				exit
*!*			ENDIF
*!*		Endif

*!*		lcString = " SELECT id from library where library = 'KONTOD' AND kood = '"+lcKreedit+"'"
*!*		lnresult = SQLEXEC(gnHandle,lcString, 'qryKontoId')
*!*		If lnresult > 0
*!*			If Reccount('qryKontoid') <  1
*!*				Set Step On
*!*				lnresult = -1
*!*				lcErr = lcKreedit
*!*				exit
*!*			Endif
*!*		Endif
*!*		If !Empty(lcKood1)
*!*			lcString = " SELECT id from library where library = 'TEGEV' AND kood = '"+lcKood1+"'"
*!*			lnresult = SQLEXEC(gnHandle,lcString, 'qryKood')
*!*			If lnresult > 0
*!*				If Reccount('qryKood') <  1
*!*					lnresult = 1
*!*					lcErr = lcKood1
*!*					lcKood1 = ''
*!*				Endif
*!*			Endif
*!*		Endif
*!*		If !Empty(lcKood2)
*!*			lcString = " SELECT id from library where library = 'ALLIKAD' AND kood = '"+lcKood2+"'"
*!*			lnresult = SQLEXEC(gnHandle,lcString, 'qryKood')
*!*			If lnresult > 0
*!*				If Reccount('qryKood') <  1
*!*					lnresult = 1
*!*					lcErr = lcKood2
*!*					lcKood2 = ''
*!*				Endif
*!*			Endif
*!*		Endif
*!*		If !Empty(lcKood3)
*!*			lcString = " SELECT id from library where library = 'RAHA' AND kood = '"+lcKood3+"'"
*!*			lnresult = SQLEXEC(gnHandle,lcString, 'qryKood')
*!*			If lnresult > 0
*!*				If Reccount('qryKood') <  1
*!*					lnresult = 1
*!*					lcErr = lcKood3
*!*					lcKood3 = ''
*!*				Endif
*!*			Endif
*!*		Endif
*!*		If !Empty(lcKood5)
*!*			lcString = " SELECT id from library where library = 'TULUDEALLIKAD' AND kood = '"+lcKood5+"'"
*!*			lnresult = SQLEXEC(gnHandle,lcString, 'qryKood')
*!*			If lnresult > 0
*!*				If Reccount('qryKood') <  1
*!*					lnresult = 1
*!*					lcErr = lcKood5
*!*					lcKood5 = ''
*!*				Endif
*!*			Endif
*!*		Endif


*!*	* �������� �� ������� tunnus
*!*		If lnresult > 0 And !Empty(lcUksus)
*!*			lcString = " SELECT id from library where library = 'TUNNUS' and rekvid = 11 AND kood = '"+lcUksus+"'"
*!*			lnresult = SQLEXEC(gnHandle,lcString, 'qryTun')
*!*			If lnresult > 0
*!*				If Reccount('qryTun') <  1
*!*	* insert new value
*!*					lcInsert = "insert into library (rekvid, kood, nimetus,library) values ("+;
*!*						"11,'"+lcUksus+"','"+lcUksus+"','TUNNUS')"
*!*					lnresult = SQLEXEC(gnHandle,lcString)
*!*				Endif
*!*			Endif
*!*		Endif

*!*	*	If lcDeebet <> lcKreedit
*!*			If lnresult > 0
*!*				lcString = "insert into journal (kpv, asutusId, rekvId, userId, selg, dok, muud) values ("+;
*!*					lcdate+","+lcAsutusId+",11,"+lcuserId+",'"+lcSelg+"','"+lcDok+"','"+lcMuud+"')"

*!*				lnresult = SQLEXEC(gnHandle,lcString)

*!*			Endif

*!*			If lnresult > 0

*!*				lcString = 'select id from journal where rekvid = 11 order by id desc limit 1'
*!*				lnresult = SQLEXEC(gnHandle,lcString,'qrylastId')
*!*			Endif

*!*			If lnresult > 0

*!*				lcString = "insert into journal1 (parentId, deebet, lisa_d, kreedit, lisa_k, summa, tunnus, kood1, kood2, kood3, kood4, kood5) values ("+;
*!*					STR(qryLastid.Id)+",'"+lcDeebet+"','"+lcTpd+"','"+lcKreedit+"','"+lcTpk+"',"+lcSumma+",'"+;
*!*					lcUksus+"','"+lcKood1+"','"+lcKood2+"','"+lcKood3+"','"+lcKood4+"','"+lcKood5+"')"

*!*				lnSumma = lnSumma + Val(lcSumma)
*!*				lnrec = lnrec  + 1
*!*				lnresult = SQLEXEC(gnHandle,lcString)

*!*			Endif
*!*	*	Endif
*!*		If lnresult < 0
*!*			Set Step On
*!*			Exit
*!*		Endif
*!*	Endscan
If lnresult > 0
	=SQLEXEC(gnHandle,'commit work')
	Messagebox('Ok, summa:'+Str(lnSumma,12,2)+' kokku read:'+Str(lnrec))
Else
	Set Step On
	=SQLEXEC(gnHandle,'rollback work')
Endif




=SQLDISCONNECT(gnHandle)

Function transdigit
	Lparameters tcString
	lnQuota = At(',',tcString)
	lcKroon = Left(tcString,lnQuota-1)
	lcCent = Right(tcString,2)
	If At(Space(1),lcKroon) > 0
* on probel
		lcKroon = Stuff(lcKroon,At(Space(1),lcKroon),1,'')
	Endif
	Return lcKroon+'.'+lcCent
Endfunc

