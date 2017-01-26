Local  lnResult
If !Used('curSource')
	Create Cursor curSource (Id Int, kood c(20), nimetus c(120))
Endif
If !Used('curValitud')
	Create Cursor curValitud (Id Int, kood c(20), nimetus c(120))
Endif
Create Cursor curResult (Id Int, gruppId Int, nomId Int)
lnStep = 1
Do While lnStep > 0
	Do Case
		Case lnStep = 1
			Do get_grupp_list
		Case lnStep = 2
			Do get_pvkaart_list
		Case lnStep > 2
			Do arvutus
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


Procedure arvutus
	Local lError
	If !Used('curKulumiarv')
		Return .F.
	ENDIF
	odb.opentransaction()
	Select Distinc Id From curResult Where !Empty(curResult.Id) Into Cursor recalc1
	Select recalc1
	Scan
		lError=edit_oper(recalc1.Id)
		If lError = .F.
			Exit
		Endif
	Endscan
	If lError = .T.
		odb.commit()
	Else
		odb.Rollback()
	Endif
	If lError = .F.
		Messagebox('Viga','Kontrol')
	Endif
	lnStep = 0
Endproc

Procedure edit_oper
	Parameter tnid
	If Used('v_pv_oper')
		Use In v_pv_oper
	Endif
	If gVersia = 'VFP' Or gVersia = 'PG'
		lcParam = Str(tnid)+","+Str(curKulumiarv.nomId)+","+;
			STR(v_dokprop.Id)+",DATE("+Str(Year(curKulumiarv.kpv),4)+","+;
			STR(Month(curKulumiarv.kpv),2)+","+Str(Day(curKulumiarv.kpv),2)+")"
	Else
		lcParam = Str(tnid)+","+Str(curKulumiarv.nomId)+","+;
			STR(v_dokprop.Id)+",'"+Dtoc(curKulumiarv.kpv,1)+"')"
	Endif
	lError = odb.Exec ('sp_samm_kulum', lcParam)
	Return lError
Endproc


Procedure get_grupp_list
	If Used('query1')
		Use In query1
	Endif
	tcKood = '%'
	tcNimetus = '%'
	tcKonto = '%'
	odb.Use('curPvGruppid','qryPvGruppid')
	Select curSource
	If Reccount('curSource') > 0
		Zap
	Endif
	Append From Dbf('qryPvGruppid')
	Use In qryPvGruppid
	Select curValitud
	If Reccount('curvalitud') > 0
		Zap
	Endif
	Do Form Forms\samm With '1', Iif(config.keel = 2,'Pхhivara gruppid','Группы основных средств'),Iif(config.keel = 2,;
		'Valitud gruppid','Выбранные группы') To nResult
	If nResult = 1
		Select Distinc Id From curValitud  Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (gruppId);
				values (query1.Id)
		Endscan
		Use In query1
		Select curValitud
		Zap
	Endif
	If nResult = 0
		lnStep = 0
	Else
		lnStep = lnStep + nResult
	ENDIF
	SELECT curResult 
Endproc

Procedure get_pvkaart_list
	If Used('query1')
		Use In query1
	ENDIF
	tcKood = '%'
	tcNimetus = '%'
	tcKonto = '%'
	tcVastIsik = '%'
	tcGrupp = '%'
	tcRentnik = '%'
	tnSoetmaks1 = -999999999
	tnSoetmaks2 = 999999999
	tdSoetkpv1 = DATE(1900,01,01)
	tdSoetkpv2 = GOMONTH(curKulumiarv.kpv,1) -1
	tnTunnus = 1
	
	odb.Use('curPohivara','qryPohivara')
	Select curSource
	If Reccount('curSource') > 0
		Zap
	ENDIF
	SELECT curResult
	Select kood, nimetus, Id From qryPohivara Where gruppId In (Select gruppId From curResult);
		into Cursor query1
	Select curSource
	Append From Dbf('query1')
	Use In query1
	Select curValitud
	If Reccount('curvalitud') > 0
		Zap
	Endif
	Do Form Forms\samm With '2', Iif(config.keel = 2,'Inv. kaardid','Инвентарные карты'),;
		iif(config.keel = 2,'Valitud lepingud','Выбранные договора') To nResult
	If nResult = 1
		Select Distinc Id From curValitud Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (Id);
				values (query1.Id)
		Endscan
		Use In query1
	Endif
	If nResult = 0
		lnStep = 0
	Else
		lnStep = lnStep + nResult
	Endif
	Return

Procedure get_nom_list
	If Used('query1')
		Use In query1
	Endif
	Select kood, nimetus, Id From comNomremote Where DOK = 'KULUM' Into Cursor qryKulum
	Select curSource
	If Reccount('curSource') > 0
		Zap
	Endif
	Append From Dbf('qryKulum')
	Use In qryKulum
	Select curValitud
	If Reccount('curvalitud') > 0
		Zap
	Endif
	If Reccount ('curSource') > 1
		Do Form Forms\samm With '1', Iif(config.keel = 2,'Pхhivara gruppid','Группы основных средств'),Iif(config.keel = 2,;
			'Valitud gruppid','Выбранные группы') To nResult
	Else
		Select curValitud
		Append Blank
		Replace kood With curSource.kood,;
			nimetus With curSource.nimetus,;
			id  With curSource.Id In curValitud
	Endif
	If nResult = 1
		Select Distinc Id From curValitud  Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (nomId);
				values (query1.Id)
		Endscan
		Use In query1
		Select curValitud
		Zap
	Endif
	If nResult = 0
		lnStep = 0
	Else
		lnStep = lnStep + nResult
	Endif
Endproc


