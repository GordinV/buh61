Parameter cWhere


lcString = "select luba.*, asutus.nimetus as asutus, asutus.regkood, asutus.aadress, "+;
	" asutus.kontakt, asutus.email, asutus.tel, ifnull(dokavluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs "+;
	" from luba inner join asutus on luba.parentid = asutus.id left outer join dokvaluuta1 ON(dokvaluuta1.dokid = luba.id and dokvaluuta1.dokliik = 23) "+;
	" where luba.staatus = 0 and luba.rekvid = "+STR(gRekv)+" UPPER(order by asutus.nimetus) "
lError = odb.execsql(lcString,'tmpLoad')
IF empty (lError) or !USED('tmpLoad')
	SELECT 0
	return
ENDIF

CREATE CURSOR printLubaArhiiv (number c(20), algkpv d, loppKpv d, summa n(12,2), alus c(254), ;
	muud m, asutus c(254), regkood c(20), aadress m, kontakt m, tel c(120), email c(120), valuuta c(20), kuurs n(14,4) )
SELECT tmpLoad
SCAN
	SELECT printLubaArhiiv 
	APPEND BLANK
	replace number WITH tmpLoad.number,;
		algkpv WITH tmpLoad.algkpv,;
		loppkpv WITH tmpLoad.loppkpv,;
		summa WITH tmpLoad.summa,;
		alus WITH tmpLoad.alus,;
		muud WITH tmpLoad.muud,;
		asutus WITH tmpLoad.asutus,;
		regkood WITH tmpLoad.regkood,;
		aadress WITH tmpLoad.aadress,;
		kontakt WITH tmpLoad.kontakt,;
		tel WITH tmpLoad.tel,;
		valuuta WITH tmpLoad.valuuta,;
		kuurs WITH tmpLoad.kuurs,;
		email WITH tmpLoad.email IN printLubaArhiiv 
		
ENDSCAN

USE IN tmpLoad

SELECT printLubaArhiiv 
IF RECCOUNT('printLubaArhiiv ') < 1
	APPEND blank
ENDIF

