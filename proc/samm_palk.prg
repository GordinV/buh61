Parameter tnIsikid
SET STEP ON 
SET TEXTMERGE ON

Local lnResult, leRror
leRror = .T.
If  .Not. Used('curSource')
	Create Cursor curSource (Id Int, koOd C (20), niMetus C (120))
Endif
If  .Not. Used('curValitud')
	Create Cursor curValitud (Id Int, koOd C (20), niMetus C (120))
Endif
Create Cursor curResult (Id Int, osAkonnaid Int, paLklibid Int)
lnStep = 1
If Used('v_dokprop')
	Use In v_dokprop
Endif
tnId = geTdokpropid('PALK')
If  .Not. Used('v_dokprop')
	odB.Use('v_dokprop','v_dokprop')
ENDIF


Do While lnStep>0
	If  .Not. Empty(tnIsikid)
		Insert Into curResult (osAkonnaid) ;
			SELECT OSAKONDID From comTootajad Where Id = tnIsikid ;
			AND OSAKONDID >= Iif(fltrPalkOper.OSAKONDID > 0,fltrPalkOper.OSAKONDID,0);
			AND OSAKONDID <= Iif(fltrPalkOper.OSAKONDID > 0,fltrPalkOper.OSAKONDID,999999999)

		Insert Into curResult (Id) Values (tnIsikid)
		lnStep = 3
		tnIsikid = 0
	Endif
	Do Case
		Case lnStep=1
			Do geT_osakonna_list
		Case lnStep=2
			Do geT_isiku_list
		Case lnStep=3
			Do geT_kood_list
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
If Used('tmpArvestaMinSots')
	Use In tmpArvestaMinSots
Endif

Endproc
*
Procedure arVutus
	Local leRror, lcOsakonnad
	leRror = .T.
	lcOsakonnad = ''
	
	With odB
		Select Distinct paLklibid From curResult Where  Not  ;
			EMPTY(curResult.paLklibid) Into Cursor ValPalkLib
		Select Distinct Id From curResult Where  Not Empty(curResult.Id)  ;
			INTO Cursor recalc1
			
		Select curResult
		Scan For osAkonnaid > 0
			If Len(lcOsakonnad) > 0
				lcOsakonnad = lcOsakonnad + ','
			Endif
			lcOsakonnad = lcOsakonnad + Str(curResult.osAkonnaid)
		Endscan
		If Len(lcOsakonnad) > 0
			lcOsakonnad = '(' + lcOsakonnad + ')'
		Endif

		Select recalc1
		Scan
			Select coMasutusremote
			Seek recalc1.Id
			Wait Window 'Arvestan: '+ Rtrim(coMasutusremote.niMetus) Nowait

			tnId = recalc1.Id

*!*				If  .Not. Used('v_palk_kaart')
*!*					.Use('v_palk_kaart')
*!*				Else
*!*					.dbReq('v_palk_kaart',gnHandle,'v_palk_kaart')
*!*				Endif
			
			TEXT TO lcString NOSHOW
				select pk.id, pk.parentid, pk.lepingid, pk.libid, pk.summa
							 FROM Library l
							 inner join Palk_kaart  pk on pk.libId = l.id
							 inner join   Palk_lib pl on pl.parentId = l.id
							 inner join tooleping t on pk.lepingId = t.id
							 left outer join dokvaluuta1 on (pk.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 20)
							 where pk.parentid = ?tnId
							 and t.rekvid = ?gRekv
							 and pk.status = 1
							 and not EMPTY(pk.summa)
							 and t.algab <= ?gdKpv
							 and (t.lopp is null or t.lopp >= ?gdKpv)
							 and (<<lcOsakonnad>>::text = ''  or t.osakondid  in <<lcOsakonnad>>)
							 order by liik, t.pohikoht desc, case when empty(pl.tululiik) then 99::text else tululiik end, Pk.percent_ desc, pk.summa desc
			ENDTEXT
			

			odB.execsql(lcString, 'qryPalkKaart')
			Select qryPalkKaart
			GO top
			
			IF tmpArvestaMinSots.kustuta = 1 
				lcDate = 'date(' + STR(YEAR(gdKpv),4)+','+STR(MONTH(gdKpv),2)+ ','+ STR(DAY(gdKpv),2)+ ')'
				* kustuta eelmine arvestus
				TEXT TO lcString NOSHOW
					DELETE FROM palk_oper WHERE lepingid in (select id FROM tooleping WHERE rekvid = ?gRekv AND parentid = ?tnId) AND kpv = <<lcDate>>
				ENDTEXT
				lError = odB.execsql(lcString)
				IF EMPTY(lError) 
					set STEP on 
				ENDIF
				
			ENDIF
			

			Select qryPalkKaart
			Scan
				Select ValPalkLib
				Locate For ValPalkLib.paLklibid=qryPalkKaart.liBid
				If Found()
					leRror = edIt_oper(recalc1.Id)
				Endif
			Endscan
			If !leRror
				Exit
			Endif
		Endscan
		If !leRror
			If _vfp.StartMode = 0
				Set Step On
			Endif
			Messagebox('Viga', 'Kontrol')
		Endif
		lnStep = 0
	Endwith
Endproc
*
Procedure edIt_oper
	Parameter tnId
	Local leRror, l_arvesta_min_sots, lcString
	tnId = recalc1.Id
	If Empty(gdKpv)
		gdKpv = Date()
		Do Form period
	Endif

	l_arvesta_min_sots = 0

	If Used('tmpArvestaMinSots')
		l_arvesta_min_sots = tmpArvestaMinSots.arvesta
	Endif

	lcString = Str(qryPalkKaart.lepingId)+","+Str(qryPalkKaart.liBid)+;
		","+Str(v_dokprop.Id)+", DATE("+;
		STR(Year(gdKpv),4)+","+Str(Month(gdKpv),2)+","+Str(Day(gdKpv),2)+")"+",0,"+ Alltrim(Str(l_arvesta_min_sots))

	leRror = odB.Exec("gen_palkoper ",lcString,'qryOper')
	IF !lerror 
		_cliptext = lcString
		MESSAGEBOX('Viga',0,'Error')
	ENDIF
	
	Return leRror
Endproc
*
Procedure geT_osakonna_list
	If Used('query1')
		Use In query1
	Endif
	tcKood = '%%'
	tcNimetus = '%%'
	odB.Use('curOsakonnad','qryOsakonnad')
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Append From Dbf('qryOsakonnad')
	Use In qrYosakonnad
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '1', Iif(coNfig.keEl=2, 'Osakonnad',  ;
		'Отделы'), Iif(coNfig.keEl=2, 'Valitud osakonnad', 'Выбранные отделы'), gdKpv, 1
	If nrEsult=1
		Select Distinct Id From curValitud Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (osAkonnaid) Values (query1.Id)
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
Procedure geT_isiku_list
	If Used('query1')
		Use In query1
	Endif
	If Used('qryTootajad')
		Use In qryTootajad
	Endif
	If Used('tooleping')
		Use In toOleping
	Endif
	If Used('asutus')
		Use In asUtus
	Endif
	tcIsik = '%%'
	odB.Use('comTootajad','qryTootajad')
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Select koOd, niMetus, Id From qryTootajad Where OSAKONDID In(Select  ;
		osAkonnaid From curResult) Into Cursor query1
	Select curSource
	Append From Dbf('query1')
	Use In query1
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '2', Iif(coNfig.keEl=2, 'Isikud',  ;
		'Работники'), Iif(coNfig.keEl=2, 'Valitud isikud', 'Выбранные работники'), gdKpv, 1
	If nrEsult=1
		Select Distinct Id From curValitud Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (Id) Values (query1.Id)
		Endscan
		Use In query1
	Endif
	If nrEsult=0
		lnStep = 0
	Else
		lnStep = lnStep+nrEsult
	Endif
	Return
Endproc
*
Procedure geT_kood_list
	If Used('query1')
		Use In query1
	Endif
	tcKood = '%%'
	tcNimetus = '%%'
	tnStatus = 0
	TCTULULIIK = '%%'
	odB.Use('curPalkLib','qryPalkLib')
	Delete From qrYpalklib Where liIk=6
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Append From Dbf('qryPalkLib')
	Use In qrYpalklib
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '3', Iif(coNfig.keEl=2,  ;
		'Palgastruktuur', 'Начисления и удержания'), Iif(coNfig.keEl=2,  ;
		'Valitud ', 'Выбранно '), gdKpv, 1


	If nrEsult=1
		Select Distinct Id From curValitud Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (paLklibid) Values (query1.Id)
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
