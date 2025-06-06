Parameter cWhere
Local lnDeebet, lnKreedit

* PV inventuuriaruanne 
		
Create Cursor varadearuanne_report1(Id Int,kood c(20), nimetus c(254), konto c(20),GRUPP c(254),;
	soetmaks n(18,6), soetkpv d, kulum n(18,6), algkulum n(18,6), kulumkokku n(18,6), jaak n(18,6), mahakantud n(18,6), parandus n(18,6),;
	PARHIND n(18,6), tunnus Int, vastisik c(254), muud m)

tcKonto = Iif (!Empty (fltrAruanne.konto), Alltrim(fltrAruanne.konto)+'%','%%')
With odb
	If !Empty (fltrAruanne.GRUPP)
		tnId = fltrAruanne.GRUPP
		.Use ('v_library','qryGrupp')
		tcGrupp = Ltrim(Rtrim(qryGrupp.nimetus))+'%'
	Else
		tcGrupp =  '%'
	Endif

	If !Empty (fltrAruanne.asutusid)
		Select comAsutusRemote
		Locate For Id = fltrAruanne.asutusid
		tcVastIsik = '%'+Ltrim(Rtrim(comAsutusRemote.nimetus))+'%'
	Else
		tcVastIsik = '%%'
	Endif

	lError = .Exec("sp_pv_inventuuri_aruanne",Str(grekv)+ ","+;
		" DATE("+Str(Year(DATE(1900,01,01)),4)+","+ Str(Month(DATE(1900,01,01)),2)+","+Str(Day(DATE(1900,01,01)),2)+"),"+;
		" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+	Str(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),'"+;
		tcKonto +"','" + tcGrupp +"','"+ tcVastIsik +"'","qryPvAruanne")

	If Used('qryPvAruanne')
		tcTimestamp = Alltrim(qryPvAruanne.sp_pv_inventuuri_aruanne)
		.Use('tmppvaruanne1')
	Endif

Endwith

Insert into varadearuanne_report1(id, kood, nimetus, konto, soetmaks, soetkpv,  algkulum, GRUPP, jaak, ;
	mahakantud, parandus, tunnus, kulum, kulumkokku, vastisik, muud);
	SELECT id, kood, nimetus, konto, soetmaks, soetkpv, algkulum, GRUPP, jaak, mahakantud, parandus, ;
	IIF(tmppvaruanne1.mahakantud > 0,0,1), kulum, kulumkokku, vastisik, muud ;
	FROM tmppvaruanne1 


USE IN tmppvaruanne1

SELECT varadearuanne_report1		
DELETE FROM varadearuanne_report1 WHERE mahakantud > 0
