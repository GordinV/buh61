PARAMETERS tcValuuta, tdKpv
LOCAL lnReturn, lcAlias
*SET STEP ON 
lnreturn = 0

IF EMPTY(tdKpv)
	tdKpv = DATE()
ENDIF

lcAlias = ALIAS()
IF YEAR(tdKpv) < 2011 AND tcValuuta = 'EEK'
	lnReturn = 1
ELSE
	SELECT comValuutaRemote
	LOCATE FOR ALLTRIM(UPPER(kood)) = ALLTRIM(UPPER(tcValuuta)) AND ;
		(EMPTY(tun4) OR tun4 <= VAL(DTOC(tdKpv,1))) AND ;
		(EMPTY(tun5) OR tun5 >= VAL(DTOC(tdKpv,1)))
	IF FOUND()
		lnReturn = 1
	ENDIF
ENDIF

	
SELECT (lcAlias)

RETURN lnReturn