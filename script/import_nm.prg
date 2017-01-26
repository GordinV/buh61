Clear All
lcFile = 'C:\avpsoft\temp\nm1.xls'
If File(lcFile)
	Import From (lcFile) Type Xl8
Endif
lcAlias = Alias()

Select * From Dbf(lcAlias) Into Cursor tmpImport

Select tmpImport
*Brow

*gnHandle = SQLCONNECT('muuseum')
gnHandle = SQLConnect('muuseum')
If gnHandle < 0
	Messagebox('Viga')
	Set Step On
	Return
Endif
* kontrollime tunnused
If !Used('tmpLib')
	TEXT TO lcString
		INSERT INTO library (rekvid,  kood, nimetus, library)
			select 1, 'PROJEKTID', 'PROJEKTID','TUNNUS'
			where not exists (select id from library where kood = 'PROJEKTID' and library = 'TUNNUS');

		INSERT INTO library (rekvid,  kood, nimetus, library)
			select 1, 'ÜRITUSED', 'ÜRITUSED','TUNNUS'
			where not exists (select id from library where kood = 'ÜRITUSED' and library = 'TUNNUS');

		INSERT INTO library (rekvid,  kood, nimetus, library)
			SELECT 1, 'HALDUS', 'HALDUS','TUNNUS'
			where not exists (select id from library where kood = 'HALDUS' and library = 'TUNNUS');

		INSERT INTO library (rekvid,  kood, nimetus, library)
			select 1, 'PALK', 'PALK','TUNNUS'
			where not exists (select id from library where kood = 'PALK' and library = 'TUNNUS');

		INSERT INTO library (rekvid,  kood, nimetus, library)
			SELECT 1, 'RESTORAN', 'RESTORAN','TUNNUS'
		where not exists (select id from library where kood = 'RESTORAN' and library = 'TUNNUS');
	ENDTEXT
	lnError = SQLEXEC(gnHandle,lcString)
	If lnError < 0
		Messagebox('Viga')
		Set Step On
	Endif

	TEXT TO lcString
			SELECT * from library WHERE library = 'TUNNUS'
	ENDTEXT
	lnError = SQLEXEC(gnHandle,lcString,'tmpLib')
	If lnError < 0
		Messagebox('Viga')
		Set Step On
	Endif
	If Used('tmpLib')
		Select tmpLib
*		brow
	Endif

Endif
* transaction
lnError = SQLEXEC(gnHandle,'BEGIN TRANSACTION')
	If lnError < 0
		Messagebox('Viga')
		Set Step On
		return
	Endif

TEXT TO lcString
	INSERT INTO eelarve (rekvid,  allikasid,  aasta ,  summa ,  muud ,  tunnus ,  tunnusid ,  kood1 ,  kood2,  kood3,  kood4,  kood5 ,  kpv,  kuu )
		values (1, 0,  2016 ,  ?lnSumma ,  ?lcMuud ,  0 ,  ?lnTunnusid ,  ?lcKood1 ,  ?lcKood2,  ?lcKood3,  ?lcKood4,  ?lcKood4 , null, 1 )
ENDTEXT
SELECT tmpImport
SET STEP ON 
SCAN FOR UPPER(tmpImport.F) <> 'KONTO' AND !EMPTY(VAL(ALLTRIM(tmpImport.g)))
	WAIT WINDOW ALLTRIM(STR(RECNO('tmpImport')))+'/'+ALLTRIM(STR(RECCOUNT('tmpImport')))  nowait
	lnSumma = 0
	lcTunnus = ''
	lcKood1 = ''
	lcKood2 = 'LE-P'
	lcKood3 = ''
	
	DO CASE
		CASE !EMPTY(tmpImport.u)
			lnSumma = VAL(ALLTRIM(tmpImport.u))
			lcTunnus = 'TEENIND'
		CASE !EMPTY(tmpImport.v)
			lnSumma = VAL(ALLTRIM(tmpImport.v))
			lcTunnus = 'ADMIN'
		CASE !EMPTY(tmpImport.W)
			lnSumma = VAL(ALLTRIM(tmpImport.W))
			lcTunnus = 'INFO'
		CASE !EMPTY(tmpImport.x)
			lnSumma = VAL(ALLTRIM(tmpImport.x))
			lcTunnus = 'TEADUS'
		CASE !EMPTY(tmpImport.y)
			lnSumma = VAL(ALLTRIM(tmpImport.y))
			lcTunnus = 'TURUNDUS'
		CASE !EMPTY(tmpImport.z)
			lnSumma = VAL(ALLTRIM(tmpImport.z))
			lcTunnus = 'PROJEKTID'
		CASE !EMPTY(tmpImport.aa)
			lnSumma = VAL(ALLTRIM(tmpImport.aa))
			lcTunnus = 'ÜRITUSED'
		CASE !EMPTY(tmpImport.ab)
			lnSumma = VAL(ALLTRIM(tmpImport.ab))
			lcTunnus = 'HALDUS'
		CASE !EMPTY(tmpImport.ac)
			lnSumma = VAL(ALLTRIM(tmpImport.ac))
			lcTunnus = 'PALK'
		CASE !EMPTY(tmpImport.ad)
			lnSumma = VAL(ALLTRIM(tmpImport.ad))
			lcTunnus = 'RESTORAN'
		otherwise
			lnError = -1
			SET STEP ON 
			EXIT			
	ENDCASE
	SELECT tmpLib
	LOCATE FOR kood = lcTunnus
	IF !FOUND() 
			lnError = -1
			SET STEP ON 
			EXIT					
	ENDIF
	lnTunnusid = tmpLib.id
	lcMuud = ALLTRIM(tmpImport.a) + IIF(LEN(ALLTRIM(tmpImport.b))> 0,' ','')+; 
		ALLTRIM(tmpImport.b)+IIF(LEN(ALLTRIM(tmpImport.c))> 0,' ','')+; 
		ALLTRIM(tmpImport.c)+IIF(LEN(ALLTRIM(tmpImport.d))> 0,' ','')+; 
		ALLTRIM(tmpImport.d)+IIF(LEN(ALLTRIM(tmpImport.e))> 0,' ','')+; 
		ALLTRIM(tmpImport.e)
		
	 lcKood4 = ALLTRIM(tmpImport.f)
	 IF lnSumma > 0 
		WAIT WINDOW 'salvestan '+ ALLTRIM(STR(RECNO('tmpImport')))+'/'+ALLTRIM(STR(RECCOUNT('tmpImport')))  nowait
			lnError = SQLEXEC(gnHandle,lcString,'tmpLib')
		ENDIF
	
	If lnError < 0
		Messagebox('Viga')
		Set Step On
		exit
	Endif
ENDSCAN
*lnError = -1
IF lnError > 0 
	lnError = SQLEXEC(gnHandle,'COMMIT')
ELSE
	lnError = SQLEXEC(gnHandle,'rollback')
ENDIF
	If lnError < 0
		Messagebox('Viga')
		Set Step On
	Endif


Select tmpImport
Scan
Endscan
If gnHandle > 0
	SQLDISCONNECT(gnHandle)
Endif



