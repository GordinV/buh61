Parameter cWhere
Local lnDeebet, lnKreedit, lcString
lcString = ''
tcAllikas = '%'
tcArtikkel = '%'
tcTegev = '%'
tcObjekt = '%'
tcTunnus = '%'
tcEelAllikas = '%'
lnDeebet = 0
lnKreedit = 0
tcKasutaja = '%' 
tcMuud = '%'
 
dKpv1 = Iif(!Empty(fltrAruanne.kpv1), fltrAruanne.kpv1,Date(Year(Date()),1,1))
dKpv2 = Iif(!Empty(fltrAruanne.kpv2), fltrAruanne.kpv2,Date())
Replace fltrAruanne.kpv1 With dKpv1,;
	fltrAruanne.kpv2 With dKpv2 In fltrAruanne
Create Cursor kaibeandmik_report1 (algdb N(18,6),algkr N(18,6),deebet N(18,6),;
	kreedit N(18,6),loppdb N(18,6), loppkr N(18,6), konto c(20), pohikonto c(20), nimetus c(120), Type Int, liik Int)
Index On pohikonto+'-'+konto Tag konto
Set Order To konto


If !Used('v_filter')
	Create Cursor v_filter (filtr m)
	Append Blank
Endif
If !Empty(fltrAruanne.tunnus)
	Select comTunnusremote
	If Tag() <> 'ID'
		Set Order To Id
	Endif
	Seek fltrAruanne.tunnus
Endif

If fltrAruanne.tunnus > 0

	Select comTunnusremote
	Locate For Id = fltrAruanne.tunnus
	lcTunnus = Ltrim(Rtrim(comTunnusremote.kood))
Else
	lcTunnus = ''
Endif

If gVersia = 'PG'

	lcString = "select count(*) as count from pg_proc where proname = 'sp_kaibeandmik_report'"
	lError = oDb.execsql(lcString, 'tmpProc')
	If !Empty (lError) And Used('tmpProc') And !Empty(VAL(ALLTRIM(tmpProc.Count)))
		Wait Window 'Serveri poolt funktsioon ....' Nowait

		lError = oDb.Exec("sp_kaibeandmik_report "," '"+Ltrim(Rtrim(fltrAruanne.konto))+"%',"+;
			Str(grekv)+","+;
			" DATE("+Str(Year(fltrAruanne.kpv1),4)+","+ Str(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+"),"+;
			" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+	Str(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),'"+;
			LTRIM(Rtrim(lcTunnus))+"%',1,"+Str(fltrAruanne.kond,9),"qryKbAsu")

		If !EMPTY(lError) and Used('qryKbAsu') 

			lcString = "select konto, algdb, algkr, db, kr from tmp_kaibeandmik_report where timestamp = '"+ Alltrim(qryKbAsu.sp_kaibeandmik_report)+"'"

			lError = sqlexec(gnHandle,lcString,'qryKaibeandmik')
*brow
			Select qryKaibeandmik
			Scan

				lnAlgdb = 0
				lnAlgKr = 0
				lnLoppdb = 0
				lnLoppKr = 0
				Select comKontodRemote
				Locate For kood = qryKaibeandmik.konto
				If comKontodRemote.tun5 = 1 Or comKontodRemote.tun5 = 3
					lnAlgdb = ROUND((qryKaibeandmik.algdb - qryKaibeandmik.algkr) / fltrPrinter.kuurs,2)
					lnAlgKr = 0
					lnLoppdb = lnAlgdb + ROUND((qryKaibeandmik.Db - qryKaibeandmik.Kr)/fltrPrinter.kuurs,2)
					lnLoppKr = 0

				Else
					lnAlgKr = ROUND(-1 * (qryKaibeandmik.algdb - qryKaibeandmik.algkr) / fltrPrinter.kuurs,2)
					lnAlgdb = 0
					lnLoppKr = lnAlgKr - ROUND(qryKaibeandmik.Db/fltrPrinter.kuurs,2) +  ROUND(qryKaibeandmik.Kr/fltrPrinter.kuurs,2)

*					lnLoppKr = lnAlgKr - qryKaibeandmik.Db + qryKaibeandmik.Kr


					lnLoppdb = 0
				Endif
				lnPk = Len(Alltrim(qryKaibeandmik.konto)) - Round(Len(Alltrim(qryKaibeandmik.konto))/2,0)
				lnPk = 3
				IF LEFT(ALLTRIM(qryKaibeandmik.konto),6) = '100100'
					lnPk = 6
				ENDIF
				
				Insert Into kaibeandmik_report1 (algdb,algkr, deebet, kreedit,loppdb, loppkr, konto, pohikonto, nimetus, liik);
					values (lnAlgdb,lnAlgKr, ROUND(qryKaibeandmik.Db/fltrPrinter.kuurs,2), ROUND(qryKaibeandmik.Kr/fltrPrinter.kuurs,2),lnLoppdb, lnLoppKr, qryKaibeandmik.konto, ;
					left(Rtrim(Ltrim(qryKaibeandmik.konto)),lnPk), comKontodRemote.nimetus,comKontodRemote.tun5 )
			Endscan
			Select kaibeandmik_report1
			DELETE FROM kaibeandmik_report1 WHERE algdb = 0 AND algkr = 0 AND deebet = 0 AND kreedit = 0
			Return .T.
		Else
			Select 0
			Return .F.
		Endif

	Endif
	lcString = ''
endif
text
	lcString = lcString + Iif(!Empty(fltrAruanne.konto), ' konto = '+Upper(Ltrim(Rtrim(fltrAruanne.konto))),'')
	lcString = lcString + Iif(!Empty(fltrAruanne.tunnus), ' ьksus = '+Upper(Ltrim(Rtrim(comTunnusremote.kood))),'')

	Replace v_filter.filtr With lcString In v_filter



&& algsaldo arvestused
	lnMonth = Month(dKpv1)
	lnYear = Year(dKpv1)
	dKpv1 = Date(lnYear,lnMonth ,1)
	dKpv2 = dKpv1

	cKonto = Ltrim(Rtrim(fltrAruanne.konto))+'%'

	tcCursor = 'CursorAlgSaldo'
	TcKonto = cKonto
	tnAsutusId1 = 0
	tnAsutusId2 = 99999999
	tnTunnusId1 = 0
	tnTunnusId2 = 99999999
	tdKpv1 = Date(1999,1,1)
	tdKpv2 = fltrAruanne.kpv1-1

* lisatud 22/05
	If Used ('curSaldo')
		Use In curSaldo
	Endif


	If !Empty(fltrAruanne.tunnus)
* сальдо по признаку
		tnTunnusId1 = fltrAruanne.tunnus
		tnTunnusId2 = fltrAruanne.tunnus
		If Used(tcCursor)
			Use In (tcCursor)
		Endif

		oDb.Use ('qrySaldo3',tcCursor)
		tdKpv1 = fltrAruanne.kpv1
		tdKpv2 = fltrAruanne.kpv2
		tcCursor = 'CursorKaibed'
* lisatud 22/05
		If Used(tcCursor)
			Use In (tcCursor)
		Endif

		oDb.Use ('qrySaldo3',tcCursor)
	Else
* сальдо по конто
		If Used(tcCursor)
			Use In (tcCursor)
		Endif

		oDb.Use ('qrySaldo1',tcCursor)
		tdKpv1 = fltrAruanne.kpv1
		tdKpv2 = fltrAruanne.kpv2
		tcCursor = 'CursorKaibed'
* lisatud 22/05
		If Used(tcCursor)
			Use In (tcCursor)
		Endif
		oDb.Use ('qrySaldo1',tcCursor)
	Endif


	Select cursorkaibed

	lcString = " SELECT * from comKontodremote "+;
		" WHERE kood in (select konto FROM CursorAlgSaldo) or kood in (select konto FROM Cursorkaibed) "
	If !Empty(fltrAruanne.konto)
		lcString = lcString + " and kood = '"+Ltrim(Rtrim(fltrAruanne.konto))+"'"
	Endif
*!*	If 'EELARVE' $ curkey.versia
*!*		lcString = lcString + " and LEN(LTRIM(RTRIM(kood))) = 6"
*!*	Endif
	lcString = lcString + " order by kood INTO CURSOR qryKontod"
	&lcString
	Scan For Left(Ltrim(Rtrim(kood)),Len(Ltrim(Rtrim(fltrAruanne.konto)))) = Ltrim(Rtrim(fltrAruanne.konto)) And;
			Len(Alltrim(kood)) = Iif('EELARVE' $ curkey.versia,6,Len(Alltrim(kood)))
		Wait Window 'Arvestan konto: '+comKontodRemote.kood Nowait
		lnRecno = Recno('qryKontod')
		lcKonto = Ltrim(Rtrim(qryKontod.kood))
		lnDb = analise_formula('DK('+lcKonto+')',fltrAruanne.kpv1,'cursorkaibed')
		lnKr = analise_formula('KK('+lcKonto+')',fltrAruanne.kpv1,'cursorkaibed')

		If qryKontod.liik = 1 Or qryKontod.liik = 3
			lnAlgdb = analise_formula('SD('+lcKonto+')',fltrAruanne.kpv1,'cursorAlgSaldo')
			lnAlgKr = 0
			lnLoppdb = lnAlgdb + lnDb - lnKr
			lnLoppKr = 0

		Else
			lnAlgKr = analise_formula('SK('+lcKonto+')',fltrAruanne.kpv1,'cursorAlgSaldo')
			lnAlgdb = 0
			lnLoppKr = lnAlgKr - lnDb + lnKr
			lnLoppdb = 0
		Endif
		lnPk = Len(lcKonto) - Round(Len(lcKonto)/2,0)
		
		IF LEFT(ALLTRIM(qryKontod.kood),6) = '100100'
			lnPk = 6
		endif
		Select qryKontod
		If lnAlgdb <> 0 Or lnAlgKr <> 0 Or lnDb<> 0 Or lnKr <> 0
			Insert Into kaibeandmik_report1 (algdb,algkr, deebet, kreedit,loppdb, loppkr, konto, pohikonto, nimetus, liik);
				values (lnAlgdb,lnAlgKr, lnDb, lnKr,lnLoppdb, lnLoppKr, qryKontod.kood,;
				left(Rtrim(Ltrim(qryKontod.kood)),lnPk), ;
				qryKontod.nimetus,qryKontod.liik )
		Endif
	Endscan
	Use In qryKontod
	Select kaibeandmik_report1
ENDTEXT
