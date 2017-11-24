Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif
tnId = cWhere
oDb.use('v_Asutus','Asutus_report1')
select Asutus_report1
