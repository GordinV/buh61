Parameter cWhere
LOCAL lnAsutusId1, lnAsutusid2
lnAsutusid1 = 0
lnAsutusid2 = 999999999

IF fltrAruanne.asutusId > 0
	lnAsutusid1 = fltrAruanne.asutusId
	lnAsutusid2 = fltrAruanne.asutusId
	
ENDIF


*SET STEP ON 



lcString = "select count(*) as kogus, sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa, tyyp, staatus "+;
" from toiming left outer join dokvaluuta1 ON(toiming.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 24) "+; 
" where staatus > 0 and kpv >= " +;
" date("+STR(YEAR(fltrAruanne.kpv1),4)+","+STR(MONTH(fltrAruanne.kpv1),2)+","+STR(DAY(fltrAruanne.kpv1),2)+")"+;
" and kpv <= date("+STR(YEAR(fltrAruanne.kpv2),4)+","+STR(MONTH(fltrAruanne.kpv2),2)+","+STR(DAY(fltrAruanne.kpv2),2)+")"+; 
" and lubaid in ("+;
" select luba.id from luba inner join luba1 on luba.id = luba1.parentid "+;
" where number like '%" + ALLTRIM(fltrAruanne.number)+"' and luba.parentId >= " + STR(lnAsutusId1,9) +;
" and luba.parentId <= " +STR(lnAsutusId2,9)+ " and luba.rekvid = "+STR(gRekv)+ " and luba.staatus > 0 ) "+; 
" group by tyyp, staatus  ORDER BY TYYP"

lError = odb.execsql(lcString,'printStat1')
IF empty (lError) or !USED('printStat1')
	SELECT 0
	return
ENDIF



