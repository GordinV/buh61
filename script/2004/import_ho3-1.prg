Local lError
Clear All

*lcFile1 = 'c:\avpsoft\haridus\pank01.dbf'
*lcFile1 = 'c:\avpsoft\haridus\pank02.dbf'
lcFile1 = 'c:\avpsoft\haridus\har1.dbf'
lcFile2= 'c:\avpsoft\haridus\har3.dbf'
*lcFile2 = 'c:\avpsoft\files\buh60\temp\haridus\tp2004.dbf'
*!*	If !File(lcFile1)
*!*		Messagebox('Viga, failid ei leidnud')
*!*		lError = .T.
*!*	Endif
Use (lcFile1) In 0 Alias qryHO
Use (lcFile2) In 0 Alias qryAsutus
*Use (lcFile2) In 0 Alias asutused Excl

*!*	Select Val(Alltrim(lausend.n11)) As asutusId, Val(Alltrim(asutused.n1)) As Id, asutused.n5 As nimetus, asutused.n6 As regkood, ;
*!*		lausend.* From lausend Left Outer Join asutused On Val(Alltrim(asutused.n1)) = lausend.asutusId;
*!*		INTO Cursor qryHO
*!*	SET STEP ON
*!*	scan
*!*		lcSumma = transdigit(ltrim(RTRIM(qryHo.n9)))
*!*	ENDSCAN
*!*	return
*ON ERROR f_error_handling()
gnHandle = SQLConnect('narvalvpg','vlad','490710')
If gnHandle < 1
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif

=SQLEXEC(gnHandle,'begin work')


lnSumma = 0
lnrec = 0

Select Distinct Str(konto) As konto From qryHO Into Cursor qryKonto

Set Step On

lError = .F.
Select qryKonto
Scan
	lnKontoid = 0
	lnKontoTyyp = 0

	lcString = "select id, tun5 from library where library = 'KONTOD' and kood = '"+Alltrim(qryKonto.konto)+"'"
	lnresult = SQLEXEC(gnHandle,lcString, 'qryId')
	If lnresult < 1 Or Reccount('qryid') <  1
		lError = .T.
		Set Step On
		Exit
	Endif
	lnKontoid = qryid.Id
	lnKontoTyyp = 1
	Use In qryid

	* chek value
		Select qryHO
		Sum Summ FOR ((konto)) = VAL(qryKonto.konto) To lnSummaKokku
		lcSummaKokku = Str(Iif(lnKontoTyyp = 1 Or lnKontoTyyp = 3,1,1) * lnSummaKokku,14,2)



* subkonto

	lnSumma = 0
	Select Sum(Summ) As Summa, n_d_k As asutusId From qryHO Where (konto) = Val(qryKonto.konto) Group By n_d_k Into Cursor qrySubkonto
	Select qrySubkonto
	Scan


* otsime asutus


		lnAsutusId = 0
		Select qryAsutus
		Locate For suppId = qrySubkonto.asutusId
		If Not Found() or Empty(qryAsutus.Descriptio)
			lnAsutusId = 1343
		Else
			Wait Window qryKonto.konto+' subkonto: '+qryAsutus.regn Nowait
			lcregkood = Alltrim(qryAsutus.regn)
			lcString = "select id from asutus where regkood = '"+lcregkood+"'"
			lnresult = SQLEXEC(gnHandle,lcString, 'qryId')
			If lnresult < 1 Or Reccount('qryid') <  1
				lError = .T.
				Set Step On
				Exit
			Endif
			lnAsutusId = qryid.Id
			Use In qryid
		Endif

		If Empty(lnAsutusId) Or Empty(lnKontoid)
			lError = .T.
			Set Step On
			Exit
		Endif

		lcString = " select id from subkonto where rekvid = 11 and kontoId = "+Str(lnKontoid)+" and asutusId = "+Str(lnAsutusId)
		lnresult = SQLEXEC(gnHandle,lcString, 'qryid')
		If lnresult <  1
			lError = .T.
			Set Step On
			Exit
		Endif
		lcSumma = Str(Iif(lnKontoTyyp = 1 Or lnKontoTyyp = 3,1,1) * qrySubkonto.Summa,14,2)

		If Reccount('qryId') < 1
* insert
			lcString = " insert into subkonto (rekvId, algsaldo, kontoId, asutusId) values (11,"+lcSumma+","+;
				STR(lnKontoid)+","+Str(lnAsutusId)+")"
		Else
			lcString = "update subkonto set algsaldo = "+lcSumma+ " where kontoId = "+Str(lnKontoid)+" and asutusId = "+;
				STR(lnAsutusId) + " and rekvId = 11 "

		Endif


		lnresult = SQLEXEC(gnHandle,lcString)
		If lnresult <  1
			lError = .T.
			Set Step On
			Exit
		Endif
		lnSumma = lnSumma + qrySubkonto.Summa
	Endscan
	IF VAL(lcSummaKokku) <> lnSumma
		MESSAGEBOX('Kontrol summa viga')
		lError = .t.
		exit
	endif


* uksus
	If lError = .F.
		lnSummaTunnus= 0
		Select Sum(Summ) As Summa, Str(kood_asutu) As kood From qryHO Where ((konto)) = VAL(qryKonto.konto) AND !EMPTY(kood_asutu) Group By kood_asutu Into Cursor qryKontoinf
		Select qryKontoinf
		SCAN 

			Wait Window qryKonto.konto+' uksus: '+qryKontoinf.kood Nowait

			lcTunnus = IIF(LEN(Alltrim(qryKontoinf.kood)) < 4,'0','')+Alltrim(qryKontoinf.kood)
			lcString = "select id from library where library = 'TUNNUS' and rekvid = 11 and ALLTRIM(kood) = '"+lcTunnus+"'"

			lnresult = SQLEXEC(gnHandle,lcString, 'qryId')
			If lnresult < 1 Or Reccount('qryid') <  1
				lError = .T.
				Set Step On
				Exit
			Endif
			lnKontoinfId = qryid.Id
			Use In qryid

			lcString = " SELECT id FROM tunnusinf WHERE rekvid = 11 and kontoid = "+Str(lnKontoid)+" and tunnusid = "+Str(lnKontoinfId)

			lnresult = SQLEXEC(gnHandle,lcString, 'qryId')
			If lnresult < 1 Or Reccount('qryid') <  1
				lError = .T.
				Set Step On
				Exit
			Endif

		lcSumma = Str(Iif(lnKontoTyyp = 1 Or lnKontoTyyp = 3,1,1) * qryKontoinf.Summa,14,2)

			If  Reccount('qryid') <  1
* insert
				lcString = " insert into tunnusinf (rekvid, kontoid, tunnusid, algsaldo) values ( 11,"+;
					STR(kontoId)+","+Str(tunnusid)+","+lcSumma+")"

			Else
* update
				lcString = " update tunnusinf set algsaldo = "+lcSumma +" where id = "+Str(qryid.Id)

			Endif
			lnresult = SQLEXEC(gnHandle,lcString)
			If lnresult <  1
				lError = .T.
				Set Step On
				Exit
			Endif
			lnSummaTunnus = lnSummaTunnus + qryKontoinf.Summa


		Endscan
	Endif
	IF VAL(lcSummaKokku) <> lnSummaTunnus
		MESSAGEBOX('Kontrol summa viga'+lcSummaKokku+STR(lnSummaTunnus,12,2))
	endif

	If lError = .F.
		Wait Window qryKonto.konto+' konto ' Nowait


		lcString = " update kontoinf set algsaldo = "+lcSummaKokku+ " where rekvid = 11 and parentid = "+Str(lnKontoid)
		lnresult = SQLEXEC(gnHandle,lcString)
		If lnresult <  1
			lError = .T.
			Set Step On
			Exit
		Endif
	Endif
	IF lError = .t.
		exit
	endif

Endscan

If lnresult > 0 And lError = .F.
	=SQLEXEC(gnHandle,'commit work')
	Messagebox('Ok, summa:'+Str(lnSumma,12,2))
Else
	Set Step On
	=SQLEXEC(gnHandle,'rollback work')
Endif

On Error


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


Function f_error_handling
	Set Step On
	lError = .T.
Endfunc
