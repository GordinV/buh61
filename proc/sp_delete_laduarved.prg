PARAMETER tnId
IF EMPTY(tnId)
	RETURN .F.
ENDIF
WITH oDb
	leRror = .usE('v_arv')
	leRror = .usE('v_arvread')
	leRror = .usE('v_arv3')
	lnId = v_Arv.joUrnalid
	SELECT v_Arv
	Delete NEXT 1
	SELECT v_Arvread
	Delete all
	SELECT v_Arv3
	Delete all
	.opEntransaction
	leRror = .cuRsorupdate('v_arv')
	IF leRror=.T.
		leRror = .cuRsorupdate('v_arv3')
	ENDIF
	IF leRror=.T.
		lError = .exec ("sp_recalc_ladujaak ",str(gRekv)+",0,"+str(tnId))
		leRror = .cuRsorupdate('v_Arvread')
	ENDIF
	USE IN v_Arvread
	USE IN v_Arv3
	USE IN v_Arv
	IF leRror=.T. .AND.  .NOT. EMPTY(lnId)
		leRror = sp_delete_journal(lnId)
	ENDIF
	IF leRror=.T.
		.coMmit
	ELSE
		.roLlback
		MESSAGEBOX('Viga, ei saa kustuda dokument', 'Kontrol')
	ENDIF
ENDWITH
RETURN leRror
ENDFUNC
*
