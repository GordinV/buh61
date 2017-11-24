Parameter cWhere
create cursor eelarve_report4 (artikkel c(20),nimetus c(254),eelaasta1 y,taitmaasta1 y,  ;
	eelaasta2 y, taitmaasta2 y, eelaasta3 y, taitmaasta3 y,;
	asutus c(254), regkood c(254),	parAsutus c(254), parregkood c(20), rekvid int, opt int)
index on left(ltrim(rtrim(parregkood)),11)+left(ltrim(rtrim(regkood)),11) +str(opt,1)+ltrim(rtrim(artikkel)) tag idx1 
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
if used ('qryKuluTaitmSvod1')
	use in qryKuluTaitmSvod1
ENDIF
IF EMPTY(fltrAruanne.kond)
	tnParent = 3
ELSE
	tnParent = 1
ENDIF


with oDb
	.use ('CURKULUDSVOD1', 'tmpeelarvekulud')
	if fltrAruanne.kassakulud = 0
		.use ('qryKuluTaitmSvod1')
	else
		.use ('qryKassaKuluTaitmSvod1','qryKuluTaitmSvod1')
	endif
	.use ('curTuluSvod1','curTuludSvod1')
	.use ('qryTuluTaitmSvod1')
endwith

select tmpeelarvekulud

scan
	select eelarve_report4
	locate for rekvid = tmpeelarvekulud.rekvid and artikkel = tmpeelarvekulud.artikkel
	if !found ()
		select comEelarveremote
		locate for kood = tmpeelarvekulud.artikkel
		insert into eelarve_report4 (artikkel, nimetus, REKVID, asutus, regkood, parAsutus, parregkood,opt) values ;
			(tmpeelarvekulud.artikkel,comEelarveremote.nimetus, tmpeelarvekulud.REKVID, tmpeelarvekulud.asutus, ;
			tmpeelarvekulud.regkood, tmpeelarvekulud.parAsutus,tmpeelarvekulud.parregkood,;
			iif (tmpeelarvekulud.artikkel = '23',1,0)) 
	endif
	do case
		case tmpeelarvekulud.aasta = year (fltrAruanne.kpv2)
				replace eelarve_report4.eelaasta1 with eelarve_report4.eelaasta1/fltrAruanne.devide+; 
					tmpeelarveKulud.summa in eelarve_report4 
				select qryKuluTaitmSvod1
				locate for rekvid = tmpeelarvekulud.rekvid and ;
					artikkel = tmpeelarvekulud.artikkel and aasta = year (fltrAruanne.kpv2) 
				if found ()
					replace eelarve_report4.taitmaasta1 with eelarve_report4.taitmaasta1/fltrAruanne.devide+; 
						qryKuluTaitmSvod1.summa in eelarve_report4 
				endif
		case tmpeelarvekulud.aasta = year (fltrAruanne.kpv2) - 1
				replace eelarve_report4.eelaasta2 with eelarve_report4.eelaasta2/fltrAruanne.devide+; 
					tmpeelarveKulud.summa in eelarve_report4 
				select qryKuluTaitmSvod1
				locate for rekvid = tmpeelarvekulud.rekvid and ;
					artikkel = tmpeelarvekulud.artikkel and aasta = year (fltrAruanne.kpv2) - 1 
				if found ()
					replace eelarve_report4.taitmaasta2 with eelarve_report4.taitmaasta2/fltrAruanne.devide+; 
						qryKuluTaitmSvod1.summa in eelarve_report4 
				endif
		case tmpeelarvekulud.aasta = year (fltrAruanne.kpv2) - 2
				replace eelarve_report4.eelaasta3 with eelarve_report4.eelaasta3/fltrAruanne.devide+; 
					tmpeelarveKulud.summa in eelarve_report4 
				select qryKuluTaitmSvod1
				locate for rekvid = tmpeelarvekulud.rekvid and ;
					artikkel = tmpeelarvekulud.artikkel and aasta = year (fltrAruanne.kpv2) 
				if found ()
					replace eelarve_report4.taitmaasta3 with eelarve_report4.taitmaasta3/fltrAruanne.devide+; 
						qryKuluTaitmSvod1.summa in eelarve_report4 
				endif
	endcase
endscan
select curTuludSvod1
scan
	select eelarve_report4
	locate for rekvid = curTuludSvod1.rekvid and nimetus = 'Tulud'
	if !found ()
		select tmpEelarveKulud
		locate for rekvid = curTuludSvod1.rekvid
		insert into eelarve_report4 (artikkel, nimetus, REKVID, asutus, regkood, parAsutus, parregkood,opt) values ;
			(space(20),'Tulud', curTuludSvod1.REKVID, tmpeelarvekulud.asutus, ;
			tmpeelarvekulud.regkood, tmpeelarvekulud.parAsutus,tmpeelarvekulud.parregkood,2)
	endif
	do case
		case curTuludSvod1.aasta = year (fltrAruanne.kpv2)
				replace eelarve_report4.eelaasta1 with eelarve_report4.eelaasta1/fltrAruanne.devide+; 
					curTuludSvod1.summa in eelarve_report4 
				select qryTuluTaitmSvod1
				locate for qryTuluTaitmSvod1.rekvid = curTuludSvod1.rekvid and qryTuluTaitmSvod1.aasta = year (fltrAruanne.kpv2) 
				if found ()
					replace eelarve_report4.taitmaasta1 with eelarve_report4.taitmaasta1/fltrAruanne.devide+; 
						qryTuluTaitmSvod1.summa in eelarve_report4 
				endif
		case curTuludSvod1.aasta = year (fltrAruanne.kpv2)-1
				replace eelarve_report4.eelaasta2 with eelarve_report4.eelaasta2/fltrAruanne.devide+; 
					curTuludSvod1.summa in eelarve_report4 
				select qryTuluTaitmSvod1
				locate for rekvid = curTuludSvod1.rekvid and aasta = year (fltrAruanne.kpv2) -1
				if found ()
					replace eelarve_report4.taitmaasta2 with eelarve_report4.taitmaasta2/fltrAruanne.devide+; 
						qryTuluTaitmSvod1.summa in eelarve_report4 
				endif
		case curTuludSvod1.aasta = year (fltrAruanne.kpv2)-2
				replace eelarve_report4.eelaasta3 with eelarve_report4.eelaasta3/fltrAruanne.devide+; 
					curTuludSvod1.summa in eelarve_report4 
				select qryTuluTaitmSvod1
				locate for rekvid = curTuludSvod1.rekvid and aasta = year (fltrAruanne.kpv2) 
				if found ()
					replace eelarve_report4.taitmaasta3 with eelarve_report4.taitmaasta3/fltrAruanne.devide+; 
						qryTuluTaitmSvod1.summa in eelarve_report4 
				endif
	endcase	
endscan
use in tmpEelarveKulud
use in qryKuluTaitmSvod1
use in curTuludSvod1
use in qryTuluTaitmSvod1
SET STEP ON 
select artikkel, nimetus, parAsutus as asutus, parRegkood as regkood, space(254) as parasutus,;
	space(20) as parregkood, sum (eelaasta1) as eelaasta1, sum (taitmaasta1) as taitmaasta1,;
		sum (eelaasta2) as eelaasta2, sum (taitmaasta2) as taitmaasta2, sum (eelaasta3) as eelaasta3,;
		sum (taitmaasta3) as taitmaasta3, opt from eelarve_report4;
		group by artikkel, nimetus, parasutus, parRegkood,opt;
		order by artikkel;
		into cursor qry1
select eelarve_report4
zap
append from dbf ('qry1')
use in qry1

