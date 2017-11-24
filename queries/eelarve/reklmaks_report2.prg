Parameter tcWhere
LOCAL lcString

*!*	TEXT
*!*	CREATE CURSOR qryViivis (konto c(20), selg c(254), number c(20), summa y, tahtaeg d, tasud y, volg y,;
*!*		 viivis y, paev int, ASUTUS C(254), asutusId int)
*!*	Create Cursor qryViArv (Id Int, asutusId Int, period d, arv Y )
*!*	ENDTEXT

IF !USED('curkuud')
	CREATE CURSOR curKuud (id int, kuu c(40))
	INSERT INTO curKuud (id, kuu) VALUES (1,'Jaanuar')
	INSERT INTO curKuud (id, kuu) VALUES (2,'Veebruar')
	INSERT INTO curKuud (id, kuu) VALUES (3,'Märts')
	INSERT INTO curKuud (id, kuu) VALUES (4,'April')
	INSERT INTO curKuud (id, kuu) VALUES (5,'Mai')
	INSERT INTO curKuud (id, kuu) VALUES (6,'Juuni')
	INSERT INTO curKuud (id, kuu) VALUES (7,'Juuli')
	INSERT INTO curKuud (id, kuu) VALUES (8,'August')
	INSERT INTO curKuud (id, kuu) VALUES (9,'September')
	INSERT INTO curKuud (id, kuu) VALUES (10,'Oktoober')
	INSERT INTO curKuud (id, kuu) VALUES (11,'November')
	INSERT INTO curKuud (id, kuu) VALUES (12,'Detsember')
ENDIF


IF !USED('qryViivis') OR RECCOUNT('qryViivis') < 1
	MESSAGEBOX('Puudub andmed')
	SELECT 0
	return
ENDIF


CREATE CURSOR reklmaks_report1 (number c(20), asutus c(254), regkood c(20), aadress m, tel c(120),;
	epost c(120), asukoht m, kirjeldus m, hind y, kogus y, paigpaev int, summa y, kuu c(40))

SELECT qryViArv 

* arvestused
SCAN
	SELECT comAsutusRemote
	IF TAG() <> 'ID'
		SET ORDER TO id
	ENDIF
	SEEK qryViArv .asutusId
	IF FOUND()
		SELECT curKuud
		LOCATE FOR id = MONTH(qryViArv.period)
		
		INSERT INTO reklmaks_report1  (asutus, regkood, aadress , ;
			epost ,  kirjeldus, summa, kuu) VALUES (;
			comAsutusRemote.nimetus, comAsutusRemote.regkood, comAsutusRemote.aadress,;
			comAsutusRemote.email, 'Rekl.maks',qryViArv.arv, curKuud.kuu)
	ENDIF

ENDSCAN


SELECT qryViivis
SCAN FOR viivis > 0
	SELECT comAsutusRemote
	IF TAG() <> 'ID'
		SET ORDER TO id
	ENDIF
	SEEK qryViivis.asutusId
	IF FOUND()
		INSERT INTO reklmaks_report1  (asutus, regkood, aadress , ;
			epost , summa, kuu, kirjeldus) VALUES (;
			comAsutusRemote.nimetus, comAsutusRemote.regkood, comAsutusRemote.aadress,;
			comAsutusRemote.email, qryViivis.viivis, '', 'Viivis')
	ENDIF	
endscan


*!*	lcString = 'select leping1.asutusId, leping1.number, leping1.muud as selg,  leping2.* from leping2 '+;
*!*	' inner join leping1 on leping1.id = leping2.parentid where rekvid = '+STR(gRekv)+;
*!*			' and tahtaeg >= DATE('+STR(YEAR(qryAlgViivis.kpv2),4)+','+STR(MONTH(qryAlgViivis.kpv2),2)+','+;
*!*			STR(DAY(qryAlgViivis.kpv2),4)+') '+;
*!*			IIF(qryAlgViivis.asutusId > 0,' and asutusid = '+STR(qryAlgViivis.asutusId,9),'')

*!*	lError = SQLEXEC(gnHandle,lcString,'qryRekldekl')
*!*	IF lError < 0
*!*		SELECT 0
*!*		RETURN .f.
*!*	endif

*!*	SELECT qryRekldekl
*!*	SCAN
*!*		SELECT comAsutusRemote
*!*		IF TAG() <> 'ID'
*!*			SET ORDER TO id
*!*		ENDIF
*!*		SEEK qryRekldekl.asutusId
*!*		
*!*		INSERT INTO reklmaks_report1  (number, asutus, regkood, aadress , ;
*!*		epost , asukoht , kirjeldus , hind , kogus ,  summa ) VALUES (;
*!*		qryRekldekl.number, comAsutusRemote.nimetus, comAsutusRemote.regkood, comAsutusRemote.aadress,;
*!*		comAsutusRemote.email, qryRekldekl.muud, qryRekldekl.selg, qryRekldekl.hind, qryRekldekl.kogus,;
*!*		IIF(!EMPTY(qryRekldekl.summa),qryRekldekl.summa,qryRekldekl.hind * qryRekldekl.kogus))
*!*	ENDSCAN
*!*	USE IN qryRekldekl

SELECT reklmaks_report1
