Parameter cWhere
* Eelarve kulude tegevusalade ja majanduliku sisu j�rgi  


Create Cursor eelarve_report2 (rekvid Int, kood1 c(20),kood2 c(20), kood4 c(20), nimetus c(254), laen Y, eelarve Y, taitmine Y, asutus c(254), regkood c(254),;
	parAsutus c(254), parregkood c(20))
Index On Left(Ltrim(Rtrim(parregkood)),11)+'-'+Left(Ltrim(Rtrim(regkood)),11)+'-'+STR(rekvid,3)+'-'+Alltrim(kood1)+'-'+Alltrim(kood4) Tag idx1
Set Order To idx1

If !Empty (fltrAruanne.asutusid)
	Select comrekvremote
	Locate For Id = fltrAruanne.asutusid
	tcAsutus = Ltrim(Rtrim(comrekvremote.nimetus)) + '%'
Else
	tcAsutus = '%'
Endif
IF EMPTY(fltrAruanne.kond)
	tnParent = 3
ELSE
	tnParent = 1
ENDIF

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



	lnLiik = 401
	
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

			lcString = "select tegev, allikas, eelarve as art, summa1 + summa2 as eelarve,summa4+summa5 as laen, summa3 as taitmine,RekvIdSub "+;
			" from tmp_eelproj_aruanne1 inner join rekv on rekv.id = tmp_eelproj_aruanne1.rekvidsub where rekvid = "+str(gRekv)+;
			" and timestamp = '"+tcTimestamp +"'" +;
			" order by RekvIdSub, tmp_eelproj_aruanne1.allikas,tmp_eelproj_aruanne1.tegev, tmp_eelproj_aruanne1.eelarve "
			lError = oDb.Execsql(lcString, 'eelarve_report_tmp')

			If !Empty (lError) And Used('eelarve_report_tmp')
					insert into  eelarve_report2 (rekvid ,kood1, kood2, kood4, nimetus, eelarve, laen, taitmine, asutus, regkood ,parAsutus, parregkood);
					select grekv, eelarve_report_tmp.tegev,eelarve_report_tmp.allikas, eelarve_report_tmp.art, iif(isnull(comEelarveAruanne.nimetus),space(254),comEelarveAruanne.nimetus), ;
					eelarve_report_tmp.eelarve,eelarve_report_tmp.laen,;
					eelarve_report_tmp.taitmine, tmpRekvSub.nimetus,tmpRekvSub.regkood, tmpRekvPar.nimetus, tmpRekvSub.regkood;
					from eelarve_report_tmp ;
					left outer join comEelarveAruanne on comEelarveAruanne.kood = eelarve_report_tmp.art;
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
	tckOOD5 = 'LAEN%'
	.Use ('CUREELARVEKULUD', 'tmpeelarveLaen_')
	tckOOD5 = Ltrim(Rtrim(fltrAruanne.KOOD5))+'%'
	.Use ('CUREELARVEKULUD', 'tmpeelarvekulud_')
	.Use (IIF(fltrAruanne.kassakulud = 1,'curKassaKuluTaitm','curFaktKuluTaitm'),'tmpKuluTaitm')
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

	Select rekvid, kood1, kood4, Sum(Summa) As Summa, regkood, asutus, parAsutus, parregkood From tmpeelarvelaen_;
		WHERE Empty(tmpeelarvelaen_.KOOD2) ;
		order By parAsutus, parregkood, asutus, regkood, kood1, kood4, rekvid;
		group By parAsutus, parregkood, asutus, regkood, kood1, kood4, rekvid;
		into Cursor tmpeelarvelaen

	Select rekvid, kood1, kood4, Sum(Summa) As Summa, asutus, regkood, parAsutus, parregkood From tmpeelarvekulud_;
		WHERE Empty(tmpeelarvekulud_.KOOD2) ;
		order By parAsutus, parregkood, asutus, regkood, kood1, kood4, rekvid;
		group By parAsutus, parregkood, asutus, regkood, kood1, kood4, rekvid;
		into Cursor tmpeelarvekulud

	Select Sum(Summa) As Summa, tegev As kood1, kood As kood4, rekvid From tmpKuluTaitm ;
		WHERE Empty(KOOD2) ;
		order By tegev, kood, rekvid;
		group By tegev, kood, rekvid;
		into Cursor qryKuluTaitm


Else
	Select rekvid, kood1, kood4, Sum(Summa) As Summa, regkood, asutus, parAsutus, parregkood From tmpeelarvelaen_;
		order By parAsutus, parregkood, asutus, regkood, kood1, kood4, rekvid;
		group By parAsutus, parregkood, asutus, regkood, kood1, kood4, rekvid;
		into Cursor tmpeelarvelaen

	Select rekvid, kood1, kood4, Sum(Summa) As Summa, asutus, regkood, parAsutus, parregkood From tmpeelarvekulud_;
		order By parAsutus, parregkood, asutus, regkood, kood1, kood4, rekvid;
		group By parAsutus, parregkood, asutus, regkood, kood1, kood4, rekvid;
		into Cursor tmpeelarvekulud

	Select Sum(Summa) As Summa, tegev As kood1, kood As kood4, rekvid From tmpKuluTaitm ;
		order By tegev, kood, rekvid;
		group By tegev, kood, rekvid;
		into Cursor qryKuluTaitm

Endif
Use In 	tmpeelarvelaen_
Use In 	tmpeelarvekulud_

Use In tmpKuluTaitm

Select rekvid, tmpeelarvekulud.kood1, tmpeelarvekulud.kood4, comEelarveRemote.nimetus,;
	tmpeelarvekulud.Summa/ fltrAruanne.devide As eelarve,tmpeelarvekulud.asutus,;
	tmpeelarvekulud.regkood, tmpeelarvekulud.parAsutus, tmpeelarvekulud.parregkood;
	from tmpeelarvekulud, comEelarveRemote;
	WHERE tmpeelarvekulud.kood4 = comEelarveRemote.kood;
	into Cursor qry1

Select eelarve_report2
Append From Dbf ('qry1')
Use In qry1

Select qryKuluTaitm
Scan
	Select eelarve_report2
	Locate For rekvid = qryKuluTaitm.rekvid And Alltrim(kood4) == Alltrim(qryKuluTaitm.kood4) And;
		alltrim(kood1) == Alltrim(qryKuluTaitm.kood1)
	If Found ()
		Replace taitmine With qryKuluTaitm.Summa / fltrAruanne.devide In eelarve_report2
	Else
		Select comTegevRemote
		Locate For Alltrim(kood) == Alltrim(qryKuluTaitm.kood1)

		Select comEelarveRemote
		Locate For Alltrim(kood) == Alltrim(qryKuluTaitm.kood4)

		Select * From comrekvremote Where Id = grekv Into Cursor qry_Rekv1
		Select * From comrekvremote Where Id = qry_Rekv1.parentid Into Cursor qry_Rekv2

		Insert Into eelarve_report2 (kood1, kood4, nimetus, eelarve, asutus, regkood,parAsutus, parregkood, taitmine) Values ;
			(comTegevRemote.kood, comEelarveRemote.kood,comEelarveRemote.nimetus,0,qry_Rekv1.nimetus,;
			qry_Rekv1.regkood, qry_Rekv2.nimetus, qry_Rekv2.regkood,qryKuluTaitm.Summa / fltrAruanne.devide )

	Endif
Endscan

Select tmpeelarvelaen
Scan
	Select eelarve_report2
	Locate For rekvid = tmpeelarvelaen.rekvid And Alltrim(kood4) =  Alltrim(tmpeelarvelaen.kood4) And;
		alltrim(kood1) = Alltrim(tmpeelarvelaen.kood1)
	If Found ()
&& �������� � ��������, ��������� ����� �� �������� ����������
		lnlaen = tmpeelarvelaen.Summa /  fltrAruanne.devide
		Replace eelarve_report2.eelarve With eelarve_report2.eelarve - lnlaen,;
			laen With lnlaen In eelarve_report2
	Else
		Select comTegevRemote
		Locate For Alltrim(kood) == Alltrim(qryKuluTaitm.kood1)

		Select comEelarveRemote
		Locate For Alltrim(kood) == Alltrim(qryKuluTaitm.kood4)

		Select * From comrekvremote Where Id = grekv Into Cursor qry_Rekv1
		Select * From comrekvremote Where Id = qry_Rekv1.parentid Into Cursor qry_Rekv2
		Insert Into eelarve_report2 (kood1, kood4, nimetus, eelarve, asutus, regkood,parAsutus, parregkood, taitmine) Values ;
			(comTegevRemote.kood, comEelarveRemote.kood,comEelarveRemote.nimetus,0,qry_Rekv1.nimetus,;
			qry_Rekv1.regkood, qry_Rekv2.nimetus, qry_Rekv2.regkood,lnlaen)

	Endif
Endscan


If Used ('qry_rekv1')
	Use In qry_Rekv1
Endif
If Used ('qry_rekv2')
	Use In qry_Rekv2
Endif

Use In qryKuluTaitm
Use In tmpeelarvekulud

IF !EMPTY(fltrAruanne.tunnus)
	SELECT comTunnusremote
	LOCATE FOR ALLTRIM(kood) = ALLTRIM(fltrAruanne.tunnus)
ENDIF


Select eelarve_report2
