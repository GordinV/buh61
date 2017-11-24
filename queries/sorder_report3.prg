Parameter cWhere
If Isdigit(Alltrim(cWhere))
	cWhere = Val(Alltrim(cWhere))
Endif
tnId = cWhere
cQuery = 'print_sorder1'
tcKood = '%'
tcNimetus = '%'
SET STEP ON 
With oDb
	.Use(cQuery,'sorder_report1')
	IF RECCOUNT('sorder_report1') > 1
		DELETE FOR RECNO('sorder_report1') > 1
	ENDIF
	GO top
	tnId =sorder_report1.JOURNALid
	.Use ('v_journalid','QRYJOURNALNUMBER' )

	Create Cursor sorder_lausend (Id Int, lausend m)
	Append Blank
	If Reccount ('QRYJOURNALNUMBER') > 0
		tnId = QRYJOURNALNUMBER.JOURNALid
		.Use ('v_journal1','qryJournal1')
		Select qryJournal1
		Scan
			lcString =  'D '+Ltrim(Rtrim(qryJournal1.deebet))+IIF(!EMPTY(qryJournal1.lisa_d),' TP '+Ltrim(Rtrim(qryJournal1.lisa_d)),'')++Space(1)+;
				'K '+Ltrim(Rtrim(qryJournal1.kreedit)) + IIF(!EMPTY(qryJournal1.lisa_k),' TP '+Ltrim(Rtrim(qryJournal1.lisa_k)),'') + Space(1)+'Summa '+;
				qryJournal1.valuuta+alltrim(Str (qryJournal1.Summa,12,2)) + Space(1)+IIF(!EMPTY(qryJournal1.kood5),' Eel. '+Ltrim(Rtrim(qryJournal1.kood5)),'')+Space(1)+;
				IIF(!EMPTY(qryJournal1.kood1),' TT '+Ltrim(Rtrim(qryJournal1.kood1)),'') +Chr(13)
			Replace Id With QRYJOURNALNUMBER.Number,;
				sorder_lausend.lausend With lcString Additive In sorder_lausend
		Endscan
	Endif
	If Used ('QRYJOURNALNUMBER')
		Use In QRYJOURNALNUMBER
	Endif
Endwith
Select sorder_report1
