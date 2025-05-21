Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif
tnId = cWhere
cQuery = 'print_sorder1'
tcKood = '%'
tcNimetus = '%'
SET STEP ON 
with oDb
	.use(cQuery,'sorder_report1')
	
	SELECT sorder_report1
	SCAN
		SELECT comAsutusRemote
		LOCATE FOR id = sorder_report1.asutusId
		replace asutus WITH comAsutusRemote.nimetus IN  sorder_report1
	endscan
	SELECT sorder_report1
	GO top	
	
	tnId =sorder_report1.journalid
	.use ('v_journalid','QRYJOURNALNUMBER' )
	
	Create cursor sorder_lausend (id int, lausend m)
	append blank
	If reccount ('QRYJOURNALNUMBER') > 0
		tnId = QRYJOURNALNUMBER.JOURNALID
		.use ('v_journal1','qryJournal1')
		Select qryJournal1
		Scan
			lcString =  'D '+ltrim(rtrim(qryJournal1.deebet))+space(1)+;
				'K '+ltrim(rtrim(qryJournal1.kreedit)) + space(1)+;
				alltrim(str (qryJournal1.summa,12,2)) + chr(13)
			Replace id with QRYJOURNALNUMBER.number,;
				sorder_lausend.lausend with lcString additive in sorder_lausend
		Endscan
	Endif
	If used ('QRYJOURNALNUMBER')
		Use in QRYJOURNALNUMBER
	Endif
endwith
select sorder_report1
*BROW