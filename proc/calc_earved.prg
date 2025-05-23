Lparameters tnId
Local lError
Set Textmerge On

cIds = ''
*!*	Test()
*!*	RETURN



If !Empty(tnId)
	cIds = Str(tnId)
Else
	If Used('curArved')
		Select curArved
		Scan For !Empty(curArved.valitud)
			If Len(cIds) > 1
				cIds = cIds + ','
			Endif

			cIds = cIds + Alltrim(Str(curArved.Id))
		Endscan
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

l_xml=execute()

If !File(cFail)
	cFail = ''
Endif

Return l_xml

FUNCTION getBankArved
LOCAL l_aa 
l_aa = ''

IF ALLTRIM(qryRekv.regkood) = '10337120'             
SELECT v_aA
SCAN For kassapank = 1
TEXT TO l_aa TEXTMERGE NOSHOW additive
<AccountInfo>
<AccountNumber/>
<IBAN><<ALLTRIM(v_aA.arve)>></IBAN>
</AccountInfo>
ENDTEXT
ENDSCAN

ENDIF


RETURN l_aa
ENDFUNC



Function execute
	Local laAddress[3]
TEXT TO lcString noshow
		select arv.*, case when arv.liik = 0 then a.regkood else rtrim(LTRIM(a.regkood)) end as regkood ,
			CASE when arv.liik = 0 then coalesce(rekv.muud,rekv.nimetus) else rtrim(LTRIM(a.nimetus)) || ' ' || rtrim(a.omvorm) end::varchar as muuja,
			CASE when arv.liik = 1 then coalesce(rekv.muud,rekv.nimetus) else rtrim(LTRIM(a.nimetus)) || ' ' || rtrim(a.omvorm) end::varchar as ostja,
			CASE when arv.liik = 0 then rekv.regkood else rtrim(LTRIM(a.regkood))  end as muuja_regkood,
			CASE when arv.liik = 0 then rekv.kbmkood else ''  end as muuja_kbmkood,
			CASE when arv.liik = 0 then rekv.aadress else rtrim(LTRIM(a.aadress))  end as muuja_aadress,
			CASE when arv.liik = 0 then rekv.email else rtrim(LTRIM(a.email))  end as muuja_email,
			CASE when arv.liik = 0 then rekv.tel else rtrim(LTRIM(a.tel))  end as muuja_tel,
			CASE when arv.liik = 1 then rekv.regkood else rtrim(LTRIM(a.regkood))  end as ostja_regkood,
			arv.viitenr as viitenr,
			a.aadress, a.email,
			(select arve from aa where parentId = rekv.id and default_ = 1 and not empty(pank) and kassa = 1 order by id desc limit 1)::varchar as arve,
			arv.lisa
			from arv
			inner join asutus a on a.id = arv.asutusId
			inner join rekv on arv.rekvId = rekv.id
			where arv.rekvId = ?gRekv
ENDTEXT

	lcString = lcString + ' and arv.id in (' + cIds + ') order by kpv, number, id '


	lnError = SQLEXEC(gnhandle,lcString,'qryeArved')
	If lnError < 0
		_Cliptext = lcString
		Set Step On
	Endif

	lcKpv = Str(Year(Date()),4) + '-'+;
		IIF(Month(Date())<10,'0','') + Alltrim(Str(Month(Date()),2))+'-'+;
		IIF(Day(Date())<10,'0','')+Alltrim(Str(Day(Date()),2))


TEXT TO lcFileString NOSHOW
<?xml version="1.0" encoding="UTF-8"?>
<E_Invoice>
<Header>
<Date><<lcKpv>></Date>
<FileId>1</FileId>
<AppId>EARVE</AppId>
<Version>1.1</Version>
</Header>

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
		ENDIF
		
		laAddress = getAddress(qryeArved.aadress)
		lcCity = getAddress(qryeArved.aadress, 3)
		lcPost = getAddress(qryeArved.aadress, 1)
		la_muuja_Address = getAddress(qryeArved.muuja_aadress)
		lc_muuja_City = getAddress(qryeArved.muuja_aadress, 3)
		lc_muuja_Post = getAddress(qryeArved.muuja_aadress, 1)
		
		lc_kmkr = IIF(!EMPTY(qryeArved.muuja_kbmkood) and LEN(ALLTRIM(qryeArved.muuja_kbmkood)) > 10,'<VATRegNumber>' + ALLTRIM(qryeArved.muuja_kbmkood) + '</VATRegNumber>','')

* <<IIF(!EMPTY(qryeArved.muuja_regkood),'<VATRegNumber>' + ALLTRIM(qryeArved.muuja_regkood) + '</VATRegNumber>')>>
		lc_arved = getBankArved()

TEXT TO lcFileString ADDITIVE NOSHOW

<Invoice invoiceId="<<Alltrim(convert_to_utf(qryeArved.Number))>>" regNumber="<<Alltrim(qryeArved.regkood)>>" channelId="EA">
<InvoiceParties>
<SellerParty>
<Name><<Alltrim(convert_to_utf(qryeArved.muuja))>></Name>
<RegNumber><<Alltrim(qryeArved.muuja_regkood)>></RegNumber>
<<lc_kmkr>>
<ContactData>
<PhoneNumber><<qryeArved.muuja_tel>></PhoneNumber>
<LegalAddress>
<PostalAddress1><<Alltrim(convert_to_utf(lc_muuja_Post))>></PostalAddress1>
<City><<ALLTRIM(convert_to_utf(lc_muuja_City))>></City>
</LegalAddress>
</ContactData>
<<lc_arved>>
</SellerParty>
<BuyerParty>
<Name><<Alltrim(convert_to_utf(qryeArved.ostja))>></Name>
<RegNumber><<Alltrim(qryeArved.ostja_regkood)>></RegNumber>
<ContactData>
<E-mailAddress><<Alltrim(convert_to_utf(qryeArved.email))>></E-mailAddress>
<LegalAddress>
<PostalAddress1><<Alltrim(convert_to_utf(lcPost))>></PostalAddress1>
<City><<ALLTRIM(convert_to_utf(lcCity))>></City>
</LegalAddress>
</ContactData>
</BuyerParty>
</InvoiceParties>
<InvoiceInformation>
<Type type="DEB"/>
<ContractNumber><<ALLTRIM(convert_to_utf(ALLTRIM(qryeArved.lisa)))>></ContractNumber>
<DocumentName>Arve</DocumentName>
<InvoiceNumber><<Alltrim(convert_to_utf(qryeArved.Number))>></InvoiceNumber>
ENDTEXT

		If !Isnull(qryeArved.muud) And !Empty(qryeArved.muud)

TEXT TO lcFileString ADDITIVE NOSHOW

	<InvoiceContentText><<ALLTRIM(convert_to_utf(ALLTRIM(qryeArved.muud)))>></InvoiceContentText>
ENDTEXT
		Endif
TEXT TO lcFileString ADDITIVE NOSHOW

<InvoiceDate><<lcKpv>></InvoiceDate>
<DueDate><<lcTKpv>></DueDate>
<Extension extensionId="eakChannel">
<InformationContent>EMAIL</InformationContent>
</Extension>
</InvoiceInformation>
<InvoiceSumGroup>
<InvoiceSum><<Alltrim(Str(qryeArved.Summa - qryeArved.kbm,14,2))>></InvoiceSum>

ENDTEXT

*!*	<Extension extensionId="eakStatusAfterImport">
*!*	<InformationContent>SENT</InformationContent>
*!*	</Extension>


TEXT TO lcString noshow
			select (case n.doklausid when 0 then 18 
					when 1 then 0 
					when 2 then 5 
					when 3 then 0 
					when 4 then 9 
					when 5 then 20 
					when 6 then 22 
					when 7 then 24
					when 8 then 13
					else 22 end::numeric) as vatRate,
				sum(arv1.kbm) as vatSum, n.doklausid, arv1.parentId, sum(summa) as summa
				from arv1
				inner join nomenklatuur n on n.id = arv1.nomid
				where arv1.parentId = ?qryeArved.id
				group by n.doklausid, arv1.parentId
ENDTEXT
		lnError = SQLEXEC(gnhandle,lcString,'qryeArvedVat')
		If lnError < 0
			Set Step On
			Exit
		Endif


* koguneme kaibemaksu summad

	Select qryeArvedVat
	Scan
TEXT TO lcFileString ADDITIVE NOSHOW

<VAT>
<VATRate><<Alltrim(Str(qryeArvedVat.vatRate))>></VATRate>
<VATSum><<Alltrim(Str(qryeArvedVat.vatSum,14,2))>></VATSum>
</VAT>

ENDTEXT

	Endscan
TEXT TO lcFileString ADDITIVE NOSHOW

<TotalSum><<Alltrim(Str(qryeArved.Summa,14,2))>></TotalSum>
<Currency>EUR</Currency>
</InvoiceSumGroup>

ENDTEXT


TEXT TO lcString noshow
			select
				case n.doklausid when 0 then 18 when 1 then 0 when 2 then 5 when 3 then 0 when 4 then 9 when 5 then 20 when 6 then 22 else 22 end as vatRate,
				arv1.parentId,	arv1.kbm as vat_summa,
				n.doklausid, ltrim(rtrim(n.nimetus)) || ' ' || ltrim(rtrim(coalesce(arv1.muud,''))) as Description,n.uhik as ItemUnit,
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
		Endif

l_tahtaeg = ALLTRIM(STR(YEAR(qryeArved.tahtaeg))) + '-' + ; 
	IIF(MONTH(qryeArved.tahtaeg) < 10, '0','') + ALLTRIM(STR(MONTH(qryeArved.tahtaeg))) + '-' + ;
	IIF(DAY(qryeArved.tahtaeg) < 10, '0','') + ALLTRIM(STR(DAY(qryeArved.tahtaeg)))

TEXT TO lcFileString ADDITIVE NOSHOW
<PaymentInfo>
<Currency>EUR</Currency>
<PaymentRefId><<ALLTRIM(IIF(ISNULL(qryeArved.viitenr),'',qryeArved.viitenr))>></PaymentRefId>
<PaymentDescription>Arve <<convert_to_utf(qryeArved.Number)>></PaymentDescription>
<Payable>YES</Payable>
<PayDueDate><<l_tahtaeg>></PayDueDate> 
<PaymentTotalSum><<Alltrim(Str(qryeArved.Summa,14,2))>></PaymentTotalSum>
<PayerName><<Alltrim(convert_to_utf(qryeArved.ostja)) >></PayerName>
<PaymentId><<ALLTRIM(convert_to_utf(qryeArved.number))>></PaymentId>
<PayToAccount><<ALLTRIM(qryeArved.arve)>></PayToAccount>
<PayToName><<ALLTRIM(convert_to_utf(qryeArved.muuja))>></PayToName>
</PaymentInfo>

ENDTEXT

IF !ISNULL(qryeArved.muud) AND !EMPTY(qryeArved.muud)
TEXT TO lcFileString ADDITIVE NOSHOW
<AdditionalInformation>  
<InformationName>Markus</InformationName><InformationContent><<ALLTRIM(qryeArved.muud)>></InformationContent>
</AdditionalInformation>
	
ENDTEXT

ENDIF

TEXT TO lcFileString ADDITIVE NOSHOW
</Invoice>
ENDTEXT



*	lcString = ALLTRIM(lcString)


	Endscan
	Select qryeArved
	Sum Summa To lnTotalSumma


TEXT TO lcFileString ADDITIVE NOSHOW

<Footer>
<TotalNumberInvoices><<Alltrim(Str(Reccount('qryeArved')))>></TotalNumberInvoices>
<TotalAmount><<Alltrim(Str(lnTotalSumma,14,2))>></TotalAmount>
</Footer>
</E_Invoice>
ENDTEXT


*!*		Strtofile(lcFileString, cFail, 4)
*!*		Return File(cFail)
RETURN lcFileString	
	
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

TEXT TO lcString ADDITIVE NOSHOW

<InvoiceItem>
<InvoiceItemGroup>

ENDTEXT


	Select qryeArvedDet
	Scan
TEXT TO lcString ADDITIVE NOSHOW
<ItemEntry>
<Description><<Alltrim(convert_to_utf(ALLTRIM(qryeArvedDet.Description)))>></Description>
<ItemDetailInfo>
<ItemUnit><<Alltrim(qryeArvedDet.ItemUnit)>></ItemUnit>
<ItemAmount><<Alltrim(Str(qryeArvedDet.ItemAmount,14,4))>></ItemAmount>
<ItemPrice><<Alltrim(Str(qryeArvedDet.itemPrice,14,2))>></ItemPrice>
</ItemDetailInfo>
<ItemSum><<Alltrim(Str(qryeArvedDet.itemSum,14,2))>></ItemSum>
<VAT>
<VATRate><<Alltrim(Str(qryeArvedDet.vatRate))>></VATRate>
<VATSum><<Alltrim(Str(qryeArvedDet.vatSum,14,2))>></VATSum>
</VAT>
<ItemTotal><<Alltrim(Str(qryeArvedDet.itemTotal,14,2))>></ItemTotal>
</ItemEntry>

ENDTEXT

	Endscan

TEXT TO lcString ADDITIVE NOSHOW

</InvoiceItemGroup>
</InvoiceItem>

ENDTEXT


*	Copy Memo tmpMk.iso To (cFail)
	Return lcString
*	Return File(cFail)
Endfunc


Function getAddress(tcAadress, Index)
	Local lcString, laAddress[10], returnAadress[3], lcIndex, lcLinn, lcPost
	lcIndex = ''
	lcLinn = ''

	If !Used('qryCities')
		TEXT TO lcString noshow
			SELECT DISTINCT nimetus FROM library WHERE  library = 'LINNAD'
		ENDTEXT
		lnError = SQLEXEC(gnhandle, lcString, 'qryCities')
	Endif


	Select qryCities

	nRows = Alines(laAddress, Strtran(tcAadress,",",Chr(13)))

	For i = 1 To nRows
		If Len(Alltrim(laAddress[i]))  = 5 And Isdigit(Alltrim(laAddress[i]))
			lcIndex = laAddress[i]
		Endif

		Select nimetus From qryCities Where Upper(Alltrim(nimetus)) = Upper(Alltrim(laAddress[i])) Into Cursor qryTmp

		If Reccount('qryTmp') > 0
			lcLinn = laAddress[i]
		Endif
		Use In qryTmp
	Endfor

	lcPost = ''
	For i = 1 To nRows
		If Alltrim(laAddress[i]) <> Alltrim(lcIndex) And Alltrim(Upper(laAddress[i])) <> Alltrim(Upper(lcLinn))
			lcPost = lcPost + Iif(i > 1, ', ','') + laAddress[i]
		Endif
	Endfor

	If Empty(lcLinn)
		lcLinn = laAddress[nRows]
	Endif

	returnAadress[1] = lcPost
	returnAadress[2] = lcIndex
	returnAadress[3] = lcLinn

	Return returnAadress[index]
Endfunc


Function test
	grekv = 119
	gnhandle = SQLConnect('NarvaLvPg','vlad','Vlad490710')
	getAddress('rahu 15, Narva, 29024')

Endfunc
