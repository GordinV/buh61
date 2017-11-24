Parameter tnNomId, tnId, tdKpv
local lnSumma
lnSumma = 0
with oDb
	if !used('qrypvoper')
		.use('v_pv_oper','qrypvoper',.t.)
	endif
	if !used('qryvpvkaart')
		.use('v_pv_kaart','qryvpvkaart')
	else
		.dbreq('qryvpvkaart',gnHandle,'v_pv_kaart')
	endif
	.use('curPvJaak')
	.use('curPvParandus')
endwith
lnJaak = iif(isnull(curPvJaak.summa),0,curPvJaak.summa) - iif (isnull(curPvParandus.summa),0,curPvParandus.summa)
lnJaak = qryvpvkaart.soetmaks - (qryvpvkaart.algkulum  + lnJaak  ) 
if used ('curPvJaak')
	use in curPvJaak
endif
if lnJaak > 0
	lnSumma = round(qryvpvkaart.kulum * 0.01 * (qryvpvkaart.soetmaks+iif (isnull(curPvParandus.summa),0,curPvParandus.summa)) / 12,0)  
	if lnSumma > lnJaak
		lnSumma = lnJaak
	endif
	insert into qrypvoper (parentid, nomId, kpv, summa, liik);
		values (tnId, tnNomId, tdKpv, lnSumma, 2)
endif
if used ('curPvParandus')
	use in curPvParandus
endif
if used ('qryNom')
	use in qryNom
endif