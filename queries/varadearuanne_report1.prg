Parameter cWhere
Local lnDeebet, lnKreedit
		
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


	lError = .Exec("sp_pv_aruanne1 ",Str(grekv)+ ","+;
		" DATE("+Str(Year(DATE(1900,01,01)),4)+","+ Str(Month(DATE(1900,01,01)),2)+","+Str(Day(DATE(1900,01,01)),2)+"),"+;
		" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+	Str(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),'"+;
		tcKonto +"','" + tcGrupp +"','"+ tcVastIsik +"'","qryPvAruanne")

	If Used('qryPvAruanne')
		tcTimestamp = Alltrim(qryPvAruanne.sp_pv_aruanne1)
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
		
*!*		
*!*		tnTunnus = 1
*!*		tcKood = '%%'
*!*		tcNimetus = '%%'
*!*		tcRentnik = '%'
*!*		tcKonto = iif (!empty (fltrAruanne.konto), alltrim(fltrAruanne.konto)+'%','%%')
*!*		If !empty (fltrAruanne.asutusid)
*!*			Select comAsutusRemote
*!*			Locate for id = fltrAruanne.asutusid
*!*			tcVastIsik = '%'+ltrim(rtrim(comAsutusRemote.nimetus))+'%'
*!*		Else
*!*			tcVastIsik = '%%'
*!*		Endif
*!*		If !empty (fltrAruanne.GRUPP)
*!*			tnId = fltrAruanne.GRUPP
*!*			.use ('v_library','qryGrupp')
*!*			tcGrupp = '%'+ltrim(rtrim(qryGrupp.nimetus))+'%'
*!*		Else
*!*			tcGrupp =  '%%'
*!*		Endif
*!*		tnSoetmaks1 = -99999999999
*!*		tnSoetmaks2 = 9999999999
*!*		tdSoetkpv1 = date() - 365 * 100
*!*		tdSoetkpv2 = fltrAruanne.kpv2
*!*		tdKpv = fltrAruanne.kpv2
*!*		.use ('curPohivaraUus')
*!*		If !USED('qryPohivara')
*!*			.use ('curPohivara','qryPohivara',gnHandle,.t.)
*!*		Endif
*!*		Select qryPohivara
*!*		If reccount ('qryPohivara') = 0
*!*			.dbreq('qryPohivara',gnHandle,'curPohivara')
*!*		Endif
*!*		Scan
*!*			Insert into varadearuanne_report0 (id, kood, nimetus, konto, soetmaks, soetkpv, vastisik,  GRUPP, kulumkokku, jaak, muud, PARHIND);
*!*				values (qryPohivara.id, qryPohivara.kood, qryPohivara.nimetus, qryPohivara.konto, qryPohivara.soetmaks,;
*!*				qryPohivara.soetkpv, qryPohivara.vastisik, qryPohivara.GRUPP, qryPohivara.algkulum,;
*!*				qryPohivara.soetmaks - qryPohivara.algkulum,qryPohivara.rentnik, qryPohivara.parhind  )
*!*		Endscan
*!*		tnTunnus = 0
*!*		Select qryPohivara
*!*		.dbreq('qryPohivara',gnHandle,'curPohivara')
*!*		Delete FROM qryPohivara where mahakantud < fltrAruanne.kpv1
*!*			
*!*		SCAN
*!*		* VLAD 30/01/2006
*!*			SELECT curPohivaraUus
*!*			LOCATE FOR curPohivaraUus.parentid = qryPohivara.id
*!*			IF FOUND()
*!*				lnHind = curPohivaraUus.summa
*!*			ELSE
*!*				lnHind = qryPohivara.soetmaks
*!*			endif
*!*		
*!*			Insert into varadearuanne_report0 (id, kood, nimetus, konto, soetmaks, soetkpv, vastisik,  GRUPP, kulumkokku, jaak, muud, parhind);
*!*				values (qryPohivara.id, qryPohivara.kood, qryPohivara.nimetus, qryPohivara.konto, lnHind,;
*!*				qryPohivara.soetkpv, qryPohivara.vastisik, qryPohivara.GRUPP, qryPohivara.algkulum,;
*!*				qryPohivara.soetmaks - qryPohivara.algkulum, qryPohivara.rentnik , qryPohivara.parhind  )
*!*		ENDSCAN
*!*		
*!*		tnTunnus = 1
*!*		tnGruppId1 = iif(!empty (fltrAruanne.GRUPP),fltrAruanne.GRUPP,0)
*!*		tnGruppId2 = iif(!empty (fltrAruanne.GRUPP),fltrAruanne.GRUPP,99999999999)
*!*		tdKpv1 = date(year(date()),1,1) - 365 * 50
*!*		tdKpv2 = fltrAruanne.kpv1

*!*		.use ('curParandus')
*!*		Select curParandus
*!*		
*!*		
*!*		SCAN
*!*		
*!*			SELECT curPohivaraUus
*!*			LOCATE FOR curPohivaraUus.parentid = qryPohivara.id
*!*			IF FOUND()
*!*				lnHind = curPohivaraUus.summa
*!*			ELSE
*!*				lnHind = qryPohivara.soetmaks
*!*			endif
*!*		
*!*		
*!*			Select varadearuanne_report0
*!*			Seek curParandus.id
*!*			If found()
*!*				Replace soetmaks with varadearuanne_report0.soetmaks + curParandus.kulumkokku,;
*!*					jaak with varadearuanne_report0.soetmaks + varadearuanne_report0.parandus - varadearuanne_report0.kulumkokku 	 IN varadearuanne_report0
*!*			Endif
*!*		Endscan

*!*		.use ('curKulum')
*!*		If RECCOUNT ('curKulum') < 1
*!*			.dbreq('curKulum',gnHandle,'curKulum')
*!*		Endif
*!*		Select curKulum
*!*		Scan
*!*			Select varadearuanne_report0
*!*			Seek curKulum.id
*!*			If found()
*!*				Replace kulumkokku with varadearuanne_report0.kulumkokku + curKulum.kulumkokku,;
*!*					jaak with varadearuanne_report0.soetmaks + varadearuanne_report0.parandus - varadearuanne_report0.kulumkokku 	 IN varadearuanne_report0
*!*			Endif
*!*		Endscan

*!*		tdKpv1 = fltrAruanne.kpv1
*!*		tdKpv2 = iif (!empty (fltrAruanne.kpv2), fltrAruanne.kpv2, date())
*!*		.dbreq('curKulum',gnHandle,'curKulum')
*!*		.dbreq('curParandus',gnHandle,'curParandus')
*!*		Select curParandus
*!*		Scan
*!*			Select varadearuanne_report0
*!*			Seek curParandus.id
*!*			If found()
*!*				Replace parandus with varadearuanne_report0.parandus + curParandus.kulumkokku,;
*!*					jaak with varadearuanne_report0.soetmaks + varadearuanne_report0.parandus - varadearuanne_report0.kulumkokku 	 IN varadearuanne_report0
*!*			Endif
*!*		Endscan
*!*		Select curKulum
*!*		Scan
*!*			Select varadearuanne_report0
*!*			Seek curKulum.id
*!*			If found()
*!*				Replace kulumkokku with varadearuanne_report0.kulumkokku + curKulum.kulumkokku,;
*!*					jaak with varadearuanne_report0.soetmaks + varadearuanne_report0.parandus - varadearuanne_report0.kulumkokku 	 IN varadearuanne_report0
*!*			Endif
*!*		Endscan

*!*		If used('curParandus')
*!*			Use in curParandus
*!*		Endif
*!*		If used('qryPohivara')
*!*			Use in qryPohivara
*!*		Endif
*!*	Endwith
*!*	Select * from varadearuanne_report0;
*!*		order by GRUPP, kood;
*!*		into cursor varadearuanne_report1
*!*	Use in varadearuanne_report0
