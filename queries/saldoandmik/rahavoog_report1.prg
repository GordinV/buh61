Parameter tcWhere

lcString = "select count(*) as count from pg_proc where proname = 'sp_saldoandmik_aruanned'"
lError = oDb.execsql(lcString, 'tmpProc')
If !Empty (lError) And Used('tmpProc') And !Empty(tmpProc.Count)
	Wait Window 'Serveri poolt funktsioon ...' Nowait
	lError = oDb.Exec("sp_saldoandmik_aruanned ", Str(grekv)+", DATE("+Str(Year(fltrAruanne.kpv2),4)+","+;
		STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+str(year(fltrAruanne.kpv2))+",5,"+Str(fltrAruanne.arvestus,9)+","+Str(fltrAruanne.kond,9),"qrySaldoandmik")

	If Used('qrySaldoandmik')
		tcTimestamp = Alltrim(qrySaldoandmik.sp_saldoandmik_aruanned)
		lcString = "select konto, nimetus, summa01, grupp, grupp2 from tmp_sk_aruanned where rekvid = "+Str(grekv)+;
			" and timestamp = '"+tcTimestamp +"'"+;
			" order by jrnr, konto, grupp, grupp2 desc "
			
		lError = oDb.execsql(lcString, 'bilanss_report1')

		If !Empty (lError) And Used('bilanss_report1')
			Select bilanss_report1
			Return
		Endif

	Else
		Select 0
		Return .F.
	Endif
Endif
