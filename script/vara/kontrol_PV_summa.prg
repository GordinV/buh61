gnHandle = SQLCONNECT('narvalvpg')
IF gnHandle < 0
	MESSAGEBOX('Viga')
	SET STEP ON 
	return
ENDIF
WAIT WINDOW 'PV nimekiri' nowait
lcString = "select kood,id,soetmaks from curPohivara where rekvid = 6 and EMPTY(mahakantud) and id in (select parentid from pv_oper where liik = 1 and kpv = date(2011,09,30))"
lnError = SQLEXEC(gnHandle,lcString,'tmpPv')
IF lnError < 1
	MESSAGEBOX('Viga')
	SET STEP ON 
	return
endif

SELECT tmpPv
SCAN
	WAIT WINDOW 'Kontrollin..'+tmpPv.kood+STR(RECNO('tmpPv'))+'/'+STR(RECCOUNT('tmpPv')) nowait
	lcString = "select summa from pv_oper where liik = 1 and kpv = DATE(2011,09,30) and parentid = "+STR(tmpPv.id)
	lnError = SQLEXEC(gnHandle,lcString,'tmpPvOper')
	IF lnError < 1
		MESSAGEBOX('Viga')
		SET STEP ON 
		exit
	ENDIF
	IF tmpPvOper.summa <> ROUND(tmpPv.soetmaks,2)
		WAIT WINDOW 'Viga summas, parandan..'+tmpPv.kood+STR(RECNO('tmpPv'))+'/'+STR(RECCOUNT('tmpPv')) nowait
		lcString = "update pv_kaart set soetmaks = "+STR(tmpPvOper.summa,18,2) +" where parentid = "+STR(tmpPv.id,9)
		lnError = SQLEXEC(gnHandle,lcstring)
		IF lnError < 0
			MESSAGEBOX('Viga')
			SET STEP ON
			exit
		ENDIF
		WAIT WINDOW 'Viga summas, parandan..tehtud'+tmpPv.kood+STR(RECNO('tmpPv'))+'/'+STR(RECCOUNT('tmpPv')) nowait
		exit		
	ENDIF
ENDSCAN


=SQLDISCONNECT(gnHandle)
