Parameter cWhere
LOCAL lcString, cKpv1, cKpv2
*kontrolliaruanne
cKpv1 = 'date('+STR(YEAR(fltrAruanne.kpv1))+','+STR(MONTH(fltrAruanne.kpv1))+','+STR(DAY(fltrAruanne.kpv1))+')'
cKpv2 = 'date('+STR(YEAR(fltrAruanne.kpv2))+','+STR(MONTH(fltrAruanne.kpv2))+','+STR(DAY(fltrAruanne.kpv2))+')'
IF EMPTY(fltrAruanne.asutusId) 
	lnAsutus = 0
ELSE
	lnAsutus = fltrAruanne.asutusId
ENDIF

*SET STEP ON 
lcString = 'select sp_rekl_aruanne3(' + STR(grekv) +',' + cKpv1+',' +cKpv2+ ',' + STR(lnAsutus)+')' 
lError = SQLEXEC(gnHandle,lcString,'qry')
IF lError < 1 
	SELECT 0
	return
ENDIF

lcString = "select * from tmpReklAruanne3 where timestamp = '" + ALLTRIM(qry.sp_rekl_aruanne3) + "' order by asutus"
lError = SQLEXEC(gnHandle,lcString,'rekl_aruanne1_report1')
IF lError < 1 
	SELECT 0	
	RETURN .f.
ENDIF

SELECT rekl_aruanne1_report1


