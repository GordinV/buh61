Parameter tnId
If Empty(tnId)
	Return .F.
Endif
With oDB
	tnGrupp = tnId
	.Use('comVara')
	IF RECCOUNT('comVara') > 0
		MESSAGEBOX(IIF(config.keel = 2,'Viga: Kustumine ebaхnestus, varagrupp ei ole tьhi','Ошибка: удаление группы не возможно, из-за связанных с группой запасов'),'Kontrol')
		USE IN comVara
		RETURN .f.
	endif
	.Use('v_library','cursor1')
	.Use('v_gruppomandus','cursor2')
	Select cuRsor1
	Delete Next 1
	Select cuRsor2
	DELETE ALL
	.opentransaction()
	lError = .cuRsorupdate('cursor1','v_library')
	IF lError = .t.
		lError = .cuRsorupdate('cursor2','v_gruppomandus')
	ENDIF
	IF lError = .t.
		.commit()
	ELSE
		.rollback()
	ENDIF
	IF USED('comVara')
		USE IN comVara
	endif
	IF USED('cursor1')
		USE IN cursor1
	endif
	IF USED('cursor2')
		USE IN cursor2
	endif
Endwith
Return lError
Endfunc
*
