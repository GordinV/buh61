Parameters tcDb, tcOdbc
If Empty(tcDb) Or !File(tcDb)
	tcDb = Getfile('DBC')
Endif
If Empty (tcDb)
	Messagebox('Viga: puudub andmebaas..')
	Return
ENDIF
tcodbc = 'lastekodu'

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




Close Databases All
Open Database (tcDb)

Create Cursor skript (Sql m)


Set Memowidth To 16000

cFail = 'c:\avpsoft\njlv\sql1.txt'
If File(cFail)
	ERASE (cFail)
Endif
	lnhandle = Fcreate(cFail)
	If lnhandle < 0
		Return .F.
	Endif


lnTables = Adbobjects(aTbl, 'TABLE')
Set Step On
For i = 1 To lnTables
	IF ALLTRIM(UPPER(aTbl(i))) = 'CURKUUD'
		loop
	ENDIF
	IF LEFT(ALLTRIM(UPPER(aTbl(i))),4) = 'MENU'
		loop
	ENDIF
	IF LEFT(ALLTRIM(UPPER(aTbl(i))),4) = 'USER'
		loop
	ENDIF
	IF LEFT(ALLTRIM(UPPER(aTbl(i))),4) = 'REKV'
		loop
	ENDIF

*	IF ALLTRIM(UPPER(aTbl(i))) <> 'ASUTUSAA'
*		loop
*	ENDIF
	
	Wait Window 'Skript:'+aTbl(i) Nowait
* open
	Select skript
	Append Blank

	If Used('v_cursor')
		Use In v_cursor
	Endif
	Use (aTbl(i)) In 0 Alias v_cursor
*!*		If Used('v_cursor')
*!*			Wait Window 'Opened :'+aTbl(i,1) TIMEOUT 1
*!*		Endif

*!*		lnError=Fputs(lnhandle,'SET check_function_bodies = false;')
*!*	nError=Fputs(lnhandle, 'SET client_min_messages = warning;')
*!*	nError=Fputs(lnhandle,'SET search_path = public, pg_catalog;')


	
*!*		Select skript
*!*		Replace skript.Sql With lcString

	Select v_cursor
	Scan
		Wait Window 'Opened: '+aTbl(i) + Alltrim(Str(Recno('v_cursor'),9))+'-'+Alltrim(Str(Reccount('v_cursor'))) Nowait
* structur
		lcInsert = ''
		lcvalueStr = ''
		lcvalue = ''
		lVal = .F.
		lnRecno = Recno('v_cursor')
		lnFields = Afields(afld,'v_cursor')
		For j = 1 To lnFields
			lcInsert = lcInsert + Iif(!Empty(lcInsert),',','')+Ltrim(Rtrim(afld(j,1)))
			If afld(j,2)= 'G'
				lcvalue = "''"
			Else
				lVal = Evaluate('v_cursor.'+Ltrim(Rtrim(afld(j,1))))
				Do Case
					Case Isnull(lVal)
						lcvalue = 'null'
					Case afld(j,2)= 'C' Or afld(j,2)= 'M'
						lcvalue = "'"+lVal+"'"
					Case afld(j,2)= 'D'
						lcvalue = "date("+Str(Year(lVal),4)+","+Str(Month(lVal),2)+","+Str(Day(lVal),2)+")"
					Case afld(j,2)= 'I'
						lcvalue = Ltrim(Str(lVal))
					Case afld(j,2)= 'N' Or afld(j,2)= 'F' Or afld(j,2)= 'B' Or afld(j,2)= 'Y'
						lnWidth = afld(j,3)
						lnDec= afld(j,4)
						lcvalue = Ltrim(Str(lVal,lnWidth,lnDec))
					Case afld(j,2) = 'L'
						lcvalue = Iif(lVal = .T.,'.T.','.F.')
					Case afld(j,2) = 'T'
						Do Case
							Case afld(j,2) = 'T'
								lcvalue = "'"+Dtoc(Ttod(lVal),1)+"'"
							Case afld(j,2) = 'D'
								lcvalue = "'"+Dtoc(lVal,1)+"'"
						Endcase
					Otherwise
						lcvalue = 'null'
				Endcase
			Endif

			lcvalueStr = lcvalueStr + Iif(!Empty(lcvalueStr),',','')+lcvalue

		Endfor

		lcInsert = ' insert into '+aTbl(i)+' ('+lcInsert+') values ('+lcvalueStr+');'
*!*			Select skript
*!*			Replace skript.Sql With lcInsert



*!*			If File('c:\avpsoft\hooldekodu\sql.txt')
*!*				Copy Memo skript.Sql To c:\avpsoft\hooldekodu\Sql.txt Additive
*!*			Else
*!*				Copy Memo skript.Sql To c:\avpsoft\hooldekodu\Sql.txt
*!*			Endif

		lnError=Fputs(lnhandle,lcInsert)


*
*WAIT WINDOW 'Skripted :'+lcInsert TIMEOUT 1
		Select v_cursor
		Go lnRecno

	ENDSCAN
	
	Select Max(Id) As Id From v_cursor Into Cursor v_maxId

	lcTbl = Lower(Alltrim(aTbl(i)))

	lnError=Fputs(lnhandle,"sELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('"+lcTbl+"', 'id'), "+;
		Alltrim(Str(v_maxId.Id,9))+", true);")

	Use In v_cursor
	Use In v_maxId
Endfor


*!*	Modify Memo skript.Sql
Close Databases
=Fclose (lnhandle)

*!*	=SQLDISCONNECT(gnHandle)
