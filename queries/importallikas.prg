Parameter tcFile
Wait window [Importeerin allikas .. ] nowait
oDb.use ('v_library','v_library',.t.)
cLibrary = 'ALLIKAD'
Do case
	Case justext (tcFile) = 'DBF'  &&
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
				Select comAllikadremote
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
Endcase
If reccount ('v_library') > 0
	lnAnswer = messagebox (iif (config.keel=1,'Сохранить '+str(reccount ('v_library'))+'записей ?',;
		'Kas salvesta '+str(reccount ('v_library'))+'kirje ?'),4+32+0,'Import')
	If lnAnswer = 6
		With oDb
			.opentransaction ()
			lError = .cursorupdate ('v_library')
			If lError = .f.
				.rollback()
				messagebox ('Viga','Kontrol')
			Else
				messagebox ('Ok','Kontrol')
				.commit()
				.dbreq('comallikadremote', gnHandle, 'comallikadremote',.t.)
			Endif
		Endwith
	Endif
Endif
if used ('V_LIBRARY')
	USE IN V_LIBRARY
ENDIF