Parameter cWhere
Create Cursor eelarve_report2 (rekvid Int, tegev c(20), artikkel c(20), nimetus c(254), eelarve Y, taitmine Y, asutus c(254), regkood c(254),;
	parAsutus c(254), parregkood c(20))
Index On Left(Ltrim(Rtrim(parregkood)),11)+Left(Ltrim(Rtrim(regkood)),11)+Alltrim(tegev) Tag idx1
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
tckOOD2 = Ltrim(Rtrim(fltrAruanne.KOOD2))+'%'
tckOOD4 = Ltrim(Rtrim(fltrAruanne.KOOD4))+'%'
tckOOD5 = Ltrim(Rtrim(fltrAruanne.KOOD5))+'%'
tckOOD = Ltrim(Rtrim(fltrAruanne.KOOD5))+'%'
tctegev = Ltrim(Rtrim(fltrAruanne.KOOD1))+'%'
tcEelarve = '%'
tcNimetus = '%'
tcValuuta = '%'
tnSumma1 = 	-999999999.99
tnSumma2 = 	999999999.99
tnAasta1 = 	Year (fltrAruanne.kpv1)
tnAasta2 = 	Year(fltrAruanne.kpv2)
tnKuu1 = 	Month(fltrAruanne.kpv1)
tnKuu2 = 	Month(fltrAruanne.kpv2)
IF tnKuu1 = 1 
	tnKuu1= 0
endif
IF EMPTY(fltrAruanne.kond)
	tnParent = 3
ELSE
	tnParent = 1
ENDIF

IF tnTunnus > 0 
	tdKpv = fltrAruanne.kpv
ELSE
	tdKpv = DATE(1900,01,01)
ENDIF
*SET STEP ON 
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
If fltrAruanne.kohalik = 1
* ������ ������� ������
	Select rekvid, KOOD1, Sum(Summa*kuurs) As Summa, asutus, regkood, parAsutus, parregkood From tmpeelarvekulud_;
		WHERE Empty(tmpeelarvekulud_.KOOD2) ;
		order By parAsutus, parregkood, asutus, regkood,rekvid,  KOOD1;
		group By parAsutus, parregkood, asutus, regkood,rekvid,  KOOD1;
		into Cursor tmpeelarvekulud


	Select Sum(Summa) As Summa, tegev, rekvid From tmpKuluTaitm ;
		WHERE Empty(KOOD2);
		order By tegev, rekvid;
		group By tegev, rekvid;
		into Cursor qryKuluTaitm


Else
	Select rekvid, KOOD1, Sum(Summa*kuurs) As Summa, asutus, regkood, parAsutus, parregkood From tmpeelarvekulud_;
		order By parAsutus, parregkood, asutus, regkood,rekvid,  KOOD1;
		group By parAsutus, parregkood, asutus, regkood,rekvid,  KOOD1;
		into Cursor tmpeelarvekulud

	Select Sum(Summa) As Summa, tegev, rekvid From tmpKuluTaitm ;
		order By tegev, rekvid;
		group By tegev, rekvid;
		into Cursor qryKuluTaitm

Endif

Use In 	tmpeelarvekulud_

Use In tmpKuluTaitm

Select tmpeelarvekulud
Scan
	Select comTegevRemote
	Locate For kood = tmpeelarvekulud.KOOD1
	lnTaitm = 0
	Select * From comrekvremote Where Id = tmpeelarvekulud.rekvid Into Cursor qry_Rekv1
	Select * From comrekvremote Where Id = qry_Rekv1.parentid Into Cursor qry_Rekv2

	Insert Into eelarve_report2 (rekvid, tegev, nimetus, eelarve, asutus, regkood,parAsutus, parregkood, taitmine) Values ;
		(tmpeelarvekulud.rekvid, comTegevRemote.kood,comTegevRemote.nimetus,tmpeelarvekulud.Summa /fltrAruanne.devide,qry_Rekv1.nimetus,;
		qry_Rekv1.regkood, qry_Rekv2.nimetus, qry_Rekv2.regkood,lnTaitm )
Endscan
Select qryKuluTaitm
Scan
	Select eelarve_report2
	Locate For  tegev = qryKuluTaitm.tegev And rekvid = qryKuluTaitm.rekvid
	If Found()
		Replace taitmine With qryKuluTaitm.Summa /fltrAruanne.devide
	Else
		Select comTegevRemote
		Locate For kood = qryKuluTaitm.tegev
		If Found()
			lnTaitm = qryKuluTaitm.Summa /fltrAruanne.devide
		Else
			lnTaitm = 0
		Endif
		Select * From comrekvremote Where Id = qryKuluTaitm.rekvid Into Cursor qry_Rekv1
		Select * From comrekvremote Where Id = qry_Rekv1.parentid Into Cursor qry_Rekv2

		Insert Into eelarve_report2 (rekvid, tegev, nimetus, eelarve, asutus, regkood,parAsutus, parregkood, taitmine) Values ;
			(qryKuluTaitm.rekvid, comTegevRemote.kood,comTegevRemote.nimetus,0,qry_Rekv1.nimetus,;
			qry_Rekv1.regkood, qry_Rekv2.nimetus, qry_Rekv2.regkood,lnTaitm )
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
DELETE FOR EMPTY(eelarve) and EMPTY(taitmine) 



If Reccount('eelarve_report2') < 1
	Append Blank
Endif
