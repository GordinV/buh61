Parameter cWhere
tcKood = '%'+ltrim(rtrim(fltrLaduJaak.kood))+'%'
tcNimetus = '%'+ltrim(rtrim(fltrLaduJaak.nimetus))+'%'
tcGrupp = '%'+ltrim(rtrim(fltrLaduJaak.grupp))+'%'
tcUhik = '%%'
tnHind1 = fltrLaduJaak.hind1
tnHind2 = fltrLaduJaak.hind2
tnJaak1 = fltrLaduJaak.jaak1
tnJaak2 = fltrLaduJaak.jaak2

oDb.use('curLaduJaak','Ladujaak_report1')
&&use (cQuery) in 0 alias arve_report2
select Ladujaak_report1
