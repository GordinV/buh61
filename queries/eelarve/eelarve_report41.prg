Parameter cWhere
Create Cursor eelarve_report2 (rekvid Int, tegev c(20), artikkel c(20), nimetus c(254), eelarve Y, taitmine Y, asutus c(254), regkood c(254),;
	parAsutus c(254), parregkood c(20), tunnus c(20), tunNimi c(254))
Index On '1'+'-'+tegev+'-'+tunnus Tag idx1
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
tckOOD = Ltrim(Rtrim(fltrAruanne.KOOD4))+'%'
tctegev = Ltrim(Rtrim(fltrAruanne.KOOD1))+'%'
tcValuuta = '%'
IF EMPTY(fltrAruanne.kond)
	tnParent = 3
ELSE
	tnParent = 1
ENDIF

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

IF tnTunnus > 0 
	tdKpv = fltrAruanne.kpv
ELSE
	tdKpv = DATE(1900,01,01)
ENDIF

With oDb
	.Use ('CUREELARVEKULUD', 'tmpeelarvekulud_')
	.Use ('curKuluTaitm','tmpKuluTaitm',.T.)
	.dbreq ('tmpKuluTaitm',gnhandle,IIF(fltrAruanne.kassakulud = 1,'curKassaTuluTaitm','curFaktTuluTaitm'))
Endwith
If gVersia = 'VFP'
	If  Used('curKassaKuludeTaitmine_')
		Use In curKassaKuludeTaitmine_
	Endif
Endif

Select KOOD1, Sum(Summa*kuurs) As Summa, tun As  tunnus  From tmpeelarvekulud_;
	group By   KOOD1, tun;
	order By   KOOD1, tun;
	into Cursor tmpeelarvekulud
Use In 	tmpeelarvekulud_

Select Sum(Summa) As Summa, tegev, tun As tunnus From tmpKuluTaitm ;
	group By tegev, tun;
	order By tegev, tun;
	into Cursor qryKuluTaitm
Use In tmpKuluTaitm

Select tmpeelarvekulud
Scan
	Select comTegevRemote
	Locate For kood = tmpeelarvekulud.KOOD1
	lnTaitm = 0
	lcTunnus = ''
	If !Empty(tmpeelarvekulud.tunnus)
		Select comTunnusRemote
		If Tag() <> 'KOOD'
			Set Order To kood
		Endif
		Seek tmpeelarvekulud.tunnus
		lcTunnus = comTunnusRemote.nimetus
	Endif

	Insert Into eelarve_report2 (tunnus, tunNimi, tegev, nimetus, eelarve, taitmine) Values ;
		(tmpeelarvekulud.kood1, lcTunnus, comTegevRemote.kood,comTegevRemote.nimetus,tmpeelarvekulud.Summa /fltrAruanne.devide,lnTaitm )
Endscan
Select qryKuluTaitm
Scan
	Select eelarve_report2
	Locate For  tegev = qryKuluTaitm.tegev And tunnus = qryKuluTaitm.tunnus
	If Found()
		Replace taitmine With qryKuluTaitm.Summa /fltrAruanne.devide
	Else
		Select comTegevRemote
		IF TAG() <> 'KOOD'
			SET ORDER TO kood
		ENDIF
		seek qryKuluTaitm.tegev 
*!*			If Found()
*!*				lnTaitm = qryKuluTaitm.Summa /fltrAruanne.devide
*!*			Else
*!*				lnTaitm = 0
*!*			Endif
		lcTunnus = ''
		If !Empty(qryKuluTaitm.tunnus)
			Select comTunnusRemote
			If Tag() <> 'KOOD'
				Set Order To kood
			Endif
			Seek qryKuluTaitm.tunnus
			lcTunnus = comTunnusRemote.nimetus
		Endif

		Insert Into eelarve_report2 (tunnus, tunNimi, tegev, nimetus, taitmine) Values ;
			(qryKuluTaitm.tunnus, lcTunnus, comTegevRemote.kood,comTegevRemote.nimetus,qryKuluTaitm.Summa /fltrAruanne.devide )
	Endif
Endscan


Use In qryKuluTaitm
Use In tmpeelarvekulud

IF !EMPTY(fltrAruanne.tunnus)
	SELECT comTunnusremote
	LOCATE FOR ALLTRIM(kood) = ALLTRIM(fltrAruanne.tunnus)
ENDIF


Select eelarve_report2
If Reccount('eelarve_report2') < 1
	Append Blank
Endif

