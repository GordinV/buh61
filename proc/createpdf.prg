Lparameters tcReport,tcPdf, tcPrefiks
Local lPdf, lnPrinters, lcDefaultPrinter

IF EMPTY(tcPrefiks)
	tcPrefiks = 'reklmaks\reklmaks.pdf'
ENDIF



DECLARE INTEGER GetDefaultPrinter IN winspool.drv; 
    STRING  @ pszBuffer,; 
    INTEGER @ pcchBuffer 
cBuff = SPACE(1024)
nBuff = 1024
IF getdefaultprinter(@cBuff, @nBuff) > 0
	lcDefaultPrinter = cBuff
ENDIF


lnPrinters = Aprinters(laPrint)
If Empty(lnPrinters)
	Return .F.
ENDIF

For i = 1 To lnPrinters
	If Alltrim(laPrint(i,1)) = 'PDFCreator'
		lPdf = .T.
	Endif
	If !Empty(lPdf)
*		SET PRINTER TO NAME laPrint(i,1)
		Exit
	Endif
Endfor

If !lPdf
	Messagebox('Puudub PDFCreator, vaata www.pdfforge.org','Viga')
	Return .F.
Endif

Set Printer To Name LTRIM(rtrim('PDFCreator'))

lcFile = Sys(5)+Sys(2003)+'\PDF\' + tcPrefiks
IF FILE(lcFile)
	WAIT TIMEOUT 3
	ERASE (lcFile) recycle
ENDIF

Report Form (tcReport) Noconsole To Printer
Set Printer To Name LTRIM(rtrim(lcDefaultPrinter))
lnSek = 0
FOR lnSek = 0 TO 2000
	IF FILE(lcFile)
		EXIT
	ENDIF
	lnSek = lnSek + 1
	WAIT TIMEOUT 1
ENDFOR


IF FILE(lcFile)	
	Rename (lcFile) To (tcPdf)
ENDIF

	If File(tcPdf) 
		RETURN .t.
	ELSE
		RETURN .f.
	
	Endif
