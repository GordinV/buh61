	Create Cursor qryasutus( Id Int,rekvId Int,regkood c(20),nimetus c(254), omvorm c(20),;
		aadress m, kontakt m,  tel c(20),  faks c(60), email c(60),  muud m,  tp c(20))

lcFile = 'c:\avpsoft\files\buh60\temp\haridus\tp2004.dbf'

IF !USED('qryAsutus_')
	USE (lcFile) IN 0 ALIAS qryAsutus_
endif
SELECT qryAsutus_
*BROWSE

gnhandle = SQLCONNECT('narvalvpg', 'vlad','490710')
IF gnHandle < 1
	MESSAGEBOX('Viga, uhendus')
	RETURN .f.
endif



lcString = 'select * from asutus '

lError = SQLEXEC(gnHandle,lcString,'comAR')
IF lError < 1 OR !USED('comAr')
	MESSAGEBOX('Viga')	
ENDIF



IF lError > 0
	lError = SQLEXEC(gnHandle,'begin work')

	SELECT qryAsutus_
	SCAN FOR ISDIGIT(ALLTRIM(qryAsutus_.n6))
		SELECT comAR
		LOCATE FOR ALLTRIM(regkood) =  ALLTRIM(qryAsutus_.n6)
		IF !FOUND()
			* запись в регистре отсутсвует
			 WAIT WINDOW [insert ]+qryAsutus_.n5 nowait
			 lcString = "insert into asutus (regkood, nimetus, rekvid, tp) values ('"+;
			 	ALLTRIM(qryAsutus_.n6)+"','"+RTRIM(LTRIM(qryAsutus_.n5))+"',11,'"+ALLTRIM(qryAsutus_.n9)+"')"
			lError = SQLEXEC(gnHandle,lcString)
			IF lError > 0 AND LEFT(ALLTRIM(qryAsutus_.n6),3) = '000' OR LEN(ALLTRIM(qryAsutus_.n6)) > 8
				* eraisik
				lcString = " select id from asutus where rekvId = 11 and regkood = '"+LTRIM(rtrim(qryAsutus_.n6))+"'"
				lError = SQLEXEC(gnHandle,lcString,'qryLastId')
				IF lError > 0 and USED('qryLastId') and RECCOUNT('qryLastId') > 0	
					lcString = 'insert into tooleping (parentid, osakondid, ametid, algab) values ('+;
						STR(qryLastId.id)+',28832,28833,DATE(2004,01,01))'
					lError = SQLEXEC(gnHandle,lcString)
				ELSE
					SET STEP ON 
					lError = -1							
				ENDIF
			endif
		ENDIF
		IF lerror < 0
			exit
		endif
	ENDSCAN
ENDIF
IF lError > 0
	=SQLEXEC(gnHandle,'commit work')
	MESSAGEBOX('Ok')
ELSE
	=SQLEXEC(gnHandle,'rollback work')
	MESSAGEBOX('Viga')
endif
=SQLDISCONNECT(gnHandle)
USE IN qryAsutus_
USE IN comAR
