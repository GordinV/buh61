SET STEP ON 
gnhandle = SQLConnect('pg60','vlad')
If gnhandle < 1
	Messagebox('Viga uhenduses')
	Return
Endif
lcstring = 'select * from doklausheader where rekvid = 56'
lError = SQLEXEC(gnhandle,lcstring,'qryHead')
If lError < 1
	_Cliptext = lcstring
	Messagebox('Viga '+lcstring)
Endif
*!*	lcstring = 'select * from rekv '
*!*	lError = SQLEXEC(gnhandle,lcstring,'qryRekv')
*!*	If lError < 1
*!*		_Cliptext = lcstring
*!*		Messagebox('Viga '+lcstring)
*!*	Endif

If lError > 0
	Create Cursor curSkript (skript m)
	Append Blank
	lcstring = 'select * from doklausend '
	lError = SQLEXEC(gnhandle,lcstring,'qryBody')
	If lError < 1
		_Cliptext = lcstring
		Messagebox('Viga '+lcstring)
	Endif
		Select qryhead
		SCAN 
			WAIT WINDOW 'Doklaus:'+STR(RECNO('qryhead'))+'/'+STR(RECCOUNT('qryhead')) nowait
			lcstring = "insert into doklausheader (rekvid, dok, selg) values ("+;
				"qryRekv.id,'"+LTRIM(RTRIM(qryhead.dok))+"','"+LTRIM(RTRIM(qryHead.selg))+"')"+CHR(13)
			replace curSkript.skript WITH lcString ADDITIVE IN curSkript
			lcString = "select CURRVAL('public.doklausheader_id_seq') as id " + CHR(13)
			replace curSkript.skript WITH lcString ADDITIVE IN curSkript
			SELECT qryBody
			SCAN FOR parentid = qryhead.id				   
				WAIT WINDOW 'Doklausend:'+STR(RECNO('qrybody'))+'/'+STR(RECCOUNT('qrybody')) nowait
				lcstring = "insert into doklausend (parentid,  summa ,  kood1,  kood2, kood3,kood4,kood5 ,deebet,kreedit,lisa_d,lisa_k) values ("+;
					"qryId.id,"+STR(qryBody.summa,12,4)+",'"+LTRIM(RTRIM(qryBody.kood1))+"','"+;
					LTRIM(RTRIM(qryBody.kood2))+"','" +LTRIM(RTRIM(qryBody.kood3))+"','"+;
					LTRIM(RTRIM(qryBody.kood4))+"','"+LTRIM(RTRIM(qryBody.kood5))+"','"+;
					LTRIM(RTRIM(qryBody.deebet))+"','"+LTRIM(RTRIM(qryBody.kreedit))+"','"+;
					LTRIM(RTRIM(qryBody.lisa_d))+"','"+LTRIM(RTRIM(qryBody.lisa_k))+"')"+CHR(13)
				replace curSkript.skript WITH lcString ADDITIVE IN curSkript
			endscan				

		Endscan
Endif
SELECT curSkript
BROWSE
COPY MEMO skript TO doklausend.txt
=SQLDISCONNECT(gnhandle)ÿ
