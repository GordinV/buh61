Parameter tnLepingId
If used ('v_palk_oper')
	If vartype (tnLepingId) <> 'N'
		tnLepingId = v_palk_oper.lepingId
	Endif
	If !empty (v_palk_oper.kpv)
		lKpv1 = date (year (v_palk_oper.kpv), month (v_palk_oper.kpv),1)
	Else
		lKpv1 = date (year (gdKpv), month (gdKpv),1)
	Endif
Else
	If vartype (gdKpv) <> 'D'
		gdKpv = date()
	Endif
	lKpv1 = date (year (gdKpv), month (gdKpv),1)
Endif
If vartype (tnLepingId) <> 'N'
	tnLepingId = 0
Endif
lKpv2 = gomonth (lKpv1,1) - 1
lcKpv1 = "'"+dtoc(lKpv1,1)+"'"
lcKpv2 = "'"+dtoc(lKpv2,1)+"'"
if gVersia = 'VFP'
	lcKpv1 = 'date ('+str (year (lKpv1),4)+','+str (month (lKpv1),2)+','+str(day(lKpv1),2)+')'
	lcKpv2 = 'date ('+str (year (lKpv2),4)+','+str (month (lKpv2),2)+','+str(day(lKpv2),2)+')'
endif
lError = oDb.exec ("sp_update_palk_jaak ",lcKpv1+","+lcKpv2+","+;
	alltrim( str (gRekv))+","+alltrim( str (tnLepingId)))
If lError = .f. and config.debug = 1
	Set step on
Endif


*!*	If gVersia = 'VFP'
*!*		Do sp_update_palk_jaak with lKpv1, lKpv2, gRekv, tnlepingId
*!*		lError = 1
*!*	Else
*!*		cString = "sp_update_palk_jaak '"+dtoc(lKpv1,1)+"','"+dtoc(lKpv2,1)+"',"+;
*!*			alltrim( str (gRekv))+","+alltrim( str (tnlepingId))
*!*		lError = sqlexec (gnHandle, cString)
*!*	Endif
