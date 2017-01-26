tcodbc = 'rugodiv'

*!*	If Empty(tcOdbc)
*!*		tcOdbc = 'NarvaLvPg'
*!*		=Inputbox('ODBC connection ', 'Import from VFP to PG', tcOdbc)
*!*	Endif
*!*	If Empty(tcOdbc)
*!*		Messagebox('Viga: puudub ODBC..')
*!*		Return
*!*	Endif


*!*	gnHandle = SQLConnect(tcOdbc)

*!*	If gnHandle < 1
*!*		lnErr = Aerror(err)
*!*		lcErr = err(1,3)
*!*		Messagebox('Viga: '+lcErr)
*!*		Return
*!*	Endif


Create Cursor skript (Sql m)


Set Memowidth To 16000
gnhandle = SQLConnect ('rugodiv')
=SQLEXEC(gnhandle,'begin work')

	Wait Window 'Selection record into cursors ...' Timeout 3

	If sqlexec(gnhandle,"select * from pg_tables where schemaname = 'public'",'qrytbl') < 0 Or !Used('qrytbl')
		Set Step On
		Return .F.
	Endif

	SELECT qryTbl
*	brow
	SET STEP ON
	
	SCAN FOR LTRIM(RTRIM(tablename)) <> 'raamat' and LTRIM(RTRIM(tablename)) <> 'uuendus'
		lcTbl = LTRIM(RTRIM(qryTbl.tablename))
		lcDbf = 'tbl'+lcTbl+'.dbf'
		lcSQL = LTRIM(RTRIM(qryTbl.tablename))+'.sql'
		IF FILE(lcSQL)
			Wait Window 'Skript:'+lcTbl Nowait
			lerror =fncImport()
			IF lError < 0 
				exit
			endif
		ENDIF
	ENDSCAN

If lError > 0
	=SQLEXEC(gnhandle,'commit work')
	=Messagebox('Ok')
ELSE
	SET STEP ON 
	=SQLEXEC(gnhandle,'rollback work')
	=Messagebox('Viga')
Endif
	
=SQLDISCONNECT(gnHandle)

	
	FUNCTION fncImport
	
		
* open
	SELECT 0
	IF USED('tmpTbl')
		USE IN tmpTbl
	ENDIF
	
	USE (lcDbf) ALIAS tmpTbl
	IF RECCOUNT('tmpTbl') = 0
		RETURN 1
	endif
	IF TYPE('tmpTbl.id') = 'U'
		RETURN 1
	ENDIF
	

	Select skript
	Append Blank

	If Used('v_cursor')
		Use In v_cursor
	Endif
	APPEND MEMO skript.sql FROM (lcSQL)
		
	FOR ii= 1 TO MEMLINES(skript.sql)
		lcSql = MLINE(skript.sql,ii)

		lnid = ATC(lcSql,'values (')
		lcid = SUBSTR(lcSql,lnId+8,6)
		lnKoma = AT(lcId,',')
		IF lnKoma > 0 
			lcid = STR(VAL(LEFT(lcId,lnKoma)))
		ELSE
			lcid = STR(VAL((lcId)))			
		ENDIF
			 	

		lcString = 'select id as id from '+lcTbl + ' where id = '+lcId	
		WAIT WINDOW 'checking rec'+ lcTbl nowait
		lError = SQLEXEC(gnhandle,lcString,'qryRec')
		IF lError > 0 
			IF USED('qryRec') AND RECCOUNT('qryrec') = 0
				WAIT WINDOW 'inserting brecord'+ lcTbl + STR(tmpTbl.id) nowait
				lcString = MLINE(skript.sql,ii)
				lError = SQLEXEC(gnhandle,lcString)
				IF lError < 1
					EXIT
				ELSE
					WAIT WINDOW 'inserting brecord'+ lcTbl + STR(tmpTbl.id)+'done' nowait
				ENDIF
			ENDIF
			
		ENDIF		
	endfor
RETURN lError
