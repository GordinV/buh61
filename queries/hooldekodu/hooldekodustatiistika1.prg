Parameter cWhere
LOCAL lcString, lnError,lcIsikuKood, lcIsik, lcHooldekodu, lcOmavalitsus, lnPension85, lnPension15, lnOmavalitsus, lnToetus, lnVara , lnMuud, lnLaen

CREATE CURSOR isikustat1 (hooldekodu c(254), KOV c(254),jaak n(16,2),;
	pension15 n(16,2), pension85 n(16,2), toetus n(16,2), vara n(16,2), omavalitsus n(16,2), muud n(16,2), laen n(16,2))

INDEX ON LEFT(ALLTRIM(UPPER(kov)),40)+LEFT(ALLTRIM(UPPER(hooldekodu)),40) TAG kov
SET ORDER TO kov

lcString = "select hl.omavalitsusId, hl.hooldekoduid, sum(ht.deebet) as db, sum(ht.kreedit) as kr, allikas, hl.jaak  from ( "+;
	" select isikid, kpv, case when ltrim(rtrim(tyyp)) = 'TULUD' then summa else 0 end::numeric as deebet , "+;
	" case when ltrim(rtrim(tyyp)) = 'KULUD' then summa else 0 end::numeric as kreedit,"+;
	" allikas, tyyp from hootehingud  "+;
	" where kpv >= date("+STR(YEAR(fltrAruanne.kpv1),4)+","+STR(MONTH(fltrAruanne.kpv1),2)+","+STR(DAY(fltrAruanne.kpv1),2)+")"+;
	" and kpv <= date("+STR(YEAR(fltrAruanne.kpv2),4)+","+STR(MONTH(fltrAruanne.kpv2),2)+","+STR(DAY(fltrAruanne.kpv2),2)+")"
	

IF !EMPTY(fltrAruanne.isikId)
	lcString = lcString + " and isikId = "+STR(fltrAruanne.isikId,9)
ENDIF
	
	lcString = lcString + " ) ht "+;
		" inner join hooleping hl on hl.isikId = ht.isikid "+;
		" where hl.loppkpv >= date("+STR(YEAR(fltrAruanne.kpv2),4)+","+STR(MONTH(fltrAruanne.kpv2),2)+","+STR(DAY(fltrAruanne.kpv2),2)+")"

IF !EMPTY(fltrAruanne.hooldekoduId)
	lcString = lcString + " and hl.HooldekoduId = "+STR(fltrAruanne.HooldekoduId,9)
ENDIF
IF !EMPTY(fltrAruanne.OmavalitsusId)
	lcString = lcString + " and hl.OmavalitsusId = "+STR(fltrAruanne.OmavalitsusId,9)
ENDIF

	lcString = lcString +" group by hl.omavalitsusId, hl.hooldekoduid,hl.jaak, ht.allikas "
	


*!*	lcString = "select hl.hooldekoduid, hk.nimetus as hooldekodu, kov.nimetus as kov, "+;
*!*		" hl.omavalitsusid, isik.nimetus as isik,isik.regkood as isikukood, hj.pension85, "+;
*!*		" hj.pension15, hj.toetus, hj.vara, hj.omavalitsus, hj.laen, hj.muud "+;
*!*		" from  hoojaak hj inner join asutus isik on isik.id = hj.isikid "+;
*!*		" inner join hooleping hl on hl.isikId = isik.id "+;
*!*		" inner join asutus hk on hk.id = hl.hooldekoduid "+;
*!*		" inner join asutus kov on kov.id = hl.omavalitsusid "+;
*!*		" where hl.algkpv <= date("+STR(YEAR(fltrAruanne.kpv1),4)+","+STR(MONTH(fltrAruanne.kpv1),2)+","+STR(DAY(fltrAruanne.kpv1),2)+")"+;
*!*		" and hl.loppkpv >= date("+STR(YEAR(fltrAruanne.kpv2),4)+","+STR(MONTH(fltrAruanne.kpv2),2)+","+STR(DAY(fltrAruanne.kpv2),2)+")"


lnError = SQLEXEC(gnHandle,lcString,'tmpisikustat')
IF lnError < 0
	_cliptext = lcString
	SET STEP ON 
	SELECT 0
	RETURN .f.
ENDIF
* select isikud
SELECT DISTINCT hooldekoduid FROM tmpisikustat INTO CURSOR tmpisikud
SELECT tmpisikud
SCAN
	SELECT tmpisikustat
	LOCATE FOR hooldekoduId = tmpisikud.hooldekoduId
	SELECT comAsutusremote
	LOCATE FOR id = tmpisikustat.hooldekoduId
	lcHooldekodu = comAsutusremote.nimetus
	lnJaak = tmpisikustat.jaak
	LOCATE FOR id = tmpisikustat.omavalitsusId
	lcOmavalitsus = comAsutusremote.nimetus
	SELECT tmpisikustat
	SUM (db-kr) FOR ALLTRIM(allikas) = 'PENSION85' AND hooldekoduid = tmpisikud.hooldekoduid TO lnPension85 	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'PENSION15' AND hooldekoduid = tmpisikud.hooldekoduid TO lnPension15 	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'TOETUS' AND hooldekoduid = tmpisikud.hooldekoduid TO lnToetus	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'OMAVALITSUS' AND hooldekoduid = tmpisikud.hooldekoduid TO lnOmavalitsus
	SUM (db-kr) FOR ALLTRIM(allikas) = 'VARA' AND hooldekoduid = tmpisikud.hooldekoduid TO lnVara 	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'MUUD' AND hooldekoduid = tmpisikud.hooldekoduid TO lnMuud 	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'LAEN' AND hooldekoduid = tmpisikud.hooldekoduid TO lnLaen	
	INSERT INTO isikustat1 ( hooldekodu, KOV ,pension15 , pension85 , toetus , vara , omavalitsus , muud , laen, jaak ) VALUES ;
		(lcHooldekodu,lcOmavalitsus,lnPension15 ,lnPension85,lnToetus,lnVara,lnOmavalitsus,lnMuud,lnLaen, lnjaak)
			
ENDSCAN
USE IN tmpisikustat
USE IN tmpisikud

SELECT isikustat1


RETURN .t.