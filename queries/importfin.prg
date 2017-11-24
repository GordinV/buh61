Parameter tcFile
oDb.use ('v_library','v_library',.t.)
cLibrary = 'OBJEKT'
Do case
	Case justext (tcFile) = 'TXT'
		Create cursor qryCursor (kood c(20), nimetus c(254))
		Create cursor qrymemo (text m)
		Append blank
		cString = "Append memo from "+tcFile
		&cString
		lnLines = memlines (qrymemo.text)
		For i = 1 to lnLines
			cLine = ltrim(rtrim(mline (qrymemo.text,i)))
			If len (cLine) > 0
				lnBlank = at (' ',cLine)
				If lnBlank > 0
					cKood = left (cLine,lnBlank)
					cNimetus = right (cLine,len(cLine)-lnBlank)
					Insert into qryCursor (kood, nimetus ) values ;
						(cKood, cNimetus)
				Endif
			Endif
		Endfor
		If reccount (qryCursor) > 0
			tcFile = 'qryCursor'
			=append from_dbf()
		Endif
		If used ('qryCursor')
			Use in qryCursor
		Endif
		If used ('qrymemo')
			Use in qrymemo
		Endif
	Case justext (tcFile) = 'DBF'
		=append_from_dbf()
Endcase
If reccount ('v_library') > 0
	lnAnswer = messagebox (iif (config.keel=1,'Сохранить '+str(reccount ('v_library'))+' записей ?',;
		'Kas salvesta '+str(reccount ('v_library'))+' kirje ?'),4+32+0,'Import')
	If lnAnswer = 6
		With oDb
			.opentransaction ()
			lError = .cursorupdate ('v_library')
			If lError = .f.
				.rollback()
				Messagebox ('Viga','Kontrol')
			Else
				Messagebox ('Ok','Kontrol')
				.commit()
				.dbreq('comObjektremote', gnHandle, 'comObjektremote',.t.)
			Endif
		Endwith
	Endif
Endif
If used ('V_LIBRARY')
	Use IN v_library
Endif


Function append_from_dbf
	Select * from (tcFile) qryCursor into array aCursor
	lnItems = alen (aCursor,1)
	If lnItems > 0
		For i = 1 to lnItems
			cKood = ltrim(rtrim(aCursor (i,1)))
			lnPunkt = at (',',cKood)
			If lnPunkt > 0
				cKood = stuff (cKood,lnPunkt,1,'.')
			Endif
			cNimetus = ''
			For lnColumn = 2 to aLen (aCursor,2)
				cNimetus = cNimetus + ltrim(rtrim(aCursor(i,lnColumn)))
			Endfor
			If len (cNimetus) > 254
				cNimetus = left (ltrim(rtrim(cNimetus)),254)
			Endif
			Select comObjektremote
			Locate for alltrim(kood) = alltrim(cKood)
			If !found ()
				Wait window [Kood :]+cKood + [Nimetus ]+cNimetus nowait
				Select v_library
				Insert into v_library (rekvId, kood, nimetus, library) values ;
					(grekv, cKood, cNimetus, cLibrary)
				cNimetus = ''
			Endif
		Endfor
	Endif

	Return
