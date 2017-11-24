**
** sp_delete_vorder.fxp
**
Parameter tnId, tlopt
If EMPTY(tnId)
	Return .F.
Endif
With odB
	.usE('v_vorder1')
	.usE('v_vorder2')
	If empty (v_vorder1.doktyyp) and empty (v_vorder1.dokid)
		lnId = v_vorder1.joUrnalid
		If  .NOT. EMPTY(v_vorder1.arVid)
			tnPankkassa = 2
			.usE('QRYARVTASUDOKID')
		Endif
		.opEntransaction()
		If USED('QRYARVTASUDOKID') .AND. RECCOUNT('QRYARVTASUDOKID')>0 and tlOpt = .f.
			= sp_delete_tasud(qrYarvtasudokid.id)
		Endif
		If USED('QRYARVTASUDOKID')
			Use IN qrYarvtasudokid
		Endif
		Select v_vorder1
		Delete NEXT 1
		Select v_Vorder2
		Delete ALL
		leRror = .cuRsorupdate('v_vorder1')
		If leRror=.T.
			leRror = .cuRsorupdate('v_vorder2')
		Endif
		If leRror=.T.
			If  .NOT. EMPTY(lnId)
				= sp_delete_journal(lnId,1)
			Endif
			.coMmit()
		Else
			.roLlback()
		Endif
	Endif
Endwith
Use IN v_vorder1
Use IN v_Vorder2
Return .T.
Endfunc
*
