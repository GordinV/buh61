Parameter tcWhere
* TSD 2015 lisa 1
*SET STEP ON
Local lcString, tdKpv1, tdKpv2, l_parent, l_sm
l_sm = 0
tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2
l_parent = Iif(Empty(fltrAruanne.kond),999999,gRekv)

Create cursor tsd_report (isikukood c(20), nimi c(254), v1020 c(20), v1030 N(14,2) NULL , v1040 N(14,2) NULL,;
	v1050 c(100), v1060 N(14,2) NULL , v1070 N(14,2) NULL , v1080 N(14,2) NULL, v1090 N(14,2) NULL , ;
	v1100 N(14,2) NULL, v1110 N(14,2) NULL ,	v1120 N(14,2) NULL , v1130 N(14,2) NULL , v1140 N(14,2) NULL , ;
	v1150 c(20),	v1160 N(14,2) NULL , v1160_610 N(14,2) NULL, v1160_620 N(14,2) NULL, v1160_630 N(14,2) NULL, v1160_640 N(14,2) NULL,;
	v1170 N(14,2) NULL , v1200 N(14,2) NULL , v1210 N(14,2) NULL, v1220 N(14,2) NULL ,;
	v1230 N(14,2) NULL , v1240 N(14,2) NULL , v1250 N(14,2) NULL )

INDEX ON isikukood TO tsd_report 
SET ORDER TO isikukood 


*!*
*!*		,;
*!*		v2000 c(20), v2010 v(254), v2020 c(20), v2030 c(20), v2040 n(14,2),v2050 n(14,2), v2060 c(20), v2070 n(14,2), v2080 n(14,2),;
*!*		v2090 n(14,2), v2100 n(14,2), v2110 n(14,2), v2120 n(14,2), v2130 n(14,2), v2140 n(14,2), v2150 n(14,2), v2160 n(14,2), v2170
*!*
*!*		 )
*SET STEP ON 
*arvestame koormus

TEXT TO lcString noshow
SELECT a.regkood as isikukood, a.nimetus as isik, sum(koormus)::numeric / 100 as koormus 
	from tooleping t
	inner join asutus a on a.id = t.parentId
	inner join rekv on rekv.id = t.rekvId
	where (rekv.Id = ?gRekv or rekv.parentId = ?l_parent)
	and algab <= ?tdKpv2 
	and (lopp is null or lopp >= ?tdKpv2)
	group by a.regkood,  a.nimetus
ENDTEXT


lnError = SQLEXEC(gnhandle, lcString,'qryKoormus')
If lnError < 0 Then
	Wait Window 'Viga' Nowait
	Do err
	SELECT 0
	return
ENDIF



TEXT TO lcString NOSHOW
SELECT isikukood, isik, tululiik, liik, palk_maar, riik, period,minsots,  sm_arv, tk_arv, minpalk,
	sum(summa) as summa, sum(tm) as tm, sum(sm) as sm, sum(tki) as tki, sum(pm) as pm, sum(tka) as tka, sum(tulubaas) as tulubaas, 
	sum(puudumine) as puhkus,
	(select sum(koormus) from tooleping where parentId = qry.id and rekvId = qry.rekvId and algab <= ?tdKpv2 and (empty(lopp) or lopp >= ?tdKpv2))::numeric / 100 as v1040	
	from (
	select a.regkood as isikukood, a.nimetus as isik,
	(po.summa) as summa, (po.tulumaks) as tm, (po.sotsmaks) as sm, (po.tootumaks) as tki, (po.pensmaks) as pm, (po.tka) as tka, (po.tulubaas) as tulubaas,
	pl.tululiik,pl.liik,
	coalesce(l.tun1,0) as tm_maar, coalesce(l.tun4,0) as tk_arv, coalesce(l.tun5,0) as pm_arv, coalesce(l.tun1,0) as tm_arv, coalesce(l.tun2,0) as sm_arv,
	(case when tasuliik = 2 then t.palk else 0 end ) as palk_maar, t.riik, po.period,
 	(pc.minpalk * (
		select minsots 
		from palk_kaart pk_ 
		inner join palk_lib pl_ on pl_.parentid = pk_.libid and pl_.liik = 5 
		where lepingid = t.id 
		and pk_.status = 1 
		limit 1) * pc.sm / 100)    as minsots, pc.minpalk, sp_puudumise_paevad(?tdKpv2::date, t.id)::numeric as puudumine ,
		a.id, t.rekvId, pk.minsots as arvesta_min_sots
	from tooleping t
	inner join asutus a on a.id = t.parentid
	inner join palk_oper po on po.lepingid = t.id
	inner join palk_lib pl on pl.parentid = po.libId
	left outer join palk_kaart pk on pk.lepingId = t.id and pk.libid = po.libid
	inner join rekv on rekv.id = po.rekvid
	left outer join library l on l.kood = pl.tululiik and l.library = 'MAKSUKOOD'
	left outer join palk_config pc on pc.rekvid = rekv.id 
	where po.kpv >= ?tdKpv1 and po.kpv <= ?tdKpv2
	and period is null
	and pl.liik = 1
	and (rekv.id = ?gRekv or rekv.parentId = ?l_parent)) qry
	group by id, rekvId, isikukood, isik, tululiik, liik, palk_maar, riik, period, v1040, minsots, sm_arv, tk_arv, minpalk
ENDTEXT

* calender days
lnPaevadKuus = DAY(GOMONTH(DATE(YEAR(tdKpv2), MONTH(tdKpv2), 1)  ,1) - 1)

lnError = SQLEXEC(gnhandle, lcString,'qryTSD')
If lnError < 0 Then
	Wait Window 'Viga' Nowait
	Do err
	SELECT 0
	return
ELSE
	Select qryKoormus.isikukood, qryKoormus.isik, Sum(summa) As Summa, Sum(tm) As tm, Sum(sm) As sm, Sum(tki) As tki, Sum(tka) As tka,;
		sum(pm) As pm, Sum(tulubaas) As tulubaas, tululiik, palk_maar, riik, sm_arv, tk_arv, ;
		sum(qryKoormus.koormus) as v1040, sum(puhkus) as puhkus ;
		FROM qryTsd ;
		left outer join qryKoormus on qryKoormus.isikukood = qryTsd.isikukood;
		WHERE (!Isnull(qryTsd.tululiik) And  qryTsd.tululiik <> '') ;
		GROUP By qryKoormus.isikukood, qryKoormus.isik, tululiik, palk_maar, riik, sm_arv, tk_arv ;
		ORDER BY qryKoormus.isikukood, tululiik;
		INTO Cursor curTSD
	Select curTSD
	l_last_isikukood = ''

	Scan
* 1090	if 
		l_sm = curTSD.sm
		Select Sum(qryTsd.sm) As sm, MAX(minsots)as minsots, MAX(minpalk) as minpalk, sum(qryTsd.summa) as summa, ;
			sum(qryTsd.summa * qryTsd.sm_arv) as sm_alus_summa From qryTsd ;
			Where isikukood = curTSD.isikukood ;
			And Isnull(qryTsd.period) Into Cursor tmpMaksud
			
*!*				IF curTsd.isikukood = '36905123715'
*!*					SET STEP ON 
*!*				ENDIF
		 	
		 	SELECT arvesta_min_sots FROM qryTsd WHERE qryTsd.isikukood = curTsd.isikukood AND !EMPTY(qryTsd.arvesta_min_sots) INTO CURSOR qryArvestaMinSots
		 	
		IF (EMPTY(l_last_isikukood) OR l_last_isikukood <> curTsd.isikukood ) AND (tmpmaksud.sm_alus_summa < tmpMaksud.minpalk) AND tmpMaksud.minsots > 0 AND RECCOUNT('qryArvestaMinSots') > 0 OR (tmpMaksud.sm > 0 AND tmpMaksud.summa = 0)
			
			* salvestame isikukood ja kasutatud min.sots
			l_last_isikukood = curTsd.isikukood
			l_sm = (tmpMaksud.minpalk / 30 * (lnPaevadKuus - IIF(ISNULL(curTsd.puhkus),0,curTsd.puhkus))) * 0.33

			l_1090 = (tmpMaksud.minpalk / 30 * (lnPaevadKuus - IIF(ISNULL(curTsd.puhkus),0,curTsd.puhkus))) - tmpMaksud.sm_alus_summa

			
			
		ELSE 
			l_1090 = 0
		ENDIF
		IF l_1090 < 0 then
			l_1090 = 0
			l_sm = curTSD.sm
		ENDIF
		
		* Veerg 1040 t�idetakse ainult koodidega 10, 11, 12 ja 13 v�ljamakse juuhul. Meie struktuuris kasutatakse enamasti 10 kood. V�ljamaksetel koodidega 16, 17, 24, 33 jne veerg 1040 ei t�ideta. N�iteks Narva Kultuurimaja Rugodiv Turaeva Liudmila ik 47001043728 � kaks v�ljamakse koodi 10 ja 24. M�lemal koodil on t�idetud veerg 1040.
		ln_tululiik = VAL(ALLTRIM(curTSD.tululiik)) 
		l_v1040 = IIF(curTSD.v1040 > 1, 1, ROUND(curTSD.v1040,2))
		IF ln_tululiik > 13 
*			curTSD.v1040 = 0
			l_v1040 = 0
		ENDIF
		   

	* 1200, 1210, 1220
		Select Sum(Summa *  curTSD.sm_arv) As Summa, Sum(qryTsd.sm) As sm, Sum(qryTsd.tm) As tm, Sum(qryTsd.tki) As tki, ;
			sum(qryTsd.tka) As tka, Sum(qryTsd.pm) As pm ;
			FROM qryTsd Where qryTsd.liik = 1 And isikukood = curTSD.isikukood Into Cursor tmpMaksud

		Insert Into tsd_report (isikukood, nimi, v1020, v1030, v1040, v1050, v1060, v1070, v1080, v1090, ;
			v1100, v1110, v1120, v1130, v1140, v1150, v1160, ;
			v1160_610, v1160_620, v1160_630,v1160_640,	;
			v1170 ,v1200, v1210, v1220, v1230, v1240, v1250 ) ;
			values (curTSD.isikukood, curTSD.isik, curTSD.tululiik, curTSD.Summa, l_v1040, curTSD.riik,;
			curTSD.Summa * curTSD.sm_arv, 0,0, l_1090, l_sm, curTSD.pm, curTSD.Summa * curTSD.tk_arv,;
			curTSD.tki, curTSD.tka, '610', curTSD.tulubaas, ;
			curTSD.tulubaas,0,0,0, ;
			curTSD.tm,tmpMaksud.Summa, tmpMaksud.sm, tmpMaksud.pm, tmpMaksud.tki, tmpMaksud.tka, tmpMaksud.tm)

	ENDSCAN
	
	* lisame isikud, kellel arvestused puuduvad, aga koormus on
	SELECT * from qryKoormus WHERE isikukood NOT in (select DISTINCT isikukood FROM tsd_report WHERE !EMPTY(v1040)) INTO CURSOR qryKoormusLisa

	SELECT qryKoormusLisa
	scan
		Insert Into tsd_report (isikukood, nimi, v1020, v1040) ;
			VALUES (qryKoormusLisa.isikukood,  qryKoormusLisa.isik,'10',qryKoormusLisa.koormus)
	endscan		
	
Endif


If Used('qryTSD')
	Use In qryTsd
Endif

If Used('qryKoormus')
	Use In qryKoormus
Endif

If Used('qryKoormusLisa')
	Use In qryKoormusLisa
Endif

Select tsd_report
*brow
