PARAMETERS tcWhere
tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2
tcTunnus = TRIM(UPPER(fltrAruanne.tunnus))+'%'
odb.use ('curInf3','inf3_report1')
SELECT inf3_report1




IF RECCOUNT('inf3_report1') < 1
	APPEND blank
ENDIF
