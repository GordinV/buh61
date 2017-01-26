* import palk kood sprodikeskus -> energia, paemurru

Wait Window 'Connect...' Nowait
gnHandle = SQLConnect('narvalvpg')
If gnHandle < 1
	Messagebox('Viga, uhendus')
	Return
Else
	Wait Window 'Connect...onnestus' Nowait
Endif
Set Step On
If gnHandle > 0
* library osakond

	Create Cursor tmpLibId (OsankVanaId Int, osakUusId Int, AmetVanaId Int, AmetUusId Int)

	lcString = "select * from library where rekvid = 15 and library in ('OSAKOND','AMET')"
	lnError = SQLEXEC(gnHandle,lcString,'tmpLibrary')

	If lnError < 0
		Set Step On
		Return
	Endif

	lcString = "select * from palk_asutus where rekvid = 15 "
	lnError = SQLEXEC(gnHandle,lcString,'tmpPalkAsutus')

	If lnError < 0
		Set Step On
		Return
	Endif

	Select tmpLibrary
	Scan
		Wait Window 'Import library '+tmpLibrary.kood + Str(Recno('tmpLibrary'))+'/'+Str(Reccount('tmpLibrary')) Nowait
* kontrollin kood

		lcString = "select id from library where rekvid = 126 and library = '"+tmpLibrary.Library+"' and kood = '"+tmpLibrary.kood +"'
		lnError = SQLEXEC(gnHandle,lcString,'tmpId')
		If lnError < 0
			Set Step On
			Exit
		Endif
		If Reccount('tmpId') = 0
* puudub, lisame
			lcString = "insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4) values (126,'"+;
				ALLTRIM(tmpLibrary.kood)+"','"+Alltrim(tmpLibrary.nimetus)+"','"+tmpLibrary.Library+"',"+;
				STR(tmpLibrary.tun1)+","+Str(tmpLibrary.tun2)+","+Str(tmpLibrary.tun3)+","+Str(tmpLibrary.tun4)+")"

			lnError = SQLEXEC(gnHandle,lcString)
			If lnError < 0
				Set Step On
				Exit
			Endif
			lcString = "select id from library where rekvid = 126 order by id desc limit 1"
			lnError = SQLEXEC(gnHandle,lcString, 'tmpId')
			If lnError < 0
				Set Step On
				Exit
			Endif
*			tmpLibId (OsankVanaId int, osakUusId int, AmetVanaId int, AmetUusId int)
			Select tmpPalkAsutus
			If tmpLibrary.Library = 'AMET'
				Locate For AmetVanaId = tmpLibrary.Id
				If !Found()
* puudub, lisame
					Insert Into tmpLibId (AmetVanaId, AmetUusId) Values(tmpLibrary.Id, tmpId.Id)
				Endif
			Else
				Locate For OsankVanaId = tmpLibrary.Id
				If !Found()
* puudub, lisame
					Insert Into tmpLibId (OsankVanaId, osakUusId) Values(tmpLibrary.Id, tmpId.Id)
				Endif
			Endif
		Endif
	ENDSCAN
	* import palk_asutus
	SELECT tmpPalkAsutus
	SCAN
		WAIT WINDOW 'Import palk_asutus '+STR(recno('mpPalkAsutus'))+'/'+STR(RECCOUNT('mpPalkAsutus')) nowait
		lnOsakId = 0
		lnAmetId = 0
		SELECT tmpLibId
		LOCATE FOR OsankVanaId = tmpPalkAsutus.osakondId
		IF !FOUND()
			SET STEP ON 
			exit
		ENDIF
		lnOsakId = tmpLibId.osakUusId

		LOCATE FOR AmetVanaId = tmpPalkAsutus.ametId
		IF !FOUND()
			SET STEP ON 
			exit
		ENDIF
		lnAmetId = tmpLibId.osakUusId
	
		* kontrollime
		lcString = "select id from palk_asutus where rekvid = 15 and osakondId = "+STR(lnOsakId,9)+" and ametId = "+STR(lnAmetId,9)
		lnError = SQLEXEC(gnHandle,lcString,'tmpId')
		IF lnError < 0
			SET STEP ON 
			EXIT			
		ENDIF
		IF RECCOUNT('tmpId') = 0
			* Puudub, lisame
			lcString = "insert into palk_asutus (rekvid, osakondId, ametId, kogus) values (126, "+STR(lnOsakId,9)+","+STR(lnAmetId,9)+","+STR(tmpPalkAsutus.kogus,9)+")"
			lnError = SQLEXEC(gnHandle,lcString)
			IF lnError < 0
				SET STEP ON 
				exit
			ENDIF			
		ENDIF
	ENDSCAN
	
	
	lImport = .F.
	If lImport = .T.

* library palk
		Wait Window 'Lib laadimine...' Nowait

		lcString = "select * from library where rekvid = 15 and library = 'PALK'"
		lError = SQLEXEC(gnHandle,lcString,'tmpLib')
		Wait Window 'Lib laadimine...tehtud' Nowait

		If lError < 0 Or !Used('tmpLib')
			Messagebox('Viga')
			Set Step On
			Return
		Endif
		Select tmpLib
		Scan
* import
			Wait Window 'Importeerimine, kood = '+Alltrim(tmpLib.kood)+Alltrim(Str(Recno('tmpLib')))+'/'+Alltrim(Str(Reccount('tmpLib'))) Nowait
* kontrollime kas kood juba salvestatud
			lcString = "select id from library where LTRIM(RTRIM(kood)) = '"+Alltrim(tmpLib.kood)+"' and rekvid = 126 and library = 'PALK'"
			lError = SQLEXEC(gnHandle,lcString,'tmpId')
			If lError < 0 Or !Used('tmpId')
				Messagebox('Viga')
				Set Step On
				Exit
			Endif
			If Reccount('tmpId') = 0
* puudub, lisame
				Wait Window 'Importeerimine, kood = '+Alltrim(tmpLib.kood)+Alltrim(Str(Recno('tmpLib')))+' puudub, lisame/'+Alltrim(Str(Reccount('tmpLib'))) Nowait
				lcString = "insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4) values (126,'"+;
					ALLTRIM(tmpLib.kood)+"','"+Alltrim(tmpLib.nimetus)+"','PALK',"+Str(tmpLib.tun1)+","+Str(tmpLib.tun2)+","+Str(tmpLib.tun3)+;
					","+Str(tmpLib.tun4)+")"

				lError = SQLEXEC(gnHandle,lcString)
				If lError < 0
					Messagebox('Viga')
					Set Step On
					Exit
				Endif
				lcString = "select id, library, rekvid from library order by id desc limit 1"
				lError = SQLEXEC(gnHandle,lcString,'tmpId')
				If lError < 0 Or !Used('tmpId')
					Messagebox('Viga')
					Set Step On
					Exit
				Endif
				Wait Window 'Importeerimine, kood = '+Alltrim(tmpLib.kood)+Alltrim(Str(Recno('tmpLib')))+' lisatud, importeerime palk_lib ../'+Alltrim(Str(Reccount('tmpLib'))) Nowait
				lcString = "select * from palk_lib where parentid = "+Str(tmpLib.Id)
				lError = SQLEXEC(gnHandle,lcString,'tmpPalkLib')
				If lError < 0 Or !Used('tmpPalkLib')
					Messagebox('Viga')
					Set Step On
					Exit
				Endif
				lcString = "insert into palk_lib (parentid, liik, tund, maks, palgafond, asutusest, lausendid, algoritm, round, sots, konto, elatis, tululiik) values("+;
					STR(tmpId.Id)+","+Str(tmpPalkLib.liik)+","+Str(tmpPalkLib.TUND)+","+Str(tmpPalkLib.maks)+","+Str(tmpPalkLib.palgafond)+","+;
					STR(tmpPalkLib.asutusest)+","+Str(tmpPalkLib.lausendid)+",'"+tmpPalkLib.algoritm+"',"+Str(tmpPalkLib.Round,12,4)+","+;
					STR(tmpPalkLib.sots)+",'"+tmpPalkLib.konto+"',"+Str(tmpPalkLib.elatis)+",'"+tmpPalkLib.tululiik+"')"

				lError = SQLEXEC(gnHandle,lcString)
				If lError < 0
					Messagebox('Viga')
					Set Step On
					Exit
				Endif
				Wait Window 'Importeerimine, kood = '+Alltrim(tmpLib.kood)+Alltrim(Str(Recno('tmpLib')))+' lisatud, importeerime palk_lib ..tehtud/'+Alltrim(Str(Reccount('tmpLib'))) Nowait
			Endif
* KONTROLLIme klassiflib
			Wait Window 'Importeerimine, kood = '+Alltrim(tmpLib.kood)+Alltrim(Str(Recno('tmpLib')))+' klassiflib ..'+Alltrim(Str(Recno('tmpLib'))) Nowait

			lcString = "select id from klassiflib where libid = "+Str(tmpId.Id)
			lError = SQLEXEC(gnHandle,lcString, 'tmpKlassifLib')
			If lError < 0 Or !Used('tmpKlassifLib')
				Messagebox('Viga')
				Set Step On
				Exit
			Endif
			If Reccount('tmpKlassifLib') = 0
				Wait Window 'Importeerimine, kood = '+Alltrim(tmpLib.kood)+Alltrim(Str(Recno('tmpLib')))+' klassiflib ..lisame '+Alltrim(Str(Recno('tmpLib'))) Nowait
				lcString = "insert into klassiflib (libid,tyyp,tunnusid,kood1,kood2,kood3,kood4,kood5,konto, proj ) "+;
					" select "+Str(tmpId.Id)+",tyyp,tunnusid,kood1,kood2,kood3,kood4,kood5,konto, proj from klassiflib where libid = " + Str(tmpLib.Id)

				lError = SQLEXEC(gnHandle,lcString)
				If lError < 0
					Messagebox('Viga')
					Set Step On
					Exit
				Endif


			Endif


		Endscan
	Endif
Endif


=SQLDISCONNECT(gnHandle)
