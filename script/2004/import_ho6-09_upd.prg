Local lError
Clear All

lcFile1 = 'c:\avpsoft\haridus\fakt\reklaam3ld.dbf'
*lcFile2 = 'c:\avpsoft\haridus\fakt\asutus.dbf'
*lcFile1 = 'c:\avpsoft\haridus\pank02.dbf'
*!*	lcFile3 = 'c:\avpsoft\haridus\pank03.dbf'
*lcFile2 = 'c:\avpsoft\files\buh60\temp\haridus\tp2004.dbf'
If !File(lcFile1)
	Messagebox('Viga, failid ei leidnud')
	lError = .T.
Endif
Use (lcFile1) In 0 Alias qryHO
*Use (lcFile2) In 0 Alias asutused Excl

*!*	Select Val(Alltrim(lausend.n11)) As asutusId, Val(Alltrim(asutused.n1)) As Id, asutused.n5 As nimetus, asutused.n6 As regkood, ;
*!*		lausend.* From lausend Left Outer Join asutused On Val(Alltrim(asutused.n1)) = lausend.asutusId;
*!*		INTO Cursor qryHO
*!*	SET STEP ON
*!*	scan
*!*		lcSumma = transdigit(ltrim(RTRIM(qryHo.n9)))
*!*	ENDSCAN
*!*	return

gnHandle = SQLConnect('narvalvpg','vlad','490710')
If gnHandle < 1
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif

lnSumma = 0
lnrec = 0

=SQLEXEC(gnHandle,'begin work')
Set Step On
Select qryHO
Scan
	Wait Window Str(Recno('qryHo'))+'-'+Str(Reccount('qryHo')) Nowait
	lcErr = ''

* otsime asutusId



* otsime operatsioon

*	lcregkood = Ltrim(Rtrim(qryHO.kood_in_go))
	lcAsutus = Ltrim(Rtrim(qryHO.asutus))



	If Upper(lcAsutus) = 'FIE VLADISLAV HANENKO' Or Upper(lcAsutus) = 'FIE HANENKO VLADISLAV'
		lcAsutus = 'Hanenko Vladislav'
	Endif
	If Upper(lcAsutus) = Upper('mtu Tiia Vohma Keeltekool')
		lcAsutus = 'Tiia Vohma Keeltekool'
	Endif
	If Upper(lcAsutus) = Upper('Noorsookeskus')
		lcAsutus = 'Eesti Noorsootookeskus'
	Endif
	If Upper(lcAsutus) = Upper('t??tajad')
		lcAsutus = 'TOOTAJAD'
	Endif
	If Upper(lcAsutus) = Upper('RIIKLIKU EKSAMI JA KVALIFIKATSIOONIK')
		lcAsutus = 'Riiklik Eksami-ja Kvalifikatsioonikeskus'
	Endif
	If Upper(lcAsutus) = Upper('FIE Heli Adamovits')
		lcAsutus = 'Heli Adamovits'
	Endif
	If Upper(lcAsutus) = Upper('FIE Inguna Joandi')
		lcAsutus = 'Inguna Joandi'
	Endif
	If Upper(lcAsutus) = Upper('Narva Haridusosakond /toend/')
		lcAsutus = 'Narva Haridusosakond'
	Endif
	If Upper(lcAsutus) = Upper('Nakro AS')
		lcAsutus = 'Nakro'
	Endif
	If Upper(lcAsutus) = Upper('FIE ALEKSANDR KOBZAR')
		lcAsutus = 'Nakro'
	Endif
	If Upper(lcAsutus) = Upper('FIE Martin Neltsas')
		lcAsutus = 'Martin Neltsas'
	Endif
	If Upper(lcAsutus) = Upper('Tokkot KU')
		lcAsutus = 'Tokkot'
	Endif
	If Upper(lcAsutus) = Upper('Ecomatik AS') Or Upper(lcAsutus) = Upper('Ecomatic LTD')
		lcAsutus = 'Ecomatic'
	Endif
	If Upper(lcAsutus) = Upper('Narva Teeniseklubi Fortuna')
		lcAsutus = 'Narva Tenniseklubi Fortuna'
	Endif
	If Upper(lcAsutus) = Upper('Pohjarannik AS')
		lcAsutus = 'PR POHJARANNIK '
	Endif
	If Upper(lcAsutus) = Upper('Flowers World TU')
		lcAsutus = 'Flowers World'
	Endif
	If Upper(lcAsutus) = Upper('Johvi Peapostkontor AS')
		lcAsutus = 'Eesti Post Johvi Peapostkontor '
	Endif
	If Upper(lcAsutus) = Upper('Prospekt Media UU')
		lcAsutus = 'Prospekt Media'
	Endif
	If Upper(lcAsutus) = Upper('Salva Kindlustus AS')
		lcAsutus = 'Salva Kindlustus'
	Endif
	If Upper(lcAsutus) = Upper('Kommertsleht OU')
		lcAsutus = 'Kommertsleht'
	Endif
	If Upper(lcAsutus) = Upper('FIE Belova Irina')
		lcAsutus = 'IRINA BELOVA'
	Endif
	If Upper(lcAsutus) = Upper('Union Kindluskons Ultats AS')
		lcAsutus = 'UNION KINDLUSTUSKONSULTATSIOONID'
	Endif
	If Upper(lcAsutus) = Upper('Kardis OU')
		lcAsutus = 'Kardis'
	Endif
	If Upper(lcAsutus) = Upper('Ergo Kindlustuse AS')
		lcAsutus = 'Ergo Kindlustuse'
	Endif
	If Upper(lcAsutus) = Upper('MTU Hea Algus')
		lcAsutus = 'Hea Algus'
	Endif
	If Upper(lcAsutus) = Upper('Eesti Securitas AS')
		lcAsutus = 'SECURITAS EESTI'
	Endif
	If Upper(lcAsutus) = Upper('Express Post AS')
		lcAsutus = 'Express Post'
	Endif
	If Upper(lcAsutus) = Upper('Tours SV') OR Upper(lcAsutus) = Upper('Tours SV OU') 
		lcAsutus = 'SV TOURS'
	ENDIF
	If Upper(lcAsutus) = Upper('Svjatogor')
		lcAsutus = 'Narva Linna Slaavi Kultuuriselts Svjatogor'
	ENDIF
	If Upper(lcAsutus) = Upper('SALVA KINDLUSTUS')
		lcAsutus = 'SALVA KINDLUSTUSE'
	ENDIF
	If Upper(lcAsutus) = Upper('MTU LOODUSAJAKIVI')
		lcAsutus = 'Loodusajakiri'
	ENDIF
	If Upper(lcAsutus) = Upper('Aripaeva Kirjastuse AS')
		lcAsutus = '�RIP�EVA KIRJASTUSE'
	ENDIF
	If Upper(lcAsutus) = Upper('Travibest Reisiburoo') OR Upper(lcAsutus) = Upper('Travibest Reisiburoo OU') OR Upper(lcAsutus) = Upper('Reisib�roo Travibest')
		lcAsutus = 'Travibest'
	ENDIF
	lcString = "select id from asutus where UPPER(LTRIM(RTRIM(nimetus))) = '"+Upper(Ltrim(Rtrim(lcAsutus)))+"' limit 1"
	lnresult = SQLEXEC(gnHandle,lcString, 'qryId')

	If Reccount('qryid') <  1

		If At(lcAsutus,'FIE') > 0
			lcAsutus = Stuff(lcAsutus,At('FIE',lcAsutus),3,'')
		Endif
		If At(' OU',lcAsutus ) > 0
			lcAsutus = Stuff(lcAsutus,At(' OU',lcAsutus),4,'')
		Endif
		If At(lcAsutus,' AS' ) > 0
			lcAsutus = Stuff(lcAsutus,At(' AS',lcAsutus),4,'')
		Endif
		If At(lcAsutus,'MTU' ) > 0
			lcAsutus = Stuff(lcAsutus,At('MTU',lcAsutus),3,'')
		Endif
		If At(lcAsutus,' TU' ) > 0
			lcAsutus = Stuff(lcAsutus,At(' TU',lcAsutus),3,'')
		Endif

	Endif


	lcString = "select id from asutus where UPPER(LTRIM(RTRIM(nimetus))) like '%"+Upper(Ltrim(Rtrim(lcAsutus)))+"%' limit 1"
	lnresult = SQLEXEC(gnHandle,lcString, 'qryId')

	If Reccount('qryid') <  1
		lnresult = -1
		Set Step On
		Exit
	Endif


	If lnresult > 0
		If Reccount('qryid') <  1
			lnresult = -1
		Endif

	Endif
	If !Used('qryId') Or lnresult < 1
		Exit
	Endif

	lcAsutusId = Str(qryId.Id)

	lcdate = 'date(2004,'+Str(Month(qryHO.kuup_ev),2)+','+Str(Day(qryHO.kuup_ev),2)+')'

	lcuserId = '199'

*	lcSelg = Ltrim(Rtrim((qryHO.mo)))
*	lcDok = Ltrim(Rtrim((qryHO.mo)))
	lcDok = ''
	lcMuud = 'reklaam3ld.xls'
	lcUksus = ''

	lcDeebet = Left(Ltrim(Rtrim(qryHO.d_t_konto)),6)
	lcKreedit = Left(Ltrim(Rtrim(Str(qryHO.k_t_konto))),6)


	lcTpd = Ltrim(Rtrim((qryHO.tp_d_t_kon)))
	lcTpk = Ltrim(Rtrim((qryHO.tp_k_t__ko)))
	lcSumma = Alltrim(Str(qryHO.Summa,14,2))
*	transdigit(Ltrim(Rtrim(qryHO.n9)))
	lcKood1 = Alltrim(qryHO.tt)
	lcKood2 = ''
	lcKood3 = Alltrim(qryHO.raha__voo)
	lcKood4 = ''
	lcKood5 = ''
	lcTunnus = Alltrim((qryHO.kood2))
	lcUksus = Iif(Len(lcTunnus) < 3,'0'+lcTunnus,lcTunnus)

*	If lcDeebet <> lcKreedit
	If lnresult > 0
		lcString = "select id, ASUTUSID from journal where rekvid = 11 and kpv = "+lcdate+" and id in ("+;
			" select parentid from journal1 where LTRIM(RTRIM(deebet)) = '"+;
			lcDeebet +"' and LTRIM(RTRIM(kreedit)) = '"+lcKreedit+"' and LTRIM(RTRIM(lisa_d)) = '"+lcTpd+"' and LTRIM(RTRIM(lisa_k)) = '"+lcTpk+"' and summa = "+lcSumma +;
			" and LTRIM(RTRIM(tunnus)) = '"+lcUksus+"')"

		lnresult = SQLEXEC(gnHandle,lcString,'qryJrnl')

	Endif

	If lnresult > 0
		If Reccount('qryJrnl') > 1
			Brow
		Endif
		If Reccount('qryJrnl') < 1
*!*				lcString = "insert into journal (kpv, asutusId, rekvId, userId, selg, dok, muud) values ("+;
*!*					lcdate+","+lcAsutusId+",11,199,'"+lcSelg+"','"+lcDok+"','"+lcMuud+"')"

*!*				lnresult = SQLEXEC(gnHandle,lcString)


*!*				If lnresult > 0

*!*					lcString = 'select id from journal where rekvid = 11 order by id desc limit 1'
*!*					lnresult = SQLEXEC(gnHandle,lcString,'qrylastId')
*!*				Endif

*!*				If lnresult > 0

*!*					lcString = "insert into journal1 (parentId, deebet, lisa_d, kreedit, lisa_k, summa, tunnus, kood1, kood2, kood3, kood4, kood5) values ("+;
*!*						STR(qryLastid.Id)+",'"+lcDeebet+"','"+lcTpd+"','"+lcKreedit+"','"+lcTpk+"',"+lcSumma+",'"+;
*!*						lcUksus+"','"+lcKood1+"','"+lcKood2+"','"+lcKood3+"','"+lcKood4+"','"+lcKood5+"')"

*!*					lnresult = SQLEXEC(gnHandle,lcString)

*!*				Endif

		Else

			If lnresult > 0 And qryJrnl.asutusID = 0

				lcString = "update journal set asutusId = "+lcAsutusId+" where ID = "+Str(qryJrnl.Id)

				lnresult = SQLEXEC(gnHandle,lcString)
				If lnresult > 0
					lcString = "update journal1 set kood1 = '"+lcKood1+"', kood3 = '"+lcKood3+"' where parentID = "+Str(qryJrnl.Id)
					lnresult = SQLEXEC(gnHandle,lcString)
				Endif


			Endif
		Endif
	Endif
	If lnresult < 0
		Set Step On
		Exit
	Endif
Endscan
If lnresult > 0
	=SQLEXEC(gnHandle,'commit work')
	Messagebox('Ok')
Else
	Set Step On
	=SQLEXEC(gnHandle,'rollback work')
Endif




=SQLDISCONNECT(gnHandle)

Function transdigit
	Lparameters tcString
	lnQuota = At(',',tcString)
	lcKroon = Left(tcString,lnQuota-1)
	lcCent = Right(tcString,2)
	If At(Space(1),lcKroon) > 0
* on probel
		lcKroon = Stuff(lcKroon,At(Space(1),lcKroon),1,'')
	Endif
	Return lcKroon+'.'+lcCent
Endfunc
