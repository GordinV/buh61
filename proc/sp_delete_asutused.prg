**
** sp_delete_asutused.fxp
**
Parameter tnId
If EMPTY(tnId)
	Return .F.
Endif
With oDb
	.use ('QRYASUTUSDELETE')
	If reccount ('QRYASUTUSDELETE') < 1
		.usE('v_asutus','cursor1')
		.usE('v_asutusaa','cursor2')
		Select cuRsor1
		Delete NEXT 1
		Select cuRsor2
		Delete all
		.opentransaction()
		leRror = .cuRsorupdate('cursor1','v_asutus')
		If leRror = .t.
			leRror = .cuRsorupdate('cursor2','v_asutusaa')
		Endif
		If leRror = .t.
			.commit()
		Else
			.rollback()
		Endif
		Use IN cuRsor1
		Use IN cuRsor2
	Else
		Messagebox(IIF(coNfig.keEl=2,  ;
			'Ei saa kustuta kaart sest on seotatud dokumendid',  ;
			'Нельзя удалить карточку, т.к. есть связанные с ней документы' ;
			), 'Kontrol')
		Return .F.

	Endif
	If used ('QRYASUTUSDELETE')
		Use in QRYASUTUSDELETE
	Endif
Endwith
Return leRror
Endfunc
*
