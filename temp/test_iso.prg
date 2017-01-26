TEXT TO lcString 
<?xml version="1.0" encoding="UTF-8"?>
<Document xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03">
<CstmrCdtTrfInitn>
<GrpHdr>
<MsgId>215967</MsgId>
<CreDtTm>2015-12-14T08:00:00</CreDtTm>
<NbOfTxs>1</NbOfTxs>
<CtrlSum>80.00</CtrlSum>
<InitgPty><Nm>0922013 Narva Soldino Gumnaasium</Nm></InitgPty>
</GrpHdr>
<PmtInf>
<PmtInfId>PMTID001</PmtInfId>
<PmtMtd>TRF</PmtMtd>
<BtchBookg>true</BtchBookg>
<NbOfTxs>1</NbOfTxs>
<PmtTpInf><SvcLvl><Cd>SEPA</Cd></SvcLvl></PmtTpInf>
<ReqdExctnDt>2015-12-14</ReqdExctnDt>
<Dbtr>
<Nm>0922013 Narva Soldino Gumnaasium</Nm>
<PstlAdr>
<Ctry>EE</Ctry>
<AdrLine>Tallinna mnt 40, 21006 Narva</AdrLine>
</PstlAdr>
</Dbtr>
<DbtrAcct>
<Id><IBAN>221023013332</IBAN></Id>
<Ccy>EUR</Ccy>
</DbtrAcct>
<ChrgBr>SLEV</ChrgBr>
<CdtTrfTxInf>
<PmtId>
<EndToEndId>20512</EndToEndId>
</PmtId>
<Amt><InstdAmt Ccy="EUR">80.00</InstdAmt></Amt>
<Cdtr>
<Nm>IDA-VIRU KOOLIJUHTIDE ?ENDUS</Nm>
<PstlAdr><Ctry>EE</Ctry><AdrLine>Viru 14, 43125 Kivi??</AdrLine></PstlAdr>
</Cdtr>
<CdtrAcct><Id><IBAN>EE331010220119530011</IBAN></Id></CdtrAcct>
<RmtInf>
<Ustrd>Arve 3/15</Ustrd>
</RmtInf>
</CdtTrfTxInf></PmtInf>
</CstmrCdtTrfInitn>
</Document>
ENDTEXT

TEXT TO lcString2 


<?xml version="1.0" encoding="UTF-8"?>
<Document xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03">	
	<CstmrCdtTrfInitn>
		<GrpHdr>
			<MsgId>215966</MsgId>
			<CreDtTm>2015-12-14T08:00:00</CreDtTm>
			<NbOfTxs>1</NbOfTxs>
			<CtrlSum>95.40</CtrlSum>
			<InitgPty>
				<Nm>0922013 Narva Soldino Gumnaasium</Nm>
			</InitgPty>
		</GrpHdr>
		<PmtInf>
			<PmtInfId>PMTID001</PmtInfId>
			<PmtMtd>TRF</PmtMtd>
			<BtchBookg>true</BtchBookg>
			<NbOfTxs>1</NbOfTxs>
			<PmtTpInf>
				<SvcLvl>
				<Cd>SEPA</Cd>
				</SvcLvl>
			</PmtTpInf>
			<ReqdExctnDt>2015-12-14</ReqdExctnDt>
			<Dbtr>
				<Nm>0922013 Narva Soldino Gumnaasium</Nm>
				<PstlAdr>
				<Ctry>EE</Ctry>
				<AdrLine>Tallinna mnt 40, 21006 Narva</AdrLine>
				</PstlAdr>
			</Dbtr>
			<DbtrAcct>
				<Id><IBAN>221023013332</IBAN></Id>
				<Ccy>EUR</Ccy>
			</DbtrAcct>
			<ChrgBr>SLEV</ChrgBr>
			<CdtTrfTxInf>
				<PmtId>
					<EndToEndId>20498</EndToEndId>
				</PmtId>
				<Amt>
					<InstdAmt Ccy="EUR">95.40</InstdAmt>
				</Amt>
			</CdtTrfTxInf>
			<Cdtr>
				<Nm>Abakhan Fabrics Eesti</Nm>
				<PstlAdr><Ctry>EE</Ctry>
				<AdrLine>R??i 11, Tartu 51007;
				Energia 2, Narva 20304
				</AdrLine></PstlAdr>
			</Cdtr>
			<CdtrAcct>
				<Id>
					<IBAN>EE512200221005105213</IBAN>
				</Id>
			</CdtrAcct>
			<RmtInf>
				<Ustrd>Arve 20156075</Ustrd>
			</RmtInf>
		</PmtInf>
	</CstmrCdtTrfInitn>
</Document>
endtext

lcFile = 'c:\temp\buh60\iso.xml'

STRTOFILE(lcstring, lcFile, 4)

MODIFY FILE (lcFile)