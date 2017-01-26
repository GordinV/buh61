gnhandle = SQLCONNECT('NarvaLvPg')
IF gnhandle < 1
	MESSAGEBOX('Viga uhendus')
	RETURN 0
ENDIF

lcDbf = 'c:\avpsoft\files\buh60\dbase\buhdata5.dbc'
IF !FILE(lcDbf)
	MESSAGEBOX('Viga dbf')
	RETURN 0
ENDIF

OPEN DATABASE (lcDbf)
SET STEP ON 
IF !USED('menupohi')
	USE menupohi IN 0
ENDIF

SELECT menupohi
SCAN FOR id >= 28432
	lError= fnc_cneck_pohimenu(menupohi.pad,menupohi.bar) 
	IF lError < 0
		exit
	ENDIF
	IF lError = 0 
		* no record
		lError = fnc_insert_menupohi()
	ENDIF	

ENDSCAN

IF !USED('menumodul')
	USE menumodul IN 0
ENDIF

SELECT menumodul
SCAN FOR modul = 'REKL'
	SELECT menupohi
	LOCATE FOR id = menumodul.parentid
	IF FOUND()
		lError= fnc_cneck_pohimenu(menupohi.pad,menupohi.bar) 
		IF lError > 0
			lError= fnc_cneck_menumodul(lError) 
		ENDIF
				
	ENDIF
	
ENDSCAN




=SQLDISCONNECT(gnhandle)

FUNCTION fnc_cneck_menumodul
LPARAMETERS tnId
lcString = "select id from menumodul where parentid = "+STR(tnId)
lnError = SQLEXEC(gnhandle,lcString,'tmpId')
IF USED('tmpId') AND RECCOUNT('tmpId') = 0
	lcString = "insert into menumodul (parentid, modul) values ("+;
		STR(tnId)+",REKL')"
		If sqlexec(gnhandle,lcString) < 0
			Return -1
		Endif
endif
	RETURN 1		

ENDFUNC


FUNCTION fnc_insert_menupohi
		lcOmandus = LTRIM(RTRIM(menupohi.omandus))
		lcproc = LTRIM(RTRIM(menupohi.proc_))
		lcPad = LTRIM(RTRIM(menupohi.pad))
		lcBar = LTRIM(RTRIM(menupohi.bar))
		lcLevel = LTRIM(RTRIM(STR(menupohi.level_)))

		lcString = "Insert Into menupohi (Pad, Bar, proc_, omandus, level_) Values "+;
			"('"+lcPad+"','"+lcBar +"','"+lcproc+"','"+lcOmandus+"',"+lcLevel+")"
		If sqlexec(gnhandle,lcString) < 0
			Return -1
		Endif
		lcString = " select id from menupohi order by id desc limit 1"
		lError = sqlexec(gnHandle,lcString,'qrymenupohi')

		lcString = "Insert Into menumodul (parentid, Modul) Values ("+Str(qrymenupohi.Id,9)+", 'REKL')"
		If sqlexec(gnhandle,lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'KASUTAJA', 1)"
		If sqlexec(gnhandle,lcString) < 0
			Return .F.
		Endif

		lcString = "Insert Into menuisik (parentid, gruppid, jah) Values ("+Str(qrymenupohi.Id,9)+", 'PEAKASUTAJA', 1)"
		If sqlexec(gnhandle,lcString) < 0
			Return .F.
		Endif

ENDFUNC




FUNCTION fnc_cneck_pohimenu
LPARAMETERS tcPadName,tcbar
lcString = "select id from menupohi where UPPER(LTRIM(RTRIM(pad))) = '"+;
	UPPER(tcPadName)+"' and bar = '"+tcbar+"'"
lResult = SQLEXEC(gnhandle,lcString,'tmpId')
IF lResult > 0 AND USED('tmpId') 
	* success
	IF RECCOUNT('tmpId') > 0
		* menu exist
		RETURN tmpId.id
	ELSE
		RETURN 0
	ENDIF
ELSE
	RETURN -1	
endif	
	
ENDFUNC

