PARAMETERS l_lib_name, l_item_name, l_cursor

SET TEXTMERGE on

Local loXMLHTTP As "MSXML2.XMLHTTP"
Local cUrl, l_found_xml
Local cMessage

Create Cursor m_memo (url c(120), Header c(120), Request m, response m, Timestamp T Default Datetime())


cUrl = Alltrim(v_config_.earved)	

cAuth = ALLTRIM(qryRekv.earved)


TEXT TO cMessage TEXTMERGE noshow
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:erp="http://e-arvetekeskus.eu/erp">
<soapenv:Header/>
<soapenv:Body>
<erp:DimensionRegistryRequest format="AXAPTA" replace="NO" parseConnections="YES" authPhrase="<<cAuth>>">

ENDTEXT

cMessage = cMessage + '<Dimensioonid><' + l_lib_name + '>'

SELECT (l_cursor)
SCAN FOR !EMPTY(kood)
	cMessage = cMessage + '<' + l_item_name + '>'
TEXT TO cMessage ADDITIVE TEXTMERGE noshow


<Num><<LEFT(ALLTRIM(kood),15)>></Num>
<Description><<LEFT(ALLTRIM(nimetus),70)>></Description>

ENDTEXT
	cMessage = cMessage + '</' + l_item_name + '>'

Endscan

TEXT TO cMessage ADDITIVE TEXTMERGE noshow

</<<l_lib_name>>>
</Dimensioonid>
</erp:DimensionRegistryRequest>
</soapenv:Body>
</soapenv:Envelope>

ENDTEXT

loXMLHTTP = Createobject("MSXML2.XMLHTTP")
l_found_xml = 0



With loXMLHTTP

	.Open("POST", cUrl ,.F.)
	.setRequestHeader('Content-Type', 'text/xml;charset=UTF-8')
	.setRequestHeader('user-agent', 'sampleTest')
	.setRequestHeader('soapAction', '')

	Wait Window 'Oodan omniva... ' Nowait
	.Send(cMessage)
	Wait Window 'Oodan omniva... ok' Nowait

	Insert Into m_memo (url, Header, Request, response) Values (cUrl, 'text/xml;charset=UTF-8', cMessage, loXMLHTTP.responsetext)
	Wait Window 'Loen vastus...' Nowait

ENDWITH


If Atc('Ok', loXMLHTTP.responsetext) > 0 AND RECCOUNT('m_memo') > 0
	l_tulemus = .T.
	Messagebox('Tehtud!',0+48,'Liidestamine')

Else
	l_answer = Messagebox('Tekkis viga, kas näida päring?',4+32+256,'Liidestamine')
	If l_answer = 6
		_Cliptext = cMessage
		Select m_memo
		Modify Memo m_memo.response
		Return .F.
*		Brow
	Endif

Endif


