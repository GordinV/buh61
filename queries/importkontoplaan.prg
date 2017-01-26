Parameter tcFile
Local lError
lError = .t.
Wait window [Importeerin kontoplaan .. ] nowait
With odb
	.use ('v_library','v_library',.t.)
	.use ('v_kontoinf','v_kontoinf',.t.)
	.use ('v_subkonto','v_subkonto',.t.)
Endwith
set step on
cLibrary = 'KONTOD'
Select comKontodRemote
index on alltrim(kood) tag kood
set order to kood
Do case
	Case justext (tcFile) = 'DBF'  and upper(justfname (tcFile)) = 'PLAN'
		lcPath = justpath (tcFile)
		lcFile = lcPath+'\buh_isikdata.dbf'

		Select * from (tcFile) qryCursor into cursor tmpKontod
		Select * from (lcFile) qryCursor1 into cursor tmpSubkonto
		odb.opentransaction()
		Select tmpKontod
		Scan
			Select comKontodRemote
			Locate for alltrim(kood) = alltrim(tmpKontod.konto)
			If !found ()
				Wait window [Konto :]+tmpKontod.konto nowait
				Select v_library
				Insert into v_library (rekvId, kood, nimetus, library) values ;
					(grekv, tmpKontod.konto, tmpKontod.Nimi, cLibrary)
				lError = odb.cursorupdate ('v_library')
				If lError = .t.
					Select v_kontoinf
					Insert into v_kontoinf (parentid,aasta, algsaldo, formula, liik, type) values;
						(v_library.id,year (date()),0, tmpKontod.formula, 1, tmpKontod.tyyp)
					Select tmpSubkonto
					Scan for konto = v_library.kood and beg_saldo <> 0
						Select comAsutusRemote
						Locate for comAsutusRemote.nimetus = tmpSubkonto.client
						If found ()
							Insert into v_subkonto (kontoid, asutusId, algsaldo, aasta) values ;
								(v_library.id, comAsutusRemote.id, tmpSubkonto.beg_saldo, v_kontoinf.aasta)
						Endif
					Endscan
					lError = odb.cursorupdate ('v_kontoinf')
					If lError = .t.
						lError = odb.cursorupdate ('v_subkonto')
					Endif
				Endif
				If lError = .f.
					Exit
				Endif
			Endif
		Endscan
		If lError = .f.
			odb.rollback()
			Messagebox ('Viga','Kontrol')
		Else
			odb.commit()
		Endif
	Case justext (tcFile) = 'DBF'  and upper(justfname (tcFile)) <> 'PLAN'
		Select * from (tcFile) qryCursor into cursor tmpKontod
		odb.opentransaction()
		Select tmpKontod
		Scan 	for !empty (kood) and len (alltrim(kood)) > 3
			Select comKontodRemote
			seek alltrim(tmpKontod.kood)
			If !found ()
				Wait window [Konto :]+tmpKontod.kood nowait
				Select v_library
				Insert into v_library (rekvId, kood, nimetus, library) values ;
					(grekv, tmpKontod.kood, tmpKontod.nimetus, cLibrary)
				lError = odb.cursorupdate ('v_library')
				If lError = .t.
					Do case
						Case left (alltrim(v_library.kood),1) = '1'
							lnType = 1
						Case left (alltrim(v_library.kood),1) = '2'
							lnType = 2
						Case left (alltrim(v_library.kood),1) = '3'
							lnType = 4
						Case left (alltrim(v_library.kood),1) = '4' or ;
								left (alltrim(v_library.kood),1) = '5' or ;
								left (alltrim(v_library.kood),1) = '6'
							lnType = 3
						Case left (alltrim(v_library.kood),1) = '7'
							lnType = 4
						Case left (alltrim(v_library.kood),1) = '8'
							lnType = 4
					Endcase
					Select v_kontoinf
					Insert into v_kontoinf (parentid,aasta, algsaldo, formula, liik, type) values;
						(v_library.id,year (date()),0, 1, 1, lnType)
					lError = odb.cursorupdate ('v_kontoinf')
				Endif
				If lError = .f.
					Exit
				Endif
			Endif
		Endscan
		If lError = .f.
			odb.rollback()
			Messagebox ('Viga','Kontrol')
		Else
			odb.commit()
		Endif

Endcase
If reccount ('v_library') > 0
	lnAnswer = messagebox (iif (config.keel=1,'Сохранить '+str(reccount ('v_library'))+'записей ?',;
		'Kas salvesta '+str(reccount ('v_library'))+'kirje ?'),4+32+0,'Import')
	If lnAnswer = 6
		With odb
			.opentransaction ()
			lError = .cursorupdate ('v_library')
			If lError = .f.
				.rollback()
				Messagebox ('Viga','Kontrol')
			Else
				Messagebox ('Ok','Kontrol')
				.commit()
				.dbreq('comallikadremote', gnHandle, 'comallikadremote',.t.)
			Endif
		Endwith
	Endif
Endif
If used ('V_LIBRARY')
	Use IN v_library
Endif
