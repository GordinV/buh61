CLEAR ALL

gnhandle = SQLCONNECT('datelviru','vladislav','490710')
IF gnhandle < 0
	MESSAGEBOX('Viga, uhendus')
	return
endif
=kontoplaan_import()

=sqldisconnect(gnHandle)

Function kontoplaan_import
	lcFile = 'c:\buh50\dbavpsoft\library.dbf'
	If !File(lcFile)
		Messagebox('Viga:'+lcFile)
		Return - 1
	Endif
	Use (lcFile) In 0 Alias qryKonto
	Select qryKonto
	Scan For library = 'KONTOD'
		Wait Window qryKonto.KOOD Nowait
		lckood = qryKonto.KOOD
		lcNimetus = Ltrim(Rtrim(qryKonto.nimetus))
		If !Empty(lckood) And !Empty(lcNimetus)
			lcString = " select id from library where kood = '"+lckood+"' and library = 'KONTOD'"
			lError = sqlexec(gnhandle, lcString,'QRYKONTOKONTROL')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
			If Reccount('QRYKONTOKONTROL')	< 1
				lcTun5 = '1'
				lcTun1 = '0'
				lcTun2 = '0'
				lcTun3 = '0'
				lcTun4 = '0'
				Do Case
					Case Left(lckood,1) = "1"
						lcTun5 = '1'
					Case Left(lckood,1) = "2"
						lcTun5 = '2'
					Case Left(lckood,1) = "3"
						lcTun5 = '4'
					Case Left(lckood,1) = "4"
						lcTun5 = '4'
					Case Left(lckood,1) = "5"
						lcTun5 = '3'
					Case Left(lckood,1) = "7"
						lcTun5 = '3'
					Case Left(lckood,1) = "8"
						lcTun5 = '3'
				Endcase
				lcString = " insert into library (rekvId, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5) values ("+;
					"2,'"+lckood+"','"+Ltrim(Rtrim(lcNimetus))+"','KONTOD',"+lcTun1+","+lcTun2+","+lcTun3+","+lcTun4+","+lcTun5+")"
				lError = sqlexec(gnhandle, lcString)
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					Exit
				Endif
				lcString = " select id from library order by id desc limit 1 "
				lError = sqlexec(gnhandle, lcString, 'qryLibId')
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					Exit
				Endif
				Select qryLibId
				lcString = "insert into kontoinf (parentid, aasta, algsaldo,rekvId) values ("+;
						STR(qryLibId.Id)+",2004,0,1)"
					lError = sqlexec(gnhandle, lcString, 'qryLibId')
					If lError < 1
						Messagebox("Viga "+lcString,'Kontrol')
						Set Step On
						Exit
					Endif
				If lError < 0
					Exit
				Endif
			Endif
		Endif
	Endscan
	Return lError
Endfunc