Parameter cWhere
*SET STEP ON 
lError = oDb.Exec("sp_kaibesaldo_aruanne1 ", Str(grekv)+", DATE("+Str(Year(fltrArved.kpv1),4)+","+;
	STR(Month(fltrArved.kpv1),2)+","+Str(Day(fltrArved.kpv1),2)+"), DATE("+Str(Year(fltrArved.kpv2),4)+","+;
	STR(Month(fltrArved.kpv2),2)+","+Str(Day(fltrArved.kpv2),2)+"),"+STR(fltrArved.liik)+",'%"+LTRIM(RTRIM(fltrArved.asutus))+"%','"+;
	  LTRIM(RTRIM(fltrArved.number))+"%'" ,"qryKaibesaldo")

If Used('qryKaibesaldo')
	tcTimestamp = Alltrim(qryKaibesaldo.sp_kaibesaldo_aruanne1)
	oDb.Use('TMPKAIBESALDOARUANNE1')
ELSE
	SELECT 0
	RETURN .f.
endif	

SELECT TMPKAIBESALDOARUANNE1        
