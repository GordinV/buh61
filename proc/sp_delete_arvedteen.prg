PARAMETER tnId
local lError
lError = .t.
IF EMPTY(tnId)
	RETURN .F.
ENDIF
WITH oDb
	.usE('v_arv')
	.usE('v_arvread')
	.usE('v_arv3')
	.opEntransaction()
	lnId = v_Arv.joUrnalid
	SELECT v_Arv
	Delete NEXT 1
	SELECT v_Arvread
	Delete all
	SELECT v_Arv3
	Delete all
	lError = .cuRsorupdate('v_arv')
	IF lError = .t.
		lError = .exec ("sp_recalc_ladujaak ",str(gRekv)+",0,"+str(tnId))
		lError = .cuRsorupdate('v_arvread')
	ENDIF
	IF lError = .t.
		lError = .cuRsorupdate('v_arv3')
	ENDIF
	USE IN v_Arv
	USE IN v_Arvread
	USE IN v_Arv3
	IF  .NOT. EMPTY(lnId)
		= sp_delete_journal(lnId)
	ENDIF
	IF lError=.F.
		.roLlback()
		MESSAGEBOX('Viga', 'Kontrol')
	ELSE
		.coMmit()
	ENDIF
ENDWITH
return lError
ENDFUNC
*
