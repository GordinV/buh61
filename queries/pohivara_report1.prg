Parameter cWhere

tcKood = '%'+ltrim(rtrim(fltrPohivara.kood))+'%'
tcNimetus = '%'+ltrim(rtrim(fltrPohivara.nimetus))+'%'
tcKonto = '%'+ltrim(rtrim(fltrPohivara.konto))+'%'
tcVastIsik = '%'+ltrim(rtrim(fltrPohivara.vastisik))+'%'
tcGrupp = '%'+ltrim(rtrim(fltrPohivara.grupp))+'%'
tnSoetmaks1 = fltrPohivara.Soetmaks1
tnSoetmaks2 = fltrPohivara.Soetmaks2
tdSoetkpv1 = fltrPohivara.soetkpv1
tdSoetkpv2 = fltrPohivara.soetkpv2
tnTunnus = fltrPohivara.tunnus
tcRentnik = '%'+TRIM(fltrPohivara.rentnik)+'%'

oDb.use('curPohivara','pohivara_report1')
SELECT pohivara_report1
index ON LEFT(LTRIM(RTRIM(GRUPP)),40)+'-'+LEFT(LTRIM(RTRIM(KOOD)),20) TAG KOOD
SET ORDER TO KOOD
*!*	*set order to gruppId



select pohivara_report1