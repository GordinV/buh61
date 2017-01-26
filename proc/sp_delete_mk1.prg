**
** sp_delete_mk1.fxp
**
Parameter tnId,tlOpt
Local leRror
If EMPTY(tnId)
	Return .F.
Endif
With odB
	.usE('v_mk', 'delMk')
	.usE('v_mk1', 'delMk1')
	If (empty (delMk.doktyyp) and empty (delMk.dokid)) or tlOpt = .t.
		If  .NOT. EMPTY(delMk.arVid)
			tnPankkassa = 1
			.usE('QRYARVTASUDOKID')
		Endif
		.opEntransaction()
		If USED('QRYARVTASUDOKID') .AND. RECCOUNT('QRYARVTASUDOKID')>0
			= sp_delete_tasud(qrYarvtasudokid.id)
		Endif
		If USED('QRYARVTASUDOKID')
			Use IN qrYarvtasudokid
		Endif
		Select delMk1
		Scan
			If  .NOT. EMPTY(delMk1.joUrnalid) and tlOpt = .f.
				= sp_delete_journal(delMk1.joUrnalid)
			Endif
		Endscan
		Select delMk
		Delete NEXT 1
		Select delMk1
		Delete ALL
		leRror = .cuRsorupdate('delMk', 'v_mk')
		If leRror=.T.
			leRror = .cuRsorupdate('delMk1','v_mk1')
		Endif
		If leRror=.T.
			.coMmit()
		Else
			.roLlback()
			Messagebox('Viga', 'Kontrol')
		Endif
	Endif
	If USED('delMk')
		Use IN delMk
	Endif
	If USED('delMk1')
		Use IN delMk1
	Endif
Endwith
Return leRror
Endfunc
*
