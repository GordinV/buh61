Local lError
Clear All

gnHandle = SQLConnect('narvalvpg','vlad','490710')
If gnHandle < 1
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif

lnSumma = 0
lnrec = 0
lnresult = 0

lcString = " select * from arv where rekvid = 6 and (kpv = DATE(2004,05,05) or kpv =  DATE(2004,05,06) or kpv =  DATE(2004,06,05) or kpv =  DATE(2004,06,07)) and userid = 174 "
lnresult = SQLEXEC(gnHandle,lcString,'qryA')

lnresult = SQLEXEC(gnHandle,'begin work')
If lnresult > 0
	Select qryA
	Scan
*  ISALPHA(SUBSTR(ALLTRIM(qryA.number),4,1))
		If ;
				(Val(Left(Alltrim(qryA.Number),3))>= 584 And Val(Left(Alltrim(qryA.Number),3))<= 624 And ;
				EMPTY(Substr(Alltrim(qryA.Number),4,1))) ;
				Or ;
				(Val(Left(Alltrim(qryA.Number),3))>= 636 And Val(Left(Alltrim(qryA.Number),3))<= 658 And ;
				EMPTY(Substr(Alltrim(qryA.Number),4,1))) ;
				Or ;
				(Val(Left(Alltrim(qryA.Number),3))>= 645 And Val(Left(Alltrim(qryA.Number),3))<= 658 And ;
				!Empty(Substr(Alltrim(qryA.Number),4,1)) And Upper(Substr(Alltrim(qryA.Number),4,1)) ='A')


			Wait Window qryA.Number Nowait

*			????? ? 724 ?? 773 - ??? ??? ????, ? 736? ?? 752?. ? ???? ?????? ?????????? ????????? ???? ? 05.06 ? 06.06. ?? 07.06.


			lcString = " update arv set kpv = DATE(2004,05,07) where rekvid = 6 and id = "+Str(qryA.Id)
			lnresult = SQLEXEC(gnHandle,lcString)
			If lnresult < 1
				Set Step On
				Exit
			Endif
			lcString = " update journal set kpv = DATE(2004,05,07) where rekvid = 6 and id = "+Str(qryA.journalid)
			lnresult = SQLEXEC(gnHandle,lcString)
			If lnresult < 1
				Set Step On
				Exit
			Endif

		Endif

		If;
				(Val(Left(Alltrim(qryA.Number),3))>= 724 And Val(Left(Alltrim(qryA.Number),3))<= 773 And ;
				EMPTY(Substr(Alltrim(qryA.Number),4,1))) ;
				Or ;
				(Val(Left(Alltrim(qryA.Number),3))>= 736 And Val(Left(Alltrim(qryA.Number),3))<= 752 And ;
				!Empty(Substr(Alltrim(qryA.Number),4,1)) And Upper(Substr(Alltrim(qryA.Number),4,1)) ='A')

			Wait Window qryA.Number Nowait

			lcString = " update arv set kpv = DATE(2004,06,07) where rekvid = 6 and id = "+Str(qryA.Id)
			lnresult = SQLEXEC(gnHandle,lcString)
			If lnresult < 1
				Set Step On
				Exit
			Endif
			lcString = " update journal set kpv = DATE(2004,06,07) where rekvid = 6 and id = "+Str(qryA.journalid)
			lnresult = SQLEXEC(gnHandle,lcString)
			If lnresult < 1
				Set Step On
				Exit
			Endif


		Endif

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

