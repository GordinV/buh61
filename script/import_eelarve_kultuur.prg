Local lError
Clear All


lnSumma = 0
lnrec = 0
lnrekvId = 62
lTulemus = .t.


lcFile = 'c:\temp\NLVKO.xls'
If !File(lcFile)
	Messagebox('Viga, failid ei leidnud')
	lError = .T.
Endif


Import From (lcFile) TYPE XL8 SHEET 'kulud'

Select * From NLVKO Into Cursor curTt


gnHandle = SQLConnect('narvalvpg','vlad','654')
If gnHandle < 1
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif
SET STEP ON 
lnresult=SQLEXEC(gnHandle,'begin work')

	Select curTt
	SCAN FOR !EMPTY(curTt.e) 
		WAIT WINDOW STR(RECNO('curTt'))+'-'+STR(RECCOUNT('curTt')) + curTt.d nowait
		
		lcTunnusId = STR(get_tunnus())
		IF lTulemus = .t.
		lcString = " insert into eelarve (rekvid, aasta, summa, muud, tunnus, tunnusid, kood1, kood2, kood3, kood4, kood5) values (62,"+;
				"2007,"+STR(curTt.e,12,2)+",'"+LTRIM(RTRIM(curTt.h))+"',0,"+lcTunnusId+",'"+;
				curtt.c+"','"+curtt.g+"','"+SPACE(1)+"','"+curtt.d+"',SPACE(1))"
		
		IF SQLEXEC(gnHandle,lcstring) < 0
			lTulemus = .f.
			MESSAGEBOX('Viga')
			_cliptext = lcString
			SET STEP ON 
			exit
		ENDIF
		
				
		lnSumma = lnSumma + curTt.e
		ENDIF
		IF lTulemus = .f.
			exit
		ENDIF
		
	ENDSCAN


If lTulemus = .t.
	=SQLEXEC(gnHandle,'commit work')
	Messagebox('Ok, summa:'+Str(lnSumma,12,2))
Else
	Set Step On
	=SQLEXEC(gnHandle,'rollback work')
Endif




=SQLDISCONNECT(gnHandle)

	

FUNCTION get_tunnus
LOCAL lcString
IF EMPTY(curTt.f)
	RETURN 0
ENDIF
lcString = "SELECT id from library where kood = '"+ALLTRIM(curTt.f)+"' and library = 'TUNNUS' and rekvid = 62"
IF SQLEXEC(gnHandle,lcString) < 0
	MESSAGEBOX('Viga')
	lTulemus = .f.
	SET STEP ON 
ELSE
	RETURN sqlresult.id
ENDIF

ENDFUNC



Function transdigit
	Lparameters tcString
	lnQuota = At(',',tcString)
	lcKroon = Left(tcString,lnQuota-1)
	lcCent = Right(tcString,2)
	If At(Space(1),lcKroon) > 0
* on probel
		lcKroon = Stuff(lcKroon,At(Space(1),lcKroon),1,'')
	Endif
	Return lcKroon+'.'+lcCent
Endfunc

