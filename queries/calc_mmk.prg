LPARAMETERS tnFormaat

Local lnError, lerror
lnError = 1
=run_query()
cFail = 'c:\temp\buh60\EDOK\mmk.txt'
If !Directory('c:\temp\buh60\EDOK')
	Mkdir c:\temp\buh60\EDOK
Endif
cFailbak = 'c:\temp\buh60\EDOK\'+Alltrim(Str(grekv))+'mmk'+Sys(2015)+'.bak'
If File (cFailbak)
	Erase (cFailbak)
Endif
If File(cFail)
	Rename (cFail) To (cFailbak)
Endif
Select comAaremote
If Empty(v_mk.aaid)
	If Reccount('comAaremote') > 0
		Locate For default_ = 1
	Endif
Else
	Locate For Id = v_mk.aaid
Endif

lcPank = Alltrim(Str(comAaremote.pank))
lcAa = comAaremote.Arve
Select mk_report1
Do case
	Case (lcPank = '767' Or lcPank = '720' OR lcPank = '689') AND !ISNULL(tnFormaat) AND !EMPTY(tnFormaat)
		WAIT WINDOW 'Eksport (TH6)' nowait
		lerror=hansapank_TH6()
*		WAIT WINDOW CLEAR 
	Case (lcPank = '767' Or lcPank = '720' OR lcPank = '689' ) AND (ISNULL(tnFormaat) OR EMPTY(tnFormaat))
		WAIT WINDOW 'Eksport (TH5)' nowait
		lerror=hansapank()
*		WAIT WINDOW CLEAR 
	Case lcPank = '401'
		lerror=uhispank()
Endcase
Return lerror


Function uhispank
	lcSelg = ''

	cFail = 'c:\temp\buh60\EDOK\mmk.txt'
	cFailbak = 'c:\temp\buh60\EDOK\'+Alltrim(Str(grekv))+'mmk'+Sys(2015)+'.bak'
	If File (cFailbak)
		Erase (cFailbak)
	Endif
	If File(cFail)
		Rename (cFail) To (cFailbak)
	Endif
	lnhandle = Fcreate(cFail)
	If lnhandle < 0
		Return .F.
	Endif
	lnError = 1
	Select mk_report1
	lcSelg = ''
	For i = 1 To Memlines(mk_report1.selg)
		lcSelg = lcSelg + Iif(!Empty(Mline(mk_report1.selg,i)),Trim(Mline(mk_report1.selg,i))+Chr(13),'')
	Endfor
	lnError=Fputs(lnhandle,':0::'+'**M5')
	lnError=Fputs(lnhandle,':1::'+Left(Ltrim(Rtrim(mk_report1.Number)),8))
	lnError=Fputs(lnhandle,':2::'+Str(Round(mk_report1.kokku * 100,0)))
	lnError=Fputs(lnhandle,':3::'+ALLTRIM(mk_report1.valuuta))
	lnError=Fputs(lnhandle,':4::'+lcSelg)
	lnError=Fputs(lnhandle,':5::'+Left(Ltrim(Rtrim(mk_report1.viitenr)),20))
	lnError=Fputs(lnhandle,':6::'+lcAa)
	lnError=Fputs(lnhandle,':12::'+Str(Year(mk_report1.maksepaev),4)+Iif(Month(mk_report1.maksepaev)< 10,'0','')+;
		ALLTRIM(Str(Month(mk_report1.maksepaev),2))+;
		IIF(Day(mk_report1.maksepaev)< 10,'0','')+Alltrim(Str(Day(mk_report1.maksepaev),2)))
	lnError=Fputs(lnhandle,':23::'+Left(Ltrim(Rtrim(mk_report1.viitenr)),20))
	lnError=Fputs(lnhandle,':26::')
	lnError=Fputs(lnhandle,':27::'+'J')
	Scan

		lnError=Fputs(lnhandle,':28::'+Alltrim(Left(mk_report1.aa,20))+';'+Alltrim(Left(Ltrim(Rtrim(mk_report1.asutus)),50))+';'+Alltrim(Str(Round(mk_report1.Summa * 100,0))))
		If lnError = 0
			Exit
		Endif
	Endscan
	=Fclose (lnhandle)
	If lnError = 0
		Return .F.
	Else
		Return .T.
	Endif


Endproc

Function hansapank_TH6
	Create Cursor mmk (mmk m)
	Append Blank

	Create Cursor mmk_pais (tunnus c(4) Default 'MM  ', kirjetunnus c(4) Default '0000',;
		aa c(20) Default lcAa, dokkpv c(6), maksekpv c(6), selg c(140), ;
		number c(5) Default Left(Ltrim(Rtrim(mk_report1.Number)),5),;
		makseId c(8) Default Left(Ltrim(Rtrim(mk_report1.Number)),8), valuuta c(3) Default ALLTRIM(mk_report1.valuuta))
		
		
		
		

	Create Cursor mmk_tmp (tunnus c(4) Default 'MM  ', kirjetunnus c(4),;
		pank N(3) Default Val(Trim(mk_report1.pank)), aa c(20) Default mk_report1.aa,;
		saaja c(30) Default Left(Ltrim(Rtrim(mk_report1.asutus)),30),;
		summa C(12,0) Default ALLTRIM(STR(Round(mk_report1.Summa * 100,0))),;
		number c(5) Default Left(Ltrim(Rtrim(mk_report1.Number)),5),;
		viitenr c(35) Default Left(Ltrim(Rtrim(mk_report1.viitenr)),35))

	Create Cursor mmk_jalg (tunnus c(4) Default 'MM  ', kirjetunnus c(4) Default '9999',;
		vaba c(45), maksarv c(4), kokku C(12,0))

	lcKpv = Right(Str(Year(mk_report1.kpv),4),2)+;
		IIF(Month(mk_report1.kpv) < 10,'0','')+Alltrim(Str(Month(mk_report1.kpv),2))+;
		IIF(Day(mk_report1.kpv) < 10,'0','')+ Alltrim(Str(Day(mk_report1.kpv),2))

	lcMakseKpv = Right(Str(Year(mk_report1.maksepaev),4),2)+;
		IIF(Month(mk_report1.maksepaev) < 10,'0','')+Alltrim(Str(Month(mk_report1.maksepaev),2))+;
		IIF(Day(mk_report1.maksepaev) < 10,'0','')+ Alltrim(Str(Day(mk_report1.maksepaev),2))


	Insert Into mmk_pais (dokkpv, maksekpv, selg) Values (lcKpv, lcMakseKpv, Trim(Mline(mk_report1.selg,1)));

	Select mk_report1
	lnCount = 0
	lnSumma = 0
	Scan
		lnCount = lnCount + 1
		lcSpace = '0000'
		lcKirinr = left(lcSpace,4 - Len(Alltrim(Str(lnCount,4))))+Alltrim(Str(lnCount,4))
		Select mmk_tmp
		Append Blank
		Replace  kirjetunnus With lcKirinr In mmk_tmp
		lnSumma = lnSumma + Round(mk_report1.Summa * 100,0)
	Endscan
	lcCount = left('0000',4 - LEN(ALLTRIM(STR(lnCount,4))))+ALLTRIM(STR(lnCount,4))
	
	Insert Into mmk_jalg (maksarv, kokku) Values (lcCount,ALLTRIM(STR(lnSumma)) )
	Select mmk_pais
	Copy To mmkpais Type Sdf As 1250
	Select mmk_tmp
	Copy To mmktmp Type Sdf As 1250
	Select mmk_jalg
	Copy To mmkjalg Type Sdf As 1250

	Select mmk
	Append Memo mmk From mmkpais.txt
	Append Memo mmk From mmktmp.txt
	Append Memo mmk From mmkjalg.txt
	Copy Memo mmk To (cFail) As 1250

*!*		cString = "copy to "+cFail + " type sdf "
*!*		&cString
	Use In mmk_tmp
	Use In mmk_pais
	Use In mmk_jalg
	Use In mmk
	Use In mk_report1
	If !File (cFail)
		Return .F.
	Else
		Return .T.
	Endif
Endproc



Function hansapank
	Create Cursor mmk (mmk m)
	Append Blank

	Create Cursor mmk_pais (tunnus c(4) Default 'MM  ', kirjetunnus c(4) Default '0000',;
		aa c(16) Default lcAa, dokkpv c(6), maksekpv c(6), selg c(70), ;
		number c(5) Default Left(Ltrim(Rtrim(mk_report1.Number)),5),;
		makseId c(8) Default Left(Ltrim(Rtrim(mk_report1.Number)),8), valuuta c(3) Default ALLTRIM(mk_report1.valuuta))
		
		
		
		

	Create Cursor mmk_tmp (tunnus c(4) Default 'MM  ', kirjetunnus c(4),;
		pank N(3) Default Val(Trim(mk_report1.pank)), aa c(16) Default mk_report1.aa,;
		saaja c(30) Default Left(Ltrim(Rtrim(mk_report1.asutus)),30),;
		summa N(12,0) Default Round(mk_report1.Summa * 100,0),;
		number c(5) Default Left(Ltrim(Rtrim(mk_report1.Number)),5),;
		viitenr c(20) Default Left(Ltrim(Rtrim(mk_report1.viitenr)),20))

	Create Cursor mmk_jalg (tunnus c(4) Default 'MM  ', kirjetunnus c(4) Default '9999',;
		vaba c(45), maksarv c(4), kokku N(12,0))

	lcKpv = Right(Str(Year(mk_report1.kpv),4),2)+;
		IIF(Month(mk_report1.kpv) < 10,'0','')+Alltrim(Str(Month(mk_report1.kpv),2))+;
		IIF(Day(mk_report1.kpv) < 10,'0','')+ Alltrim(Str(Day(mk_report1.kpv),2))

	lcMakseKpv = Right(Str(Year(mk_report1.maksepaev),4),2)+;
		IIF(Month(mk_report1.maksepaev) < 10,'0','')+Alltrim(Str(Month(mk_report1.maksepaev),2))+;
		IIF(Day(mk_report1.maksepaev) < 10,'0','')+ Alltrim(Str(Day(mk_report1.maksepaev),2))


	Insert Into mmk_pais (dokkpv, maksekpv, selg) Values (lcKpv, lcMakseKpv, Trim(Mline(mk_report1.selg,1)));

	Select mk_report1
	lnCount = 0
	lnSumma = 0
	Scan
		lnCount = lnCount + 1
		lcSpace = '0000'
		lcKirinr = Left(lcSpace,Len(Alltrim(Str(lnCount,4))))+Alltrim(Str(lnCount,4))
		Select mmk_tmp
		Append Blank
		Replace  kirjetunnus With lcKirinr In mmk_tmp
		lnSumma = lnSumma + Round(mk_report1.Summa * 100,0)
	Endscan

	Insert Into mmk_jalg (maksarv, kokku) Values (Str(lnCount,4),lnSumma )
	Select mmk_pais
	Copy To mmkpais Type Sdf As 1250
	Select mmk_tmp
	Copy To mmktmp Type Sdf As 1250
	Select mmk_jalg
	Copy To mmkjalg Type Sdf As 1250

	Select mmk
	Append Memo mmk From mmkpais.txt
	Append Memo mmk From mmktmp.txt
	Append Memo mmk From mmkjalg.txt
	Copy Memo mmk To (cFail) As 1250

*!*		cString = "copy to "+cFail + " type sdf "
*!*		&cString
	Use In mmk_tmp
	Use In mmk_pais
	Use In mmk_jalg
	Use In mmk
	Use In mk_report1
	If !File (cFail)
		Return .F.
	Else
		Return .T.
	Endif
Endproc


Function run_query
	Parameter tnId
	Local lcFin, lcTulu, lcKulu, lctegev
	If Empty(tnId) And Used('v_mk')
		tnId = v_mk.Id
	Endif
	If Vartype (tnId) = 'C'
		tnId = Val(Alltrim(tnId))
	Endif
	If Empty (tnId) And Used ('curMk')
		tnId = curMk.Id
	Endif
	With oDb
		.Use('v_mk','qryMk')
		.Use('v_mk1','qryMk1')
		Create Cursor mk_report1 (Id Int, kpv d, asutus c(254),maksepaev d, Number c(20),pank c(3), aa c(20),;
			selg m, nimetus c(254), viitenr c(120),kokku Y, Summa Y, fin c(20), tulu c(20),regkood c(11),;
			kulu c(20), tegev c(20), eelallikas c(20), lausnr Int, lausend m, valuuta c(20))
*!*	if !empty (v_mk.journal)
*!*		.use ('v_journalid','QRYJOURNALNUMBER' )
		Select qrymk1
		Scan

			Select comNomRemote
			Locate For Id = qrymk1.nomid
			Select comAsutusRemote
			Locate For Id = qrymk1.asutusid
			Insert Into mk_report1 (kpv, asutus,regkood, maksepaev, Number, pank, aa, selg, nimetus, viitenr, Summa, valuuta);
				values (qryMk.kpv, comAsutusRemote.nimetus,comAsutusRemote.regkood, qryMk.maksepaev, qryMk.Number, qrymk1.pank, qrymk1.aa, qryMk.selg,;
				comNomRemote.nimetus, qryMk.viitenr, qrymk1.Summa, qrymk1.valuuta)
		Endscan
		Select qrymk1
		Sum Summa To lnKokku
		Use In qrymk1
		Use In qryMk
		Update mk_report1 Set kokku = lnKokku

	Endwith

	Select mk_report1
Endfunc
