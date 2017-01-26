Parameter cWhere

Local lnDeebet, lnKreedit
tcAllikas = '%'
tcArtikkel = '%'
tcTegev = '%'
tcObjekt = '%'
tcEelAllikas = '%'
tcKasutaja = '%'
tcMuud = '%'

* lisatud 22/05
IF USED ('curSaldo')
	USE IN curSaldo
ENDIF


Create Cursor KontoAsutusAndmik_report (algsaldo N(18,6),loppsaldo N(18,6),deebet N(18,6), journalid Int,;
	kreedit N(18,6),konto c(20), korrkonto c(20), nimetus c(120), dok c(120), kpv d, asutus c(254), asutusId Int,;
	fin c(20), tulu c(20), kulu c(20), tegev c(20), allikas c(20), regkood c(20), tunnus c(20), tp c(20), subrekvid int, subrekvnim c(254) null)



If gVersia = 'PG'

	If fltrAruanne.tunnus > 0

		Select comTunnusRemote
		Locate For Id = fltrAruanne.tunnus
		lcTunnus = Ltrim(Rtrim(comTunnusRemote.kood))
	Else
		lcTunnus = ''
	Endif

	lError = oDb.Exec("sp_subkontod_report "," '"+Ltrim(Rtrim(fltrAruanne.konto))+"%',"+;
		Str(grekv)+","+;
		" DATE("+Str(Year(fltrAruanne.kpv1),4)+","+ Str(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+"),"+;
		" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+	Str(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
		STR(fltrAruanne.asutusId,9)+",'"+;
		LTRIM(Rtrim(lcTunnus))+"%',2,"+str(fltrAruanne.kond,9),"qryKbAsu")

	If Used('qryKbAsu')
		tcTimestamp = Alltrim(qryKbAsu.sp_subkontod_report)
		oDb.Use('tmpsubkontod_report')

		Select KontoAsutusAndmik_report
		Insert Into KontoAsutusAndmik_report (algsaldo, deebet , kreedit, loppsaldo, konto , nimetus , asutus , asutusId , regkood,;
			korrkonto, tunnus, tegev, kulu, dok, allikas, fin, journalid, kpv, subrekvid, subrekvnim);
			SELECT tmpsubkontod_report.algjaak	, tmpsubkontod_report.db, tmpsubkontod_report.kr, tmpsubkontod_report.loppjaak,;
			tmpsubkontod_report.konto, Iif(Isnull(comKontodRemote.nimetus),Space(1),comKontodRemote.nimetus),;
			tmpsubkontod_report.asutus, tmpsubkontod_report.asutusId, tmpsubkontod_report.regkood,;
			tmpsubkontod_report.korkonto, tmpsubkontod_report.tunnus, tmpsubkontod_report.kood1, tmpsubkontod_report.kood5, ;
			tmpsubkontod_report.dok, tmpsubkontod_report.kood2, tmpsubkontod_report.kood3,;
			tmpsubkontod_report.lausend, tmpsubkontod_report.dokkpv,;
			tmpsubkontod_report.subrekvid, tmpsubkontod_report.subrekvnim;
			FROM tmpsubkontod_report Left Outer Join comKontodRemote On tmpsubkontod_report.konto = comKontodRemote.kood 

		Use In qryKbAsu
		Use In tmpsubkontod_report

		Select KontoAsutusAndmik_report
		

	Else
		Select 0
		Return .F.
	Endif




Else


	If !Empty(fltrAruanne.asutusId)
		Select comAsutusRemote
		Seek fltrAruanne.asutusId
		cAsutus = Ltrim(Rtrim(comAsutusRemote.nimetus))+'%'
	Else
		cAsutus = '%'
	Endif

	With oDb
		Select comKontodRemote
		Scan For Left(Ltrim(Rtrim(kood)),Len(Ltrim(Rtrim(fltrAruanne.konto)))) = Ltrim(Rtrim(fltrAruanne.konto)) And;
				Len(Alltrim(kood)) = Iif('EELARVE' $ curkey.versia,6,Len(Alltrim(kood)))
			Wait Window 'Arvestan konto: '+comKontodRemote.kood Nowait
			tcKood1 = '%'
			tcKood2 = '%'
			tcKood3 = '%'
			tcKood4 = '%'
			tcKood5 = '%'
			tcTunnus = '%'
			tcproj = '%'
			tcUritus = '%'
			dKpv1 = fltrAruanne.kpv1
			dKpv2 = fltrAruanne.kpv2
			cDeebet = Ltrim(Rtrim(comKontodRemote.kood))+'%'
			cKreedit = '%'
			cDok = '%'
			cSelg = '%'
			nSumma1 = -99999999
			nSumma2 = 999999999
			tcTpD = '%'
			tcTpK = '%'

			.Use('curJournal','JournalQuery1')
			Select Journalquery1
			Scan
				lcKorrkonto = Journalquery1.kreedit
				Insert Into KontoAsutusAndmik_report (konto, korrkonto, asutusId,  asutus, deebet, kreedit, nimetus, dok,;
					kpv, journalid);
					values (Journalquery1.deebet, lcKorrkonto, Journalquery1.asutusId,  Journalquery1.asutus,;
					Journalquery1.Summa, 0,Journalquery1.selg,;
					Journalquery1.dok, Journalquery1.kpv, Journalquery1.Number)
			Endscan
			cKreedit = Ltrim(Rtrim(comKontodRemote.kood))+'%'
			cDeebet = '%'
			.Use('curJournal','JournalQuery1')
			Select Journalquery1
			Scan
				lcKorrkonto = Journalquery1.deebet
				Insert Into KontoAsutusAndmik_report (konto, korrkonto, asutusId,  asutus, deebet, kreedit, nimetus, dok,;
					kpv, journalid);
					values (Journalquery1.kreedit, lcKorrkonto, Journalquery1.asutusId,  Journalquery1.asutus,;
					0, Journalquery1.Summa, Journalquery1.selg,;
					Journalquery1.dok, Journalquery1.kpv, Journalquery1.Number)
			Endscan

			tcCursor = 'CursorAlgSaldo_'
			cKonto = Ltrim(Rtrim(fltrAruanne.konto))+'%'
			TcKonto = cKonto
			tnAsutusId1 = 0
			tnAsutusId2 = 99999999
			tdKpv1 = Date(1999,1,1)
			tdKpv2 = fltrAruanne.kpv1-1
			oDb.Use ('qrySaldo2',tcCursor)


			tnid = comKontodRemote.Id
			.Use ('v_subkonto','qrySubkonto')
			Select qrySubKonto
			If fltrAruanne.asutusId > 0
				Delete For asutusId <> fltrAruanne.asutusId
			Endif

			Scan

				Select * From CURsorAlgsaldo_ Where asutusId = qrySubKonto.asutusId Into Cursor cursorAlgsaldo

				lnAlg = analise_formula('ASD('+Ltrim(Rtrim(comKontodRemote.kood))+','+Alltrim(Str(qrySubKonto.asutusId))+')', fltrAruanne.kpv1-1, 'CursorAlgSaldo')
				Select KontoAsutusAndmik_report
				Sum deebet For asutusId = qrySubKonto.asutusId To lnDb
				Sum kreedit For asutusId = qrySubKonto.asutusId To lnKr
				Select KontoAsutusAndmik_report
				Locate For konto = comKontodRemote.kood And asutusId = qrySubKonto.asutusId
				If !Found()
					Append Blank
					Select comAsutusRemote
					Seek qrySubKonto.asutusId
					Replace konto With comKontodRemote.kood,;
						asutusId With qrySubKonto.asutusId,;
						asutus With comAsutusRemote.nimetus In KontoAsutusAndmik_report

				Endif
				Update KontoAsutusAndmik_report Set algsaldo = lnAlg,;
					loppsaldo = lnAlg + lnDb - lnKr;
					Where konto = comKontodRemote.kood;
					AND asutusId = qrySubKonto.asutusId
			Endscan
		Endscan
	Endwith
Endif
If Used('Journalquery1')
	Use In Journalquery1
Endif

If 'EELARVE' $ curkey.versia

	SELECT DISTINCT asutusId From KontoAsutusAndmik_report INTO cursor qryTp_
	Select qryTp_
	Scan
		Select comAsutusRemote
		If Tag() <> 'ID'
			Set Order To Id
		Endif
		Seek qryTp_.asutusId
		If Found()
			Update KontoAsutusAndmik_report Set tp = comAsutusRemote.tp Where asutusId = comAsutusRemote.Id
		Endif
	Endscan
Endif

Select * From KontoAsutusAndmik_report Order By konto, asutus, subrekvid, kpv ;
	where !Empty (algsaldo) Or !Empty (deebet) Or !Empty (kreedit) Or !Empty (loppsaldo);
	into Cursor KontoAsutusAndmik_report1
Use In KontoAsutusAndmik_report


Select KontoAsutusAndmik_report1
