Parameter cWhere
Local lnDeebet, lnKreedit

*!*	IF EMPTY(fltrAruanne.konto)
*!*		MESSAGEBOX(IIF(config.keel = 2,'Puudub konto','����������� ����'),'Kontrol')
*!*		SELECT 0
*!*		RETURN .f.
*!*	ENDIF


dKpv1 = Iif(!Empty(fltrAruanne.kpv1), fltrAruanne.kpv1,Date(Year(Date()),1,1))
dKpv2 = Iif(!Empty(fltrAruanne.kpv2), fltrAruanne.kpv2,Date())

Create Cursor KaibeAsutusAndmik_report1 (algsaldo N(12,2),deebet N(12,2),;
	kreedit N(12,2),konto c(20), nimetus c(120), asutus c(120), regkood c(20), Asutusid Int, tp c(20), aadress c(254),;
	 subrekvid int, subrekvnim c(254) null)
Index On Asutusid Tag Asutusid
Index On Left (Upper (asutus),40) Tag asutus
Index On Alltrim(konto)+':'+Alltrim(Str (Asutusid))  Tag klkonto

Set Order To Asutusid



With odb


	If gVersia = 'PG'

		If fltrAruanne.tunnus > 0

			Select comTunnusRemote
			Locate For Id = fltrAruanne.tunnus
			lcTunnus = Ltrim(Rtrim(comTunnusRemote.kood))
		Else
			lcTunnus = ''
		Endif

		lError = odb.Exec("sp_subkontod_report "," '"+Ltrim(Rtrim(fltrAruanne.konto))+"%',"+;
			Str(grekv)+","+;
			" DATE("+Str(Year(fltrAruanne.kpv1),4)+","+ Str(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+"),"+;
			" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+	Str(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
			STR(fltrAruanne.Asutusid,9)+",'"+;
			LTRIM(Rtrim(lcTunnus))+"%',3,"+str(fltrAruanne.kond,9),"qryKbAsu")

		If Used('qryKbAsu')
			tcTimestamp = Alltrim(qryKbAsu.sp_subkontod_report)
			odb.Use('tmpsubkontod_report')

*!*				SELECT comAsutusRemote
*!*				LOCATE FOR id = tmpsubkontod_report.Asutusid

			Select KaibeAsutusAndmik_report1
			
			Insert Into KaibeAsutusAndmik_report1 (algsaldo, konto , nimetus , asutus , Asutusid , regkood, aadress,subrekvid, subrekvnim );
				SELECT tmpsubkontod_report.algjaak	, tmpsubkontod_report.konto, Iif(Isnull(comKontodRemote.nimetus),Space(1),comKontodRemote.nimetus),;
				tmpsubkontod_report.asutus, tmpsubkontod_report.Asutusid, tmpsubkontod_report.regkood, ;
				IIF(ISNULL(comAsutusRemote.aadress),SPACE(254),comAsutusRemote.aadress),tmpsubkontod_report.subrekvid, tmpsubkontod_report.subrekvnim  ;
				FROM tmpsubkontod_report Left Outer Join comKontodRemote On tmpsubkontod_report.konto = comKontodRemote.kood;
				Left Outer Join comAsutusRemote On tmpsubkontod_report.asutusId = comAsutusRemote.id

			Use In qryKbAsu
			Use In tmpsubkontod_report

		Else
			Select 0
			Return .F.
		Endif

	Else

		Select comKontodRemote
		Scan For Left(Ltrim(Rtrim(kood)),Len(Ltrim(Rtrim(fltrAruanne.konto)))) = Ltrim(Rtrim(fltrAruanne.konto)) And;
				Len(Alltrim(kood)) = Iif('EELARVE' $ curkey.versia,6,Len(Alltrim(kood)))
			Wait Window 'Arvestan konto: '+comKontodRemote.kood Nowait
			lnRecno = Recno('comKontodRemote')
			lcKonto = Ltrim(Rtrim(comKontodRemote.kood))
			tnid = comKontodRemote.Id
			.Use ('v_subkonto','qrySubkonto')
			Select qrySubKonto
			If fltrAruanne.Asutusid > 0
				Delete For Asutusid <> fltrAruanne.Asutusid
			Endif

			tcCursor = 'CursorAlgSaldo_'
			cKonto = Ltrim(Rtrim(fltrAruanne.konto))+'%'
			TcKonto = cKonto
			tnAsutusId1 = 0
			tnAsutusId2 = 99999999
			tdKpv1 = Date(1999,1,1)
			tdKpv2 = fltrAruanne.kpv2
			odb.Use ('qrySaldo2',tcCursor)

			Select qrySubKonto
			Scan
				Select comAsutusRemote
				Seek qrySubKonto.Asutusid

				Wait Window 'Arvestan konto: '+Trim(comKontodRemote.kood)+' Subkonto:'+Trim(comAsutusRemote.nimetus) Nowait

				Select * From CURsorAlgsaldo_ Where Asutusid = qrySubKonto.Asutusid Into Cursor cursorAlgsaldo

				lnAlg = analise_formula('ASD('+Ltrim(Rtrim(comKontodRemote.kood))+','+Alltrim(Str(qrySubKonto.Asutusid))+')', fltrAruanne.kpv2, 'cursorAlgsaldo')
*!*				lnDb = analise_formula('ADK('+Ltrim(Rtrim(comKontodRemote.kood))+','+Alltrim(Str(qrySubKonto.Asutusid))+')')
*!*				lnKr = analise_formula('AKK('+Ltrim(Rtrim(comKontodRemote.kood))+','+Alltrim(Str(qrySubKonto.Asutusid))+')')
				If !Empty(lnAlg)
					Insert Into KaibeAsutusAndmik_report1 (algsaldo, konto, nimetus, asutus, Asutusid) Values ;
						(lnAlg,comKontodRemote.kood, comKontodRemote.nimetus, comAsutusRemote.nimetus, qrySubKonto.Asutusid)
				Endif

			Endscan
		Endscan
	Endif

ENDWITH

If 'EELARVE' $ curkey.versia

	SELECT DISTINCT asutusId From KaibeAsutusAndmik_report1 INTO cursor qryTp_
	Select qryTp_
	Scan
		Select comAsutusRemote
		If Tag() <> 'ID'
			Set Order To Id
		Endif
		Seek qryTp_.asutusId
		If Found()
			Update KaibeAsutusAndmik_report1 Set tp = comAsutusRemote.tp Where asutusId = comAsutusRemote.Id
		Endif
	Endscan
Endif


Select KaibeAsutusAndmik_report1
Delete For Empty (algsaldo)
IF EMPTY(fltrAruanne.konto)
	DELETE FROM KaibeAsutusAndmik_report1 WHERE LEFT(ALLTRIM(konto),3) not in ('102','103','201')
endif
If Reccount('KaibeAsutusAndmik_report1') < 1
	Append Blank
Endif

SET ORDER TO asutus


