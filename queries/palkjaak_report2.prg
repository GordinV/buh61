Parameter tcWhere

If used('fltrPalkJaak')
	tcNimetus = '%'+rtrim(ltrim(fltrPalkJaak.nimetus))+'%'
	tnKuu1 = iif(empty(fltrPalkJaak.kuu1),0,fltrPalkJaak.kuu1)
	tnKuu2 = iif(empty(fltrPalkJaak.kuu2),12,fltrPalkJaak.kuu2)
	tnAasta1 = iif(empty(fltrPalkJaak.aasta1),0,fltrPalkJaak.aasta1)
	tnAasta2 = iif(empty(fltrPalkJaak.aasta2),9999,fltrPalkJaak.aasta2)
	tnArv1 = iif(empty(fltrPalkJaak.arv1),-999999999,fltrPalkJaak.arv1)
	tnArv2 = iif(empty(fltrPalkJaak.arv2),999999999,fltrPalkJaak.arv2)
	tnKinni1 = iif(empty(fltrPalkJaak.kinni1),-999999999,fltrPalkJaak.kinni1)
	tnKinni2 = iif(empty(fltrPalkJaak.kinni2),999999999,fltrPalkJaak.kinni2)
	tnTulu1 = iif(empty(fltrPalkJaak.Tulu1),-999999999,fltrPalkJaak.Tulu1)
	tnTulu2 = iif(empty(fltrPalkJaak.Tulu2),999999999,fltrPalkJaak.Tulu2)
	tnSots1 = iif(empty(fltrPalkJaak.Sots1),-999999999,fltrPalkJaak.Sots1)
	tnSots2 = iif(empty(fltrPalkJaak.Sots2),999999999,fltrPalkJaak.Sots2)
	tnJaak1 = iif(empty(fltrPalkJaak.Jaak1),-999999999,fltrPalkJaak.Jaak1)
	tnJaak2 = iif(empty(fltrPalkJaak.Jaak2),999999999,fltrPalkJaak.Jaak2)
	tnParent = 3
Else
	if !empty (fltrAruanne.asutusid)
		select comAsutusRemote
		locate for id = fltrAruanne.asutusid
		tcNimetus = ltrim(rtrim(comAsutusRemote.nimetus))+'%'
	else
		tcNimetus = '%'
	endif
	tnKuu1 = iif(empty(fltrAruanne.kpv1),0,month(fltrAruanne.kpv1))
	tnKuu2 = iif(empty(fltrAruanne.kpv2),12,month(fltrAruanne.kpv2))
	tnAasta1 = iif(empty(fltrAruanne.kpv1),0,year(fltrAruanne.kpv1))
	tnAasta2 = iif(empty(fltrAruanne.kpv2),9999,year(fltrAruanne.kpv2))
	tnArv1 = -999999999
	tnArv2 = 999999999
	tnKinni1 = -999999999
	tnKinni2 = 999999999
	tnTulu1 = -999999999
	tnTulu2 = 999999999
	tnSots1 = -999999999
	tnSots2 = 999999999
	tnJaak1 = -999999999
	tnJaak2 = 999999999
IF EMPTY(fltrAruanne.kond)
	tnParent = 3
ELSE
	tnParent = 1
ENDIF

Endif
tcOsakond = '%'
tcAmet = '%'
tcisik = tcNimetus
tnKokku1 = 0
tnKokku2 = 999
tnToo1 = 0
tnToo2 = 999
tnPuhk1 = 0
tnPuhk2 = 999
tnParentRekvId = 9

With oDb
	.use('curTaabel1','tmpTaabel1')
	.use('curPalkJaak','tmpPalkJaak')
Endwith
Select isik, arvestatud as arv, tulumaks, sotsmaks, tka, tki, kinni, workdays (1,tmpPalkJaak.kuu,tmpPalkJaak.aasta) as tpaevad,  ;
	maxdays (tmpPalkJaak.kuu, tmpPalkJaak.aasta) as kpaevad, iif(isnull(tmpTaabel1.kokku),;
	maxdays (tmpPalkJaak.kuu, tmpPalkJaak.aasta),tmpTaabel1.kokku) as kokku, g31 ;
	from tmpPalkJaak  left outer join tmpTaabel1 on (left(tmpTaabel1.isik,120) = left(tmpPalkJaak.nimetus,120);
	and tmpTaabel1.kuu = tmpPalkJaak.kuu and tmpTaabel1.aasta = tmpPalkJaak.aasta);
	into cursor tmpPalkJaak1
Use in tmpTaabel1
Use in tmpPalkJaak
Select isik, sum (arv) as arv, sum (tulumaks) as tulumaks, sum (sotsmaks) as sotsmaks, sum (tki) as tki,;
	sum (tka) as tka, sum (kinni) as kinni, sum (tpaevad) as tpaevad, sum (kpaevad) as kpaevad, sum(kokku) as kokku, sum(g31) as g31;
	from tmpPalkJaak1;
	where !isnull(isik);
	order by isik;
	group by isik;
	into cursor palkstat_report1
Use in tmpPalkJaak1
Select palkstat_report1

Function maxdays
	Parameter tnKuu, tnAasta
	Return day (gomonth(date (tnAasta, tnKuu,1),1)-1)

