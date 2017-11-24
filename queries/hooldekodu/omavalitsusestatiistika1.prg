Parameter cWhere
LOCAL lcString, lnError,lcIsikuKood, lcIsik, lcHooldekodu, lcOmavalitsus, lnPension85, lnPension15, lnOmavalitsus, lnToetus, lnVara , lnMuud, lnLaen

CREATE CURSOR isikustat1 (isik c(254), isikukood c(20), hooldekodu c(254), KOV c(254),;
	pension15 n(16,2), pension85 n(16,2), toetus n(16,2), vara n(16,2), omavalitsus n(16,2), muud n(16,2), laen n(16,2))
INDEX ON LEFT(ALLTRIM(UPPER(kov)),40) TAG kov
SET ORDER TO kov

lcString = "select hl.omavalitsusId, sum(ht.deebet) as db, sum(ht.kreedit) as kr, allikas from ( "+;
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

	lcString = lcString +" group by hl.omavalitsusId, ht.allikas "
	


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
SELECT DISTINCT omavalitsusid FROM tmpisikustat INTO CURSOR tmpisikud
SELECT tmpisikud
SCAN
	SELECT comAsutusremote
	LOCATE FOR id = tmpisikustat.omavalitsusId
	lcOmavalitsus = comAsutusremote.nimetus
	SELECT tmpisikustat
	SUM (db-kr) FOR ALLTRIM(allikas) = 'PENSION85' AND omavalitsusid = tmpisikud.omavalitsusid TO lnPension85 	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'PENSION15' AND omavalitsusid = tmpisikud.omavalitsusid TO lnPension15 	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'TOETUS' AND omavalitsusid = tmpisikud.omavalitsusid TO lnToetus	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'OMAVALITSUS' AND omavalitsusid = tmpisikud.omavalitsusid TO lnOmavalitsus
	SUM (db-kr) FOR ALLTRIM(allikas) = 'VARA' AND omavalitsusid = tmpisikud.omavalitsusid TO lnVara 	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'MUUD' AND omavalitsusid = tmpisikud.omavalitsusid TO lnMuud 	
	SUM (db-kr) FOR ALLTRIM(allikas) = 'LAEN' AND omavalitsusid = tmpisikud.omavalitsusid TO lnLaen	
	INSERT INTO isikustat1 ( KOV ,pension15 , pension85 , toetus , vara , omavalitsus , muud , laen ) VALUES ;
		(lcOmavalitsus,lnPension15 ,lnPension85,lnToetus,lnVara,lnOmavalitsus,lnMuud,lnLaen)
			
ENDSCAN
USE IN tmpisikustat
USE IN tmpisikud

SELECT isikustat1


RETURN .t.