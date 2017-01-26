SET MEMOWIDTH TO 64000

lcFile = 'c:\avpsoft\temp\kl1.sql'
IF !FILE(lcFile)
	MESSAGEBOX('Viga')
	return
ENDIF
CREATE CURSOR tmpsql (sql m, sqlIns m)
IF RECCOUNT() < 1
	APPEND blank
ENDIF

 
gnHandle = SQLCONNECT('NarvaLvPg','vlad','654')
IF gnhandle < 0
	MESSAGEBOX('Viga conn')
	return
ENDIF
SET STEP ON 
=SQLEXEC(gnHandle,'begin work')
lnError = 0

APPEND MEMO tmpsql.sql from (lcFile) overwrite
lnLines = MEMLINES(tmpsql.sql)
FOR i = 1 TO lnLines
	lcString = MLINE(tmpsql.sql,i)
	IF !ISDIGIT(ALLTRIM(LEFT(lcString,8)))
		exit
	ENDIF
	
	lcInsert = ''
	lnLen = LEN(lcString)
	lcid = LTRIM(RTRIM(LEFT(lcString,8)))
	lcNomId = LTRIM(RTRIM(substr(lcString,9,8)))
	lcPalkLibId = LTRIM(RTRIM(SUBSTR(lcString,17,8)))
	lcLibId = LTRIM(RTRIM(SUBSTR(lcString,25,8)))
	lcTyyp = LTRIM(RTRIM(SUBSTR(lcString,33,8)))
	lcTunnusId = LTRIM(RTRIM(SUBSTR(lcString,41,8)))
	lcKood1 = "'"+LTRIM(RTRIM(SUBSTR(lcString,49,8)))+"'"
	lcKood2 = "'"+LTRIM(RTRIM(SUBSTR(lcString,57,8)))+"'"
	lcKood3 = "'"+LTRIM(RTRIM(SUBSTR(lcString,65,8)))+"'"
	lcKood4 = "'"+LTRIM(RTRIM(SUBSTR(lcString,72,8)))+"'"
	lcKood5 = "'"+LTRIM(RTRIM(SUBSTR(lcString,81,8)))+"'"
	lcKonto = "'"+LTRIM(RTRIM(SUBSTR(lcString,89,8)))+"'"
	lcVanaId = LTRIM(RTRIM(SUBSTR(lcString,97,8)))
	IF lcvanaId = '\N'
		lcvanaid = '0'
	ENDIF
	
	IF EMPTY(lcVanaId)
		lcVanaId = '0'
	ENDIF
	lcProj = "'"+LTRIM(RTRIM(SUBSTR(lcString,105,8)))+"'"
	lcInsert = "insert into klassiflib_old (id,nomid,palklibid,libid,tyyp,tunnusid,kood1,kood2,kood3,kood4,kood5,konto,vanaid,proj) values("+;	
		lcId+","+lcNomId+","+lcPalkLibId+","+lcLibId+","+lcTyyp+","+lcTunnusId+","+lcKood1+","+lcKood2+","+lcKood3+","+lcKood4+","+lcKood5+","+lcKonto+","+lcvanaId+","+lcProj+")"
*	replace sqlIns WITH lcInsert ADDITIVE IN tmpsql

	lnError = SQLEXEC(gnHandle,lcInsert)
	IF lnError < 0 
		exit
	ENDIF
	

	WAIT WINDOW STR(i)+'/'+STR(lnLines) nowait	TIMEOUT 1
*!*		
*!*		IF i > 25
*!*			EXIT		
*!*		ENDIF
	
ENDFOR

*MODIFY MEMO tmpsql.sqlIns

IF lnError > 0
	=SQLEXEC(gnHandle,'commit work')
	MESSAGEBOX('Lopp')
ELSE
	=SQLEXEC(gnHandle,'rollback work')
	MESSAGEBOX('Viga')
ENDIF



=SQLDISCONNECT(gnhandle)



