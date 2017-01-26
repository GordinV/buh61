Parameter cWhere
* печать документа 
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif
tnId = cWhere
IF !USED('v_tulud1')
WITH oDb
	.use('v_tulud1')
	.use('v_tulud2')
ENDWITH
ENDIF

CREATE CURSOR koolitus_report1 (kpv d, summa y, number int, isik1 c(254),;
 isik2 c(254), isikukood1 c(20), isikukood2 c(254), konto c(20), tunnus c(20),;
 kood1 c(20), kood2 c(20), kood3 c(20), kood4 c(20), kood5 c(20) )

INSERT INTO KOOLITUS_REPORT (KPV, Summa, number, isik1, isik2,;
	isikukood1, isikukood2, konto, tunnus, kood1, kood2, kood3, kood4, kood5);
SELECT kpv, v_tulud2.summa, number, isik1, isik2, ;
isikukood1, isikukood2, konto, tunnus, koo1, kood2, kood3, kood4, kood5;
FROM v_tulud1, v_tulud2

select koolitus_report1
IF RECCOUNT() < 1
	APPEND BLANK
endif
 
