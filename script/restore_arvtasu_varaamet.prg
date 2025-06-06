gnHandle = SQLConnect('narvalv2009','vlad')
gnHandle2010 = SQLConnect('narvalvpg','vlad')

IF gnHandle < 0
	return
ENDIF 

lcString = "select * from arvtasu where rekvid = 6 and YEAR(kpv) < 2010"

lResult = SQLEXEC(gnHandle,lcString,'tmpArvTasu')

IF lResult < 1
	SET STEP ON 
	return
ENDIF

SELECT tmpArvTasu

SCAN
	WAIT WINDOW 'Kontrollin ..:'+STR(RECNO('tmpArvTasu'))+'/'+STR(RECCOUNT('tmpArvTasu')) nowait
	lcString =  "select id from arvtasu where id = "+STR(tmpArvTasu.id,9)
	lResult = SQLEXEC(gnHandle,lcString,'qry1')
	IF USED('qry1') AND RECCOUNT('qry1') > 0 
		WAIT WINDOW 'Kontrollin : kiri on olemas'+STR(RECNO('tmpArvTasu'))+'/'+STR(RECCOUNT('tmpArvTasu')) nowait
		
	ELSE
		WAIT WINDOW 'Kontrollin : kiri puudub, lisame'+STR(RECNO('tmpArvTasu'))+'/'+STR(RECCOUNT('tmpArvTasu')) nowait
		lcString = " insert into arvtasu (id, rekvid, arvid, kpv, summa, dok, nomid, pankkassa, journalid, sorderid, doklausid) values ("+;
			STR(tmpArvTasu.id)+","+STR(tmpArvTasu.rekvid)+","+STR(tmpArvTasu.arvid)+",DATE("+;
			STR(YEAR(tmpArvTasu.kpv),4)+","+STR(MONTH(tmpArvTasu.kpv),2)+","+STR(DAY(tmpArvTasu.kpv),2)+"),"+;
			STR(tmpArvTasu.summa,14,2)+", SPACE(1),"+STR(tmpArvTasu.nomid)+","+STR(tmpArvTasu.pankkassa)+",0,"+;
			STR(tmpArvTasu.sorderid)+","+STR(tmpArvTasu.doklausId)+")	

		lResult = SQLEXEC(gnHandle2010,lcString)
		IF lResult < 0
			SET STEP ON 
			exit
		ENDIF
		
	ENDIF
	
ENDSCAN



=SQLDISCONNECT(gnHandle)

=SQLDISCONNECT(gnHandle2010)

