Parameter cWhere
* печать документа 
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif
tnId = cWhere
*!*	IF !USED('v_tulud1')
*!*	WITH oDb
*!*		.use('v_tulud1')
*!*		.use('v_tulud2')
*!*	ENDWITH
*!*	ENDIF
 
lError = oDb.Exec("sp_vanemtasu_aruanne3 ", Str(grekv)+",'%"+;
	LTRIM(RTRIM(fltrVanemTasu.tunnus))+"%','"+;
	"%"+LTRIM(RTRIM(fltrVanemTasu.isikukood1))+"%','"+;
	"%"+LTRIM(RTRIM(fltrVanemTasu.isik1))+"%','"+;
	"%"+LTRIM(RTRIM(fltrVanemTasu.isikukood2))+"%','"+;
	"%"+LTRIM(RTRIM(fltrVanemTasu.isik2))+"%',"+;
	" DATE("+Str(Year(fltrVanemTasu.kpv1),4)+","+;
	STR(Month(fltrVanemTasu.kpv1),2)+","+Str(Day(fltrVanemTasu.kpv1),2)+"), DATE("+Str(Year(fltrVanemTasu.kpv2),4)+","+;
	STR(Month(fltrVanemTasu.kpv2),2)+","+Str(Day(fltrVanemTasu.kpv2),2)+"),"+;
	Str(fltrVanemTasu.liik) + ",'%"+LTRIM(RTRIM(fltrVanemTasu.grupp))+"%','%"+;
	LTRIM(RTRIM(fltrVanemTasu.konto))+"%'","qryVanemtasu")

If Used('qryVanemtasu')
	tcTimestamp = Alltrim(qryVanemtasu.sp_vanemtasu_aruanne3)
	oDb.Use('tmpvanemtasu_aruanne3','qryVanem')
ELSE
	SELECT 0
	RETURN .f.
endif	


CREATE CURSOR koolitus_report1 (kpv d, deebet y, kreedit y, number int, isik1 c(254),;
 isik2 c(254), isikukood1 c(20), isikukood2 c(254), korkonto c(20), konto c(20), tunnus c(20),;
 kood1 c(20), kood2 c(20), kood3 c(20), kood4 c(20), kood5 c(20), lausend int )

INSERT INTO KOOLITUS_REPORT1 (KPV, deebet, kreedit, number, isik1, isik2,;
	isikukood1, isikukood2, korkonto,  konto, tunnus, kood1, kood2, kood3, kood4, kood5, lausend);
SELECT dokkpv, deebet, kreedit, number,  nimi, vanemnimi, isikkood, vanemkood, ;
	korkonto, konto, tunnus, kood1, kood2, kood3, kood4, kood5, lausend;
	FROM qryVanem

select koolitus_report1
IF RECCOUNT() < 1
	APPEND BLANK
endif
 
