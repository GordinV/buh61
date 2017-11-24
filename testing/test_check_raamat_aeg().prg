PARAMETER gversia, tlDebug
&& вставка двух запесей, запуск процедуры и контроль кол-ва записей
grekv = 1
guSerid = 1
IF empty (gversia)
	CLOSE data all
	gversia = 'PG'
ENDIF
DO case
	CASE gversia = 'VFP'
		gnhandle = 1
		glError = .f.
		cData = 'c:\buh50\dbavpsoft\buhdata5.dbc'
		OPEN data (cData)
	CASE gversia = 'MSSQL'
		gnhandle = sqlconnect ('buhdata5local')
	CASE gversia = 'PG'
		gnhandle = sqlconnect ('postgres','vlad')
ENDCASE

IF gnhandle < 1
	MESSAGEBOX ('Viga: connection','Kontrol')
	RETURN
ENDIF
IF !used ('testlog')
	CREATE cursor testlog (log m)
ENDIF
SELECT testlog
APPEN blank
REPLACE testlog.log with 'FUNCTION CHECK_RAAMAT_AEG' additive
IF !used ('menuitem')
	USE menuitem IN 0
ENDIF
IF !used ('menubar')
	USE menubar IN 0
ENDIF
IF !used ('config')
	USE config IN 0
ENDIF
SET classlib to classes\classlib
oDb = createobject('db')
WITH oDb

	.login = 'VLAD'
	.pass = ''

	CREATE cursor curKey (versia m)
	APPEND blank
	REPLACE versia with 'RAAMA' in curKey
	CREATE cursor v_account (admin int default 1)

&& проверка кол-ва записей
	lnrecno1 = read_tbl()
	IF vartype (lnrecno1)= 'C'
		lnrecno1 = val (alltrim(lnrecno1))
	ENDIF
	REPLACE testlog.log with '1 RECNO(RAAMAT):'+str (lnrecno1) additive

	tcOper =  'test'
	tcDok = 'test'
	tnId = 1
	tAeg = gomonth(datetime() , -4)

	IF gversia = 'VFP'
		lcString = " INSERT INTO raamat (reKvid, usErid, opEratsioon, doKument, doKid, aeg) "+;
			" VALUES ("+str (grekv)+","+ str (guSerid)+",'"+ tcOper+"','"+ tcDok+"',"+str( tnId)+","+;
			"datetime("+str(year(tAeg))+","+str(month(tAeg))+","+str(day(tAeg))+"))"
		&lcString
	ELSE
		IF gversia= 'PG'
			lcString = " INSERT INTO raamat (reKvid, usErid, opEratsioon, doKument, doKid, aeg) "+" VALUES ("+str (grekv)+","+ str (guSerid)+",'"+ tcOper+"','"+ tcDok+"',"+str( tnId)+", timestamp '" +ttoc(tAeg)+"')"
		ELSE
			lcString = " INSERT INTO raamat (reKvid, usErid, opEratsioon, doKument, doKid, aeg) "+;
				" VALUES ("+str (grekv)+","+ str (guSerid)+",'"+ tcOper+"','"+ tcDok+"',"+str( tnId)+",'" +ttoc(tAeg)+"')"
		ENDIF
		lError = sqlexec (gnhandle,lcString)
		IF lError < 1
			lcViga = 'Viga,lisamine raamat'
			REPLACE testlog.log with lcViga additive
			MESSAGEBOX (lcViga)
			SET step on
			RETURN
		ENDIF
	ENDIF

	tAeg = datetime()
	IF gversia = 'VFP'
		lcString = " INSERT INTO raamat (reKvid, usErid, opEratsioon, doKument, doKid, aeg) "+;
			" VALUES ("+str (grekv)+","+ str (guSerid)+",'"+ tcOper+"','"+ tcDok+"',"+str( tnId)+","+;
			"datetime("+str(year(tAeg))+","+str(month(tAeg))+","+str(day(tAeg))+"))"
		&lcString
	ELSE
		IF gversia = 'PG'
			lcString = " INSERT INTO raamat (reKvid, usErid, opEratsioon, doKument, doKid, aeg) "+;
				" VALUES ("+str (grekv)+","+ str (guSerid)+",'"+ tcOper+"','"+ tcDok+"',"+str( tnId)+", timestamp '" +ttoc(tAeg)+"')"
		ELSE
			lcString = " INSERT INTO raamat (reKvid, usErid, opEratsioon, doKument, doKid, aeg) "+;
				" VALUES ("+str (grekv)+","+ str (guSerid)+",'"+ tcOper+"','"+ tcDok+"',"+str( tnId)+",'" +ttoc(tAeg)+"')"
		ENDIF
		lError = sqlexec (gnhandle,lcString)
		IF lError < 1
			lcViga = 'Viga,lisamine raamat'
			REPLACE testlog.log with lcViga additive
			MESSAGEBOX (lcViga)
			SET step on
			RETURN
		ENDIF
	ENDIF
	lnrecno2 = read_tbl()
	IF vartype (lnrecno2)= 'C'
		lnrecno2 = val (alltrim(lnrecno2))
	ENDIF
	REPLACE testlog.log with '1 RECNO(RAAMAT):'+str (lnrecno1) additive
	IF lnrecno1+2 <> lnrecno2
		lcViga = 'Viga,ошибка кол-ва записей в таблице'
		REPLACE testlog.log with lcViga additive
		MESSAGEBOX (lcViga)
	ENDIF
	IF empty (tlDebug)
		SET step on
	ENDIF
	LRETURN = .exec ('check_raamat_aeg')
	lnrecno3 = read_tbl()
	IF vartype (lnrecno3)= 'C'
		lnrecno3 = val (alltrim(lnrecno3))
	ENDIF
	IF lnrecno1+1 <> lnrecno2
		lvViga = 'Viga,ошибка кол-ва записей в таблице'
		REPLACE testlog.log with lcViga additive
		MESSAGEBOX (lcViga)
	ENDIF

	IF LRETURN = .t.
		REPLACE testlog.log with 'FUNCTION CHECK_RAAMAT_AEG: OK' additive
		MESSAGEBOX ('Ok')
	ELSE
		REPLACE testlog.log with 'FUNCTION CHECK_RAAMAT_AEG: FAILD' additive
		MESSAGEBOX ('FAILD')
	ENDIF
ENDWITH
IF FILE('testlog.log')
	COPY MEMO testlog.log TO testlog.log ADDITIVE
ELSE
	COPY MEMO testlog.log TO testlog.log
ENDIF


*!*	lcDir = curdir ()
*!*	set default to 'c:\avpsoft\files\buh52\proc'
*!*	lnSumma = analise_formula (lcFormula, date())
*!*	set step on
*!*	set default to (lcDir)


FUNCTION read_tbl
	lcString = "select count (id) as id from raamat "
	IF gversia = 'VFP'
		lcString = lcString + " into cursor qry1"
		&lcString
	ELSE
		lError = sqlexec (gnhandle,lcString, 'qry1')
		IF lError < 1
			MESSAGEBOX ('Viga,lugemine raamat')
			SET step on
			RETURN
		ENDIF
	ENDIF
	IF used ('qry1')
		lnRec = qry1.id
	ELSE
		MESSAGEBOX ('Viga,lugemine raamat')
		SET step on
		RETURN 0
	ENDIF
	RETURN qry1.id
