With Odb
	.use ('curPuudubSubkontod')
	If !used ('curPuudubSubkontod')
		Return .f.
	Endif
	Select curPuudubSubkontod
	lnrec = reccount ('curPuudubSubkontod')
	Scan
		wait window ('Kokku '+alltrim(str(recno('curPuudubSubkontod')))+'/'+alltrim(str(lnRec))) nowait
		Select comKontodRemote
		Set order to kood
		Seek curPuudubSubkontod.konto
		If found ()
			lnKontoid = comKontodRemote.id
			If !used ('v_subkonto')
				.use ('v_subkonto','v_subkonto',.t.)
			Endif
			Select v_subkonto
			Insert into v_subkonto (rekvid, kontoid, asutusId, aasta) values ;
				(grekv, lnKontoid, curPuudubSubkontod.asutusId, year (date()))
		Endif
	Endscan
	If reccount ('v_subkonto') > 0
		wait window ('Salvestamine ..') nowait
		.opentransaction
		lError = .cursorupdate('v_subkonto')
		If lError = .t.
			.commit()
			select v_subkonto
			browse
			Messagebox('Ok','Kontrol')
			use in v_subkonto
		Else
			.rollback()
			Messagebox('Viga','Kontrol')
			If config.debug = 1
				Set step on
			Endif
		Endif
	Endif
Endwith
if used ('curPuudubSubkontod')
	use in curPuudubSubkontod
endif