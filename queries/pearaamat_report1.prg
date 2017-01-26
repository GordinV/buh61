Parameter cWhere

LOCAL lcNimetus 
lcNimetus = ''

If Isdigit(Alltrim(cWhere))
	cWhere = Val(Alltrim(cWhere))
ENDIF
* lisatud 22/05
IF USED ('curSaldo')
	USE IN curSaldo
ENDIF

Local lnDeebet, lnKreedit, lInsertedDb,lInsertedKr
dKpv1 = Iif(!Empty(fltrAruanne.kpv1), fltrAruanne.kpv1,Date(Year(Date()),1,1))
dKpv2 = Iif(!Empty(fltrAruanne.kpv2), fltrAruanne.kpv2,Date())
Replace fltrAruanne.kpv1 With dKpv1,;
	fltrAruanne.kpv2 With dKpv2 In fltrAruanne
Create Cursor pearaamat_report1 (pohikonto c(20),konto c(20), korkonto c(20), nimetus c(254), algsaldo n(18,2), deebet n(18,2), kreedit n(18,2), ;
	dbkokku n(18,2), krkokku n(18,2), lSaldo n(18,2), opt Int,palgsaldo n(18,2), plsaldo n(18,2),pdbkokku n(18,2), pkrkokku n(18,2))
Index On TRIM(pohikonto)+'-'+TRIM(konto)+'-'+TRIM(korkonto) Tag konto
Index On korkonto Tag korkonto
Set Order To korkonto

tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2
tnKond = IIF(fltrAruanne.kond = 1,3,9)

With oDb
If Empty(fltrAruanne.konto)
* таблица сальдо
	tcCursor = 'CursorAlgSaldo'
	TcKonto = '%'
	tnAsutusId1 = 0
	tnAsutusId2 = 99999999
	tnTunnusId1 = 0
	tnTunnusId2 = 99999999
	tdKpv1 = Date(1999,1,1)
	tdKpv2 = fltrAruanne.kpv1-1

	.Use ('qrySaldo1',tcCursor)
Endif

* таблица оборотов
	tdKpv1 = fltrAruanne.kpv1
	tdKpv2 = fltrAruanne.kpv2
	tcKonto = Trim(fltrAruanne.konto)+'%'
*!*	SELECT konto,  korkonto, sum(deebet) as db, sum (kreedit) as kr from ( SELECT JOURNAL1.deebet As konto,  journal1.kreedit as korkonto, 
*!*	(journal1.Summa * ifnull(dokvaluuta1.kuurs,1)) As deebet, 0 As kreedit, journal.rekvid,  journal.kpv  
*!*	FROM journal  JOIN journal1 ON journal.id = journal1.parentid JOIN journalid ON journal.id = journalid.journalid 
*!*	LEFT OUTER JOIN dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1)  
*!*	UNION All 
*!*	SELECT JOURNAL1.kreedit As konto,  journal1.deebet as korkonto, 0 as deebet, (journal1.Summa * ifnull(dokvaluuta1.kuurs,1)) As kreedit,  journal.rekvid,  journal.kpv  
*!*	FROM journal  JOIN journal1 ON journal.id = journal1.parentid JOIN journalid ON journal.id = journalid.journalid 
*!*	LEFT OUTER JOIN dokvaluuta1 on (journal1.id = dokvaluuta1.dokid and dokliik = 1) ) qrySaldoaruanne  
*!*	WHERE qrySaldoaruanne.rekvid in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, 63) > 9) or  qrySaldoaruanne.rekvid = 63
*!*	AND kpv >= date(2011,01,01) and kpv <= date(2011,01,31) and  konto like '100100%' 

*!*	group BY konto, korkonto 
	
	.Use ('krosskonto')
	INDEX ON konto TAG konto
	SET ORDER TO konto
	IF !EMPTY(fltrAruanne.konto)
		Select * from comKontodRemote WHERE kood like ALLTRIM(fltrAruanne.konto)+'%' INTO CURSOR qryKontod
	ELSE
		Select * from comKontodRemote WHERE kood in (select distinct konto FROM CursorAlgSaldo ) or;
			kood in (select DISTINCT konto FROM krosskonto) ;
			INTO CURSOR qryKontod
	ENDIF
	SET STEP ON 
	SELECT qryKontod
	Scan 
		Wait Window 'Arvestan konto: '+qryKontod.kood Nowait
&& Alg.saldo arvestamine
		lnAlg =fnc_eursumma( analise_formula('SD('+Rtrim(Ltrim(qryKontod.kood))+')',fltrAruanne.kpv1-1))
		llInserted = .f.
		lnDb = 0
		lnKr = 0
		Select krosskonto
		SCAN FOR konto =  qryKontod.kood
			Wait Window 'Arvestan konto: '+qryKontod.kood+SPACE(1)+ krosskonto.korkonto Nowait
			lnDb = lnDb + krosskonto.db
			lnKr = lnKr + KrossKonto.kr
			
*!*				SELECT qryKontod
*!*				LOCATE FOR kood = krosskonto.korkonto
*!*				IF FOUND()
*!*					lcNimetus = qryKontod.nimetus
*!*				ELSE
*!*					lcNimetus = ''
*!*				ENDIF
			lnPk = Len(ALLTRIM(qryKontod.kood)) - Round(Len(ALLTRIM(qryKontod.kood))/2,0)
		
			IF LEFT(ALLTRIM(qryKontod.kood),6) = '100100'
				lnPk = 6
			endif

			INSERT INTO pearaamat_report1 (pohikonto, konto, nimetus, korkonto, algsaldo , deebet , kreedit) VALUES ;
				(left(Rtrim(Ltrim(qryKontod.kood)),lnPk),qryKontod.kood,qryKontod.Nimetus, krosskonto.korkonto, ;
				ROUND(lnAlg ,2), ROUND(krosskonto.db,2) , ROUND(krosskonto.kr,2))
			llInserted = .t.
			Select krosskonto
		ENDSCAN
		
		IF lnAlg <> 0 AND llInserted = .f.
			lnPk = Len(ALLTRIM(qryKontod.kood)) - Round(Len(ALLTRIM(qryKontod.kood))/2,0)
		
			IF LEFT(ALLTRIM(qryKontod.kood),6) = '100100'
				lnPk = 6
			endif

			INSERT INTO pearaamat_report1 (pohikonto, konto, algsaldo, nimetus ) VALUES ;
				(left(Rtrim(Ltrim(qryKontod.kood)),lnPk),qryKontod.kood, ROUND(lnAlg/ fltrPrinter.kuurs,2),qryKontod.Nimetus)
		ENDIF
		UPDATE pearaamat_report1 SET dbkokku = ROUND(lnDb,2),;
			krkokku = ROUND(lnKr,2),;
			lSaldo = ROUND(lnAlg,2) + ROUND(lnDb,2) - ROUND(lnKr,2) WHERE konto = qryKontod.kood
	ENDSCAN

* arvestame kontod

	SELECT konto FROM krosskonto GROUP BY konto INTO CURSOR tmpArvKonto

	IF USED('CursorAlgSaldo')
		USE IN CursorAlgSaldo
	ENDIF
		SELECT distin pohikonto FROM pearaamat_report1  INTO CURSOR tmpPohikontod
		SELECT tmpPohikontod
	*	SET STEP ON 
		SCAN
			SELECT distin algsaldo, lsaldo, pohikonto, konto from pearaamat_report1 WHERE ALLTRIM(pearaamat_report1.pohikonto) = ALLTRIM(tmpPohikontod.pohikonto) INTO CURSOR tmpPea
			SUM algsaldo, lsaldo TO lnPAlgSaldo, lnPlSaldo
			USE in tmpPea
			UPDATE pearaamat_report1 SET palgsaldo = lnPAlgSaldo, plsaldo = lnPlSaldo WHERE ALLTRIM(pohikonto) = ALLTRIM(tmpPohikontod.pohikonto)
		endscan
		USE IN tmpPohikontod
	
Endwith

* arvestame kokku summad

SELECT sum(deebet) as dbkokku, sum(kreedit) as krkokku FROM pearaamat_report1 INTO CURSOR tmpKokku

UPDATE pearaamat_report1 SET pdbkokku = tmpKokku.dbkokku, pkrKokku = tmpKokku.krkokku

USE IN tmpKokku

* SUM KORKONTO

*SET STEP ON
IF !EMPTY(fltrAruanne.konto) AND RECCOUNT('tmpArvKonto') > 1

	SELECT korkonto, sum(deebet) as deebet, sum(kreedit) as kreedit;
		FROM pearaamat_report1 ;
		WHERE konto like LTRIM(RTRIM(tcKonto))+'%' ;
		GROUP BY korkonto;
		INTO CURSOR tmpPKonto

SELECT konto, algsaldo, lsaldo FROM pearaamat_report1 WHERE konto like LTRIM(RTRIM(tcKonto))+'%' GROUP BY konto, algsaldo, lsaldo INTO CURSOR tmpSaldod

SELECT tmpSaldod
SUM algsaldo, lsaldo TO lnAlg, lnLopp 

INSERT INTO pearaamat_report1 (konto, nimetus, korkonto, algsaldo , deebet , kreedit, lsaldo) ;
SELECT tcKonto, '',korkonto, lnAlg, deebet, kreedit, lnLopp FROM tmpPKonto


ENDIF

SELECT pearaamat_report1
Set Order To konto
Go Top

USE IN tmpPKonto
USE IN tmpSaldod

USE IN qryKontod
USE IN krosskonto
