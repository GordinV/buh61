Local lnPalk, lnBaas, lcTund, lnRate, nTulu, tnSumma
tnSumma = 0
lnRate = 0
lnPalk = 0
lnBaas = 0
lcTund = ''
nTulu = 0
With oDb
	If !empty(v_palk_kaart.percent_) && � ��������� �� ������ ����������
		If empty (v_palk_kaart.alimentid)
			tnId = v_palk_kaart.lepingId
			If !used ('qryTooleping')
				.use ('qryTooleping')
			Else
				.dbreq('qryTooleping',gnHandle,'qryTooleping')
			Endif
			tnId = qryTooleping.ametId
			If !used ('qryAmet')
				.use ('v_library','qryAmet')
			Else
				.dbreq('qryAmet',gnHandle,'v_library')
			Endif
			Select comAsutusremote
			Locate for id = qryTooleping.parentid
			tnId = v_palk_kaart.LibId
			If !used ('qryPalkLib')
				.use ('v_palk_lib','qryPalkLib')
			Else
				.dbreq('qryPalkLib',gnHandle,'v_Palk_Lib')
			Endif
			If reccount('qryPalkLib') > 0
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
				If !used ('qryTaabel1')
					.use ('curTaabel1','qryTaabel1')
				Else
					.dbreq('qryTaabel1',gnHandle,'curTaabel1')
				Endif
				If reccount('qryTaabel1') > 0 and qryTaabel1.kokku > 0
					Select qryTaabel1
					Locate for tooleping = v_palk_kaart.lepingId
					if !found () or qryTaabel1.kokku = 0
						return 0
					endif
					
					nHours = workdays(1, gnkuu, gnaasta, 31,v_palk_kaart.lepingId) / (qryTooleping.koormus * 0.01) * qryTooleping.toopaev
					Do case
						Case qryTooleping.tasuliik = 1
&& �����					
							lnTPalk = val(str(qryTooleping.palk,14,6))
							nPalk = lnTPalk * (qryTaabel1.kokku / nHours)
							lnRate = nPalk / qryTaabel1.kokku
						Case qryTooleping.tasuliik = 2
&& ������� ������
							nPalk = qryTooleping.palk * qryTaabel1.kokku
							lnRate = qryTooleping.palk
					Endcase
				Endif
				If  qryPalkLib.tund = 5 && ���������� �� ��������.����
					lnPalk = f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.tahtpaev,'+',qryPalkLib.round)
					lnBaas = qryTaabel1.tahtpaev
					lcTund = 'TUND'
				Endif
				If  qryPalkLib.tund = 6 && ���������� �� ���������.����
					lnPalk = f_round(lnRate * v_palk_kaart.Summa * 0.01 * qryTaabel1.puhapaev,'+',qryPalkLib.round)
					lnBaas = qryTaabel1.puhapaev
					lcTund = 'TUND'
				Endif
				If  qryPalkLib.tund < 5 && ���������� �� ����
					lnPalk = lnPalk + f_round(lnRate * v_palk_kaart.Summa * 0.01 * ;
						iif(qryPalkLib.tund =3,qryTaabel1.ohtu,;
						iif(qryPalkLib.tund =4,qryTaabel1.oo,iif (qryPalkLib.tund =2,qryTaabel1.paev,qryTaabel1.kokku))),'+',qryPalkLib.round)
					lnBaas = lnBaas + iif(qryPalkLib.tund =3,qryTaabel1.ohtu,;
						iif(qryPalkLib.tund =4,qryTaabel1.oo,qryTaabel1.paev))
					lcTund = 'TUND'
				Endif
			Else
				lnPalk = f_round(v_palk_kaart.Summa * (0.01 * qryTooleping.palk),'+',qryPalkLib.round)
				lnBaas = nHours
				lcTund = 'TUND'
			Endif
		Else
			lnBaas = calc_alimentid ()
			lnPalk = f_round( lnBaas * v_palk_kaart.Summa * 0.01)
			lnTund = 'TUND'
		Endif

	Else
		lnPalk = f_round(v_palk_kaart.Summa,'+',qryPalkLib.round)
		lcTund = 'SUMMA'
		lnBaas = 0
	Endif
	If !empty(v_palk_kaart.tulumaks)
		nTulu = nTulu + lnPalk
	Endif
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
Endwith
Return lnPalk

Function calc_alimentid
	Local lnSumma
	lnSumma = 0
&& 1. lEPINGUD
	If !used ('qryTootajad')
		tcisik = '%'
		oDb.use('comTootajad','qryTootajad' )
	Endif
	Select qryTootajad
	Locate for id = v_palk_kaart.alimentid
	If !found ()
		Return 0
	Endif
&& 2. TULUD
	tdkpv1 = date (gnaasta, gnkuu,1)
	tdKpv2 = gomonth (tdkpv1,1) - 1
	tnLepingid = qryTootajad.lepingId
	oDb.use ('qryTulud', 'qryAlimBaas')
	lnSumma = qryAlimBaas.summa
	Use in qryAlimBaas
	Use in qryTootajad
	Return lnSumma
