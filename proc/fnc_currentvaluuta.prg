PARAMETERS tcOpt, tdKpv

LOCAL lReturn, lcAlias

IF EMPTY(tdKpv)
	tdKpv = DATE()
ENDIF

lcAlias = ALIAS()

DO case
	CASE tcOpt = 'VAL'
		IF !USED('comValuutaRemte')
			odb.use('comValuutaRemote')
		ENDIF
		SELECT comValuutaRemote
		LOCATE FOR !EMPTY(comValuutaRemote.tun1)
		IF FOUND()
			lReturn = comValuutaRemote.kood
		ELSE
			lReturn = 'EEK'
		ENDIF
		
	CASE tcOpt = 'KUURS'	
		IF !USED('comValuutaRemte')
			odb.use('comValuutaRemote')
		ENDIF
		SELECT comValuutaRemote
		LOCATE FOR !EMPTY(comValuutaRemote.tun1)
		IF FOUND()
			lReturn = comValuutaRemote.kuurs
		ELSE
			lReturn = 1
		ENDIF
ENDCASE'
IF !EMPTY(lcAlias)
	SELECT (lcAlias)
ENDIF

RETURN lReturn