Local lnSotsmaks, lnSotsmaar, lnBaas, lnMinPalk
lnBaas = 0
lnSotsmaks = 0
With oDb
	If !used('palk_config')
		.use('v_palk_config','palk_config')
	Endif
	tnId = v_palk_kaart.lepingId
	If !used ('qryTooleping')
		.use ('qryTooleping')
	Else
		.dbreq('qryTooleping',gnHandle,'qryTooleping')
	Endif
	tnId = v_palk_kaart.LibId
	If !used ('qryPalkLib')
		.use ('v_palk_lib','qryPalkLib')
	Else
		.dbreq('qryPalkLib',gnHandle,'v_Palk_Lib')
	Endif
	tnId = qryTooleping.ametId
	If !used ('qryAmet')
		.use ('v_library','qryAmet')
	Else
		.dbreq('qryAmet',gnHandle,'v_library')
	Endif

	tcOsakond = '%'
	tcAmet = rtrim(qryAmet.nimetus)+'%'
	tcisik = rtrim(comAsutusremote.nimetus)+'%'
	tnKokku1 = 0
	tnKokku2 = 9999
	tnToo1 = 0
	tnToo2 = 9999
	tnPuhk1 = 0
	tnPuhk2 = 9999
	tnKuu1 = gnkuu
	tnKuu2 = gnkuu
	tnAasta1 = gnaasta
	tnAasta2 = gnaasta
	tdKpv1 = date (gnaasta, gnkuu, 1)
	tdKpv2 = gomonth (date (gnaasta, gnkuu, 1),1) - 1
	tnLepingId = v_palk_kaart.lepingId
	If !used ('qryTaabel1')
		.use ('curTaabel1','qryTaabel1')
	Else
		.dbreq('qryTaabel1',gnHandle,'curTaabel1')
	Endif
	Select qryTaabel1
	Locate for tooleping = v_palk_kaart.lepingId

	nHours = workdays(1) * qryTooleping.koormus * 0.01 * qryTooleping.toopaev
	tdKpv1 = date (gnaasta,gnkuu,1)
	tdKpv2 = gomonth (date (gnaasta,gnkuu,1),1) - 1
	If v_palk_kaart.percent_ = 1
		Do case
			Case qryPalkLib.palgafond = 0
				nPalk = qryTooleping.palk * 0.01 * qryTooleping.toopaev * (qryTaabel1.kokku / nHours)
			Case qryPalkLib.palgafond = 1
				.use ('qryPalgafond')
				nPalk = iif(isnull(qryPalgafond.summa),0,qryPalgafond.summa)
				Use in qryPalgafond
		Endcase
		lnSumma = f_round(v_palk_kaart.summa * 0.01 * nPalk,'+', qryPalkLib.round)
	Else
		lnSumma = f_round(v_palk_kaart.Summa,'+',qryPalkLib.round)
	Endif


	If lnSumma > 0
		If !used ('v_palk_oper')
			.use ('v_palk_oper', 'v_palk_oper',.t.)
		Endif

		If reccount ('v_palk_oper') < 1
			Insert into v_palk_oper (rekvid, LibId, lepingId, kpv, summa);
				values (gRekv,qryPalkLib.id,v_palk_kaart.lepingId,gdKpv,lnSumma)
		Else
			If !empty (v_palk_oper.LibId) and !empty (v_palk_oper.lepingId)
				Replace summa with lnSumma,;
					kpv with gdKpv  in v_palk_oper
			Else
				Replace v_palk_oper.LibId with qryPalkLib.id,;
					lepingId with v_palk_kaart.lepingId,;
					kpv with gdKpv,;
					summa with lnSumma in v_palk_oper
			Endif
		Endif

	Endif
Endwith
Return lnSumma
