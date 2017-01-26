Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif
tnId = cWhere
cQuery = 'print_arv1'
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
oDb.use(cQuery,'arve_report1')
&&use (cQuery) in 0 alias arve_report1
create cursor arve_lausend (id int, lausend m)
insert into arve_lausend (id) values (arve_report1.JOURNALID)
tnId =arve_report1.JOURNALID
oDb.use ('v_journal1','qryJournal1')
select qryJournal1
scan
	lcString =  'D '+ltrim(rtrim(qryJournal1.deebet))+space(1)+;
		'K '+ltrim(rtrim(qryJournal1.kreedit)) + space(1)+;
		alltrim(str (qryJournal1.summa,12,2)) + chr(13)
	replace arve_lausend.lausend with lcString additive in arve_lausend
endscan
select arve_report1
