Local lnError, lTSD
lnError = 1

DO queries\palk\tsd2015_report2.fxp
IF !USED('tsd_report')
	SELECT 0
	RETURN .f.	
ENDIF

*set STEP on
cFail = 'c:\temp\buh60\EDOK\tsd.txt'
cFailbak = 'c:\temp\buh60\EDOK\'+Alltrim(Str(grekv))+'tsd'+Sys(2015)+'.bak'
If File (cFailbak)
	Erase (cFailbak)
Endif
If File(cFail)
	Rename (cFail) To (cFailbak)
Endif


SELECT isikukood as v1000, nimi as v1010, v1020 , v1030, v1040, v1050, v1060, v1070, v1080, v1090, v1100, v1110,	v1120, v1130, v1140, ;
	v1150,	v1160_610,	v1170 , v1200, v1210, v1220, v1230 , v1240, v1250 ;
	from tsd_report ;
	into cursor qryTSD

COPY TO tsd.tmp TYPE csv
lTSD = FILETOSTR('tsd.tmp')
STRTOFILE(lTSD, cFail , 4)

Return


