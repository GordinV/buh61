Parameter cWhere
If Isdigit(Alltrim(cWhere))
	cWhere = Val(Alltrim(cWhere))
Endif
tnId = cWhere
cQuery = 'print_arv1'
With odb
	.Use(cQuery,'arve_report1')
*!*		Index On KM Tag KM
*!*		Set Order To KM
	Create Cursor arve_lausend (Id Int, lausend m)
	Insert Into arve_lausend (Id) Values (arve_report1.JOURNALID)
	tnId =arve_report1.JOURNALID
	tnAasta = Year (arve_report1.kpv)
	.Use ('QRYJOURNALNUMBER')
	If Reccount ('QRYJOURNALNUMBER') > 0
		tnId = QRYJOURNALNUMBER.JOURNALID
		.Use ('v_journal1','qryJournal1')
		Select qryJournal1
		Scan
			lcString =  'D '+Ltrim(Rtrim(qryJournal1.deebet))+Space(1)+;
				'K '+Ltrim(Rtrim(qryJournal1.kreedit)) + Space(1)+;
				alltrim(Str (qryJournal1.Summa,12,2)) + Chr(13)
			Replace arve_lausend.lausend With lcString Additive In arve_lausend
		Endscan

	Endif
	If Used ('QRYJOURNALNUMBER')
		Use In QRYJOURNALNUMBER
	Endif
	Select comAsutusRemote
*!*		If Tag() <> 'ID'
*!*			Set Order To Id
*!*		Endif
	LOCATE FOR id = arve_report1.asutusId
	If Found()
		lnJaak = 0
		If !Empty(arve_report1.konto)
			lnJaak = analise_formula('ASD('+Ltrim(Rtrim(arve_report1.konto))+','+Alltrim(Str(arve_report1.asutusId))+')', arve_report1.kpv, 'CursorAlgSaldo')
		Endif

		Update arve_report1 Set asutus = Rtrim(Ltrim(comAsutusRemote.nimetus))+Space(1)+Trim(comAsutusRemote.omvorm), jaak = lnJaak

*		Update arve_report1 Set asutus = RTRIM(lTrim(comAsutusRemote.nimetus))+Space(1)+Trim(comAsutusRemote.omvorm)
	Endif
	Select arve_report1
	Scan
		Select comNomRemote
*!*			If Tag() <> 'ID'
*!*				Set Order To Id
*!*			Endif
*!*			Seek arve_report1.nomid
		locate for id = arve_report1.nomid
		lcKbm = ''
		Do Case
			Case comNomRemote.doklausid = 0
				lcKbm =  '18%'
			Case comNomRemote.doklausid = 1
				lcKbm =  '0%'
			Case comNomRemote.doklausid = 2
				lcKbm =  '5%'
			Case comNomRemote.doklausid = 3
				lcKbm =  'Vaba'
			Case comNomRemote.doklausid = 4
				lcKbm =  '9%'
			Case comNomRemote.doklausid = 5
				lcKbm =  '20%'
		Endcase
		Replace KM With lcKbm In arve_report1
	Endscan

Endwith
Select arve_report1
Index On KM Tag KM
Set Order To KM
