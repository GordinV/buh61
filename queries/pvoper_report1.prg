Parameter cWhere
If vartype(cWhere) = 'C'
	tnId = val(alltrim(cWhere))
Else
	tnId = cWhere
Endif
If empty (tnId)
	Return .f.
Endif
tnLiik = iif (vartype(pv_kaart) = 'O' and !isnull(pv_kaart),pv_kaart.pageframe1.activepage - 1,0)
WITH oDb
	.use('v_library','print_pv')
	.use('curPvJaak')
	.use('v_pv_kaart','print_pv_kaart')
	.use('v_pv_oper','print_pv_oper')
endwith
tnId = print_pv_kaart.gruppId
oDb.use('v_library','qryLibrary')
cGrupp = qryLibrary.nimetus
Use in qryLibrary
lnJaak = iif(isnull(curPvJaak.summa),0,curPvJaak.summa)
lnKulum = lnJaak
select print_pv_kaart
sum soetmaks to lnSoetmaks
sum algkulum to lnAlgKulum
lnJaak = lnsoetmaks - (lnalgkulum  + lnJaak  )
Create cursor pvoper_report1 (pvkood c(20), pvnimetus c(120), soetmaks y, jaak y, kulum y,;
	kood c(20), nimetus c(254), kpv d, summa y, liik c(40))
Select print_pv_oper
Scan
	cLiik = ''
	do case
		case print_pv_oper.liik = 1
			cLiik = 'PAIGUTUS'
		case print_pv_oper.liik = 2
			cLiik = 'KULUM'
		case print_pv_oper.liik = 3
			cLiik = 'PARANDAMINE (PLUUS)'
		case print_pv_oper.liik = 4
			cLiik = 'PARANDAMINE (MINUUS)'
		case print_pv_oper.liik = 5
			cLiik = 'MAHAKANDMINE'
	endcase
	select pvoper_report1
	Append blank
	Replace pvkood with print_pv.kood,;
		pvnimetus with print_pv.nimetus,;
		soetmaks with lnsoetmaks,;
		jaak with lnJaak,;
		kulum with lnKulum,;
		kood with print_pv_oper.kood,;
		nimetus with print_pv_oper.nimetus,;
		summa with print_pv_oper.summa,;
		kpv with print_pv_oper.kpv,;
		liik with cLiik in pvoper_report1
Endscan
Use in print_pv
Use in print_pv_kaart
Use in print_pv_oper
Select pvoper_report1
