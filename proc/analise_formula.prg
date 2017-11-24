Parameter tString, tdKpv, tcCursor
Local lcString, lSD, lSK, lKD, lKK, lbr_left, lbr_right, lcMath, lcBitCurrent, lcBitPrev, lcBit, lcparam, lcFunc, lnSaldo,;
	lcalias, lnrecno
lcalias = Alias()
lnrecno = Recno()
If Empty (tdKpv)
	tdKpv = Date()
Endif
tcString = tString
lnSaldo = 0
lcparam = ''
lcFunc = ''
lcBit = ''
lcBitPrev = ''
lcBitCurrent = ''
lcString = ''
lcMath = '+-*/'
glError = .F.
If Empty (tcCursor)
	tcCursor = ''
Endif
If !Empty (tcString) And Vartype (tcString) = 'C'
	If Atc ('?',tcString) > 0
		=Remove_macro()
	Endif
	For i = 1 To Len (Ltrim(Rtrim(tcString)))
		lcBit = Substr (tcString,i,1)
		Do Case
			Case  Isalpha (lcBit)
&& Characher expr - func name
				lcBitPrev = lcBitCurrent
				lcBitCurrent = lcBit
			Case  lcBit = '('
&& Start funct
				lcparam = "date ("+Str (Year(tdKpv),4)+","+Str (Month(tdKpv),2)+","+Str (Day(tdKpv),2)+"),'"+tcCursor+"'"
				If Len(lcBitPrev + lcBitCurrent) = 2
					lcFunc = Upper(lcBitPrev + lcBitCurrent)
				Endif
				lcBit = lcBit + "'"
				lcBitCurrent = ''
				lbr_left = .T.
			Case  lcBit = ')'
&& Finish funct
				lcBit =  "',"+lcparam+lcBit
				lcparam = ''
				lcBitCurrent = ''
				lbr_left = .F.
				lbr_right = .T.
			Case  lcBit = ','
&& второй параметер
				lcBit = "','"
		Endcase
		lcString = lcString + lcBit
	Endfor
Endif
If !Empty (lcString)
	lnSaldo = Evaluate (lcString)
Endif
If !Empty (lcalias) And Used (lcalias)
	Select (lcalias)
	If !Empty (lnrecno) And Reccount (lcalias) >= lnrecno
		Go lnrecno
	Endif
Endif
Return lnSaldo

Function Remove_macro
	nOcur = Occurs ('?',tcString)
	For i = 1 To nOcur
		lnstart = Atc('?',tcString)
		lnWidth = width_of_macro(lnstart)
		lcMacro=Substr(tcString, lnstart,lnWidth)
		tcString=Stuff(tcString, lnstart, lnWidth, get_macro_value(lcMacro))
	Endfor
	Return

Function get_macro_value
	Parameter tcExpr
	Local cMacroResult, lcCursor, lnstart, nKomma, lcField
	lcField = ''
	cMacroResult = '0'
	Do Case
		Case '=' $ tcExpr
&& сложное выражение
			If Left(tcExpr,1) = '?'
				tcExpr = Stuff (tcExpr,1,1,'')
			Endif
			lnstart = At ('=',tcExpr)
			If lnstart = 0
				Return cMacroResult
			Endif
			lcCursor = Left (tcExpr,lnstart-1)
			nKomma = At(',',tcExpr)
			If nKomma > 0
				lcField = Right (tcExpr, Len (tcExpr)-nKomma)
			Endif
			lcvalue = Substr (tcExpr,lnstart+1,nKomma-(lnstart+1))
			If At ('.',lcCursor) = 0
&& имя курсора не задано
				lcCursor = Alias()+'.'+lcCursor
			Endif
			If !Used (Juststem(lcCursor))
&& курсор не найден (ошибка в формуле)
				Return cMacroResult
			Endif
			Select (Juststem(lcCursor))
			lcString = 'locate for '+lcCursor+' = '+lcvalue
			&lcString
			If Found () And !Empty (lcField)
				cString = 'vartype('+lcField+')'
				lcType = Evaluate (cString)
				cMacroResult = get_macro_stringvalue (&lcField,lcType)
			Endif
		Otherwise
&& переменная
			cString = 'vartype ('+tcExpr+')'
			lcType = Evaluate (cString)
			cMacroResult = get_macro_stringvalue (&tcExpr,lcType)
	Endcase
	Return cMacroResult

Function get_macro_stringvalue
	Parameter lcvalue, cType
	Do Case
		Case cType = 'I'
			If Isnull(lcvalue)
				lcvalue = 0
			Endif
			lcvalue = Ltrim(Str(lcvalue))
		Case cType = 'N' Or cType = 'Y'
			If Isnull(lcvalue)
				lcvalue = 0
			Endif
			lnWidth = 14
			lnDec = 4
			lcvalue = Ltrim(Str(lcvalue,lnWidth,lnDec))
		Case cType = 'F'
			If Isnull(lcvalue)
				lcvalue = 0
			Endif
			lnWidth = 18
			lnDec = 6
			lcvalue = Ltrim(Str(lcvalue,lnWidth,lnDec))
		Case cType = 'C'
			If Isnull(lcvalue)
				lcvalue = ''
			Endif
			lcvalue = "'"+Ltrim(Rtrim(lcvalue))+"'"
		Case cType = 'M'
			If Isnull(lcvalue)
				lcvalue = ''
			Endif
			lcvalue = "'"+Ltrim(Rtrim(lcvalue))+"'"
		Case cType = 'L'
			If Isnull(lcvalue)
				lcvalue = .F.
			Endif
			lcvalue = Iif(lcvalue = .T.,'.T.','.F.')
		Case cType = 'D'
			If Isnull(lcvalue)
				lcvalue = {}
			Endif
			If gVersia = 'VFP'
				lcvalue = "ctod('"+Dtoc(lcvalue)+"')"
			Else
				lcvalue = "'"+Dtoc(lcvalue,1)+"'"
			Endif
		Case cType = 'G'
		Case cType = 'T'
			If Isnull(lcvalue)
				lcvalue = {}
			Endif
			If gVersia = 'VFP'
				lcvalue = "ctot('"+Dtoc(lcvalue)+"')"
			Else
				Do Case
					Case Vartype (lcvalue) = 'T'
						lcvalue = "'"+Dtoc(Ttod(lcvalue),1)+"'"
					Case Vartype (lcvalue) = 'D'
						lcvalue = "'"+Dtoc(lcvalue,1)+"'"
				Endcase
			Endif
		Otherwise
			lcvalue = '0'
	Endcase
	Return lcvalue

Function width_of_macro
	Parameter tnStart
	Local lEndOfMacro, lcBit, lcMacro, lnWidth, lcKontrolString
	lnWidth = 0
	lcBit = ''
	lcKontrolString = '+-*/)'
	Do While !lEndOfMacro
		lcBit = Substr (tcString,tnStart,1)
		If lcBit $ lcKontrolString
			lEndOfMacro = .T.
			Exit
		Else
			tnStart = tnStart + 1
			lnWidth = lnWidth + 1
		Endif
		If Len (tcString) = tnStart
			lnWidth = lnWidth + 1
			lEndOfMacro = .T.
		Endif
	Enddo
	Return lnWidth

Function getSaldo
	Parameter tcKonto, tdKpv, tcCursor
	Local lSaldo, lOpt
	lSaldo = 0
	lcKonto = tcKonto
	If Empty(tcCursor) Or !Used(tcCursor)
&& выборка сальдо по одному счету
		tcCursor = 'qrySaldo'
		tcKonto = Ltrim(Rtrim(tcKonto))+'%'
		tnAsutusId1 = 0
		tnAsutusId2 = 99999999
		tdKpv1 = Date(1999,1,1)
		tdKpv2 = tdKpv
		oDb.Use ('qrySaldo1',tcCursor)
*!*			lError = oDb.Exec ("sp_saldo1 ",Str(gRekv)+",1,'"+ DTOC(tdKpv,1)+",'"+;
*!*				DTOC(tdKpv,1)+"','"+cKonto+"%'",tcCursor)
		lOpt = .T.
	Endif
	Select (tcCursor)
	If Reccount (tcCursor) > 0
		Select (tcCursor)
		Scan For Left(Alltrim(Evaluate (tcCursor+'.konto')),Len(Alltrim(lcKonto))) == Alltrim(lcKonto)
			lSaldo = lSaldo + Evaluate(tcCursor+'.deebet')-Evaluate (tcCursor+'.kreedit')
		Endscan
	Endif
	Return lSaldo

Function getkaibed
	Parameter tcKonto, tcOpt, tnAsutusId
	lnKaibed = 0
	tnAsutusId = Iif(Vartype(tnAsutusId)='C',Val(Alltrim(tnAsutusId)),tnAsutusId)
	tdKpv1 = fltrAruanne.kpv1
	tdKpv2 = fltrAruanne.kpv2
*	tnAsutusid = IIF(EMPTY(tnAsutusId),'0',ALLTRIM(STR(tnAsutusid)))
	If Empty(tnAsutusId)
		tnAsutusId1 = 0
		tnAsutusId2 = 999999999
	Else
		tnAsutusId1 = tnAsutusId
		tnAsutusId2 = tnAsutusId
	Endif

	If Empty(tcCursor) Or !Used(tcCursor)
&& выборка сальдо по одному счету
		tcCursor = 'qryKaibed'
		cKonto = Ltrim(Rtrim(tcKonto))+'%'
*!*			lError = oDb.Exec ("sp_saldo1 ",Str(gRekv)+",2,'"+ DTOC(dKpv1,1)+"','"+;
*!*				DTOC(dKpv2,1)+"','"+cKonto+"%',"+tnAsutusId,tcCursor)
		oDb.Use ('qrysaldo1',tcCursor)
		lOpt = .T.
	Endif
	Select (tcCursor)
	If Reccount (tcCursor) > 0
		Select (tcCursor)
		Scan For Left(Alltrim(Evaluate (tcCursor+'.konto')),Len(Alltrim(tcKonto))) == Alltrim(tcKonto)
			lnKaibed = lnKaibed + Iif(tcOpt = 'D',Evaluate(tcCursor+'.deebet'),Evaluate (tcCursor+'.kreedit'))
		Endscan
	Endif
	Return lnKaibed

Function TSD
	Parameter tcKontogrupp, tnTunnusId, tdKpv, tcCursor
* возвращает сальдо по признаку

	Local lnSaldo
	lnSaldo = 0
	If Vartype(tnTunnusId) = 'C'
		tnTunnusId = Val(Alltrim(tnTunnusId))
	Endif
	If Empty (tcCursor) Or !Used (tcCursor)
*!*			If Empty (tcCursor)
*!*				tcCursor = Sys(2015)
*!*			ENDIF
*!*			TcKonto = Ltrim(Rtrim(tcKontogrupp))+'%'
*!*			tnTunnusId1 = tnTunnusId
*!*			tnTunnusId2 = tnTunnusId
*!*			tdKpv1 = DATE(1999,1,1)
*!*			tdKpv2 = tdKpv
*!*			oDb.use ('qrySaldo3',tcCursor)

*!*			lError = oDb.Exec ("sp_saldo1 ",Str(gRekv)+",1, '"+DTOC(tdkpv,1)+"','"+;
*!*				 Dtoc(tdkpv,1)+"','"+tcKontogrupp+"%',"+ALLTRIM(STR(tnAsutusId)),tcCursor)
		lError = oDb.Exec("TSD ","'"+tcKontogrupp+"',"+Str(tnTunnusId)+","+Str(grekv)+', DATE('+Str(Year(tdKpv),4)+','+;
			STR(Month(tdKpv),2)+','+Str(Day(tdKpv),2)+')','qrySd')
		If lError = .T.
			lnSaldo = qrySd.TSD
			Use In qrySd
		Endif


	Else
		If !Empty (tcKontogrupp)
			lnSaldo = getSaldo (tcKontogrupp,tdKpv, tcCursor)
		Endif
	Endif
	Return lnSaldo

Function TSK
	Lparameter tcKontogrupp, tnTunnusId, tdKpv, tcCursor
	Local lnSaldo
* возвращает сальдо по признаку
	lnSaldo = 0
	lnSaldo = TSD(tcKontogrupp, tnTunnusId, tdKpv, tcCursor ) * -1
	Return lnSaldo


Function DJ
	Parameter tcNumber
	Local lnSaldo, lUsed
	lnSaldo = 0
	tcCursor = Sys(2015)
	lnstart = At(',',tcKontogrupp)
	If lnstart = 0
		Return 0
	Endif
	oDb.Use ('VALIDATEARVE')
	If Reccount('VALIDATEARVE') < 1 Or Empty(VALIDATEARVE.Id)
		Return 0
	Endif
	tnid = 	VALIDATEARVE.Id
	oDb.Use('v_arv',tcCursor)
	lnSaldo = Evaluate(tcCursor+'.jaak')
	Use In VALIDATEARVE
	Use In (tcCursor)
	Return lnSaldo



Function L
	Parameter tcKonto1, tcKonto2, tdKpv, tcCursor
	Local lnSaldo, lUsed
	lnSaldo = 0
	tcCursor = Sys(2015)
*!*		lnstart = At(',',tcKontogrupp)
*!*		If lnstart = 0
*!*			Return 0
*!*		Endif
*!*		cdeebet = Trim(Left(tcKontogrupp,lnstart-1))+'%'
*!*		ckreedit = Trim(Substr(tcKontogrupp,lnstart+1,20))+'%'

	* lisatud 02/02/2005
	
	cdeebet = tcKonto1+'%'
	ckreedit = tcKonto2+'%'

	dkpv1 = fltrAruanne.kpv1
	dkpv2 = fltrAruanne.kpv2
	nsumma1 = -999999999
	nsumma2 = 999999999
	tcTpd = '%'
	tcTpK = '%'
	cDok = '%'
	cselg = '%'
	casutus = '%'
	tcAllikas = '%'
	tcTegev = '%'
	tcArtikkel = '%'
	tcObjekt = '%'
	tcEelAllikas = '%'
	tcTunnus = '%'
	tcKasutaja = '%'
	tcMuud = '%'
	tcKood1 = '%'
	tcKood2 = '%'
	tcKood3 = '%'
	tcKood4 = '%'
	tcKood5 = '%'
	oDb.Use ('curJournal',tcCursor)
	Select (tcCursor)
	Sum Summa To lnSaldo
	Use In (tcCursor)
	Return lnSaldo


Function DK
	Parameter tcKontogrupp, tdKpv, tcCursor
	Local lnSaldo
	lnSaldo = 0
	If !Empty (tcKontogrupp)
		lnSaldo = getkaibed (tcKontogrupp,'D',0)
	Endif
	Return lnSaldo

Function KK
	Parameter tcKontogrupp, tdKpv, tcCursor
	Local lnSaldo
	lnSaldo = 0
	If !Empty (tcKontogrupp)
		lnSaldo = getkaibed (tcKontogrupp,'K',0)
	Endif
	Return lnSaldo

Function ADK
	Parameter tcKontogrupp, tnAsutusId, tdKpv, tcCursor
	Local lnKaibed
	lnKaibed = 0
	If Vartype(tnAsutusId) = 'C'
		tnAsutusId = Val(Alltrim(tnAsutusId))
	Endif
	If !Empty (tcKontogrupp) And !Empty(tnAsutusId)
		lnKaibed = getkaibed (tcKontogrupp,'D',tnAsutusId)
	Endif
	Return lnKaibed

Function AKK
	Parameter tcKontogrupp, tnAsutusId, tdKpv, tcCursor
	Local lnKaibed
	lnKaibed = 0
	If Vartype(tnAsutusId) = 'C'
		tnAsutusId = Val(Alltrim(tnAsutusId))
	Endif
	If !Empty (tcKontogrupp) And !Empty(tnAsutusId)
		lnKaibed = getkaibed (tcKontogrupp,'K',tnAsutusId)
	Endif
	Return lnKaibed

Function ASD
	Parameter tcKontogrupp, tnAsutusId, tdKpv, tcCursor

	Local lnSaldo
	lnSaldo = 0
	If Vartype(tnAsutusId) = 'C'
		tnAsutusId = Val(Alltrim(tnAsutusId))
	Endif
	If Empty (tcCursor) Or !Used (tcCursor) OR VARTYPE(tcCursor) <> 'C'
*!*			If Empty (tcCursor)
*!*				tcCursor = Sys(2015)
*!*			ENDIF
*!*			TcKonto = Ltrim(Rtrim(tcKontogrupp))+'%'
*!*			tnAsutusId1 = tnAsutusId
*!*			tnAsutusId2 = tnAsutusId
*!*			tdKpv1 = DATE(1999,1,1)
*!*			tdKpv2 = tdKpv
*!*			oDb.use ('qrySaldo2',tcCursor)

*!*			lError = oDb.Exec ("sp_saldo1 ",Str(gRekv)+",1, '"+DTOC(tdkpv,1)+"','"+;
*!*				 Dtoc(tdkpv,1)+"','"+tcKontogrupp+"%',"+ALLTRIM(STR(tnAsutusId)),tcCursor)

		lError = oDb.Exec("ASD ","'"+tcKontogrupp+"',"+Str(tnAsutusId)+","+Str(grekv)+', DATE('+Str(Year(tdKpv),4)+','+;
			STR(Month(tdKpv),2)+','+Str(Day(tdKpv),2)+')','qrySd')
		If lError = .T.
			lnSaldo = qrySd.ASD
			Use In qrySd
		Endif

	Else
		If !Empty (tcKontogrupp)
			lnSaldo = getSaldo (tcKontogrupp,tdKpv, tcCursor)
		Endif
	Endif
	Return lnSaldo

Function ASK
	Lparameter tcKontogrupp, tnAsutusId, tdKpv, tcCursor
	Local lnSaldo
	lnSaldo = 0
	lnSaldo = ASD(tcKontogrupp, tnAsutusId, tdKpv, tcCursor ) * -1
	Return lnSaldo

Function SD
	Parameter tcKontogrupp, tdKpv, tcCursor
	Local lnSaldo, lnAlg, lnDb, lnKr
	lnSaldo = 0
	If Empty (tcCursor) Or !Used (tcCursor)
*!*			If Empty (tcCursor)
*!*				tcCursor = Sys(2015)
*!*			ENDIF
*!*			TcKonto = Ltrim(Rtrim(tcKontogrupp))+'%'
*!*			tnAsutusId1 = 0
*!*			tnAsutusId2 = 999999999
*!*			tdKpv1 = DATE(1999,1,1)
*!*			tdKpv2 = tdKpv
*!*			oDb.use ('qrySaldo1',tcCursor)
		If gVersia <> 'VFP'
*		SET STEP ON 
			IF !USED('fltrAruanne') or fltrAruanne.kond = 0
				lError = oDb.Exec("SD ","'"+tcKontogrupp+"',"+Str(grekv)+', DATE('+Str(Year(tdKpv),4)+','+;
					STR(Month(tdKpv),2)+','+Str(Day(tdKpv),2)+')','qrySd')
			ELSE
				lError = oDb.Exec("SD ","'"+tcKontogrupp+"',"+Str(grekv)+', DATE('+Str(Year(tdKpv),4)+','+;
					STR(Month(tdKpv),2)+','+Str(Day(tdKpv),2)+'),'+IIF(fltrAruanne.kond = 1,'3','9'),'qrySd')
			
			ENDIF
			

		Else
*	-- arv algsaldo
			Select Sum(algsaldo) As Summa From Library L inner Join kontoinf k On L.Id = k.parentId ;
				where k.rekvId = grekv And L.kood Like Ltrim(Rtrim(tcKontogrupp))+'%';
				INTO Cursor qryAlgS

*	-- arv. deebet kaibed
			Select Sum(Summa) As Summa From journal1 ;
				where deebet Like Ltrim(Rtrim(tcKontogrupp))+'%';
				and parentId In (Select Id From journal Where rekvId = grekv And kpv <= tdKpv);
				INTO Cursor qryDbK

*	-- arv. kreedit kaibed
			Select Sum(Summa) As Summa From journal1 ;
				where kreedit Like Ltrim(Rtrim(tcKontogrupp))+'%';
				and parentId In (Select Id From journal Where rekvId = grekv And kpv <= tdKpv);
				INTO Cursor qryKrK
			lnAlg = qryAlgS.Summa
			lnDb = qryDbK.Summa
			lnKr = qryKrK.Summa
			Use In qryAlgS
			Use In qryDbK
			Use In qryKrK
			Return lnAlg + lnDb - lnKr

		Endif


		If lError = .T.
			lnSaldo = qrySd.SD
			Use In qrySd
		Endif
	Else
		If !Empty (tcKontogrupp)
			lnSaldo = getSaldo (tcKontogrupp,tdKpv, tcCursor)
		Endif
	Endif

	Return lnSaldo

Function SK
	Lparameter tcKontogrupp, tdKpv, tcCursor
	Local lnSaldo
	lnSaldo = 0
	lnSaldo = SD(tcKontogrupp, tdKpv, tcCursor ) * -1
	Return lnSaldo

