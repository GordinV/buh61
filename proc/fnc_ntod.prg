LPARAMETER tnDate
LOCAL ldReturn, lcDate, lnAasta, lnKuu, lnPaev, lTest
ldreturn = {}
IF EMPTY(tndate) OR ISNULL(tnDate)
	tndate = 20121105
	ltest = .t.
*	RETURN ldReturn
ENDIF
lcdate = ALLTRIM(STR(tnDate))
lnAasta = VAL(LEFT(lcDate,4))
lnKuu = VAL(SUBSTR(lcDate,5,2))
lnPaev = VAL(SUBSTR(lcDate,7,2))
ldReturn = DATE(lnAasta,lnKuu,lnPaev)
IF lTest 
	WAIT WINDOW DTOC(ldReturn)
ENDIF


RETURN ldReturn