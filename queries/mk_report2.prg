Parameter tnId
Local lcFin, lcTulu, lcKulu, lctegev
If vartype (tnId) = 'C'
	tnId = val(alltrim(tnId))
Endif
If empty (tnId) and used ('curMk')
	tnId = curMk.id
Endif
With oDb
	.use('v_mk','qryMk')
	.use('v_mk1','qryMk1')
	Create cursor mk_report1 (id int, kpv d, asutus c(254),maksepaev d, number c(20),pank c(3), aa c(20),;
		selg m, nimetus c(254), viitenr c(120),kokku y, summa y, fin c(20), tulu c(20),regkood c(11),;
		kulu c(20), tegev c(20), eelallikas c(20), lausnr int, lausend m, valuuta c(20), kuurs n(14,4))
*!*	if !empty (v_mk.journal)
*!*		.use ('v_journalid','QRYJOURNALNUMBER' )
	Select qrymk1
	Scan
		lclausend = ''
		lnLausNr = 0
		If !empty (qrymk1.journalid)
			tnId =qrymk1.journalid
			tnAasta = year (qryMk.maksepaev)
			.use ('QRYJOURNALNUMBER')
			If reccount ('QRYJOURNALNUMBER') > 0
				lnLausNr = QRYJOURNALNUMBER.number
				tnId = QRYJOURNALNUMBER.journalid
				.use ('v_journal1','qryJournal1')
				Select qryJournal1
				Scan
					lcFin = ''
					lcTulu = ''
					lcKulu = ''
					lctegev = ''
					If !empty (qryJournal1.kood1)
						Select comObjektRemote
						If order() <> 'ID'
							Set order to id
						Endif
						Seek qryJournal1.kood1
						lcFin = comObjektRemote.kood
					Endif
					If !empty (qryJournal1.kood2)
						Select comAllikasRemote
						If order() <> 'ID'
							Set order to id
						Endif
						Seek qryJournal1.kood2
						lcTulu = comAllikasRemote.kood
					Endif
					If !empty (qryJournal1.kood3)
						Select comArtikkelRemote
						If order() <> 'ID'
							Set order to id
						Endif
						Seek qryJournal1.kood3
						lcKulu = comArtikkelRemote.kood
					Endif
					If !empty (qryJournal1.kood4)
						Select comTegevRemote
						If order() <> 'ID'
							Set order to id
						Endif
						Seek qryJournal1.kood4
						lctegev = comTegevRemote.kood
					Endif


					lclausend =  lclausend + 'D '+ltrim(rtrim(qryJournal1.deebet))+space(1)+;
						'K '+ltrim(rtrim(qryJournal1.kreedit)) + space(1)+;
						alltrim(str (qryJournal1.summa,12,2)) + space(1)+;
						lcFin+space(1)+lcTulu+space(1)+lcKulu+space(1)+lctegev +chr(13)
				Endscan
			Endif
		Endif

		Select comNomRemote
		Locate for id = qrymk1.nomid
		Select comAsutusRemote
		Locate for id = qrymk1.asutusid
		Insert into mk_report1 (kpv, asutus,regkood, maksepaev, number, pank, aa, selg, nimetus, viitenr, summa, lausnr, lausend, valuuta, kuurs);
			values (qryMk.kpv, comAsutusRemote.nimetus,comAsutusRemote.regkood, qryMk.maksepaev, qryMk.number, qrymk1.pank, qrymk1.aa, qryMk.selg,;
			comNomRemote.nimetus, qryMk.viitenr, qrymk1.summa,lnLausNr, lclausend, qryMk1.valuuta, qryMk1.kuurs )
	Endscan
	Sum summa to lnKokku
	Use in qrymk1
	Use in qryMk
	Update mk_report1 set kokku = lnKokku
	If used ('QRYJOURNALNUMBER')
		Use in QRYJOURNALNUMBER
	Endif
Endwith

Select mk_report1
