Parameter cWhere

CREATE CURSOR Laduraamat_report1 (nomid int,kood c(20), nimetus c(254), uhik c(20), hind n(14,4), akogus n(14,2), asumma n(18,6))
INDEX ON kood TAG kood
SET ORDER TO kood

*!*	tcOper = '%'+rtrim(ltrim(fltrLaduArved.oper))+'%'
*!*	tcKood = '%'+rtrim(ltrim(fltrLaduArved.kood))+'%'
*!*	tcNumber = '%'+rtrim(ltrim(fltrLaduArved.number))+'%'
*!*	tcAsutus = '%'+rtrim(ltrim(fltrLaduArved.asutus))+'%'
*!*	tdKpv1 = iif(empty(fltrLaduArved.kpv1),date(year(date()),1,1),fltrLaduArved.kpv1)
*!*	tdKpv2 = iif(empty(fltrLaduArved.kpv2),date(year(date()),12,31),fltrLaduArved.kpv2)
*!*	tnKogus1 = iif(empty(fltrLaduArved.kogus1),-999999999,fltrLaduArved.kogus1)
*!*	tnKogus2 = iif(empty(fltrLaduArved.kogus2),999999999,fltrLaduArved.kogus2)
*!*	tnSumma1 = iif(empty(fltrLaduArved.Summa1),-999999999,fltrLaduArved.Summa1)
*!*	tnSumma2 = iif(empty(fltrLaduArved.Summa2),999999999,fltrLaduArved.Summa2)
*!*	tnLiik = 1
*!*	oDb.use('curLaduArved','Laduraamat_reportS')
*!*	&&use (cQuery) in 0 alias arve_report2
*!*	tnLiik = 2
*!*	select curLaduArved
*!*	oDb.use('curLaduArved','Laduraamat_reportV')

*!*		select distinct nomid FROM Laduraamat_reportS;
*!*		union all;
*!*		select distinct nomid FROM Laduraamat_reportV;
*!*		INTO CURSOR tmp


*!*	SELECT MIN(nomid) as min, MAX(nomid) as max FROM tmp INTO CURSOR tmpNom
*!*	USE IN tmp
*SET STEP ON 
*!*	* algkogus
*tdKpv2 = iif(empty(fltrLaduArved.kpv1),date(year(date()),1,1),fltrLaduArved.kpv1)
tdKpv2 = fltrLaduArved.kpv2+1
lcString = "select sp_ladu_aruanne1("+STR(grekv)+",DATE("+STR(YEAR(tdKpv2),4)+","+STR(MONTH(tdKpv2),2)+","+STR(DAY(tdKpv2),2)+"),DATE(),'%','%"+;
	ALLTRIM(fltrLaduArved.kood)+"%',1)"
lnError = SQLEXEC(gnHandle,lcString,'tmp')
IF lnError > 0 AND USED('tmp')
	lcString = "select algdb-algkr as kogus, db-kr as summa, lausend as nomId from tmp_kaibeandmik_report where algdb-algkr <> 0 and timestamp = '"+;
		ALLTRIM(tmp.sp_ladu_aruanne1) +"'"

	lnError = SQLEXEC(gnHandle,lcString,'tmpLadu')

ENDIF


SELECT tmpLadu
INSERT into Laduraamat_report1 (nomid,kood, nimetus, uhik, hind, akogus , asumma) ;
select tmpLadu.nomid, comNomremote.kood, comNomremote.nimetus, comNomremote.uhik, comNomremote.hind, tmpLadu.kogus, tmpLadu.summa ;
	FROM tmpLadu LEFT OUTER JOIN comNomRemote ON tmpLadu.nomId = comNomremote.id
IF USED('tmpLadu')
	USE IN tmpLadu
ENDIF

SELECT Laduraamat_report1