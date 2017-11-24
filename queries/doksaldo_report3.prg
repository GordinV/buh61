Parameter cWhere

SET STEP ON 
create cursor doksaldo_report1 (arvid int, number c(120), kpv d, asutus c(120),asutusid int, liik int, summa y,;
 tasu y, jaak y, konto c(20), algdb y, algkr y, db n(18,4), kr n(18,4), loppdb n(18,4), loppkr n(18,4))
index on arvid tag arvid
index on left(upper(asutus),40)+'-'+ALLTRIM(konto)+dtoc(kpv,1) tag kpv


if !empty (fltrAruanne.asutusId)
	tnId = fltrAruanne.asutusId
	oDb.use ('v_asutus','qryAsutus')
	tcAsutus = ltrim(rtrim(qryAsutus.nimetus))+'%'
	use in qryAsutus
else
	tcAsutus = '%'
endif
tcNumber = '%%'
tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2
tcKonto = fltrAruanne.konto
tdTaht1 = gomonth(date(year(date()),1,1),-1200)
tdTaht2 = gomonth(date(year(date()),1,1),1200)
tnSumma1 = -9999999999
tnSumma2 = 999999999
tdTasud1 = gomonth(date(year(date()),1,1),-1200)
tdTasud2 = gomonth(date(year(date()),1,1),1200)
tnLiik = 0

tnObjekt1 = 0
tnObjekt2 = 999999999
tcAmetnik = '%'

* varaanet 29.08.2012

lcString = "select count(*) as count from pg_proc where proname = 'sp_kaibeandmik_report'"
lError = oDb.execsql(lcString, 'tmpProc')
If !Empty (lError) And Used('tmpProc') And !empty(tmpProc.Count)
			wait window 'Serveri poolt funktsioon ...' nowait
			
*select sp_kaibeandmik_report('%', 6, date(2012,07,01), date(2012,07,31), '%', 2, 0)
			
		lError = oDb.Exec("sp_kaibeandmik_report ", "'%',"+Str(grekv)+;
			", DATE("+Str(Year(fltrAruanne.kpv1),4)+","+STR(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+"),"+;
			" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
			"'%',2,"+Str(fltrAruanne.kond,9),"qryDokKaibed")

		If Used('qryDokKaibed')
			lcTimestamp = Alltrim(qryDokKaibed.sp_kaibeandmik_report)

			lcString = "select lausend as arvid, asutusid, asutus, regkood, konto, algdb, algkr, db, kr, loppdb, loppkr, dok from tmp_kaibeandmik_report "+;
				" where timestamp = '"+lcTimestamp+"'"+;
				" and konto like '"+ALLTRIM(tcKonto)+"%'"+;
				" and UPPER(asutus) like '"+UPPER(tcAsutus)+"%'"+;
				" order by asutus, konto, arvid "
			lError = oDb.Execsql(lcString, 'tmpdok')
			IF lError < 0 OR !USED('tmpDok')
				SELECT 0
				RETURN .f.
			ENDIF 
			INSERT INTO doksaldo_report1 (arvid, number, asutus,asutusid,konto, algdb , algkr, db, kr, loppdb, loppkr ) ;
			SELECT arvid, dok, asutus, asutusid,konto, ROUND(algdb/fltrPrinter.kuurs,2), ROUND(algkr/fltrPrinter.kuurs,2),;
				ROUND(db/fltrPrinter.kuurs,2), ROUND(kr/fltrPrinter.kuurs,2), ROUND(loppdb/fltrPrinter.kuurs,2),ROUND(loppkr/fltrPrinter.kuurs,2);
				 FROM tmpDok			
			SELECT doksaldo_report1
			RETURN .t.
		ENDIF
		

ENDIF

oDb.use('curArved','qryArv')
select qryArv
SCAN
	IF EMPTY(tcKonto) OR qryarv.konto = tcKonto
		insert into doksaldo_report1 (arvid, number, kpv, asutus, asutusid, liik, summa, jaak, konto) values;
			(qryArv.id, qryarv.number, qryarv.kpv, qryArv.asutus, qryArv.asutusid, 0, qryarv.summa, qryarv.summa, qryarv.konto)
	ENDIF	
endscan
tnLiik = 1
oDb.dbreq('qryArv',gnHandle,'curArved')
select qryArv
SCAN
	IF EMPTY(tcKonto) OR qryarv.konto = tcKonto

		insert into doksaldo_report1 (arvid,number, kpv, asutus, asutusid, liik, summa, jaak, konto) values;
		(qryArv.id,qryarv.number, qryarv.kpv, qryArv.asutus, qryArv.asutusid, 1, qryarv.summa, qryArv.summa, qryarv.konto)
	ENDIF
	
ENDSCAN

tcDok = '%%'
tcNumber = '%%'
tnSumma1 = -99999999999
tnSumma2 = 99999999999
select doksaldo_report1
set order to arvid
oDb.use('curArvTasud','qryArvTasud')
select qryArvTasud
scan
	select doksaldo_report1
	seek qryArvTasud.arvid
	if found ()
		replace tasu with tasu + qryArvTasud.summa,;
			jaak with summa - tasu in doksaldo_report1
	endif
endscan
use in qryArvTasud
use in qryArv

* alg.saldo

SELECT DISTINCT konto, asutusId  FROM doksaldo_report1 ORDER BY konto, asutusId GROUP BY konto, asutusId INTO CURSOR tmpAruanne
SELECT tmpAruanne
scan
	lError = oDb.Exec("sp_subkontod_report "," '"+Ltrim(Rtrim(tmpAruanne.konto))+"%',"+;
		Str(grekv)+","+;
		" DATE("+Str(Year(fltrAruanne.kpv1),4)+","+ Str(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+"),"+;
		" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+	Str(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
		STR(tmpAruanne.asutusId,9)+",'%',2","qryKbAsu")

	If Used('qryKbAsu')
		tcTimestamp = Alltrim(qryKbAsu.sp_subkontod_report)
		oDb.Use('tmpsubkontod_report')

		Select doksaldo_report1

		Insert Into doksaldo_report1 (kpv, asutus, asutusid, algdb, konto );
			SELECT fltrAruanne.kpv1, tmpsubkontod_report.asutus, tmpsubkontod_report.asutusId, tmpsubkontod_report.algjaak,	tmpsubkontod_report.konto;
			FROM tmpsubkontod_report WHERE tmpsubkontod_report.algjaak <> 0 AND asutusId <> 0 AND !EMPTY(tmpsubkontod_report.konto)
			

		Use In qryKbAsu
		Use In tmpsubkontod_report
	Endif
ENDSCAN




select doksaldo_report1
IF !EMPTY(fltrAruanne.konto)
	DELETE FROM doksaldo_report1 WHERE konto <> fltrAruanne.konto
ENDIF
set order to kpv
