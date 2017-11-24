Parameter tnLepingId, tnPakettId, tnstatus
Local lnResult
tnStatus = IIF(ISNULL(tnStatus),0,tnStatus)
		WAIT WINDOW 'Start uuenda andmed..' nowait

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
*				WAIT WINDOW 'step'+STR(lnStep) NOWAIT TIMEOUT 10
	
		If  .Not. Empty(tnLepingId)
			Insert Into curResult (Id, lePingud) Values (tnLepingId, 1)
			tnId = tnLepingId
			WAIT WINDOW ".Use('v_leping2','vleping2_')" nowait 
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
	Local leRror

* uuenda lepingud

	Select Distinct Id From curResult Where lePingud=1 Into Cursor recalc1
	Select recalc1
	SCAN				
		WAIT WINDOW 'Uuendan andmed:'+STR(RECNO('recalc1'))+'/'+STR(RECCOUNT('recalc1')) nowait
*		.opEntransaction()
		lError = edit_leping(recalc1.Id)		
*!*			
*!*			If !Empty(leRror)
*!*				.coMmit()
*!*			Else
*!*				.Rollback()
*!*			Endif
		If Empty(leRror)
			Exit
		Endif
	Endscan
	If Empty(leRror)
		Messagebox('Viga', 'Kontrol')
	Endif
	lnStep = 0
Endproc
*
Function edIt_leping
	Parameter tnId
*	WAIT WINDOW "odb.Use('v_leping2')" nowait
	odb.Use('v_leping2')
	lSave = .f.
	Select v_Pakett
	Scan
		Select v_leping2
		Locate For nomid = v_Pakett.nomid
		If Found()
			IF tnStatus = 0
				If v_leping2.hind <> v_Pakett.hind Or v_leping2.valuuta <> v_Pakett.valuuta Or v_leping2.kuurs <> v_Pakett.kuurs Or v_leping2.formula <> v_Pakett.formula
					Replace v_leping2.hind With v_Pakett.hind,;
						v_leping2.valuuta With v_Pakett.valuuta,;
						v_leping2.kuurs With v_Pakett.kuurs ,;
						v_leping2.formula With v_Pakett.formula In v_leping2
					lSave = .t.
				
				ENDIF
			ELSE
				replace v_leping2.status WITH v_Pakett.status IN v_leping2
				lSave = .t.
			ENDIF
			
		Else
			Insert Into v_leping2 (parentid, nomid, hind, kogus, Status, valuuta, kuurs, formula, kogus) Values;
				(tnId, v_Pakett.nomid,  v_Pakett.hind, v_Pakett.kogus,v_Pakett.status, v_Pakett.valuuta, v_Pakett.kuurs, v_Pakett.formula, v_pakett.kogus)
				lSave = .t.
		Endif
	ENDSCAN
	SELECT v_leping2
	IF lSave = .t.
*		Wait Window 'Salvestan leping..' Nowait
		lnError = odb.cursorupdate('v_leping2')
		
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
	ENDIF
	WAIT WINDOW "odB.Use('wizlepingnom1','query1')" nowait

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
	WAIT WINDOW 'Koostan lepingute nimikiri..' nowait
	IF EMPTY(tnPakettId)
		odB.Use('wizlepingud2','query1_')
	ELSE
		lcString = "SELECT distinct id, kood, nomid,  left(rtrim(asutus)+ space(1)+ rtrim(nimetus),120)::varchar as nimetus,objektid, pakettId, tahtaeg FROM  Wizlepingud WHERE "+;
			" rekvId = "+STR(grekv) + " and PAKETTid = "+STR(tnPakettId)+ " ORDER BY kood"
	ENDIF
	lError = SQLEXEC(gnHandle,lcString,'query1_')
	IF lError < 1 OR !USED('query1_')
		SET STEP ON 
	ENDIF
	
*	DELETE FROM query1_ where !ISNULL(query1_.tahtaeg) AND !EMPTY(query1_.tahtaeg) AND query1_.tahtaeg > DATE()
*!*		Select curSource
*!*		If Reccount('curSource')>0
*!*			Zap
*!*		Endif

	SELECT query1_
	Select Distinct Id From query1_ ;
		Where objektid In (Select Id From curResult Where curResult.objekted=1) ;
		AND taHtaeg > gdKpv;
		Into Cursor query1
		
		Select query1
		Scan
			Insert Into curResult (Id, lePingud) Values (query1.Id, 1)
		Endscan
*!*			
*!*		Use In query1_
*!*		Select curSource
*!*		Append From Dbf('query1')
*!*		Use In query1
*!*		Select curValitud
*!*		If Reccount('curvalitud')>0
*!*			Zap
*!*		Endif
*!*		If Empty(ldArvKpv)
*!*			ldArvKpv = Date()
*!*		Endif

*!*		Do Form Forms\samm To nrEsult With '2', Iif(coNfig.keEl=2, 'Lepingud',  ;
*!*			'Договора'), Iif(coNfig.keEl=2, 'Valitud lepingud', 'Выбранные договора') , ldArvKpv
*!*		If nrEsult=1
*!*			If !Empty(gdKpv)
*!*				ldArvKpv = gdKpv
*!*			Endif

*!*			Select Distinct Id From curValitud Where  Not Id In(Select Id From  ;
*!*				curResult Where lePingud=1) Into Cursor query1
*!*			Select query1
*!*			Scan
*!*				Insert Into curResult (Id, lePingud) Values (query1.Id, 1)
*!*			Endscan
*!*			Use In query1
*!*		Endif
*!*		If nrEsult=0
*!*			lnStep = 0
*!*		Else
*!*			lnStep = lnStep+nrEsult
*!*		Endif
		lnStep = lnStep+1
	Return
Endproc
*



Procedure geT_objektide_list
	If Used('query1')
		Use In query1
	Endif
*	WAIT WINDOW 'sel objekt list' TIMEOUT 1
*!*		lcString = "SELECT distinct library.kood, library.nimetus, library.id "+;
*!*			" FROM  library inner join  Leping1 on Leping1.objektid = library.id "+;
*!*			" WHERE    Leping1.rekvid = ?gRekv  ORDER BY library.kood, library.nimetus, library.id "

	lcString = " SELECT distinct library.kood, library.nimetus, library.id  FROM  library inner join  Leping1 on Leping1.objektid = library.id "+;
		" WHERE    Leping1.rekvid =  " + STR(gRekv)
	IF !EMPTY(tnPakettId) 	
		lcString = lcString + " and leping1.pakettid = "+STR(tnPakettId) 
	ENDIF
	lcString = lcString +  " ORDER BY library.kood, library.nimetus, library.id "


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
