Parameter cWhere
Local lnDeebet, lnKreedit

*!*	IF EMPTY(fltrAruanne.konto)
*!*		MESSAGEBOX(IIF(config.keel = 2,'Puudub konto','Отсутствует счет'),'Kontrol')
*!*		SELECT 0
*!*		RETURN .f.
*!*	ENDIF


dKpv1 = Iif(!Empty(fltrAruanne.kpv1), fltrAruanne.kpv1,Date(Year(Date()),1,1))
dKpv2 = Iif(!Empty(fltrAruanne.kpv2), fltrAruanne.kpv2,Date())

Create Cursor KaibeAsutusAndmik_report1 (algsaldo N(12,2),deebet N(12,2),;
	kreedit N(12,2),konto c(20), nimetus c(120), asutus c(120), regkood c(20), Asutusid Int, tp c(20), aadress c(254))
Index On Asutusid Tag Asutusid
Index On Left (Upper (asutus),40) Tag asutus
Index On Alltrim(konto)+':'+Alltrim(Str (Asutusid))  Tag klkonto

Set Order To Asutusid

lcAsutusId = IIF(!EMPTY(fltrAruanne.asutusId),' and asutusId = '+ALLTRIM(STR(fltrAruanne.asutusId,9)),'')

With odb

	If gVersia = 'PG'

		If fltrAruanne.tunnus > 0

			Select comTunnusRemote
			Locate For Id = fltrAruanne.tunnus
			lcTunnus = Ltrim(Rtrim(comTunnusRemote.kood))+'%'
		Else
			lcTunnus = '%'
		Endif
*SET STEP ON

	lcKpv = "date("+STR(YEAR(dKpv2),4)+","+STR(MONTH(dKpv2),2)+","+STR(DAY(dkpv2),2)+")"

* deebet

	lcString = "select asutusId, sum(db-kr) as db  from ( select journal.asutusId, summa * ifnull(dokvaluuta1.kuurs,1)::numeric as db, 0::numeric as kr "+;
		" from journal inner join journal1 on (journal.id = journal1.parentid) left outer join dokvaluuta1 ON (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1) "+;
		" where left(ltrim(rtrim(deebet)),3)  in ('102','103') "+;
		" and asutusid <> 0 "+;
		" and deebet not in ('103701','103950','103009')"+ lcAsutusId+;
		" and deebet = '103000-01' "+;
		" and kpv <= " +lcKpv +lcAsutusId+;
		" and (rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, " + STR(gRekv)+")"+;
		 IIF(fltrAruanne.kond= 1,">3", "=3")+") or rekvid = "+STR(gRekv)+")"+;
		" and tunnus like '"+lcTunnus+"'"+;
		" union all "+;
		" select journal.asutusId, 0::numeric as db, summa * ifnull(dokvaluuta1.kuurs,1)::numeric as kr "+;
		" from journal inner join journal1 on (journal.id = journal1.parentid) left outer join dokvaluuta1 ON (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1) "+;
		" where left(ltrim(rtrim(kreedit)),3)  in ('102','103') "+;
		" and asutusid <> 0 "+;
		" and kreedit not in ('103701','103950','103009')"+lcAsutusId+;
		" and kreedit = '103000-01' "+;
		" and kpv <= "+lcKpv+;
		" and (rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, " + STR(gRekv)+")"+;
		 IIF(fltrAruanne.kond= 1,">3", "=3") +") or rekvid = "+STR(gRekv)+")"+;
		" and tunnus like '"+lcTunnus+"') tmpSubkontod "+;
		" group by asutusId "
	
		

	lError = SQLEXEC(gnHandle,lcString,'tmpDbKaibed')
	SELECT tmpDbKaibed

*!*	* kreedit
*!*		lcString = "select asutusId, sum(kr-db) as kr  from ( select journal.asutusId, summa * ifnull(dokvaluuta1.kuurs,1)::numeric as db, 0::numeric as kr "+;
*!*			" from journal inner join journal1 on (journal.id = journal1.parentid) left outer join dokvaluuta1 ON (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)"+;
*!*			" where (left(ltrim(rtrim(deebet)),3)  in ('201') or deebet = '203900')"+;
*!*			" and asutusid <> 0 "+;
*!*			" and kpv <= " +lcKpv +lcAsutusId+;
*!*			" and (rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, " + STR(gRekv)+")"+;
*!*			 IIF(fltrAruanne.kond= 1,">3", "=3")+") or rekvid = "+STR(grekv)+")"+;
*!*			" and tunnus like '"+lcTunnus+"'"+;
*!*			" union all "+;
*!*			" select journal.asutusId, 0::numeric as db, summa * ifnull(dokvaluuta1.kuurs,1)::numeric as kr "+;
*!*			" from journal inner join journal1 on (journal.id = journal1.parentid) left outer join dokvaluuta1 ON (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1) "+;
*!*			" where (left(ltrim(rtrim(kreedit)),3)  in ('201') or kreedit = '203900')"+;
*!*			" and asutusid <> 0 "+;
*!*			" and kpv <= "+lcKpv+lcAsutusId+;
*!*			" and (rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, " + STR(gRekv)+")"+;
*!*			 IIF(fltrAruanne.kond= 1,">3", "=3")+") or rekvid = "+STR(grekv)+")"+;
*!*			" and tunnus like '"+lcTunnus+"') tmpSubkontod "+;
*!*			" group by asutusId "

*!*		lError = SQLEXEC(gnHandle,lcString,'tmpKrKaibed')

	SELECT asutusid, db, 000000000.00 as kr  from tmpDbKaibed WHERE db <> 0 INTO CURSOR tmpsubkontod
*	UNION ALL ;
*	SELECT asutusid, 000000000.00 as db, kr as kr  from tmpKrKaibed WHERE kr <> 0 INTO CURSOR tmpsubkontod

*	USE IN tmpKrKaibed
	USE IN tmpDBKaibed

	SELECT 	asutusId, sum(db) as db, sum(kr) as kr FROM tmpSubkontod GROUP BY asutusId INTO CURSOR tmpSubkontod_report



*!*			lError = odb.Exec("sp_subkontod_report "," '%',"+;
*!*				Str(grekv)+","+;
*!*				" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+ Str(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
*!*				" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+	Str(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
*!*				STR(fltrAruanne.Asutusid,9)+",'"+;
*!*				LTRIM(Rtrim(lcTunnus))+"%',5,"+str(fltrAruanne.kond,9),"qryKbAsu")


*!*			IF EMPTY(lError)
*!*				SELECT 0
*!*				RETURN .f.
*!*			ENDIF
*!*				tcTimestamp = Alltrim(qryKbAsu.sp_subkontod_report)
*!*				odb.Use('tmpsubkontod_report')
		 
*!*				tcTimestamp = Alltrim(qryKbAsu.sp_subkontod_report1)
*!*				odb.Use('tmpsubkontod_report')


		Select tmpSubkontod_report
		Scan
			Select comAsutusremote
			Locate For Id = tmpSubkontod_report.asutusId

			Insert Into KaibeAsutusAndmik_report1 (asutus , Asutusid , regkood, aadress, deebet, kreedit);
				VALUES (comAsutusremote.nimetus, comAsutusremote.Id, comAsutusremote.regkood, comAsutusremote.aadress,;
				tmpSubkontod_report.db, tmpSubkontod_report.kr)
		Endscan

		Use In tmpSubkontod_report
		Use In tmpSubkontod

		Use In qryKbAsu
		Use In tmpsubkontod_report

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
				Select comAsutusremote
				Seek qrySubKonto.Asutusid

				Wait Window 'Arvestan konto: '+Trim(comKontodRemote.kood)+' Subkonto:'+Trim(comAsutusremote.nimetus) Nowait

				Select * From CURsorAlgsaldo_ Where Asutusid = qrySubKonto.Asutusid Into Cursor cursorAlgsaldo

				lnAlg = analise_formula('ASD('+Ltrim(Rtrim(comKontodRemote.kood))+','+Alltrim(Str(qrySubKonto.Asutusid))+')', fltrAruanne.kpv2, 'cursorAlgsaldo')
*!*				lnDb = analise_formula('ADK('+Ltrim(Rtrim(comKontodRemote.kood))+','+Alltrim(Str(qrySubKonto.Asutusid))+')')
*!*				lnKr = analise_formula('AKK('+Ltrim(Rtrim(comKontodRemote.kood))+','+Alltrim(Str(qrySubKonto.Asutusid))+')')
				If !Empty(lnAlg)
					Insert Into KaibeAsutusAndmik_report1 (algsaldo, konto, nimetus, asutus, Asutusid) Values ;
						(lnAlg,comKontodRemote.kood, comKontodRemote.nimetus, comAsutusremote.nimetus, qrySubKonto.Asutusid)
				Endif

			Endscan
		Endscan
	Endif

Endwith

If 'EELARVE' $ curkey.versia

	Select Distinct Asutusid From KaibeAsutusAndmik_report1 Into Cursor qryTp_
	Select qryTp_
	Scan
		Select comAsutusremote
		If Tag() <> 'ID'
			Set Order To Id
		Endif
		Seek qryTp_.Asutusid
		If Found()
			Update KaibeAsutusAndmik_report1 Set tp = comAsutusremote.tp Where Asutusid = comAsutusremote.Id
		Endif
	Endscan
Endif


Select KaibeAsutusAndmik_report1
Delete For Empty (deebet) AND EMPTY(kreedit)

If Reccount('KaibeAsutusAndmik_report1') < 1
	Append Blank
Endif


