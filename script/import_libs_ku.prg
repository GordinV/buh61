gnHandle = SQLCONNECT('KU')

IF gnHandle < 0
	MESSAGEBOX('Viga uhenduses')
	SET STEP ON 
	return
ENDIF

TEXT TO lcString TEXTMERGE NOSHOW 
	SELECT * from nomenklatuur WHERE dok <> 'LADU' AND rekvid = 1
ENDTEXT

l_error = SQLEXEC(gnHandle,lcString, 'tmpNom')

IF l_error < 1
	MESSAGEBOX('Viga')
	_cliptext = lcString
	SET STEP ON 
	return
ENDIF


TEXT TO lcString TEXTMERGE NOSHOW 
	SELECT * from rekv WHERE id = 77
ENDTEXT

l_error = SQLEXEC(gnHandle,lcString, 'tmpRekv')

IF l_error < 1
	MESSAGEBOX('Viga')
	_cliptext = lcString
	SET STEP ON 
	return
ENDIF


TEXT TO lcString TEXTMERGE NOSHOW 
	SELECT * from klassiflib WHERE nomid in (SELECT id from nomenklatuur WHERE dok <> 'LADU' AND rekvid = 1)
ENDTEXT

l_error = SQLEXEC(gnHandle,lcString, 'tmpKlassif')

IF l_error < 1
	MESSAGEBOX('Viga')
	_cliptext = lcString
	SET STEP ON 
	return
ENDIF
*set STEP on 
SELECT tmpRekv
SCAN

	SELECT tmpNom
	SCAN
		WAIT WINDOW 'import -> ' + ALLTRIM(tmpRekv.nimetus) + 'tmpNom.kood' nowait
		TEXT TO lcString TEXTMERGE noshow	
			INSERT INTO nomenklatuur (rekvid, kood, nimetus, dok, uhik, hind, doklausid, kbm)
				values(<<tmpRekv.id>>, '<<ALLTRIM(tmpNom.kood)>>','<<ALLTRIM(tmpNom.nimetus)>>','<<ALLTRIM(tmpNom.dok)>>',
				'<<ALLTRIM(tmpNom.uhik)>>',<<str(tmpNom.hind,12,2)>>,<<tmpNom.doklausid>>,20) returning id				
		ENDTEXT
		l_error = SQLEXEC(gnHandle, lcString,'qryId')
		IF l_error < 1
			MESSAGEBOX('Viga')
			_cliptext = lcString
			SET STEP ON 
			exit		
		ENDIF
		
		SELECT 	tmpKlassif
		SCAN FOR nomid = tmpNom.id
			WAIT WINDOW 'Import klassif' + STR(RECNO('tmpKlassif')) + '/' + STR(RECCOUNT('tmpKlassif')) nowait
			TEXT TO lcString TEXTMERGE noshow
				INSERT INTO klassiflib (nomid, tyyp, konto)
					values(<<qryId.id>>,<<tmpKlassif.tyyp>>,'<<ALLTRIM(tmpKlassif.konto)>>')
			ENDTEXT
			
		ENDSCAN
		l_error = SQLEXEC(gnHandle, lcString)
		IF l_error < 1
			MESSAGEBOX('Viga')
			_cliptext = lcString
			SET STEP ON 
			exit		
		ENDIF
			
	ENDSCAN
	
	
ENDSCAN




=SQLDISCONNECT(gnHandle)