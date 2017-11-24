Parameter tKpv1, tKpv2, tcKonto
tKpv1 = iif(empty(tKpv1),date(year(date()),1,1),tKpv1)
tKpv2 = iif(empty(tKpv2),date(year(date()),12,31),tKpv2)
tcKonto = iif(empty(tcKonto),'%%',tcKonto)
cString = "sp_calc_saldod1 @rekvId = "+alltrim(str(gRekv))+", @kpv1	= '"+;
	dtoc(tKpv1,1)+"', @kpv2 = '"+dtoc(tKpv2,1)+"', @KONTO = '"+tcKonto+"'"
lError = sqlexec(gnHandleAsync,cString)
