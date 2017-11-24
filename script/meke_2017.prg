LOCAL lnConnect

lnConnect = SQLCONNECT('meke')

IF lnConnect < 1 
	MESSAGEBOX('connection viga')
ENDIF

lcFile = 'tm.csv'

CREATE CURSOR tmp (regkood c(20), tm c(20), soodus c(20))

APPEND FROM (lcFile) delimited WITH CHARACTER ';'

GO TOP       
lcString = ''

SCAN
	WAIT WINDOW tmp.regkood + STR(RECNO('tmp')) + "/" + STR(RECCOUNT('tmp')) nowait
	lcString = "select po.id from asutus a " +; 
		" inner join tooleping t on t.parentid = a.id "+;
		" inner join palk_oper po on po.lepingid = t.id " +;
		" and kpv = date(2016,12,31) "+;
		" where a.regkood = '" + ALLTRIM(tmp.regkood) + "'" +;
	" order by po.tulubaas desc , summa desc limit 1"
	
	lnError = SQLEXEC(lnConnect, lcString,'tmpId')

	IF lnError < 1 OR EMPTY(tmpId.id)
		MESSAGEBOX('Error')
		_cliptext = lcString
		quit
	ENDIF
	
	

	lcStr = ALLTRIM(tmp.tm)	
	lnComma = AT(',',lcStr)
	lcTulumaks = STUFF(lcStr,lnComma,1,'.')
	
	lcStr = ALLTRIM(tmp.soodus)	
	lnComma = AT(',',lcStr)
	lcSoodus = 	STUFF(lcStr,lnComma,1,'.')
	
	
	lcString = "update palk_oper set tulumaks = " + lcTulumaks + ", tulubaas = " + lcSoodus + " where id = " + STR(tmpId.id)
	lnError = SQLEXEC(lnConnect, lcString)
	IF lnError < 0 
		_cliptext = lcString
		MESSAGEBOX('Viga')
		quit
	ENDIF
		
endscan


SQLDISCONNECT(lnConnect)



lcStr = '11232,23'
lnComma = AT(',',lcStr)
lnSumma = VAL(STUFF(lcStr,lnComma,1,'.'))
WAIT WINDOW STR(lnComma) + '-'+STR(lnSumma) + '-'+STUFF(lcStr,lnComma,1,'.')