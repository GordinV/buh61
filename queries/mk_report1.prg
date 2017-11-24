PARAMETER nId
cOmaPank = ''
IF vartype (nId) = 'C'
	tnId = val(alltrim(nId))
ENDIF
DO case
	CASE comAaRemote.pank = 767
		cOmaPank = 'HANSAPANK'
	CASE comAaRemote.pank = 401
		cOmaPank = 'SEB'
	CASE comAaRemote.pank = 720
		cOmaPank = 'SAMPOPANK'
ENDCASE
CREATE cursor mk_report1 (id int, kpv d, asutus c(254), maksepaev d, number c(20),;
	omapangakood c(3) default str(comAaRemote.pank,3), omapank c(120) default cOmaPank ,;
	omaarve c(20) default comAaRemote.arve,;
	pank c(3), aa c(20),;
	selg m, nimetus c(254), viitenr c(120),kokku y, summa y, fin c(20), tulu c(20),regkood c(11),;
	kulu c(20), tegev c(20), eelallikas c(20), panknimi c(120), valuuta c(20) DEFAULT 'EEK', kuurs n(14,4) default 1)

IF empty (nId) and used ('curMk')
	SELECT curMk
	SCAN
		DO createmk with curmk.id
	ENDSCAN
ELSE
	DO createmk with nid
ENDIF
select mk_report1

PROCEDURE createmk
parameter tnId
	WITH oDb
		
		.use('v_mk','qryMk')
		.use('v_mk1','qryMk1')
	ENDWITH
	SELECT comAaRemote
	LOCATE for id = qryMk.aaid

*!*	if !empty (v_mk.journal)
*!*		.use ('v_journalid','QRYJOURNALNUMBER' )
	SELECT qrymk1
	SCAN
		cPank = ''
		DO case
			CASE qrymk1.pank = '767'
				cPank = 'HANSAPANK'
			CASE qrymk1.pank = '401'
				cPank = 'SEB'
			CASE qrymk1.pank = '720'
				cPank = 'SAMPOPANK'
		ENDCASE
		SELECT comNomRemote
		LOCATE for id = qrymk1.nomid
		SELECT comAsutusRemote
		LOCATE for id = qrymk1.asutusid
		INSERT into mk_report1 (id, kpv, asutus,regkood, maksepaev, number, pank, aa, selg, nimetus, viitenr, summa, panknimi, valuuta, kuurs);
			values (qryMk.id, qryMk.kpv, comAsutusRemote.nimetus,comAsutusRemote.regkood, qryMk.maksepaev, qryMk.number, qrymk1.pank, qrymk1.aa, qryMk.selg,;
			comNomRemote.nimetus, qryMk.viitenr, qrymk1.summa, cPank, qryMk1.valuuta, qryMk1.kuurs)
	ENDSCAN
	SUM summa to lnKokku
	UPDATE mk_report1 set kokku = lnKokku  where id = qryMk.id
	USE in qrymk1
	USE in qryMk
	SELECT mk_report1
ENDPROC
