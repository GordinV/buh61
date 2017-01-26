Parameter cWhere
* reklmaksu arvestus
LOCAL lcString, cKpv1, cKpv2
IF EMPTY(fltrAruanne.asutusId)
	MESSAGEBOX('Puudub asutus')
	SELECT 0
	return
ENDIF

cKpv1 = 'date('+STR(YEAR(fltrAruanne.kpv1))+','+STR(MONTH(fltrAruanne.kpv1))+','+STR(DAY(fltrAruanne.kpv1))+')'
cKpv2 = 'date('+STR(YEAR(fltrAruanne.kpv2))+','+STR(MONTH(fltrAruanne.kpv2))+','+STR(DAY(fltrAruanne.kpv2))+')'


lcString = 'select sp_rekl_aruanne1(' + STR(grekv) +',' + cKpv1+',' +cKpv2+ ',' + STR(fltrAruanne.asutusId)+')' 
lError = SQLEXEC(gnHandle,lcString,'qry')
IF lError < 1 
	SELECT 0
	return
ENDIF

lcString = "select * from tmpReklAruanne1 where timestamp = '" + ALLTRIM(qry.sp_rekl_aruanne1) + "' order by luba, tyypnimi, toiming_nr, kpv"
lError = SQLEXEC(gnHandle,lcString,'rekl_aruanne1_report1')
IF lError < 1 
	SELECT 0
	SET STEP on
	
	RETURN .f.
ENDIF

SELECT rekl_aruanne1_report1


