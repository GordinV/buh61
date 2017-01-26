Local lnTulumaks, lnTulubaas, lnKulu
if empty (v_palk_kaart.lepingId) and used ('v_palk_oper') and !empty (v_palk_oper.libid)
	select v_palk_kaart
	locate for v_palk_kaart.libId = v_palk_oper.libid
endif

TNID = v_palk_kaart.LepingId
tnlepingId = v_palk_kaart.LepingId

With oDb
	.use ('qryTooleping')
&&	tnlepingId = qryTooleping.id
	tdKpv1 = date (gnAasta, gnKuu, 1)
	tdKpv2 = gomonth(date (gnAasta, gnKuu, 1),1) - 1
	If !used ('qryTulumaks')
		.use ('qryTulumaks')
	Endif
	If reccount ('qryTulumaks') < 1
		Return .t.
	Endif
	If v_palk_kaart.liik = 4
		Select qryTulumaks
		Locate for id = v_palk_kaart.libId
	Endif

	If !used ('palk_config')
		.use ('v_palk_config','palk_config' )
	Endif
	lnTulubaas = iif(qryTooleping.pohikoht > 0,palk_config.tulubaas,0)
	.use ('qryTulud')
	.use ('qryKulud')
	lnTulumaks = 0
	lnKulu = 0
	Select sum(summa) as 'tulu', tulumaar;
		FROM  qryTulud;
		where qryTulud.tulumaar = val(alltrim(qryTulumaks.algoritm));
		order by qryTulud.tulumaar;
		group by qryTulud.tulumaar;
		INTO CURSOR qryTuludKokku
	If reccount('qryTuludKokku') > 0
		Select qryTuludKokku
		Scan
			If !empty(qryTuludKokku.tulu)
				Select sum(summa) as 'kulu',tulumaar;
					FROM  qryKulud ;
					where tulumaar = qryTuludKokku.tulumaar;
					order by tulumaar;
					group by tulumaar;
					INTO CURSOR qryKuludKokku
				lnTulumaks = qryTuludKokku.tulumaar * 0.01 * (qryTuludKokku.tulu - lnTulubaas - qryKuludKokku.kulu)
				If lnTulubaas > 0
					lnTulubaas = 0
				Endif
				If lnTulumaks < 0
					lnTulumaks = 0
				Else
					lnRound = iif (used('qryPalkLib'),qryPalkLib.round,0)
					lnTulumaks = f_round(lnTulumaks,'-',lnRound)
				Endif
				if !used ('v_palk_oper')
					.use ('v_palk_oper', 'v_palk_oper',.t.)
				endif
				If reccount ('v_palk_oper') < 1
					Insert into v_palk_oper (rekvid, libId, LepingId, kpv, summa);
						values (gRekv,qryTulumaks.id,v_palk_kaart.LepingId,gdKpv,lnTulumaks)
				Else
					If !empty (v_palk_oper.libId) and !empty (v_palk_oper.LepingId)
						Replace summa with lnTulumaks,;
							kpv with gdKpv  in v_palk_oper
					Else
						Replace qryTulumaks.Id with qryPalkLib.id,;
							LepingId with v_palk_kaart.LepingId,;
							kpv with gdKpv,;
							summa with lnTulumaks in v_palk_oper
					Endif
				Endif
			Endif
		Endscan
	Endif
Endwith
Return lnTulumaks
