gnHandle1 = SQLCONNECT('narvalvpg')

IF gnHandle1 < 0
	=MESSAGEBOX('Viga, gnHandle1')
ENDIF

gnHandle2 = SQLCONNECT('narvalv2010')

IF gnHandle2 < 0
	=MESSAGEBOX('Viga, gnHandle1')
ENDIF

IF gnHandle1 < 0 OR gnHandle2 < 0
	=SQLDISCONNECT(gnHandle1)
	=SQLDISCONNECT(gnHandle2)
	return
ENDIF
*SET STEP ON 
=import_eeltaitmine()

=SQLDISCONNECT(gnHandle1)
=SQLDISCONNECT(gnHandle2)


FUNCTION import_eeltaitmine
lcString = "select * from eeltaitmine where aasta = 2010"
lError = SQLEXEC(gnHandle2,lcString,'qryArhiiv')

IF !USED('qryArhiiv') OR lError < 1
	MESSAGEBOX('Error')
	SET STEP ON 
	return
ENDIF

SELECT qryArhiiv
SCAN
	WAIT WINDOW 'Import:'+STR(RECNO('qryArhiiv'))+'/'+str(RECCOUNT('qryArhiiv')) nowait
	lcString = "INSERT INTO eeltaitmine (rekvid, aasta, kuu, kood1, kood2, kood3, kood4, kood5, objekt, proj, summa) VALUES ("+;
		STR(qryArhiiv.rekvid,9)+","+STR(qryArhiiv.aasta,4)+","+STR(qryArhiiv.kuu,2)+",'"+ALLTRIM(qryArhiiv.kood1)+"','"+;
		ALLTRIM(qryArhiiv.kood2)+"','"+ALLTRIM(qryArhiiv.kood3)+"','"+ALLTRIM(qryArhiiv.kood4)+"','"+ALLTRIM(qryArhiiv.kood5)+"','"+;
		ALLTRIM(qryArhiiv.objekt)+"','"+ALLTRIM(qryArhiiv.proj)+"',"+STR(qryArhiiv.summa,18,2)+")"
	lError = SQLEXEC(gnHandle1,lcstring)
	IF lError < 1
		MESSAGEBOX('Error')
		SET STEP ON 
		exit	
	ENDIF
	
	
ENDSCAN



END FUNC



FUNCTION arvesta_andmed

* Arvestame 2010 aasta
lcString = "select id, nimetus from rekv where parentid < 200"
lnError = SQLEXEC(gnHandle2,lcString,'qryRekv')
IF lnError < 0 OR !USED('qryRekv')
	=MESSAGEBOX('Viga')
	SET STEP ON 
ENDIF
IF USED('qryRekv')
	SELECT qryRekv
	scan
		FOR i = 1 TO 12
			WAIT WINDOW 'Arvestan'+STR(i)+'kuu '+ALLTRIM(qryRekv.nimetus)+STR(RECNO('qryRekv'))+'/'+STR(RECCOUNT('qryRekv')) nowait			
			ldKpv = DATE(2010,i,1)
			ldKpv = GOMONTH(ldKpv,1)-1
			lcKpv = "date(2010,"+STR(MONTH(ldKpv),2)+","+STR(DAY(ldKpv),2)+")"
			lcString = "select sp_koosta_kassakulud ("+STR(qryRekv.id)+","+lcKpv+",2010,1)"
			lnError = SQLEXEC(gnHandle2,lcString)
			IF lnError < 1
				=messagebox('Error')
				SET STEP ON 
			ENDIF			
		ENDFOR
	ENDSCAN	
ENDIF

END function



