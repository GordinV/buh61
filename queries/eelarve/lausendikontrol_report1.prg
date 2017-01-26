Parameter cWhere


* Lausendi kontrol

tdKpv = fltrAruanne.kpv

* kontrollin sp_lausendikontrol
lcString = "select count(*) as count from pg_proc where proname = 'sp_lausendikontrol'"
	
lError = oDb.execsql(lcString, 'tmpProc')
If !Empty (lError) And Used('tmpProc') And !empty(tmpProc.Count)
	
	lcString = "select * from JournalKontrol where " +;
	" rekvid = " + str(grekv)+" and kpv >= "+;
	" DATE("+Str(Year(fltrAruanne.kpv1),4)+","+STR(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+") and kpv <= "+;
	" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+") "+;
	" order by viga,kpv, number " 
	
	
	lError = oDb.execsql(lcString, 'lausendikontrol_report1')
	
	if !empty (lError) and used('lausendikontrol_report1')			
			Select lausendikontrol_report1
			return .t.

	Else
			Select 0
			Return .F.
	Endif
Else
	Select 0
	Return .F.
endif
