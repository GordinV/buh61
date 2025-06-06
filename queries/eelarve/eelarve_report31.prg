Parameter cWhere

* Eelarve kulude majanduliku ja �ksuste sisu j�rgi   

Create Cursor eelarve_report2 (rekvid Int, tegev c(20), kood c(20), nimetus c(254), eelarve Y, taitmine Y, asutus c(254), regkood c(254),;
	parAsutus c(254), parregkood c(20), tunnus c(20), tunNimi c(254))
Index On '1'+'-'+kood+'-'+tunnus Tag idx1
Set Order To idx1

If !Empty (fltrAruanne.asutusid)
	Select comrekvremote
	Locate For Id = fltrAruanne.asutusid
	tcAsutus = Ltrim(Rtrim(comrekvremote.nimetus)) + '%'
Else
	tcAsutus = '%'
Endif
tnTunnus = fltrAruanne.tunn
tcTunnus = Ltrim(Rtrim(fltrAruanne.tunnus))+'%'
tckOOD1 = Ltrim(Rtrim(fltrAruanne.KOOD1))+'%'
tckOOD4 = Ltrim(Rtrim(fltrAruanne.KOOD4))+'%'
tckOOD2 = Ltrim(Rtrim(fltrAruanne.KOOD2))+'%'
tckOOD5 = Ltrim(Rtrim(fltrAruanne.KOOD5))+'%'
*tckOOD = Iif (Empty(fltrAruanne.KOOD4),'3',Ltrim(Rtrim(fltrAruanne.KOOD4)))+'%'
tckOOD = Ltrim(Rtrim(fltrAruanne.KOOD4))+'%'
tctegev = Ltrim(Rtrim(fltrAruanne.KOOD1))+'%'
tcEelarve = tckOOD5
tcNimetus = '%'
tnSumma1 = 	-999999999.99
tnSumma2 = 	999999999.99
tnAasta1 = 	Year (fltrAruanne.kpv1)
tnAasta2 = 	Year(fltrAruanne.kpv2)
tnKuu1 = 	Month(fltrAruanne.kpv1)
tnKuu2 = 	Month(fltrAruanne.kpv2)
IF tnKuu1 = 1 
	tnKuu1 = 0
endif
IF EMPTY(fltrAruanne.kond)
	tnParent = 3
ELSE
	tnParent = 1
ENDIF

IF tnTunnus > 0 
	tdKpv = fltrAruanne.kpv
ELSE
	tdKpv = DATE(YEAR(DATE()),12,31)
ENDIF

	lnLiik = 501
	
	lnLiik = lnLiik + tnTunnus + iif(fltrAruanne.kassakulud = 1,0,10)

	lcString = "select count(*) as count from pg_proc where proname = 'sp_eelarve_aruanne1'"
	lError = oDb.execsql(lcString, 'tmpProc')
	If !Empty (lError) And Used('tmpProc') And !empty(tmpProc.Count)
			wait window 'Serveri poolt funktsioon ...' nowait
		lError = oDb.Exec("sp_eelarve_aruanne1 ", Str(grekv)+;
			", DATE("+Str(Year(fltrAruanne.kpv1),4)+","+STR(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+"),"+;
			" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
			str(fltrAruanne.asutusid,9)+",'"+ltrim(rtrim(fltrAruanne.tunnus))+"','"+;
			ltrim(rtrim(fltrAruanne.kood4))+"','"+ltrim(rtrim(fltrAruanne.kood2))+"','"+;
			ltrim(rtrim(fltrAruanne.kood1))+"','"+ltrim(rtrim(fltrAruanne.kood5))+"','"+;
			ltrim(rtrim(fltrAruanne.proj))+"','"+ltrim(rtrim(fltrAruanne.tp))+"',"+str(lnLiik,3)+","+;
			Str(fltrAruanne.kond,9),"qryEelarve1")


		If Used('qryEelarve1')
			tcTimestamp = Alltrim(qryEelarve1.sp_eelarve_aruanne1)

			lcString = "select tunnus, eelarve, summa1 as eelarve1, summa2 as eelarve2, summa3 as taitmine,RekvIdSub "+;
			" from tmp_eelproj_aruanne1 inner join rekv on rekv.id = tmp_eelproj_aruanne1.rekvidsub where rekvid = "+str(gRekv)+;
			" and timestamp = '"+tcTimestamp +"'" +;
			" order by RekvIdSub, eelarve "
			lError = oDb.Execsql(lcString, 'eelarve_report_tmp')

			If !Empty (lError) And Used('eelarve_report_tmp')
					insert into  eelarve_report2 (rekvid , tunnus, tunnimi, kood, nimetus, eelarve, taitmine, asutus, regkood ,parAsutus, parregkood);
					select grekv, tunnus, iif(isnull(comTunnusRemote.nimetus),space(254),comTunnusRemote.nimetus),;
					 eelarve_report_tmp.eelarve, iif(isnull(comEelarveAruanne.nimetus),space(254),comEelarveAruanne.nimetus), ;
					eelarve_report_tmp.eelarve1+eelarve_report_tmp.eelarve2,;
					eelarve_report_tmp.taitmine, tmpRekvSub.nimetus,tmpRekvSub.regkood, tmpRekvPar.nimetus, tmpRekvSub.regkood;
					from eelarve_report_tmp ;
					left outer join comEelarveAruanne on comEelarveAruanne.kood = eelarve_report_tmp.eelarve;
					left outer join comTunnusRemote on comTunnusRemote.kood = eelarve_report_tmp.tunnus;
					left outer join comRekvRemote tmpRekvSub on tmpRekvSub.id = eelarve_report_tmp.RekvIdSub;
					left outer join comRekvRemote tmpRekvPar on tmpRekvPar.id = gRekv
					
				use in 	eelarve_report_tmp
				if used('tmpRekvPar')
					use in 	tmpRekvPar
				endif
				if used('tmpRekvSub')
					use in 	tmpRekvSub
				endif
						
				Select eelarve_report2
				return .t.
			Endif

		Else
			Select 0
			Return .F.
		Endif
	Endif





With oDb
	.Use ('CUREELARVEKULUD', 'tmpeelarvekulud_')
	.Use ('curKuluTaitm','tmpKuluTaitm',.T.)
	.dbreq ('tmpKuluTaitm',gnhandle,IIF(fltrAruanne.kassakulud = 1,'curKassaKuluTaitm','curFaktKuluTaitm'))
Endwith
If gVersia = 'VFP'
	If  Used('curKassaKuludeTaitmine_')
		Use In curKassaKuludeTaitmine_
	Endif
Endif

Select KOOD4, TUN As tunnus, Sum(Summa) As Summa From tmpeelarvekulud_;
	order By   KOOD4, TUN;
	group By  KOOD4, TUN;
	into Cursor tmpeelarvekulud
Use In 	tmpeelarvekulud_

Select Sum(Summa) As Summa, kood, TUN As tunnus From tmpKuluTaitm ;
	order By kood,  TUN;
	group By kood,  TUN;
	into Cursor qryKuluTaitm
Use In tmpKuluTaitm


Select tmpeelarvekulud
Scan
	lcKood = ''
	lcNimetus = ''
	If !Empty(tmpeelarvekulud.KOOD4)
		Select comEelarveRemote
		If Tag() <> 'KOOD'
			Set Order To kood
		Endif
		Seek tmpeelarvekulud.KOOD4
		If Found()
			lcKood = comEelarveRemote.kood
			lcNimetus = comEelarveRemote.nimetus
		Endif

	Endif

	lnTaitm = 0
	lcTunnus = ''
	If !Empty(qryKuluTaitm.tunnus)
		Select comTunnusRemote
		If Tag() <> 'KOOD'
			Set Order To kood
		Endif
		Seek tmpeelarvekulud.tunnus
		If Found()
			lcTunnus = comTunnusRemote.nimetus
		Endif
	Endif

	Insert Into eelarve_report2 (tunnus, tunNimi, kood, nimetus, eelarve,  taitmine) Values ;
		(tmpeelarvekulud.tunnus, lcTunnus,  lcKood,lcNimetus,tmpeelarvekulud.Summa /fltrAruanne.devide,lnTaitm )
Endscan

Select qryKuluTaitm
Scan
	lcTunnus = ''
	If !Empty(qryKuluTaitm.tunnus)
		Select comTunnusRemote
		If Tag() <> 'KOOD'
			Set Order To kood
		Endif
		Seek qryKuluTaitm.tunnus
		If Found()
			lcTunnus = comTunnusRemote.nimetus
		Endif
	Endif
	Select eelarve_report2
	Locate For kood = qryKuluTaitm.kood And;
		tunnus = qryKuluTaitm.tunnus
*And eelarve = tmpeelarvetulud.KOOD5 And tegev = tmpeelarvetulud.KOOD1
	If Found()
		Replace taitmine With qryKuluTaitm.Summa /fltrAruanne.devide In eelarve_report2
	Else
		Select comEelarveRemote
		If Tag() <> 'KOOD'
			Set Order To kood
		Endif
		lcKood = ''
		lcNimetus = ''
		Seek qryKuluTaitm.kood
		IF FOUND()
			lcKood = comEelarveRemote.kood
			lcNimetus = comEelarveRemote.nimetus
		ENDIF
		
		Insert Into eelarve_report2 (tunnus, tunNimi,  kood, nimetus, eelarve, taitmine) Values ;
			(qryKuluTaitm.tunnus, lcTunnus, lckood,lcnimetus,0 ,qryKuluTaitm.Summa /fltrAruanne.devide )
	Endif
Endscan

Use In qryKuluTaitm
Use In tmpeelarvekulud

IF !EMPTY(fltrAruanne.tunnus)
	SELECT comTunnusremote
	LOCATE FOR ALLTRIM(kood) = ALLTRIM(fltrAruanne.tunnus)
ENDIF


Select eelarve_report2
If Reccount() < 1
	Append Blank
Endif


