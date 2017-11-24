Parameter tnId, tnKuu, tnAasta
Local  lnHours
If empty (tnId) and used ('v_taabel1')
	tnId = v_taabel1.Tooleping
Endif
If empty (tnKuu)
	If empty (gnKuu)
		Do form period
	Endif
	If empty (gnKuu)
		Return .f.
	Endif
	tnKuu = gnKuu
Endif
If empty (tnAasta) and used ('v_taabel1')
	tnAasta = gnaasta
Endif
lnHours = 0
lnreturn = 0
lnHoliday = 0
lnId = tnId
With oDb
	If !used ('qryTooleping')
		.use ('qryTooleping','qryTooleping')
	Else
		.dbreq('qryTooleping',gnhandle,'qryTooleping')
	Endif
	If month (qryTooleping.algab ) = gnKuu and year (qryTooleping.algab) = gnaasta
		nPaev = day (qryTooleping.algab)
	Else
		nPaev = 1
	Endif
Endwith
lnPuhkus = check_puhkus()
lnHaigus = check_haigus()
lnWorkDays = workdays(nPaev, gnKuu, gnAasta, 31, tnId)
lnHours = (lnworkdays - (lnpuhkus + lnhaigus)) * qryTooleping.toopaev
If used ('v_taabel1')
	Replace paev with lnHours,;
		kokku with lnHours,;
		too with lnHours in v_taabel1
Endif
if used ('qryTooleping')
	use in qryTooleping
endif
Return lnHours


Function check_puhkus
	Local lnStartKpv, lnLoppKpv, lresult

	lresult = 0
	If !used ('qryPuhkused')
		tdKpv1_1 =  gomonth(date (tnAasta,tnKuu,1),-3)
		tdKpv1_2 =  gomonth(date (tnAasta,tnKuu,1),3)
		tdKpv2_1 = tdKpv1_1
		tdKpv2_2 = tdKpv1_2
		tnpaevad1 = 0
		tnpaevad2 = 9999
		tcAmet = '%'
		tcisik = '%'
		tcPohjus = 'PUHKUS%'
		tcLiik = '%'
		oDb.use ('curPuudumine','qryPuhkused')
		If used ('curPuudumine_')
			Use in curPuudumine_
		Endif
	Endif
	Select qryPuhkused
	Scan for lepingid = tnId and ((month(kpv1) = tnKuu and year (kpv1) = tnAasta) or ;
			(month(kpv2) = tnKuu and year (kpv2) = tnAasta))
		If month (qryPuhkused.kpv1) = tnKuu and year (qryPuhkused.kpv1) = tnAasta
			lnStartKpv = day (qryPuhkused.kpv1)
		Else
			lnStartKpv = 1
		Endif
		If month (qryPuhkused.kpv2) = tnKuu and year (qryPuhkused.kpv2) = tnAasta
			lnLoppKpv = day (qryPuhkused.kpv2)
		Else
			lnLoppKpv = gomonth(date(tnAasta, tnKuu,1),1) - 1
		Endif
		lresult = lresult + workdays(lnStartKpv, tnKuu, tnAasta, lnLoppKpv)
	Endscan
	If used ('qryPuhkused')
		Use in qryPuhkused
	Endif

	Return lresult

Function check_haigus
	Local lnStartKpv, lnLoppKpv, lresult

	lresult = 0
	If !used ('qryPuhkused')
		tdKpv1_1 =  gomonth(date (tnAasta,tnKuu,1),-3)
		tdKpv1_2 =  gomonth(date (tnAasta,tnKuu,1),3)
		tdKpv2_1 = tdKpv1_1
		tdKpv2_2 = tdKpv1_2
		tnpaevad1 = 0
		tnpaevad2 = 9999
		tcAmet = '%'
		tcisik = '%'
		tcPohjus = 'HAIGUS%'
		tcLiik = '%'
		oDb.use ('curPuudumine','qryPuhkused')
		If used ('curPuudumine_')
			Use in curPuudumine_
		Endif
	Endif
	Select qryPuhkused
	Scan for lepingid = tnId and ((month(kpv1) = tnKuu and year (kpv1) = tnAasta) or ;
			(month(kpv2) = tnKuu and year (kpv2) = tnAasta))
		If month (qryPuhkused.kpv1) = tnKuu and year (qryPuhkused.kpv1) = tnAasta
			lnStartKpv = day (qryPuhkused.kpv1)
		Else
			lnStartKpv = 1
		Endif
		If month (qryPuhkused.kpv2) = tnKuu and year (qryPuhkused.kpv2) = tnAasta
			lnLoppKpv = day (qryPuhkused.kpv2)
		Else
			lnLoppKpv = day(gomonth(date(tnAasta, tnKuu,1),1) - 1)
		Endif
		lresult = lresult + workdays(lnStartKpv, tnKuu, tnAasta, lnLoppKpv)
	Endscan
	If used ('qryPuhkused')
		Use in qryPuhkused
	Endif
	Return lresult
