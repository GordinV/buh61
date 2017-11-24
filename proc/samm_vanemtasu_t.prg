Parameter tnIsikid
Local lnResult, leRror
leRror = .T.
If  .Not. Used('curSource')
	Create Cursor curSource (Id Int, koOd C (20), niMetus C (120))
Endif
If  .Not. Used('curValitud')
	Create Cursor curValitud (Id Int, koOd C (20), niMetus C (120))
Endif
Create Cursor curResult (Id Int, osAkonnaid Int, paLklibid Int, UHIK C(20), gruppId int, grupp c(20), tunnus c(20))
lnStep = 1
If Used('v_dokprop')
	Use In v_dokprop
ENDIF


Do Form period WITH 1


tnId = geTdokpropid('VANEM')
If  .Not. Used('v_dokprop')
	odB.Use('v_dokprop','v_dokprop')
Endif
Do While lnStep>0
	If  .Not. Empty(tnIsikid)
		Insert Into curResult (Id) Values (tnIsikid)
		lnStep = 3
		tnIsikid = 0
	Endif
	Do Case
		Case lnStep=1
			Do geT_osakonna_list
		Case lnStep=2
			Do geT_grupp_list
		Case lnStep=3
			Do geT_isiku_list
*!*			Case lnStep=4
*!*				Do geT_kood_list
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
ENDIF

IF varTYPE(oVanemtasu) = 'O'
	oVanemtasu.requery()
endif

Endproc
*
Procedure arVutus
	Local leRror
	leRror = .T.
	With odB
		Select Distinct OsakonnaId  From curResult Into Cursor ValTunnus

		Select Distinct Id From curResult Where  Not Empty(curResult.Id)  ;
			INTO Cursor recalc1
			
				
			

*!*			If !Used ('v_vanemtasu3')
*!*				.Use ('v_vanemtasu3','v_vanemtasu3',.T.)
*!*			Endif
*!*			Select v_vanemtasu3
*!*			If Reccount() > 0
*!*				Zap
*!*			Endif
*!*			If !Used ('v_vanemtasu4')
*!*				.Use ('v_vanemtasu4','v_vanemtasu4',.T.)
*!*			Endif
*!*			Select v_vanemtasu4
*!*			If Reccount() > 0
*!*				Zap
*!*			ENDIF
		
		SELECT DISTINCT id as isikid FROM curResult WHERE id > 0 INTO CURSOR qryisikId
		.opEntransaction()
		SELECT qryisikId
		lnid = 0
		SCAN
			lError = .Exec("sp_create_vt_arved",Str(qryisikId.isikid)+','+Alltrim(Str(lnid))+',DATE('+;
				STR(YEAR(gdKpv),4)+','+STR(MONTH(gdKpv),2)+','+STR(DAY(gdKpv),2)+'),'+STR(V_DOKPROP.ID,9),'qryVT3')
			IF !EMPTY(lError) AND USED('qryVT3')
				lnid = Iif(gversia = 'PG',qryVT3.sp_create_vt_arved,qryVT3.id)
			ELSE
				exit
			ENDIF
			
		ENDSCAN
		

*!*			Insert Into v_vanemtasu3 (kpv, rekvId, tunnus, dokpropId, konto, opt, userid) ;
*!*				Select Distinct gdKpv, grekv, comTunnusRemote.koOd, v_dokprop.Id, v_dokprop.konto, 2, gUserId;
*!*				From curResult inner Join comTunnusRemote ON(curResult.OsakonnaId = comTunnusRemote.Id AND !EMPTY(curResult.id))

*!*			leRror = .cursorupdate('v_vanemtasu3')

*!*			If leRror = .T.

*!*				Select v_vanemtasu3
*!*				Scan
*!*					Select curResult
*!*					Insert Into v_vanemtasu4 (parentId, HIND, KOGUS, Summa, isikId, nomId, konto, kood1, kood2, kood3, kood4, kood5);
*!*						SELECT v_vanemtasu3.Id,comNomremote.hind,IIF(comNomremote.uhik = 'PAEV',gnPaev,1), comNomremote.hind * IIF(comNomremote.uhik = 'PAEV',gnPaev,1),;
*!*						 curResult.Id,qryNomId.nomid, comNomremote.konto, ;
*!*						comNomremote.kood1, comNomremote.kood2, comNomremote.kood3, comNomremote.kood4, comNomremote.kood5;
*!*						FROM curResult, qryNomId inner Join comNomremote On(qryNomId.nomid = comNomremote.Id And comNomremote.Tyyp = 1 and comNomremote.dok = 'VANEM');
*!*						WHERE !Empty(curResult.Id) AND !EMPTY(curresult.osakonnaId) AND comNomremote.hind > 0

*!*				ENDSCAN
*!*				SELECT v_vanemtasu4
*!*				SUM SUMMA FOR PARENTID = v_vanemtasu3.Id TO lnSumma
*!*				replace v_vanemtasu3.summa WITH lnSumma IN v_vanemtasu3
*!*			Endif
*!*			If Reccount('v_vanemtasu4') <  1
*!*				leRror = .F.
*!*			Endif
*!*			If leRror = .T.
*!*				leRror = .cursorupdate('v_vanemtasu4')
*!*			Endif
*!*			If leRror = .T.
*!*				leRror = .cursorupdate('v_vanemtasu3')
*!*			Endif
		IF lError = .t. and v_dokprop.registr > 0 AND lnId > 0
			lError = .Exec("GEN_LAUSEND_KOOLITUS",Str(lnId),'qryVanemTasuLausend')
		ENDIF
		

		If leRror=.T.
			.coMmit()
		Else
			.Rollback()
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


	Return leRror
Endproc
*

Procedure geT_grupp_list
	If Used('query1')
		Use In query1
	Endif

	DELETE FROM curresult WHERE !EMPTY(gruppid)

	odB.Use('QRYLAPSGRUPP')
	lnId = 1
	SCAN
		replace id WITH lnId IN QRYLAPSGRUPP
		lnId = lnId + 1
	ENDSCAN
	
	Select curSource
	If Reccount('curSource')>0
		Zap
	ENDIF
	
	Append From Dbf('QRYLAPSGRUPP')
	DELETE FROM curSource ;
		where nimetus NOT in (select kood FROM comTunnusRemote inner join curResult on curResult.osakonnaId = comTunnusRemote.id)
*	Use In QRYLAPSGRUPP
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '2', Iif(coNfig.keEl=2, 'Gruppid',  ;
		'Группы'), Iif(coNfig.keEl=2, 'Valitud gruppid', 'Выбранные группыя')
	If nrEsult=1
*		Select Distinct OsakonnaId, gruppid From curValitud Into Cursor query1
		SELECT curvalitud
		SCAN
			SELECT comTunnusRemote
			LOCATE FOR LTRIM(RTRIM(kood)) = LTRIM(RTRIM(curValitud.nimetus)) 
		
			Insert Into curResult (osAkonnaid, gruppid, grupp, tunnus) Values (comTunnusRemote.Id, curvalitud.id, curvalitud.kood, LTRIM(RTRIM(curValitud.nimetus)))
		Endscan
*		Use In query1
		Select curValitud
		Zap
	Endif
	If nrEsult=0
		lnStep = 0
	Else
		lnStep = lnStep+nrEsult
	Endif
Endproc



Procedure geT_osakonna_list
	If Used('query1')
		Use In query1
	Endif
	tcKood = '%%'
	tcNimetus = '%%'
	odB.Use('curTunnus','qryOsakonnad')
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
	Do Form Forms\samm To nrEsult With '1', Iif(coNfig.keEl=2, 'Ьksused',  ;
		'Отделы'), Iif(coNfig.keEl=2, 'Valitud ьksused', 'Выбранные подразделения')
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
	If Used('qryLapsed')
		Use In qryLapsed
	Endif
	DELETE FROM curresult WHERE !EMPTY(id)

	odB.Use('qryLapsed')
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Select koOd, LEFT(LTRIM(RTRIM(niMetus)),60)+'('+LTRIM(RTRIM(tunnus))+')' as nimetus, ISIKID AS Id From qryLapsed;
		Where LTRIM(RTRIM(STR(qryLapsed.tunnusId)))+'-'+LTRIM(RTRIM(qryLapsed.grupp)) In(Select  ;
		LTRIM(rtrim(STR(curresult.osAkonnaid)))+'-'+LTRIM(RTRIM(curresult.grupp)) ;
		From curResult WHERE !EMPTY(gruppId)) ;
		Into Cursor query1
	
	Select curSource
	Append From Dbf('query1')

	Use In query1
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '3', Iif(coNfig.keEl=2, 'Isikud',  ;
		'Работники'), Iif(coNfig.keEl=2, 'Valitud lapsed', 'Выбранные дети')
	If nrEsult=1
		Select Distinct Id From curValitud Into Cursor query1
		Select query1
		SCAN
			SELECT qryLapsed
			LOCATE FOR isikid = query1.id
			IF FOUND()
				Insert Into curResult (osakonnaId, Id, grupp, tunnus) Values (qryLapsed.tunnusId, qryLapsed.ISIKId, qryLapsed.grupp, qryLapsed.tunnus)
			endif
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
	cDok = '%VANEM%'
	cKood = '%'
	cNimetus = '%'
	odB.Use('curNomenklatuur','qryNom')
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Append From Dbf('qryNom')
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '4', Iif(coNfig.keEl=2,  ;
		'Operatsioonid', 'Операции'), Iif(coNfig.keEl=2,  ;
		'Valitud ', 'Выбранно ')
	If nrEsult=1
		Select Distinct Id From curValitud Into Cursor query1
		Select query1
		SCAN
			SELECT qryNom
			LOCATE FOR id = query1.id
			Insert Into curResult (paLklibid, uhik) Values (query1.Id, qryNom.uhik)
		Endscan
		Use In query1
		Select curValitud
		Zap
	Endif
	Use In qrYNom

	If nrEsult=0
		lnStep = 0
	Else
		lnStep = lnStep+nrEsult
	Endif
Endproc
*
