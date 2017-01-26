parameters pcFileName, pcReport

*******************************************************************************
* Print2PDF.PRG  Version 1.3
*
* Parms: 	pcReport 				= Name of VFP report to run
*			pcOutputFile 			= Name of finished PDF file to create.
*
* Author:	Paul James (Life-Cycle Technologies, Inc.) mailto:paulj@lifecyc.com
* "Standing on the shoulders of giants", I incorporated the hard work of many
* talented individuals into one program (with my own additions, enhancements, etc.).
* This file is free for anyone to use and distribute.  
* If you plan any commercial distribution, please contact the appropriate people.
*
*
****** MANY THANKS:
* This program is based off the public domain work of:
* Sergey Berezniker		mailto:sergeyb@isgcom.com					(Automating Ghostscript DLLs)
* Bob Lee 				WWW.1amsoftware.com 		(pdfMaker)		(Original version of this program)
* Ed Rauh 				mailto:edrauh@earthlink.net (clsheap.prg)	(Variables for DLLs, etc.)
*
*
****** PURPOSE:
* This program will run a VFP report and output it to a postscript file (temporary filename, temp folder).
* This part of the code uses the Adobe postscript printer driver.
* (It will automatically select the appropriate Postscript printer driver.)
* It will then turn that postscript file into a PDF file (named whatever you want in whatever folder you want).
* This part of the code calls the Ghostscript DLL to turn the postscript file into a PDF.
*
*
****** REQUIREMENTS/SETUP:
*	The "Zip" file this file was included in, contains everything you need to start creating PDF's.
*	Just run the "Demo" program (P2Demo.prg) and it will automatically walk you through installing
*	Ghostscript and the Adobe Postscript driver.  It will then "print" a demo VFP report to a PDF!
*
*
****** COLOR PRINTING:
*	If you want to have "color" in your PDF's, you will need an additional file.
*	 The "Zip" file includes this file.  It is a "Generic Color PostScript" PPD from Adobe.

*	When you are installing the Adobe PostScript driver:
*		In the install dialogue, choose Local Printer.
*		Choose an output port of FILE.
*		When prompted to "Select Printer Model", click the "Browse" button, 
*		locate the file (included with this program) named DEFPSCOL.PPD,
*		Choose the "Generic Color Printer" from the printer list.
*
*	The following web page has excellent additional documentation: 
*		http://www.ep.ph.bham.ac.uk/general/printing/winsetup.html
*
*
****** NOTES:
*	If an Error ocurrs, a .False. return code will be returned, but you should check the .lError property.
*	If .lError is .True., then the .cError property will have text explaining the error.
*
*	Because this is a class, you can either call the Main() method to execute all logic,
*	or you can set the properties yourself and call individual methods as needed (sweet).
*
*
****** EXAMPLE CALLS:
*	1.	*A one line call (nice and neat)
*		loPDF = createobject("Print2PDF", lcMyPDFName, lcMyVFPReport, .t.)
*
*	2.	*This is probably the most typical example.
*		set procedure to Print2PDF.prg additive
*		loPDF = createobject("Print2PDF")
*		if isnull(loPDF)
*			=messagebox("Could not setup PDF class!",48,"Error")
*			return .f.
*		endif
*
*		with loPDF
*			.cINIFile 		= gcCommonPath+"\Print2PDF.ini"
*			.cOutputFile 	= "C:\Output\myfile.pdf"
*			.cReport		= "C:\Myapp\Reports\MyVFPReport.frx"
*			llResult 		= .Main()
*		endwith
*
*		if !llResult or loPDF.lError
*			=messagebox("This error ocurred creating the PDF:"+chr(13)+;
*						alltrim(loPDF.cError),48,"Error Message")
*		endif
*
*	3.	*This example shows manually setting some properties.
*		loPDF = createobject("Print2PDF")
*		loPDF.cReport = "C:\MyApp\Reports\MyVfpReport.frx"
*		loPDF.cOutputFile = "C:\Output\myfile.pdf"
*		loPDF.cPSPrinter = "My PS Printer Name"
*		llResult = loPDF.Main()
*
*	4.	*This example assumes you have created the (.ps) Postscript file yourself and just want to create the PDF.
*		loPDF = createobject("Print2PDF")
*		loPDF.ReadIni()
*		loPDF.cOutputFile = "C:\Output\myfile.pdf"
*		loPDF.cPSFile = "C:\temp\myfile.ps"
*		llResult = loPDF.MakePDF()
*
*
****** OTHER LINKS:
*	If you want to make sure you have a recent copy of the Adobe Generic Postscript printer driver:
*		http://www.adobe.com/support/downloads/detail.jsp?ftpID=1500
*		This link changes periodically, so you might also just try:
*		http://www.adobe.com/support/downloads/product.jsp?product=44&platform=Windows
*
*	Main Ghostscript Web Site:	http://www.ghostscript.com/doc/AFPL/index.htm
*	Licensing Page: http://www.ghostscript.com/doc/cvs/New-user.htm#Find_Ghostscript
*
*
****** GHOSTSCRIPT:
*	Ghostscript does NOT register it's DLL file with Windows, so this code has a function called GSFind()
*	that will try to find the Ghostscript DLL.  Here is what it does:
*	1. See if it is in the VFP Path.
*	2. Grab the location out of the Print2PDF.INI file (if it exists)
*	3. Look in the default installation folder of C:\GS\
*	If the program uses option #3 (my preference) then it will automatically detect the
*	subfolder used to contain the DLL.  Since I am running version 7.04, my
*	folder is "C:\gs\gs7.04\bin\".  The program looks for "C:\GS\GSxxxxx\bin\"
*
*	GhostScript's job (in this class) is to take a "postscript file" (.ps) and turn
*	it into a PDF file (compatible with Adobe 3.x and above).  A "postscript file"
*	is basically a file that contains all of the "printer commands" necessary to
*	print the document, including fonts, pictures, etc.  You could go to a DOS prompt
*	and "copy" a postscript file to your printer port, and it should print the document
*	(providing your printer was Postscript Level 2 capable).  Ghostscript has many other
*	abilities, including converting a PDF back into a postscript file.
*
*	Ghostscript ONLY "prints" what is in the postscript file.  What gets into the
*	postscript file is determined by the "Postscript Printer Driver" that you are
*	using.  If you want COLOR for example, you must use a driver that supports color.
*	Also, because it is setup in Windows like any other 'printer', you can use the
*	Printer Control Panel to change the settings of the driver (cool).
*
*	The "Aladdin Free Public License" (AFPL) version of Ghostscript is "free" as long as
*	it is not a commercial package.
*	The Ghostscript web site has the most recent "publicly released" version.  Also,
*	you can download the actual Source Code for Ghostscript (written in C), and you
*	also get the developer's documentation which describes all parameters, etc.  The
*	parms used here are pretty generally acceptable, but if you need higher resolution,
*	debug messages, printer specific stuff, etc. it's good to have.
*
*	Once you install Ghostscript (usually C:\gs\), you can run it (gswin32.exe)
*	It's main interface is a "command prompt" where you can interactively enter GS commands.
*	You can also enter "devicenames ==" at the GS command prompt to get a current list
*	of all "output devices" currently supported (DEVICE=pdfwrite, DEVICE=laserject, etc.)
*
*	The calls to the Ghostscript DLL interfaces use Ed Rauh's "clsheap.prg" program.  
*	It must be in your VFP path.  It is included in the ZIP file with this code 
*	(thanks Ed), or you can get it from the Universal Thread...
*		http://www.universalthread.com/wconnect/wc.dll?FournierTransformation~2,2,9482
*
*
****** REVISION HISTORY:
*	Version 1.2
*	---------------------------------------------------------------------------------
*	Turned this "thing" into a Class.
*	Added Flags and logic to allow the user to install Postscript on-the-fly.
*	Added Flags and logic to allow the user to install Ghostscript on-the-fly.
*	Added Flags and logic to allow the user to install Adobe Acrobat on-the-fly.
*	Added the ability to read most setting from the .INI file.
*
*	Version 1.3
*	---------------------------------------------------------------------------------
*	Corrected some logic bugs, and bugs in the .ini processing.
*	Changed .ini setting names to be the same as the variable names for clarity**.
*	Added all new properties to .ini file.
*	Added "cStartFolder" property to hold the folder the program is running from.
*	Added "cTempPath" property to hold the folder for storing temporary files.
*	Added support for printing "color" in pdf.
*		Added "lUseColor" to determine color printer use.
*		Added "cColorPrinter" property (and .ini setting) to hold color printer driver.
*	Added "cPrintResolution" so you can change printer resolution on-the-fly.
*	Added the ability to use "dynamic" or "variable" paths in the Install Paths (including this.cStartFolder)
*	Made this file callable as a "procedure".
*	Included Demo program, dbf, report.
*	Included Ghostscript and Postscript installs.
******************************************************************************************************************


*************************************************************************************************
*** The following code allows you to call the Print2PDF class as a Function/Procedure,
*** just pass in the Output Filename and the Report Filename like:
***		Do Print2PDF with "MyPdfFile" "MyVfpReport"
*** If you use Print2PDF as a class, this code NEVER gets hit!
*************************************************************************************************
if vartype(pcFileName) <> "C" or vartype(pcReport) <> "C" or empty(pcFileName) or empty(pcReport)
	=messagebox("No Parms passed to Print2PDF",48,"Error")
	return .f.
endif

local loPDF
loPDF = .NULL.

loPDF = createobject("Print2PDF")

if isnull(loPDF)
	=messagebox("Could not setup PDF class!",48,"Error")
	return .f.
endif

with loPDF
	.cOutputFile 	= pcFileName
	.cReport		= pcReport
	llResult 		= .Main()
endwith

if !llResult or loPDF.lError
	=messagebox("This error ocurred creating the PDF:"+chr(13)+alltrim(loPDF.cError),48,"Error Message")
endif

loPDF = .NULL.
release loPDF

return .t.



**************************************************************************************
** Class Definition :: Print2PDF
**************************************************************************************
define class Print2PDF as relation
	**Please note that any of these properties can be set by you in your code.
	**You can also set most of them by using the .ini file.

	**Set these properties (required)
	cReport			= space(0)	&&Name of VFP report to Run
	cOutputFile		= space(0)	&&Name of finished PDF file to create.

	**User-Definable properties (most of these can be set in the .ini file)
	cStartFolder	= justpath(sys(16))+iif(right(justpath(sys(16)),1)="\","","\")	&&Folder this program started from.
	cTempPath		= sys(5)+sys(2003)+'\temp\'	&&Folder for Temporary Files (default = VFP temp path)
	cExtraRptClauses= space(0)	&&Any extra reporting clauses for the "report form" command
	lReadINI		= .t.		&&Do you want to pull settings out of Print2PDF.ini file?
	cINIFile		= this.cStartFolder+"Print2PDF.ini"	&&Name of INI file to use.  If not in current folder or VFP path, specify full path.
	lFoundPrinter	= .f.		&&Was the PS printer found?
	lFoundGS		= .f.		&&Was Ghostscript found?
	cPSPrinter		= space(0)	&&Name of the Windows Printer that is the Postscript Printer (default = "GENERIC POSTSCRIPT PRINTER")
	cPSColorPrinter	= space(0)	&&Name of the Windows Printer that is the Postscript Printer (default = "GENERIC COLOR POSTSCRIPT")
	lUseColor		= .f.		&&Use "color" printer driver?
	cPrintResolution= space(0)	&&Printer resolution string (300, 600x600, etc.) (default = "300")
	cPSFile			= space(0)	&&Path/Filename for Postscript file (auto-created if not passed)
	lErasePSFile	= .t.		&&Erase the .ps file after conversion?
	cPDFFile		= space(0)	&&Path/Filename for PDF file		(auto-created if not passed)
	cGSFolder		= space(0)	&&Path where Ghostscript DLLs exist	(auto-populated if not passed)


	**Internal properties
	lError			= .f.		&&Indicates that this class had an error.
	cError			= ""		&&Error message generated by this class
	cOrigSafety		= space(0)	&&Original "set safety" settting
	cOrigPrinter	= space(0)	&&Original "Set printer" setting


	**AutoInstall properties	&&See the ReadINI method for more details
	iInstallCount	= 1			&&Number of programs setup for AutoInstallation

	dimension aInstall[1, 7]

	aInstall[1,1] = space(0)	&&Program Identifier (used to find program in array)
	aInstall[1,2] = .t.			&&Can we install this product
	aInstall[1,3] = space(0)	&&Product Name (for user)
	aInstall[1,4] = space(0)	&&Description of product for user
	aInstall[1,5] = space(0)	&&Folder where install files are stored
	aInstall[1,6] = space(0)	&&Setup Executable name
	aInstall[1,7] = space(0)	&&Notes to show user before installing


	**************************************************************************************
	** Class Methods
	**************************************************************************************
	**********************
	** Init Method
	**********************
	function init(pcFileName, pcReport, plRunNow)
		with this
			.cOrigSafety = set("safety")
			.cOrigPrinter = set("Printer", 3)

			.lError = .f.
			.cError = ""

			if type("pcFileName") = "C" and !empty(pcFileName)
				.cOutputFile = alltrim(pcFileName)
			endif

			if type("pcReport") = "C" and !empty(pcReport)
				.cReport = alltrim(pcReport)
			endif
		endwith

		set safety off

		**Did User pass in parm to autostart the Main method?
		if type("plRunNow") = "L" and plRunNow = .t.
			return this.main()
		endif
	endfunc


	**********************************************************************
	** Cleanup Method
	** 	Make sure all objects are released, etc.
	**********************************************************************
	function CleanUp
		local lcOrigPrinter, lcOrigSafety

		with this
			lcOrigSafety = .cOrigSafety
			lcOrigPrinter = .cOrigPrinter
		endwith

		if !empty(lcOrigSafety)
			set safety &lcOrigSafety
		endif

		if !empty(lcOrigPrinter)
			set printer to
			set printer to name "&lcOrigPrinter"
		endif

		return
	endfunc


	**********************************************************************
	** ResetError Method
	** 	Call this method on each subsequent call to SendFax or CheckLog
	**********************************************************************
	function ResetError
		with this
			.lError = .f.
			.iError = 0
			.cError = ""
		endwith
		return .t.
	endfunc



	**************************************************************************************
	* Main Method - Main code
	*	If you wanted to run each piece seperately, you can make your own calls
	*	to each of the methods called below from within your program and not
	*	call this method at all.  That way, you could execute only the methods you want.
	*	For example, if your postscript file already existed, you could simply set
	*	the properties for the file location, then skip the calls that create the PS file
	*	and go straight to the MakePDF() method.
	**************************************************************************************
	function main(pcFileName, pcReport)
		local x
		store 0 to x

		with this
			if type("pcFileName") = "C" and !empty(pcFileName)
				.cOutputFile = alltrim(pcFileName)
			endif

			if type("pcReport") = "C" and !empty(pcReport)
				.cReport = alltrim(pcReport)
			endif

			if empty(.cReport) or empty(.cOutputFile)
				.lError = .t.
				.cError(".cReport and/or .cOutputFile empty",48,"Error")
				return .f.
			endif

			**Get values from Print2Pdf.ini file
			**Also sets default values even if .ini is not used.
			if !.lError
				=.ReadINI()
			endif

			**Set printer to PostScript
			if !.lError
				=.SetPrinter()
			endif

			**Create the Postscript file
			if !.lError
				=.MakePS()
			endif

			**Make sure Ghostscript DLLs can be found
			if !.lError
				=.GSFind()
			endif

			**Turn Postscript into PDF
			if !.lError
				=.MakePDF()
			endif

			**Install PDF Reader
			if !.lError
				=.InstPDFReader()
			endif

			.CleanUp()
		endwith

		return !this.lError
	endfunc



	**************************************************************************************
	* ReadIni()	-	Function to open/read contents of Print2PDF.INI file.
	*			-	If the .ReadINI property is .False., this method will not run
	*			-	This method examines each property, it will not overwrite a property
	*				with a value from the .INI that you have already populated via code.
	**************************************************************************************
	function ReadINI()
		local lcTmp
		store "" to lcTmp

		**If we're not supposed to read the INI, make sure default values are set
		if this.lReadINI = .t.
			**Win API declaration
			declare integer GetPrivateProfileString ;
				in WIN32API ;
				string cSection,;
				string cEntry,;
				string cDefault,;
				string @cRetVal,;
				integer nSize,;
				string cFileName


			**Read INI settings
			with this
				**General Properties
				**Postscript Printer Driver Name
				if empty(.cPSPrinter)
					.cPSPrinter = .ReadIniSetting("PostScript", "cPSPrinter")
				endif

				**Color Postscript Printer Driver Name
				if empty(.cPSColorPrinter)
					.cPSColorPrinter = .ReadIniSetting("PostScript", "cPSColorPrinter")
				endif
		
				**Name of PostScript file
				if empty(.cPSFile)
					.cPSFile = .ReadIniSetting("PostScript", "cPSFile")
				endif

				**Name of folder to hold Temporary postscript files
				if empty(.cTempPath)
					.cTempPath = .ReadIniSetting("PostScript", "cTempPath")
				endif

				**Name of PDF file
				if empty(.cPDFFile)
					.cPDFFile = .ReadIniSetting("GhostScript", "cPDFFile")
				endif

				**Name of Ghostscript folder (where installed to)
				if empty(.cGSFolder)
					.cGSFolder = .ReadIniSetting("GhostScript", "cGSFolder")
				endif

				**Resolution for PDF files
				if empty(.cPrintResolution)
					.cPrintResolution = .ReadIniSetting("PostScript", "cPrintResolution")
				endif

				**Installation Packages
				**# of packages to store settings for
				lcTmp = .ReadIniSetting("Install", "iInstallCount")
				if !empty(lcTmp)
					.iInstallCount = val(lcTmp)

					if .iInstallCount > 1
						dimension .aInstall[.iInstallCount, 7]
					endif

					for x = 1 to .iInstallCount
						**What is the "programmatic" ID for this package
						.aInstall[x,1] = upper(.ReadIniSetting("Install", "cInstID"+transform(x)))

						**Can we install this package?
						lcTmp = upper(.ReadIniSetting("Install", "lAllowInst"+transform(x)))
						.aInstall[x,2] = iif("T" $ lcTmp or "Y" $ lcTmp, .t., .f.)

						**Product Name
						.aInstall[x,3] = .ReadIniSetting("Install", "cInstProduct"+transform(x))

						**Description of Product to show user
						.aInstall[x,4] = .ReadIniSetting("Install", "cInstUserDescr"+transform(x))

						**Folder where installation files exist
						.aInstall[x,5] = .ReadIniSetting("Install", "cInstFolder"+transform(x))

						**Executable file to start installation
						.aInstall[x,6] = .ReadIniSetting("Install", "cInstExe"+transform(x))
						
						**Instructions to User
						.aInstall[x,7] = .ReadIniSetting("Install", "cInstInstr"+transform(x))
					endfor
				endif
			ENDWITH
		ENDIF
		
		**Make sure these basic settings are not blank
		if empty(.cPSPrinter)
			.cPSPrinter	= "GENERIC POSTSCRIPT PRINTER"
		endif
		if empty(.cPSColorPrinter)
			.cPSColorPrinter = "GENERIC COLOR POSTSCRIPT"
		ENDIF
		if empty(.cTempPath)
			.cTempPath = sys(2023) + iif(right(sys(2023),1)="\","","\")
		endif
		if empty(.cPrintResolution)
			.cPrintResolution= "300"
		endif
		return .t.
	endfunc



	**************************************************************************************
	* ReadIniSetting() - Returns the value of a "setting" from an "INI" file (text file)
	*				 	 (returns "" if string is not found)
	*	Parms:	pcSection	= The "section" in the INI file to look in...	[Section Name]
	*			pcSetting	= The "setting" to return the value of			Setting="MySetting"
	**************************************************************************************
	function ReadIniSetting(pcSection, pcSetting)
		local lcRetValue, lnNumRet, lcFile
		
		lcFile = alltrim(this.cIniFile)

		lcRetValue = space(8196)

		**API call to get string
		lnNumRet = GetPrivateProfileString(pcSection, pcSetting, "[MISSING]", @lcRetValue, 8196, lcFile)

		
		lcRetValue = alltrim(substr(lcRetValue, 1, lnNumRet))
		
		if lcRetValue == "[MISSING]"
			lcRetValue = ""
		endif
		
		return lcRetValue
	endfunc



	**************************************************************************************
	* SetPrinter() - Set the printer to the PostScript Printer
	**************************************************************************************
	function SetPrinter()
		local x, lcPrinter
		x = 0
		lcPrinter = ""
		
		with this
			if empty(.cPSPrinter)
				.cPSPrinter = "GENERIC POSTSCRIPT PRINTER"
			endif
			if empty(.cPSColorPrinter)
				.cPSPrinter = "GENERIC COLOR POSTSCRIPT"
			endif

			if .lUseColor = .t.
				lcPrinter = .cPSColorPrinter
			else
				lcPrinter = .cPSPrinter
			endif
			
			.lFoundPrinter = .f.

			***Make sure a Postscript printer exists on this PC
			if aprinters(laPrinters) > 0
				for x = 1 to alen(laPrinters)
					if alltrim(upper(laPrinters[x])) == lcPrinter
						.lFoundPrinter = .t.
					endif
				endfor

				if !.lFoundPrinter
					.cError = lcPrinter+" is not installed!!"
					.lError = .t.
				endif
			else
				.cError = "NO printer drivers are installed!!"
				.lError = .t.
			endif

			if .lFoundPrinter
				*** Set the printer to Generic Postscript Printer
				lcEval = "SET PRINTER TO NAME '" +lcPrinter+"'"
				&lcEval

				if alltrim(upper(set("PRINTER",3))) == alltrim(upper(lcPrinter))
				else
					.cError = "Could not set printer to: "+alltrim(lcPrinter)
					.lError = .t.
					.lFoundPrinter = .f.
				endif
			endif

			**Auto-Install, If no PS printer was found.
			if !.lFoundPrinter
				if this.Install("POSTSCRIPT")	&&Install PS driver
					return this.SetPrinter()	&&Call this function again
				endif
			endif
		endwith

		return .lFoundPrinter
	endfunc



	**************************************************************************************
	* MakePS() - Run the VFP report to a PostScript file
	**************************************************************************************
	function MakePS()
		local lcReport, lcExtra, lcPSFile

		set safety off

		with this
			**If no PS printer was found yet, find it
			if !.lFoundPrinter
				if !.SetPrinter()
					return .f.
				endif
			endif

			lcReport	= .cReport
			lcExtra		= .cExtraRptClauses

			if empty(lcReport)
				.cError = "No Report File was specified."
				.lError = .t.
				return .f.
			endif

			if empty(.cPSFile)
				*** We'll create a Postscript Output File (use VFP temporary path and temp filename)
				.cPSFile = .cOutputFile			
&&				.cPSFile = .cTempPath + sys(2015) + ".ps"
			endif

			lcPSFile = .cPSFile

			*** Make sure we erase existing file first
			erase (lcPSFile)

			report form (lcReport) &lcExtra noconsole to file &lcPSFile

			if !file(lcPSFile)
				.cError = "Could create PDF file"
				.lError = .t.
				return .f.
			endif
		endwith

		return .t.
	endfunc



	**************************************************************************************
	* GSFind() - Finds the Ghostscript DLL path and adds it to the VFP path
	**************************************************************************************
	function GSFind()
		local x, lcPath
		store "" to lcPath
		store 0 to x

		with this
			.lFoundGS = .f.

			**Look for Ghostscript DLL files.  If not in the VFP path, then GSFind().
			if file("gsdll32.dll")
				.lFoundGS = .t.
				return .t.
			endif

			**Try location specified in INI file
			if !empty(.cGSFolder)
				lcTmp = .cGSFolder + "gsdll32.dll"			&&Make sure the DLL file can be found
				if !file(lcTmp)
					.cGSFolder = ""
				endif
			endif

			*Look for them to exist in C:\gs\gsX.XX\bin\
			if empty(.cGSFolder)
				if !directory("C:\gs")
					return .f.
				endif

				liGS = adir(laGSFolders, "C:\gs\*.*","D")
				if liGS < 1
					return .f.
				endif

				for x = 1 to alen(laGSFolders,1)
					lcTmp = alltrim(upper(laGSFolders[x,1]))
					if "GS" = left(lcTmp,2) and "D" $ laGSFolders[x,5]
						.cGSFolder = lcTmp
						exit
					endif
				endfor

				if empty(.cGSFolder)
					return .f.
				endif

				.cGSFolder = "c:\gs\"+alltrim(.cGSFolder)+"\bin\"
			endif

			if !empty(.cGSFolder)
				lcTmp = .cGSFolder + "gsdll32.dll"			&&Make sure the DLL file can be found
				if !file(lcTmp)
					.cGSFolder = ""
				endif
			endif

			if empty(.cGSFolder)
				return .f.
			else
				.lFoundGS = .t.
			endif
		endwith

		lcPath = alltrim(set("Path"))
		set path to lcPath + ";" + .cGSFolder

		return .t.
	endfunc




	**************************************************************************************
	* MakePDF() - Run Ghostscript to create PDF file from the Postscript file
	**************************************************************************************
	function MakePDF()
		local lcPDFFile, lcOutputFile, lcPSFile

		set safety off

		with this
			**Make sure Ghostscript DLLs have been found (or install them)
			if !.lFoundGS
				if !.GSFind()

					**Auto-Install, Ghostscript
					if .Install("GHOSTSCRIPT")
						if !.GSFind()	&&Call function again
							.cError = "Could not Install Ghostscript!"
							.lError = .t.
							return .f.
						endif
					endif
				endif
			endif

			lcOutputFile	= .cOutputFile
			lcPSFile		= .cPSFile

			if empty(.cPDFFile)
				.cPDFFile = juststem(lcPSFile) + ".pdf"
			endif

			lcPDFFile = .cPDFFile
			erase (lcPDFFile)

			if !.GSConvertFile(lcPSFile, lcPDFFile)
				.cError = "Could not create: "+lcPDFFile
				.lError = .t.
			endif

			if !file(lcPDFFile)
				.cError = "Could not create: "+lcPDFFile
				.lError = .t.
			endif

			**Get rid of .ps file
*!*				if .lErasePSFile
*!*					erase (lcPSFile)
*!*				endif

			**Make sure output file does not exist already
*!*				erase (lcOutputFile)

			*** Move the temp file to the actual file name by renaming
*!*				rename (lcPDFFile) to (lcOutputFile)

			if !file(lcOutputFile)
				.cError = "Could not rename file to "+lcOutputFile
				.lError = .t.
			endif
		endwith
		return !this.lError
	endfunc



	**************************************************************************************
	* GSConvert() - Sets up arguments that will be passed to Ghostscript DLL, calls GSCall
	**************************************************************************************
	function GSConvertFile(tcFileIn, tcFileOut)
		local lnGSInstanceHandle, lnCallerHandle, loHeap, lnElementCount, lcPtrArgs, lnCounter, lnReturn
		dimension  laArgs[11]

		store 0 to lnGSInstanceHandle, lnCallerHandle, lnElementCount, lnCounter, lnReturn
		store null to loHeap
		store "" to lcPtrArgs

		set safety off
		set procedure to clsheap additive
		loHeap = createobject('Heap')

		**Declare Ghostscript DLLs
		clear dlls "gsapi_new_instance", "gsapi_delete_instance", "gsapi_init_with_args", "gsapi_exit"

		declare long gsapi_new_instance in gsdll32.dll ;
			long @lngGSInstance, long lngCallerHandle
		declare long gsapi_delete_instance in gsdll32.dll ;
			long lngGSInstance
		declare long gsapi_init_with_args in gsdll32.dll ;
			long lngGSInstance, long lngArgumentCount, ;
			long lngArguments
		declare long gsapi_exit in gsdll32.dll ;
			long lngGSInstance

		laArgs[1] = "dummy" 			&&You could specify a text file here with commands in it (NOT USED)
		laArgs[2] = "-dNOPAUSE"			&&Disables Prompt and Pause after each page
		laArgs[3] = "-dBATCH"			&&Causes GS to exit after processing file(s)
		laArgs[4] = "-dSAFER"			&&Disables the ability to deletefile and renamefile externally
		laArgs[5] = "-r"+this.cPrintResolution	&&Printer Resolution (300x300, 360x180, 600x600, etc.)
		laArgs[6] = "-sDEVICE=pdfwrite"	&&Specifies which "Device" (output type) to use.  "pdfwrite" means PDF file.
		laArgs[7] = "-sOutputFile=" + tcFileOut	&&Name of the output file
		laArgs[8] = "-c"				&&Interprets arguments as PostScript code up to the next argument that begins with "-" followed by a non-digit, or with "@". For example, if the file quit.ps contains just the word "quit", then -c quit on the command line is equivalent to quit.ps there. Each argument must be exactly one token, as defined by the token operator
		laArgs[9] = ".setpdfwrite"		&&If this file exists, it uses it as command-line input?
		laArgs[10] = "-f"				&&(ends the -c argument started in laArgs[8])
		laArgs[11] = tcFileIn			&&Input File name (.ps file)

		* Load Ghostscript and get the instance handle
		lnReturn = gsapi_new_instance(@lnGSInstanceHandle, @lnCallerHandle)
		if (lnReturn < 0)
			loHeap = null
			RELEASE loHeap
			this.lError = .t.
			this.cError = "Could not start Ghostscript."
			return .f.
		endif

		* Convert the strings to null terminated ANSI byte arrays
		* then get pointers to the byte arrays.
		lnElementCount = alen(laArgs)
		lcPtrArgs = ""
		for lnCounter = 1 to lnElementCount
			lcPtrArgs = lcPtrArgs + NumToLONG(loHeap.AllocString(laArgs[lnCounter]))
		endfor
		lnPtr = loHeap.AllocBlob(lcPtrArgs)

		lnReturn = gsapi_init_with_args(lnGSInstanceHandle, lnElementCount, lnPtr)
		if (lnReturn < 0)
			loHeap = null
			RELEASE loHeap
			this.lError = .t.
			this.cError = "Could not Initilize Ghostscript."
			return .f.
		endif

		* Stop the Ghostscript interpreter
		lnReturn=gsapi_exit(lnGSInstanceHandle)
		if (lnReturn < 0)
			loHeap = null
			RELEASE loHeap
			this.lError = .t.
			this.cError = "Could not Exit Ghostscript."
			return .f.
		endif


		* release the Ghostscript instance handle'
		=gsapi_delete_instance(lnGSInstanceHandle)

		loHeap = null
		RELEASE loHeap

		if !file(tcFileOut)
			this.lError = .t.
			this.cError = "Ghostscript could not create the PDF."
			return .f.
		endif

		return .t.
	endfunc



	**************************************************************************************
	* InstPDFReader Method - Installs the PDFReader if needed
	**************************************************************************************
	function InstPDFReader()
		**Make sure the PDF file has been created
		if !file(.cOutputFile)
			return .f.
		endif

		**Ask Windows which EXE is associated with this file (extension)
		lcExe = .AssocExe(.cOutputFile)

		if empty(lcExe)
			**Install the PDF Reader
			return .Install("PDFREADER")
		else
			return .t.
		endif
	endfunc


	**************************************************************************************
	* AssocExe Method - Returns the Executable File associated with a file
	**************************************************************************************
	function AssocExe(pcFile)
		local lcExeFile
		store "" to lcExeFile

		declare integer FindExecutable in shell32;
			string   lpFile,;
			string   lpDirectory,;
			string @ lpResult

		lcExeFile = space(250)

		if FindExecutable(pcFile, "", @lcExeFile) > 32
			lcExeFile = left(lcExeFile, at(chr(0), lcExeFile) -1)
		else
			lcExeFile = ""
		endif

		return lcExeFile
	endfunc


	**************************************************************************************
	* Install Method - Installs software on the PC
	**************************************************************************************
	function Install(pcID)
		local llFound, x, lcEval, lcProduct, lcDesc, lcTmp, ;
				lcFolder, lcInstEXE, lcInstruct, llDynaPath
		store "" to lcEval, lcProduct, lcAbbr, lcDesc, lcTmp, lcFolder, lcInstEXE, lcInstruct
		store .f. to llFound, llDynaPath

		with this
			pcID = alltrim(upper(pcID))

			**See if this Installation ID is in our array
			for x = 1 to alen(.aInstall,1)
				if alltrim(upper(.aInstall[x,1])) == pcID
					llFound = .t.
					exit
				endif
			endfor

			if !llFound
				.lError = .t.
				.cError = "Installation parms do not exist for ID: "+pcID
				return .f.
			endif

			**Copy array contents to variables
			llDoInst	= .aInstall[x,2]
			lcProduct	= .aInstall[x,3]
			lcDesc		= .aInstall[x,4]
			lcFolder	= .aInstall[x,5]
			lcInstEXE	= .aInstall[x,6]
			if !empty(.aInstall[x,7])
				lcInstruct	= ALLTRIM(.aInstall[x,7])
				if "+" $ lcInstruct
					lcInstruct = &lcInstruct
				endif
			else
				lcInstruct	= "Please accept the 'Default Values'"+chr(13)+"during the installation."
			endif

			**See if the path is "dynamically" generated based on variables
			if "+" $ lcFolder
				llDynaPath = .t.
			else
				llDynaPath = .f.
			endif
			
			**Are we allowed to install this product?
			if llDoInst = .t.
				**Make sure we have the Folder and Executable to install from?
				if !empty(lcFolder) and !empty(lcInstEXE)
					if llDynaPath
						lcFolder = alltrim(lcFolder)
						lcEval = &lcFolder
						lcEval = lcEval+alltrim(lcInstEXE)	&&command string
					else
						if right(lcFolder,1) <> "\"				&&Make sure the final backslash exists
							lcFolder = lcFolder + "\"
						endif
				
						lcEval = alltrim(lcFolder)+alltrim(lcInstEXE)	&&command string
					endif

					**Make sure install .exe exists in the path given
					if !llDynaPath and !file(lcEval)
						.cError = "Could not find installer for "+lcProduct+" in:"+chr(13)+alltrim(lcEval)
						.lError = .t.
					else
						if 7=messagebox(lcProduct+" needs to be installed on your computer."+chr(13)+;
								lcDesc+chr(13)+;
								"Is it OK to install now?",36,"Confirmation")
							.lError = .t.
							.cError = "User cancelled "+lcProduct+" Installation."
							return .f.
						endif

						=messagebox(lcInstruct,64,"Instructions")

						**Do the Installation
						.aInstall[x,2] = .f.		&&Do not allow ourselves to get into a loop
						lcEval = "run /n "+lcEval
						&lcEval

						=messagebox("When the Installation has finished"+chr(13)+;
							"COMPLETELY, please click OK...",64,"Waiting for Installation...")

						**Did it work?
						if 7=messagebox("Was the installation successfull?"+chr(13)+chr(13)+;
								"If no errors ocurred during the Installation"+chr(13)+;
								"and everything went OK, please click 'Yes'...",36,"Everything OK?")
							.lError = .t.
							.cError = "Errors ocurred during "+lcProduct+" Installation."
							return .f.
						else
							.lError = .f.
							.cError = ""
							return .t.
						endif
					endif
				endif
			endif
		endwith
		return .f.
	endfunc

enddefine

*** End of Class Print2PDF ***
