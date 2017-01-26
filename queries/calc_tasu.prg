Local lntasu
lntasu = 0
tnId = v_palk_kaart.lepingId
With oDb
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
	tnleping = v_palk_kaart.lepingId
	tnKuu = gnKuu
	tnAasta = gnAasta
	.use ('v_palk_jaak')
	lnBaas = v_palk_jaak.jaak
	Use in v_palk_jaak
	lnTasuMaar = v_palk_kaart.summa
	lntasu = f_round(lnTasuMaar * 0.01 * lnBaas,'-',qryPalkLib.round)
	If lntasu > 0
		If !used ('v_palk_oper')
			.use ('v_palk_oper', 'v_palk_oper',.t.)
		Endif
		If reccount ('v_palk_oper') < 1
			Insert into v_palk_oper (rekvid, LibId, lepingId, kpv, summa);
				values (gRekv,qryPalkLib.id,v_palk_kaart.lepingId,gdKpv,lntasu)
		Else
			If !empty (v_palk_oper.LibId) and !empty (v_palk_oper.lepingId)
				Replace summa with lntasu,;
					kpv with gdKpv  in v_palk_oper
			Else
				Replace v_palk_oper.LibId with qryPalkLib.id,;
					lepingId with v_palk_kaart.lepingId,;
					kpv with gdKpv,;
					summa with lntasu in v_palk_oper
			Endif
		Endif

	Endif
Endwith
Return lntasu
