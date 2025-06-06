Clear All


*gnVersia = 'MSSQL'
gnVersia = 'VFP'

Set Date To German
Set Century On

Set Safety Off

If !Used ('config')
	Use config In 0
Endif


*!*	SET STEP ON
*!*	lcstr = DateToStr(DATE())
*!*	RETURN


Create Cursor curKey (versia m)
Append Blank
Replace versia With 'RAAMA' In curKey
Create Cursor versia (admin Int Default 1)
Append Blank

gnhandleSQL = 0
lcDbf = ''


gnhandleSQL = SQLConnect ('lastekodu')
gnhandlePG = SQLConnect ('lastekoduvana')


If gnVersia = 'MSSQL' And gnhandleSQL < 0
	Messagebox('Viga connection','Kontrol')
	Set Step On
	Return
Endif
If gnhandlePG < 0
	Messagebox('Viga connection','Kontrol')
	Set Step On
	Return
Endif
grekv = 1
gversia = 'PG'


Local lError
lError = mssql_to_cursor()
*lError = skript()

=SQLDISCONNECT(gnhandleSQL)
=SQLDISCONNECT(gnhandlePG)
If Used('qryLog')
	Copy Memo qryLog.Log To Buh60Dblog.Log
	Use In qryLog
Endif


Function mssql_to_cursor

	Wait Window 'Selection record into cursors ...' Timeout 3
	Wait Window 'Selection record into cursors: userid ...' Nowait

	If sqlexec(gnhandlePg,"select * from pg_tables where schemaname = 'public' and Ltrim(Rtrim(tablename)) = 'journal1'",'qrytbl') < 0 Or !Used('qrytbl')
		Set Step On
		Return .F.
	Endif

	Select qryTbl
*	brow
*	Scan For Ltrim(Rtrim(tablename)) <> 'raamat' And Ltrim(Rtrim(tablename)) <> 'uuendus' And Ltrim(Rtrim(tablename)) <> 'saldo'
	Scan For Ltrim(Rtrim(tablename)) = 'journal1' 

* old tbl

		lnRec = Recno()
		Wait Window qryTbl.tablename Timeout 0.5
		lcTable = Ltrim(Rtrim(qryTbl.tablename))
		lcstring = 'select * from ' + lcTable
		lerr = 1
		If sqlexec(gnhandlePG,lcstring,'qry'+lcTable) < 0
			lerr = 0
			Exit

		Endif
* new tbl
		If lerr = 1
			Select * From ('qry'+lcTable) Into Table ('tbl'+lcTable)
			Wait Window 'Skript'+ lcTable Nowait
			
			SET STEP ON 
			=sqlexec(gnhandleSQL,'begin work')
			lerr=skript()
			IF lerr < 0
				SET STEP ON 
				=SQLEXEC(gnHandleSQL,'rollback work')
				EXIT
			ELSE
				=SQLEXEC(gnHandleSQL,'commit work')			
			ENDIF
			
		Else
			Set Step On
		Endif
		Select qryTbl
		Go lnRec
		Use In (lcTable)
	Endscan
	If lerr = 1
		Wait Window 'Selection record into cursors: done' Timeout 3
*			=skript()
	Else
		Wait Window 'Selection record into cursors: viga' Timeout 3
		Set Step On
	Endif



Endfunc


Function fnc_check_id
	Lparameters tcTbl, tnId

	lcstring = 'select id from '+ tcTbl+' where id = '+ Alltrim(Str(tnId))
	lError = sqlexec(gnhandleSQL,lcstring,'qryId')
	If lError < 1
		Return -1
	Endif
	If lError > 0 And Reccount('qryId') > 0
		Return 1
	Endif
	If lError > 0 And Reccount('qryId') = 0
		Return 0
	Endif


Endfunc



Function skript
	lError = 0
	
	Create Cursor skript (Sql m)


	Set Memowidth To 16000


	Wait Window 'Skript:'+qryTbl.tablename Nowait
* open
	Select skript
	Append Blank

	If Used('v_cursor')
		Use In v_cursor
	Endif
	lcTable = 'qry'+Ltrim(Rtrim(qryTbl.tablename))
	Select * From (lcTable) WHERE parentid > 25372 Into Table v_cursor
	cFail = Ltrim(Rtrim(qryTbl.tablename))+'.sql'

	Select v_cursor
	SCAN 
			Wait Window 'Opened: '+Ltrim(Rtrim(qryTbl.tablename)) + Alltrim(Str(Recno('v_cursor'),9))+'-'+Alltrim(Str(Reccount('v_cursor'))) TIMEOUT 0.5		
			
		
* structur
		lcInsert = ''
		lcvalueStr = ''
		lcvalue = ''
		lVal = .F.
		lnRecno1 = Recno('v_cursor')
		lnFields = Afields(afld,'v_cursor')
		If Ascan(afld,'ID') > 0
			For j = 1 To lnFields
				lcInsert = lcInsert + Iif(!Empty(lcInsert),',','')+IIF(UPPER(afld(j,1))= UPPER('palk_lehti'),'palk_lehtid',Ltrim(Rtrim(afld(j,1))))
				If afld(j,2)= 'G'
					lcvalue = "''"
				Else
					lVal = Evaluate('v_cursor.'+Ltrim(Rtrim(afld(j,1))))
					IF UPPER(Ltrim(Rtrim(afld(j,1)))) = 'ID' OR UPPER(Ltrim(Rtrim(afld(j,1)))) = 'PARENTID' 
						lval = lVal + 30000
					endif
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

			lcInsert = ' insert into '+Ltrim(Rtrim(qryTbl.tablename))+' ('+lcInsert+') values ('+lcvalueStr+');'

*		lnError=Fputs(lnhandle,lcInsert)
*			If fnc_check_id(qryTbl.tablename, EVALUATE('v_cursor.id')) = 0
				WAIT WINDOW 'Insert '+Ltrim(Rtrim(qryTbl.tablename)) nowait
				
				lError = sqlexec(gnhandleSQL,lcInsert)
*			Endif
			If lError < 0
				SET STEP ON 
				Exit
			Endif
		Endif


*
*WAIT WINDOW 'Skripted :'+lcInsert TIMEOUT 1
		Select v_cursor
*		Go lnRecno1

	ENDSCAN
	RETURN lError
*!*
*!*		Select Max(Id) As Id From v_cursor Into Cursor v_maxId

*!*		lcTbl = Lower(Alltrim(LTRIM(RTRIM(qryTbl.tablename))))

*!*		lnError=Fputs(lnhandle,"sELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('"+lcTbl+"', 'id'), "+;
*!*			Alltrim(Str(v_maxId.Id,9))+", true);")

*!*		Use In v_cursor
*!*		Use In v_maxId
*!*		=Fclose (lnhandle)



*Modify Memo skript.Sql
*Close Databases

*!*	=SQLDISCONNECT(gnHandle)

Endfunc




*!*	If lError > 0
*!*		lError = set_serials()
*!*	Endif




Function remove_simbol
	Lparameters tcString
	Local lcstring
	lcstring = ''
	lcProjStr = "'"

	If lcProjStr $ lcstring
*	lnStart = STUFF(tcString,AT(tcString,lcProjStr),'')
		lnStart = Stuff(tcString,At(lcProjStr,tcString),1,'')

	Endif


	Return lcstring


Function DateToStr
	Lparameters tdKpv

	Local lcstring

	If Type('tdKpv') = 'C'
		tdKpv = Alltrim(tdKpv)
		tdKpv = Date(Val(Right(tdKpv,4)),Val(Substr(tdKpv,4,2)),Val(Left(tdKpv,2)))
	Endif

	If Empty(tdKpv) Or Type('tdKpv') <> 'D'
		lcstring = 'null'
	Else
		lcstring = "DATE("+Left(Dtoc(tdKpv,1),4)+","+Substr(Dtoc(tdKpv,1),5,2)+","+Right(Dtoc(tdKpv,1),2)+")"
	Endif

	Return lcstring
