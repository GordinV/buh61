Select comAsutusremote

Locate for id = v_arv.asutusId
tcNumber = '%%'
tcSelgitus = '%%'
tcAsutus = rtrim(comAsutusremote.nimetus)+'%'
dKpv1 = date(year(date())-10,1,1)
dKpv2 = date(year(date()),12,31)
lError = oDb.use('curLepingud','qryLepingud')
If !used ('qryLepingud')
	Messagebox('Viga','Kontrol')
	If config.debug = 1
		Set step on
	Endif
	Return .f.
Endif
Delete for asutusId <> v_arv.asutusId
lnOpt = 0
Select qryLepingud
Count to lnCount
Go top
Do case
	Case lnCount = 1
		lnOpt = qryLepingud.id
	Case lnCount > 1
		Do form valileping with v_arv.asutusId to lnOpt
	Otherwise
		Return
Endcase
If used ('qryLepingud')
	Use in qryLepingud
Endif
If empty (lnOpt)
	Return
Endif
tnId = lnOpt
oDb.use('queryLeping')
If !used ('queryLeping') or reccount('queryLeping')<1 or;
		(!isnull(queryLeping.tahtaeg) and  queryLeping.tahtaeg < date())
	Return .f.
Endif
*!*	Set classlib to doknum
*!*	oDoknum = createobject('doknum')
*!*	With oDoknum
*!*		.alias = 'ARV'
*!*		.GETLASTDOK()
*!*		lnDok = .doknum
*!*	Endwith
*!*	Release oDoknum
*!*	If vartype(lnDok) <> 'N'
*!*		lnDok = 0
*!*	Endif
*!*	lnDok = lnDok + 1
*!*	lcNumber = alltrim(config.reserved2)+alltrim(str(lnDok))
*!*	Select v_arv
*!*	If reccount ('v_arv') < 1
*!*		Insert into v_arv (rekvid, userId, DoklausId, number, kpv, asutusId, arvId, lisa, tahtaeg);
*!*			values (gRekv, gUserId, this.dokprop, alltrim(config.reserved2)+alltrim(str(lnDok)),;
*!*			date(), queryLeping.asutusId, queryaa.id,'Leping '+rtrim(queryLeping.number), date()+14)
*!*	Else
*!*		Replace DoklausId with this.dokprop,;
*!*			lisa with 'Leping '+rtrim(queryLeping.number) ,;
*!*			tahtaeg with date()+14
*!*	Endif

lcValuuta = fnc_currentvaluuta('VAL',v_arv.kpv)
lnKuurs = fnc_currentvaluuta('KUURS',v_arv.kpv)

Select queryLeping
Scan

		Select comNomRemote
		Locate for id = queryLeping.nomId AND TYYP = 1

		lnKbm = 0
		DO case
			CASE comNomRemote.doklausid = 0
				lnKbm = 1.18
			CASE comNomRemote.doklausid = 1
				lnKbm = 1
			CASE comNomRemote.doklausid = 2
				lnKbm = 1.05
			CASE comNomRemote.doklausid = 3
				lnKbm = 1
			Case comNomRemote.doklausid = 4
				lnKbm = 1.09
			Case comNomRemote.doklausid = 5
				lnKbm = 1.20
		endcase

IF DATE() > DATE(2009,06,30)  AND lnKbm = 1.18
	lnKbm = 1.20
endif




	If empty (queryLeping.formula)
		If !empty (queryLeping.summa)
			lnSumma = round(queryLeping.summa * queryLeping.kuurs,2)
			lnKbmta = round(lnSumma / lnKbm,2) * iif (empty (qryrekv.kbmkood),0,1)
			lnKbm = lnSumma - lnKbmta
			lnKogus = iif(empty(queryLeping.kogus),1,queryLeping.kogus)
			lnHind = lnKbmta / lnKogus
		Else
			lnKogus = queryLeping.kogus
			lnKbmta = round(((queryLeping.hind - queryLeping.soodus) * queryLeping.kogus)*queryLeping.kuurs,2)
			lnKbm = round(lnKbmta * (lnKbm - 1),2)
			lnHind = queryLeping.hind*queryLeping.kuurs
			lnSumma = lnKbmta + lnKbm
		Endif
	Else
		lnKbmta = round(readformula(queryLeping.formula, queryLeping.id) * queryLeping.kuurs,2)
		If lnKbmta > 0
			lnKbm = round(lnKbmta * (lnKbm - 1),2)
			lnSumma = lnKbmta + lnKbm
			lnHind = lnKbmta
		Else
			lnSumma = 0
			lnKbm = 0
			lnHind = 0
		Endif
	Endif

	Select queryLeping
	If lnSumma <> 0 and !empty(queryLeping.nomId)
	
		Insert into v_arvread (kood, nomId, kogus, hind, soodus, kbm, summa, kbmta, konto, kood1, kood2, kood3, kood4, kood5, valuuta, kuurs, proj, tunnus);
			values (comNomRemote.kood,queryLeping.nomId, lnkogus, (lnHind / lnKuurs),;
			queryLeping.soodus, (lnKbm / lnKuurs), (lnSumma/lnKuurs), (lnKbmta/lnKuurs), comNomRemote.konto, comNomRemote.kood1, comNomRemote.kood2, comNomRemote.kood3,;
			comNomRemote.kood4, comNomRemote.kood5, lcValuuta, lnKuurs, comNomRemote.proj, comNomRemote.tunnus)

		Select v_arvread
		lcMuud = convert_muud (iif (isnull(queryLeping.muud),space(1),queryLeping.muud))
		Replace muud with lcMuud in v_arvread
	Endif
Endscan
Select v_arvread
Sum (v_arvread.kbmta - v_arvread.soodus) to lnKbmta
Sum kbm to lnKbm
Sum summa to lnSumma
Replace v_arv.kbmta with round(lnKbmta,2),;
	v_arv.kbm with round(lnKbm,2),;
	v_arv.summa with round(lnSumma,2) in v_arv
Use in queryLeping


Function convert_muud
Parameter tcString
Local cUusVar, lnKogus, cVar
Private lnKogus, lnSumma, lnHind
cVar = ''
lnKogus = 0
cUusVar = ''
lnKogus = 0
lnHind = v_arvread.hind
llKogus = v_arvread.kogus
lnSumma = v_arvread.summa
lcUhik = rtrim(v_arvread.uhik)

If len(tcString) > 1
	nKogus = OCCURS('?',tcString)
	For i = 1 to nKogus
		lnStart = atc('?',tcString, 1)
		If lnStart > 0
			lnKogus = 4
			cVar = substr (tcString,lnStart+1,lnKogus)
			Do case
				Case upper(left (cVar,3)) = 'KUU'
					cUusVar = str(month(date()),2)+'/'+str(year(date()),4)+' a.'
					lnKogus = 4
				Case upper(left (cVar,4)) = 'HIND'
					cUusVar = str (lnHind,12,2)
					lnKogus = 5
				Case upper(left (cVar,4)) = 'KOGU'
					cUusVar = str (llKogus,12,3)
					lnKogus = 6
				Case upper(left (cVar,4)) = 'SUMM'
					cUusVar = str (lnSumma,12,2)
					lnKogus = 6
				Case upper(left (cVar,4)) = 'UHIK'
					cUusVar = rtrim(lcUhik)
					lnKogus = 5
				Case upper(left (cVar,4)) = 'FORM'
					cUusVar = readformula(queryleping.formula, queryleping.id,1)
					lnKogus = 7
			Endcase
			If !empty (cVar) 
				if empty (cUusVar)
					cUusVar = ''
				endif
				tcString = stuff (tcString, lnStart, lnKogus, cUusVar)
			Endif

		Endif
	Endfor
Endif
Return tcString
