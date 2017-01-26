Parameter cWhere
tcAsutus = ltrim(rtrim(fltrKuluTaitm.asutus))+'%'
tcKood = ltrim(rtrim(fltrKuluTaitm.kood))+'%'
tcTegev = ltrim(rtrim(fltrKuluTaitm.tegev))+'%'
tcEelarve = ltrim(rtrim(fltrKuluTaitm.eelarve))+'%'
tcNimetus = '%'+ltrim(rtrim(fltrKuluTaitm.nimetus))+'%'
tnSumma1 = 	fltrKuluTaitm.summa1
tnSumma2 = 	iif (empty (fltrKuluTaitm.summa2),999999999.99,fltrKuluTaitm.summa2)
tnKuu1 = 	fltrKuluTaitm.kuu1
tnKuu2 = 	iif (empty (fltrKuluTaitm.kuu2),YEAR(date()),fltrKuluTaitm.kuu2)
tnAasta1 = 	fltrKuluTaitm.aasta1
tnAasta2 = 	iif (empty (fltrKuluTaitm.aasta2),YEAR(date()),fltrKuluTaitm.aasta2)
tcTunnus = ltrim(rtrim(fltrKuluTaitm.tunnus))+'%'
tcKood2 = ltrim(rtrim(fltrKuluTaitm.kood2))+'%'

IF EMPTY(fltrAruanne.kond)
	tnParent = 3
ELSE
	tnParent = 1
ENDIF


Select curKuluTaitm

lError = odb.use (iif (oKulutaitm.pAGeframe1.ActivePage = 1,'curKassaTuluTaitm','curKassaKuluTaitm'),'qryEelaTaitm')
IF gversia = 'VFP' AND USED('curkassakuludetaitmine_')
	USE IN curkassakuludetaitmine_
endif
IF gversia = 'VFP' AND USED('curkassatuludetaitmine_')
	USE IN curkassatuludetaitmine_
endif
SELECT qryEelaTaitm.kuu, qryEelaTaitm.aasta, qryEelaTaitm.rekvid, qryEelaTaitm.summa,;
	qryEelaTaitm.tegev,qryEelaTaitm.kood, qryEelaTaitm.TUN, comEelarveRemote.nimetus, comRekvRemote.nimetus as asutus ;
	from qryEelaTaitm INNER JOIN comEelarveRemote ON qryEelaTaitm.kood =  comEelarveRemote.kood;
	INNER JOIN comRekvRemote ON qryEelaTaitm.rekvId = comRekvRemote.id;
	INTO CURSOR KuluTaitm_report1

USE IN qryEelaTaitm


if lError = .f.
	glError = .t.
	SELECT 0
	return .f.
ENDIF

IF !EMPTY(fltrKuluTaitm.tunnus)
	SELECT comTunnusremote
	LOCATE FOR ALLTRIM(kood) = ALLTRIM(fltrKuluTaitm.tunnus)
ENDIF


Select KuluTaitm_report1
