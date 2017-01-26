Lparameters tnId
Local lError

cIds = ''

If !Empty(tnId)
	cIds = Str(tnId)
Else
	If Used('curArved')
		Select curArved
		SCAN FOR !EMPTY(curArved.valitud)
			If Len(cIds) > 1
				cIds = cIds + ','
			Endif

			cIds = cIds + Alltrim(Str(curArved.Id))
		endscan
	Endif

Endif

*!*	gRekv = 119
cFail = 'c:\temp\buh60\EDOK\earved.xml'
cFailbak = 'c:\temp\buh60\EDOK\'+Alltrim(Str(grekv))+'earved'+Sys(2015)+'.bak'

If !Directory(Justpath(cFail))
	Mkdir(Justpath(cFail))
Endif

If File (cFailbak)
	Erase (cFailbak)
Endif
If File(cFail)
	Rename (cFail) To (cFailbak)
Endif

=execute()

If !File(cFail)
	cFail = ''
Endif

Return cFail


Function execute
TEXT TO lcString noshow
		select arv.*, case when arv.liik = 0 then a.regkood else rtrim(LTRIM(a.regkood)) end as regkood ,
			CASE when arv.liik = 0 then rekv.nimetus else rtrim(LTRIM(a.nimetus)) || ' ' || rtrim(a.omvorm) end as muuja,
			CASE when arv.liik = 1 then rekv.nimetus else rtrim(LTRIM(a.nimetus)) || ' ' || rtrim(a.omvorm) end as ostja,
			CASE when arv.liik = 0 then rekv.regkood else rtrim(LTRIM(a.regkood))  end as muuja_regkood,
			CASE when arv.liik = 1 then rekv.regkood else rtrim(LTRIM(a.regkood))  end as ostja_regkood
			from arv
			inner join asutus a on a.id = arv.asutusId
			inner join rekv on arv.rekvId = rekv.id
			where arv.rekvId = ?gRekv
ENDTEXT

lcString = lcString + ' and arv.id in (' + cIds + ') order by kpv, number, id '


	lnError = SQLEXEC(gnhandle,lcString,'qryeArved')
	If lnError < 0
		_cliptext = lcString
		Set Step On
	Endif


TEXT TO lcFileString NOSHOW
<?xml version="1.0" encoding="UTF-8"?>
<E_Invoice>
ENDTEXT

	Select qryeArved
	Scan

		lcKpv = Str(Year(qryeArved.kpv),4) + '-'+;
			IIF(Month(qryeArved.kpv)<10,'0','') + Alltrim(Str(Month(qryeArved.kpv),2))+'-'+;
			IIF(Day(qryeArved.kpv)<10,'0','')+Alltrim(Str(Day(qryeArved.kpv),2))

		lcTKpv = ''
		If !Empty(qryeArved.tahtaeg)
			lcTKpv = Str(Year(qryeArved.tahtaeg),4) + '-'+;
				IIF(Month(qryeArved.tahtaeg)<10,'0','') + Alltrim(Str(Month(qryeArved.tahtaeg),2))+'-'+;
				IIF(Day(qryeArved.tahtaeg)<10,'0','')+Alltrim(Str(Day(qryeArved.tahtaeg),2))
		Endif


		lcFileString = lcFileString + Chr(13)+;
			'<Header>'+  Chr(13)+;
			'<Date>' + lcKpv + '</Date>' + Chr(13)+;
			'<FileId>' + Alltrim(Str(qryeArved.Id))+ '</FileId>'+Chr(13)+;
			'<AppId>EARVE</AppId>' + Chr(13)+;
			'<Version>1.1</Version>' + Chr(13)+;
			'</Header>'+  Chr(13) +;
			'<Invoice invoiceId="' + Alltrim(qryeArved.Number) + '" regNumber="' +Alltrim(qryeArved.regkood)+'">'+Chr(13)+;
			'<InvoiceParties>'+Chr(13)+;
			'<SellerParty>'+Chr(13)+;
			'<Name> ' + Alltrim(qryeArved.muuja) + ' </Name>' + Chr(13)+;
			'<RegNumber> ' + Alltrim(qryeArved.muuja_regkood) + ' </RegNumber>' + Chr(13)+;
			'</SellerParty>' + Chr(13)+;
			'<BuyerParty>'+ Chr(13)+;
			'<Name>' + Alltrim(qryeArved.ostja) + '</Name>' + Chr(13)+;
			'<RegNumber>' + Alltrim(qryeArved.ostja_regkood) + '</RegNumber>' + Chr(13)+;
			'</BuyerParty>'+ Chr(13)+;
			'</InvoiceParties>' + Chr(13)+;
			'<InvoiceInformation>'+ Chr(13)+;
			'<Type type="DEB"/>'+Chr(13)+;
			'<DocumentName>Arve</DocumentName>'+Chr(13)+;
			'<InvoiceNumber>' + Alltrim(qryeArved.Number) + '</InvoiceNumber>'+Chr(13)+;
			'<InvoiceDate>' + lcKpv+ '</InvoiceDate>' + Chr(13) + ;
			'</InvoiceInformation>'+ Chr(13)+;
			'<InvoiceSumGroup>'+Chr(13)+;
			'<InvoiceSum>' + Alltrim(Str(qryeArved.Summa,14,2)) + '</InvoiceSum>' +Chr(13)+;
			'<VAT>'+Chr(13)


TEXT TO lcString noshow
			select (case n.doklausid when 0 then 18 when 1 then 0 when 2 then 5 when 3 then 0 when 4 then 9 else 20 end::numeric) as vatRate,
				sum(kbm) as vatSum, n.doklausid, arv1.parentId
				from arv1
				inner join nomenklatuur n on n.id = arv1.nomid
				where arv1.parentId = ?qryeArved.id
				group by n.doklausid, arv1.parentId
ENDTEXT
		lnError = SQLEXEC(gnhandle,lcString,'qryeArvedVat')
		If lnError < 0
			Set Step On
			exit
		Endif

TEXT TO lcString noshow
			select
				case n.doklausid when 0 then 18 when 1 then 0 when 2 then 5 when 3 then 0 when 4 then 9 else 20 end as vatRate,
				arv1.parentId,	arv1.kbm as vat_summa,
				n.doklausid, n.nimetus as Description,n.uhik as ItemUnit,
				arv1.kogus as ItemAmount, arv1.hind as ItemPrice, (arv1.summa - arv1.kbm) as ItemSum, arv1.kbm as VATSum, arv1.summa as ItemTotal
				from arv1
				inner join nomenklatuur n on n.id = arv1.nomid
				where arv1.parentId = ?qryeArved.id
ENDTEXT
		lnError = SQLEXEC(gnhandle,lcString,'qryeArvedDet')
		If lnError < 0
			Set Step On
			Exit
		Endif
		If Used('qryeArvedDet')
			lcFileString= lcFileString  + create_details()
		ENDIF
		
	lcFileString = lcFileString + ;
		'</InvoiceItemGroup>' + Chr(13)+;
		'</InvoiceItem>' + Chr(13)+;
		'<AdditionalInformation>' + Chr(13)+;
		'<InformationName>Lisa</InformationName>'+ Chr(13)+;
		'<InformationContent>'+Alltrim(qryeArved.lisa)+'</InformationContent>'+ Chr(13)
		
	If !Empty(qryeArved.muud)
		lcFileString = lcFileString + ;
			'<InformationName>Muud</InformationName>'+ Chr(13)+;
			'<InformationContent>'+Alltrim(qryeArved.muud)+'</InformationContent>'+ Chr(13)
	Endif
	lcFileString = lcFileString + ;
		'</AdditionalInformation>' + Chr(13)+;
		'<PaymentInfo>' + Chr(13)+;
		'<Currency>EUR</Currency>' + Chr(13)+;
		'<PaymentRefId></PaymentRefId>'+Chr(13)+;
		'<PaymentDescription>Arve ' + Alltrim(qryeArved.Number)+'</PaymentDescription>'+Chr(13)+;
		'<Payable>NO</Payable>'+Chr(13)+;
		'<PayDueDate>' + lcTKpv+ '</PayDueDate>'+Chr(13)+;
		'<PaymentTotalSum>'+ Alltrim(Str(qryeArved.Summa,14,2))+'</PaymentTotalSum>'+Chr(13)+;
		'<PayerName>' + Alltrim(qryeArved.ostja) + '</PayerName>'+Chr(13)+;
		'</PaymentInfo>'+ Chr(13)+;
		'</Invoice>' + Chr(13)



*	lcString = ALLTRIM(lcString)


	Endscan
	Select qryeArved
	Sum Summa To lnTotalSumma

	lcFileString = lcFileString +;
		'<Footer>' + Chr(13)+;
		'<TotalNumberInvoices>' + Alltrim(Str(Reccount('qryeArved')))+ '</TotalNumberInvoices>' + Chr(13) +;
		'<TotalAmount>'+ Alltrim(Str(lnTotalSumma,14,2))+ '</TotalAmount>' + Chr(13)+;
		'</Footer>'	+ Chr(13) + ;
		'</E_Invoice>'

	Strtofile(lcFileString, cFail, 4)
	RETURN FILE(cFail)
Endfunc




Function test
	grekv = 119

	gnhandle = SQLConnect('NarvaLvPg')
	If gnhandle < 0
		Set Step On
	Endif
	cIds = '354150'
	=execute()

	SQLDISCONNECT(gnhandle)

Endfunc



Function create_details
	Local lcString, lnSummaKokku, lcIsoKpv, lcPankIban, lcTKpv, lcKpv
	lcString = ''

* koguneme kaibemaksu summad

	Select qryeArvedVat
	Scan
		lcString = lcString + ;
			'<VATRate>' + Alltrim(Str(qryeArvedVat.vatRate))+ '</VATRate>'+;
			'<VATSum>' + Alltrim(Str(qryeArvedVat.vatSum,14,2))+ '</VATSum>'+Chr(13)
	Endscan
	lcString = lcString + ;
		'</VAT>'+Chr(13)+;
		'<TotalSum>' + Alltrim(Str(qryeArved.Summa,14,2)) + '</TotalSum>' +Chr(13)+;
		'<Currency>EUR</Currency>'+Chr(13)+;
		'</InvoiceSumGroup>'+Chr(13)

* teenused
	lcString = lcString + ;
		'<InvoiceItem>' + Chr(13)+;
		'<InvoiceItemGroup>' + Chr(13)

	Select qryeArvedDet
	Scan
		lcString = lcString + ;
			'<ItemEntry>' + Chr(13)+;
			'<Description>' + Alltrim(qryeArvedDet.Description) + '</Description>' + Chr(13) +;
			'<ItemDetailInfo>'+Chr(13)+;
			'<ItemUnit>' + Alltrim(qryeArvedDet.ItemUnit) + '</ItemUnit>' + Chr(13)+;
			'<ItemAmount>' + Alltrim(Str(qryeArvedDet.ItemAmount,14,4)) + '</ItemAmount>' + Chr(13)+;
			'<ItemPrice>' + Alltrim(Str(qryeArvedDet.itemPrice,14,2))+ '</ItemPrice>' + Chr(13)+;
			'</ItemDetailInfo>'+Chr(13)+;
			'<ItemSum>' + Alltrim(Str(qryeArvedDet.itemSum,14,2))+ '</ItemSum>'+ Chr(13)+;
			'<VAT>'+Chr(13)+;
			'<VATRate>' + Alltrim(Str(qryeArvedDet.vatRate)) + '</VATRate>'+ Chr(13)+;
			'<VATSum>' + Alltrim(Str(qryeArvedDet.vatSum,14,2))+'</VATSum>'+Chr(13)+;
			'</VAT>'+Chr(13)+;
			'<ItemTotal>' + Alltrim(Str(qryeArvedDet.itemTotal,14,2))+'</ItemTotal>' +Chr(13)+;
			'</ItemEntry>' + Chr(13)
	ENDSCAN
	
*	Copy Memo tmpMk.iso To (cFail)
	RETURN lcString
*	Return File(cFail)
Endfunc
