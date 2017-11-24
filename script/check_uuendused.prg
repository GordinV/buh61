


Set Safety Off
CLEAR all

gnhandle = SQLConnect ('narvalvpg')
If gnhandle < 0
	Messagebox('Viga connection','Kontrol')
	Set Step On
	Return
ENDIF
IF !USED('tmpTp')
	lnResult = SQLEXEC(gnHandle,"select * from library where library = 'TP'",'TMPtP')

IF lnResult < 0 
	Messagebox('Viga tp pärngus','Kontrol')
	Set Step On
	Return
endif
ENDIF

*SELECT tmpTp

CREATE CURSOR tmpLog (log m)
SELECT tmpLog
APPEND BLANK


IF !USED('curU')
lcFile = 'uuendused\u32.xls'

SELECT 0
Import From (lcFile) Type Xls

Select * From u32 Into Cursor curU
ENDIF

SELECT curU
SCAN FOR NOT EMPTY(curU.c)
	WAIT window curU.c nowait
	lcKood = LTRIM(RTRIM(STR(curU.a,6)))
	IF LEN(lcKood) = 5 then
		lcKood = '0'+lcKood
	ENDIF
	lnRegkood = 0
	lnTun1 = 0
	lnTun4 = 0
	lnTun5 = 0
	
	SELECT tmpTp
	LOCATE FOR kood = lcKood
	IF FOUND()
		* kontrol kas on muudetusi
		lnUpdate = 0
		IF !EMPTY(curU.b) AND EMPTY(tmpTp.tun1)
			lnTun1 = curU.B		
			lnUpdate = 1
		ENDIF
		IF !EMPTY(curU.d) AND EMPTY(tmpTp.tun4)
			lnTun4 = VAL(ALLTRIM(DTOC(curU.d,1)))		
			lnUpdate = 1
		ENDIF
		IF !EMPTY(curU.e) AND EMPTY(tmpTp.tun5)
			lnTun5 = VAL(ALLTRIM(DTOC(curU.e,1)))		
			lnUpdate = 1
		ENDIF
		IF lnUpdate = 1 
			WAIT WINDOW STR(curU.a) + 'parandame' nowait
			lcString = ''
			IF !EMPTY(lnTun1) 
				lcString = lcString + ' tun1 = '+STR(lnTun1,9)
			ENDIF
			IF !EMPTY(lnTun4) 
				lcString = lcString + IIF(!EMPTY(lcString),',','')+' tun4 = '+STR(lnTun4,9)
			ENDIF
			IF !EMPTY(lnTun5) 
				lcString = lcString + IIF(!EMPTY(lcString),',','')+' tun5 = '+STR(lnTun5,9)
			ENDIF
			lcString = 'update library set '+lcstring+' where id = '+STR(tmptp.id,9)
			WAIT WINDOW lcString nowait
			lnResult = SQLEXEC(gnHandle,lcString)
			IF lnResult < 1
				SET STEP ON 
				exit
			ENDIF
			
			SELECT tmpLog
			replace tmpLog.log WITH 'parandetud:'+STR(curU.a)+' '+ALLTRIM(curU.c) + chr(13) additive
		ENDIF
			
	ELSE
		* lisame
		WAIT WINDOW STR(curU.a) + 'lisame' nowait
		
		lcString = ' insert into library (rekvid,kood, nimetus, library,tun1, tun4,tun5) values (63,'
		lcString = lcString + "'"+lcKood+"','"+LTRIM(RTRIM(curU.c))+"','TP',"+STR(curU.b)+","+ALLTRIM(DTOC(curU.d,1))+","+IIF(EMPTY(curU.e),'20201231',ALLTRIM(DTOC(curU.e,1)))+")"


		WAIT WINDOW lcstring TIMEOUT 1
			lnResult = SQLEXEC(gnHandle,lcString)
			IF lnResult < 1
				SET STEP ON 
				exit
			ENDIF

		SELECT tmpLog
		replace tmpLog.log WITH 'lisatud:'+STR(curU.a)+' '+ALLTRIM(curU.c) + chr(13) additive

	endif
	 
	
ENDSCAN



=SQLDISCONNECT(gnhandle)

SELECT tmpLog
COPY MEMO tmpLog.log TO uuendus.txt

MODIFY FILE uuendus.txt 


*!*	text
*!*	Local lError
*!*	=sqlexec (gnhandle,'begin work')
*!*	Set Step On
*!*	lError = import_tootajad()
*!*	If Vartype (lError ) = 'N'
*!*		lError = Iif( lError = 1,.T.,.F.)
*!*	Endif
*!*	If lError = .F.
*!*		=sqlexec (gnhandle,'ROLLBACK WORK')
*!*	Else
*!*		=sqlexec (gnhandle,'COMMIT WORK')
*!*	*!*		Wait Window 'Grant access to views' Nowait
*!*	*!*		lError =pg_grant_views()
*!*	*!*		Wait Window 'Grant access to tables' Nowait
*!*	*!*		lError = pg_grant_tables()
*!*	Endif
*!*	=SQLDISCONNECT(gnhandle)
*!*	If Used('qryLog')
*!*		Copy Memo qryLog.Log To Buh60Dblog.Log
*!*		Use In qryLog
*!*	Endif


*!*	Function import_tootajad
*!*		Local lTulemus, lcFile, lnisikId, lnOsakond, lnAmet
*!*		lcFile = 'temp\llm.xls'

*!*		Import From (lcFile) Type Xls

*!*		Select * From llm Into Cursor curTt

*!*		Select curTt
*!*		SCAN FOR !EMPTY(curTt.e)
*!*	* check for name in asutus
*!*			lcIsikuKood = Alltrim(STR(curTt.e,12,0))
*!*			lcNimi = Trim(curTt.b)
*!*			lcAadress = Trim(curTt.F)
*!*			lcAmet = Alltrim(curTt.c)
*!*			lcOsakond = Alltrim(curTt.d)
*!*			lcAlgKpv = Alltrim(curTt.i)
*!*			lcAa = Alltrim(curTt.g)
*!*			lcpalk = Alltrim(STR(curTt.j))
*!*			lcPohikoht = Alltrim(curTt.h)
*!*			lcpank = Iif(Left(lcAa,2) = '33','722',Iif(Left(lcAa,4) = '1056','401','767'))
*!*			lcKoormus = Alltrim(STR(curTt.k,12,4))

*!*			WAIT WINDOW STR(RECNO('curTt'))+'-'+STR(RECCOUNT('curTt'))+lcNimi nowait
*!*			
*!*			lnisikId = get_isik_id(lcIsikuKood)

*!*			If lnisikId = 0
*!*				If uusIsik()
*!*					lnisikId = get_isik_id(lcIsikuKood)
*!*					=uusAa()
*!*				Else
*!*					If !err()
*!*						Exit
*!*					Endif
*!*				Endif
*!*			Endif
*!*			lnOsakond = get_osakond_id(lcOsakond)
*!*			If lnOsakond = 0
*!*				If uusOsakond()
*!*					lnOsakond = get_osakond_id(lcOsakond)
*!*				Else
*!*					If !err()
*!*						Exit
*!*					Endif
*!*				Endif
*!*			Endif
*!*			lnAmetId = get_amet_id(lnOsakond)
*!*			If lnAmetId = 0
*!*				If uusAmet(lnOsakond)
*!*					lnAmetId = get_amet_id(lnOsakond)
*!*				Else
*!*					If !err()
*!*						Exit
*!*					Endif
*!*				Endif
*!*			ENDIF
*!*			
*!*			IF lnAmetid = 0
*!*				SET STEP ON 
*!*			endif
*!*			
*!*			If get_tooleping(lnisikid, lnOsakond,lnAmetid) = 0
*!*				If !uusTooleping(lnisikid, lnOsakond,lnAmetid)
*!*					If !err()
*!*						Exit
*!*					Endif
*!*				Endif

*!*			Endif



*!*		Endscan


*!*		Return lTulemus

*!*	Endfunc

*!*	Function err
*!*		lnError = Aerror(laerr)
*!*		If lnError > 0 
*!*			lcError = laerr(1,3)
*!*			Wait Window lcError
*!*	*		_Cliptext = lcError
*!*			lTulemus = .F.
*!*			Return .F.
*!*		Else
*!*			Return .T.
*!*		Endif

*!*	Endfunc


*!*	Function uusTooleping
*!*		LPARAMETERS tnisik, tnOsakond, tnAmet

*!*		Local 	lcString, lTulemus
*!*		IF !EMPTY(lcAlgKpv)
*!*			lcAlg = "date("+SUBSTR(lcAlgKpv,7,4)+","+SUBSTR(lcAlgKpv,4,2)+","+SUBSTR(lcAlgKpv,1,2)+")"
*!*		ELSE
*!*			lcAlg = "date(2006,01,01)"
*!*		ENDIF
*!*		
*!*		lcString = "insert into tooleping (rekvid, parentid, osakondid,ametid, algab, toopaev, palk, pohikoht,ametnik,tasuliik,resident, koormus ) values ("+ Str(grekv)+","+;
*!*			STR(tnisik)+","+Str(tnOsakond)+","+Str(tnAmet)+","+lcAlg+",8,"+lcpalk+","+lcPohikoht+",0,1,1,"+lcKoormus+")"
*!*		
*!*		_cliptext = lcstring
*!*		
*!*		IF EMPTY(tnAmet) OR EMPTY(tnOsakond) OR EMPTY(tnisik)
*!*			RETURN .f.
*!*		ENDIF
*!*		
*!*		
*!*		If sqlexec(gnhandle,lcString) > 0
*!*			Return .T.
*!*		Else
*!*			Return .F.
*!*		Endif

*!*	Endfunc


*!*	Function uusAa
*!*		If !Empty(lcAa)
*!*			lcString = "insert into asutusaa (rekvid, parentid, aa, pank ) values ("+ Str(grekv)+","+;
*!*				STR(lnisikId)+",'"+lcAa+"','"+lcpank+"')"

*!*		_cliptext = lcstring

*!*			If sqlexec(gnhandle,lcString) > 0
*!*				Return .T.
*!*			Else
*!*				Return .F.
*!*			Endif

*!*		Else
*!*			Return .T.
*!*		Endif

*!*	Endfunc


*!*	Function get_tooleping
*!*		LPARAMETERS tnisik, tnOsakond, tnAmet
*!*		Local lnLibId
*!*		lnLibId = 0
*!*		lcString = " select id from tooleping where ametId = " + Str(tnAmet) +" and rekvid = " +;
*!*			STR(grekv) +" and osakondId  = " + Str(tnOsakond) + " and parentId = "+ Str(tnisik)

*!*		_cliptext = lcstring
*!*		lnError = sqlexec(gnhandle,lcString)
*!*		If lnError > 0 And Used('sqlresult')
*!*			If Reccount('sqlresult') > 0
*!*	* OSAKOND andmebaasis
*!*				lnLibId = sqlresult.Id
*!*			Else
*!*				lnLibId = 0
*!*			Endif
*!*		Endif
*!*		If Used('sqlresult')
*!*			Use In sqlresult
*!*		Endif
*!*		Return lnLibId


*!*	Function uusAmet
*!*		LPARAMETERS tnOsakond
*!*		Local 	lcString, lTulemus
*!*		lcString = "insert into library (rekvid, kood, nimetus, library ) values ("+ Str(grekv)+",'"+;
*!*			LEFT(lcAmet,20) +"','"+lcAmet+"','AMET')"

*!*		_cliptext = lcstring
*!*		If sqlexec(gnhandle,lcString) < 1
*!*			Return .F.
*!*		Endif
*!*		lcString = "SELECT ID FROM library  where rekvid = "+ Str(grekv) + " and  library = 'AMET' order by id desc limit 1"
*!*		_cliptext = lcstring
*!*		If sqlexec(gnhandle,lcString) < 1 Or Not Used('sqlresult')
*!*			Return .F.
*!*		ENDIF
*!*		lnAmetid = sqlresult.id
*!*		lcString = "insert into palk_asutus (rekvid, osakondId, ametid, kogus, vaba, palgamaar ) values ("+ Str(grekv)+","+;
*!*			STR(tnOsakond,9) +","+STR(lnAmetId,9)+",1,0,0)"
*!*		_cliptext = lcstring
*!*		If sqlexec(gnhandle,lcString) < 1
*!*			Return .F.
*!*		Else
*!*			Return .T.
*!*		Endif


*!*	Endfunc


*!*	Function get_amet_id
*!*		LPARAMETERS tnOsakond
*!*		Local lnLibId
*!*		lnLibId = 0
*!*		lcString = " select library.id from library inner join palk_asutus on library.id = palk_asutus.ametid " + ;
*!*			" where palk_asutus.osakondId = " + Str(tnOsakond,9,0) + " and LTRIM(RTRIM(LEFT(library.kood,20))) = '" + LEFT((lcAmet),20) + ;
*!*			"' and library.rekvid = " + Str(grekv) +" and library = 'AMET'"

*!*		_cliptext = lcstring
*!*		lnError = sqlexec(gnhandle,lcString)
*!*		If lnError > 0 And Used('sqlresult')
*!*			If Reccount('sqlresult') > 0
*!*	* OSAKOND andmebaasis
*!*				lnLibId = sqlresult.Id
*!*			Else
*!*				lnLibId = 0
*!*			Endif
*!*		Endif
*!*		If Used('sqlresult')
*!*			Use In sqlresult
*!*		Endif
*!*		Return lnLibId

*!*	Endfunc


*!*	Function uusOsakond
*!*		Local 	lcString, lTulemus
*!*		lcString = "insert into library (rekvid, kood, nimetus, library ) values ("+ Str(grekv)+",'"+;
*!*			LEFT(lcOsakond,20) +"','"+lcOsakond+"','OSAKOND')"

*!*		_cliptext = lcstring
*!*		If sqlexec(gnhandle,lcString) > 0
*!*			Return .T.
*!*		Else
*!*			Return .F.
*!*		Endif

*!*	Endfunc



*!*	Function get_osakond_id
*!*		Lparameters tcKood
*!*		Local lnLibId
*!*		lnLibId = 0
*!*		lcString = " select id from library where LTRIM(RTRIM(LEFT(kood,20))) = '" + LEFT(tcKood,20) +"' and rekvid = " + Str(grekv) +" and library = 'OSAKOND'"

*!*		_cliptext = lcstring
*!*		lnError = sqlexec(gnhandle,lcString)
*!*		If lnError > 0 And Used('sqlresult')
*!*			If Reccount('sqlresult') > 0
*!*	* OSAKOND andmebaasis
*!*				lnLibId = sqlresult.Id
*!*			Else
*!*				lnLibId = 0
*!*			Endif
*!*		Endif
*!*		If Used('sqlresult')
*!*			Use In sqlresult
*!*		Endif
*!*		Return lnLibId

*!*	Endfunc



*!*	Function uusIsik
*!*		Local 	lcString, lTulemus
*!*		lcString = "insert into asutus (rekvid, regkood, nimetus, aadress) values ("+ Str(grekv)+",'"+;
*!*			lcIsikuKood +"','"+lcNimi+"','"+lcAadress+"')"

*!*		_cliptext = lcstring
*!*		If sqlexec(gnhandle,lcString) > 0

*!*			Return .T.
*!*		Else
*!*			Return .F.
*!*		Endif

*!*	Endfunc



*!*	Function get_isik_id
*!*		Lparameters tcIsikukood
*!*		Local lnisikId, lcString, lnError
*!*		lnisikId = 0
*!*		lcString = " select id from asutus where regkood = '" + tcIsikukood +"'"

*!*		_cliptext = lcstring
*!*		lnError = sqlexec(gnhandle,lcString)
*!*		If lnError > 0 And Used('sqlresult')
*!*			If Reccount('sqlresult') > 0
*!*	* isik andmebaasis
*!*				lnisikId = sqlresult.Id
*!*			Else
*!*				lnisikId = 0
*!*			Endif
*!*		Endif
*!*		If Used('sqlresult')
*!*			Use In sqlresult
*!*		Endif
*!*		Return lnisikId


*!*	Endfunc


