Local lError
Clear All

lcFile1 = 'c:\avpsoft\haridus\eelarve\kulud.dbf'
*lcFile1 = 'c:\avpsoft\haridus\palk1.dbf'
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


=SQLEXEC(gnHandle,'begin work')

Select qryHO 
SCAN 
	Wait Window Str(Recno('qryHo'))+'/'+Str(Reccount('qryHo')) Nowait
	lcKood1 = ''
	lcKood2 = ''
	lcKood4 = ''
	lnTunnusId = 0

	lcString = "select id from library where rekvid = 31 and library = 'TUNNUS' and kood = '"+qryHO.n_ksus+"'"
	lnResult = SQLEXEC(gnHandle,lcString,'qryId')
	If lnResult < 1 Or Reccount('qryId') < 1
		lnResult = -1
		Set Step On
		Exit
	Else
		lnTunnusId = qryId.Id

	Endif
	If Used('qryId')
		Use In qryId
	Endif

	lcString = "select id from library where library = 'TEGEV' and kood = '"+qryHO.tegevusala+"'"
	lnResult = SQLEXEC(gnHandle,lcString,'qryId')
	If lnResult < 1 Or Reccount('qryId') < 1
		lnResult = -1
		Set Step On
		Exit
	Else
		lcKood1 = ALLTRIM(qryHO.tegevusala)
	Endif

	If Used('qryId')
		Use In qryId
	Endif
	If !Empty(qryHO.allikas)
		lcString = "select id from library where library = 'ALLIKAD' and kood = '"+qryHO.allikas+"'"
		lnResult = SQLEXEC(gnHandle,lcString,'qryId')
		If lnResult < 1 Or Reccount('qryId') < 1
			lnResult = -1
			Set Step On
			Exit
		Else
			lcKood2 = ALLTRIM(qryHO.allikas)
		Endif
	Endif


	If Used('qryId')
		Use In qryId
	Endif

	lcString = "select id from library where library = 'TULUDEALLIKAD' and kood = '"+qryHO.kood+"'"
	lnResult = SQLEXEC(gnHandle,lcString,'qryId')
	If lnResult < 1 Or Reccount('qryId') < 1
		lnResult = -1
		Set Step On
		Exit
	Else
		lcKood4 = ALLTRIM(qryHO.kood)
	Endif

	If Used('qryId')
		Use In qryId
	Endif

	lcSumma = (ALLTRIM(qryHO.summa))
	IF AT(',', lcSumma) > 0
		lcSumma = transdigit(lcSumma)
	endif 
	If lnResult > 0
		lcString = "insert into eelarve (aasta, rekvid, tunnusId, kood1, kood2, kood4, summa, muud) values (2004,31,"+;
			STR(lnTunnusId,31)+",'"+lcKood1+"','"+lcKood2+"','"+lcKood4+"',"+lcsumma+",'"+qryHo.m_rkused+"')"
		lnResult = SQLEXEC(gnHandle,lcString)
	Endif

	If lnResult < 1
		Set Step On
		Exit
	Endif
	lnSumma = lnSumma + Val(lcSumma)
	lnrec = lnrec + 1
Endscan



If lnResult > 0
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

