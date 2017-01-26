LPARAMETERS tcKood
local lcReturn, lnNumber, lnSumma, lnDigit, ln731, lnKalu 
lcReturn = tcKood
lnSumma = 0
FOR i =1 TO LEN(tcKood)
	DO case
		CASE EMPTY(ln731)
			ln731 = MOD(LEN(tcKood),3)
			ln731 = IIF(ln731 = 1,7,IIF(ln731 = 2,3,1))
		CASE ln731 = 1
			ln731 = 3	
		CASE ln731 = 7
			ln731 = 1
		CASE ln731 = 3
			ln731 = 7 
	ENDCASE
	
	
	lnDigit = VAL(ALLTRIM(SUBSTR(tcKood,i,1)))
	lnSumma = lnSumma + lnDigit * ln731


endfor
*WAIT WINDOW STR(lnDigit)+'-'+STR(lnSumma) TIMEOUT 1
lnKalu =  CEILING(lnSumma /10)
*	WAIT WINDOW 'lnkalu:' + STR(lnkalu) TIMEOUT 1

lnKalu = lnKalu * 10 - lnSumma
RETURN tcKood + ALLTRIM(STR(lnKalu))
