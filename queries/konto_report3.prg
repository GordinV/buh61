Parameter cWhere
local lnrecno
lnRecno = 0
tcKood = ltrim(rtrim(fltrKontod.kood))+'%'
tcNimetus = '%'+ltrim(rtrim(fltrKontod.nimetus))+'%'
oDb.use('printkontod1','konto_report1')
select konto_report1
go top