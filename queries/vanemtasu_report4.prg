Parameter cWhere

CREATE CURSOR vanemtasu_report4 (tunnus c(20) DEFAULT tmpvanemtasu_aruanne4.tunnus, grupp c(40) DEFAULT tmpvanemtasu_aruanne4.grupp,;
	kogus n(12,3) DEFAULT 0, deebet n(14,2) DEFAULT 0, kreedit n(14,2) DEFAULT 0, nimetus c(254))

INDEX ON tunnus + '-'+grupp TAG nimi
SET ORDER TO nimi

set step on
lError = oDb.Exec("sp_vanemtasu_aruanne4 ", Str(grekv)+",'%"+;
	LTRIM(RTRIM(fltrVanemTasu.tunnus))+"%','"+;
	"%"+LTRIM(RTRIM(fltrVanemTasu.grupp))+"%',"+;
	" DATE("+Str(Year(fltrVanemTasu.kpv1),4)+","+;
	STR(Month(fltrVanemTasu.kpv1),2)+","+Str(Day(fltrVanemTasu.kpv1),2)+"), DATE("+Str(Year(fltrVanemTasu.kpv2),4)+","+;
	STR(Month(fltrVanemTasu.kpv2),2)+","+Str(Day(fltrVanemTasu.kpv2),2)+")","qryVanemtasu")


If Used('qryVanemtasu')
	tcTimestamp = Alltrim(qryVanemtasu.sp_vanemtasu_aruanne4)
	oDb.Use('tmpvanemtasu_aruanne4')
ELSE
	SELECT 0
	RETURN .f.
endif	

SELECT vanemtasu_report4
APPEND FROM DBF('tmpvanemtasu_aruanne4')

USE IN tmpvanemtasu_aruanne4
SELECT vanemtasu_report4
