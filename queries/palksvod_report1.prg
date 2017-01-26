Parameter tcWhere
if !empty (fltrAruanne.asutusId)
	tnIsikId1 = fltrAruanne.asutusId
	tnIsikId2 = fltrAruanne.asutusId
else
	tnIsikId1 = 0
	tnIsikId2 = 999999999
endif
tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2
oDb.use ('qryPalkSvod')

create cursor palksvod_report1 (nimetus c(120), summa y, liik c(1))
index on liik tag liik
set order to liik
IF RECCOUNT ('qryPalkSvod') > 0
	append from dbf ('qryPalkSvod')
else
	APPEND BLANK
ENDIF
use in qryPalkSvod
select palksvod_report1
