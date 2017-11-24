WAIT WINDOW 'Uhendan meke...' nowait

gnHandle = SQLCONNECT('meke')

IF gnhandle < 0 
	MESSAGEBOX('Viga, uhendus')
	SET STEP ON 
	return
ENDIF

WAIT WINDOW 'Uhendan meke...ok' TIMEOUT 1

* ladu andmed
lcFile = 'meke/ladu.xls'

IF !FILE(lcFile)
	MESSAGEBOX(' Puudub file' +lcFile)
endif

WAIT WINDOW 'Loen faili...' TIMEOUT 1

IMPORT FROM (lcFile) TYPE XL5

lImport = .f.
lnError = 1

IF USED('ladu')
	WAIT WINDOW 'Loen faili...ok, kokku '+ STR(RECCOUNT('ladu')) +' kirjad'  TIMEOUT 1
	lImport = .t.
ENDIF
IF lImport = .t.
* koostame vararegister
SELECT ladu
SCAN FOR a <> 'код запаса' AND !EMPTY(a)
	WAIT WINDOW 'vara register, importeerin:'+ALLTRIM(ladu.a)+str(RECNO('ladu'))+'/'+ STR(RECCOUNT('ladu')) nowait
	* kontrollin, kas kood juba andmebaasis
	
	lcString = "select id from nomenklatuur where dok = 'LADU' AND kood = '"+ALLTRIM(ladu.a)+"'"
	lError = SQLEXEC(gnHandle,lcString,'tmpId')
	IF lError < 1
		MESSAGEBOX('Viga')
		SET STEP on
		exit
	ENDIF
	IF RECCOUNT('tmpId') = 0 
		* uus kiri
		WAIT WINDOW 'vara register, importeerin..kood puudub, salvestan..:'+ALLTRIM(ladu.a)+str(RECNO('ladu'))+'/'+ STR(RECCOUNT('ladu')) nowait			
		* nomenklatuur
		lcString = "select sp_salvesta_nomenklatuur (0,1,0,'LADU','"+ALLTRIM(ladu.a)+"','"+ALLTRIM(ladu.b)+"','"+ALLTRIM(ladu.c)+"',"+;
			alltrim(ladu.e)+",'import',0,0,'','EUR',15.6466)"
		lnError = SQLEXEC(gnHandle,lcString,'tmpNomId')
		IF lnError < 0
			MESSAGEBOX('Viga')
			SET STEP ON 
			exit
		ENDIF
		* ladu_grupp
*				integer, integer, integer, numeric, date, numeric, numeric, numeric

		lcString = "select sp_salvesta_ladu_grupp(0,0,"+STR(tmpNomId.sp_salvesta_nomenklatuur)+",0::numeric,DATE(1900,01,01)::date,0::numeric,0::numeric,0::numeric)"
		lnError = SQLEXEC(gnHandle,lcString)
		IF lnError < 0
			MESSAGEBOX('Viga')
			SET STEP ON 
			exit
		ENDIF
		WAIT WINDOW 'vara register, importeerin..kood puudub, salvestan..Ok:'+ALLTRIM(ladu.a)+str(RECNO('ladu'))+'/'+ STR(RECCOUNT('ladu')) nowait			
				
	ELSE
		WAIT WINDOW 'vara register, importeerin..kood juba on:'+ALLTRIM(ladu.a)+str(RECNO('ladu'))+'/'+ STR(RECCOUNT('ladu')) nowait
	ENDIF
	
ENDSCAN
ENDIF

IF lnError > 0
* korras, koostame dokument
	WAIT WINDOW 'Kostan dokument..' nowait
	* arv
	
	lcString = "select sp_salvesta_arv(0,1,1,0,0,1,1, '1'::varchar,DATE(2012,01,01),7, 0, 'Import'::character, null::date, "+;
		" 0::numeric, 0::numeric, 0::numeric,null::date, ''::varchar,null, 0::numeric,0)"
	lnError = SQLEXEC(gnHandle,lcString,'tmpArvId')
	IF lnError < 0
		MESSAGEBOX('Viga')
		SET STEP ON 
		=SQLDISCONNECT(gnHandle)
		return
	ENDIF
	
	* koostame dokument
	SELECT ladu	
	SCAN FOR (a <> 'код запаса') AND !EMPTY(a)
		WAIT WINDOW 'arve, salvestan..kood..'+ALLTRIM(ladu.a)+str(RECNO('ladu'))+'/'+ STR(RECCOUNT('ladu')) nowait
		lcString = "select id, hind from nomenklatuur where dok = 'LADU' and kood = '"+ALLTRIM(ladu.a)+"'"
		lnError = SQLEXEC(gnHandle,lcString,'tmpNomId')
		IF lnError < 1
			MESSAGEBOX('Viga')
			SET STEP ON 
			exit
		ENDIF	
		lnKogus = VAL(ALLTRIM(ladu.d))
		lnSumma = tmpNomId.hind * lnKogus
		lcString = "select sp_salvesta_arv1(0,"+STR(tmpArvId.sp_salvesta_arv)+","+STR(tmpNomId.id)+","+ALLTRIM(ladu.d)+"::numeric,"+;
			ALLTRIM(str(tmpNomId.hind,14,2))+"::numeric,0,0::numeric,0,"+ALLTRIM(STR(lnSumma,14,2))+"::numeric,null::text,"+;
			"''::varchar,''::varchar,''::varchar,''::varchar,''::varchar,''::varchar,''::varchar,"+ALLTRIM(STR(lnSumma,14,2))+"::numeric,0,'','EUR',15.6466::numeric,'')"

		lnError = SQLEXEC(gnHandle,lcString)
		IF lnError < 0
			MESSAGEBOX('viga')
			SET STEP ON 
			exit
		endif
				
	ENDSCAN
	
ENDIF

=SQLDISCONNECT(gnHandle)