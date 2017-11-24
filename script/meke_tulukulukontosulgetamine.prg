gnHandle = SQLCONNECT('meke')

IF gnHandle < 1
	MESSAGEBOX('Viga uhendus')
	return
ENDIF
*lausend
CREATE CURSOR dblausend (konto c(20), summa n(18,2))
CREATE CURSOR krlausend (konto c(20), summa n(18,2))


* kaibeandmink

lcString = " select sp_kaibeandmik_report ('%',1,DATE(2011,12,31),DATE(2011,12,31),'%',1,0)"
lnError = SQLEXEC(gnHandle,lcString,'tmpTulemus')
*SET STEP on
IF lnError > 0
	lcString = "select konto, algdb, algkr, db, kr from tmp_kaibeandmik_report where timestamp = '"+ Alltrim(tmpTulemus.sp_kaibeandmik_report)+"' order by konto"
	lnError = sqlexec(gnHandle,lcString,'qryKaibeandmik')
*brow
	IF lnError < 0
		SET STEP ON 
		=SQLDISCONNECT(gnHandle)
		return
	ENDIF
	 
	
	Select qryKaibeandmik
	SCAN FOR VAL(LEFT(ALLTRIM(qryKaibeandmik.konto),1))>2 AND VAL(LEFT(ALLTRIM(qryKaibeandmik.konto),1))<7 
		WAIT WINDOW qryKaibeandmik.konto nowait
		lnSumma = qryKaibeandmik.algdb - qryKaibeandmik.algkr + qryKaibeandmik.db - qryKaibeandmik.kr
		IF lnSumma > 0 
			INSERT INTO dblausend (konto, summa) VALUES (qryKaibeandmik.konto,lnSumma)
		ELSE
			INSERT INTO krlausend (konto, summa) VALUES (qryKaibeandmik.konto,-1*lnSumma)
		
		ENDIF
		
	ENDSCAN
	
ELSE
	SET STEP ON 	
endif

* salvestame lausendid
* tulud
* pealkiri
lnJournalId = 0
lcString = "insert into journal (rekvid,userid,kpv,asutusid, selg) values (1,1,DATE(2014,12,31),0,'Tulemus, tulud')"
lnError = SQLEXEC(gnHandle,lcString)
IF lnError < 0
	SET STEP ON 
ELSE
	* id
	lnError = SQLEXEC(gnHandle,"select id from journal order by id desc limit 1",'tmpJournal')
	IF lnError > 0 AND USED('tmpJournal')
		lnJournalId = tmpJournal.id
	ENDIF
ENDIF
IF lnJournalId > 0
	SELECT krlausend
	WAIT WINDOW 'Tulud:'+krlausend.konto nowait
	SCAN
		lcString = "insert into journal1(parentid,summa,deebet,kreedit,valuuta,kuurs, valsumma) values("+;
			STR(lnJournalId,9)+","+	STR(krlausend.summa,16,2)+",'"+krlausend.konto+"','298000','EEK',1,"+STR(krlausend.summa,16,2)+")"
		lnError = SQLEXEC(gnHandle,lcString)
		IF lnError < 0
			SET STEP ON 
			exit
		ENDIF

	ENDSCAN
ENDIF
lnJournalId = 0
lcString = "insert into journal (rekvid,userid,kpv,asutusid, selg) values (1,1,DATE(2014,12,31),0,'Tulemus, kulud')"
lnError = SQLEXEC(gnHandle,lcString)
IF lnError < 0
	SET STEP ON 
ELSE
	* id
	lnError = SQLEXEC(gnHandle,"select id from journal order by id desc limit 1",'tmpJournal')
	IF lnError > 0 AND USED('tmpJournal')
		lnJournalId = tmpJournal.id
	ENDIF
ENDIF
IF lnJournalId > 0
	SELECT dblausend
	WAIT WINDOW 'Kulud:'+dblausend.konto nowait
	SCAN
		lcString = "insert into journal1(parentid,summa,kreedit,deebet, valuuta,kuurs, valsumma) values("+;
			STR(lnJournalId,9)+","+	STR(dblausend.summa,16,2)+",'"+dblausend.konto+"','298000','EEK',1,"+STR(dblausend.summa,16,2)+")"
		lnError = SQLEXEC(gnHandle,lcString)
		IF lnError < 0
			SET STEP ON 
			exit
		ENDIF

	ENDSCAN
ENDIF



=SQLDISCONNECT(gnHandle)

*!*	SELECT dblausend
*!*	BROWSE
*!*	SELECT krlausend
*!*	BROWSE
