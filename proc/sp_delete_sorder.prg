**
** sp_delete_sorder.fxp
**
Parameter tnId, tlOpt
If EMPTY(tnId)
	Return .F.
Endif
With odB
	.usE('v_sorder1')
	.usE('v_sorder2')
	If  .NOT. EMPTY(v_Sorder1.arVid)
		tnPankkassa = 2
		.usE('QRYARVTASUDOKID')
	Endif
	.opEntransaction()
	If USED('QRYARVTASUDOKID') .AND. RECCOUNT('QRYARVTASUDOKID')> 0 and tlOpt = .f.
		= sp_delete_tasud(qrYarvtasudokid.id)
	Endif
	If USED('QRYARVTASUDOKID')
		Use IN qrYarvtasudokid
	Endif
	Select v_Sorder1
	lnId = v_Sorder1.joUrnalid
	Delete NEXT 1
	Select v_Sorder2
	Delete ALL
	leRror = .cuRsorupdate('v_sorder1')
	If leRror=.T.
		leRror = .cuRsorupdate('v_sorder2')
	Endif
	If  .NOT. EMPTY(lnId) and tlOpt = .f.
		= sp_delete_journal(lnId,1)
	Endif

	If leRror=.T.
		.coMmit()
	Else
		.roLlback()
	Endif
Endwith
Use IN v_Sorder1
Use IN v_Sorder2
Return .T.
Endfunc
*
