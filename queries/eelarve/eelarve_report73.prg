Parameter cWhere
* Eelarve kulude tegevusalade ja majanduliku sisu j�rgi


*!*	Create Cursor eelarve_report2 (kood1 c(20),kood2 c(20), kood5 c(20), nimetus c(254), eelarve Y, taitmine Y)
*!*	Index On Left(Ltrim(Rtrim(parAsutus)),11)+'-'+Left(Ltrim(Rtrim(asutus)),11)+'-'+Str(rekvid,3)+'-'+Alltrim(kood1)+'-'+Alltrim(kood4)+'-'+Alltrim(kood2) Tag idx1
*!*	Set Order To idx1

Wait Window 'Serveri poolt funktsioon ...' Nowait
lError = oDb.Exec("sp_eelarve_aruanne4 ", Str(grekv)+;
	", DATE("+Str(Year(fltrAruanne.kpv2),4)+","+Str(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),'"+;
	ltrim(Rtrim(fltrAruanne.kood2))+"%','"+;
	ltrim(Rtrim(fltrAruanne.kood1))+"%','"+;
	ltrim(Rtrim(fltrAruanne.KOOD5))+"%',"+;
	IIF(fltrAruanne.tunn=0,'0','1')+","+;
	Str(fltrAruanne.kond,9)+","+IIF(fltrAruanne.read = 1,'1','0'),"qryEelarve1")


If Used('qryEelarve1')
	tcTimestamp = Alltrim(qryEelarve1.sp_eelarve_aruanne4)

	lcString = "select kood1, kood5, nimetus, summa1 as eelarve, summa2 as taitmine "+;
		" from tmp_eelproj_aruanne1 where timestamp = '"+tcTimestamp +"'" +;
		" order by tunnus,kood1,kood5 "

	lError = oDb.Execsql(lcString, 'eelarve_report2')

	If Used('qryEelarve1')
		Use In 	qryEelarve1
	Endif

	Select eelarve_report2
	Return .T.
Else
	Select 0
	Return .F.
Endif

