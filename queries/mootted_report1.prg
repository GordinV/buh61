Parameter cWhere
tdKpv1 = iif(!empty(fltrAruanne.kpv1), fltrAruanne.kpv1,date(year(date()),1,1))
tdKpv2 = iif(!empty(fltrAruanne.kpv2), fltrAruanne.kpv2,date())
tcAsutus = '%'
if !empty (fltrAruanne.asutusid)
	select comAsutusRemote
	locate for id = fltrAruanne.asutusid
	tcAsutus = rtrim(comAsutusRemote.nimetus)+tcAsutus
endif
create cursor mootted_report1 (kood c(20), nimetus c(120), uhik c(20), kogus n(12,3))
oDb.use ('print2leping3')
SELECT mootted_report1
APPEND FROM DBF('print2leping3')
USE IN print2leping3
IF RECCOUNT ('mootted_report1') < 1
	append blank
endif
select mootted_report1
