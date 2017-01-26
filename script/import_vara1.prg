Local lError
CLEAR ALL

SET STEP ON 
lcFile1 = 'temp\jobuhova.xls'
IMPORT FROM (lcFile1) TYPE XL8 


*'c:\avpsoft\files\buh60\temp\haridus\agr2004palk.dbf'
*lcFile2 = 'c:\avpsoft\files\buh60\temp\haridus\tp2004.dbf'
If !File(lcFile1) 
	Messagebox('Viga, failid ei leidnud')
	lError = .T.
Endif
*!*	Use (lcFile1) In 0 Alias lausend Excl
*!*	Use (lcFile2) In 0 Alias asutused Excl

*!*	sele

*!*	Select Val(Alltrim(lausend.n11)) As asutusId, Val(Alltrim(asutused.n1)) As Id, asutused.n5 As nimetus, asutused.n6 As regkood, ;
*!*		lausend.* From lausend Left Outer Join asutused On Val(Alltrim(asutused.n1)) = lausend.asutusId;
*!*		INTO Cursor qryHO
*!*	SET STEP ON
*!*	scan
*!*		lcSumma = transdigit(ltrim(RTRIM(qryHo.n9)))
*!*	ENDSCAN
*!*	return

gnHandle = SQLConnect('narvalvpg','vlad','654')
If gnHandle < 1
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif

lnSumma = 0
lnrec = 0
lnresult=SQLEXEC(gnHandle,'begin work')

lcString = 'select * from asutus '
=SQLEXEC(gnHandle,lcString,'qryAsutus')

Select jobuhova
Scan
	Wait Window Str(Recno('jobuhova'))+'-'+Str(Reccount('jobuhova')) Nowait
	lcErr = ''

	lcdate = 'date('+str(jobuhova.c,4)+','+STR(jobuhova.b,2)+','+str(jobuhova.d,2)+')'
	
	SELECT qryAsutus
	LOCATE FOR ALLTRIM(UPPER(jobuhova.l)) $ ALLTRIM(UPPER(nimetus)) 
	IF FOUND()
		lcAsutusId = STR(qryAsutus.id)
	ELSE
		lnResult = -1
			SET STEP ON 
			exit
*		lcAsutusId = '0'
	ENDIF
	
	
	lcuserId = '175'
	lcSelg = Ltrim(Rtrim(jobuhova.j))
	lcDok = LEFT(Ltrim(Rtrim(jobuhova.k)),60)
	lcMuud = ''
	lcUksus = ''

	lcDeebet = Ltrim(Rtrim(STR(jobuhova.e)))
	lcKreedit = Ltrim(Rtrim(jobuhova.g))


	lcTpd = Ltrim(Rtrim(STR(jobuhova.f)))
	lcTpk = Ltrim(Rtrim(jobuhova.h))
	
	lcSumma = str(jobuhova.i,12,2)
	lcKood1 = ''
	*Ltrim(Rtrim(qryHO.n4))
	lcKood2 = ''
	lcKood3 = ''
	IF jobuhova.r > 0 
		lcKood3 = str(jobuhova.r,2)
	ENDIF
	
	lcKood4 = ''
	lcKood5 = ''


* kontrol

*!*		lcString = " SELECT id from library where library = 'KONTOD' AND kood = '"+lcDeebet+"'"
*!*		lnresult = SQLEXEC(gnHandle,lcString, 'qryKontoId')
*!*		If lnresult > 0
*!*			If Reccount('qryKontoid') <  1
*!*				lnresult = -1
*!*				lcErr = lcDeebet
*!*			Endif
*!*		Endif

*!*		lcString = " SELECT id from library where library = 'KONTOD' AND kood = '"+lcKreedit+"'"
*!*		lnresult = SQLEXEC(gnHandle,lcString, 'qryKontoId')
*!*		If lnresult > 0
*!*			If Reccount('qryKontoid') <  1
*!*				lnresult = -1
*!*				lcErr = lcKreedit
*!*			Endif
*!*		Endif
*!*		If !Empty(lcKood1)
*!*			lcString = " SELECT id from library where library = 'TEGEV' AND kood = '"+lcKood1+"'"
*!*			lnresult = SQLEXEC(gnHandle,lcString, 'qryKood')
*!*			If lnresult > 0
*!*				If Reccount('qryKood') <  1
*!*					lnresult = -1
*!*					lcErr = lcKood1
*!*				Endif
*!*			Endif
*!*		Endif
*!*		If !Empty(lcKood2)
*!*			lcString = " SELECT id from library where library = 'ALLIKAD' AND kood = '"+lcKood2+"'"
*!*			lnresult = SQLEXEC(gnHandle,lcString, 'qryKood')
*!*			If lnresult > 0
*!*				If Reccount('qryKood') <  1
*!*					lnresult = -1
*!*					lcErr = lcKood2
*!*				Endif
*!*			Endif
*!*		Endif
*!*		If !Empty(lcKood3)
*!*			lcString = " SELECT id from library where library = 'RAHA' AND kood = '"+lcKood3+"'"
*!*			lnresult = SQLEXEC(gnHandle,lcString, 'qryKood')
*!*			If lnresult > 0
*!*				If Reccount('qryKood') <  1
*!*					lnresult = -1
*!*					lcErr = lcKood3
*!*				Endif
*!*			Endif
*!*		Endif
*!*		If !Empty(lcKood5)
*!*			lcString = " SELECT id from library where library = 'TULUDEALLIKAD' AND kood = '"+lcKood5+"'"
*!*			lnresult = SQLEXEC(gnHandle,lcString, 'qryKood')
*!*			If lnresult > 0
*!*				If Reccount('qryKood') <  1
*!*					lnresult = -1
*!*					lcErr = lcKood5
*!*				Endif
*!*			Endif
*!*		Endif


*!*	* Проверка на наличие tunnus
*!*		If lnresult > 0 And !Empty(lcUksus)
*!*			lcString = " SELECT id from library where library = 'TUNNUS' and rekvid = 11 AND kood = '"+lcUksus+"'"
*!*			lnresult = SQLEXEC(gnHandle,lcString, 'qryTun')
*!*			If lnresult > 0
*!*				If Reccount('qryTun') <  1
*!*	* insert new value
*!*					lcInsert = "insert into library (rekvid, kood, nimetus,library) values ("+;
*!*						"11,'"+lcUksus+"','"+lcUksus+"','TUNNUS')"
*!*					lnresult = SQLEXEC(gnHandle,lcString)
*!*				Endif
*!*			Endif
*!*		Endif

	If lcDeebet <> lcKreedit
		If lnresult > 0
			lcString = "insert into journal (kpv, asutusId, rekvId, userId, selg, dok, muud) values ("+;
				lcdate+","+lcAsutusId+",6,"+lcuserId+",'"+lcSelg+"','"+lcDok+"','"+lcMuud+"')"

			lnresult = SQLEXEC(gnHandle,lcString)

		Endif

		If lnresult > 0

			lcString = 'select id from journal where rekvid = 6 order by id desc limit 1'
			lnresult = SQLEXEC(gnHandle,lcString,'qrylastId')
		Endif

		If lnresult > 0	
			WAIT WINDOW 'insert journal1' nowait

			lcString = "insert into journal1 (parentId, deebet, lisa_d, kreedit, lisa_k, summa, tunnus, kood1, kood2, kood3, kood4, kood5, proj) values ("+;
				STR(qryLastid.Id)+",'"+lcDeebet+"','"+lcTpd+"','"+lcKreedit+"','"+lcTpk+"',"+lcSumma+",'"+;
				lcUksus+"','"+lcKood1+"','"+lcKood2+"','"+lcKood3+"','"+lcKood4+"','"+lcKood5+"','')"

			lnSumma = lnSumma + VAL(lcSumma)
			lnrec = lnrec  + 1
			lnresult = SQLEXEC(gnHandle,lcString)
			IF lnresult > 0
				lcString = 'select id from journal1 where parentid = ' + STR(qryLastid.Id) + ' order by id desc limit 1'
				lnresult = SQLEXEC(gnHandle,lcString, 'qryJournal1')
				IF lnResult > 0
					WAIT WINDOW 'insert journal1, done: ' + STR(qryJournal1.id) nowait
				ELSE
					WAIT WINDOW 'insert journal1: viga' nowait
					SET STEP ON 
				ENDIF
				
			ENDif
			
		Endif
	Endif
	If lnresult < 0
		Exit
	Endif
Endscan
Set Step On
If lnresult > 0
	=SQLEXEC(gnHandle,'commit work')
	MESSAGEBOX('Ok, summa:'+STR(lnSumma,12,2)+' kokku read:'+STR(lnRec))
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

