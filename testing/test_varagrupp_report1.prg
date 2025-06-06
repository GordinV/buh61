CLOSE data all
grekv = 1
gVersia = 'VFP'
gnhandle = 1
glError = .f.
&&cData = 'c:\buh50\dbavpsoft\buhdata5.dbc'
cData = 'e:\files\buh52\dbase\buhdata5.dbc'
OPEN data (cData)
USE menuitem IN 0
USE menubar IN 0
USE config IN 0

SET classlib to classes\classlib
oDb = createobject('db')
with odb
.login = 'VLAD'
.pass = ''

tnid = grekv
.use ('v_rekv','qryRekv')
CREATE cursor qryAaRekv (aa m)
APPEND blank
.use ('v_aa')
SELECT v_aA
SCAN for kassapank = 1
	REPLACE aa with left(v_aA.arve,20) + space(1)+;
		str (v_aA.pank,3)+space(1)+left(v_aA.nimetus,60)+chr(13) in qryAaRekv
ENDSCAN
endwith

CREATE cursor curKey (versia m)
APPEND blank
REPLACE versia with 'RAAMA' in curKey
CREATE cursor v_account (admin int default 1)

create cursor fltrGruppid (kood c(20), nimetus c(120))
append blank

DO queries\varagrupp_report1

IF !empty (alias())
	BROW
ENDIF
report form reports\varagrupp_report1 prev
if !used ('curPrinter')
	use curprinter in 0
endif
select curprinter
locate for 	procfail = 'varagrupp_report1'
if !found ()
	messagebox ('Viga, ei leida paring curprinter tabelis')
endif