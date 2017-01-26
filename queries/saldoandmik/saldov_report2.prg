Parameter tcWhere
*SET STEP ON 
lcString = "select count(*) as count from pg_proc where proname = 'sp_saldoandmik_aruanned'"
lError = oDb.execsql(lcString, 'tmpProc')
If !Empty (lError) And Used('tmpProc') And !Empty(tmpProc.Count)
	Wait Window 'Serveri poolt funktsioon ...' Nowait
	
	lError = oDb.Exec("sp_saldoandmik_aruanned ", Str(grekv)+", DATE("+Str(Year(fltrAruanne.kpv2),4)+","+;
		STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+str(year(fltrAruanne.kpv2))+",6,"+Str(fltrAruanne.arvestus,9)+","+Str(fltrAruanne.kond,9),"qrySaldoandmik")
	
	
*	lError = oDb.Exec("sp_saldoandmik_aruanned ", Str(grekv)+", DATE("+Str(Year(fltrAruanne.kpv2),4)+","+;
*		STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+str(year(fltrAruanne.kpv2))+",3,"+Str(fltrAruanne.kond,9)+","+Str(fltrAruanne.arvestus,9),"qrySaldoandmik")

	If Used('qrySaldoandmik')
		tcTimestamp = Alltrim(qrySaldoandmik.sp_saldoandmik_aruanned)
		lcString = "select tmp_sk_aruanned.tp,tmp_sk_aruanned.konto, tmp_sk_aruanned.nimetus, tmp_sk_aruanned.summa01, TP.NIMETUS as asutus "+;
		" from tmp_sk_aruanned inner join library tp ON (tmp_sk_aruanned.tp = tp.kood and tp.library = 'TP') where tmp_sk_aruanned.rekvid = "+;
			Str(grekv)+	" and timestamp = '"+tcTimestamp +"' and tp like '"+ ALLTRIM(fltrAruanne.tp)+"%"+"'" +;
			" order by tmp_sk_aruanned.tp,tmp_sk_aruanned.konto "
			
		lError = oDb.execsql(lcString, 'saldov_report2')

		If !Empty (lError) And Used('saldov_report2')
			Select saldov_report2
			Return
		Endif

	Else
		Select 0
		Return .F.
	Endif
Endif
