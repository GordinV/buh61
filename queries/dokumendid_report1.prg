Parameter cWhere
IF !USED('curDokumendid')
	SELECT 0
	RETURN .f.
ENDIF

SELECT * from curDokumendid ORDER BY asutus, rekv INTO CURSOR dokumendid_report1
SELECT dokumendid_report1