
gnHandle = SQLConnect('mekearv')
If gnHandle < 0
	Messagebox('Uhnduse viga',0,'Viga',10)
	Return
Endif
If !Used('qryObj')
	lcString = "SELECT library.*,objekt.parentid,objekt.asutusId,objekt.nait14, objekt.nait15 from library inner join objekt on library.id = objekt.libid WHERE library = 'OBJEKT'"
	lnResult = SQLEXEC(gnHandle,lcString,'qryObj')
	If lnResult < 0 Or Reccount('qryObj') < 0
		Messagebox 'Viga')
		Set Step On
		Return
	Endif
Endif
lnCount = 0
Select qryObj
Scan
	Wait Window qryObj.kood+Str(Recno('qryObj'))+'/'+Str(Reccount('qryObj')) Nowait
	lcObjekt = Alltrim(qryObj.kood)
	If Atc('  ',lcObjekt) > 0
		Wait Window 'Uuendan:'+qryObj.kood+Str(Recno('qryObj'))+'/'+Str(Reccount('qryObj')) Nowait
		lcObjekt = Stuff(lcObjekt,Atc('  ',lcObjekt),1,'')
* uuenda obj info
		lcString = "update library set kood = '"+lcObjekt+"' where id = "+Str(qryObj.Id)
		lnResult = SQLEXEC(gnHandle,lcString)
		If lnResult < 0
			Messagebox 'Viga')
			_Cliptext = lcString
			Set Step On
			Exit
		Else
			Wait Window 'Salvastatud uus kood:'+qryObj.kood+Str(Recno('qryObj'))+'/'+Str(Reccount('qryObj')) Nowait
		Endif
	ENDIF
* otsime parentobjekt

	If qryObj.parentid = 0 And qryObj.asutusId > 0
*		SET STEP ON 
* see on korter ja ei ole seotud majaga
		Wait Window 'Otsime maja andmed:'+qryObj.kood+Str(Recno('qryObj'))+'/'+Str(Reccount('qryObj')) Nowait

		If !Used('qryMaja')
			Select Id, kood From qryObj Where asutusId = 0 Into Cursor qryMaja
		Endif

		lcMaja = Left(lcObjekt,Atc('-',lcObjekt)-1)
		Select qryMaja
		Locate For kood = lcMaja
		If Found()
* leitud
			lcString = " update objekt set parentid = "+Str(qryMaja.Id)+" where libid = "+Str(qryObj.Id)
			lnResult = SQLEXEC(gnHandle,lcString)
			If lnResult < 0
				Messagebox 'Viga')
				_Cliptext = lcString
				Set Step On
				Exit
			Else
				Wait Window 'Salvastatud maja andmed:'+qryObj.kood+Str(Recno('qryObj'))+'/'+Str(Reccount('qryObj')) Nowait
			Endif
		Endif
	Endif

	lnCount = lnCount + 1
*!*		IF lnCount > 100
*!*			exit
*!*		endif

Endscan


=SQLDISCONNECT(gnHandle)

