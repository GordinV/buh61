CLEAR all
IF !EMPTY(DBC())
	CLOSE DATABASES 
endif
cNewData = 'c:\avpsoft\files\buh60\temp\dbase\buhdata5.dbc'
lcLibFolder = 'c:\avpsoft\files\buh60\script\Kommlib'
IF !FILE(cNewData) OR !DIRECTORY(lcLibFolder)
	MESSAGEBOX('Database or library not found,'+cNewData)
	return
ENDIF
SET EXCLUSIVE ON

OPEN DATABASE  (cNewData)

* 1. clean tables

	lnObj = ADBOBJECTS(aTbl,'TABLE')
	
	FOR i = 1 TO lnObj
		lcTable = aTbl(i)
		IF 'MENU' $ UPPER(lcTable) 
		ELSE
			WAIT WINDOW [Cleaning ]+lcTable nowait
			USE (lcTable) IN 0 ALIAS ctbl
			SELECT ctbl
			ZAP
			USE IN ctbl
		ENDIF		
	ENDFOR
	
* Rekv

	INSERT INTO rekv (regkood, nimetus) ;
		VALUES ('1000','Asutus')	

	INSERT INTO aa (ParentId, arve, nimetus, default_, kassa, pank,konto) ;
		VALUES (rekv.id,'1000','Pank',1,2,401,'113')	

	INSERT INTO aa (ParentId, arve, nimetus, default_, kassa, pank,konto) ;
		VALUES (rekv.id,'1001','Kassa',0,1,0,'111')	

	INSERT INTO userid (rekvid, kasutaja, ametnik, kasutaja_, peakasutaja_, admin) ;
		VALUES (rekv.id,'Kasutaja','Kasutaja',1,1,1)	
	
	
* 2. Kontoplaan
	lcLib = lcLibFolder+'\qryKontod.dbf'	
	IF FILE(lcLib)	
		WAIT WINDOW [Importing ]+lcLib NOWAIT 
		USE (lcLib) IN 0 ALIAS qry
		SELECT qry
		lnFields = AFIELDS(aCurs)
		lnEl = ASCAN(aCurs,'ID')
		IF lnEl > 0
			ALTER TABLE qry drop COLUMN ID
		ENDIF
		IF !USED ('library')
			USE library IN 0
		ENDIF
		SELECT library
		APPEND FROM DBF('qry')
		USE IN qry
		UPDATE library SET rekvId = rekv.id 
		SCAN
			DO case
				CASE LEFT(library.kood,1)='1'
					lnTun = 1
				CASE LEFT(library.kood,1)='2'
					lnTun = 2
				CASE LEFT(library.kood,1)='4' OR LEFT(library.kood,1)='4'
					lnTun = 4
				CASE LEFT(library.kood,1)='5' OR LEFT(library.kood,1)='6'
					lnTun = 3
				OTHERWISE
					lnTun = 3
			endcase
			replace tun1 WITH lnTun IN library
		endscan
	ELSE
		MESSAGEBOX('File '+lcLib + ' not found ')
	endif


	lcLib = lcLibFolder+'\qryDok.dbf'	
	IF FILE(lcLib)	
		WAIT WINDOW [Importing ]+lcLib NOWAIT 
		USE (lcLib) IN 0 ALIAS qry
		SELECT qry
		lnFields = AFIELDS(aCurs)
		lnEl = ASCAN(aCurs,'ID')
		IF lnEl > 0
			ALTER TABLE qry drop COLUMN ID
		ENDIF
		IF !USED ('library')
			USE library IN 0
		ENDIF
		SELECT library
		APPEND FROM DBF('qry')
		USE IN qry
		UPDATE library SET rekvId = rekv.id 

		SELECT library
		SCAN FOR library = 'LIBRARY'
			INSERT INTO dokprop (parentid) VALUES (library.id)				
		ENDSCAN
		

	ELSE
		MESSAGEBOX('File '+lcLib + ' not found ')
	endif


	lcLib = lcLibFolder+'\qryHolidays.dbf'	
	IF FILE(lcLib)	
		WAIT WINDOW [Importing ]+lcLib NOWAIT 
		USE (lcLib) IN 0 ALIAS qry
		SELECT qry
		lnFields = AFIELDS(aCurs)
		lnEl = ASCAN(aCurs,'ID')
		IF lnEl > 0
			ALTER TABLE qry drop COLUMN ID
		ENDIF
		IF !USED ('holidays')
			USE holidays IN 0
		ENDIF
		SELECT holidays
		APPEND FROM DBF('qry')
		USE IN qry
		UPDATE holidays SET rekvId = rekv.id 
	ELSE
		MESSAGEBOX('File '+lcLib + ' not found ')
	endif

	lcLib = lcLibFolder+'\qryNom.dbf'	
	IF FILE(lcLib)	
		WAIT WINDOW [Importing ]+lcLib NOWAIT 
		USE (lcLib) IN 0 ALIAS qry
		SELECT qry
		lnFields = AFIELDS(aCurs)
		lnEl = ASCAN(aCurs,'ID')
		IF lnEl > 0
			ALTER TABLE qry drop COLUMN ID
		ENDIF
		IF !USED ('nomenklatuur')
			USE nomenklatuur IN 0
		ENDIF
		SELECT nomenklatuur
		APPEND FROM DBF('qry')
		USE IN qry
		UPDATE nomenklatuur SET rekvId = rekv.id 
	ELSE
		MESSAGEBOX('File '+lcLib + ' not found ')
	endif

	INSERT INTO library (rekvid, kood, nimetus, library) VALUES (rekv.id, 'PALK','PALK','PALK')
	INSERT INTO PALK_LIB (parentid, liik, tund, maks,algoritm, asutusest, palgafond, round, sots, konto,elatis, tululiik);
	VALUES (library.id, 1, 1,0, '26',0,0,1,1,'',0,'01')

	INSERT INTO library (rekvid, kood, nimetus, library) VALUES (rekv.id, 'SOTS','Sotsialmaks','PALK')
	INSERT INTO PALK_LIB (parentid, liik, tund, maks,algoritm, asutusest, palgafond, round, sots, konto,elatis, tululiik);
	VALUES (library.id, 5, 0,0, '26',0,0,1,0,'',0,'')

	INSERT INTO library (rekvid, kood, nimetus, library) VALUES (rekv.id, 'TULU26','Tulumaks','PALK')
	INSERT INTO PALK_LIB (parentid, liik, tund, maks,algoritm, asutusest, palgafond, round, sots, konto,elatis, tululiik);
	VALUES (library.id, 4, 0, 0,'26',0,0,1,0,'',0,'')

	INSERT INTO library (rekvid, kood, nimetus, library) VALUES (rekv.id, 'TKA','Töökindlustusmaks asutuses','PALK')
	INSERT INTO PALK_LIB (parentid, liik, tund, maks,algoritm, asutusest, palgafond, round, sots, konto,elatis, tululiik);
	VALUES (library.id, 7, 0, 0,'26',1,1,1,0,'',0,'')

	INSERT INTO library (rekvid, kood, nimetus, library) VALUES (rekv.id, 'TKI','Töökindlustusmaks isikult','PALK')
	INSERT INTO PALK_LIB (parentid, liik, tund, maks,algoritm, asutusest, palgafond, round, sots, konto,elatis, tululiik);
	VALUES (library.id, 7, 0, 0,'26',0,1,1,0,'',0,'')

	INSERT INTO library (rekvid, kood, nimetus, library) VALUES (rekv.id, 'PM','Pensionimaks','PALK')
	INSERT INTO PALK_LIB (parentid, liik, tund, maks,algoritm, asutusest, palgafond, round, sots, konto,elatis, tululiik);
	VALUES (library.id, 8, 0, 0,'26',0,1,1,0,'',0,'')


	INSERT INTO library (rekvid, kood, nimetus, library) VALUES (rekv.id, 'TASU','Väljamaks','PALK')
	INSERT INTO PALK_LIB (parentid, liik, tund, maks,algoritm, asutusest, palgafond, round, sots, konto,elatis, tululiik);
	VALUES (library.id, 6, 0, 0,'26',0,1,1,0,'',0,'')


CLOSE DATABASES 

SET EXCLUSIVE Off


