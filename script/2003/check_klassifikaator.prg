set step on
lcFile = 'e:\files\buh52\dok\eelarve_klassid_01092003.txt'
if !file (lcFile)
	messagebox ('Viga: fail ei leidnud')
	return .f.
endif
create cursor cur_result (id int, kood c(20), nimetus c(254), tulemus int, lib c(20))
create cursor cur_eelarve (mtext m)
append blank
append memo mtext from (lcFile)

gversia = 'MSSQL'
gnhandle = sqlconnect ('narva','vladislav','654')
if gnHandle < 0
	messagebox ('Viga: uhendus eba õnestus')
	return .f.	
endif
grekv = 2

glError = .f.
USE menuitem IN 0
USE menubar IN 0
USE config IN 0

CREATE cursor curKey (versia m)
APPEND blank
REPLACE versia with 'RAAMA' in curKey
CREATE cursor v_account (admin int default 1)
tcKood = '%'
tcNimetus = '%'
SET classlib to classes\classlib
oDb = createobject('db')
WITH oDb
	.login = 'VLADISLAV'
	.pass = '654'
	tnid = grekv
	.use ('curAllikad')
	.use ('curTegev')
	.use ('curObjekt')
	.use ('curArtikkel')
ENDWITH
lKood = .f.
lcKood = ''
lcNimetus = ''
lnLines = memlines (cur_eelarve.mtext)
for i = 1 to lnLines
	lcString = ltrim(rtrim(mline (cur_eelarve.mtext,i)))
	if !empty (lcString)
		if isdigit(left(lcString,1))
			lcKood = lcString
			lKood = .t.
			wait window [Kontroling rea kood:]+lcKood nowait
		else
			lcNimetus = lcString
			lKood = .f.
			=f_kontrol()
		endif		
	endif
endfor
select cur_result
brow
*!*	scan for tulemus = 0
*!*		if !used ('v_library')
*!*			oDb.use ('v_library','v_library',.t.)
*!*		endif
*!*		select v_library
*!*		append blank
*!*		replace rekvid with grekv,;
*!*			kood with cur_result.kood,;
*!*			nimetus with cur_result.nimetus,;
*!*			library with cur_result.lib in v_library
*!*	endscan
*!*	select v_library
*!*	lError = odb.opentransaction()
*!*	if lError = .f.
*!*		messagebox ('Viga: transaction')
*!*		return .f.
*!*	endif	
*!*	lError = odb.cursorupdate('v_library')
*!*	if lError = .f.
*!*		odb.rollback()
*!*		messagebox ('Viga: update')
*!*	else
*!*		oDb.commit
*!*		messagebox ('OK')
*!*	endif	
=sqldisconnect(gnhandle)
clear all


Function f_kontrol
lcLib = ''
		do case
			case left (lcKood,1) = '1'
				&& Tulud
				lcCursor =  'curAllikad'
				lcLib = 'ALLIKAD'
			case left (lcKood,1) = '2'
				&& Kulud
				lcCursor =  'curArtikkel'
				lcLib = 'ARTIKKEL'
			case left (lcKood,1) = '3'
				&& Fin. rist
				lcCursor =  'curObjekt'
				lcLib = 'OBJEKT'
			case left (lcKood,1) = '4'
				&& tegev
				lcCursor =  'curtegev'
				lcLib = 'TEGEV'
		endcase
		select cur_result
		append blank
		select (lcCursor)
			locate for alltrim(kood) == lcKood
			if found ()
				if ltrim(rtrim(upper(nimetus))) <> lcNimetus
					replace kood with lcKood,;
						id with evaluate (lcCursor+'.id'),;
						nimetus with lcNimetus,;
						lib with lcLib,;
						tulemus with 2 in cur_result
				else
					replace kood with lcKood,;
						id with evaluate (lcCursor+'.id'),;
						lib with lcLib,;
						nimetus with lcNimetus,;
						tulemus with 1 in cur_result
				endif
			else
					replace kood with lcKood,;
						id with 0,;
						nimetus with lcNimetus,;
						lib with lcLib,;
						tulemus with 0 in cur_result
			endif
return



