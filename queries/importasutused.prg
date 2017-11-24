Parameter tcFile
wait window [Importeerin asutused .. ] nowait
oDb.use ('v_asutus','v_asutus',.t.)
Do case
	Case justext (tcFile) = 'DBF' and upper(justfname (tcFile)) = 'CL' 
		Select * from (tcFile) qryCursor into cursor tmpAsutus
		select tmpAsutus
		scan
			Select comAsutusRemote
			Locate for alltrim(regkood) = alltrim(tmpAsutus.regnumber)
			If !found ()
				Wait window [Asutus :]+tmpAsutus.client nowait
				Select v_asutus
				Insert into v_asutus (rekvId, regkood, nimetus, aadress, kontakt,omvorm, email, tel, faks) values ;
					(grekv, tmpAsutus.regnumber, tmpAsutus.client, tmpAsutus.address, tmpAsutus.fam, space(3),;
					tmpAsutus.email, tmpAsutus.phone, tmpAsutus.fax)
			Endif
		Endscan
		use in tmpAsutus
Endcase
If reccount ('v_asutus') > 0
	lnAnswer = messagebox (iif (config.keel=1,'Сохранить '+str(reccount ('v_asutus'))+' записей ?',;
		'Kas salvesta '+str(reccount ('v_asutus'))+' kirje ?'),4+32+0,'Import')
	If lnAnswer = 6
		With oDb
			.opentransaction ()
			lError = .cursorupdate ('v_asutus')
			If lError = .f.
				.rollback()
				messagebox ('Viga','Kontrol')
			Else
				messagebox ('Ok','Kontrol')
				.commit()
				.dbreq('comAsutusremote', gnHandle, 'comAsutusremote',.t.)
			Endif
		Endwith
	Endif
Endif
if used ('V_LIBRARY')
	USE IN V_LIBRARY
ENDIF