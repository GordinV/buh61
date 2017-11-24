Parameter tcWhere
LOCAL lcString

CREATE CURSOR reklmaks_report1 (number c(20), asutus c(254), regkood c(20), aadress m, tel c(120),;
	epost c(120), asukoht m, kirjeldus m, hind y, kogus y, paigpaev int, summa y)

lcString = 'select leping1.asutusId, leping1.number, leping1.muud as selg,  leping2.* from leping2 '+;
' inner join leping1 on leping1.id = leping2.parentid where rekvid = '+STR(gRekv)+;
		' and tahtaeg >= DATE('+STR(YEAR(qryAlgViivis.kpv2),4)+','+STR(MONTH(qryAlgViivis.kpv2),2)+','+;
		STR(DAY(qryAlgViivis.kpv2),4)+') '+;
		IIF(qryAlgViivis.asutusId > 0,' and asutusid = '+STR(qryAlgViivis.asutusId,9),'')

lError = SQLEXEC(gnHandle,lcString,'qryRekldekl')
IF lError < 0
	SELECT 0
	RETURN .f.
endif

SELECT qryRekldekl
SCAN
	SELECT comAsutusRemote
	IF TAG() <> 'ID'
		SET ORDER TO id
	ENDIF
	SEEK qryRekldekl.asutusId
	
	INSERT INTO reklmaks_report1  (number, asutus, regkood, aadress , ;
	epost , asukoht , kirjeldus , hind , kogus ,  summa ) VALUES (;
	qryRekldekl.number, comAsutusRemote.nimetus, comAsutusRemote.regkood, comAsutusRemote.aadress,;
	comAsutusRemote.email, qryRekldekl.muud, qryRekldekl.selg, qryRekldekl.hind, qryRekldekl.kogus,;
	IIF(!EMPTY(qryRekldekl.summa),qryRekldekl.summa,qryRekldekl.hind * qryRekldekl.kogus))
ENDSCAN
USE IN qryRekldekl

SELECT reklmaks_report1
