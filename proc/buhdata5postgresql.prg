*!*	cData = getfile('DBC')
*!*	If empty(cData)
*!*		Return
*!*	Endif
Set step on
gnHandle = sqlconnect ('postgresql','vlad','4gordin2')
If gnHandle < 1
	Messagebox ('Viga: connection','Kontrol')
	Set step on
	Return
Endif
Do create_table_arv
Do create_table_dbase
Do create_table_arv1
Do create_table_nomenklatuur
Do create_table_journal
Do create_table_journal1
Do create_table_lausend
Do create_table_library
Do create_table_saldo
Do create_table_saldo1
Do create_table_saldo2
Do create_table_asutus
Do create_table_rekv
Do create_table_userid
Do create_table_aa
Do create_table_doklausend
Do create_table_doklausheader
Do create_table_sorder1
Do create_table_sorder2
Do create_table_vorder1
Do create_table_vorder2
Do create_table_kontoinf
Do create_table_subkonto
Do create_table_arvtasu
Do create_table_leping1
Do create_table_leping2
Do create_table_aasta
Do create_table_lausdok
=sqldisconnect (gnHandle)

Procedure create_table_arv
	cString = ' Create TABLE arv(ID SERIAL  NOT NULL  ,REKVID INT4  NOT NULL ,'+;
		"USERID INT4  NOT NULL ,JOURNALID INT4  NOT NULL ,DOKLAUSID INT4  NOT NULL,"+;
		"NUMBER VARCHAR (20)  NOT NULL ,KPV DATE  NOT NULL ,ASUTUSID INT4  NOT NULL ,"+;
		"ARVID INT4  NOT NULL ,LISA VARCHAR (120)  NOT NULL  ,TAHTAEG DATE  NULL ,"+;
		"KBMTA MONEY  NOT NULL ,KBM MONEY  NOT NULL ,SUMMA MONEY  NOT NULL ,"+;
		"TASUD DATE  NULL ,TASUDOK VARCHAR (254)  NULL ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_dbase
	cString = " Create TABLE dbase(ALIAS VARCHAR (50)  NOT NULL ,LASTNUM INT4  NOT NULL ,"+;
		"DOKNUM INT4  NOT NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_arv1
	cString = 'Create TABLE arv1(ID SERIAL  NOT NULL  ,PARENTID INT4  NOT NULL ,'+;
		"NOMID INT4  NOT NULL     ,KOGUS NUMERIC (12,3)  NOT NULL     ,HIND MONEY  NOT NULL     ,"+;
		"SOODUS NUMERIC (12,4)  NOT NULL     ,KBM MONEY  NOT NULL     ,SUMMA MONEY  NOT NULL     ,"+;
		"KOOD1 INT4  NOT NULL     ,KOOD2 INT4  NOT NULL     ,KOOD3 INT4  NOT NULL     ,"+;
		"KOOD4 INT4  NOT NULL     ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_nomenklatuur
	cString = ' Create TABLE nomenklatuur(ID SERIAL  NOT NULL  ,'+;
		"REKVID INT4  NOT NULL ,DOKLAUSID INT4  NOT NULL     ,DOK VARCHAR (20)  NOT NULL ,"+;
		"KOOD VARCHAR (20)  NOT NULL ,NIMETUS VARCHAR (254)  NOT NULL ,UHIK VARCHAR (20)  NULL ,"+;
		"HIND MONEY  NOT NULL     ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc

Procedure create_table_journal
	cString = ' Create TABLE journal(ID SERIAL  NOT NULL ,'+;
		"REKVID INT4  NOT NULL    ,USERID INT4  NOT NULL ,DOKID INT4  NOT NULL     ,"+;
		"KPV DATE  NOT NULL   ,ASUTUSID INT4  NOT NULL     ,SELG TEXT  NULL ,"+;
		"DOK VARCHAR (60)  NULL ,TUNNUSID INT4  NOT NULL     ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_journal1
	cString = 'Create TABLE journal1(ID SERIAL  NOT NULL    ,PARENTID INT4  NOT NULL ,'+;
		"LAUSENDID INT4  NOT NULL ,SUMMA MONEY  NOT NULL     ,DOKUMENT VARCHAR (20)  NULL ,"+;
		"KOOD1 INT4  NOT NULL     ,KOOD2 INT4  NOT NULL     ,KOOD3 INT4  NOT NULL     ,"+;
		"KOOD4 INT4  NOT NULL     ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_lausend
	cString = 'Create TABLE lausend(ID SERIAL  NOT NULL    ,REKVID INT4  NULL ,'+;
		"DEEBET VARCHAR (20)  NULL ,KREEDIT VARCHAR (20)  NULL ,"+;
		"NIMETUS VARCHAR (254)  NULL ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_library
	cString = 'Create TABLE library(ID SERIAL  NOT NULL     ,'+;
		"REKVID INT4  NOT NULL     ,KOOD VARCHAR (20)  NOT NULL ,NIMETUS VARCHAR (254)  NOT NULL ,"+;
		"LIBRARY VARCHAR (20)  NOT NULL ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_saldo
	cString = ' Create TABLE saldo(ID SERIAL  NOT NULL    ,REKVID INT4  NOT NULL ,'+;
		"PERIOD DATE  NOT NULL ,KONTO VARCHAR (20)  NOT NULL  ,saldo MONEY  NOT NULL     ,"+;
		"DBKAIBED MONEY  NOT NULL     ,KRKAIBED MONEY  NOT NULL     )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_saldo1
	cString = 'Create TABLE saldo1(ID SERIAL  NOT NULL    ,REKVID INT4  NOT NULL ,'+;
		"PERIOD DATE  NOT NULL ,KONTO VARCHAR (4)  NOT NULL ,ASUTUSID INT4  NOT NULL ,"+;
		"saldo MONEY  NOT NULL     ,DBKAIBED MONEY  NOT NULL     ,KRKAIBED MONEY  NOT NULL     )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_saldo2
	cString = 'Create TABLE saldo2(ID SERIAL  NOT NULL    ,PARENTID INT4  NOT NULL ,'+;
		"KOOD1 INT4  NULL ,KOOD2 INT4  NULL ,KOOD3 INT4  NULL ,KOOD4 INT4  NULL ,SUMMA MONEY  NOT NULL     )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_asutus
	cString = 'Create TABLE asutus(ID SERIAL  NOT NULL     ,REKVID INT4  NOT NULL ,'+;
		"REGKOOD VARCHAR (20)  NULL ,NIMETUS VARCHAR (254)  NOT NULL ,"+;
		"OMVORM VARCHAR (20)  NOT NULL,AADRESS TEXT  NULL ,KONTAKT TEXT  NULL ,"+;
		"TEL VARCHAR (60)  NULL ,FAKS VARCHAR (60)  NULL ,EMAIL VARCHAR (60)  NULL ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_rekv
	cString = 'Create TABLE rekv(ID SERIAL  NOT NULL    ,PARENTID INT4  NOT NULL     ,'+;
		"REGKOOD VARCHAR (20)  NOT NULL ,NIMETUS VARCHAR (254)  NOT NULL ,KBMKOOD VARCHAR (20)  NOT NULL ,"+;
		"AADRESS TEXT  NOT NULL ,HALDUS VARCHAR (254)  NOT NULL ,TEL VARCHAR (120)  NOT NULL ,"+;
		"FAKS VARCHAR (120)  NOT NULL ,EMAIL VARCHAR (120)  NOT NULL ,JUHT VARCHAR (120)  NOT NULL ,"+;
		"RAAMA VARCHAR (120)  NOT NULL ,MUUD TEXT  NOT NULL ,RECALC NUMERIC (1,0 )  NOT NULL     )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_userid
	cString = 'Create TABLE userid(ID SERIAL  NOT NULL    ,REKVID INT4  NOT NULL ,'+;
		"KASUTAJA VARCHAR (50)  NOT NULL ,AMETNIK VARCHAR (254)  NOT NULL ,PAROOL TEXT  NOT NULL ,"+;
		"KASUTAJA_ INT4  NOT NULL ,PEAKASUTAJA_ INT4  NOT NULL     ,"+;
		"ADMIN INT4  NOT NULL     ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_aa
	cString = 'Create TABLE aa(ID SERIAL  NOT NULL    ,PARENTID INT4  NOT NULL ,'+;
		"ARVE VARCHAR (20)  NOT NULL ,NIMETUS VARCHAR (254)  NOT NULL ,saldo MONEY  NOT NULL     ,"+;
		" default_ NUMERIC (1,0 )  NOT NULL     ,KASSA INT4  NOT NULL     ,PANK INT4  NOT NULL ,"+;
		"KONTO VARCHAR (20)  NULL ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_doklausend
	cString = 'Create TABLE doklausend(ID SERIAL  NOT NULL    ,'+;
		"PARENTID INT4  NOT NULL ,LAUSENDID INT4  NOT NULL ,PERCENT_ NUMERIC (4, )  NOT NULL     ,"+;
		"SUMMA MONEY  NOT NULL     ,KOOD1 INT4  NOT NULL     ,KOOD2 INT4  NOT NULL     ,"+;
		"KOOD3 INT4  NOT NULL     ,KOOD4 INT4  NOT NULL     ,"+;
		"KBM NUMERIC (1,0 )  NOT NULL     ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_doklausheader
	cString = 'Create TABLE doklausheader(ID SERIAL  NOT NULL    ,'+;
		"REKVID INT4  NOT NULL ,DOK VARCHAR (50)  NOT NULL ,PROC_ VARCHAR (254)  NULL ,SELG TEXT  NULL ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_sorder1
	cString = 'Create TABLE sorder1(ID SERIAL  NOT NULL    ,REKVID INT4  NOT NULL ,'+;
		"USERID INT4  NOT NULL ,JOURNALID INT4  NOT NULL     ,KASSAID INT4  NOT NULL     ,"+;
		"DOKLAUSID INT4  NOT NULL     ,NUMBER VARCHAR (20)  NOT NULL ,KPV DATE  NOT NULL   ,'+;
		"ASUTUSID INT4  NOT NULL     ,NIMI TEXT  NULL ,AADRESS TEXT  NULL ,DOKUMENT TEXT  NULL ,"+;
"ALUS TEXT  NULL ,SUMMA MONEY  NOT NULL     ,MUUD TEXT  NULL )"
	NULLNULLlError = sqlexec(gnHandle,cString)"
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_sorder2
	cString = 'Create TABLE sorder2(ID SERIAL  NOT NULL    ,PARENTID INT4  NOT NULL ,'+;
		"NOMID INT4  NOT NULL     ,NIMETUS VARCHAR (120)  NOT NULL ,"+;
		"SUMMA MONEY  NOT NULL     ,KOOD1 INT4  NOT NULL     ,KOOD2 INT4  NOT NULL     ,"+;
		"KOOD3 INT4  NOT NULL     ,KOOD4 INT4  NOT NULL     )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_vorder1
	cString = 'Create TABLE vorder1(ID SERIAL  NOT NULL    ,REKVID INT4  NOT NULL ,'+;
		"USERID INT4  NOT NULL ,JOURNALID INT4  NOT NULL     ,KASSAID INT4  NOT NULL     ,"+;
		"DOKLAUSID INT4  NOT NULL     ,NUMBER VARCHAR (20)  NOT NULL ,KPV DATE  NOT NULL   ,"+;
		"ASUTUSID INT4  NOT NULL     ,NIMI TEXT  NULL ,AADRESS TEXT  NULL ,DOKUMENT TEXT  NULL ,"+;
		"ALUS TEXT  NULL ,SUMMA MONEY  NOT NULL     ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_vorder2
	cString = 'Create TABLE vorder2(ID SERIAL  NOT NULL    ,PARENTID INT4  NOT NULL ,'+;
		"NOMID INT4  NOT NULL     ,NIMETUS VARCHAR (120)  NOT NULL  ,"+;
		"SUMMA MONEY  NOT NULL     ,KOOD1 INT4  NOT NULL     ,KOOD2 INT4  NOT NULL     ,"+;
		"KOOD3 INT4  NOT NULL     ,KOOD4 INT4  NOT NULL     ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_kontoinf
	cString = 'Create TABLE kontoinf(ID SERIAL  NOT NULL    ,PARENTID INT4  NOT NULL ,'+;
		"TYPE INT4  NOT NULL  ,FORMULA INT4  NOT NULL ,"+;
		"AASTA NUMERIC (4, )  NOT NULL    YEAR(DATE()),ALGSALDO MONEY  NOT NULL     ,"+;
		"LIIK INT4  NOT NULL ,POHIKONTO VARCHAR (20)  NOT NULL    )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_subkonto
	cString = 'Create TABLE subkonto(ID SERIAL  NOT NULL    ,KONTOID INT4  NOT NULL ,'+;
		"ASUTUSID INT4  NOT NULL ,ALGSALDO MONEY  NOT NULL     ,AASTA NUMERIC (4, )  NOT NULL    YEAR(DATE()))"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_arvtasu
	cString = 'Create TABLE arvtasu(ID SERIAL  NOT NULL    ,REKVID INT4  NOT NULL ,'+;
		"ARVID INT4  NOT NULL ,KPV DATE  NOT NULL ,SUMMA MONEY  NOT NULL     ,"+;
		"DOK VARCHAR (60)  NOT NULL    ,NOMID INT4  NOT NULL ,PANKKASSA NUMERIC (1,0 )  NOT NULL ,"+;
		"JOURNALID INT4  NOT NULL     ,SORDERID INT4  NOT NULL     ,MUUD TEXT  NULL ,"+;
		"DOKLAUSID INT4  NOT NULL     )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_leping1
	cString = 'Create TABLE leping1(ID SERIAL  NOT NULL    ,ASUTUSID INT4  NOT NULL ,'+;
		"REKVID INT4  NOT NULL ,DOKLAUSID INT4  NOT NULL    ,NUMBER VARCHAR (20)  NOT NULL    ,"+;
		"KPV DATE  NOT NULL ,TAHTAEG DATE  NULL ,SELGITUS TEXT  NULL ,DOK   NULL ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_leping2
	cString = 'Create TABLE leping2(ID SERIAL  NOT NULL    ,PARENTID INT4  NOT NULL ,'+;
		"NOMID INT4  NOT NULL ,KOGUS NUMERIC (12,3)  NOT NULL ,HIND MONEY  NOT NULL    ,"+;
		"SOODUS NUMERIC (12,3)  NOT NULL    ,SOODUSALG DATE  NULL ,SOODUSLOPP DATE  NULL ,"+;
		"STATUS NUMERIC (1,0 )  NOT NULL ,MUUD TEXT  NULL )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_aasta
	cString = 'Create TABLE AASTA(ID SERIAL  NOT NULL    ,REKVID INT4  NOT NULL ,'+;
		"AASTA NUMERIC (4, )  NOT NULL    YEAR(DATE()),KINNI NUMERIC (1,0 )  NOT NULL    ,"+;
		"  NUMERIC (1,0 )  NOT NULL    )"
	lError = sqlexec(gnHandle,cString)
	If lError < 1
		Messagebox('Viga','Kontrol')
		Set step on
	Endif
Endproc
Procedure create_table_lausdok
	cString = 'Create TABLE lausdok(ID SERIAL  NOT NULL    ,DOKID INT4  NOT NULL    ,'+;
		"LAUSID INT4  NOT NULL    )"
Endproc
lError = sqlexec(gnHandle,cString)
If lError < 1
	Messagebox('Viga','Kontrol')
	Set step on
Endif
Endproc

