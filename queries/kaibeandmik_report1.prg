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
Create Cursor kaibeandmik_report1 (algdb N(14,2),algkr N(14,2),deebet N(14,2),;
	kreedit N(14,2),loppdb N(14,2), loppkr N(14,2), konto c(20), pohikonto c(20), nimetus c(120), Type Int, liik Int)
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
ENDIF

replace fltrPrinter.kuurs WITH 15.6466 IN fltrPrinter

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
			SCAN
				

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
