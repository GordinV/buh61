Parameter cWhere
create cursor eelarve_report3 (a21 y, a22 y, a23 y, a24 y, a25 y, a26 y, a27 y, a28 y,a29 y, a34 y, muud y, kokku y,;
	asutus c(254), regkood c(254),	parAsutus c(254), parregkood c(20), rekvid int)
index on left(ltrim(rtrim(parregkood)),11)+left(ltrim(rtrim(regkood)),11) tag idx1 
set order to idx1
		
if !empty (fltrAruanne.asutusid)
	select comrekvremote
	locate for id = fltrAruanne.asutusid
	tcAsutus = ltrim(rtrim(comrekvRemote.nimetus)) + '%'
else
	tcAsutus = '%'
endif
tnTunnus = fltrAruanne.tunn
tcArtikkel = ltrim(rtrim(fltrAruanne.kood4))+'%'
tcTegev = ltrim(rtrim(fltrAruanne.kood1))+'%'
tcAllikas = ltrim(rtrim(fltrAruanne.kood2))+'%'
tnAasta1 = 	year (fltrAruanne.kpv1)
tnAasta2 = 	YEAR(fltrAruanne.kpv2)
IF EMPTY(fltrAruanne.kond)
	tnParent = 3
ELSE
	tnParent = 1
ENDIF

oDb.use ('CURKULUDSVOD1', 'tmpeelarvekulud')
select tmpeelarvekulud
scan
	select eelarve_report3
	locate for rekvid = tmpeelarvekulud.rekvid
	if !found ()
		insert into eelarve_report3 (REKVID, asutus, regkood, parAsutus, parregkood) values ;
			(tmpeelarvekulud.REKVID, tmpeelarvekulud.asutus, tmpeelarvekulud.regkood, tmpeelarvekulud.parAsutus,tmpeelarvekulud.parregkood) 
	endif
	do case
		case tmpeelarvekulud.artikkel = '21'
				replace eelarve_report3.a21 with eelarve_report3.a21+ tmpeelarveKulud.summa /fltrAruanne.devide in eelarve_report3 
		case tmpeelarvekulud.artikkel = '22'
				replace eelarve_report3.a22 with eelarve_report3.a22/fltrAruanne.devide + tmpeelarveKulud.summa/fltrAruanne.devide in eelarve_report3 
		case tmpeelarvekulud.artikkel = '23'
				replace eelarve_report3.a23 with eelarve_report3.a23/fltrAruanne.devide + tmpeelarveKulud.summa/fltrAruanne.devide in eelarve_report3 
		case tmpeelarvekulud.artikkel = '24'
				replace eelarve_report3.a24 with eelarve_report3.a24/fltrAruanne.devide+ tmpeelarveKulud.summa/fltrAruanne.devide in eelarve_report3 
		case tmpeelarvekulud.artikkel = '25'
				replace eelarve_report3.a25 with eelarve_report3.a25/fltrAruanne.devide+ tmpeelarveKulud.summa/fltrAruanne.devide in eelarve_report3 
		case tmpeelarvekulud.artikkel = '26'
				replace eelarve_report3.a26 with eelarve_report3.a26/fltrAruanne.devide+ tmpeelarveKulud.summa/fltrAruanne.devide in eelarve_report3 
		case tmpeelarvekulud.artikkel = '27'
				replace eelarve_report3.a27 with eelarve_report3.a27/fltrAruanne.devide+ tmpeelarveKulud.summa/fltrAruanne.devide in eelarve_report3 
		case tmpeelarvekulud.artikkel = '28'
				replace eelarve_report3.a28 with eelarve_report3.a28/fltrAruanne.devide+ tmpeelarveKulud.summa/fltrAruanne.devide in eelarve_report3 
		case tmpeelarvekulud.artikkel = '29'
				replace eelarve_report3.a29 with eelarve_report3.a29/fltrAruanne.devide + tmpeelarveKulud.summa/fltrAruanne.devide in eelarve_report3 
		case tmpeelarvekulud.artikkel = '34'
				replace eelarve_report3.a34 with eelarve_report3.a34/fltrAruanne.devide+ tmpeelarveKulud.summa/fltrAruanne.devide in eelarve_report3 
		otherwise 
				replace eelarve_report3.muud with eelarve_report3.muud/fltrAruanne.devide+ tmpeelarveKulud.summa/fltrAruanne.devide in eelarve_report3 
	ENDCASE
	replace eelarve_report3.kokku with eelarve_report3.kokku+ tmpeelarveKulud.summa/fltrAruanne.devide in eelarve_report3 
	
endscan
use in tmpEelarveKulud
select eelarve_report3