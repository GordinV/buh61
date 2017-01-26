Parameter tcWhere

If gVersia <> 'PG'
	select 0
	return .f.
endif
*set step on
	lcString = "select count(*) as count from pg_proc where proname = 'sp_eelarve_aruanne1'"
	lError = oDb.execsql(lcString, 'tmpProc')
	If !Empty (lError) And Used('tmpProc') And !empty(tmpProc.Count)
	*		wait window 'Serveri poolt funktsioon ...' nowait
		lError = oDb.Exec("sp_eelarve_aruanne1 ", Str(grekv)+;
			", DATE("+Str(Year(fltrAruanne.kpv1),4)+","+STR(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+"),"+;
			" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
			str(fltrAruanne.asutusid,9)+",'"+ltrim(rtrim(fltrAruanne.tunnus))+"','"+;
			ltrim(rtrim(fltrAruanne.tunnus))+"','"+ltrim(rtrim(fltrAruanne.kood2))+"','"+;
			ltrim(rtrim(fltrAruanne.kood2))+"','"+ltrim(rtrim(fltrAruanne.kood5))+"','"+;
			ltrim(rtrim(fltrAruanne.proj))+"','"+ltrim(rtrim(fltrAruanne.tp))+"',1,"+;
			Str(fltrAruanne.kond,9),"qryEelarve1")

		If Used('qryEelarve1')
			tcTimestamp = Alltrim(qryEelarve1.sp_eelarve_aruanne1)

			lcString = "select konto, tp_db, tp_kr, tegev, eelarve, allikas, rahavoo, sum(db) as db, sum(kr) as kr, AllAsutus, RekvIdSub from tmp_eelarve_aruanne1 where rekvid = "+str(gRekv)+;
			" and timestamp = '"+tcTimestamp +"' group by konto, tp_db, tp_kr, tegev, allikas, rahavoo, eelarve, AllAsutus, RekvIdSub"+;
			" order by AllAsutus,konto, allikas, tegev, eelarve, tp_db, tp_kr "
			lError = oDb.Execsql(lcString, 'eelarve_report1')

			If !Empty (lError) And Used('eelarve_report1')
				Select eelarve_report1
				return .t.
			Endif

		Else
			Select 0
			Return .F.
		Endif
	Endif


