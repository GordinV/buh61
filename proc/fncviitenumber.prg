LPARAMETERS tnLepingId, tnAsutusId, tnArveId
DECLARE a731(7),aInput(7),aTulemus(7)
DO case
	CASE !EMPTY(tnLepingId)
		lcTyyp = '1'
		lcKeha = STR(tnLepingId)
	CASE !EMPTY(tnAsutusId)
		lcTyyp = '3'
		lcKeha = STR(tnAsutusId)
	CASE !EMPTY(tnArveId)
		lcTyyp = '5'
		lcKeha = STR(tnArveId)		
ENDCASE

a731(7) = 7
a731(6) = 3
a731(5) = 1
a731(4) = 7
a731(3) = 3
a731(2) = 1
a731(1) = 7



lcInput = '1'+lcTyyp+fncLisaNullid(ALLTRIM(lcKeha))

lnReaSumma = 0
FOR i = 1 TO 7
	aInput(i) = VAL(SUBSTR(lcInput,i,1))
	aTulemus(i) = aInput(i)*a731(i)
	lnReaSumma = lnReaSumma + aTulemus(i)
ENDFOR
lnKaal = 10 - VAL(RIGHT(ALLTRIM(STR(lnReaSumma)),1))
IF lnKaal = 10
	lnKaal = 0
ENDIF

lcViiteNumber = ALLTRIM(lcInput) + ALLTRIM(STR(lnKaal))
RETURN lcViiteNumber

FUNCTION fncLisaNullid
LPARAMETERS tcNumber
lnI = 5-LEN(ALLTRIM(tcNumber))
FOR i = 1 TO lnI
	tcNumber = '0'+ALLTRIM(tcNumber)
ENDFOR
RETURN tcNumber



ENDFUNC


