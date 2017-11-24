Parameter tcWhere
*SET STEP ON 
lcString = "select count(*) as count from pg_proc where proname = 'sp_saldoandmik_aruanned'"
lError = oDb.execsql(lcString, 'tmpProc')
If !Empty (lError) And Used('tmpProc') And !Empty(tmpProc.Count)
	Wait Window 'Serveri poolt funktsioon ...' Nowait
	
	lError = oDb.Exec("sp_saldoandmik_aruanned ", Str(grekv)+", DATE("+Str(Year(fltrAruanne.kpv2),4)+","+;
		STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+str(year(fltrAruanne.kpv2))+",7,"+Str(fltrAruanne.arvestus,9)+","+Str(fltrAruanne.kond,9),"qrySaldoandmik")
	
	
*	lError = oDb.Exec("sp_saldoandmik_aruanned ", Str(grekv)+", DATE("+Str(Year(fltrAruanne.kpv2),4)+","+;
*		STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+str(year(fltrAruanne.kpv2))+",3,"+Str(fltrAruanne.kond,9)+","+Str(fltrAruanne.arvestus,9),"qrySaldoandmik")

	If Used('qrySaldoandmik')
		tcTimestamp = Alltrim(qrySaldoandmik.sp_saldoandmik_aruanned)
		lcString = "select konto, nimetus, summa01,summa02,summa03,summa04,summa05,summa06,summa07 from tmp_sk_aruanned where rekvid = "+;
			Str(grekv)+	" and timestamp = '"+tcTimestamp +"'"+;
			" order by tmp_sk_aruanned.konto "
			
		lError = oDb.execsql(lcString, 'varadearuanne_report1')

		If !Empty (lError) And Used('varadearuanne_report1')
			Select varadearuanne_report1
			Return
		Endif

	Else
		Select 0
		Return .F.
	Endif
Endif
