Clear All

gnVersia = 'PG'

*gnVersia = 'MSSQL'
*gnVersia = 'VFP'

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

gnhandleSQL = SQLConnect ('buhdata5zur','zinaida','159')


gnhandlePG = SQLConnect ('zurpg','vlad','490710')

grekv = 1
gversia = 'PG'


Local lError
=sqlexec (gnhandlePG,'begin work')

* switch off triggers

lcString = " update pg_trigger set tgenabled = false"
If sqlexec (gnhandlePG,lcString) < 0
	Set Step On
	lError = .F.
Else

*lError = kontotyyp()
	lError = kontojaak ()
*	lError = subjaak ()
	If Vartype (lError ) = 'N'
		lError = Iif( lError = 1,.T.,.F.)
	Endif

Endif

If lError = .F.
	=sqlexec (gnhandlePG,'ROLLBACK WORK')
Else
	lcString = " update pg_trigger set tgenabled = true"
	=sqlexec (gnhandlePG,lcString)
	=sqlexec (gnhandlePG,'COMMIT WORK')
*!*		Wait Window 'Grant access to views' Nowait
*!*		lError =pg_grant_views()
*!*		Wait Window 'Grant access to tables' Nowait
*!*		lError = pg_grant_tables()
Endif
=SQLDISCONNECT(gnhandlePG)
If Used('qryLog')

	Copy Memo qryLog.Log To Buh60Dblog.Log
	Use In qryLog
Endif




Function kontotyyp

	lcString = "select library.id, kontoinf.type from library inner join kontoinf on library.id = kontoinf.parentid"
	=SQLEXEC(gnHandleSQL,lcString,'tmpKontotyyp')

	Select tmpKontoTyyp
	Scan
		Wait Window STR(Recno('tmpKontoTyyp'))+'/'+STR(Reccount('tmpKontoTyyp')) Nowait

		lcString = 'update library set tun5 = '+Str(tmpKontoTyyp.Type) + 'where id = '+Str(tmpKontoTyyp.Id)

		If SQLEXEC(gnhandlePG,lcString) < 0
			Wait Window 'Update faild'
			_Cliptext = lcString
			Exit
			Return 0
		Endif
	Endscan
	Return 1
Endfunc



Function subjaak
	Local lResult, lcFile
	lResult = 1

	lcFile = 'c:\buh50\zurasutusjaak.dbf'
	If !File(lcFile)
		Wait Window 'Viga fail'
		Return 0
	Endif
	Select 0
	Use (lcFile) Alias kontojaak


	lcString = 'select library.*, subkonto.algsaldo,subkonto.asutusid, subkonto.id as kontoinfId from library inner join subkonto on library.id = subkonto.kontoid '
	If sqlexec(gnhandlePG,lcString,'tmpKontoJaak') < 0
		Wait Window 'Viga sql paring'
		_Cliptext = lcString
		Return 0
	Endif


	Create Cursor sqllog( vead m)


	Select kontojaak
	Scan
		Wait Window kontojaak.col_1 Nowait
		Select tmpKontoJaak
		Locate For Alltrim(kood) = Alltrim(kontojaak.col_1) AND asutusid = kontojaak.col_2 
		If !Found()
*			Wait Window 'Kood:' + kontojaak.col_1 + ' not found'
*			Insert Into sqllog ( vead) Values (kontojaak.col_1 + ' not found')
			Wait Window 'Updating kood:'+kontojaak.col_1 + Str(kontojaak.col_4,12,2) Nowait

			lnAlgsaldo = kontojaak.col_4
			lnAsutusId = kontojaak.col_2
			SELECT tmpKontoJaak
			LOCATE FOR kood = Alltrim(kontojaak.col_1)
			IF FOUND()
	
				lcString = 'INSERT INTO subkonto (rekvid, kontoid,  asutusId, algsaldo) VALUES (1,'+;
					STR(tmpKontoJaak.id)+','+	STR(lnAsutusId)+','+	STR(lnAlgsaldo,12,2)+')'	
			
			
*		Else
*					lcString = 'INSERT INTO subkonto (rekvid, kontoid, asutusId, algsaldo) VALUES (1,'+STR(tmpKontoJaak.id)+','+Str(kontojaak.col_2)+','+Str(kontojaak.col_4,12,2)+')'

*!*					Wait Window 'Updating kood:'+kontojaak.col_1 + Str(kontojaak.col_4,12,2) Nowait
*!*					lcString = 'update subkonto set algsaldo = ' + Str(kontojaak.col_4,12,2)+' where id = ' + Str(tmpKontoJaak.kontoinfId)

				If sqlexec(gnhandlePG,lcString) < 0
					Wait Window 'Update faild'
					_Cliptext = lcString
					Exit
					Return 0

				Endif
*!*					Wait Window 'Updating kood:'+kontojaak.col_1 + Str(kontojaak.col_4,12,2)+' success' Nowait
		ENDIF
		ENDIF
		

	Endscan



	Use In kontojaak
	Use In tmpKontoJaak


		


	Return lResult



Function kontojaak
	Local lResult, lcFile
	lResult = 1
SET STEP ON 
	lcFile = 'c:\avpsoft\files\buh60\script\zurjaak1.dbf'
	If !File(lcFile)
		Wait Window 'Viga fail'
		Return 0
	Endif
	Select 0
	Use (lcFile) Alias kontojaak



	lcString = "select * from kontoinf "
	If sqlexec(gnhandleSQL,lcString,'tmpKontoTyyp') < 0
		Wait Window 'Viga sql paring'
		_Cliptext = lcString
		Return 0
	Endif

	lcString = "select library.*, kontoinf.algsaldo, kontoinf.id as kontoinfId from library left outer join kontoinf on library.id = kontoinf.parentid where library = 'KONTOD'"
	If sqlexec(gnhandlePG,lcString,'tmpKontoJaak') < 0
		Wait Window 'Viga sql paring'
		_Cliptext = lcString
		Return 0
	Endif


	Create Cursor sqllog( vead m)


	Select kontojaak
	Scan
		Wait Window kontojaak.col_1 TIMEOUT 1
		Select tmpKontoJaak
		Locate For Alltrim(kood) = Alltrim(kontojaak.col_1)
		If !Found()
			Wait Window 'Kood:' + kontojaak.col_1 + ' not found'
			Insert Into sqllog ( vead) Values (kontojaak.col_1 + ' not found')
		Else


			If kontojaak.col_3 <> 0 And kontojaak.col_3 <> IIF(ISNULL(tmpKontoJaak.algsaldo),0,tmpKontoJaak.algsaldo)
				Wait Window 'Updating kood:'+kontojaak.col_1 + Str(kontojaak.col_3,12,2) TIMEOUT 1
				IF ISNULL(tmpKontoJaak.algsaldo)
					lcString = 'INSERT INTO kontoinf (rekvid, parentid, algsaldo) VALUES (1,'+STR(tmpKontoJaak.id)+','+Str(kontojaak.col_3,12,2)+')'
				ELSE				
					lcString = 'update kontoinf set algsaldo = ' + Str(kontojaak.col_3,12,2)+' where id = ' + Str(tmpKontoJaak.kontoinfId)
				ENDIF

				

				If sqlexec(gnhandlePG,lcString) < 0
					Wait Window 'Update faild'
					_Cliptext = lcString
					Exit
					Return 0

				Endif
				If sqlexec(gnhandlePG,lcString) < 0
					Wait Window 'Update faild'
					_Cliptext = lcString
					Exit
					Return 0

				Endif

				Wait Window 'Updating kood:'+kontojaak.col_1 + Str(kontojaak.col_3,12,2)+' success'TIMEOUT 1

			Endif
			If kontojaak.col_4 <> 0 And -1 * kontojaak.col_4 <> IIF(ISNULL(tmpKontoJaak.algsaldo),0,tmpKontoJaak.algsaldo)
				Wait Window 'Updating kood:'+kontojaak.col_1 + Str(kontojaak.col_4,12,2) TIMEOUT 1
				IF ISNULL(tmpKontoJaak.algsaldo)
					lcString = 'INSERT INTO kontoinf (rekvid, parentid, algsaldo) VALUES (1,'+STR(tmpKontoJaak.id)+','+Str(kontojaak.col_4,12,2)+')'
				ELSE				

					lcString = 'update kontoinf set algsaldo = ' + Str(-1 * kontojaak.col_4,12,2)+' where id = ' + Str(tmpKontoJaak.kontoinfId)
				ENDIF
				
				If sqlexec(gnhandlePG,lcString) < 0
					Wait Window 'Update faild'
					_Cliptext = lcString
					Exit
					Return 0

				Endif

				Wait Window 'Updating kood:'+kontojaak.col_1 + Str(kontojaak.col_4,12,2)+' success' TIMEOUT 1
			ENDIF

			
		Endif

	Endscan




	Use In kontojaak
	Use In tmpKontoJaak


	Return lResult
