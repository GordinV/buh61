Parameter cWhere
Create Cursor eelarve_report2 (rekvid Int, tegev c(20), kood c(20), nimetus c(254), eelarve Y, taitmine Y, asutus c(254), regkood c(254),;
	parAsutus c(254), parregkood c(20), tunnus c(20))
Index On Left(Ltrim(Rtrim(parregkood)),11)+'-'+Left(Ltrim(Rtrim(regkood)),11)+'-'+Alltrim(kood) Tag idx1
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
tckOOD = Iif (Empty(fltrAruanne.KOOD4),'3',Ltrim(Rtrim(fltrAruanne.KOOD4)))+'%'
tctegev = Ltrim(Rtrim(fltrAruanne.KOOD1))+'%'
tcValuuta = '%'
IF EMPTY(fltrAruanne.kond)
	tnParent = 3
ELSE
	tnParent = 1
ENDIF

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
	tdKpv = DATE(1900,01,01)
ENDIF
IF !EMPTY(fltrAruanne.kond)
	tnParent = 3
ELSE
	tnParent = 1
ENDIF

With oDb
	.Use ('CUREELARVE', 'tmpeelarvetulud1')
	.Use (IIF(fltrAruanne.kassakulud = 1,'curKassaTuluTaitm','curFaktTuluTaitm'),'tmpTuluTaitm')
Endwith
If gVersia = 'VFP'
	If  Used('curKassaTuludeTaitmine_')
		Use In curKassaTuludeTaitmine_
	Endif

Endif

*APPEND FROM DBF('comKontodRemote') FOR LEN(ALLTRIM(kood)) < 6 AND LEFT(ALLTRIM(kood),1) = '3'
If !Empty(fltrAruanne.kohalik)
	Select rekvid,  KOOD4, KOOD5, Sum(Summa*kuurs) As Summa, asutus, regkood,parAsutus, parregkood ;
		from tmpeelarvetulud1;
		WHERE Empty(KOOD2);
		order By rekvid, KOOD4, KOOD5,asutus, regkood, parAsutus, parregkood ;
		group By rekvid, KOOD4, KOOD5,asutus, regkood, parAsutus, parregkood ;
		into Cursor tmpeelarvetulud


	Select Sum(Summa)  As Summa, kood, eelarve, rekvid From tmpTuluTaitm ;
		WHERE Empty(KOOD2);
		order By rekvid, kood, eelarve;
		group By rekvid, kood, eelarve;
		into Cursor qryTuluTaitm

Else
	Select rekvid, KOOD4, KOOD5, Sum(Summa*kuurs) As Summa, asutus, regkood,parAsutus, parregkood ;
		from tmpeelarvetulud1;
		order By rekvid, KOOD4, KOOD5,asutus, regkood, parAsutus, parregkood ;
		group By rekvid, KOOD4, KOOD5,asutus, regkood, parAsutus, parregkood ;
		into Cursor tmpeelarvetulud


	Select Sum(Summa)  As Summa, kood, eelarve,  rekvid From tmpTuluTaitm ;
		order By rekvid, kood,  eelarve;
		group By rekvid, kood,  eelarve;
		into Cursor qryTuluTaitm

Endif


Use In tmpeelarvetulud1

Use In tmpTuluTaitm


Select tmpeelarvetulud
brow
Scan
	Select comEelarveRemote
	Locate For ALLTRIM(kood) = ALLTRIM(tmpeelarvetulud.KOOD4)
	lnTaitm = 0
	Select * From comrekvremote Where Id = tmpeelarvetulud.rekvid Into Cursor qry_Rekv1
	Select * From comrekvremote Where Id = qry_Rekv1.parentid Into Cursor qry_Rekv2

	Insert Into eelarve_report2 (rekvid,  kood, nimetus, rekvid, eelarve, taitmine, asutus, regkood, parAsutus, parregkood) Values;
		(tmpeelarvetulud.rekvid,  tmpeelarvetulud.KOOD4, comEelarveRemote.nimetus,tmpeelarvetulud.rekvid, ;
		tmpeelarvetulud.Summa/fltrAruanne.devide, lnTaitm, qry_Rekv1.nimetus,;
		qry_Rekv1.regkood, qry_Rekv2.nimetus, qry_Rekv2.regkood )
Endscan

Select qryTuluTaitm
Scan
	Select eelarve_report2
	Locate For ALLTRIM(kood) = ALLTRIM(qryTuluTaitm.kood) And rekvid = qryTuluTaitm.rekvid
	If Found()
		Replace taitmine With  qryTuluTaitm.Summa /fltrAruanne.devide In eelarve_report2
	Else
		Select comEelarveRemote
		Locate For kood = qryTuluTaitm.kood
		Select * From comrekvremote Where Id = qryTuluTaitm.rekvid Into Cursor qry_Rekv1
		Select * From comrekvremote Where Id = qry_Rekv1.parentid Into Cursor qry_Rekv2
		Insert Into eelarve_report2 (rekvid,  kood, nimetus, rekvid, eelarve, taitmine, asutus, regkood, parAsutus, parregkood) Values;
			(qryTuluTaitm.rekvid,  qryTuluTaitm.kood, comEelarveRemote.nimetus,qryTuluTaitm.rekvid, ;
			0, qryTuluTaitm.Summa/fltrAruanne.devide, qry_Rekv1.nimetus,;
			qry_Rekv1.regkood, qry_Rekv2.nimetus, qry_Rekv2.regkood )
	Endif
Endscan


If Used ('qry_rekv1')
	Use In qry_Rekv1
Endif
If Used ('qry_rekv2')
	Use In qry_Rekv2
Endif
Use In qryTuluTaitm
Use In tmpeelarvetulud

IF !EMPTY(fltrAruanne.tunnus)
	SELECT comTunnusremote
	LOCATE FOR ALLTRIM(kood) = ALLTRIM(fltrAruanne.tunnus)
ENDIF



Select eelarve_report2
If Reccount()< 1
	Append Blank
Endif
