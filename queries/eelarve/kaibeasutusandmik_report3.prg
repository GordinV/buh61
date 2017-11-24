Parameter cWhere
Local lnDeebet, lnKreedit
	Create Cursor KaibeAsutusAndmik_report1 (algsaldo N(12,2),deebet N(12,2),;
		kreedit N(12,2),konto c(20), nimetus c(120), tp c(20), tpNimi c(254), asutus c(120), Asutusid Int, regkood c(20), tunnus c(20), subrekvid int, subrekvnim c(254) null)
	Index On Alltrim(tp)+':' + Alltrim(konto) TAG tp

	Set Order To tp

lnStartAeg = Sys(2)

If gVersia = 'PG'

	IF fltrAruanne.tunnus > 0

		SELECT comTunnusRemote
		LOCATE FOR id = fltrAruanne.tunnus
		lcTunnus = LTRIM(RTRIM(comTunnusRemote.kood))
	ELSE
		lcTunnus = ''
	endif

	lError = oDb.Exec("sp_subkontod_report "," '"+Ltrim(Rtrim(fltrAruanne.konto))+"%',"+;   
	Str(grekv)+","+;
	" DATE("+Str(Year(fltrAruanne.kpv1),4)+","+ STR(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+"),"+;
	" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+	STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
	STR(fltrAruanne.asutusId,9)+",'"+;
	LTRIM(RTRIM(lcTunnus))+"%',4,"+str(fltrAruanne.kond,9),"qryKbAsu")

If Used('qryKbAsu')
	tcTimestamp = Alltrim(qryKbAsu.sp_subkontod_report)
	oDb.Use('tmpsubkontod_report')
	
	
	SELECT KaibeAsutusAndmik_report1
	INSERT INTO KaibeAsutusAndmik_report1 (algsaldo,deebet , kreedit, konto , nimetus , asutus , Asutusid , regkood,tunnus, subrekvid, subrekvnim );
	SELECT tmpsubkontod_report.algjaak	, tmpsubkontod_report.db, tmpsubkontod_report.kr, tmpsubkontod_report.konto, IIF(ISNULL(comKontodRemote.nimetus),SPACE(1),comKontodRemote.nimetus),;
		tmpsubkontod_report.asutus, tmpsubkontod_report.asutusId, tmpsubkontod_report.regkood,tmpsubkontod_report.tunnus, ;
		tmpsubkontod_report.subrekvid, tmpsubkontod_report.nim;
		FROM tmpsubkontod_report LEFT OUTER JOIN comKontodRemote ON tmpsubkontod_report.konto = comKontodremote.kood

	USE IN qryKbAsu
	USE IN tmpsubkontod_report
	
ELSE
	SELECT 0
	RETURN .f.
endif	




Else
	tcKood1 = '%'
	tcKood2 = '%'
	tcKood3 = '%'
	tcKood4 = '%'
	tcKood5 = '%'
	tcTunnus = '%'
	tcKasutaja = '%'
	tcMuud = '%'

	lnDeebet = 0
	lnKreedit = 0
	dKpv1 = Iif(!Empty(fltrAruanne.kpv1), fltrAruanne.kpv1,Date(Year(Date()),1,1))
	dKpv2 = Iif(!Empty(fltrAruanne.kpv2), fltrAruanne.kpv2,Date())

	With odb
		Select comKontodRemote
		Scan For Left(Ltrim(Rtrim(kood)),Len(Ltrim(Rtrim(fltrAruanne.konto)))) = Ltrim(Rtrim(fltrAruanne.konto)) And;
				Len(Alltrim(kood)) = Iif('EELARVE' $ curkey.versia,6,Len(Alltrim(kood)))
			Wait Window 'Arvestan konto: '+comKontodRemote.kood Nowait

			tcCursor = 'CursorAlgSaldo_'
			cKonto = Ltrim(Rtrim(fltrAruanne.konto))+'%'
			TcKonto = cKonto
			tnAsutusId1 = 0
			tnAsutusId2 = 99999999
			tdKpv1 = Date(1999,1,1)
			tdKpv2 = fltrAruanne.kpv1-1
			odb.Use ('qrySaldo2',tcCursor)
			tdKpv1 = fltrAruanne.kpv1
			tdKpv2 = fltrAruanne.kpv2
			tcCursor = 'CursorKaibed_'
			odb.Use ('qrySaldo2',tcCursor)


			lnRecno = Recno('comKontodRemote')
			lcKonto = Ltrim(Rtrim(comKontodRemote.kood))+'%'
			tnid = comKontodRemote.Id
			.Use ('v_subkonto','qrySubkonto')
			Select qrySubKonto
			If fltrAruanne.Asutusid > 0
				Delete For Asutusid <> fltrAruanne.Asutusid
			Endif

			Select qrySubKonto
			Scan
				Select comAsutusRemote
				Seek qrySubKonto.Asutusid

				Wait Window 'Arvestan konto: '+Trim(comKontodRemote.kood)+' Subkonto:'+Trim(comAsutusRemote.nimetus) Nowait

				Select * From CURsorKaibed_ Where Asutusid = qrySubKonto.Asutusid Into Cursor cursorKaibed
				Select * From CURsorAlgsaldo_ Where Asutusid = qrySubKonto.Asutusid Into Cursor cursorAlgsaldo

				If Reccount('cursorAlgsaldo') > 0
					lnAlg = analise_formula('ASD('+Ltrim(Rtrim(comKontodRemote.kood))+','+Alltrim(Str(qrySubKonto.Asutusid))+')', fltrAruanne.kpv1, 'CursorAlgSaldo' )
				Else
					lnAlg = 0
				Endif
				If Reccount('cursorKaibed') > 0

					lnDb = analise_formula('ADK('+Ltrim(Rtrim(comKontodRemote.kood))+','+Alltrim(Str(qrySubKonto.Asutusid))+')',fltrAruanne.kpv1,  'Cursorkaibed')
					lnKr = analise_formula('AKK('+Ltrim(Rtrim(comKontodRemote.kood))+','+Alltrim(Str(qrySubKonto.Asutusid))+')',fltrAruanne.kpv1,  'CursorKaibed')
				Else
					lnDb = 0
					lnKr = 0
				Endif
				Insert Into KaibeAsutusAndmik_report1 (algsaldo, deebet, kreedit, konto, nimetus, asutus, Asutusid, regkood) Values ;
					(lnAlg, lnDb, lnKr, comKontodRemote.kood, comKontodRemote.nimetus, ;
					comAsutusRemote.nimetus, qrySubKonto.Asutusid, comAsutusRemote.regkood)
				Use In  cursorAlgsaldo
				Use In  cursorKaibed
			Endscan


			Select * From CURsorKaibed_ Where Asutusid = 0 Into Cursor cursorKaibed
			Select * From CURsorAlgsaldo_ Where Asutusid = 0 Into Cursor cursorAlgsaldo

			If Reccount('cursorAlgsaldo') > 0
				lnAlg = analise_formula('ASD('+Ltrim(Rtrim(comKontodRemote.kood))+','+Alltrim(Str(0))+')', fltrAruanne.kpv1, 'CursorAlgSaldo' )
			Else
				lnAlg = 0
			Endif
			If Reccount('cursorKaibed') > 0

				lnDb = analise_formula('ADK('+Ltrim(Rtrim(comKontodRemote.kood))+','+Alltrim(Str(0))+')',fltrAruanne.kpv1,  'Cursorkaibed')
				lnKr = analise_formula('AKK('+Ltrim(Rtrim(comKontodRemote.kood))+','+Alltrim(Str(0))+')',fltrAruanne.kpv1,  'CursorKaibed')
			Else
				lnDb = 0
				lnKr = 0
			Endif
			Insert Into KaibeAsutusAndmik_report1 (algsaldo, deebet, kreedit, konto, nimetus, asutus, Asutusid) Values ;
				(lnAlg, lnDb, lnKr, comKontodRemote.kood, comKontodRemote.nimetus, ;
				SPACE(1), 0)
			Use In  cursorAlgsaldo
			Use In  cursorKaibed

		Endscan
	Endwith

Endif
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
			SELECT comTpRemote
			LOCATE FOR kood = comAsutusRemote.tp
			Update KaibeAsutusAndmik_report1 Set tp = comAsutusRemote.tp,;
					tpnimi = comTpRemote.nimetus;
					 Where asutusId = comAsutusRemote.Id
		Endif
	Endscan
Endif

lnFin = Sys(2)
lnAeg = Val(lnFin) - Val(lnStartAeg)

Wait Window 'Kokku aeg:'+Str(lnAeg) Nowait
SELECT sum(algsaldo) as algsaldo, sum(deebet) as deebet,;
		sum(kreedit) as kreedit,konto , nimetus , tp , tpNimi FROM KaibeAsutusAndmik_report1 ;
		GROUP BY tp, tpnimi, konto, nimetus ;
		ORDER BY tp, konto;
		INTO CURSOR KaibeAsutusAndmik_report


