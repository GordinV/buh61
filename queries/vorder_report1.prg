Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif
tnId = cWhere
cQuery = 'print_vorder1'
With odb
	.use (cQuery,'vorder_report1',.t.)
	.use ('v_korder1','qryVorder1')
	.use ('v_korder2','qryVorder2')
	If reccount ('qryvorder1') < 1
		Select qryvorder1
		Append blank
	Endif

	Select qryvorder2
	If reccount ('qryvorder2') < 1
		Append blank
	Endif
	Scan
		lcNimetus = ''
		If !empty (qryvorder2.nomid)
			Select comNomremote
			Locate for id = qryvorder2.nomid
			lcNimetus = comNomremote.nimetus
		Endif
		Select vorder_report1
		Append blank
		Replace number with qryvorder1.number,;
			kpv with qryvorder1.kpv,;
			kokku with qryvorder1.summa,;
			nimi with qryvorder1.nimi,;
			aadress with qryvorder1.aadress,;
			alus with qryvorder1.alus,;
			nimetus with lcNimetus,;
			summa with qryvorder2.summa,;
			valuuta WITH qryvorder2.valuuta,;
			kuurs WITH qryvorder2.kuurs,;
			dokument with qryvorder1.dokument in vorder_report1

	Endscan
	Create cursor arve_lausend (id int, lausend m)

	tnid = qryvorder1.journalid
	.use ('v_journalid')
	If reccount ('v_journalid') > 0
		Insert into arve_lausend (id) values (v_journalid.number)
		.use ('v_journal1','qryJournal1')
		Select qryJournal1
		Scan
			lcString =  'D '+Ltrim(Rtrim(qryJournal1.deebet))+IIF(!EMPTY(qryJournal1.lisa_d),' TP '+Ltrim(Rtrim(qryJournal1.lisa_d)),'')++Space(1)+;
				'K '+Ltrim(Rtrim(qryJournal1.kreedit)) + IIF(!EMPTY(qryJournal1.lisa_k),' TP '+Ltrim(Rtrim(qryJournal1.lisa_k)),'') + Space(1)+'Summa '+;
				qryJournal1.valuuta+' '+alltrim(Str (qryJournal1.Summa,12,2)) + Space(1)+IIF(!EMPTY(qryJournal1.kood5),' Eel. '+Ltrim(Rtrim(qryJournal1.kood5)),'')+Space(1)+;
				IIF(!EMPTY(qryJournal1.kood1),' TT '+Ltrim(Rtrim(qryJournal1.kood1)),'') +Chr(13)
			Replace arve_lausend.lausend with lcString additive in arve_lausend
		Endscan
		Use in qryJournal1
	Endif
	if used ('v_journalid')
		use in v_journalid
	endif
Endwith
select vorder_report1 