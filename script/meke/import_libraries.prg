* импорт справочников МЕКЕ
WAIT WINDOW 'Uhendan Meke ..' nowait
gnHandle = SQLCONNECT('meke')

IF gnHandle < 0 
	MESSAGEBOX('err in connection')
	SET STEP ON 
ELSE 
	WAIT WINDOW 'Uhendan Meke ..onnestus' TIMEOUT 1
ENDIF

IF gnHandle > 0
* kustutan vana andme
*!*		lcString = "delete from library where library = 'OBJEKT'"
*!*		lnError = SQLEXEC(gnHandle,lcString)
*!*		IF lnError < 0
*!*			MESSAGEBOX('Viga')
*!*			SET STEP ON 
*!*		ENDIF
	

	lcFile = 'tmp/mekelib.xls'
	IF !FILE(lcFile)
		MESSAGEBOX(' Puudub file' +lcFile)
	endif
	IMPORT FROM (lcFile) TYPE XL5
	* SHEET 'tunnus'
*	brow

* pusiandmete laadimine
*!*		WAIT WINDOW 'Pusiandmete laadimine.. ' nowait
*!*		lcString = "select * from library where library = 'TUNNUS'"
*!*		lnError = SQLEXEC(gnHandle,lcString,'tmpLib')
*!*		IF lnError < 0 
*!*			SET STEP ON 
*!*		endif
*!*		WAIT WINDOW 'Pusiandmete laadimine.. onnestus' nowait
*!*		SELECT tmpLib
*!*		SCAN
*!*			WAIT WINDOW 'Loen tunnus ..'+STR(RECNO('tmpLib'))+'/'+STR(RECCOUNT('tmpLib')) nowait
*!*			* otsime kas see kood oli kasutusel
*!*			lcString = "select count(id) as id from journal1 where tunnus = '"+ALLTRIM(tmpLib.kood)+"'"
*!*			lnError = SQLEXEC(gnHandle,lcString,'tmp')
*!*			IF lnError < 0
*!*				SET STEP ON 
*!*				exit
*!*			ENDIF
*!*			IF USED('tmp') AND RECCOUNT('tmp') > 0 AND VAL(ALLTRIM(tmp.id))= 0
*!*				WAIT WINDOW 'Loen tunnus ..'+STR(RECNO('tmpLib'))+'/'+STR(RECCOUNT('tmpLib'))+'kustutan' nowait
*!*				lcString = "update library set library = 'TUNNUSVIGA' WHERE ID = "+STR(tmpLib.id)
*!*				lnError = SQLEXEC(gnHandle,lcString,'tmp')
*!*				IF lnError < 0
*!*					SET STEP ON 
*!*					exit
*!*				ENDIF		
*!*			ENDIF
*!*			
*!*		ENDSCAN
	
	SELECT mekelib
	SCAN
		WAIT WINDOW 'Import TUNNUS... '+STR(RECNO('mekelib'))+'/'+STR(RECCOUNT('mekelib')) nowait
		* kontrollin kas see kiri juba on andmebaasis
		lcString = "select id from library where library = 'TUNNUS' and LTRIM(RTRIM(kood)) = '"+LEFT(ALLTRIM((mekelib.a)),20)+"'"
		lnError = SQLEXEC(gnHandle,lcString,'tmp')
		IF lnError < 1 OR !USED('tmp')
			SET STEP ON 
			EXIT		
		ENDIF
		IF RECCOUNT('tmp') = 0 
			* kiri puudub, lisame kood
			lcString = "insert into library (rekvid, kood, nimetus, library) values (1,'"+;
				LEFT(ALLTRIM(mekelib.a),20)+"','"+ALLTRIM(mekelib.b)+"','TUNNUS')"			
			lnError = SQLEXEC(gnHandle,lcString)
			IF lnError < 0
				SET STEP on
				exit
			ENDIF
		ENDIF
		
		
		
		
	ENDSCAN
	
		
*		lcString = "select count(id) as id from library where library = 'TUNNUS' and UPPER(LTRIM(RTRIM(kood))) = '"+ALLTRIM(UPPER(		
	
ENDIF




=SQLDISCONNECT(gnHandle)
