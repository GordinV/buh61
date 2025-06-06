Lparameters tnId
Local lError, oXML, loNode, lnNodes, oNode

lcFile = 'C:\temp\buh60\edok\earved.xml'
*lcFile = 'C:\avpsoft\buh61\XML\example.xml'

If !File(lcFile)
	Messagebox('file not found')
	Return
ENDIF

grekv = 119
CREATE CURSOR v_rekv (regkood c(20), nimetus c(254))
INSERT INTO v_rekv (regkood, nimetus) VALUES ('75024260', '0860001 Kultuuriosakond')

IF !USED('comAsutusRemote')
	TEXT TO lcString
			SELECT nimetus::varchar AS nimetus,  regkood, id, aadress, kontakt, email, asutus.tp, asutus.omvorm, fnc_ntod(rekvid)::date as kehtivus 
				FROM  Asutus 

	ENDTEXT
	
	
	

	gnhandle = SQLConnect('NarvaLvPg')
	If gnhandle < 0
		Set Step On
		return
	Endif

	lnError = SQLEXEC(gnhandle,lcString,'comAsutusRemote')
	IF lnError < 0 
		SET STEP ON 
		return
	ENDIF
	
	=SQLDISCONNECT(gnhandle)

ENDIF


CREATE CURSOR v_arv_import (;
	id int DEFAULT 0,  rekvid int,  userid int,  journalid int DEFAULT 0,  doklausid int DEFAULT 0,  liik int NOT NULL DEFAULT 0,  operid int DEFAULT 0, ; 
	number c(20) DEFAULT space(1),  kpv d DEFAULT DATE(),  asutusid int DEFAULT 0,  arvid int DEFAULT 0,  lisa c(120) DEFAULT space(1),  tahtaeg date, ; 
	kbmta n(12,4) DEFAULT 0,  kbm n(12,4) DEFAULT 0,  summa n(12,4) DEFAULT 0,  tasud d,  tasudok c(254),  muud m,  jaak n(12,4) DEFAULT 0,;  
	objektid int DEFAULT 0,  objekt c(20), valuuta c(20) DEFAULT 'EUR', kuurs n(12,4) DEFAULT 1;
)

CREATE CURSOR v_arvread_import (;
  id int,  parentid int,  nomid int,  kogus n(18,3) DEFAULT 0,  hind n(12,4) DEFAULT 0,  soodus int DEFAULT 0,  kbm n(12,4)DEFAULT 0,  maha int DEFAULT 0,;  
  	summa n(12,4) DEFAULT 0,  muud m,  kood1 c(20) DEFAULT space(20),  kood2 c(20) DEFAULT space(20),  kood3 c(20) DEFAULT space(20), ; 
  	kood4 c(20)DEFAULT space(20),  kood5 c(20) DEFAULT space(20),  konto c(20) DEFAULT space(20),  tp c(20) DEFAULT space(20),  kbmta n(12,4) DEFAULT 0,;  
  	isikid int DEFAULT 0,  tunnus c(20) DEFAULT space(20),  proj c(20) DEFAULT space(20),  tahtaeg d;
)




*!*	Set Step On

*!*	oXML=Createobject('msxml.domdocument')  && This creates the parser object
*!*	oXML.Load(lcFile)

*!*	Create Cursor dok (XML Memo)
*!*	Append Blank
*!*	SET STEP ON

*!*	With oXML.DocumentElement.ChildNodes
*!*		For iCount = 0 To .Length - 1
*!*			loNode = .Item(iCount).childNodes
*!*			lnNodes = .Item(iCount).childNodes.length

*!*			DIMENSION aNode[lnNodes,3]

*!*			readNode(loNode, @aNode, '')
*!*			
*!*					FOR iSubCount = 0 TO lnNodes - 1
*!*						IF loNode.item(iSubCount).attributes.length > 0
*!*							SET STEP ON 		
*!*							loSubNode = loNode.item(iSubCount).childNodes
*!*							lnSubNodes = loSubNode.length
*!*							
*!*							DIMENSION aSubNode[lnNodes,3]
*!*							readNode(loSubNode, @aSubNode, aNode(iSubCount + 1,2)
*!*						ENDIF
*!*									
*!*					ENDFOR
*!*			
*!*		ENDFOR	
*!*	ENDWITH
*!*	MODIFY MEMO dok.xml

*!*	RETURN


*aNode = readNode(loNode, lnNodes, lcSubField)		

*WAIT WINDOW oXML.DocumentElement.Basename + ALLTRIM(STR(oXML.documentelement.childnodes.LENGTH )) TIMEOUT 3

With oXML.DocumentElement.ChildNodes
	For iCount = 0 To .Length - 1

		IF .item(iCount).baseName = 'Invoice'
			SELECT v_arv_import
			APPEND BLANK
			replace v_arv_import.id WITH v_arv_import.id + 1,;
				rekvid WITH gRekv,;
				liik WITH 1 IN v_arv_import
		ENDIF
		For iChild = 0 To .Item(0).ChildNodes.Length - 1
			oNode = .Item(iCount).ChildNodes(iChild)

			If !Isnull(oNode)
				lcField = oNode.NodeName
				lcFieldValue =  oNode.Text
				lcParentField = oNode.parentNode.NodeName
				
				
				IF lcParentField = 'InvoiceItemGroup'
					SET STEP ON 
				ENDIF
				
				* has atributes?
				IF oNode.parentNode.attributes.length > 0 
					lnLines = oNode.parentNode.attributes.length - 1
					FOR lnAtributes = 0 TO lnLines
						lcPropName = oNode.parentNode.attributes.item(lnAtributes).baseName
						lcPropValue = oNode.parentNode.attributes.item(lnAtributes).nodeValue
						Replace dok.XML With 'attributes: ' + 'Parent:' + lcParentField + ', Field:' + lcField + ', value:' + lcFieldValue + ;
							' prop:' +lcPropName + ' propvalue:' + lcPropValue + Chr(13) Additive In dok

					ENDFOR
					
				ENDIF

				Replace dok.XML With 'Parent:' + lcParentField + ', Field:' + lcField + ', value:' + lcFieldValue + Chr(13) Additive In dok
				Wait Window 'Parent:' + lcParentField + ', Field:' + lcField + ', value:' + lcFieldValue Nowait

				If !Isnull(oNode.hasChildNodes) And oNode.hasChildNodes
					For iSubChild = 0 To oNode.childNodes.length - 1
					
						lcSubField = oNode.childNodes.Item(iSubChild).NodeName
						lcSubFieldValue =  ALLTRIM(oNode.childNodes.Item(iSubChild).Text)
						lcSubParentField = oNode.childNodes.Item(iSubChild).parentNode.NodeName
				
*						IF lcSubField <> '#text' 
							Replace dok.XML With 'chield' + CHR(13) + 'Parent:' + lcSubParentField + ', Field:' + lcSubField + ', value:' + lcSubFieldValue + Chr(13) Additive In dok
*						ENDIF
						DO case
							CASE lcSubField = 'InvoiceNumber'
								replace v_arv_import.number WITH lcSubFieldValue IN v_arv_import
							CASE lcSubField = 'InvoiceDate'
								*2016-09-14
								ldKpv = DATE(VAL(LEFT(lcSubFieldValue,4)), VAL(SUBSTR(lcSubFieldValue,6,2)),val(RIGHT(lcSubFieldValue,2)))
								replace v_arv_import.kpv WITH ldKpv IN v_arv_import
							CASE lcSubField = 'PaymentInfo'
								SET STEP ON 
							CASE lcSubField = 'PayDueDate'
								*2016-09-14
								ldKpv = DATE(VAL(LEFT(lcSubFieldValue,4)), VAL(SUBSTR(lcSubFieldValue,6,2)),val(RIGHT(lcSubFieldValue,2)))
								replace v_arv_import.tahtaeg WITH ldKpv IN v_arv_import
								
							CASE lcSubField = 'SellerParty'
								loNode = oNode.childNodes.Item(iSubChild).childNodes
								lnNodes = loNode.length

								DIMENSION aNode[lnNodes,2]
								
								* saving node data into array
								aNode = readNode(loNode, lnNodes, lcSubField)							
							
								* looking for regnum
								* ASCAN(ArrayName, eExpression [, nStartElement [, nElementsSearched [, nSearchColumn [, nFlags ]]]])
								lnElement = ASCAN(aNode,'RegNumber')
								IF !EMPTY(lnElement)
								* line number
									lnLineNumber = ASUBSCRIPT(aNode, lnElement, 1)
									SELECT comAsutusRemote
									LOCATE FOR UPPER(regkood) = aNode(lnLineNumber,2)
									
									IF FOUND() 
										replace v_arv_import.asutusid WITH comAsutusRemote.id IN v_arv_import
									ENDIF									
																		
								ENDIF
								
								IF !FOUND()
									SET STEP ON 
								ENDIF
								
						ENDCASE
					
						ENDFOR 
						*!*oNode.childNodes.length
				ENDIF
				


			Endif

*            REPLACE (oNode.NodeName) WITH (oNode.TEXT)
		Endfor
	Endfor
Endwith

SELECT v_arv_import
brow
Modify Memo dok.XML



FUNCTION readNode
	LPARAMETERS loNode, laNode, cPrevNode
	LOCAL iNodes
*	DIMENSION aNode[nNodes,2]
	
	for iNodes = 0 to loNode.length - 1
		laNode(iNodes + 1,1) = loNode.item(iNodes).NodeName
		laNode(iNodes + 1,2) = loNode.item(iNodes).text
		laNode(iNodes + 1,3) = loNode.item(iNodes).hasChildNodes

		Replace dok.XML With 'parent: ' + cPrevNode + ', Field:' + laNode(iNodes + 1,1) + ', value:' + laNode(iNodes + 1,2) + Chr(13) Additive In dok

	ENDFOR
	
	
	RETURN @laNode
ENDFUNC


*FILE (lcFile)


*!*	cIds = ''

*!*	If !Empty(tnId)
*!*		cIds = Str(tnId)
*!*	Else
*!*		If Used('curArved')
*!*			Select curArved
*!*			If Len(cIds) > 1
*!*				cIds = cIds + ','
*!*			Endif

*!*			cIds = cIds + Alltrim(Str(curArved.Id))
*!*		Endif

*!*	Endif

*!*	*!*	gRekv = 119
*!*	cFail = 'c:\temp\buh60\EDOK\earved.xml'
*!*	cFailbak = 'c:\temp\buh60\EDOK\'+Alltrim(Str(grekv))+'earved'+Sys(2015)+'.bak'

*!*	If !Directory(Justpath(cFail))
*!*		Mkdir(Justpath(cFail))
*!*	Endif

*!*	If File (cFailbak)
*!*		Erase (cFailbak)
*!*	Endif
*!*	If File(cFail)
*!*		Rename (cFail) To (cFailbak)
*!*	Endif

*!*	=execute()

*!*	If !File(cFail)
*!*		cFail = ''
*!*	Endif

*!*	Return cFail


Function execute
TEXT TO lcString noshow
		select arv.*, case when arv.liik = 0 then a.regkood else rtrim(LTRIM(a.regkood)) end as regkood ,
			CASE when arv.liik = 0 then rekv.nimetus else rtrim(LTRIM(a.nimetus)) || ' ' || rtrim(a.omvorm) end as muuja,
			CASE when arv.liik = 1 then rekv.nimetus else rtrim(LTRIM(a.nimetus)) || ' ' || rtrim(a.omvorm) end as ostja
			from arv
			inner join asutus a on a.id = arv.asutusId
			inner join rekv on arv.rekvId = rekv.id
			where arv.rekvId = ?gRekv
			and arv.id in (?cIds)
			order by kpv, number, id
ENDTEXT
	lnError = SQLEXEC(gnhandle,lcString,'qryeArved')
	If lnError < 0
		Set Step On
	Endif


TEXT TO lcFileString NOSHOW
<?xml version="1.0" encoding="UTF-8"?>
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


		lcFileString = lcFileString + Chr(13)+ '<E_Invoice>' + Chr(13)+;
			'<Header>'+  Chr(13)+;
			'<Date>' + lcKpv + '</Date>' + Chr(13)+;
			'<FileId>' + Alltrim(Str(qryeArved.Id))+ '</FileId>'+Chr(13)+;
			'<AppId>EARVE</AppId>' + Chr(13)+;
			'<Version>1.1</Version>' + Chr(13)+;
			'</Header>'+  Chr(13) +;
			'<Invoice invoiceId="' + Alltrim(qryeArved.Number) + '" regNumber="' +Alltrim(qryeArved.regkood)+'">'+Chr(13)+;
			'<InvoiceParties>'+Chr(13)+;
			'<SellerParty>'+Chr(13)+;
			'<Name>' + Alltrim(qryeArved.muuja) + '</Name>' + Chr(13)+;
			'</SellerParty>' + Chr(13)+;
			'<BuyerParty>'+ Chr(13)+;
			'<Name>' + Alltrim(qryeArved.ostja) + '</Name>' + Chr(13)+;
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
			Exit
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
		Endif

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
	Return File(cFail)
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
	Endscan

*	Copy Memo tmpMk.iso To (cFail)
	Return lcString
*	Return File(cFail)
Endfunc
