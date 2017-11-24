LOCAL lnResult
IF EMPTY(gnKuu) .OR. EMPTY(gnAasta)
	DO FORM period
ENDIF
IF  .NOT. USED('curSource')
	CREATE CURSOR curSource (id INT, koOd C (20), niMetus C (120))
ENDIF
IF  .NOT. USED('curValitud')
	CREATE CURSOR curValitud (id INT, koOd C (20), niMetus C (120))
ENDIF
CREATE CURSOR curResult (id INT, osAkondid INT)
lnStep = 1
DO WHILE lnStep>0
	DO CASE
		CASE lnStep=1
			DO geT_osakonna_list
		CASE lnStep=2
			DO geT_isiku_list
		CASE lnStep>2
			DO arVutus
	ENDCASE
ENDDO
IF USED('curSource')
	USE IN curSource
ENDIF
IF USED('curvalitud')
	USE IN curValitud
ENDIF
IF USED('curResult')
	USE IN curResult
ENDIF
IF USED('qryPuhkused')
	USE IN qrYpuhkused
ENDIF
ENDPROC
*
PROCEDURE arVutus
	LOCAL leRror
	WITH odB
		.opEntransaction()
		SELECT DISTINCT id FROM curResult WHERE  NOT EMPTY(curResult.id) INTO  ;
			CURSOR recalc1
		SELECT recalc1
		SCAN
			lError = odb.exec ('gen_taabel1',STR(recalc1.Id)+","+STR(gnKuu,2)+","+STR(gnAasta,4))
			IF leRror=.F.
				EXIT
			ENDIF
		ENDSCAN
		IF leRror=.T.
			.coMmit
		ELSE
			.roLlback()
			MESSAGEBOX('Viga', 'Kontrol')
		ENDIF
	ENDWITH
	lnStep = 0
ENDPROC
*
PROCEDURE geT_osakonna_list
	IF USED('query1')
		USE IN query1
	ENDIF
	tcKood = '%%'
	tcNimetus = '%%'
	odB.usE('curOsakonnad','qryOsakonnad')
	SELECT curSource
	IF RECCOUNT('curSource')>0
		ZAP
	ENDIF
	APPEND FROM DBF('qryOsakonnad')
	USE IN qrYosakonnad
	SELECT curValitud
	IF RECCOUNT('curvalitud')>0
		ZAP
	ENDIF
	DO FORM forms\samm TO nrEsult WITH '1', IIF(coNfig.keEl=2, 'Osakoonad',  ;
		'Подразделения'), IIF(coNfig.keEl=2, 'Valitud osakonnad',  ;
		'Выбранные подразделения')
	IF nrEsult=1
		SELECT DISTINCT id FROM curValitud INTO CURSOR query1
		SELECT query1
		SCAN
			INSERT INTO curResult (osAkondid) VALUES (query1.id)
		ENDSCAN
		USE IN query1
		SELECT curValitud
		ZAP
	ENDIF
	IF nrEsult=0
		lnStep = 0
	ELSE
		lnStep = lnStep+nrEsult
	ENDIF
ENDPROC
*
PROCEDURE geT_isiku_list
	IF USED('query1')
		USE IN query1
	ENDIF
	odB.usE('curKaader','qryKaader')
	SELECT curSource
	IF RECCOUNT('curSource')>0
		ZAP
	ENDIF
	SELECT isIkukood AS koOd, LEFT(RTRIM(isIk)+SPACE(1)+RTRIM(amEt), 120) AS  ;
		niMetus, id FROM qryKaader WHERE osAkondid IN (SELECT osAkondid  ;
		FROM curResult) INTO CURSOR query1
	SELECT curSource
	APPEND FROM DBF('query1')
	USE IN query1
	SELECT curValitud
	IF RECCOUNT('curvalitud')>0
		ZAP
	ENDIF
	DO FORM forms\samm TO nrEsult WITH '2', IIF(coNfig.keEl=2, 'Tццtajad',  ;
		'Работники'), IIF(coNfig.keEl=2, 'Valitud tццtajad', 'Выбранные работники')
	IF nrEsult=1
		SELECT DISTINCT id FROM curValitud INTO CURSOR query1
		SELECT query1
		SCAN
			INSERT INTO curResult (id) VALUES (query1.id)
		ENDSCAN
		USE IN query1
	ENDIF
	IF nrEsult=0
		lnStep = 0
	ELSE
		lnStep = lnStep+nrEsult
	ENDIF
	RETURN
ENDPROC
*
