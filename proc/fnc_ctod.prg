PARAMETERS tcKpv
LOCAL ldReturn

IF EMPTY(tcKpv)
	ldReturn = {}
endif
tcKpv = ALLTRIM(tcKpv)

lcKpv = right(tcKpv,2)+'.'+SUBSTR(tcKpv,5,2)+'.'+LEFT(tcKpv,4)

ldReturn = CTOD(lcKpv)

RETURN ldReturn
