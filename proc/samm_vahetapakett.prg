Parameter tnLepingId, tnPakettId
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

	IF !USED('v_pakett')
		tnId = tnPakettId
		.use('v_pakett')
	ENDIF
	

	lnStep = 2
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
*				WAIT WINDOW 'objekt' NOWAIT TIMEOUT 1
			
				Do geT_objektide_list

			Case lnStep=3
				Do geT_lepingu_list
			Case lnStep>3
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
Endwith
Endproc
*
Procedure arVutus
	Local leRror, lnCount

* uuenda lepingud

	Select Distinct Id From curResult Where lePingud=1 Into Cursor recalc1
	Select recalc1
	lnCount = 0
	SCAN				
		.opEntransaction()
		lError = edit_leping(recalc1.Id)		
		If !Empty(leRror)
			.coMmit()
			lnCount = lnCount + 1
		Else
			.Rollback()
		Endif
		If Empty(leRror)
			Exit
		Endif
	Endscan
	If Empty(leRror)
		Messagebox('Viga', 'Kontrol')
	ENDIF
	IF lnCount > 0
		MESSAGEBOX('Kokku uuendatud:'+STR(lnCount,3)+' lepingud',0+64,'Lepingud',20)
	ENDIF
	
	lnStep = 0
Endproc
*
Function edIt_leping
	Parameter tnId
	lSave = .t.
	odb.Use('v_leping1')
	IF v_leping1.pakettid <> tnPakettId
			odb.Use('v_leping2')
			DELETE FROM v_leping2
	ENDIF
*	 	SET STEP ON 
	SELECT v_leping1
	replace v_leping1.pakettid WITH tnPakettId IN v_leping1
	IF lSave = .t.
*		Wait Window 'Salvestan leping nr:'+Alltrim(tmpLep.Number)+' kokku: '+Alltrim(Str(Recno('tmpLep')))+'/'+Alltrim(Str(Reccount('tmpLep'))) Nowait
		lnError = odb.cursorupdate('v_leping1')
		
		IF USED('v_leping2')
			lnError = odb.cursorupdate('v_leping2')		
		ENDIF
*!*			IF lnError < 0
*!*				WAIT WINDOW 'Viga save v_leping2'
*!*				SET STEP ON 
*!*			ENDIF
		

*!*			IF !EMPTY(lnError) 	
*!*				Wait Window 'Leping nr:'+Alltrim(tmpLep.Number)+' kokku: '+Alltrim(Str(Recno('tmpLep')))+'/'+Alltrim(Str(Reccount('tmpLep'))) +' uuendatud' TIMEOUT 5
*!*			ENDIF
		
	ENDIF	
	IF USED('v_leping1')
		USE IN v_leping1
	ENDIF

	IF USED('v_leping2')
		USE IN v_leping2
	ENDIF

Endfunc
*
Function coNvert_muud
	Parameter tcString
	Local cuUsvar, lnKogus, lnHind, llKogus, lcUhik
	cuUsvar = ''
	lcUhik = ''
	lnHind = quEryleping.hind
	llKogus = quEryleping.kogus
	Select coMnomremote
	Locate For Id=quEryleping.nomid
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
						cuUsvar = reAdformula(quEryleping.foRmula, ;
							quEryleping.Id,1)
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
		'Услуги'), Iif(coNfig.keEl=2, 'Valitud teenused', 'Выбранные услуги'), ldArvKpv
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
	ENDIF
	odB.Use('wizlepingud2','query1_')

	SELECT query1_
	Select Distinct Id From query1_ ;
		Where objektid In (Select Id From curResult Where curResult.objekted=1) AND pakettId <> tnPakettId 	AND taHtaeg > gdKpv;
		Into Cursor query1
		IF RECCOUNT('query1') = 0 
			MESSAGEBOX('Lepingud puuduvad',0+64,'Lepingud',20)
		ENDIF
		
		Select query1
		Scan
			Insert Into curResult (Id, lePingud) Values (query1.Id, 1)
		Endscan
		lnStep = lnStep+1
	Return
Endproc
*



Procedure geT_objektide_list
	If Used('query1')
		Use In query1
	Endif
*	WAIT WINDOW 'sel objekt list' TIMEOUT 1
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
	ENDIF
	ldArvKpv = DATE()
	nrEsult = 0
	Do Form Forms\samm To nrEsult With '2', Iif(coNfig.keEl=2, 'Objektid',  ;
		'Объекты'), Iif(coNfig.keEl=2, 'Valitud objektid', 'Выбранные объекты') , ldArvKpv
	If nrEsult=1

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
	ENDIF
Endproc
