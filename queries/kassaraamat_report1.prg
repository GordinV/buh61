Parameter cWhere
local lnJaak
lnJaak = 0

create cursor kassaraamat_report (number c(20), kpv d, asutus c(120),;
	 algjaak n(18,8) default lnJaak, deebet n(18,8), kreedit n(18,8), loppjaak n(18,8), lausend int, konto c(20), ;
	 kood1 c(20), kood2 c(20), kood3 c(20), kood5 c(20), tunnus c(20),;
	 kpvloppjaak n(18,8), kassa c(254), kassaAlgjaak n(18,6), kassaLoppjaak n(18,6))

tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2
tcNumber = '%'
tcNimi = '%'
tcKassa = '%'
tnSumma1 = 0
tnSumma2 = 999999999

tnDb1 = -99999999
tnDb2 = 999999999
tnKr1 = -99999999
tnKr2 = 999999999
tnTyyp = 0

with odb
lcKonto = ALLTRIM(fltrAruanne.konto)+'%'

TEXT TO lcString NOSHOW
	SELECT sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa, aa.konto, aa.nimetus as kassa  
		FROM korder1 INNER JOIN aa ON korder1.kassaid = aa.id 
		left outer join dokvaluuta1 on (korder1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik =  10) 
		WHERE korder1.rekvid = ?gRekv  and korder1.tyyp = 2 AND korder1.kpv < ?tdKpv1::date  
		AND aa.konto like ?lcKonto
		group by aa.nimetus, aa.konto 
ENDTEXT		
			
	lnError = SQLEXEC(gnHandle,lcString,'QRYALGVORDERJAAK')
TEXT TO lcString NOSHOW
	SELECT sum(summa * ifnull(dokvaluuta1.kuurs,1)) as summa, aa.konto, aa.nimetus as kassa  
		FROM korder1 INNER JOIN aa ON korder1.kassaid = aa.id 
		left outer join dokvaluuta1 on (korder1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik =  10) 
		WHERE korder1.rekvid = ?gRekv  and korder1.tyyp = 1 AND korder1.kpv < ?tdKpv1::date
		AND aa.konto like ?lcKonto
		group by aa.nimetus, aa.konto 
ENDTEXT

	lnError = SQLEXEC(gnHandle,lcString,'QRYALGSORDERJAAK')
 
	.use('curKorder','qryKorder')

TEXT TO lcString noshow
	select sum(saldo) as jaak from (
	select sd(konto,1, ?tdKpv2::date) as saldo from aa
	where kassa = 0 
	and parentid = ?gRekv
	) qry

ENDTEXT

	lnError = SQLEXEC(gnHandle,lcString,'qryKassaLoppJaak')
 
	
	* Kassa algjaak
	
		SELECT QRYALGSORDERJAAK
		SUM summa TO lnDb
		
		SELECT QRYALGVORDERJAAK
		SUM summa TO lnKr

		lnJaak = lnDb - lnKr
* kassa loppjaak
		SELECT sum(deebet*kuurs) as db, sum(kreedit*kuurs) as kr FROM qryKorder INTO CURSOR tmpLoppSaldo
		lnLoppJaak = lnJaak + tmpLoppSaldo.db - tmpLoppSaldo.kr
		USE IN tmpLoppSaldo

	IF !EMPTY(fltrAruanne.konto)
		DELETE FROM qryKorder WHERE aKonto NOT like lcKonto
	ENDIF
	

	SELECT kpv, sum(deebet * KUURS) as deebet, sum(kreedit * KUURS) as kreedit, kassa FROM qryKorder GROUP BY kassa, kpv INTO CURSOR qryKpv


		select kassa, konto FROM QRYALGSORDERJAAK ;
		UNION ALL ;
		select kassa, konto FROM QRYALGVORDERJAAK ;
		UNION ALL ;
		select distinc kassa, akonto as konto FROM qryKorder INTO cursor qryKassad

	SELECT distinc kassa, konto FROM qryKassad INTO CURSOR tmpKassad

	lnKpvDb = 0
	lnKpvKr = 0
	lnDb = 0
	lnKr = 0
	
	SELECT tmpKassad
	SCAN 
	 	IF !EMPTY(fltrAruanne.konto)
			IF ALLTRIM(tmpKassad.konto) <> ALLTRIM(fltrAruanne.konto)
				LOOP 
			ENDIF
		ENDIF
		
		
		lnKassaAlgJaak = 0
		SELECT QRYALGSORDERJAAK
		LOCATE FOR kassa = tmpKassad.kassa
		IF FOUND()
			lnDb = QRYALGSORDERJAAK.summa 
		ENDIF
		
		SELECT QRYALGVORDERJAAK
		LOCATE FOR kassa = tmpKassad.kassa
		IF FOUND()
			lnKr = QRYALGVORDERJAAK.summa
		endif
		
		lnKassaAlgJaak = lnDb - lnKr
		select qryKorder
		SCAN FOR kassa = tmpKassad.kassa
			SELECT qryKpv
			SUM deebet TO lnKpvDb FOR qryKpv.kpv <= qryKorder.kpv AND kassa = qryKorder.kassa			
			SUM kreedit TO lnKpvKr FOR qryKpv.kpv <= qryKorder.kpv AND kassa = qryKorder.kassa
			
			insert into kassaraamat_report (number, kpv, asutus, deebet, kreedit, lausend, konto, kood1, kood2, ;
				kood3, kood5, tunnus, kpvloppjaak, kassa, algjaak, loppjaak) values ;
				(qryKorder.number,qryKorder.kpv, qryKorder.nimi,IIF(qryKorder.tyyp = 1,qryKorder.deebet * qryKorder.KUURS, 0),;
				IIF(qryKorder.tyyp = 2,qryKorder.kreedit * qryKorder.KUURS, 0), qryKorder.lausend,;
				IIF(qryKorder.tyyp = 2,qryKorder.db, qryKorder.kr), qryKorder.kood1, qryKorder.kood2,;
				qryKorder.kood3, qryKorder.kood5, qryKorder.tunnus, lnKassaAlgJaak + lnKpvDb - lnKpvKr, qryKorder.kassa, lnJaak, qryKassaLoppJaak.jaak  ) 
		ENDSCAN
		lnDb = 0
		lnKr = 0

		SELECT QRYALGSORDERJAAK
		SUM summa FOR kassa = tmpKassad.kassa TO lnDb
		SELECT QRYALGVORDERJAAK
		SUM summa FOR kassa = tmpKassad.kassa TO lnKr	
		
		SELECT sum(deebet) as db, sum(kreedit) as kr FROM kassaraamat_report WHERE kassa = tmpKassad.kassa INTO cursor TmpKassaKaibed
		UPDATE kassaraamat_report SET kassaAlgjaak = lnDb - lnKr,kassaLoppjaak =  lnDb - lnKr + TmpKassaKaibed.db - TmpKassaKaibed.kr;
		 WHERE ALLTRIM(kassa) = ALLTRIM(tmpKassad.kassa)

	ENDSCAN
	select kassaraamat_report
	IF RECCOUNT()< 1
		APPEND BLANK
	ENDIF

		
	SELECT * from kassaraamat_report ORDER BY kassa, kpv INTO CURSOR kassaraamat_report1
	USE IN kassaraamat_report
ENDWITH
IF USED('qryKassad')
	use in qryKassad
ENDIF

USE IN kassaraamat_report
USE IN TmpKassaKaibed
USE IN tmpKassad
use in qryKorder
use in QRYALGVORDERJAAK
use in QRYALGSORDERJAAK
