Parameter cWhere
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
create cursor muuk_report1 (kood c(20), nimetus c(254), GRUPP C(254),;
	kogus y, summa y, paevad int default fltrAruanne.kpv2 - fltrAruanne.kpv1)
index on left(ltrim(rtrim(grupp))+ltrim(rtrim(kood)),20) tag kood
set order to kood
dKpv1 =  fltrAruanne.kpv1
dkpv2 = fltrAruanne.kpv2
tnNom1 = fltrAruanne.kood3
tnNom2 = iif (!empty (fltrAruanne.kood3),fltrAruanne.kood3,9999999999)
oDb.use ('curMuuk')
select muuk_report1
if reccount ('curMuuk') > 0
	append from dbf ('curMuuk')	
else
	append blank
endif
use in curMuuk
