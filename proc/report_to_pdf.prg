Lparameters tcReport,tcPdf
Local lPdf, lnPrinters, lcDefaultPrinter

lcDefaultPrinter = Alltrim(getdefaultprinter())
*SET STEP ON 

lnPrinters = Aprinters(laPrint)
If Empty(lnPrinters)
	Return .F.
Endif
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

=adjust('PDFCreator')
Report Form (tcReport) Noconsole To Printer
*		lcFile = LEFT(TTOC(DATETIME(),1),14)+'.pdf'
	=adjust(lcDefaultPrinter)

	If File(tcPdf) 
		RETURN .t.
	ELSE
		RETURN .f.
	
	Endif


*		Do Proc\print2pdf With .Pdf, cReport, .spLeht1.Value,.spLeht2.Value




FUNCTION getdefaultprinter

DECLARE INTEGER GetDefaultPrinter IN winspool.drv; 
    STRING  @ pszBuffer,; 
    INTEGER @ pcchBuffer 
cBuff = SPACE(1024)
nBuff = 1024
IF getdefaultprinter(@cBuff, @nBuff) > 0
	RETURN cBuff
ENDIF

ENDFUNC


FUNCTION adjust
Lparameters tcPrintName
If !Empty(tcPrintName)
	lcPrinter = tcPrintName
Else
	lcPrinter = Getprinter()
Endif

If !Empty (lcPrinter)
	Declare Integer SetDefaultPrinter In winspool.drv;
		STRING pszPrinter

	=SetDefaultPrinter(lcPrinter)
	Set Printer To Name LTRIM(rtrim(lcPrinter))
Endif

ENDFUNC
