Parameter cWhere
LOCAL lcString, lnError,lcIsikuKood, lcIsik, lcHooldekodu, lcOmavalitsus, lnPension85, lnPension15, lnOmavalitsus, lnToetus, lnVara , lnMuud, lnLaen

CREATE CURSOR isikustat1 (isik c(254), isikukood c(20), hooldekodu c(254), KOV c(254),;
	pension15 n(16,2), pension85 n(16,2), toetus n(16,2), vara n(16,2), omavalitsus n(16,2), muud n(16,2), laen n(16,2), jaak n(18,2), kovjaak n(18,2))

INDEX ON LEFT(ALLTRIM(UPPER(kov)),40)+LEFT(ALLTRIM(UPPER(hooldekodu)),40)+LEFT(ALLTRIM(UPPER(isik)),40) TAG isik
SET ORDER TO isik

lcString = "select hl.omavalitsusId, hl.hooldekoduid, ht.isikId, sum(ht.deebet) as db, sum(ht.kreedit) as kr, allikas from ( "+;
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

	lcString = lcString +" group by hl.omavalitsusId, hl.hooldekoduid, ht.isikid, ht.allikas "
	


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
SELECT DISTINCT isikid FROM tmpisikustat INTO CURSOR tmpisikud
SELECT tmpisikud
SCAN
	SELECT tmpisikustat
	LOCATE FOR isikId = tmpisikud.isikId
	SELECT comAsutusremote
	LOCATE FOR id = tmpisikud.isikid
	lcIsikuKood = comAsutusremote.regkood
	lcIsik = comAsutusremote.nimetus
	LOCATE FOR id = tmpisikustat.hooldekoduId
	lcHooldekodu = comAsutusremote.nimetus
	LOCATE FOR id = tmpisikustat.omavalitsusId
	lcOmavalitsus = comAsutusremote.nimetus
	SELECT tmpisikustat
	SUM (db-kr) FOR ALLTRIM(allikas) = 'PENSION85' AND isikid = tmpisikud.isikid TO lnPension85 	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'PENSION15' AND isikid = tmpisikud.isikid TO lnPension15 	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'TOETUS' AND isikid = tmpisikud.isikid TO lnToetus	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'OMAVALITSUS' AND isikid = tmpisikud.isikid TO lnOmavalitsus
	SUM (db-kr) FOR ALLTRIM(allikas) = 'VARA' AND isikid = tmpisikud.isikid TO lnVara 	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'MUUD' AND isikid = tmpisikud.isikid TO lnMuud 	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'LAEN' AND isikid = tmpisikud.isikid TO lnLaen	
	INSERT INTO isikustat1 (isik, isikukood, hooldekodu, KOV ,pension15 , pension85 , toetus , vara , omavalitsus , muud , laen ) VALUES ;
		(lcisik,lcIsikukood ,lcHooldekodu,lcOmavalitsus,lnPension15 ,lnPension85,lnToetus,lnVara,lnOmavalitsus,lnMuud,lnLaen)
			
ENDSCAN
USE IN tmpisikustat
USE IN tmpisikud

SELECT isikustat1

RETURN .t.