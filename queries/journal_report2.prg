Parameter tnId
If Vartype (tnId) = 'C'
	tnId = Val(tnId)
Endif
If Empty (tnId) And Used ('curJournal')
	tnId = curJournal.Id
Endif
If Used ('qryjournal')
	Use In qryjournal
Endif
If Used ('qryjournal1')
	Use In qryJournal1
Endif
With oDb
	.Use('v_journal','qryjournal')
	.Use('v_journal1','qryjournal1')
	Create Cursor journal_report1 (Id Int, kpv d, asutus c(254), dok c(120),;
		selg m, deebet c(20), kreedit c(20), lisa_d c(20), lisa_k c(20), Summa Y, kood1 c(20), valuuta c(20), kuurs n(14,4), kood2 c(20),;
		kood3 c(20), kood4 c(20), kood5 c(20), muud m, kasutaja c(120), TUNNUS c(20), proj c(20))
	.Use ('v_journalid','QRYJOURNALNUMBER' )

	Select comAsutusRemote
	Locate For Id = qryjournal.asutusid
	Select qryJournal1

	Scan
		Select journal_report1
		Append Blank

		Replace kpv With qryjournal.kpv,;
			id With QRYJOURNALNUMBER.Number,;
			asutus With Rtrim(comAsutusRemote.nimetus),;
			dok With qryjournal.dok,;
			selg With qryjournal.selg,;
			deebet With qryJournal1.deebet,;
			lisa_d With qryJournal1.lisa_d,;
			lisa_k With qryJournal1.lisa_k,;
			kreedit With qryJournal1.kreedit,;
			kood1 With qryJournal1.kood1,;
			kood2 With qryJournal1.kood2,;
			kood3 With qryJournal1.kood3,;
			kood4 With qryJournal1.kood4,;
			kood5 With qryJournal1.kood5,;
			summa With qryJournal1.Summa,;
			kuurs WITH qryJournal1.kuurs,;
			valuuta WITH qryJournal1.valuuta,;
			tunnus with qryjournal1.tunnus,;
			proj with qryjournal1.proj,;
			muud WITH qryJournal.muud  In journal_report1
	Endscan
	Use In qryjournal
	Use In qryJournal1
Endwith
Select journal_report1
