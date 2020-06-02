Parameter tcWhere
lcWhere = ''
WAIT WINDOW 'report start'


TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekv_id = <<fltrAruanne.asutusid>>)
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
ENDTEXT
WAIT WINDOW 'report'

lError = oDb.readFromModel('aruanned\eelarve\tegev_eelnou', 'tegev_eelnou', 'fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve täitmine')
	Set Step On
	Select 0
	Return .F.
Endif

SELECT * ;
	from tmpReport ;
	ORDER BY parentAsutus, asutus, tegev ; 
	INTO Cursor eelarve_report1

Use In tmpReport
Select eelarve_report1

