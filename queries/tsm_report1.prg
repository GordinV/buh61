Parameter tcWhere
Create cursor tsm_report (lepingId int DEFAULT comTootajad.lepingId, AASTA int default year(fltrpalkoper.kpv1),;
	kuu int default month (fltrpalkoper.kpv1),;
	isikukd c(11) DEFAULT comAsutusRemote.regkood, nimi c(254) DEFAULT comAsutusRemote.nimetus,;
	aadr m DEFAULT comAsutusRemote.aadress, kpv1 d default fltrpalkoper.kpv1, kpv2 d default fltrpalkoper.kpv2,;
	sm y, arvsm y, palk y, tulu y, tululiik c(20), palk10 y, tm y,  pm y, elatis y, lm y, nimetus c(120), maar y, IIIsamba y, vpm y, lapsepm y)

Create cursor tsm_report1 (lepingId int DEFAULT comTootajad.lepingId, AASTA int default year(fltrpalkoper.kpv1),;
	kuu int default month (fltrpalkoper.kpv1),;
	isikukd c(11) DEFAULT comAsutusRemote.regkood, nimi c(254) DEFAULT comAsutusRemote.nimetus,;
	aadr m DEFAULT comAsutusRemote.aadress, kpv1 d default fltrpalkoper.kpv1, kpv2 d default fltrpalkoper.kpv2,;
	sm y, arvsm y, palk y, tulu y, tululiik c(20), palk10 y, tm y,  pm y, elatis y, lm y,  nimetus c(120), IIIsamba y, vpm y, lapsepm y, maar y DEFAULT 21)

IF !USED('comTululiik')
CREATE CURSOR comTululiik (kood c(2), nimetus c(120))
	INSERT INTO comTululiik (kood, nimetus) VALUES (' ','P�hipalk')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('01','P�hipalk')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('02','rendi- v�i ��ritulu ning litsentsitasud')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('03','intressid')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('04','elatis')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('05','Eesti riigi poolt seaduse alusel makstav pension')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('06','stipendiumid, toetused, kultuuri-, spordi- ja teaduspreemiad ning loteriiv�idud')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('07','ajutise t��v�imetuse rahaline h�vitis')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('08','investeerimisriskiga elukindlustuslepingu alusel kindlustusv�tjale v�i soodustatud isikule v�ljamakstav summa')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('09','26% maksum��raga maksustatavad v�ljamaksed, mis on tehtud t�iendava kogumispensioni kindlustuslepingu alusel v�i vabatahtlikust pensionifondist')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('10','10% maksum��raga maksustatavad v�ljamaksed, mis on tehtud t�iendava kogumispensioni kindlustuslepingu alusel v�i vabatahtlikust pensionifondist')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('11','juriidilise isiku juhtimis- v�i kontrollorgani liikmele makstav tasu')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('12','seoses t���nnetusega v�i kutsehaigusega makstav h�vitis')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('13','- t��lepingu l�petamisel "Eesti Vabariigi t��lepingu seaduse" alusel v�i teenistusest vabastamisel "Avaliku teenistuse seaduse" alusel t��tajale v�i avalikule teenistujale makstavad h�vitised')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('14','muud v�ljamaksed')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('15','t��v�tu-, k�sundus- v�i muu v�la�igusliku lepingu alusel makstav t��- v�i teenustasu')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('16','T��tukassa poolt "T��tuskindlustuse seaduse" alusel v�ljamakstav t��tuskindlustush�vitis')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('17','T��tukassa poolt "T��tuskindlustuse seaduse" alusel v�ljamakstav h�vitis t��lepingute kollektiivse �les�tlemise korral')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('18','T��tukassa poolt "T��tuskindlustuse seaduse" alusel v�ljamakstav h�vitis t��andja maksej�uetuse korral')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('19','Vanemah�vitise seaduse" (RT I 2003, 82, 549) alusel v�ljamakstav vanemah�vitis')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('19a','teenistusest vabastamisel teenistujale makstavad h�vitised')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('20','�li�pilaste tulu')
	INSERT INTO comTululiik (kood, nimetus) VALUES ('21','muu tulu')
ENDIF

 
tdKpv1 = fltrpalkoper.kpv1
tdKpv2 = fltrpalkoper.kpv2
SET STEP ON 
SELECT comTootajad
SCAN
	tnlepingId = comTootajad.lepingId
	SELECT comAsutusRemote
	LOCATE FOR id = comTootajad.id
	
	* tulud
	tnLiik = 1
	tnElatis = 0
	tnLiikmemaks = 0
	tnArvSots = 1
	odb.use ('qryTSM')
	IF qryTSM.summa > 0
		INSERT INTO tsm_report (tululiik, palk, nimetus) ;
			SELECT  qryTSM.tululiik, qryTSM.summa, IIF(ISNULL(comTululiik.nimetus),SPACE(254),comTululiik.nimetus) ;
				FROM qryTsm ;
				left outer join  comTululiik on ALLTRIM(qryTsm.tululiik) = ALLTRIM(comTululiik.kood)
	ENDIF
	
	tnArvSots = 0
	odb.use ('qryTSM')
	IF qryTSM.summa > 0

		INSERT INTO tsm_report (tululiik, palk, nimetus) ;
			SELECT  qryTSM.tululiik, qryTSM.summa, IIF(ISNULL(comTululiik.nimetus),SPACE(254),comTululiik.nimetus) FROM qryTsm ;
				left outer join  comTululiik on ALLTRIM(qryTsm.tululiik) = ALLTRIM(comTululiik.kood)
	ENDIF
	

	* TULUMAKS
	tnLiik = 4
	tnElatis = 0
	tnLiikmemaks = 0
	odb.use ('qryTSMpens','qryTSM')
*!*		SELECT tsm_report
*!*		COUNT TO lnCount FOR lepingid = comTootajad.lepingId
*!*		IF lnCount < 1
*!*			APPEND blank
*!*		ENDIF
*!*		SELECT 	tsm_report
*!*		LOCATE FOR lepingid = comTootajad.lepingId
*!*		replace tulu WITH qryTsm.summa IN tsm_report
*	UPDATE tsm_report SET tulu = qryTsm.summa WHERE lepingid = comTootajad.lepingId
	INSERT INTO tsm_report (tulu) values(qryTSM.summa)
	


	* elatis
	tnLiik = 2
	tnElatis = 1
	tnLiikmemaks = 0
	odb.use ('qryTSMpens','qryTSM')
*!*		SELECT tsm_report
*!*		COUNT TO lnCount FOR lepingid = comTootajad.lepingId
*!*		IF lnCount < 1
*!*			APPEND blank
*!*		endif
*!*		UPDATE tsm_report SET elatis = qryTsm.summa WHERE lepingid = comTootajad.lepingId
	INSERT INTO tsm_report (elatis) values(qryTSM.summa)
	
	* liikmemaks
	tnLiik = 2
	tnElatis = 0
	tnLiikmemaks = 1
	odb.use ('qryTSMpens','qryTSM')

*!*		UPDATE tsm_report SET lm = qryTsm.summa WHERE lepingid = comTootajad.lepingId
	INSERT INTO tsm_report (lm) values(qryTSM.summa)

	* pensmaks
	tnLiik = 8
	tnElatis = 0
	tnLiikmemaks = 0
	tnArvSots = 0
	odb.use ('qryTSMPENS','qryTSM')

*	UPDATE tsm_report SET pm = qryTsm.summa WHERE lepingid = comTootajad.lepingId
	INSERT INTO tsm_report (pm) values(qryTSM.summa)

	* tkmaks
	tnLiik = 7
	tnElatis = 0
	tnLiikmemaks = 0
	odb.use ('qryTSMpens','qryTSM')
	INSERT INTO tsm_report (tm) values(qryTSM.summa)

*	UPDATE tsm_report SET tm = qryTsm.summa WHERE lepingid = comTootajad.lepingId

	* arvsmaks
	tnLiik = 1
	tnElatis = 0
	tnLiikmemaks = 0
	tnArvSots = 1
	odb.use ('qryTSM')
	
	INSERT INTO tsm_report (arvsm) values(qryTSM.summa)
*	UPDATE tsm_report SET arvsm = qryTsm.summa WHERE lepingid = comTootajad.lepingId

	* arvsmaks
	tnLiik = 5
	tnElatis = 0
	tnLiikmemaks = 0
	odb.use ('qryTSMpens','qryTSM')
	INSERT INTO tsm_report (sm) values(qryTSM.summa)
*	UPDATE tsm_report SET sm = qryTsm.summa WHERE lepingid = comTootajad.lepingId


endscan

SET STEP ON 
* group by isik

SELECT distinc isikukd FROM tsm_report INTO CURSOR qryIsik
SELECT qryIsik
SCAN
	SELECT comAsutusRemote
	LOCATE FOR ALLTRIM(regkood) = ALLTRIM(qryIsik.isikukd)
	INSERT INTO tsm_report1 (AaSTA , kuu,isikukd,  kpv1, kpv2, tululiik, palk, nimetus) ;
		SELECT aASTA , kuu,isikukd, kpv1, kpv2,tululiik, sum(palk), nimetus ;
		FROM tsm_report ;
		WHERE isikukd = qryIsik.isikukd AND palk <> 0;
		group by aASTA , kuu,isikukd, kpv1, kpv2,sm , arvsm , tululiik, nimetus
		
*	SELECT 	DISTINCT lepingid, sm , arvsm , tm ,  pm , elatis , lm, tulu  FROM tsm_report WHERE isikukd = qryIsik.isikukd INTO CURSOR qryMuudArv

*!*		SELECT sum(sm) as sm, sum(arvsm) as arvsm, sum(tm) as tm,  sum(pm) as pm  , sum(elatis) as elatis, sum(lm) as lm, sum(tulu) as tulu;
*!*			FROM qryMuudArv;
*!*			INTO CURSOR qryMuudArvSumma

*!*		SELECT  sum(tulu) as tulu;
*!*			FROM  tsm_report WHERE isikukd = qryIsik.isikukd;
*!*			INTO CURSOR qryMuudArvTulumaks

	SELECT sum(sm) as sm, sum(arvsm) as arvsm, sum(tm) as tm,  sum(pm) as pm  , sum(elatis) as elatis, sum(lm) as lm, sum(tulu) as tulu;
		FROM  tsm_report WHERE isikukd = qryIsik.isikukd;
		INTO CURSOR qryMuudArvSumma

		
	UPDATE 	tsm_report1 SET sm = qryMuudArvSumma.sm,;
		nimi = comAsutusremote.nimetus,;
		aadr = comAsutusremote.aadress,;
		arvsm = qryMuudArvSumma.arvsm,;
		tm = qryMuudArvSumma.tm,;
		pm = qryMuudArvSumma.pm,;
		elatis = qryMuudArvSumma.elatis,;
		lm = qryMuudArvSumma.lm WHERE tsm_report1.isikukd = qryisik.isikukd

		select tsm_report1
		LOCATE FOR tsm_report1.isikukd = qryisik.isikukd AND palk > 0
		replace tulu WITH qryMuudArvSumma.tulu IN tsm_report1

ENDSCAN

SELECT tsm_report
ZAP
APPEND FROM DBF('tsm_report1')
USE IN tsm_report1
SELECT tsm_report
SCAN FOR !EMPTY(tululiik)
	SELECT comTululiik
	LOCATE FOR kood = tsm_report.tululiik
	IF FOUND()
		replace nimetus WITH comtululiik.nimetus IN tsm_report
	endif
ENDSCAN

SELECT tsm_report
