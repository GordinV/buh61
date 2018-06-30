Parameter tcTest
* TSD 2015 lisa 1
Local lcString, tdKpv1, tdKpv2, l_parent, l_sm
l_sm = 0
ltest = .f.
IF (ltest)
	SET STEP on
	gnHandle = SQLCONNECT('NarvaLvPg')
	tdKPv1 = DATE(2018,01,01)
	tdKPv2 = DATE(2018,01,31)
	l_parent = 999999
	gRekv = 119
ELSE 
	tdKpv1 = fltrAruanne.kpv1
	tdKpv2 = fltrAruanne.kpv2
	l_parent = Iif(Empty(fltrAruanne.kond),999999,gRekv)

ENDIF

Create Cursor v_mvt(isikukood c(11), summa n(14,4), mvt N(14,4), tm n(14,4), tki n(14,4), pm n(14,4), tululiik c(2))
Index On isikukood Tag kood
Set Order To kood

Create Cursor tsd_report (isikukood c(20), nimi c(254), v1020 c(20), v1030 N(14,2) Null , v1040 N(14,2) Null,;
	v1050 c(100), v1060 N(14,2) Null , v1070 N(14,2) Null , v1080 N(14,2) Null, v1090 N(14,2) Null , ;
	v1100 N(14,2) Null, v1110 N(14,2) Null ,	v1120 N(14,2) Null , v1130 N(14,2) Null , v1140 N(14,2) Null , ;
	v1150 c(20),	v1160 N(14,2) Null , v1160_610 N(14,2) Null, v1160_620 N(14,2) Null, v1160_630 N(14,2) Null, v1160_640 N(14,2) Null,;
	v1170 N(14,2) Null , v1200 N(14,2) Null , v1210 N(14,2) Null, v1220 N(14,2) Null ,;
	v1230 N(14,2) Null , v1240 N(14,2) Null , v1250 N(14,2) Null )

*arvestame koormus

TEXT TO lcString noshow
SELECT a.regkood as isikukood, a.nimetus as isik, sum(koormus)::numeric / 100 as koormus ,
	max(coalesce(qryMinSots.arv_min_sots,0)) as arv_min_sots, max(coalesce(qryMinSots.min_sots_alus,0)) as min_sots_alus
	from tooleping t
	inner join asutus a on a.id = t.parentId
	inner join rekv on rekv.id = t.rekvId
	left outer join (
	select lepingid, rekvid, po.summa as arv_min_sots, po.sotsmaks as min_sots_alus
			from palk_oper po inner join palk_lib pl on pl.parentid = po.libid and pl.liik = 5 and po.sotsmaks <> 0
			where po.kpv >= ?tdKpv1 and po.kpv <= ?tdKpv2
	) qryMinSots on qryMinSots.lepingid = t.id and qryMinSots.rekvid = rekv.id
	where (rekv.Id = ?gRekv or rekv.parentId = ?l_parent)
	and algab <= ?tdKpv2
	and (lopp is null or lopp >= ?tdKpv1)
	and t.resident = 1
	group by a.regkood,  a.nimetus
ENDTEXT

 
lnError = SQLEXEC(gnhandle, lcString,'qryKoormus')
If lnError < 0 Then
	Wait Window 'Viga' Nowait
	Do err
	Select 0
	Return
Endif

TEXT TO lcString NOSHOW
	SELECT isikukood, isik, tululiik, liik,  riik, period,minsots,  sm_arv, tk_arv, minpalk,
		sum(summa) as summa, sum(puhkused) as puhkused, sum(haigused) as haigused, sum(tm) as tm, sum(sm) as sm, sum(tki) as tki, sum(pm) as pm, sum(tka) as tka, sum(tulubaas) as tulubaas,
		(select sum(sp_puudumise_paevad(?tdKpv2::date, tooleping.id)) from tooleping where tooleping.parentid = qry.id and tooleping.rekvid = qry.rekvid)::numeric as puhkus,
		(select sum(koormus) from tooleping where parentId = qry.id and rekvId = qry.rekvId and algab <= ?tdKpv2 and (empty(lopp) or lopp >= ?tdKpv1))::numeric / 100 as v1040,
		MAX(lopp) as lopp,
		max(arv_min_sots) as arv_min_sots, max(	 min_sots_alus) as  min_sots_alus
		from (
		select a.regkood as isikukood, a.nimetus as isik,
		po.summa as summa,
		(case when pl.liik = 1 and po_kood.kood ilike '%PUHKUS%' then po.summa else 0 end) as puhkused,
		(case when pl.liik = 1 and po_kood.kood ilike '%HAIGUS%' then po.summa else 0 end) as haigused,
		(po.tulumaks) as tm, (po.sotsmaks) as sm, (po.tootumaks) as tki, (po.pensmaks) as pm, (po.tka) as tka, (po.tulubaas) as tulubaas,
		pl.tululiik,pl.liik,
		coalesce(l.tun1,0) as tm_maar, coalesce(l.tun4,0) as tk_arv, coalesce(l.tun5,0) as pm_arv, coalesce(l.tun1,0) as tm_arv, coalesce(l.tun2,0) as sm_arv,
		 t.riik, po.period,
	 	(pc.minpalk * (
			select minsots
			from palk_kaart pk_
			inner join palk_lib pl_ on pl_.parentid = pk_.libid and pl_.liik = 5
			where lepingid = t.id
			and pk_.status = 1
			limit 1) * pc.sm / 100)    as minsots, pc.minpalk,
			a.id, t.rekvId, ifnull(t.lopp, date(2099,12,31)) as lopp,
			qryMinSots.arv_min_sots, qryMinSots.min_sots_alus
		from tooleping t
		inner join asutus a on a.id = t.parentid
		inner join palk_oper po on po.lepingid = t.id
		inner join palk_lib pl on pl.parentid = po.libId
		inner join library po_kood on po.libid = po_kood.id
		left outer join palk_kaart pk on pk.lepingId = t.id and pk.libid = po.libid
		inner join rekv on rekv.id = po.rekvid
		left outer join library l on l.kood = pl.tululiik and l.library = 'MAKSUKOOD'
		left outer join palk_config pc on pc.rekvid = rekv.id
		left outer join (select lepingid, rekvid, po.summa as arv_min_sots, po.sotsmaks as min_sots_alus
			from palk_oper po inner join palk_lib pl on pl.parentid = po.libid and pl.liik = 5 and po.sotsmaks <> 0
			where po.kpv >= ?tdKpv1 and po.kpv <= ?tdKpv2
		) qryMinSots on qryMinSots.lepingid = t.id and qryMinSots.rekvid = rekv.id

		where po.kpv >= ?tdKpv1 and po.kpv <= ?tdKpv2
		and period is null
		and pl.liik = 1
		and t.resident = 1
		and (rekv.id = ?gRekv or rekv.parentId = ?l_parent)) qry
	group by id, rekvId, isikukood, isik, tululiik, liik, riik, period, v1040, minsots, sm_arv, tk_arv, minpalk

ENDTEXT

* calender days
lnPaevadKuus = Day(Gomonth(Date(Year(tdKpv2), Month(tdKpv2), 1)  ,1) - 1)
lnError = SQLEXEC(gnhandle, lcString,'qryTSD')
If lnError < 0 Then
	Wait Window 'Viga' Nowait
	Do err
	Select 0
	Return
Else

	l_last_isikukood = ''

	Select qryKoormus.isikukood, qryKoormus.isik, Sum(Summa) As Summa, Sum(puhkused) As puhkused, Sum(haigused) As haigused, Sum(tm) As tm, Sum(sm) As sm, Sum(tki) As tki, Sum(tka) As tka,;
		sum(pm) As pm, Sum(tulubaas) As tulubaas, tululiik, riik, sm_arv, tk_arv, ;
		max(qryKoormus.koormus) As v1040, Sum(puhkus) As puhkus, Max(lopp) As lopp, Max(qryTsd.arv_min_sots) As arv_min_sots, ;
		max(qryTsd.min_sots_alus) As min_sots_alus;
		FROM qryTsd ;
		inner Join qryKoormus On Alltrim(qryKoormus.isikukood) = Alltrim(qryTsd.isikukood);
		WHERE (!Isnull(qryTsd.tululiik) And  qryTsd.tululiik <> '') ;
		GROUP By qryKoormus.isikukood, qryKoormus.isik, tululiik, riik, sm_arv, tk_arv ;
		ORDER By qryKoormus.isikukood, tululiik;
		INTO Cursor curTSD
	Select curTSD


	Scan
* 1090


		If l_last_isikukood <> curTSD.isikukood
			l_last_isikukood = curTSD.isikukood
			l_used_1090 = .F.
			l_used_mvt = .F.

		Endif

		l_sm = curTSD.sm
		Select Sum(qryTsd.sm) As sm, Max(minsots)As minsots, Max(minpalk) As minpalk, Sum(qryTsd.Summa) As Summa, ;
			sum((qryTsd.Summa - qryTsd.puhkused - qryTsd.haigused) * qryTsd.sm_arv) As sm_alus_summa, Max(lopp) As lopp From qryTsd ;
			Where isikukood = curTSD.isikukood ;
			And Isnull(qryTsd.period) Into Cursor tmpMaksud


		l_1090 = 0
		If !Isnull(curTSD.arv_min_sots) And l_used_1090 = .F.
			l_1090 = curTSD.min_sots_alus
			l_sm = curTSD.sm + curTSD.arv_min_sots
			l_used_1090 = .T.
		Endif

* Veerg 1040 täidetakse ainult koodidega 10, 11, 12 ja 13 väljamakse juuhul. Meie struktuuris kasutatakse enamasti 10 kood. Väljamaksetel koodidega 16, 17, 24, 33 jne veerg 1040 ei täideta. Näiteks Narva Kultuurimaja Rugodiv Turaeva Liudmila ik 47001043728 – kaks väljamakse koodi 10 ja 24. Mõlemal koodil on täidetud veerg 1040.
		ln_tululiik = Val(Alltrim(curTSD.tululiik))

		l_v1040 = Iif(curTSD.v1040 > 1, 1, Round(curTSD.v1040,2))
		If ln_tululiik > 13
*			curTSD.v1040 = 0
			l_v1040 = 0
		ENDIF
		
*!*			IF curTsd.isikukood = '47805312216'
*!*				SET STEP ON 
*!*			ENDIF
*!*			


		l_mvt = 0
* mvt
		lcAlias = Alias()
		If  l_used_mvt = .F.
			l_mvt = calcMVT(curTSD.isikukood)
			l_used_mvt  = .T.
		Endif

		Select v_mvt
		Locate For Alltrim(isikukood) =  Alltrim(curTSD.isikukood) AND ALLTRIM(tululiik) = Alltrim(curTSD.tululiik)
		l_mvt = v_mvt.mvt
		l_tm = v_mvt.tm
		
		Select (lcAlias)


* 1200, 1210, 1220
		Select Sum((curTSD.Summa) *  curTSD.sm_arv) As Summa, Sum(qryTsd.sm) As sm, Sum(qryTsd.tm) As tm, Sum(qryTsd.tki) As tki, ;
			sum(qryTsd.tka) As tka, Sum(qryTsd.pm) As pm ;
			FROM qryTsd Where qryTsd.liik = 1 And isikukood = curTSD.isikukood Into Cursor tmpMaksud

		Insert Into tsd_report (isikukood, nimi, v1020, v1030, v1040, v1050, v1060, v1070, v1080, v1090, ;
			v1100, v1110, v1120, v1130, v1140, v1150, v1160, ;
			v1160_610, v1160_620, v1160_630,v1160_640,	;
			v1170 ,v1200, v1210, v1220, v1230, v1240, v1250 ) ;
			values (curTSD.isikukood, curTSD.isik, curTSD.tululiik, (curTSD.Summa) , l_v1040, curTSD.riik,;
			(curTSD.Summa) * curTSD.sm_arv, 0,0, l_1090,;
			l_sm, curTSD.pm,(curTSD.Summa) * curTSD.tk_arv,curTSD.tki, curTSD.tka, ;
			'610', l_mvt, l_mvt,0,0,0, ;
			l_tm, tmpMaksud.Summa, tmpMaksud.sm, tmpMaksud.pm, tmpMaksud.tki, tmpMaksud.tka, l_tm)

	Endscan

* koormus mitte rohkem kui 1
	Update tsd_report Set v1040 = 1 Where v1040 > 1

* lisame isikud, kellel arvestused puuduvad, aga koormus on
	Select * From qryKoormus Where isikukood Not In ;
		(Select Distinct isikukood From tsd_report ;
		WHERE (!Empty(v1040) Or ;
		v1020 In ('10','17'))) ;
		INTO Cursor qryKoormusLisa

	Select qryKoormusLisa
	Scan
		Insert Into tsd_report (isikukood, nimi, v1020, v1040, v1090, v1100) ;
			VALUES (qryKoormusLisa.isikukood,  qryKoormusLisa.isik,'10',qryKoormusLisa.koormus, qryKoormusLisa.min_sots_alus,qryKoormusLisa.arv_min_sots )
	Endscan

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

IF (ltest)
	=SQLDISCONNECT(gnHandle)
ENDIF


Function calcMVT
Lparameters tcIsikukood
LOCAL l_found_miinus, lMVT, l_miinus_tululiik, l_miinus_mvt
lMVT = 0
l_found_miinus = .f.
l_miinus_tululiik = ''
l_miinus_mvt = 0

lcAlias = Alias()
Select tululiik, sum(curTsd.summa) as summa, Sum(curTSD.tulubaas) As mvt, sum(curTsd.tm) as tm, sum(curTsd.pm) as pm, sum(curTsd.tki) as tki ; 
	From curTSD Where curTSD.isikukood = tcIsikukood GROUP BY tululiik Into Cursor tmp
If Used('tmp') And Reccount('tmp') > 0
	lMVT = tmp.mvt
Endif

IF USED('v_mvt') 
	SELECT tmp
	SCAN
		IF (tmp.mvt < 0)
			l_found_miinus = .t.
		ENDIF
		
		INSERT INTO v_mvt (isikukood, summa, mvt, tm, pm, tki, tululiik) VALUES (tcIsikukood, tmp.summa, tmp.mvt, tmp.tm, tmp.pm, tmp.tki, tmp.tululiik)
	ENDSCAN
	IF (l_found_miinus) 
		* parandame
		DO WHILE l_found_miinus
			l_found_miinus = updateMiinusMVT(tcIsikukood)
		ENDDO
		
	ENDIF
	
ENDIF
Use In tmp
SELECT(lcAlias)
Return lMVT
ENDFUNC


FUNCTION updateMiinusMVT
	LPARAMETERS tcIsikukood
	IF !USED('v_mvt')
		RETURN .f.
	ENDIF

	SELECT tululiik, summa as summa,  MIN(mvt) as mvt, (tm) as tm, (tki) as tki, (pm) as pm FROM v_mvt ;
		WHERE ALLTRIM(isikukood) = ALLTRIM(tcIsikukood) AND mvt < 0 GROUP BY tululiik, tm, summa, tki, pm INTO CURSOR t_mvt_min

	SELECT tululiik, (summa) as summa, (pm) as pm, (tki) as tki,  MAX(mvt) as mvt, tm FROM v_mvt ;
		WHERE ALLTRIM(isikukood) = ALLTRIM(tcIsikukood) AND mvt > 0 GROUP BY tululiik, tm, summa, tki, pm INTO CURSOR t_mvt_max
	IF RECCOUNT('t_mvt_min') =0 OR RECCOUNT('t_mvt_max') = 0
		RETURN .f.
	ENDIF
	 * nullime miinus
	 l_tm = calc_tm(t_mvt_min.summa, 0, t_mvt_min.tki, t_mvt_min.pm)
	 
	UPDATE v_mvt SET mvt = 0, tm = l_tm WHERE ALLTRIM(isikukood) = ALLTRIM(tcIsikukood) AND ALLTRIM(tululiik) = ALLTRIM(t_mvt_min.tululiik)
	* parandame pluus
	* arvestame tm
	l_tm = calc_tm(t_mvt_max.summa, (t_mvt_max.mvt + t_mvt_min.mvt), t_mvt_max.tki, t_mvt_max.pm) 
	UPDATE v_mvt SET mvt = (t_mvt_max.mvt + t_mvt_min.mvt), tm = l_tm WHERE ALLTRIM(isikukood) = ALLTRIM(tcIsikukood) AND ALLTRIM(tululiik) = ALLTRIM(t_mvt_max.tululiik)
	
	USE IN t_mvt_max
	USE IN t_mvt_min
	SELECT 	v_mvt
	RETURN .t.
	
ENDFUNC


FUNCTION calc_tm
LPARAMETERS tnSumma, tnMvt, tnTki, tnPm
LOCAL l_tm
l_tm = 0

l_tm = ROUND((tnSumma - tnMvt - tnTki - tnPm) * 0.20,2)
RETURN l_tm
ENDFUNC
