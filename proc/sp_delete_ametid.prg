Parameter tnId
Local lError
If empty(tnId)
	Return .f.
Endif
With odb
	.use ('queryAmetid')
	If reccount ('queryAmetid') > 0
		MESSAGEBOX(IIF(config.keel = 2,'Ei saa kustuta amet','Удаление должности не разрешено'),'Kontrol')
		lError =  .f.
	Else
		lError = .t.
	Endif
	If used ('queryAmetid')
		Use in queryAmetid
	Endif
	If lError = .t.
		.use('v_library', 'cursor1')
		.use('v_palk_tmpl', 'cursor2')
		Select cursor1
		Delete all
		Select cursor2
		Delete all
		.opentransaction()
		lError = .cursorupdate('cursor1','v_library')
		IF lError = .t.
			lError = .cursorupdate('cursor2','v_palk_tmpl')
		ENDIF
		IF lError = .t.
			.commit()
		ELSE
			.rollback()
		ENDIF
	Endif
	if used ('cursor1')
		use in cursor1
	endif
	if used ('cursor2')
		use in cursor2
	endif
Endwith
Return lError
