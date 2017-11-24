Local lError
Clear All

lcFile1 = 'c:\avpsoft\haridus\lapsed\lapsed09.dbf'
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


lnresult=SQLEXEC(gnHandle,'begin work')



If lnresult > 0
	Select qryHO
	Scan
		Wait Window Str(Recno('qryHo'))+'/'+Str(Reccount('qryHo')) Nowait

* check isik
		lcisikkood = Alltrim((qryHO.n7))
		lcNimi = Ltrim(Rtrim(qryHO.n6))
		lcisikkood = Iif(lcisikkood = '0' or EMPTY(lcisikkood),'',lcisikkood)
		If !Empty(qryHO.N45)
			lcString = 	"select * from vanemtasu1 where isikkood 	= '"+lcisikkood+"'"
		Else
			lcString = 	"select * from vanemtasu1 where UPPER(nimi) 	= '"+Upper(lcNimi)+"'"

		Endif
		If Used('qryisikId')
			Use In qryIsikId
		Endif

		lnresult =SQLEXEC(gnHandle,lcString,'qryIsikId')
		If lnresult > 0
			If Reccount('qryIsikId') < 1
* puudub

				IF EMPTY(lcisikkood)
					lcisikkood = ''
				endif
				lcString = " insert into vanemtasu1 ( isikkood, nimi,  vanemkood ,  vanemnimi ,  muud ) values ('"+;
					lcisikkood+"','"+lcNimi+"','"+qryHO.n46+"','"+Ltrim(Rtrim(qryHO.n45))+"','"+;
					"(nd)"+(qryHO.n2)+" (gr)"+qryHO.n3+" (kod)"+(qryHO.n4)+"')"

				lnresult =SQLEXEC(gnHandle,lcString)
				If lnresult > 1
					lcString = " SELECT * FROM vanemtasu1 ORDER BY id desc limit 1"
					lnresult =SQLEXEC(gnHandle,lcString,'qryIsikId')
				Endif
			Endif
		Endif

* check uksus
		If lnresult > 0 And Reccount('qryIsikId') > 0
			lcString = " select id from vanemtasu2 where rekvid = 31 and isikId = "+Str(qryIsikId.Id)+" and tunnus = '"+Ltrim(Rtrim(qryHO.n1))+"'"
			lnresult =SQLEXEC(gnHandle,lcString,'qryAsuId')
			If lnresult > 0 And Reccount('qryAsuId') < 1
* puudub
				lcString = "insert into vanemtasu2 (isikid,tunnus,rekvid,algkpv, loppkpv, grupp) values ("+;
					STR(qryIsikId.Id,9)+",'"+Ltrim(Rtrim(qryHO.n1))+"',31,DATE(2004,09,01),DATE(2005,05,31),"+;
					(qryHO.n2)+")"
				lnresult =SQLEXEC(gnHandle,lcString)
				If lnresult > 0
					lcString = " SELECT id FROM vanemtasu2 ORDER BY id desc limit 1"
					lnresult =SQLEXEC(gnHandle,lcString,'qryAsuId')
				Endif
			Endif

		Endif

* tasu 0
*!*			If lnresult > 0
*!*				If !Empty(VAL(transdigit(ALLTRIM(qryHO.n48)))) And lnresult > 0
*!*					lcDate = "date(2004,0,"+alltrim(qryHo.n16)+")"
*!*					lcString = "insert into vanemtasu3 (rekvid, userid ,  opt ,  kpv ,  tunnus ,  muud ) values ("+;
*!*						" 31, 222, 1,"+lcdate +", '"+Ltrim(Rtrim(qryHO.n1))+"','imp. fail DDU09_vladN.xls ')"
*!*					lnresult =SQLEXEC(gnHandle,lcString)
*!*					If lnresult > 0
*!*						lcString = " SELECT id FROM vanemtasu3 ORDER BY id desc limit 1"
*!*						lnresult =SQLEXEC(gnHandle,lcString,'qryDokId')

*!*						lcString = " insert into vanemtasu4 (parentid,isikid , maksjakood , maksjanimi ,  nomid ,  kogus ,  hind ,  summa ) values ("+;
*!*							STR(qryDokId.Id,9)+","+Str(qryIsikId.Id,9)+",'"+Ltrim(Rtrim(qryIsikId.vanemkood))+"','"+;
*!*							LTRIM(Rtrim(qryIsikId.vanemnimi))+"',0,1,"+transdigit(ALLTRIM(qryHO.n48))+","+transdigit(ALLTRIM(qryHO.n48))+")"
*!*						lnresult =SQLEXEC(gnHandle,lcString)

*!*					Endif
*!*				Endif

*arv
		If lnresult > 0 AND (VAL(transdigit(ALLTRIM(qryHO.n53))) +   VAL(transdigit(ALLTRIM(qryHO.n52))) +  VAL(transdigit(ALLTRIM(qryHO.n54)))) <>0
			If !Empty(VAL(transdigit(ALLTRIM(qryHO.n52)))) And lnresult > 0
				lcDate = "date(2004,09,30)"
				lcString = "insert into vanemtasu3 (rekvid, userid ,  opt ,  kpv ,  tunnus ,  muud ) values ("+;
					" 31, 222, 2,"+lcdate +", '"+Ltrim(Rtrim(qryHO.n1))+"','imp. fail DDU09_vladN.xls ')"
				lnresult =SQLEXEC(gnHandle,lcString)
				If lnresult > 0
					lcString = " SELECT id FROM vanemtasu3 ORDER BY id desc limit 1"
					lnresult =SQLEXEC(gnHandle,lcString,'qryDokId')
				ENDIF
				

				If lnresult > 0 AND VAL(transdigit(ALLTRIM(qryHO.n52))) <> 0

					lcString = " insert into vanemtasu4 (parentid,isikid , maksjakood , maksjanimi ,  nomid ,  kogus ,  hind ,  summa ) values ("+;
						STR(qryDokId.Id,9)+","+Str(qryIsikId.Id,9)+",'"+Ltrim(Rtrim(qryIsikId.vanemkood))+"','"+;
						LTRIM(Rtrim(qryIsikId.vanemnimi))+"',852,1,"+transdigit(ALLTRIM(qryHO.n52))+","+transdigit(ALLTRIM(qryHO.n52))+")"
					lnresult =SQLEXEC(gnHandle,lcString)

				ENDIF
				If lnresult > 0 AND VAL(transdigit(ALLTRIM(qryHO.n53))) <> 0
					lcString = " insert into vanemtasu4 (parentid,isikid , maksjakood , maksjanimi ,  nomid ,  kogus ,  hind ,  summa ) values ("+;
						STR(qryDokId.Id,9)+","+Str(qryIsikId.Id,9)+",'"+Ltrim(Rtrim(qryIsikId.vanemkood))+"','"+;
						LTRIM(Rtrim(qryIsikId.vanemnimi))+"',853,1,"+transdigit(ALLTRIM(qryHO.n53))+","+transdigit(ALLTRIM(qryHO.n53))+")"
					lnresult =SQLEXEC(gnHandle,lcString)
				ENDIF
				
				If lnresult > 0 AND VAL(transdigit(ALLTRIM(qryHO.n54))) <> 0
					lcString = " insert into vanemtasu4 (parentid,isikid , maksjakood , maksjanimi ,  nomid ,  kogus ,  hind ,  summa ) values ("+;
						STR(qryDokId.Id,9)+","+Str(qryIsikId.Id,9)+",'"+Ltrim(Rtrim(qryIsikId.vanemkood))+"','"+;
						LTRIM(Rtrim(qryIsikId.vanemnimi))+"',855,1,"+transdigit(ALLTRIM(qryHO.n54))+","+transdigit(ALLTRIM(qryHO.n54))+")"
					lnresult =SQLEXEC(gnHandle,lcString)
				ENDIF
				
				
			ENDIF
		ENDIF
		



*!*				If VAL(transdigit(ALLTRIM(qryHO.n48))qryHO.s22<> 0
*!*					lcDate = "date(2004,07,"+STR(qryHo.dop2,2)+")"

*!*					lcString = "insert into vanemtasu3 (rekvid, userid ,  opt ,  kpv ,  tunnus ,  muud ) values ("+;
*!*						" 31, 222, 1, "+lcDate+", '"+Ltrim(Rtrim(qryHO.kood))+"','imp. fail ddu0804')"
*!*					lnresult =SQLEXEC(gnHandle,lcString)
*!*					If lnresult > 0
*!*						lcString = " SELECT id FROM vanemtasu3 ORDER BY id desc limit 1"
*!*						lnresult =SQLEXEC(gnHandle,lcString,'qryDokId')



*!*						If !Empty(qryHO.s22) And lnresult > 0
*!*							lcString = " insert into vanemtasu4 (parentid,isikid , maksjakood , maksjanimi ,  nomid ,  kogus ,  hind ,  summa ) values ("+;
*!*								STR(qryDokId.Id,9)+","+Str(qryIsikId.Id,9)+",'"+Ltrim(Rtrim(qryIsikId.vanemkood))+"','"+;
*!*								LTRIM(Rtrim(qryIsikId.vanemnimi))+"',0,1,"+Str(qryHO.s22,12,2)+","+Str(qryHO.s22,12,2)+")"
*!*							lnresult =SQLEXEC(gnHandle,lcString)

*!*						Endif

*!*					Endif
*!*				Endif





		If lnresult < 1
			Set Step On
			Exit
		Endif
		lnSumma = lnSumma + VAL(transdigit(ALLTRIM(qryHO.n52)))+VAL(transdigit(ALLTRIM(qryHO.n53)))+VAL(transdigit(ALLTRIM(qryHO.n54)))
		lnrec = lnrec + 1
	Endscan


Endif

If lnresult > 0
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

