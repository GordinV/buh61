*Clear All


gnhandle = SQLConnect ('narvalvpg')
If gnhandle < 0
	Messagebox('Viga connection','Kontrol')
	Set Step On
	Return
Endif
grekv = 61
gversia = 'PG'


Local lError
=sqlexec (gnhandle,'begin work')
Set Step On
lError = _alter_pg ()
If Vartype (lError ) = 'N'
	lError = Iif( lError = 1,.T.,.F.)
Endif
If lError = .F.
	=sqlexec (gnhandle,'ROLLBACK WORK')
Else
	=sqlexec (gnhandle,'COMMIT WORK')
*!*		Wait Window 'Grant access to views' Nowait
*!*		lError =pg_grant_views()
*!*		Wait Window 'Grant access to tables' Nowait
*!*		lError = pg_grant_tables()
Endif
=SQLDISCONNECT(gnhandle)
If Used('qryLog')
	Copy Memo qryLog.Log To Buh60Dblog.Log
	Use In qryLog
Endif

Function _alter_pg
	

	lcString = "select vanemtasu1.isikkood, vanemtasu2.id, vanemtasu2.tunnus "+;
		"from vanemtasu1 inner join vanemtasu2 on vanemtasu1.id = vanemtasu2.isikid where vanemtasu2.rekvid = 61"
	lnError = SQLEXEC(gnHandle,lcString, 'tmp_lapsed')
	SELECT tmp_lapsed
	SCAN
		WAIT WINDOW tmp_lapsed.isikkood + STR(RECNO('tmp_lapsed'))+'/'+STR(RECCOUNT('tmp_lapsed')) nowait
		lcKood = ALLTRIM(tmp_lapsed.isikkood) + RIGHT(ALLTRIM(tmp_lapsed.tunnus),2)
		lcVN = fnc_get_VN(lcKood)
		IF !EMPTY(lcVN)
			lcString = "update vanemtasu2 set number = '"+lcVN+"' where id = " + STR(tmp_lapsed.id) 
			lnError = SQLEXEC(gnHandle,lcString)
			IF lnError < 1
				SET STEP ON 
				exit
			endif
		endif
	ENDSCAN
		
	
	Return lnError
ENDFUNC

FUNCTION fnc_get_VN
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
