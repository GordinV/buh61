Parameter cWhere

lError = oDb.Exec("sp_vanemtasu_aruanne1 ", Str(grekv)+",'%"+LTRIM(RTRIM(fltrVanemTasu.tunnus))+"%', DATE("+Str(Year(fltrVanemTasu.kpv1),4)+","+;
	STR(Month(fltrVanemTasu.kpv1),2)+","+Str(Day(fltrVanemTasu.kpv1),2)+"), DATE("+Str(Year(fltrVanemTasu.kpv2),4)+","+;
	STR(Month(fltrVanemTasu.kpv2),2)+","+Str(Day(fltrVanemTasu.kpv2),2)+"),'%"+;
	LTRIM(RTRIM(fltrVanemTasu.grupp))+"%','%"+LTRIM(RTRIM(fltrVanemTasu.konto))+"%'","qryVanemtasu")

If Used('qryVanemtasu')
	tcTimestamp = Alltrim(qryVanemtasu.sp_vanemtasu_aruanne1)
	oDb.Use('tmpvanemtasu_aruanne1')
ELSE
	SELECT 0
	RETURN .f.
endif	

SELECT tmpvanemtasu_aruanne1
