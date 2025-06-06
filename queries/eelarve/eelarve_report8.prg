Parameter cWhere
* Eelarve (kassa ja tegelik kulud)    

Create Cursor eelarve_report2 (rekvid Int, kood1 c(20), kood4 c(20), nimetus c(254), eelarve Y, ;
	taitmineK Y, taitmineF Y, taitmine Y, asutus c(254), regkood c(254),;
	parAsutus c(254), parregkood c(20))
Index On Left(Ltrim(Rtrim(parregkood)),11)+'-'+Left(Ltrim(Rtrim(regkood)),11)+'-'+Alltrim(kood1)+'-'+Alltrim(kood4) Tag idx1
Set Order To idx1

If !Empty (fltrAruanne.asutusid)
	Select comrekvremote
	Locate For Id = fltrAruanne.asutusid
	tcAsutus = Ltrim(Rtrim(comrekvremote.nimetus)) + '%'
Else
	tcAsutus = '%'
ENDIF
IF EMPTY(fltrAruanne.kond)
	tnParent = 3
ELSE
	tnParent = 1
ENDIF

SET STEP ON 

tnTunnus = fltrAruanne.tunn
tcTunnus = Ltrim(Rtrim(fltrAruanne.tunnus))+'%'
tckOOD1 = Ltrim(Rtrim(fltrAruanne.KOOD1))+'%'
tckOOD2 = Ltrim(Rtrim(fltrAruanne.KOOD2))+'%'
tckOOD4 = Ltrim(Rtrim(fltrAruanne.KOOD4))+'%'
tckOOD5 = Ltrim(Rtrim(fltrAruanne.KOOD5))+'%'
tckOOD = Ltrim(Rtrim(fltrAruanne.KOOD5))+'%'
tctegev = Ltrim(Rtrim(fltrAruanne.KOOD1))+'%'
tcEelarve = '%'
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

IF tnTunnus > 0 
	tdKpv = fltrAruanne.kpv
ELSE
	tdKpv = DATE(YEAR(DATE()),12,31)
ENDIF
 
 
	lnLiik = 601
	
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

			lcString = "select eelarve, tegev, summa1 as eelarve1, summa2 as eelarve2, summa3 as taitmineK,summa6 as TaitmineF, RekvIdSub "+;
			" from tmp_eelproj_aruanne1 inner join rekv on rekv.id = tmp_eelproj_aruanne1.rekvidsub where rekvid = "+str(gRekv)+;
			" and timestamp = '"+tcTimestamp +"'" +;
			" order by RekvIdSub, eelarve "
			lError = oDb.Execsql(lcString, 'eelarve_report_tmp')

			If !Empty (lError) And Used('eelarve_report_tmp')
					insert into  eelarve_report2 (rekvid , kood1, kood4, nimetus, eelarve, taitmineK, taitmineF, asutus, regkood ,parAsutus, parregkood);
					select grekv, eelarve_report_tmp.tegev, eelarve_report_tmp.eelarve, iif(isnull(comEelarveAruanne.nimetus),space(254),comEelarveAruanne.nimetus), ;
					eelarve_report_tmp.eelarve1+eelarve_report_tmp.eelarve2,;
					eelarve_report_tmp.taitmineK, eelarve_report_tmp.taitmineF, tmpRekvSub.nimetus,tmpRekvSub.regkood, tmpRekvPar.nimetus, tmpRekvSub.regkood;
					from eelarve_report_tmp ;
					left outer join comEelarveAruanne on comEelarveAruanne.kood = eelarve_report_tmp.eelarve;
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
	.Use ('curKassaKuluTaitm')
	.Use ('curFaktKuluTaitm')
Endwith
If gVersia = 'VFP'
	If  Used('curKassaKuludeTaitmine_')
		Use In curKassaKuludeTaitmine_
	Endif
	If  Used('curKassaTuludeTaitmine_')
		Use In curKassaTuludeTaitmine_
	Endif

Endif

If fltrAruanne.kohalik = 1
* ������ ������� ������

	* ����
	Select rekvid, kood1, kood4, Sum(Summa) As Summa, asutus, regkood, parAsutus, parregkood From tmpeelarvekulud;
		WHERE Empty(tmpeelarvekulud_.KOOD2) ;
		order By parAsutus, parregkood, asutus, regkood, kood1, kood4, rekvid;
		group By parAsutus, parregkood, asutus, regkood, kood1, kood4, rekvid;
		into Cursor tmpeelarvekulud

	* �����

	Select Sum(Summa) As Summa, tegev As kood1, kood As kood4, rekvid From curKassaKuluTaitm ;
		WHERE Empty(KOOD2) ;
		order By tegev, kood, rekvid;
		group By tegev, kood, rekvid;
		into Cursor qryKuluTaitmK

	* ����

	Select Sum(Summa) As Summa, tegev As kood1, kood As kood4, rekvid From curFaktKuluTaitm ;
		WHERE Empty(KOOD2) ;
		order By tegev, kood, rekvid;
		group By tegev, kood, rekvid;
		into Cursor qryKuluTaitmF


Else

	Select rekvid, kood1, kood4, Sum(Summa) As Summa, asutus, regkood, parAsutus, parregkood From tmpeelarvekulud_;
		order By parAsutus, parregkood, asutus, regkood, kood1, kood4, rekvid;
		group By parAsutus, parregkood, asutus, regkood, kood1, kood4, rekvid;
		into Cursor tmpeelarvekulud

	Select Sum(Summa) As Summa, tegev As kood1, kood As kood4, rekvid From curKassaKuluTaitm ;
		order By tegev, kood, rekvid;
		group By tegev, kood, rekvid;
		into Cursor qryKuluTaitmK

	Select Sum(Summa) As Summa, tegev As kood1, kood As kood4, rekvid From curFaktKuluTaitm;
		order By tegev, kood, rekvid;
		group By tegev, kood, rekvid;
		into Cursor qryKuluTaitmF

Endif
Use In 	tmpeelarvekulud_

Use In curKassaKuluTaitm
Use In curFaktKuluTaitm

Select rekvid, tmpeelarvekulud.kood1, tmpeelarvekulud.kood4, comEelarveRemote.nimetus,;
	tmpeelarvekulud.Summa / fltrAruanne.devide As eelarve,tmpeelarvekulud.asutus,;
	tmpeelarvekulud.regkood, tmpeelarvekulud.parAsutus, tmpeelarvekulud.parregkood;
	from tmpeelarvekulud, comEelarveRemote;
	WHERE tmpeelarvekulud.kood4 = comEelarveRemote.kood;
	into Cursor qry1

Select eelarve_report2
Append From Dbf ('qry1')
Use In qry1

Select qryKuluTaitmK
Scan
	Select eelarve_report2
	Locate For rekvid = qryKuluTaitmK.rekvid And Alltrim(kood4) == Alltrim(qryKuluTaitmK.kood4) And;
		alltrim(kood1) == Alltrim(qryKuluTaitmK.kood1)
	If Found ()
		Replace taitmineK With qryKuluTaitmK.Summa / fltrAruanne.devide In eelarve_report2
	Else
		Select comTegevRemote
		Locate For Alltrim(kood) == Alltrim(qryKuluTaitmK.kood1)

		Select comEelarveRemote
		Locate For Alltrim(kood) == Alltrim(qryKuluTaitmK.kood4)

		Select * From comrekvremote Where Id = grekv Into Cursor qry_Rekv1
		Select * From comrekvremote Where Id = qry_Rekv1.parentid Into Cursor qry_Rekv2

		Insert Into eelarve_report2 (kood1, kood4, nimetus, eelarve, asutus, regkood,parAsutus, parregkood, taitmineK) Values ;
			(comTegevRemote.kood, comEelarveRemote.kood,comEelarveRemote.nimetus,0,qry_Rekv1.nimetus,;
			qry_Rekv1.regkood, qry_Rekv2.nimetus, qry_Rekv2.regkood,qryKuluTaitmK.Summa / fltrAruanne.devide )

	Endif
Endscan

Select qryKuluTaitmF
Scan
	Select eelarve_report2
	Locate For rekvid = qryKuluTaitmF.rekvid And Alltrim(kood4) == Alltrim(qryKuluTaitmF.kood4) And;
		alltrim(kood1) == Alltrim(qryKuluTaitmF.kood1)
	If Found ()
		Replace taitmineF With qryKuluTaitmF.Summa / fltrAruanne.devide In eelarve_report2
	Else
		Select comTegevRemote
		Locate For Alltrim(kood) == Alltrim(qryKuluTaitmF.kood1)

		Select comEelarveRemote
		Locate For Alltrim(kood) == Alltrim(qryKuluTaitmF.kood4)

		Select * From comrekvremote Where Id = grekv Into Cursor qry_Rekv1
		Select * From comrekvremote Where Id = qry_Rekv1.parentid Into Cursor qry_Rekv2

		Insert Into eelarve_report2 (kood1, kood4, nimetus, eelarve, asutus, regkood,parAsutus, parregkood, taitmineF) Values ;
			(comTegevRemote.kood, comEelarveRemote.kood,comEelarveRemote.nimetus,0,qry_Rekv1.nimetus,;
			qry_Rekv1.regkood, qry_Rekv2.nimetus, qry_Rekv2.regkood,qryKuluTaitmF.Summa / fltrAruanne.devide )

	Endif
Endscan



If Used ('qry_rekv1')
	Use In qry_Rekv1
Endif
If Used ('qry_rekv2')
	Use In qry_Rekv2
Endif

Use In qryKuluTaitmK
Use In qryKuluTaitmF

Use In tmpeelarvekulud

IF !EMPTY(fltrAruanne.tunnus)
	SELECT comTunnusremote
	LOCATE FOR ALLTRIM(kood) = ALLTRIM(fltrAruanne.tunnus)
ENDIF


Select eelarve_report2
IF RECCOUNT() < 1
	APPEND blank
endif
