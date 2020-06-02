Parameters tnId
Local loXMLHTTP As "MSXML2.XMLHTTP"
Local cUrl, l_tulemus
Local cMessage

IF EMPTY(tnId)
	gRekv = 1
	gUserId = 1
	cUrl = 'https://finance.omniva.eu/finance/erp/'	
*	l_secret = '106549:elbevswsackajyafdoupavfwewuiafbeeiqatgvyqcqdqxairz'
	l_secret = ' 88991:xemtclclnqovlpqaijfhpwjcgzntpgtzxghgquvpvqkwblhxay'
	cMessage = get_test_xml()
	l_fail_id = INT(RAND() * 1000000)
	l_dok_id = 1
	gnHandle = SQLCONNECT('meke','vlad','490710')
	
	SET STEP on	
ELSE
	cUrl = Alltrim(v_config_.earved)
	l_secret = ALLTRIM(qryRekv.earved)
	cMessage = get_xml()
	l_fail_id = get_last_file_id()	
	l_dok_id = tnId
ENDIF

* replace <FileId>1</FileId>
cMessage = STUFF(cMessage,ATC('<FileId>1</FileId>',cMessage),LEN('<FileId>1</FileId>'),'<FileId>' + ALLTRIM(STR(l_fail_id))+ '</FileId>')

* replace <?xml version="1.0" encoding="UTF-8"?>
cMessage = STUFF(cMessage,ATC('<?xml version="1.0" encoding="UTF-8"?>',cMessage),LEN('<?xml version="1.0" encoding="UTF-8"?>'),'')

Create Cursor m_memo (url c(120), Header c(120), Request m, response m, Timestamp T Default Datetime())


loXMLHTTP = Createobject("MSXML2.XMLHTTP")

With loXMLHTTP

	.Open("POST", cUrl ,.F.)
	.setRequestHeader('Content-Type', 'text/xml;charset=UTF-8')
	.setRequestHeader('user-agent', 'sampleTest')
	.setRequestHeader('soapAction', '')

	.Send(cMessage)
	
	IF !empty(loXMLHTTP.readystate) 

		Insert Into m_memo (url, Header, Request, response) Values (cUrl, 'text/xml;charset=UTF-8', cMessage, loXMLHTTP.responsetext)
	
	
		IF ATC('Ok', loXMLHTTP.responsetext) > 0
			l_tulemus = .t.
			
			* salvesta file_id
			
			TEXT TO l_sql TEXTMERGE noshow
				INSERT INTO fail_id (fail_id, dok_id, rekvid, kasutaja_id)
					values (<<l_fail_id>>, <<l_dok_id>>, <<gRekv>>,<<gUserId>>)
			ENDTEXT
			l_error = SQLEXEC(gnHandle, l_sql)
			IF l_error < 1
				SET STEP ON 
				l_sql = _cliptext
			ENDIF
			
		ENDIF
	ELSE
		MESSAGEBOX('Server ei vasta',0+64,'e-Arved')
	ENDIF
		

Endwith

IF EMPTY(l_tulemus)
	l_answer = MESSAGEBOX('Tekkis viga, kas näida päring?',4+32+256,'E-arved')
	IF l_answer = 6
		_cliptext = cMessage
		Select m_memo
		MODIFY MEMO m_memo.response 
		RETURN .f.
*		Brow	
	ENDIF
ELSE
	MESSAGEBOX('Arve saadetud!',0+48,'E-arved')
ENDIF

Return .t.
Endfunc

FUNCTION get_last_file_id
	LOCAL l_file_id
	TEXT TO l_sql TEXTMERGE noshow
		SELECT coalesce(MAX(fail_id),0)::integer as file_id FROM fail_id WHERE rekvid = <<gRekv>>
	ENDTEXT
	
	l_error = SQLEXEC(gnHandle, l_sql, 'tmp_file_id')
	
	IF l_error < 1
		SET STEP ON 
		_cliptext = l_sql
		RETURN 0
	ENDIF
	
	IF RECCOUNT('tmp_file_id') = 0 OR EMPTY(tmp_file_id.file_id)
			l_file_id =  1000000
	ELSE
		l_file_id = tmp_file_id.file_id + 1	
	endif

	USE IN tmp_file_id
	
	RETURN l_file_id 
ENDFUNC

*<VATRegNumber>EE100143647</VATRegNumber>


FUNCTION get_test_xml
Local l_xml, l_xml_arve

TEXT TO  l_xml TEXTMERGE noshow
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:erp="http://e-arvetekeskus.eu/erp">
<soapenv:Header/>
<soapenv:Body>
<erp:EInvoiceRequest authPhrase="88991:xemtclclnqovlpqaijfhpwjcgzntpgtzxghgquvpvqkwblhxay">
<E_Invoice>
<Header>
<Date>2019-08-05</Date>
<FileId>1000229</FileId>
<AppId>EARVE</AppId>
<Version>1.1</Version>
</Header>
<Invoice invoiceId="07014" regNumber="80426569">
<InvoiceParties>
<SellerParty>
<Name>AS Meke  Sillamae</Name>
<RegNumber>10337120</RegNumber>
<VATRegNumber>EE100143647</VATRegNumber>
<ContactData>
<PhoneNumber>3924081</PhoneNumber>
<LegalAddress>
<PostalAddress1>Ranna 3,  Sillamae</PostalAddress1>
<City>Sillamae</City>
</LegalAddress>
</ContactData>
<AccountInfo>
<AccountNumber/>
<IBAN>EE472200001120046901</IBAN>
</AccountInfo>
</SellerParty>
<BuyerParty>
<Name>Sillamae linn, J. Gagarini tn 11 korteriuhistu KU</Name>
<RegNumber>80426569</RegNumber>
<ContactData>
<E-mailAddress></E-mailAddress>
<LegalAddress>
<PostalAddress1>Ida-Viru maakond,  Sillamae linn,  J. Gagarini tn 11</PostalAddress1>
<City>J. Gagarini tn 11</City>
</LegalAddress>
</ContactData>
</BuyerParty>
</InvoiceParties>
<InvoiceInformation>
<Type type="DEB"/>
<ContractNumber></ContractNumber>
<DocumentName>Arve</DocumentName>
<InvoiceNumber>07014</InvoiceNumber><InvoiceDate>2019-07-11</InvoiceDate>
</InvoiceInformation>
<InvoiceSumGroup>
<InvoiceSum>10.16</InvoiceSum>
<VAT>
<VATRate>20</VATRate>
<VATSum>1.69</VATSum>
</VAT>
<TotalSum>10.16</TotalSum>
<Currency>EUR</Currency>
</InvoiceSumGroup>
<InvoiceItem>
<InvoiceItemGroup>
<ItemEntry>
<Description>Teenused .( Sanitaartehniliste  toode   eest )</Description>
<ItemDetailInfo>
<ItemUnit></ItemUnit>
<ItemAmount>1.0000</ItemAmount>
<ItemPrice>8.47</ItemPrice>
</ItemDetailInfo>
<ItemSum>8.47</ItemSum>
<VAT>
<VATRate>20</VATRate>
<VATSum>1.69</VATSum>
</VAT>
<ItemTotal>10.16</ItemTotal>
</ItemEntry>
</InvoiceItemGroup>
</InvoiceItem>
<PaymentInfo>
<Currency>EUR</Currency>
<PaymentRefId></PaymentRefId>
<PaymentDescription>Arve 07014               </PaymentDescription>
<Payable>YES</Payable>
<PayDueDate>2019-07-26</PayDueDate> 
<PaymentTotalSum>10.16</PaymentTotalSum>
<PayerName>Sillamae linn, J. Gagarini tn 11 korteriuhistu KU</PayerName>
<PaymentId>07014</PaymentId>
<PayToAccount>EE472200001120046901</PayToAccount>
<PayToName>AS Meke  Sillamae</PayToName>
</PaymentInfo>
</Invoice><Footer>
<TotalNumberInvoices>1</TotalNumberInvoices>
<TotalAmount>10.16</TotalAmount>
</Footer>
</E_Invoice></erp:EInvoiceRequest>
</soapenv:Body>
</soapenv:Envelope>
ENDTEXT

RETURN l_xml
ENDFUNC



Function get_xml
	Local l_xml, l_xml_arve
	
TEXT TO l_xml TEXTMERGE noshow

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:erp="http://e-arvetekeskus.eu/erp">
<soapenv:Header/>
<soapenv:Body>
<erp:EInvoiceRequest authPhrase="<<l_secret>>">
ENDTEXT
l_xml_arve = calc_earved(tnId)

l_xml = l_xml + l_xml_arve

TEXT TO l_xml TEXTMERGE NOSHOW additive

</erp:EInvoiceRequest>
</soapenv:Body>
</soapenv:Envelope>
ENDTEXT
	Return l_xml
ENDFUNC
