If vartype ( oDb ) <> 'O'
	Set classlib to classes\classlib
	oDb = createobject ( 'db' )
Endif
With oDb
	.use ('v_doklausheader', 'v_doklausheader',.t.)
	.use ('v_doklausend', 'v_doklausend',.t.)
	If !empty (v_journal.dokid )
		Select comDokJournal
		Locate for id = v_journal.dokid
		cDok = comDokJournal.kood
	Else
		cDok = space(1)
	Endif
	Select v_doklausheader
	Insert into v_doklausheader (rekvid, dok, selg);
		values (gRekv, cDok, v_journal.selg )
	Select v_journal1
	Scan for !empty (v_journal1.lausendId) and !empty (v_journal1.summa)
		Insert into v_doklausend (lausendId, percent_, summa, kood1, kood2, kood3, kood4, kood5);
			values (v_journal1.lausendId, 1, v_journal1.summa, v_journal1.kood1,;
			v_journal1.kood2, v_journal1.kood3,v_journal1.kood4, v_journal1.kood5 )
	Endscan
	.opentransaction()
	lResult = .cursorupdate ('v_doklausheader')
	If lResult = .t. and v_doklausheader.id > 0
		Update v_doklausend set parentId = v_doklausheader.id
		lResult = .cursorupdate ('v_doklausend')
	Endif
	If lResult = .t.
		tnid = v_doklausheader.id
		.commit()
	Else
		.rollback()
		Use in v_doklausheader
		Use in v_doklausend
		Messagebox ('Viga','Kontrol')
	Endif
Endwith