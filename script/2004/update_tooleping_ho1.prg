gnhandle = SQLCONNECT('narvalvpg', 'vlad','490710')
IF gnHandle < 1
	MESSAGEBOX('Viga, uhendus')
	RETURN .f.
endif

lcString = 'select * from tooleping where rekvId = 31'
lError = SQLEXEC(gnHandle,lcString,'qryToo')
IF lError < 0
	MESSAGEBOX('Viga, select')
	
ENDIF
IF lError > 0
lError = SQLEXEC(gnHandle,'begin work')
	SELECT qryToo
	SCAN
		WAIT WINDOW STR(RECNO('qryToo'))+'-'+STR(RECCOUNT('qryToo')) nowait
		lcString = 'select count(*)::int as count from palk_oper where MONTH(kpv) = 7 and lepingid = '+STR(qryToo.id) 
		lError = SQLEXEC(gnHandle,lcString,'qryCount')
		IF lError < 0
			exit
		ENDIF
		IF RECCOUNT('qryCount') > 0 AND qryCount.count = 0
			lcString = 'update tooleping set algab = DATE(2004,08,01) where rekvid = 31 and ID = '+STR(QRYtOO.id)
			lError = SQLEXEC(gnHandle,lcString)
			IF lError < 0
				exit
			ENDIF		
		endif

	ENDSCAN
	
	
IF lError > 0
	=SQLEXEC(gnHandle,'commit work')
	MESSAGEBOX('Ok')
ELSE
	=SQLEXEC(gnHandle,'rollback work')
	MESSAGEBOX('Viga')
ENDIF
ENDIF

=SQLDISCONNECT(gnHandle)
