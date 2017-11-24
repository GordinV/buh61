**
** samm_palktasu.fxp
**
Parameter tnIsikid
Local lnResult, leRror
lnkassaOrder = 0
lnKassaSumma = 0
leRror = .T.
If Empty(tnIsikid)
	tnIsikid = 0
Endif
If  .Not. Used('curSource')
	Create Cursor curSource (Id Int, koOd C (20), niMetus C (120))
Endif
If  .Not. Used('curValitud')
	Create Cursor curValitud (Id Int, koOd C (20), niMetus C (120))
Endif
Create Cursor curResult (Id Int, osAkonnaid Int, paLklibid Int)
lnStep = 1
If Used('v_dokprop')
	Use In v_dokprop
Endif
If Used('v_mk')
	Use In v_mk1
Endif
If Used('v_dokprop')
	Use In v_dokprop
Endif
tnId = geTdokpropid('PALK')
If  .Not. Used('v_dokprop')
	odB.Use('v_dokprop','v_dokprop')
Endif
Do While lnStep>0
	If  .Not. Empty(tnIsikid)
		Insert Into curResult (Id) Values (tnIsikid)
		lnStep = 3
		tnIsikid = 0
	Endif
	Do Case
		Case lnStep=1
			Do geT_osakonna_list
		Case lnStep=2
			Do geT_isiku_list
		Case lnStep=3
			Do geT_kood_list
		Case lnStep>3
*!*				If _vfp.StartMode = 0
*!*					Set Step On
*!*				Endif
			Do arVutus
	Endcase
Enddo
If Used('curSource')
	Use In curSource
Endif
If Used('curvalitud')
	Use In curValitud
Endif
If Used('curResult')
	Use In curResult
Endif
Endproc
*
Procedure arVutus
	Local leRror
	leRror = .T.
	With odB
		Select Distinct paLklibid From curResult Where  Not  ;
			EMPTY(curResult.paLklibid) Into Cursor ValPalkLib
		Select Distinct Id From curResult Where  Not Empty(curResult.Id)  ;
			INTO Cursor recalc1
		Select recalc1
		Scan
			Select coMasutusremote
			Locate For Id=recalc1.Id
			If Found()
				cnImi = Rtrim(coMasutusremote.niMetus)
			Else
				cnImi = ''
			Endif
			tnId = recalc1.Id
			If  .Not. Used('v_palk_kaart')
				.Use('v_palk_kaart')
			Else
				.dbReq('v_palk_kaart',gnHandle,'v_palk_kaart')
			Endif
			Select v_Palk_kaart
			Index On (liIk*Iif(v_Palk_kaart.liIk=2 .And. v_Palk_kaart.maKs=1, 10, 1)) Tag liIk For Status=1 And liIk = 6
			Set Order To liIk
			Select v_Palk_kaart
*			SET STEP ON
			Delete From v_Palk_kaart Where osakondId Not In (Select osAkonnaid As osakondId From curResult Where osAkonnaid > 0)
			Scan For v_Palk_kaart.Status=1 And !Deleted()
				Select ValPalkLib
				Locate For ValPalkLib.paLklibid=v_Palk_kaart.liBid
				If Found()
					leRror = uusmkpalk()
					If leRror=.F.
						Exit
					Endif
				Endif
			Endscan
			If leRror = .F.
				Exit
			Endif
		Endscan
*!*				If _vfp.StartMode = 0
*!*					Set Step On
*!*				Endif
		If leRror=.T. And Used('v_mk1_') And Reccount('v_mk1_') > 0
			lnreturn = 0
			Select v_mk1_
			If Reccount('v_mk') > 0
				.opEntransaction()
				leRror = .cursorupdate ('v_mk')
				If leRror = .T.
					lnreturn = v_mk.Id
					Select v_mk1
					Select asutusId, aa, pank, Sum(Summa) As Summa, nomid, konto, tp, kood1, kood2, kood3, kood4, kood5, valuuta, kuurs From v_mk1_;
						GROUP By asutusId, aa, pank,  nomid, konto, tp, kood1, kood2, kood3, kood4, kood5, valuuta, kuurs;
						INTO Cursor qryMk1
					Select v_mk1
					If Reccount('qryMk1') > 0
						Append From Dbf('qryMk1') For Summa > 0 And !Empty(aa)
						Use In v_mk1_
						Use In qryMk1
						Update v_mk1 Set parentid = v_mk.Id
						leRror = .cursorupdate ('v_mk1')
					Endif

				Endif

				If leRror = .T. And lnreturn > 0
					.coMmit()
					lnreturn = v_mk.Id
					Do Form mk With 'EDIT',lnreturn
				Else
					.Rollback()
					Messagebox('Viga', 'Kontrol')
				Endif
			Endif
		Endif
		lnStep = 0
	Endwith
	If lnkassaOrder > 0 And lnKassaSumma > 0
		Messagebox('Kogu valmistatud '+Alltrim(Str(lnkassaOrder))+' kassaorderid, summa '+Alltrim(Str( lnKassaSumma,12,2)),'Kassa')
	Endif

Endproc

Function is_kassa
* if kassakonto then kassa (.t.) else pank (.f.) default
	If !Used('qryPalktasu') Or Empty(qryPalktasu.konto)
		Return .F.
	Endif

* comparing kassa ja pank kontod with palkoper data

	Select comKassaRemote
	Locate For konto = qryPalktasu.konto
	If Found()
		Return .T.
	Else
		Return .F.
	Endif

Endfunc




*
*!*	Procedure edIt_oper
*!*		Parameter tnId
*!*		tnId = recalc1.Id
*!*		tnId = v_Palk_kaart.liBid
*!*		If Empty(gdKpv) .Or. Empty(gnKuu) .Or. Empty(gnAasta)
*!*			Do Form period
*!*		Endif
*!*		leRror = odB.Exec("gen_palkoper ",Str(v_Palk_kaart.lepingId)+","+Str(v_Palk_kaart.liBid)+;
*!*			","+Str(v_dokprop.Id)+", DATE("+;
*!*			STR(Year(gdKpv),4)+","+Str(Month(gdKpv),2)+","+Str(Day(gdKpv),2)+")",'qryOper')
*!*		Return leRror
*!*	Endproc
*

Function uusmkpalk
	Parameter tlVaataDok
	Local lnSumma, lnreturn, leRror
	lnSumma = 0
	lnreturn = 0
	leRror = .T.
	With  odB
		tdKpv = gdKpv
		
		tnLibId = v_Palk_kaart.liBid
		tnlepingId = v_Palk_kaart.lepingId

		.Use ('curpalkoper4','qryPalktasu')
		SELECT qryPalkTasu
		If is_kassa() Then
			Return uuskassapalk()
		Endif

		If !Used ('v_mk')
			.Use ('v_mk','v_mk',.T.)
		Endif
		If !Used ('v_mk1')
			.Use ('v_mk1','v_mk1',.T.)
			.Use ('v_mk1','v_mk1_',.T.)
		Endif

		Select comNomRemote
		Locate For  Upper(dok) = Upper('mk') And	tyyp = 1
		If !Found ()
			This.ErrorMess = Iif (config.keel = 2,'Viga: Operatsioon ei leidnud','Ошибка:Операция не найдена')
			Messagebox(This.ErrorMess,'Kontrol')
			Return .F.
		Else
			lnNomId = comNomRemote.Id
		Endif

		Select qryPalktasu
		GO top
		lcValuuta = qryPalkTasu.valuuta
		lnKuurs = qryPalkTasu.kuurs
		Sum (qryPalktasu.Summa*kuurs) To lnSumma
		Go Top
		IF fnc_currentValuuta('VAL',gdKpv) <> 'EEK'
			lnSumma = lnSumma / fnc_currentValuuta('KUURS',gdKpv) 
		ENDIF
		
		
		If !Used('v_dokprop')
			tnId = qryPalktasu.doklausId
			odB.Use ('V_DOKPROP')
		Endif
		Set Classlib To getAsutusArve
		oAsutusAa = Createobject ('getAsutusArve',recalc1.Id,'','')
		oAsutusAa.getAa()
*!*			if !empty (oAsutusAa.aa)
*!*				replace v_mk1.aa with oAsutusAa.aa,;
*!*					v_mk1.pank with oAsutusAa.pank in v_mk1
*!*			endif
		If Reccount('v_mk') < 1
			Select v_mk
			Append Blank
			oDoknum = Newobject ('doknum','doknum')
			oDoknum.Alias = 'mk'
			oDoknum.GETLASTDOK()
			lnDok = odoknum.doknum
			If vartype(lnDok) = 'C'
				lnDok = val(alltrim(lnDok))
			Endif
			lnDok = lnDok + 1
			Release oDoknum

			Replace rekvid With gRekv,;
				doktyyp With 8,;
				dokId With 0,;
				aaId With comAaremote.Id,;
				arvid With 0,;
				number With Alltrim(Str(lndok)),;
				kpv With gdKpv,;
				opt With 0,;
				selg With 'Palk',;
				journalid With qryPalktasu.journalid,;
				v_mk.maksepaev With gdKpv In v_mk

		Endif
		Select v_mk1_
		
		lcValuuta = IIF(EMPTY(lcValuuta),fnc_currentvaluuta('VAL',gdKpv),lcValuuta)
		lnKuurs = IIF(EMPTY(lnKuurs),fnc_currentvaluuta('KUURS',gdKpv),lnKuurs)
		
		Insert Into v_mk1_ (asutusId, nomid, Summa,aa, pank,kood1, kood2, kood3, kood4, kood5, konto, tp, valuuta, kuurs, proj) Values ;
			(recalc1.Id, comNomRemote.Id, lnSumma,oAsutusAa.aa, oAsutusAa.pank, comNomRemote.kood1,;
			comNomRemote.kood2, comNomRemote.kood3, comNomRemote.kood4, comNomRemote.kood5, v_dokprop.konto,;
			'800699',lcValuuta,lnKuurs, comNomRemote.proj )

		SELECT v_mk1_
		
	Endwith

	Return leRror

Endfunc


Function  uuskassapalk
	If !Used('qryPalktasu')
		Return .F.
	Endif


	With  odB
		.Use ('v_korder1','v_korder1',.T.)
		.Use ('v_korder2','v_korder2',.T.)

		Select v_korder1
		If Reccount ('v_korder1') < 1
			Append Blank
		Endif


		If !Used('v_dokprop')
			tnId = qryPalktasu.doklausId
			odB.Use ('V_DOKPROP')
		Endif


		Set Classlib To doknum
		oDoknum = Createobject ('doknum')
		oDoknum.Alias = 'vorder1'
		oDoknum.GETLASTDOK()
		lndok = oDoknum.doknum + 1
		Release oDoknum

		Select comKassaRemote
		Locate For !Empty(comKassaRemote.default_)
		If !Found ()
			Go Top
		Endif
		Select coMasutusremote
		Set Order To Id
		Seek recalc1.Id
		If !EMPTY(coMasutusremote.kontakt)
			lcNimi = coMasutusremote.kontakt
		Else
			lcNimi = coMasutusremote.niMetus
		Endif

		Select qryPalktasu
		Sum qryPalktasu.Summa To lnSumma
		Go Top

		Replace rekvid With gRekv,;
			doklausId With qryPalktasu.doklausId,;
			number With Alltrim(config.reserved2)+Alltrim(Str(lndok)),;
			userId With gUserId,;
			KassaId With comKassaRemote.Id	,;
			asutusId With coMasutusremote.Id,;
			nimi With lcNimi,;
			tyyp With 2,;
			summa With lnSumma,;
			alus With 'Palk ',;
			kpv With qryPalktasu.kpv,;
			muud WITH 'PALK' In v_korder1

		Select comNomRemote
		lnNomId = 0
		Scan For  Upper(dok) = 'VORDER' And	tyyp = 1
			lnNomId = Recno('comNomRemote')
			If Empty(v_dokprop.konto)
				Exit
			Endif
			If v_dokprop.konto = comNomRemote.konto
*	palgakonto
				Exit
			Endif
		Endscan
		If Eof('comNomRemote')
			Go lnNomId
		Endif
		If !Empty(comNomRemote.tunnusId)
			Select comTunnusRemote
			Seek comNomRemote.tunnusId
			lcTunnus = comTunnusRemote.koOd
		Else
			lcTunnus = ''
		Endif

		Insert Into v_korder2 (nomid, Summa, tp, konto, kood1, kood2, kood3, kood4, kood5, tunnus);
			values (comNomRemote.Id, lnSumma, Iif(Empty(coMasutusremote.tp),'800699',coMasutusremote.tp), ;
			comNomRemote.konto, comNomRemote.kood1,	comNomRemote.kood2, comNomRemote.kood3, comNomRemote.kood4,;
			comNomRemote.kood5, lcTunnus)

		If lnSumma > 0 And !Empty (comNomRemote.Id)
			.opEntransaction()
			leRror = .cursorupdate ('v_korder1')
			If leRror = .T.
				lnreturn = v_korder1.Id
				Update v_korder2 Set parentid = v_korder1.Id
				leRror = .cursorupdate ('v_korder2')
			Endif

			If leRror = .T.
				.coMmit()
				lnkassaOrder = lnkassaOrder + 1
				lnKassaSumma = lnKassaSumma + lnSumma


			Else
				.Rollback()
			Endif
		Endif
	Endwith

Endfunc




Procedure geT_osakonna_list
	If Used('query1')
		Use In query1
	Endif
	tcKood = '%%'
	tcNimetus = '%%'
	odB.Use('curOsakonnad','qryOsakonnad')
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Append From Dbf('qryOsakonnad')
	Use In qrYosakonnad
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '1', Iif(config.keel=2, 'Osakonnad',  ;
		'Отделы'), Iif(config.keel=2, 'Valitud osakonnad', 'Выбранные отделы')
	If nrEsult=1
		Select Distinct Id From curValitud Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (osAkonnaid) Values (query1.Id)
		Endscan
		Use In query1
		Select curValitud
		Zap
	Endif
	If nrEsult=0
		lnStep = 0
	Else
		lnStep = lnStep+nrEsult
	Endif
Endproc
*
Procedure geT_isiku_list
	If Used('query1')
		Use In query1
	Endif
	If Used('qryTootajad')
		Use In qryTootajad
	Endif
	If Used('tooleping')
		Use In toOleping
	Endif
	If Used('asutus')
		Use In asUtus
	Endif
	tcIsik = '%%'
	odB.Use('comTootajad','qryTootajad')
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Select koOd, niMetus, Id From qryTootajad Where osakondId In(Select  ;
		osAkonnaid From curResult) Into Cursor query1
	Select curSource
	Append From Dbf('query1')
	Use In query1
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '2', Iif(config.keel=2, 'Isikud',  ;
		'Работники'), Iif(config.keel=2, 'Valitud isikud', 'Выбранные работники')
	If nrEsult=1
		Select Distinct Id From curValitud Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (Id) Values (query1.Id)
		Endscan
		Use In query1
	Endif
	If nrEsult=0
		lnStep = 0
	Else
		lnStep = lnStep+nrEsult
	Endif
	Return
Endproc
*
Procedure geT_kood_list
	If Used('query1')
		Use In query1
	Endif
	tcKood = '%%'
	tcNimetus = '%%'
	TCTULULIIK = '%%'
	tnStatus = 0
	odB.Use('curPalkLib','qryPalkLib')
	Delete From qryPalkLib Where liIk<>6
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Append From Dbf('qryPalkLib')
	Use In qryPalkLib
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '3', Iif(config.keel=2,  ;
		'Palgastruktuur', 'Начисления и удержания'), Iif(config.keel=2,  ;
		'Valitud ', 'Выбранно ')
	If nrEsult=1
		Select Distinct Id From curValitud Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (paLklibid) Values (query1.Id)
		Endscan
		Use In query1
		Select curValitud
		Zap
	Endif
	If nrEsult=0
		lnStep = 0
	Else
		lnStep = lnStep+nrEsult
	Endif
Endproc
*
