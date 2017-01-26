Parameter gversia, tlDebug
grekv = 1
guSerid = 1
If empty (gversia)
	Close data all
	gversia = 'VFP'
Endif
Do case
	Case gversia = 'VFP'
		gnhandle = 1
		glError = .f.
		cData = 'c:\buh50\dbavpsoft\buhdata5.dbc'
		Open data (cData)
	Case gversia = 'MSSQL'
		gnhandle = sqlconnect ('buhdata5local')
	Case gversia = 'PG'
		gnhandle = sqlconnect ('postgresql30')
Endcase

If gnhandle < 1
	Messagebox ('Viga: connection','Kontrol')
	Return
Endif
If !used ('testlog')
	Create cursor testlog (log m)
Endif
Select testlog
Appen blank
Replace testlog.log with PROGRAM() +CHR(13) additive IN testlog
If !used ('menuitem')
	Use menuitem IN 0
Endif
If !used ('menubar')
	Use menubar IN 0
Endif
If !used ('config')
	Use config IN 0
Endif
Set classlib to classes\classlib
oDb = createobject('db')
With oDb

	.login = 'VLAD'
	.pass = ''

	Create cursor curKey (versia m)
	Append blank
	Replace versia with 'RAAMA' in curKey
	Create cursor v_account (admin int default 1)


	If empty (tlDebug)
		Set step on
	Endif
	IF GVERSIA = 'VFP'
		lError = .exec ("sp_calc_palk_jaak ","7,2003,1",'')
	ENDIF
	IF GVERSIA = 'MSSQL'
		lError = .exec ("sp_calc_palk_jaak ","7,2003,1",'')
	ENDIF
	IF GVERSIA = 'PG'
		lError = .exec ("sp_calc_palk_jaak ","7,2003,1",'')
	ENDIF
	If lError = .t. 
		Replace testlog.log with PROGRAM()+': OK'+CHR(13) additive IN testlog
		Messagebox ('Ok')
	Else
		Replace testlog.log with PROGRAM()+': FAILD' +CHR(13) additive IN testlog
		Messagebox ('FAILD')
	Endif
Endwith
If FILE('testlog.log')
	Copy MEMO testlog.log TO testlog.log ADDITIVE
Else
	Copy MEMO testlog.log TO testlog.log
Endif


*!*	lcDir = curdir ()
*!*	set default to 'c:\avpsoft\files\buh52\proc'
*!*	lnSumma = analise_formula (lcFormula, date())
*!*	set step on
*!*	set default to (lcDir)
