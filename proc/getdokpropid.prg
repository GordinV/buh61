**
** getdokpropid.fxp
**
LPARAMETER tcTyyp
LOCAL lnId
lnId = 0
IF !USED('comDokRemote') OR RECCOUNT('comDokRemote') = 0
	oDb.use('comDokRemote')
ENDIF

SELECT coMdokremote
LOCATE For ALLTRIM(UPPER(koOd))=ALLTRIM(UPPER(tcTyyp))
IF  .Not. Found()
	RETURN 0
ENDIF
tnId = coMdokremote.Id
odB.Use('curDokProp')
IF Reccount('curDokProp')>1
	lcForm = 'validok'
	DO Form (lcForm) To lnId With tnId
ELSE
	IF Reccount('curDokProp')<1
		IF  'RAAMA' $ curKey.VERSIA
			CREATE Cursor cMessage (prOp1 Int)
			INSERT Into cMessage (prOp1) Values (coMdokremote.Id)
			lcForm = 'dokprop'
			DO Form (lcForm) To lnId With 'ADD', 0
		ELSE
			lnId = 0
		ENDIF
	ELSE
		lnId = cuRdokprop.Id
	ENDIF
ENDIF
IF Used('curDokprop')
	USE In cuRdokprop
ENDIF
RETURN lnId
ENDFUNC
*
