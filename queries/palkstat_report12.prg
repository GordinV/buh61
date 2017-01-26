LPARAMETERS tcWhere
If gVersia <> 'PG'
	Select 0
	Return
ENDIF

lError = oDb.Exec("sp_palkstat_aruanne22 ",Str(grekv)+","+;
	" DATE("+Str(Year(fltrAruanne.kpv1),4)+","+ Str(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+"),"+;
	" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+	Str(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
	STR(fltrAruanne.osakondId,9)+","+ STR(fltrAruanne.ametnik,1),"qryStat")

If Used('qryStat')
	tcTimestamp = Alltrim(qryStat.sp_palkstat_aruanne22)
	oDb.Use('TMPPALKSTAT_ARUANNE2','PalkStat_report1')
	Select PalkStat_report1
	If Reccount('PalkStat_report1') < 1
		Append Blank
	ENDIF
Else
	Select 0
	Return
Endif
