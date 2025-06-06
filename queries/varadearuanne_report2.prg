Parameter cWhere
Local lnDeebet, lnKreedit
With odb
	Create cursor varadearuanne_report0 (id int,kood c(20), nimetus c(254), konto c(20),GRUPP c(254),;
		soetmaks n(18,6), soetkpv d, algjaak n(18,6), algkulum n(18,6), deebet n(18,6), sise n(18,6), sisekulum n(18,6), valja n(18,6), valja n(18,6), loppjaak n(18,6), loppkulum n(18,6))
	Index on id tag id
	Set order to id
	tnTunnus = 1
	tcKood = '%%'
	tcNimetus = '%%'
	tcRentnik = '%'
	tcKonto = iif (!empty (fltrAruanne.konto), alltrim(fltrAruanne.konto)+'%','%%')
	If !empty (fltrAruanne.asutusid)
		Select comAsutusRemote
		Locate for id = fltrAruanne.asutusid
		tcVastIsik = '%'+ltrim(rtrim(comAsutusRemote.nimetus))+'%'
	Else
		tcVastIsik = '%%'
	Endif
	If !empty (fltrAruanne.GRUPP)
		tnId = fltrAruanne.GRUPP
		.use ('v_library','qryGrupp')
		tcGrupp = '%'+ltrim(rtrim(qryGrupp.nimetus))+'%'
	Else
		tcGrupp =  '%%'
	Endif
	tnSoetmaks1 = -99999999999
	tnSoetmaks2 = 9999999999
	tdSoetkpv1 = date() - 365 * 100
	tdSoetkpv2 = fltrAruanne.kpv2
	If !USED('qryPohivara')
		.use ('curPohivara','qryPohivara',gnHandle,.t.)
	Endif
	Select qryPohivara
	If reccount ('qryPohivara') = 0
		.dbreq('qryPohivara',gnHandle,'curPohivara')
	Endif
	Scan
		Insert into varadearuanne_report0 (id, kood, nimetus, konto, soetmaks, soetkpv, vastisik,  GRUPP, kulumkokku, jaak, muud, PARHIND);
			values (qryPohivara.id, qryPohivara.kood, qryPohivara.nimetus, qryPohivara.konto, qryPohivara.soetmaks * qryPohivara.kuurs,;
			qryPohivara.soetkpv, qryPohivara.vastisik, qryPohivara.GRUPP, qryPohivara.algkulum * qryPohivara.kuurs,;
			(qryPohivara.soetmaks - qryPohivara.algkulum)*qryPohivara.kuurs,qryPohivara.rentnik, qryPohivara.parhind  * qryPohivara.kuurs)
	Endscan
	tnTunnus = 0
	Select qryPohivara
	.dbreq('qryPohivara',gnHandle,'curPohivara')
	Delete FROM qryPohivara where mahakantud < fltrAruanne.kpv1
	Scan
		Insert into varadearuanne_report0 (id, kood, nimetus, konto, soetmaks, soetkpv, vastisik,  GRUPP, kulumkokku, jaak, muud, parhind);
			values (qryPohivara.id, qryPohivara.kood, qryPohivara.nimetus, qryPohivara.konto, qryPohivara.soetmaks * qryPohivara.kuurs,;
			qryPohivara.soetkpv, qryPohivara.vastisik, qryPohivara.GRUPP, qryPohivara.algkulum * qryPohivara.kuurs,;
			(qryPohivara.soetmaks - qryPohivara.algkulum) * qryPohivara.kuurs, qryPohivara.rentnik , qryPohivara.parhind * qryPohivara.kuurs  )
	Endscan
	tnTunnus = 1
	tnGruppId1 = iif(!empty (fltrAruanne.GRUPP),fltrAruanne.GRUPP,0)
	tnGruppId2 = iif(!empty (fltrAruanne.GRUPP),fltrAruanne.GRUPP,99999999999)
	tdKpv1 = date(year(date()),1,1) - 365 * 50
	tdKpv2 = fltrAruanne.kpv1

	.use ('curParandus')
	Select curParandus
	Scan
		Select varadearuanne_report0
		Seek curParandus.id
		If found()
			Replace soetmaks with varadearuanne_report0.soetmaks + curParandus.kulumkokku,;
				jaak with varadearuanne_report0.soetmaks + varadearuanne_report0.parandus - varadearuanne_report0.kulumkokku 	 IN varadearuanne_report0
		Endif
	Endscan

	.use ('curKulum')
	If RECCOUNT ('curKulum') < 1
		.dbreq('curKulum',gnHandle,'curKulum')
	Endif
	Select curKulum
	Scan
		Select varadearuanne_report0
		Seek curKulum.id
		If found()
			Replace kulumkokku with varadearuanne_report0.kulumkokku + curKulum.kulumkokku,;
				jaak with varadearuanne_report0.soetmaks + varadearuanne_report0.parandus - varadearuanne_report0.kulumkokku 	 IN varadearuanne_report0
		Endif
	Endscan

	tdKpv1 = fltrAruanne.kpv1
	tdKpv2 = iif (!empty (fltrAruanne.kpv2), fltrAruanne.kpv2, date())
	.dbreq('curKulum',gnHandle,'curKulum')
	.dbreq('curParandus',gnHandle,'curParandus')
	Select curParandus
	Scan
		Select varadearuanne_report0
		Seek curParandus.id
		If found()
			Replace parandus with varadearuanne_report0.parandus + curParandus.kulumkokku,;
				jaak with varadearuanne_report0.soetmaks + varadearuanne_report0.parandus - varadearuanne_report0.kulumkokku 	 IN varadearuanne_report0
		Endif
	Endscan
	Select curKulum
	Scan
		Select varadearuanne_report0
		Seek curKulum.id
		If found()
			Replace kulumkokku with varadearuanne_report0.kulumkokku + curKulum.kulumkokku,;
				jaak with varadearuanne_report0.soetmaks + varadearuanne_report0.parandus - varadearuanne_report0.kulumkokku 	 IN varadearuanne_report0
		Endif
	Endscan

	If used('curParandus')
		Use in curParandus
	Endif
	If used('qryPohivara')
		Use in qryPohivara
	Endif
Endwith
Select * from varadearuanne_report0;
	order by GRUPP, kood;
	into cursor varadearuanne_report1
Use in varadearuanne_report0
