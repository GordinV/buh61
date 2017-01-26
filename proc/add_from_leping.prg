Select comAsutusremote
Locate For Id = v_arv.asutusId
tcNumber = '%%'
tcSelgitus = '%%'
tcAsutus = Rtrim(comAsutusremote.nimetus)+'%'
dKpv1 = Date(Year(Date())-10,1,1)
dKpv2 = Date(Year(Date()),12,31)
lError = oDb.Use('curLepingud','qryLepingud')
If !Used ('qryLepingud')
	Messagebox('Viga','Kontrol')
	If config.Debug = 1
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
oDb.Use('queryLeping')
If !Used ('queryLeping') Or Reccount('queryLeping')<1 Or;
		(!Isnull(queryLeping.tahtaeg) And  queryLeping.tahtaeg < Date())
	Return .F.
Endif
Select queryLeping
Scan
	Select comNomRemote
	Locate For Id = queryLeping.nomId And tyyp = 1
	lnKbm_ = 0
	lcKbm = ''
	Do Case
		Case comNomRemote.doklausid = 0
			lnKbm_ = 0.18
			lcKbm =  '18%'
		Case comNomRemote.doklausid = 1
			lnKbm_ = 0
			lcKbm =  '0%'
		Case comNomRemote.doklausid = 2
			lnKbm_ = 0.05
			lcKbm =  '5%'
		Case comNomRemote.doklausid = 3
			lnKbm_ = 0
			lcKbm =  'Vaba'
		Case comNomRemote.doklausid = 4
			lnKbm_ = 0.09
			lcKbm =  '9 %'
		Case comNomRemote.doklausid = 5
			lnKbm_ = 0.20
			lcKbm =  '20 %'
	Endcase

	If Empty (queryLeping.formula)
		If !Empty (queryLeping.Summa)
&& расчет от суммы
			lnSumma = Round(queryLeping.Summa,2)
			lnKbm = Round(lnSumma  - (lnSumma / (1 + lnKbm_)),2)  * Iif (Empty (qryrekv.kbmkood),0,1)* Iif(Empty(queryLeping.kbm),0,1)
			lnKbmta = Round((lnSumma - lnKbm),2)
			lnKogus = Iif(Empty(queryLeping.kogus),1,queryLeping.kogus)
			lnHind = Round(lnKbmta / lnKogus,2)
		Else
			lnHind = queryLeping.hind
			lnKogus = queryLeping.kogus
			lnKbmta = Round(((lnHind - queryLeping.soodus) * lnKogus),2)
			lnKbm = Round(lnKbmta  * lnKbm_,2) * Iif (Empty (qryrekv.kbmkood),0,1)* Iif(Empty(queryLeping.kbm),0,1)
			lnSumma = lnKbm + Round(lnKbmta,2)
		Endif

	Else
		lnKbmta = fround(readformula(queryLeping.formula, queryLeping.Id))
		If lnKbmta > 0
			lnKbm = fround(lnKbmta * lnKbm_) * Iif(Empty(queryLeping.kbm),0,1)
			lnSumma = lnKbmta + lnKbm
			lnHind = lnKbmta
		Else
			lnSumma = 0
			lnKbm = 0
			lnHind = 0
		Endif
	Endif
	If lnSumma - (lnKbm + lnKbmta) <> 0
		lnKbm = lnKbm + lnSumma - (lnKbm + lnKbmta)
	Endif

	Select queryLeping

	If lnSumma <> 0 And !Empty(queryLeping.nomId)
		If !Empty(comNomRemote.tunnusId)
			Select comTunnusRemote
			Seek comNomRemote.tunnusId
			lcTunnus = comTunnusRemote.kood
		Else
			lcTunnus = ''
		Endif





		Select v_arvread


		Insert Into v_arvread (kood, nomId, kogus, hind, soodus, kbm, Summa, kbmta,;
			konto, tp, kood1, kood2, kood3, kood4, kood5, tunnus, km);
			values (comNomRemote.kood,queryLeping.nomId, lnKogus, lnHind,;
			queryLeping.soodus, lnKbm, lnSumma, lnKbmta, comNomRemote.konto,;
			comAsutusremote.tp, comNomRemote.kood1, comNomRemote.kood2, comNomRemote.kood3,;
			comNomRemote.kood4, comNomRemote.kood5, lcTunnus, lcKbm)

		Select v_arvread
		lcMuud = convert_muud (Iif (Isnull(queryLeping.muud),Space(1),queryLeping.muud))
		Replace muud With lcMuud In v_arvread
	Endif
Endscan
Select v_arvread
Sum (v_arvread.kbmta - v_arvread.soodus) To lnKbmta
Sum kbm To lnKbm
Sum Summa To lnSumma
Replace v_arv.kbmta With fround(lnKbmta),;
	v_arv.kbm With fround(lnKbm),;
	v_arv.Summa With fround(lnSumma) In v_arv
Use In queryLeping


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
	lnSumma = v_arvread.Summa
	lcUhik = Rtrim(v_arvread.uhik)

	If Len(tcString) > 1
		nKogus = Occurs('?',tcString)
		For i = 1 To nKogus
			lnStart = Atc('?',tcString, 1)
			If lnStart > 0
				lnKogus = 4
				cVar = Substr (tcString,lnStart+1,lnKogus)
				Do Case
					Case Upper(Left (cVar,3)) = 'KUU'
						cUusVar = Str(Month(Date()),2)+'/'+Str(Year(Date()),4)+' a.'
						lnKogus = 4
					Case Upper(Left (cVar,4)) = 'HIND'
						cUusVar = Str (lnHind,12,2)
						lnKogus = 5
					Case Upper(Left (cVar,4)) = 'KOGU'
						cUusVar = Str (llKogus,12,3)
						lnKogus = 6
					Case Upper(Left (cVar,4)) = 'SUMM'
						cUusVar = Str (lnSumma,12,2)
						lnKogus = 6
					Case Upper(Left (cVar,4)) = 'UHIK'
						cUusVar = Rtrim(lcUhik)
						lnKogus = 5
					Case Upper(Left (cVar,4)) = 'FORM'
						cUusVar = readformula(queryLeping.formula, queryLeping.Id,1)
						lnKogus = 7
				Endcase
				If !Empty (cVar)
					If Empty (cUusVar)
						cUusVar = ''
					Endif
					tcString = Stuff (tcString, lnStart, lnKogus, cUusVar)
				Endif

			Endif
		Endfor
	Endif
	Return tcString

