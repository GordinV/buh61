Local lnPalk, lnBaas, lcTund, nPalk
nPalk = 0
lnPalk = 0
lnBaas = 0
lcTund = ''
tnId = v_palk_kaart.lepingId
tnLepingId = v_palk_kaart.lepingId
select comAsutusRemote
locate for id = v_palk_kaart.parentid
with oDb
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
nHours = workdays(1, gnKuu, gnAasta, 31,v_palk_kaart.lepingId) * qryTooleping.koormus * 0.01 * qryTooleping.toopaev
Do case
	Case qryPalkLib.palgafond = 0
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
		If !used ('qryTaabel1')
			.use ('curTaabel1','qryTaabel1')
		Else
			.dbreq('qryTaabel1',gnHandle,'curTaabel1')
		Endif
		Select qryTaabel1
		Locate for tooleping = v_palk_kaart.lepingId

		nPalk = qryTooleping.palk * 0.01 * qryTooleping.tooPAEV * (qryTaabel1.kokku / nHours)
	Case qryPalkLib.palgafond = 1
		tdKpv1 = date (gnaasta,gnkuu,1)
		tdKpv2 = gomonth (date (gnaasta,gnkuu,1),1) - 1
&&		.use ('qryPalgafond')
		.use ('qrySotsfond','qryPalgafond')		
		nPalk = iif(isnull(qryPalgafond.summa),0,qryPalgafond.summa)
		Use in qryPalgafond
Endcase

If qryPalkLib.maks = 1
&& После налогообложения
	If !used ('qryKuluMaks')
		.use ('qryKuluMaks')
	Else
		.dbreq ('qryKuluMaks', gnHandle,'qryKuluMaks')
	Endif
	lnkulumaks = iif (isnull(qryKuluMaks.summa), 0, qryKuluMaks.summa)
Else
	lnkulumaks = 0
Endif
nPalk = nPalk - lnkulumaks

If !empty(v_palk_kaart.percent_) && в процентах от базиса начисления
	lnPalk = f_round(nPalk * (0.01 * v_palk_kaart.summa),'-',qryPalkLib.round)
	lnBaas = nHours
	lcTund = 'TUND'
Else
	lnPalk = f_round(v_palk_kaart.summa,'-',qryPalkLib.round)
	lcTund = 'SUMMA'
	lnBaas = 0
Endif
*!*	IF qryPalkLib.liik = 7
*!*		lnPalk = round(lnPalk,0)
*!*	endif
If lnPalk <> 0
	if !used ('v_palk_oper')
		.use ('v_palk_oper', 'v_palk_oper',.t.)
	endif
	If reccount ('v_palk_oper') < 1
		Insert into v_palk_oper (rekvid, LibId, lepingId, kpv, summa);
			values (gRekv,qryPalkLib.id,v_palk_kaart.lepingId,gdKpv,lnPalk)
	Else
		If !empty (v_palk_oper.LibId) and !empty (v_palk_oper.lepingId)
			Replace summa with lnPalk,;
				kpv with gdKpv  in v_palk_oper
		Else
			Replace v_palk_oper.LibId with qryPalkLib.id,;
				lepingId with v_palk_kaart.lepingId,;
				kpv with gdKpv,;
				summa with lnPalk in v_palk_oper
		Endif
	Endif

Endif
endwith
Return lnPalk

