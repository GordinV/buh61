Parameter cWhere

CREATE CURSOR vanemtasu_report2 (number c(20) DEFAULT tmpvanemtasu_aruanne2.number, dokkpv d DEFAULT tmpvanemtasu_aruanne2.dokkpv, ;
	isikkood c(20) DEFAULT tmpvanemtasu_aruanne2.isikkood, nimi c(254) DEFAULT tmpvanemtasu_aruanne2.nimi, ;
	vanemkood c(20) DEFAULT tmpvanemtasu_aruanne2.vanemkood, vanemnimi c(254) DEFAULT tmpvanemtasu_aruanne2.vanemnimi, ;
	aadress m DEFAULT tmpvanemtasu_aruanne2.aadress, tunnus c(20) DEFAULT tmpvanemtasu_aruanne2.tunnus, grupp c(40) DEFAULT tmpvanemtasu_aruanne2.grupp,;
	rea1 c(254),rea2 c(254), rea3 c(254), rea4 c(254), rea5 c(254), rea6 c(254),;
	hind1 n(14,2) DEFAULT 0, hind2 n(14,2) DEFAULT 0, hind3 n(14,2) DEFAULT 0, hind4 n(14,2) DEFAULT 0, hind5 n(14,2) DEFAULT 0, hind6 n(14,2) DEFAULT 0,;
	kogus1 n(12,3) DEFAULT 0, kogus2 n(12,3) DEFAULT 0, kogus3 n(12,3) DEFAULT 0, kogus4 n(12,3) DEFAULT 0,kogus5 n(12,3) DEFAULT 0, kogus6 n(12,3) DEFAULT 0, ;
	summa1 n(14,2) DEFAULT 0, summa2 n(14,2) DEFAULT 0, summa3 n(14,2) DEFAULT 0, summa4 n(14,2) DEFAULT 0, summa5 n(14,2) DEFAULT 0, summa6 n(14,2) DEFAULT 0,;
	algsaldo n(14,2) DEFAULT tmpvanemtasu_aruanne2.algjaak, tasud n(14,2) DEFAULT tmpvanemtasu_aruanne2.tasud, ;
	loppsaldo n(14,2), tahtaeg d DEFAULT DATE(YEAR(tmpvanemtasu_aruanne2.dokkpv),MONTH(tmpvanemtasu_aruanne2.dokkpv),DAY(tmpvanemtasu_aruanne2.dokkpv)))

INDEX ON LEFT(UPPER(nimi),40) TAG nimi
SET ORDER TO nimi

lError = oDb.Exec("sp_vanemtasu_aruanne2 ", Str(grekv)+",'%"+;
	LTRIM(RTRIM(fltrVanemTasu.tunnus))+"%','"+;
	"%"+LTRIM(RTRIM(fltrVanemTasu.isikukood1))+"%','"+;
	"%"+LTRIM(RTRIM(fltrVanemTasu.isik1))+"%',"+;
	" DATE("+Str(Year(fltrVanemTasu.kpv1),4)+","+;
	STR(Month(fltrVanemTasu.kpv1),2)+","+Str(Day(fltrVanemTasu.kpv1),2)+"), DATE("+Str(Year(fltrVanemTasu.kpv2),4)+","+;
	STR(Month(fltrVanemTasu.kpv2),2)+","+Str(Day(fltrVanemTasu.kpv2),2)+")," + ;
	"'%"+LTRIM(RTRIM(fltrVanemTasu.grupp))+"%'","qryVanemtasu")

If Used('qryVanemtasu')
	tcTimestamp = Alltrim(qryVanemtasu.sp_vanemtasu_aruanne2)
	oDb.Use('tmpvanemtasu_aruanne2')
ELSE
	SELECT 0
	RETURN .f.
endif	

SELECT vanemtasu_report2
*APPEND FROM DBF('tmpvanemtasu_aruanne2')
*SET STEP ON 

SELECT DISTINCT number, dokkpv, isikkood FROM tmpvanemtasu_aruanne2 INTO CURSOR tmp1

SELECT tmp1
SCAN
	SELECT tmpvanemtasu_aruanne2
	lnRea = 0
	SCAN FOR number = tmp1.number AND isikkood = tmp1.isikkood AND dokkpv = tmp1.dokkpv
		SELECT vanemtasu_report2
		IF lnRea = 0
			APPEND BLANK
			lnRea = lnRea + 1
		ENDIF
		DO case
			CASE lnRea = 1
					replace rea1 WITH tmpvanemtasu_aruanne2.nimetus,;
						hind1 WITH tmpvanemtasu_aruanne2.hind,;
						kogus1 WITH tmpvanemtasu_aruanne2.kogus,;
						summa1 WITH tmpvanemtasu_aruanne2.summa ,;
						algsaldo with tmpvanemtasu_aruanne2.algjaak IN vanemtasu_report2
			CASE lnRea = 2
					replace rea2 WITH tmpvanemtasu_aruanne2.nimetus,;
						hind2 WITH tmpvanemtasu_aruanne2.hind,;
						kogus2 WITH tmpvanemtasu_aruanne2.kogus,;
						algsaldo WITH tmpvanemtasu_aruanne2.algjaak,;
						summa2 WITH tmpvanemtasu_aruanne2.summa IN vanemtasu_report2

			CASE lnRea = 3
					replace rea3 WITH tmpvanemtasu_aruanne2.nimetus,;
						hind3 WITH tmpvanemtasu_aruanne2.hind,;
						kogus3 WITH tmpvanemtasu_aruanne2.kogus,;
						algsaldo WITH tmpvanemtasu_aruanne2.algjaak,;
						summa3 WITH tmpvanemtasu_aruanne2.summa IN vanemtasu_report2
			CASE lnRea = 4
					replace rea4 WITH tmpvanemtasu_aruanne2.nimetus,;
						hind4 WITH tmpvanemtasu_aruanne2.hind,;
						kogus4 WITH tmpvanemtasu_aruanne2.kogus,;
						algsaldo WITH tmpvanemtasu_aruanne2.algjaak,;
						summa4 WITH tmpvanemtasu_aruanne2.summa IN vanemtasu_report2
			CASE lnRea = 5
					replace rea5 WITH tmpvanemtasu_aruanne2.nimetus,;
						hind5 WITH tmpvanemtasu_aruanne2.hind,;
						kogus5 WITH tmpvanemtasu_aruanne2.kogus,;
						algsaldo WITH tmpvanemtasu_aruanne2.algjaak,;
						summa5 WITH tmpvanemtasu_aruanne2.summa IN vanemtasu_report2
			CASE lnRea = 6
					replace rea6 WITH tmpvanemtasu_aruanne2.nimetus,;
						hind6 WITH tmpvanemtasu_aruanne2.hind,;
						kogus6 WITH tmpvanemtasu_aruanne2.kogus,;
						algsaldo WITH tmpvanemtasu_aruanne2.algjaak,;
						summa6 WITH tmpvanemtasu_aruanne2.summa IN vanemtasu_report2
		endcase
		lnRea = lnrea + 1
		IF lnRea > 6
			exit
		ENDIF
		
	ENDSCAN
	
	
ENDSCAN
USE IN tmp1
USE IN tmpvanemtasu_aruanne2
SELECT vanemtasu_report2
