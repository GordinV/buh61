Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif
tnId = cWhere
&&use (cQuery) in 0 alias 'konto_report1'
If vartype(odb) <> 'O'
	Set classlib to classes\classlib
	odb = createobject('db')
Endif
With odb
	lError = .use('V_LIBRARY','qrykonto')
	lError = .use('V_kontoinf','qrykontoinf')
	lError = .use('V_subkonto','qrySubkonto')
Endwith
If lError = .f.
	Return .f.
Endif
create cursor konto_report1 (konto c(20) default qryKonto.kood, ;
	nimetus c(254) default qryKonto.nimetus, ;
	type c(2) default iif (qryKontoinf.type = 1,'SD',iif (qryKontoinf.type = 2,'SK',;
	iif (qryKontoinf.type = 3,'D','K'))),;
 	algsaldo y DEFAULT qryKontoinf.algsaldo,;
	aasta int default qryKontoinf.aasta, asutus c(254),saldo y)
if reccount ('qrySubkonto') < 1
	append blank
endif
select qrysubkonto 
scan
	Select konto_report1
	append blank
	replace asutus with qrySubkonto.nimetus,;
		saldo with qrySubkonto.asutus in konto_report1
endscan
use in qrySubkonto
use in qryKonto
use in qryKontoinf
select konto_report1
