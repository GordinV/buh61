Parameter tcWhere
if !used('fltrTaabel1')
	return .f.
endif
tcOsakond = '%'+rtrim(ltrim(fltrTaabel1.Osakond))+'%'
tcAmet = '%'+rtrim(ltrim(fltrTaabel1.amet))+'%'
tcisik = '%'+rtrim(ltrim(fltrTaabel1.Isik))+'%'
tnKokku1 = fltrTaabel1.Kokku1
tnKokku2 = iif(empty(fltrTaabel1.Kokku2),999,fltrTaabel1.Kokku2)
tnToo1 = fltrTaabel1.too1
tnToo2 = iif(empty(fltrTaabel1.Too2),999,fltrTaabel1.Too2)
tnPuhk1 = fltrTaabel1.puhk1
tnPuhk2 = iif(empty(fltrTaabel1.puhk2),999,fltrTaabel1.Puhk2)
tnKuu1 = fltrTaabel1.kuu1
tnKuu2 = iif(empty(fltrTaabel1.Kuu2),999,fltrTaabel1.Kuu2)
tnAasta1 = fltrTaabel1.aasta1
tnAasta2 = iif(empty(fltrTaabel1.Aasta2),999,fltrTaabel1.Aasta2)
oDb.use(IIF(empty (fltrTaabel1.status),'curTaabel1','curTaabel2'),'Taabel1_report1')
select taabel1_report1
INDEX ON UPPER(LEFT(isik,40))+'-'+STR(aasta,4)+'-'+STR(kuu,2) TAG kood
SET ORDER TO kood
