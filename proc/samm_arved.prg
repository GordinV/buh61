Parameter tnLepingId, tdKpv, tnPreliminary
If !Empty(tdKpv)
	ldArvKpv = tdKpv
Else
*	ldArvKpv = Gomonth(Date(Year(Date()),Month(Date()),1),1)-1
	ldArvKpv = date()
ENDIF
SET STEP ON 
Local lnResult
With odB

	If Empty(tnLepingId)
		tnLepingId = 0
	Endif

	If  .Not. Used('curSource')
		Create Cursor curSource (Id Int, koOd C (20), niMetus C (120))
	Endif
	If  .Not. Used('curValitud')
		Create Cursor curValitud (Id Int, koOd C (20), niMetus C (120))
	Endif
	Create Cursor curResult (Id Int, teEnused N (1), lePingud N (1), objekted N(1))

	Create Cursor curMotteNimekiri (teenus C(20), arverida i, uhis i, objektid i, nomid i, kpv d)

	If Empty(tnPreliminary)
		If Used('v_dokprop')
			Use In v_dokprop
		Endif
		tnId = geTdokpropid('ARV')
		If  .Not. Used('v_dokprop')
			.Use('v_dokprop','v_dokprop')
		Endif
	Endif

	lnStep = 1
	Do While lnStep>0
		If  .Not. Empty(tnLepingId)
			Insert Into curResult (Id, lePingud) Values (tnLepingId, 1)
			tnId = tnLepingId
			.Use('v_leping2','vleping2_')
			Select vleping2_
			Scan
				Insert Into curResult (Id, teEnused) Values (vleping2_.nomid, 1)
			Endscan
			Use In vleping2_
			lnStep = 4
			tnLepingId = 0
		Endif
		Do Case
			Case lnStep=1
				Do geT_nom_list
			Case lnStep=2
				Do geT_objektide_list

			Case lnStep=3
				Do geT_lepingu_list
			Case lnStep>3
				Do arVutus
		Endcase
	Enddo
	If Used('v_arv')
		Use In v_arv
	Endif
	If Used('v_arvread')
		Use In v_arvread
	Endif
	If Used('curSource')
		Use In curSource
	Endif
	If Used('curvalitud')
		Use In curValitud
	Endif
	If Used('curResult')
		Use In curResult
	Endif
Endwith
Endproc
*
Procedure arVutus
	Local leRror
	If !Empty(tnPreliminary)
* koostame pre-arvestus
		Create Cursor prearve_report1 (kpv d, objekt C(20), asutus C(254), koOd C(20), niMetus C(254), hind N(14,2),;
			kogus N(14,4), kbmta N(14,2), kbm N(14,2), Summa N(14,2), muud m, kuurs N(14,4), valuuta C(20))
	Endif



	Select Distinct Id From curResult Where lePingud=1 Into Cursor recalc1
	Select recalc1
	Scan

		leRror = edIt_arve(recalc1.Id)
		If leRror=.T. And v_arv.Summa > 0 And Empty(tnPreliminary)
			Wait Window 'Salvestan arve number:'+v_arv.Number Nowait
			.opEntransaction()
			leRror = saVe_arve()
			If !Empty(leRror)
				.coMmit()
			Else
				.Rollback()
			Endif
			If Empty(leRror)
				Exit
			Endif
		Endif
		If !Empty(tnPreliminary) And v_arv.Summa > 0
			Wait Window 'Salvestan aruanne..' Nowait
			Select comAsutusRemote
			Locate For Id = v_arv.asutusId
			Select v_arvread
			Scan
				Insert Into  prearve_report1 (kpv , objekt, asutus, koOd, niMetus, hind,kogus, kbmta , kbm , Summa , muud, valuuta, kuurs ) Values ;
					(v_arv.kpv, v_arv.objekt, comAsutusRemote.niMetus,v_arvread.koOd, v_arvread.niMetus,  v_arvread.hind, v_arvread.kogus, ;
					v_arvread.kbmta,v_arvread.kbm, v_arvread.Summa, v_arvread.muud, v_arvread.valuuta, v_arvread.kuurs )
			Endscan
		Endif

	Endscan
	If Empty(leRror)
		Messagebox('Viga', 'Kontrol')
	Endif
	lnStep = 0
Endproc
*
Function edIt_arve
	Parameter tnId

	If Empty(gdKpv)
		Do Form period
	Endif
	ldArvKpv = gdKpv
	With odB
		.Use('queryLeping')
		Select comAsutusRemote
		Locate For Id = queryLeping.asutusId
		Wait Window 'Arvestan '+Alltrim(comAsutusRemote.niMetus) Nowait
		
		If Reccount('queryLeping')=  0 .Or. ( .not. ISNULL(queryLeping.taHtaeg) .And. ;
				(Year(queryLeping.taHtaeg) <> Year(ldArvKpv) .Or. Month(queryLeping.taHtaeg) <> Month(ldArvKpv)) .And. ;
				queryLeping.taHtaeg < ldArvKpv)

			Wait Window 'Leping nr.:'+queryLeping.Number + ' v‰lja sest lepingu t‰htaeg on lıpetatud' Nowait
			Return .F.
		Endif
		.Use('v_arv','v_arv',.T.)
		.Use('v_arvread','v_arvread',.T.)
	Endwith
	lnDok = 0
	lcNumber = ''
	lnPaev = 1
	ldKpv = Date()
	lnDokPropId = 0
	If Empty(tnPreliminary)
		Set Classlib To doknum
		odOknum = Createobject('doknum')
		With odOknum
			.Alias = 'ARV'
			.geTlastdok()
			.kpv = Date()
			lnDok = .doknum
		Endwith
		Release odOknum
		If Vartype(lnDok)= 'C'
			lnDok = Val(Alltrim(lnDok))
		Endif
		lnDok = lnDok+1
		lcNumber = Alltrim(v_dokprop.proc_)+Alltrim(Str(lnDok))
		lnMaxDay = Day(Gomonth(Date(Year(Date()),Month(Date()),1),1)-1)
		Select v_arv
		If !Empty(queryLeping.doklausid)
			lnPaev = Iif( lnMaxDay < queryLeping.doklausid, lnMaxDay, queryLeping.doklausid)
		Else
			lnPaev = 15
		Endif
		If Empty(queryLeping.doklausid) Or queryLeping.doklausid >= 30
			lnPaev = lnMaxDay
		Endif

		ldKpv = Date(Year(Date()), Month(Date()), lnPaev)
		If Date() > ldKpv
			ldKpv = Gomonth(ldKpv,1)
		Endif
		lnDokPropId = v_dokprop.Id
		ldKpv = ldArvKpv + IIF(EMPTY(v_config_.tahtpaev),lnPaev,v_config_.tahtpaev)
	Endif

	lcObjekt = ''
	If !Empty(queryLeping.objektid)
		Select comObjektRemote
		Locate For Id = queryLeping.objektid
		lcObjekt = comObjektRemote.koOd
	Endif
*SET STEP ON
	If !Used('v_config_')
		tnUserId = 0
		odB.Use('v_config_')
	Endif
	Insert Into v_arv (reKvid, Userid, doklausid, Number, kpv, asutusId, liSa, taHtaeg, objekt, muud) Values ;
		(grEkv, guSerid, lnDokPropId, Alltrim(Str(lnDok)), ldArvKpv, queryLeping.asutusId, ;
		IIF(Upper(gcProgNimi) = 'ARVELDUSED.EXE','Viitenumber:'+fncViitenumber(Iif(v_config_.toolbar3 = 1,queryLeping.Id,0),;
		IIF(v_config_.toolbar3=2,queryLeping.asutusId,0),0),queryLeping.Number), ldKpv, lcObjekt,queryLeping.selg )

*		SET STEP ON 

	=fnc_addfromleping(queryLeping.Id)

	ldAlgKpv = Date(Year(ldArvKpv),Month(ldArvKpv),1)
	If queryLeping.kpv  > ldAlgKpv
		ldAlgKpv = queryLeping.kpv
	Endif
*	Set Step On
	lnKoef = 1
	If 	Not Isnull(queryLeping.taHtaeg) .And. ;
			YEAR(queryLeping.taHtaeg) = Year(ldArvKpv) And  Month(queryLeping.taHtaeg) = Month(ldArvKpv) And;
			queryLeping.taHtaeg < ldArvKpv

		ldArvKpv = queryLeping.taHtaeg
	Endif
	If Day(ldAlgKpv) > 1 Or Day(ldArvKpv) < viimane_paev(Year(ldArvKpv),Month(ldArvKpv))
		lnKoef = (Day(ldArvKpv) - Day(ldAlgKpv)) / 	viimane_paev(Year(ldArvKpv),Month(ldArvKpv))
	Endif
	ldLKpv1 = queryLeping.kpv
	ldLKpv2 = Iif(Isnull(queryLeping.taHtaeg) Or Empty(queryLeping.taHtaeg),Gomonth(ldArvKpv,12),queryLeping.taHtaeg)
	If ldArvKpv > ldLKpv1 And ldArvKpv < ldLKpv2
		lnKoef = 1
	Endif


*	Do queries\add_from_leping

	Select v_arvread
	Delete From v_arvread Where nomid Not In (Select Id From curResult Where teEnused = 1) Or Summa = 0
	If lnKoef < 1
		Scan

			Replace kogus With kogus * lnKoef,;
				v_arvread.kbmta With hind * kogus,;
				v_arvread.kbm With (v_arvread.kbmta - v_arvread.soodus) * v_arvread.kbmaar,;
				v_arvread.Summa With (v_arvread.kbmta - v_arvread.soodus) + v_arvread.kbm In v_arvread
		Endscan
	Endif


	Sum (v_arvread.kbmta-v_arvread.soodus) To lnKbmta
	Sum kbm To lnKbm
	Sum Summa To lnSumma
	Replace v_arv.kbmta With frOund(lnKbmta), v_arv.kbm With frOund(lnKbm),  ;
		v_arv.Summa With frOund(lnSumma), jaAk With frOund(lnSumma) In v_arv
Endfunc
*
Function coNvert_muud
	Parameter tcString
	Local cuUsvar, lnKogus, lnHind, llKogus, lcUhik
	cuUsvar = ''
	lcUhik = ''
	lnHind = queryLeping.hind
	llKogus = queryLeping.kogus
	Select coMnomremote
	Locate For Id=queryLeping.nomid
	If Found()
		lcUhik = coMnomremote.uhIk
	Endif
	If Len(tcString)>1
		nkOgus = Occurs('?', tcString)
		For i = 1 To nkOgus
			lnStart = Atc('?', tcString, 1)
			If lnStart>0
				lnKogus = 4
				cvAr = Substr(tcString, lnStart+1, lnKogus)
				Do Case
					Case Upper(Left(cvAr, 3))='KUU'
						cuUsvar = Ltrim(Rtrim(Str(Month(ldArvKpv), 2)+'/'+ ;
							STR(Year(ldArvKpv), 4)+' a.'))
						lnKogus = 4
					Case Upper(Left(cvAr, 4))='HIND'
						cuUsvar = Ltrim(Rtrim(Str(lnHind, 12, 2)))
						lnKogus = 5
					Case Upper(Left(cvAr, 4))='KOGU'
						cuUsvar = Ltrim(Rtrim(Str(llKogus, 12, 3)))
						lnKogus = 6
					Case Upper(Left(cvAr, 4))='SUMM'
						cuUsvar = Ltrim(Rtrim(Str(lnSumma, 12, 2)))
						lnKogus = 6
					Case Upper(Left(cvAr, 4))='UHIK'
						cuUsvar = Rtrim(lcUhik)
						lnKogus = 5
					Case Upper(Left(cvAr, 4))='FORM'
						cuUsvar = reAdformula(queryLeping.foRmula, ;
							queryLeping.Id,1)
						lnKogus = 7
				Endcase
				If  .Not. Empty(cvAr)
					If Empty(cuUsvar)
						cuUsvar = ''
					Endif
					tcString = Stuff(tcString, lnStart, lnKogus, cuUsvar)
				Endif
			Endif
		Endfor
	Endif
	Return tcString
Endfunc
*
Function saVe_arve
	Select v_arv
	Local lrEsult
	lrEsult = .T.
	If v_arv.Summa > 0

		With odB
			Wait Window 'Salvestan arve nr.:'+v_arv.Number Nowait
			.opEntransaction()
			lrEsult = .cuRsorupdate('v_arv')
			tnId = v_arv.Id
			Select v_arvread
			Update v_arvread Set paRentid = tnId
			lrEsult = .cuRsorupdate('v_arv')
			If !Empty(lrEsult)
				lrEsult = .cuRsorupdate('v_arvread')
			Endif
			If !Empty(lrEsult)
* lukkustame mıtte andmed
				Select curMotteNimekiri
				Scan
					Wait Window 'M‰rgistame mıtted ..' Nowait
					If curMotteNimekiri.nomid = 0
						Select coMnomremote
						lcKood = Alltrim(curMotteNimekiri.teenus)
						If Left(lcKood,1) = '{'
							lcKood = Right(lcKood,Len(lcKood)-1)
						Endif

						Locate For koOd = lcKood
						Replace curMotteNimekiri.nomid With coMnomremote.Id In curMotteNimekiri
					Endif

					If curMotteNimekiri.uhis = 0
						lcString = " update counter set muud = "+Str(v_arv.Id) +;
							" where counter.parentid in (select id from library where tun2 = "+Str(curMotteNimekiri.objektid)+;
							" and library.tun3 = "+Str(curMotteNimekiri.nomid) + ;
							" and library.tun1 = 1 )" +;
							" and (ifnull(counter.muud,'null') = 'null' or EMPTY(counter.muud))"+;
							" and MONTH(counter.kpv) = " + Str(Month(curMotteNimekiri.kpv))+;
							" and YEAR(counter.kpv) = "+ Str(Year(curMotteNimekiri.kpv))
					Else
* Parent objekt
						If !Used('comObjektRemote')
							odB.Use('comObjektRemote')
						Endif

						Select comObjektRemote
						Locate For Id = curMotteNimekiri.objektid

						lcString = " update counter set muud = "+Str(v_arv.Id) +;
							" where counter.parentid in (select id from library where tun2 = "+Str(comObjektRemote.paRentid)+;
							" and library.tun3 = "+Str(curMotteNimekiri.nomid) + ;
							" and library.tun1 = 1 )" +;
							" and (ifnull(counter.muud,'null') = 'null' or EMPTY(counter.muud)) "+;
							" and MONTH(counter.kpv) = " + Str(Month(curMotteNimekiri.kpv))+;
							" and YEAR(counter.kpv) = "+ Str(Year(curMotteNimekiri.kpv))
					Endif
					leRror = .execsql(lcString)
				Endscan

				If  Used('v_dokprop') And v_dokprop.registr > 0
					Wait Window 'Konteerimine arve nr.:'+v_arv.Number Nowait
					lrEsult = .Exec("GEN_LAUSEND_ARV",Str(v_arv.Id),'qryArvLausend')
				Endif

			Endif
			If lrEsult = .T.
				.coMmit()
				Wait Window 'Arve nr.:'+v_arv.Number +' salvestatud' Nowait
			Else
				.Rollback()
			Endif

		Endwith
	Endif

	Return lrEsult
Endfunc

Procedure geT_nom_list
	If Used('query1')
		Use In query1
	Endif
	odB.Use('wizlepingnom1','query1')
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Append From Dbf('query1')
	Use In query1
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	If Empty(ldArvKpv)
		ldArvKpv = Date()
	Endif
	Do Form Forms\samm  To nrEsult With '1', Iif(coNfig.keEl=2, 'Teenused',  ;
		'”ÒÎÛ„Ë'), Iif(coNfig.keEl=2, 'Valitud teenused', '¬˚·‡ÌÌ˚Â ÛÒÎÛ„Ë'), ldArvKpv
	If nrEsult=1
		ldArvKpv = gdKpv


		Select Distinct Id From curValitud Where  Not Id In(Select Id From  ;
			curResult Where teEnused=1) Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (Id, teEnused) Values (query1.Id, 1)
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
Procedure geT_lepingu_list
	If Used('query1')
		Use In query1
	Endif
	odB.Use('wizlepingud2','query1_')
*	DELETE FROM query1_ where !ISNULL(query1_.tahtaeg) AND !EMPTY(query1_.tahtaeg) AND query1_.tahtaeg > DATE()
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Select Distinct koOd, niMetus, Id From query1_ ;
		Where nomid In (Select Id From curResult Where curResult.teEnused=1) ;
		AND objektid In (Select Id From curResult Where curResult.objekted=1) ;
		AND taHtaeg > gdKpv;
		Into Cursor query1
	Use In query1_
	Select curSource
	Append From Dbf('query1')
	Use In query1
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	If Empty(ldArvKpv)
		ldArvKpv = Date()
	Endif

	Do Form Forms\samm To nrEsult With '2', Iif(coNfig.keEl=2, 'Lepingud',  ;
		'ƒÓ„Ó‚Ó‡'), Iif(coNfig.keEl=2, 'Valitud lepingud', '¬˚·‡ÌÌ˚Â ‰Ó„Ó‚Ó‡') , ldArvKpv
	If nrEsult=1
		If !Empty(gdKpv)
			ldArvKpv = gdKpv
		Endif

		Select Distinct Id From curValitud Where  Not Id In(Select Id From  ;
			curResult Where lePingud=1) Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (Id, lePingud) Values (query1.Id, 1)
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

Function fnc_addfromleping
	Lparameters tnId
	Local oFormula
	lnKSumma = 	0
	lnKSummaKbm = 0
	lnKSummaKokku = 0

	If !Used('v_leping2')
		odB.Use('v_leping2')
	Else
		odB.dbreq('v_leping2')
	Endif

*!*		Delete From v_leping2 ;
*!*			Where nomid Not In (Select Id From curResult Where teEnused = 1) Or v_leping2.Status < 1

	Select v_leping2
	If Used('qryLeping2')
		Use In qryLeping2
	Endif
*SET STEP ON 
	Set Classlib To Classlib
	oFormula = Createobj('classlib.formula')

	With oFormula
		.Requery()
		.kpv = ldArvKpv
		Select v_leping2
		lnrecno = Recno()
		Scan For v_leping2.Status = 1
			Select curResult
			Locate For Id = v_leping2.nomid And teEnused = 1
			If Found()
				Wait Window 'Arvestan leping nr.:'+Alltrim(queryLeping.Number)+Alltrim(Str(Recno('v_leping2')))+'/'+Alltrim(Str(Reccount('v_leping2'))) Nowait

				lnKogus = 0
				lnSumma = 0
				lnSummaKokku = 0
				lcSelg = ''
				lnSoodus = 0
				lnKbm = 0
				lnKogus = v_leping2.kogus
				lnHind = v_leping2.hind
				.puhasta()
				lnAlg = 0
				lnLopp = 0

				If Empty(.objektid) And !Empty(queryLeping.objektid)
					.objektid = comObjektRemote.Id
				Endif
				.lepingid = v_leping2.paRentid
				.arvId = 0

				.hind = lnHind
				.kogus = lnKogus
				.valuuta = v_leping2.valuuta
				.kuurs = v_leping2.kuurs
				.asutusId = 0
				.kpv = v_arv.kpv
				If !Isnull(v_leping2.foRmula) And !Empty(v_leping2.foRmula)

					lcFormulaTais = ALLTRIM(v_leping2.foRmula)
					lcFormulaKogus = ''
					lcFormulaHind = ''
					lnKogusFormula = Atc('KOGUS:', Upper(ALLTRIM(v_leping2.foRmula)))
					lnHindFormula = Atc('HIND:', Upper(ALLTRIM(v_leping2.foRmula)))
					If lnKogusFormula > 0 Or lnHindFormula > 0
						If lnKogusFormula > lnHindFormula
							lnAlg = lnHindFormula
							lnLopp = lnKogusFormula
							lcFormulaKogus = Alltrim(Substr(lcFormulaTais,lnLopp+6))
							lcFormulaHind = Alltrim(Substr(lcFormulaTais,lnAlg+5,lnLopp-lnAlg - 5))

						Else
							lnAlg = lnKogusFormula
							lnLopp = lnHindFormula
							lcFormulaHind = Alltrim(Substr(lcFormulaTais,lnLopp+5))
							lcFormulaKogus = Alltrim(Substr(lcFormulaTais,lnAlg+6,lnLopp-lnAlg - 6))
						Endif
					Else
						lcFormula = lcFormulaTais
					Endif
*					With Thisform.formULA1
						If lnAlg + lnLopp > 0
* meil on hind ja / voi kogus osad
* esimine loeme hinna osa

							If !Empty(lcFormulaHind)
*								SET STEP ON 
								=Kaivitaformula(oFormula,lcFormulaHind)
								.lcHind = .returnvalue
							Else
								.lcHind = '1'
							Endif
* kogus
							If !Empty(lcFormulaKogus)
								=KaivitaFormula(oFormula,lcFormulaKogus)
								.lcKogus = .returnvalue
								If Empty(.lcKogus)
									.lcKogus = '0'
								Endif

							Else
								.lcKogus = '1'
							Endif

							.returnvalue  = .lcHind +'*' + .lcKogus
						Else
							=KaivitaFormula(oFormula,lcFormulaTais)
						Endif

*		Replace Arv With .ReturnValue  In curExpr
						lnHind = 0
*					SET STEP ON
						.hind = lnHind
						.kogus = v_leping2.kogus
						lnHind = Iif(Empty(.hind),1,.hind)
						lnKogus = Iif(Empty(.kogus),1,.kogus)
						lcSelg = .selg

						DO case
							case !EMPTY(.lcHind) AND EMPTY(.lcKogus)
								.Hind = Evaluate(.lcHind)
								lnHind = .hind
								.kogus = v_leping2.kogus
								lnKogus = .kogus
							case !EMPTY(.lcKogus) AND EMPTY(.lcHind)
								.kogus = Evaluate(.lcKogus)
								.hind = v_leping2.hind
							case !EMPTY(.lcKogus) AND !EMPTY(.lcHind)
								.Hind = Evaluate(.lcHind)
								.kogus = Evaluate(.lcKogus)
							otherwise
								.Hind = Evaluate(.returnvalue)
								
								.kogus = 1
								lnSumma = .Hind *.kogus
						ENDCASE
						IF !EMPTY(.returnvalue)
							lnHind = .hind
							lnKogus = .kogus
						ENDIF
						
*!*						IF RECNO('v_leping2') <> lnrecno
*!*							SELECT v_leping2
*!*							GO lnrecno
*!*						ENDIF

						.nomid = v_leping2.nomid
						If !Isnull(v_leping2.soodus) And !Empty(v_leping2.soodus) And;
								!Empty(v_leping2.soodusalg) And  !Empty(v_leping2.sooduslopp) And;
								ldArvKpv >= v_leping2.soodusalg And ldArvKpv <= v_leping2.sooduslopp
							.soodus = v_leping2.soodus
						Else
							.soodus = 0
						Endif
						lnSumma = lnHind * lnKogus - .soodus
						If Empty(v_leping2.kbm)
* ei siseldab kbm
							.Summa = lnSumma
							.summakokku = 0
						Else
							.Summa = 0
							.summakokku = lnSumma
						Endif
					Else
*puudub formula
						If !Isnull(v_leping2.soodus) And !Empty(v_leping2.soodus) And;
								!Empty(v_leping2.soodusalg) And  !Empty(v_leping2.sooduslopp) And;
								ldArvKpv >= v_leping2.soodusalg And ldArvKpv <= v_leping2.sooduslopp
							.soodus = v_leping2.soodus
						Endif

						If !Empty(v_leping2.Summa)
							lnSumma = Round(v_leping2.Summa ,2)
*							lnSumma = Round(v_leping2.Summa * v_leping2.kuurs,2)
							If Empty(v_leping2.kbm)
* ei siseldab kbm
								.Summa = lnSumma
								.summakokku = 0
							Else
								.Summa = 0
								.summakokku = lnSumma
							Endif
						Else
							lnSumma = (v_leping2.hind - .soodus) * v_leping2.kogus
							If Empty(v_leping2.kbm)
* ei siseldab kbm
								.Summa = lnSumma
								.summakokku = 0
							Else
								.Summa = 0
								.summakokku = lnSumma
							Endif
						Endif

					Endif
					If Empty(.nomid)
						.nomid = v_leping2.nomid
					Endif

					.arvestakbm()
					.arvestakbmsumma()

					lcValuuta = fnc_currentvaluuta('VAL',v_arv.kpv)
					lnKuurs = fnc_currentvaluuta('KUURS',v_arv.kpv)

					Select coMnomremote
					If coMnomremote.Id <> v_leping2.nomid
						Locate For coMnomremote.Id = v_leping2.nomid And coMnomremote.tyyp = 1
					Endif
					If v_leping2.valuuta = 'EUR'
						lnKuurs = 1
					Endif

					.hind = Round(.hind / lnKuurs,4)
					.kbmsumma = Round(.kbmsumma / lnKuurs,2)
					.Summa = Round(.Summa / lnKuurs,2)
					.soodus = Round(.soodus / lnKuurs,2)
					.summakokku = Round(.summakokku / lnKuurs,2)



					lcValuuta = fnc_currentvaluuta('VAL',v_arv.kpv)
					lnKuurs = fnc_currentvaluuta('KUURS',v_arv.kpv)

*!*	SET STEP ON
IF EMPTY(lcSelg) AND !EMPTY(v_leping2.muud)
	lcSelg = coNvert_muud (Iif (Isnull(v_leping2.muud),Space(1),v_leping2.muud))
ENDIF

					Insert Into v_arvread (nomid, koOd, niMetus, kogus, hind, soodus, kbm, Summa, kbmta, konto, kood1, kood2, kood3, kood4, kood5, valuuta, kuurs, Proj, muud,kbmaar);
						values (v_leping2.nomid, coMnomremote.koOd, coMnomremote.niMetus, .kogus, .hind,.soodus, .kbmsumma, .summakokku, .Summa, ;
						coMnomremote.konto, coMnomremote.kood1,;
						coMnomremote.kood2, coMnomremote.kood3,coMnomremote.kood4, coMnomremote.kood5, ;
						lcValuuta, lnKuurs,	 coMnomremote.Proj, lcSelg,.kbmmaar)

*!*			Select v_arvread
*!*			lcMuud = convert_muud (iif (isnull(queryLeping.muud),space(1),queryLeping.muud))
*!*			Replace muud with lcMuud in v_arvread


*!*			Insert Into arvestus (nomid, kood, hind, kogus, soodus, Summa, kbm, summakokku, formula, selg) Values ;
*!*				(v_leping2.nomid,v_leping2.kood, .hind, .kogus, .soodus, .Summa, .kbmsumma, .summakokku,;
*!*				v_leping2.formula, lcSelg  )

*!*			lnKSumma = 	lnKSumma + .Summa
*!*			lnKSummaKbm = 	lnKSummaKbm + .kbmsumma
*!*			lnKSummaKokku = 	lnKSummaKokku + .Summa
				Endif

			Endscan
		Endwith
		Select v_arvread
		Sum (v_arvread.kbmta - v_arvread.soodus) To lnKbmta
		Sum kbm To lnKbm
		Sum Summa To lnSumma
		Replace v_arv.kbmta With frOund(lnKbmta),;
			v_arv.kbm With frOund(lnKbm),;
			v_arv.Summa With frOund(lnSumma) In v_arv

	Endfunc



Function fnc_addfromleping_vana
	Select comAsutusRemote

	Locate For Id = v_arv.asutusId
	tcNumber = '%%'
	tcSelgitus = '%%'
	tcAsutus = Rtrim(comAsutusRemote.niMetus)+'%'
	dKpv1 = Date(Year(ldArvKpv)-10,1,1)
	dKpv2 = Date(Year(ldArvKpv),12,31)
	leRror = odB.Use('curLepingud','qryLepingud')
	If !Used ('qryLepingud')
		Messagebox('Viga','Kontrol')
		If coNfig.Debug = 1
			Set Step On
		Endif
		Return .F.
	Endif
	Delete For asutusId <> v_arv.asutusId
	lnOpt = 0
	Select qryLepingud
	Count To lnCount
	Go Top
	Do Case
		Case lnCount = 1
			lnOpt = qryLepingud.Id
		Case lnCount > 1
			Do Form valileping With v_arv.asutusId To lnOpt
		Otherwise
			Return
	Endcase
	If Used ('qryLepingud')
		Use In qryLepingud
	Endif
	If Empty (lnOpt)
		Return
	Endif
	tnId = lnOpt
	odB.Use('queryLeping')
	Select queryLeping
	If !Used ('queryLeping') Or Reccount('queryLeping')<1 Or;
			(!Isnull(queryLeping.taHtaeg) And  queryLeping.taHtaeg < ldArvKpv)
		Return .F.
	Endif

	lcValuuta = fnc_currentvaluuta('VAL',v_arv.kpv)
	lnKuurs = fnc_currentvaluuta('KUURS',v_arv.kpv)

	Select queryLeping
	Scan

		Select coMnomremote
		Locate For Id = queryLeping.nomid And tyyp = 1

		lnKbm = 0
		Do Case
			Case coMnomremote.doklausid = 0
				lnKbm = 1.18
			Case coMnomremote.doklausid = 1
				lnKbm = 1
			Case coMnomremote.doklausid = 2
				lnKbm = 1.05
			Case coMnomremote.doklausid = 3
				lnKbm = 1
			Case coMnomremote.doklausid = 4
				lnKbm = 1.09
			Case coMnomremote.doklausid = 5
				lnKbm = 1.20
		Endcase

		If ldArvKpv > Date(2009,06,30)  And lnKbm = 1.18
			lnKbm = 1.20
		Endif




		If Empty (queryLeping.foRmula)
			If !Empty (queryLeping.Summa)
				lnSumma = Round(queryLeping.Summa * queryLeping.kuurs,2)
				lnKbmta = Round(lnSumma / lnKbm,2) * Iif (Empty (qryrekv.kbmkood),0,1)
				lnKbm = lnSumma - lnKbmta
				lnKogus = Iif(Empty(queryLeping.kogus),1,queryLeping.kogus)
				lnHind = lnKbmta / lnKogus
			Else
				lnKogus = queryLeping.kogus
				lnKbmta = Round(((queryLeping.hind - queryLeping.soodus) * queryLeping.kogus)*queryLeping.kuurs,2)
				lnKbm = Round(lnKbmta * (lnKbm - 1),2)
				lnHind = queryLeping.hind*queryLeping.kuurs
				lnSumma = lnKbmta + lnKbm
			Endif
		Else
			lnKbmta = Round(reAdformula(queryLeping.foRmula, queryLeping.Id) * queryLeping.kuurs,2)
			If lnKbmta > 0
				lnKbm = Round(lnKbmta * (lnKbm - 1),2)
				lnSumma = lnKbmta + lnKbm
				lnHind = lnKbmta
			Else
				lnSumma = 0
				lnKbm = 0
				lnHind = 0
			Endif
		Endif

		Select queryLeping
		If lnSumma <> 0 And !Empty(queryLeping.nomid)

			Insert Into v_arvread (koOd, nomid, kogus, hind, soodus, kbm, Summa, kbmta, konto, kood1, kood2, kood3, kood4, kood5, valuuta, kuurs, Proj);
				values (coMnomremote.koOd,queryLeping.nomid, lnKogus, (lnHind / lnKuurs),;
				IIF(Isnull(queryLeping.soodus),0,queryLeping.soodus), (lnKbm / lnKuurs), (lnSumma/lnKuurs), (lnKbmta/lnKuurs), coMnomremote.konto, coMnomremote.kood1, coMnomremote.kood2, coMnomremote.kood3,;
				coMnomremote.kood4, coMnomremote.kood5, lcValuuta, lnKuurs, coMnomremote.Proj)

			Select v_arvread
			lcMuud = coNvert_muud (Iif (Isnull(queryLeping.muud),Space(1),queryLeping.muud))
			Replace muud With lcMuud In v_arvread
		Endif
	Endscan
	Select v_arvread
	Sum (v_arvread.kbmta - v_arvread.soodus) To lnKbmta
	Sum kbm To lnKbm
	Sum Summa To lnSumma
	Replace v_arv.kbmta With Round(lnKbmta,2),;
		v_arv.kbm With Round(lnKbm,2),;
		v_arv.Summa With Round(lnSumma,2) In v_arv
	Use In queryLeping


Function coNvert_muud
	Parameter tcString
	Local cuUsvar, lnKogus, cvAr
	Private lnKogus, lnSumma, lnHind
	cvAr = ''
	lnKogus = 0
	cuUsvar = ''
	lnKogus = 0
	lnHind = v_arvread.hind
	llKogus = v_arvread.kogus
	lnSumma = v_arvread.Summa
	lcUhik = Rtrim(v_arvread.uhIk)

	If Len(tcString) > 1
		nkOgus = Occurs('?',tcString)
		For i = 1 To nkOgus
			lnStart = Atc('?',tcString, 1)
			If lnStart > 0
				lnKogus = 4
				cvAr = Substr (tcString,lnStart+1,lnKogus)
				Do Case
					Case Upper(Left (cvAr,3)) = 'KUU'
						cuUsvar = Str(Month(ldArvKpv),2)+'/'+Str(Year(ldArvKpv),4)+' a.'
						lnKogus = 4
					Case Upper(Left (cvAr,4)) = 'HIND'
						cuUsvar = Str (lnHind,12,2)
						lnKogus = 5
					Case Upper(Left (cvAr,4)) = 'KOGU'
						cuUsvar = Str (llKogus,12,3)
						lnKogus = 6
					Case Upper(Left (cvAr,4)) = 'SUMM'
						cuUsvar = Str (lnSumma,12,2)
						lnKogus = 6
					Case Upper(Left (cvAr,4)) = 'UHIK'
						cuUsvar = Rtrim(lcUhik)
						lnKogus = 5
					Case Upper(Left (cvAr,4)) = 'FORM'
						cuUsvar = reAdformula(queryLeping.foRmula, queryLeping.Id,1)
						lnKogus = 7
				Endcase
				If !Empty (cvAr)
					If Empty (cuUsvar)
						cuUsvar = ''
					Endif
					tcString = Stuff (tcString, lnStart, lnKogus, cuUsvar)
				Endif

			Endif
		Endfor
	Endif
	Return tcString

Procedure geT_objektide_list
	If Used('query1')
		Use In query1
	Endif
	lcString = "SELECT distinct library.kood, library.nimetus, library.id "+;
		" FROM  library inner join  Leping1 on Leping1.objektid = library.id "+;
		" WHERE    Leping1.rekvid = ?gRekv  ORDER BY library.kood, library.nimetus, library.id "

	odB.execsql(lcString,'query1')
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Append From Dbf('query1')
	Insert Into curSource (koOd, niMetus, Id) Values ('ILMA','Ilma objektita',0)
	Use In query1
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '2', Iif(coNfig.keEl=2, 'Teenused',  ;
		'”ÒÎÛ„Ë'), Iif(coNfig.keEl=2, 'Valitud teenused', '¬˚·‡ÌÌ˚Â ÛÒÎÛ„Ë') , ldArvKpv
	If nrEsult=1

		If !Empty(gdKpv)
			ldArvKpv = gdKpv
		Endif

		Select Distinct Id From curValitud Where  Not Id In(Select Id From  ;
			curResult Where objekted=1) Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (Id, objekted) Values (query1.Id, 1)
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


Function Kaivitaformula
	Lparameters loFormula, lcFormula
	loFormula.foRmula = lcFormula
	nOccurs = Occurs ('?',lcFormula)
	For i = 1 To nOccurs
		With loFormula
			If Empty(.returnvalue)
				.returnvalue = .foRmula
			Endif
			.loemakro()
			.koOd = Substr (.returnvalue,.Start1+1,.Start2 - .Start1)
			Wait Window 'Oodake, arvestan:'+.koOd Nowait
*			.kpv = gdkpv
*!*				.objektid = This.objektid
*!*				.lepingid = This.leping
*!*			IF USED('qryLeping2') AND !EMPTY(this.leping2id)
*!*				LOCATE FOR id = this.leping2id
*!*			ENDIF
			.nomid = v_leping2.nomid

			Select coMnomremote
			Locate For koOd = .koOd
			If FOUND() AND coMnomremote.Id <> .nomid
				.nomid = coMnomremote.Id
				Select v_leping2
				lnRecno = RECNO('v_leping2')
				Locate For v_leping2.nomid = .nomid
				If Found()
					.hind = v_leping2.hind
				Else
					.hind = coMnomremote.hind
				Endif
				SELECT v_leping2
				GO lnRecno
			Endif

			lcSumma = .loekood()
			tcString = .koodivahetus()
		Endwith
	Endfor
Endfunc
