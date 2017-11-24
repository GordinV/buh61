SET STEP ON 
IF !USED('svt')
lcFile = "c:\avpsoft\files\buh61\meke\svt.xls"
IMPORT FROM (lcFile) TYPE XLS

ENDIF

lCount = 0

gnHandle = SQLConnect('mekearv')
If gnHandle < 0
	Set Step On
	Return
Endif

If !Used('qryObj')
	lcString = " select library.id, library.kood FROM library inner join objekt on library.id = objekt.libId where objekt.parentid = 0"

	lError = SQLEXEC(gnHandle,lcString,'qryObj')
	If Used('qryObj')
		Select qryObj
	Else
		Set Step On
	Endif
Endif


Select svt
GO top
lnMopId = 0
Scan
		Wait Window STR(RECNO('svt'))+'/'+STR(RECCOUNT('svt')) Nowait
		* otsime maja nimikirjas
		lcMaja = ALLTRIM(STUFF(svt.a,ATC('  ',svt.a),1,''))
		lnMopId = 0
		
		SELECT qryObj
		LOCATE FOR UPPER(qryObj.kood) = UPPER(lcmaja)
		IF !FOUND()
			LOOP
		ENDIF
		WAIT WINDOW 'Maja leitud .'+lcMaja nowait
		
		* otsime korter koos MOPiga
		
		lcString = "select nomid from leping2 inner join leping1 on leping1.id = leping2.parentid  where nomid in (1855, 1856, 1857, 1858) and kogus = 1  and objektid in "+;
		" (select library.id from library inner join objekt on library.id = objekt.libid  where objekt.parentid = "+;
			STR(qryObj.id)+") order by leping2.id desc limit 1 "

		lError = SQLEXEC(gnHandle,lcString,'qryMOP')
		IF lError < 1 
			_cliptext = lcString
			SET STEP ON 
			exit
		ENDIF
		IF USED('qryMOP') AND RECCOUNT('qryMOP') > 0
			lnMop = qryMOP.nomid
		ELSE
			lnMop = 0
		ENDIF
			
		* selle maja korterid ja lepingud
		
		lcString = "select leping1.id from leping1 where objektid in (select library.id from library inner join objekt on library.id = objekt.libid  where objekt.parentid = "+;
			STR(qryObj.id)+")"
		
		lError = SQLEXEC(gnHandle,lcString,'qryLep1')
		IF lError < 1 OR RECCOUNT('qryLep1') = 0
*			_cliptext = lcString
*			SET STEP ON 
*			exit
			loop
		ENDIF
		
		* kontrollime lepingud
		SELECT qryLep1
		SCAN
			WAIT WINDOW 'uuendan leping..'+lcMaja + STR(RECNO('qryLep1'))+'/'+STR(RECCOUNT('qryLep1')) nowait
			IF lnMOP > 0
				lcString = 'update leping2 set kogus = 1 where nomid = '+STR(lnMOP)+' and parentid = ' + STR(qryLep1.id)
			lError = SQLEXEC(gnHandle,lcString)
			IF lError < 1  
				_cliptext = lcString
				SET STEP ON 
				exit
			ENDIF
			ENDIF
					
			lcString = 'update leping2 set kogus = 0 where nomid in(1851, 1852, 1853, 1860) and parentid = ' + STR(qryLep1.id)
			lError = SQLEXEC(gnHandle,lcString)
			IF lError < 1  
				_cliptext = lcString
				SET STEP ON 
				exit
			ENDIF
			
			DO case
				CASE svt.b = 1
					lcString = 'update leping2 set kogus = 1 where nomid = 1851 and parentid = ' + STR(qryLep1.id)
				CASE svt.b = 2
					lcString = 'update leping2 set kogus = 1 where nomid = 1852 and parentid = ' + STR(qryLep1.id)
				CASE svt.b = 3
					lcString = 'update leping2 set kogus = 1 where nomid = 1853 and parentid = ' + STR(qryLep1.id)
				OTHERWISE
					lcString = ''
			ENDCASE
			IF !EMPTY(lcString)
				lError = SQLEXEC(gnHandle,lcString)
				IF lError < 1  
					_cliptext = lcString
					SET STEP ON 
					exit
				ENDIF		
			ELSE
				WAIT WINDOW 'uuendan leping..'+lcMaja + STR(RECNO('qryLep1'))+'/'+STR(RECCOUNT('qryLep1')) + ' onnestus' nowait
			ENDIF
			
			


		endscan
		lCount = lCount + 1
*!*			IF lCount = 2
*!*				exit
*!*			ENDIF
		IF lError < 0 
			exit
		ENDIF
				
Endscan


=SQLDISCONNECT(gnHandle)
