*	This program contains additional functions only (for SET PROCEDURE TO)
*
*	The program that actually is doing the work is RepExpFl.
*
*	Here are placed two type of functions:
*		1.	Functions NEEDED RepExpFl to work (they are called from inside RepExpFl).
*			These functions you can include in your project procedure file, or write your own
*			with same functionality.
*		2.	Functions needed only examples to work. With them you can do what you like.
*
*	Functions used in RepExpFl from Foxtools.fll: 
*		In VFP WORDS, WORDNUM.
*		In Foxpro 2.6 for Windows: some more functions like FORCEEXT and more.
*		In Foxpro 2.6 for DOS: you have to write replacements for all functions used from Foxtools.fll.

#INCLUDE "FOXPRO.H"

************************ START SECTION: Functions NEEDED RepExpFl to work
*	Functions NEEDED RepExpFl to work (they are called from inside RepExpFl).
*	These functions you can include in your project procedure file, or write your own
*	with same functionality.

***
*	Creates a table according to the given structure information
*	(CREATE TABLE or CREATE CURSOR with error handling)
*	Written by Nikolay Petkov
*	PARAMETERS:
*	tcPath
*		empty - create a cursor
*		valid path and name - create a table with given name
*	aStrct - structure information. Possibilities
*		1. with ARRAY
*		2. directly with string of type "field1 N(4), field2 C(10)"
*	tnBlockSiz - BLOCKSIZE for created table
*	tcAlias - (inp) alias (cursor name) to open cursor or table and to use in program
*			(out) - new alias
*	tcOtherFormat - (only in case of table creation) Table is created in other format. For example if here place FOX2X - in old 2.6 format
*		(see COPY TO command for more information)
*	RETURNs:
*		 0 if all is OK, otherwise number of the error
*		IF OK - new table is selected as work area
*	EXAMPLEs:
*	to create table
*IF CreTabl1( m.pathDB, @aStruct, 0, '', 'FREE' ) = 0	
*ENDIF
*	to create cursor
*IF CreTabl1( '', @aStruct, 0, m.tcAlias ) = 0	
*ENDIF
*
FUNCTION CreTabl1( tcPath, aStrct, tnBlockSiz, tcAlias, tcClause, tcOtherFormat )
IF EMPTY(m.tnBlockSiz)
	tnBlockSiz = SetBlock()
ENDIF
IF !IsChar(m.tcClause)
	tcClause = IIF( EMPTY(m.tcPath), '', 'FREE' ) && defaults to create FREE tables
ENDIF
LOCAL lcStructInfo, lnOldBlock, lnError, lcOldOnERR
IF TYPE("aStrct[1]")="U"
	lcStructInfo = "(" + m.aStrct + ")"
ELSE
	lcStructInfo = "FROM ARRAY aStrct"
ENDIF
lnOldBlock = SetBlock()
lnError = 0
lcOldOnERR = onError()
ON ERROR lnError=ERROR()
SET BLOCKSIZE TO m.tnBlockSiz
SELECT 0	&& in any case - to have criteria if can not be created
IF EMPTY(m.tcPath)
	*	create a CURSOR
	IF EMPTY(m.tcAlias)
		tcAlias = SYS(2015)
	ENDIF
	CREATE CURSOR (m.tcAlias) &tcClause ;
		&lcStructInfo
ELSE
	*	create a TABLE
	tcPath = Force_DBF(m.tcPath,.t.)
	IF EMPTY(m.tcOtherFormat)
		CREATE TABLE (m.tcPath) &tcClause ;
			&lcStructInfo
	ELSE
		*	Table is created in other format. For exmple if tcOtherFormat="FOX2X" - in old 2.6 format
		LOCAL lcAliasTmp
		lcAliasTmp = SYS(2015)
		CREATE CURSOR (m.lcAliasTmp) &lcStructInfo
		IF m.lnError = 0
			COPY TO (m.tcPath) TYPE &tcOtherFormat
			IF m.lnError = 0
				IF EMPTY(m.tcAlias)
					USE (m.tcPath) EXCLUSIVE
				ELSE
					USE (m.tcPath) ALIAS (m.tcAlias) EXCLUSIVE
				ENDIF
			ENDIF
		ENDIF
		=Close1(m.lcAliasTmp)
	ENDIF
	IF m.lnError = 0
		*	if OK, new table work area is selected
		IF !EMPTY(m.tcAlias) AND !CurAlias( m.tcAlias )
			*	if other alias is given - re-open with this alias
			USE (m.tcPath) ALIAS (m.tcAlias) EXCLUSIVE
		ENDIF
		FLUSH	&& to be shure that table files are really created on disk!! (otherwise buffering in Windows...)
	ENDIF
ENDIF
IF m.lnError = 0
	IF USED()
		tcAlias = ALIAS()
	ELSE
		lnError = -1	&& it is not created, but no error (!) - we set error to -1
	ENDIF
ENDIF
SET BLOCKSIZE TO m.lnOldBlock
ON ERROR &lcOldOnERR
RETURN m.lnError

***
*	Return FoxPro version running (compatible in all FoxPro versions)
*	VERSION(5) returns the number 700 in VFP, so this function is not universal and compatible in versions up to VFP
*	Written by Nikolay Petkov
*
FUNCTION FoxVersion
PRIVATE lcVerStr, lnVersion, ln1, ln2, i
lnVersion = 0
lcVerStr = VERSION(1)
FOR i=1 TO 3
	ln1 = AT(SPACE(1),m.lcVerStr,m.i) + 1
	ln2 = AT(SPACE(1),m.lcVerStr,m.i+1)
	lnVersion = VAL(SUBSTR(m.lcVerStr,m.ln1,m.ln2-m.ln1))
	IF m.lnVersion > 0
		EXIT
	ENDIF
ENDFOR
RETURN m.lnVersion

***
*	Returns RECNO(), but if the table is in state BOF(),EOF()
*	returns negative value, to be used with function GO1
*
FUNCTION RecNo1
LPARAMETERS tcAlias
IF EMPTY(m.tcAlias)
	tcAlias = ALIAS()
ENDIF
IF EMPTY(m.tcAlias)
	RETURN -3
ENDIF
IF EOF(m.tcAlias)
	RETURN -2
ENDIF
IF BOF(m.tcAlias)
	RETURN -1
ENDIF
RETURN RECNO(m.tcAlias)

***
*	As GO, but with checking position, to be used with function Recno1
*
FUNCTION Go1
LPARAMETERS tnRecToGo, tcAlias
IF EMPTY(m.tcAlias)
	tcAlias = ALIAS()
ENDIF
DO CASE
CASE m.tnRecToGo>RECCOUNT(m.tcAlias)
	GO BOTTOM IN (m.tcAlias)
	RETURN .f.
CASE m.tnRecToGo<1
	GO TOP IN (m.tcAlias)
	RETURN .f.
OTHERWISE
	GO m.tnRecToGo IN (m.tcAlias)
	RETURN ( RECNO(m.tcAlias)=m.tnRecToGo )
ENDCASE

****
*	Closes a table and returns the result
*
FUNCTION Close1
LPARAMETER tcAlias, tlUsed
IF VARTYPE(m.tcAlias) = "L"
	*	closes table in current work area
	IF USED()
		USE
	ENDIF
	RETURN !USED()
ENDIF
IF EMPTY(m.tcAlias)
	RETURN .t.
ENDIF
IF m.tlUsed
	RETURN .f.
ENDIF
IF USED(m.tcAlias)
    USE IN (m.tcAlias)
ENDIF
RETURN !USED(m.tcAlias)

***
*	Returns ON('ERROR')
*
FUNCTION OnError
RETURN ON('ERROR')

***
*	Returns SET('BLOCKSIZE')
*
FUNCTION SetBlock
RETURN SET('BLOCKSIZE')

***
*	Returns blank value, depending on the type of tValue
*
FUNCTION NullInit( tValue )
LOCAL lcType
lcType = VARTYPE(m.tValue)
DO CASE
CASE INLIST(m.lcType,'N','F','Y')
	RETURN 0
CASE INLIST(m.lcType,'D')
	RETURN Date00()
CASE INLIST(m.lcType,'T')
	RETURN DTOT(Date00())
CASE m.lcType=='L'
	RETURN .f.
CASE m.lcType=='O'
	RETURN .NULL.
ENDCASE
RETURN ''

***
*	Returns empty date
*
FUNCTION Date00
RETURN CTOD('')

***
*	Combination from ALLTRIM & STR
*
FUNCTION AS( tnNumber )
RETURN ALLTRIM( STR(m.tnNumber) )

***
*	Returns .t. if specified expression is character
*
FUNCTION IsChar
LPARAMETERS teToTest
RETURN VARTYPE(m.teToTest)="C" 

***
*	Returns .t. if the given alias is currently selected
*
FUNCTION CurAlias( tcAlias )
IF USED() AND !EMPTY(m.tcAlias) AND ALLTRIM(UPPER(m.tcAlias))==ALIAS()
	RETURN .t. 
ELSE
	RETURN .f.
ENDIF

***
*	Returns path and name with forced extention
*	PARAMETERS:
*	olnlyIfNot
*		.f. - allways puts extention
*		.t. - puts extention only if extention is absent in given name
*
FUNCTION Force_DBF
LPARAMETERS m.filname, m.olnlyIfNot
IF PCOUNT()<2
	m.olnlyIfNot = .f.
ENDIF
RETURN Force_EXT(m.filname, CDBF, m.olnlyIfNot)

***
*	Returns path and name with changed extension
*	PARAMETERS:
*	tlOnlyIfNot
*		.f. - puts extension even allready have
*		.t. - puts extension only if extension missing in tcFileName
*
FUNCTION Force_EXT
LPARAMETERS tcFileName, tcNewExt, tlOnlyIfNot
PRIVATE lcDot
lcDot = "."
IF m.tlOnlyIfNot AND m.lcDot$JustFname(m.tcFileName)
	RETURN m.tcFileName
ENDIF
tcFileName = stripExt(m.tcFileName)
tcNewExt = ALLTRIM(m.tcNewExt)
DO CASE
CASE EMPTY(m.tcNewExt)
	RETURN m.tcFileName
CASE LEFT(m.tcNewExt,1)==m.lcDot
	RETURN m.tcFileName + m.tcNewExt
ENDCASE
RETURN m.tcFileName + m.lcDot + m.tcNewExt

***
*	Removes extension from the file name
*
FUNCTION StripExt
LPARAMETER tcFilename
tcFilename = TRIM(m.tcFilename)
PRIVATE lnDotPos, lnTerminator
lnDotPos = RAT(".", m.tcFilename)
lnTerminator = MAX(RAT("\", m.tcFilename), RAT(":", m.tcFilename))
IF m.lnDotPos > m.lnTerminator
	tcFilename = LEFT(m.tcFilename, m.lnDotPos-1)
ENDIF
RETURN m.tcFilename

***
*	Returns Font attributes for given NUMERIC variable,
*	which is also suitable to be used as parameter in FONTMETRIC()
*
FUNCTION FontStyleN
LPARAMETERS tnFontStyle
DO CASE
CASE m.tnFontStyle=1
	RETURN 'B'
OTHERWISE
	RETURN 'N'
ENDCASE

***
*	Renames a given file with error handling (if target file is in other device - copy/delete)
*
FUNCTION RenFile
PARAMETERS tcFile1, tcFile2, m.useTTS_N
PRIVATE llUseWinApi
llUseWinApi = .t.	&& if need can be a parameter
IF FILE(m.tcFile1)
	*IF m.useTTS_N AND TTSATTRIB(m.tcFile)
	*	=TTSATTRIB(m.tcFile,.f.)
	*ENDIF
	IF FILE(m.tcFile2) AND !DelFile(m.tcFile2,m.useTTS_N)
		RETURN .f.
	ENDIF
	PRIVATE lnError
	lnError = 0
	IF UPPER(JustDrive(m.tcFile1)) <> UPPER(JustDrive(m.tcFile2))
		IF CopyFile( m.tcFile1, m.tcFile2 )
			=DelFile( m.tcFile1 )
		ENDIF
	ELSE
		IF m.llUseWinApi
			RETURN MoveFile( m.tcFile1, m.tcFile2 ) <> 0
		ELSE
			PRIVATE lcOldOnError
			lcOldOnError = OnError()
			ON ERROR lnError=ERROR()
			RENAME (m.tcFile1) TO (m.tcFile2)
			ON ERROR &lcOldOnError
			RETURN FILE(m.tcFile2) AND !FILE(m.tcFile1) AND m.lnError = 0
		ENDIF
	ENDIF
ENDIF
RETURN .f.

***
*	Deletes a given file with error handling
*	RETURs: .t. if file is deleted, otherwise .f.
*			in tnError returns the error number, if any
*			Possible error numbers:
*			File is in use by another.  (108)
*			File is in use.  (3)
*		tcBadMessage (out)
*	Remark: useTTSIN is dummy
*
FUNCTION DelFile
PARAMETERS tcFile, useTTSIN, tnError, tlMesNotDeleted, tcBadMessage
tnError = 0
PRIVATE llUseWinApi
llUseWinApi = .t.	&& if need can be a parameter
IF FILE(m.tcFile)
	IF m.llUseWinApi
		IF DeleteFile( m.tcFile ) = 0	&& Error deleting
			tnError = -108	&& File is in use by another, we put minus sign
		ENDIF
	ELSE
		*IF m.useTTSIN AND TTSATTRIB(m.tcFile)
		*	=TTSATTRIB(m.tcFile,.f.)
		*ENDIF
		PRIVATE lcOldOnERR
		lcOldOnERR = onError()
		ON ERROR tnError = ERROR()
		DELETE FILE (m.tcFile)
		ON ERROR &lcOldOnERR
		IF FILE(m.tcFile) AND m.tnError=0
			*	no error in command DELETE FILE, but file is not deleted
			*	(for example when file is used by another)
			tnError = -108
		ENDIF
	ENDIF
	IF FILE(m.tcFile)
		PRIVATE lcMessage
		lcMessage = "Problem deleting file:"+CHR(13)+CHR(13)+LOWER(m.tcFile)
		IF EMPTY(m.tcBadMessage)
			tcBadMessage = ""
		ENDIF
		tcBadMessage = m.tcBadMessage + CHRTRAN( m.lcMessage, CHR(13), SPACE(1) ) + CHR(13)
		IF m.tlMesNotDeleted
			=Worn_mesg( m.lcMessage )
		ENDIF
		RETURN .f.
	ENDIF
ENDIF
RETURN .t.

***
*	As Windows API function MoveFile
*	The MoveFile function renames an existing file or a directory (including all its children).
*	The MoveFile function will move (rename) either a file or a directory (including all its children)
*	either in the same directory or across directories. The one caveat is that the MoveFile function
*	will fail on directory moves when the destination is on a different volume.
*		If the function succeeds, the return value is nonzero.
*		If the function fails, the return value is zero
*
FUNCTION MoveFile
PARAMETERS tcExistingFileName, tcNewFileName
DECLARE INTEGER MoveFile IN Win32api AS MoveFile0 ;
	STRING @src, STRING @dest
RETURN MoveFile0( @m.tcExistingFileName, @m.tcNewFileName )

***
*	As Windows API function DeleteFile
*	The DeleteFile function deletes an existing file.
*		If the function succeeds, the return value is nonzero.
*		If the function fails, the return value is zero
*
FUNCTION DeleteFile
PARAMETERS tcFileName
DECLARE INTEGER DeleteFile IN Win32api AS DeleteFile0 ;
	STRING @
RETURN DeleteFile0( @m.tcFileName )

***
*	Copies given file, with error handling
*	RETURN: .t. if OK
*		tcBadMessage (out)
*	Remark: useTTSIN is dummy
*
FUNCTION CopyFile
PARAMETERS tcFile1, tcFile2, useTTSIN, tlMesProgrss, tlMesNotCopied, tcBadMessage
PRIVATE llOk, llUseWinApi
llOk = .f.
llUseWinApi = .t.	&& if need can be a parameter
IF FILE(m.tcFile1)
	IF !DelFile( m.tcFile2, m.useTTSIN, 0, m.tlMesNotCopied, @m.tcBadMessage )
		RETURN .f.
	ENDIF
	IF m.tlMesProgrss
		WAIT CLEAR
		WAIT WINDOW 'Копира файл '+LOWER(m.tcFile1)+' в '+LOWER(m.tcFile2) NOWAIT
	ENDIF
	IF m.llUseWinApi
		*	Copy with the help of Windows API
		llOk = CopyFileApi( m.tcFile1, m.tcFile2, 0 ) <> 0
	ELSE
		*	Fox style copy
		PRIVATE lnError, lcOldOnError
		lnError = 0
		lcOldOnError = OnError()
		ON ERROR lnError=ERROR()
		COPY FILE (m.tcFile1) TO (m.tcFile2)
		ON ERROR &lcOldOnError
		llOk = FILE(m.tcFile2) AND m.lnError = 0
	ENDIF
	IF m.tlMesProgrss
		WAIT CLEAR
	ENDIF
ELSE
	PRIVATE lcMessage
	lcMessage = "Can not copy file:"+CHR(13)+LOWER(m.tcFile1)+CHR(13)+CHR(13)+;
			"in file:"+CHR(13)+LOWER(m.tcFile2)
	IF EMPTY(m.tcBadMessage)
		tcBadMessage = ""
	ENDIF
	tcBadMessage = m.tcBadMessage + CHRTRAN( m.lcMessage, CHR(13), SPACE(1) ) + CHR(13)
	IF m.tlMesNotCopied
		=Worn_mesg( m.lcMessage )
	ENDIF
ENDIF
RETURN m.llOk

***
*	Function: Copies File. Faster than Fox Copy and handles errors internally.
*		tcSource -  Source File
*		tcTarget -  Target File
*		tnFlag   -  0* override, 1 don't
*    Return:
*		If the function succeeds, the return value is nonzero
*		If the function fails, the return value is zero. To get extended error information, call GetLastError
*
FUNCTION CopyFileApi
PARAMETERS lcSource, lcTarget, nFlag
DECLARE INTEGER CopyFile IN WIN32API AS CopyFile0 ;
   STRING @cSource, STRING @cTarget, INTEGER nFlag
RETURN CopyFile0( @m.lcSource, @m.lcTarget, m.nFlag )

***
*	Calls MessageBox for simple WORNING message (replaces old WornMess)
*
#DEFINE WARNING_LOC			"Warning"
FUNCTION Worn_mesg
LPARAMETERS tcMessage, tcTitle, nDialogBoxType
IF PCOUNT()<2 OR EMPTY(m.tcTitle)
	tcTitle = UPPER(WARNING_LOC)
ENDIF
IF PCOUNT()<3
	nDialogBoxType = MB_OK + MB_ICONEXCLAMATION
ENDIF
RETURN MessageBox( m.tcMessage, m.tcTitle, m.nDialogBoxType )

************************ END SECTION: Functions NEEDED RepExpFl to work

************************ START SECTION: Functions NEEDED RepExpFl to work
*	Additional functions NEEDED RepEnhance to work (they are called from inside RepEnhance).
*	These functions you can include in your project procedure file, or write your own
*	with same functionality.

***
*	Returns .t. if specified expression is object
*
FUNCTION IsObject
LPARAMETERS teToTest
*RETURN VARTYPE(m.teToTest)="O" 
RETURN VARTYPE(m.teToTest)="O" AND !ISNULL(m.teToTest)

***
*	Returns type C from the given value (any type)
*	lnTypeRet
*		0 - ordinary conversion
*		1 - other ("frendly")
*
FUNCTION AnyToC
LPARAMETERS inVar, tnTypeRet
IF PCOUNT()<2
	tnTypeRet = 0
ENDIF
LOCAL lcType
lcType = TYPE("m.inVar")
DO CASE
CASE INLIST(m.lcType,'C','M')
	RETURN m.inVar
CASE INLIST(m.lcType,'N','I','Y')
	RETURN ASspec(m.inVar)
CASE m.lcType='D'
	RETURN DTOC(m.inVar)
CASE m.lcType='T'
	RETURN TTOC(m.inVar)
CASE m.lcType='L'
	IF m.tnTypeRet=1
		RETURN IIF(m.inVar,CYES_LOC,CNO_LOC)
	ELSE
		RETURN IIF(m.inVar,".t.",".f.")
	ENDIF
CASE m.lcType='O'
	RETURN COBJECT_LOC
CASE m.lcType='G'
	RETURN CGENERAL_LOC
OTHERWISE
	RETURN m.inVar
ENDCASE
ENDFUNC

***
*	Returns STRING - whole number without decimal portion,
*	only if it is zero
*
FUNCTION ASspec
LPARAMETERS tnNumber, tnRound
IF PCOUNT()<2
	tnRound = 15
ENDIF
IF IsWhole(m.tnNumber)
	RETURN AS(m.tnNumber)
ELSE
	RETURN LTRIM(trim1(STR(m.tnNumber,25,m.tnRound),'0'))
ENDIF

***
*	Check if a numeric value is whole
*
FUNCTION IsWhole
PARAMETERS m.tnNumber
RETURN m.tnNumber=INT(m.tnNumber)

***
*	As TRIM, but removes also all simbols, listed in tcSimb,
*	from the end of the string. tcSimb can be longer from 1
*
FUNCTION Trim1
LPARAMETERS tcStr, tcSimb
IF PCOUNT()<2
	tcSimb = ","
ENDIF
LOCAL lnLen
tcSimb = m.tcSimb+SPACE(1)		&& also removes and spaces
tcStr = TRIM(m.tcStr)
lnLen = LEN(m.tcStr)
DO WHILE .t.
	IF m.lnLen<=0
		EXIT
	ENDIF
	IF ! SUBSTR(m.tcStr,m.lnLen,1) $ m.tcSimb
		EXIT
	ENDIF
	lnLen = m.lnLen - 1
ENDDO
IF m.lnLen>0
	RETURN PADR(m.tcStr,m.lnLen)
ELSE
	RETURN ""
ENDIF

************************ END SECTION: Functions NEEDED RepEnhance to work

************************ START SECTION: Functions needed only examples to work
*	Functions needed only examples to work. With them you can do what you like.

***
*	Calls MessageBox for simple informative message
*	(да замени yes_mesg.SCX, yes_Mesg.SPR )
*
#DEFINE INFORMATION_LOC		"information"
FUNCTION Info_mesg
LPARAMETERS tcMessage, tcTitle, nDialogBoxType
IF EMPTY(m.tcMessage)	
	tcMessage = ""
ENDIF
IF EMPTY(m.tcTitle)
	tcTitle = UPPER(INFORMATION_LOC)
ENDIF
IF PCOUNT()<3
	nDialogBoxType = MB_OK + MB_ICONINFORMATION
ENDIF
RETURN MessageBox( m.tcMessage, m.tcTitle, m.nDialogBoxType )

***
*	Similar function as in Windows DLL and addititions
*	Runs external exe or file
*	tcFileName  -  Name of the file to open (execute)
*	tcWorkDir   -  Working directory
*	tnShowWindow
*		SW_HIDE = 0
*		SW_SHOWNORMAL, SW_NORMAL = 1
*		SW_SHOWMINIMIZED = 2
*		SW_SHOWMAXIMIZED, SW_MAXIMIZE = 3
*		SW_SHOWNOACTIVATE = 4
*		SW_SHOW = 5
*		SW_MINIMIZE = 6
*		SW_SHOWMINNOACTIVE = 7
*		SW_SHOWNA = 8
*		SW_RESTORE = 9
*		SW_SHOWDEFAULT, SW_MAX = 10
*	tcOperation
*		"open"  The function opens the file specified by the lpFile parameter. The file can be an executable file or a document file. It can also be a folder. 
*		"print"  The function prints the file specified by lpFile. The file should be a document file. If the file is an executable file, the function opens the file, as if "open" had been specified. 
*		"explore"  The function explores the folder specified by lpFile.  
*		This parameter can be EMPTY. In that case, the function opens the file specified by lpFile. 
*	tnAction
*		0 - Normal
*		1 - Wait to start application and return handle to window
*		2 - Wait to terminate started application
*	RETURN:
*		0  - The operating system is out of memory or resources
*		2  - Bad Association
*		31 - No application association
*		29 - Failure to load application
*		30 - Application is busy 
*		Returns a value greater than 32 if successful,
*		or an error value that is less than or equal to 32 otherwise
*
FUNCTION ShellExe( tcFileName, tcParameters, tcWorkDir, tcOperation, tnShowWindow, ;
	tnAction, tnHandleStarted )
IF EMPTY(m.tnAction)
	tnAction = 0
ENDIF
IF EMPTY(m.tcParameters)
	tcParameters = ""
ENDIF
IF EMPTY(m.tcWorkDir)
	tcWorkDir = ""
ENDIF
IF EMPTY(m.tcOperation)
	tcOperation = "Open"
ENDIF
IF IsLog(m.tnShowWindow)
	tnShowWindow = 1
ENDIF
DECLARE INTEGER ShellExecute ;
	IN SHELL32.DLL ;
	INTEGER nWinHandle,;
	STRING cOperation,;   
	STRING cFileName,;
	STRING cParameters,;
	STRING cDirectory,;
	INTEGER nShowWindow
LOCAL lnReturn
tcFilename = PutQuotes( ALLTRIM(m.tcFilename), .f., .t. )
tcWorkDir = PutQuotes( ALLTRIM(m.tcWorkDir), .f., .t. )
IF m.tnAction>0
	LOCAL aWins0[1]
	=aWindows( @aWins0 )	&& Array with Windows before starting
ENDIF
lnReturn = ShellExecute( 0, m.tcOperation, m.tcFilename, m.tcParameters, m.tcWorkDir, m.tnShowWindow )
IF m.lnReturn>=32 AND m.tnAction>0
	*	wait for the new window to appear)
	LOCAL lnInitialActiveWindow, tnTimeStart, lcTitle, aWinsAfter[1]
	lnInitialActiveWindow = MainHwnd()	&& FoxTools.FLL
	tnTimeStart = SECONDS()
	lcTitle = "Starting "+m.tcFileName
	DO WHILE .t.
		=aWindows( @aWinsAfter )
		tnHandleStarted = GetNewWindow( @aWins0, @aWinsAfter )
		IF m.tnHandleStarted>0 AND m.lnInitialActiveWindow<>m.tnHandleStarted
			EXIT
		ENDIF
		IF EscapeProc()
			EXIT
		ENDIF
		IF SECONDS() - m.tnTimeStart > 30
			IF INLIST( YesNo( "After 30 s the application is not activated."+CHR(13)+"Wait more?", m.lcTitle, MB_DEFBUTTON1 ), IDOK, IDYES )
				WAIT CLEAR
				WAIT WINDOW m.lcTitle NOWAIT NOCLEAR
				tnTimeStart = SECONDS()
			ELSE
				EXIT
			ENDIF
		ENDIF
		*=INKEY( 0.05 )
	ENDDO
	IF m.tnAction=2 AND m.tnHandleStarted>0 AND m.lnInitialActiveWindow<>m.tnHandleStarted
		* Provided window handle is still valid then wait to terminate
		WAIT WINDOW 'Waiting to finish "' + ALLTRIM(GetWindowText(m.tnHandleStarted)) +'"' NOWAIT NOCLEAR
		DO WHILE IsWindow( m.tnHandleStarted ) = 1
			*=INKEY( 0.1 )
			=Sleep( 100 )	&& In Milliseconds
		ENDDO
	ENDIF
	WAIT CLEAR
ENDIF
RETURN m.lnReturn

***
*	Returns .t. if specified expression is logical
*
FUNCTION IsLog
LPARAMETERS teToTest
RETURN VARTYPE(m.teToTest)="L" 

***
*	Puts quotes on the given string
*
FUNCTION PutQuotes
LPARAMETERS m.tcString, tlCheck, tlOnlyIfSpaces
IF m.tlOnlyIfSpaces AND !SPACE(1)$m.tcString
	RETURN m.tcString
ENDIF
LOCAL lcQuote
lcQuote = '"'
IF m.tlCheck AND m.lcQuote $ m.tcString
	lcQuote = "'"
ENDIF
IF m.lcQuote <> PADR(m.tcString,1)
	RETURN m.lcQuote + m.tcString + m.lcQuote
ELSE
	RETURN m.tcString
ENDIF

******************
***   Author: (c) Rick Strahl, 1994, Modified by Nikolay Petkov 04.022002
*** Function: Creates an Array of top level wins
***           on the Windows DeskTop.
***   Assume: FOXTOOLS is loaded
***           Pass paWindows array by REFERENCE!
***     Uses: WinTitle()
***           WinNext()
***     Pass: paWindows -  an array that will be
***                        loaded with window names.
***                        The array will be 2D
***                        containing names and win
***                        handles.
***   Return: lnWinCount-  Number of Windows loaded
*
PROCEDURE aWindows
PARAMETERS paWindows
PRIVATE lhCurrWin, lnWinCount
*** Assign FoxPro Window (Desktop? NP)
lhCurrWin = GetWindow( MainHWND(), 0 )
lnWinCount = 0
DO WHILE lhCurrWin > 0
	*** Skip non-visible and child wins
	IF !EMPTY( GetWindowText(m.lhCurrWin) ) AND IsWindowVisible(m.lhCurrWin)<>0
		lnWinCount = lnWinCount + 1
		DIMENSION paWindows(m.lnWinCount,2)
		paWindows[m.lnWinCount,1] = GetWindowText(m.lhCurrWin)
		paWindows[m.lnWinCount,2] = m.lhCurrWin
	ENDIF
	*** Next Window in Chain
	lhCurrWin = GetWindow(m.lhCurrWin,2)
ENDDO
RETURN m.lnWinCount

***
*	Returns handle to reasantly started application (window), by Nikolay Petkov 04.02.2002
*	Usage:
*	LOCAL aWins0[1], aWinsAfter[1], lnHandleStarted
*	=aWindows( @aWins0 )	&& Array with Windows before starting
*	action...
*	=aWindows( @aWinsAfter )
*	lnHandleStarted = GetNewWindow( @aWins0, @aWinsAfter )
*
FUNCTION GetNewWindow( taWins0, taWinsAfter )
EXTERNAL ARRAY taWins0, taWinsAfter
LOCAL lnHandle, i, j, llFound
lnHandle = 0
FOR i=1 TO ALEN(taWinsAfter,1)	&& scan array "after"
	IF !EMPTY(taWinsAfter[m.i,2])
		llFound = .f.
		FOR j=1 TO ALEN(taWins0,1)	&& scan array "before"
			IF !EMPTY(taWins0[m.j,2])
				IF taWins0[m.j,2] = taWinsAfter[m.i,2]
					llFound = .t.
					EXIT
				ENDIF
			ENDIF
		ENDFOR
		IF !m.llFound
			lnHandle = taWinsAfter[m.i,2]
			EXIT
		ENDIF
	ENDIF
ENDFOR
RETURN m.lnHandle

***
*	Checks keyboard buffer for keyboard input.
*	If yes, ascs if to exit a procedure and return the ansuer: .t./.f.
*	m.chrList - list with keys to check (defaults to Escape)
*
#DEFINE PROCEDURE_LOC		"Procedure "
#DEFINE WILLCANSEL_LOC		"will be canceled"
#DEFINE CCONFIRM_LOC		"Do you confirm?"
FUNCTION EscapeProc
LPARAMETERS tcMessage, tcChrList
IF PCOUNT()<2
	tcChrList = CHR(27)
ENDIF
IF CHRSAW()
	LOCAL lnKeyNumber
	lnKeyNumber = INKEY()
	CLEAR TYPEAHEAD
	IF m.lnKeyNumber<1 OR CHR(m.lnKeyNumber)$m.tcChrList
		IF INLIST(MessageBox(PROCEDURE_LOC+IIF(EMPTY(m.tcMessage),"та",m.tcMessage)+CHR(13)+WILLCANSEL_LOC+CHR(13)+CCONFIRM_LOC,;
			MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2), IDOK, IDYES)
			RETURN .t.
		ENDIF
	ENDIF
ENDIF
RETURN .f.

***
*	Simple YES/NO dialog, using MessageBox().
*	PARAMETERS:
*	nDialogBoxType
*		MB_OK               0 - OK button only
*		MB_OKCANCEL         1 - OK and Cancel buttons
*		MB_ABORTRETRYIGNORE 2 - Abort, Retry, and Ignore buttons
*		MB_YESNOCANCEL      3 - Yes, No, and Cancel buttons
*		MB_YESNO            4 - Yes and No buttons
*		MB_RETRYCANCEL      5 - Retry and Cancel buttons
*	nDefaultButton
*		MB_DEFBUTTON1       0   - First button is default
*		MB_DEFBUTTON2       256 - Second button is default
*		MB_DEFBUTTON3       512 - Third button is default
*	nIcon
*		MB_ICONSTOP             16      && Critical message
*		MB_ICONQUESTION         32      && Warning query
*		MB_ICONEXCLAMATION      48      && Warning message
*		MB_ICONINFORMATION      64      && Information message
*	Other Constants (summ with nDialogBoxType)
*		MB_SYSTEMMODAL		4096 - System Modal
*		MB_TASKMODAL		8192 - Task Modal
*
*
*	RETURN:
*		IDOK        1 - OK button pressed
*		IDCANCEL    2 - Cancel button pressed
*		IDABORT     3 - Abort button pressed
*		IDRETRY     4 - Retry button pressed
*		IDIGNORE    5 - Ignore button pressed
*		IDYES       6 - Yes button pressed
*		IDNO        7 - No button pressed
*
FUNCTION YesNo
LPARAMETERS tcMessage, tcTitleBox, nDefaultButton, nDialogBoxType, nIcon
IF EMPTY(m.tcTitleBox)
	tcTitleBox = _SCREEN.Caption
ENDIF
IF PCOUNT()<3
	nDefaultButton = MB_DEFBUTTON1
ENDIF
IF PCOUNT()<4
	*nDialogBoxType = MB_YESNO
	nDialogBoxType = MB_YESNOCANCEL
ENDIF
IF PCOUNT()<5
	nIcon = MB_ICONQUESTION
ENDIF
IF EMPTY(m.tcMessage)
	tcMessage = 'Are you sure?'
ENDIF
*lnAnswer = MessageBox( m.tcMessage, m.nDialogBoxType+m.nDefaultButton+m.nIcon , m.tcTitleBox )
lnAnswer = 1
RETURN lnAnswer

FUNCTION GetWindowText( tnHandle )
DECLARE INTEGER GetWindowText IN WIN32API AS GetWindowText0 ;
	INTEGER hWnd, STRING @lpString, INTEGER nMaxCount
LOCAL lpTitle, lnResult, lnLen
lnLen = 512
lpTitle = REPL(CHR(0),m.lnLen)
lnResult = GetWindowText0( m.tnHandle, @m.lpTitle, m.lnLen-1 )
IF m.lnResult <> 0
	RETURN LEFT(m.lpTitle,AT(CHR(0),lpTitle)-1)
ELSE
	RETURN ""
ENDIF
*
FUNCTION IsWindow( tnHandle )
DECLARE INTEGER IsWindow IN user32.dll AS IsWindow0 ;
	INTEGER hWnd
RETURN IsWindow0( m.tnHandle )	&& Return 0/1
*
*	Usage: IsWindowVisible(m.tnHandle)<>0
FUNCTION IsWindowVisible( tnHandle )
DECLARE INTEGER IsWindowVisible IN user32.dll AS IsWindowVisible0 ;
	INTEGER hWnd
RETURN IsWindowVisible0( m.tnHandle )	&& Return 0/1
*
***     #define GW_HWNDFIRST        0 (Desktop)
***     #define GW_HWNDLAST         1
***     #define GW_HWNDNEXT         2 (default)
***     #define GW_HWNDPREV         3
FUNCTION GetWindow( tnHandleOriginal, tnRelationship )
DECLARE INTEGER GetWindow IN user32.dll AS GetWindow0 ;
	INTEGER hWnd, INTEGER uCmd
RETURN GetWindow0( m.tnHandleOriginal, m.tnRelationship )	&& Return 0/1

***
*	The Sleep function suspends the execution of the current thread for a specified interval
*	Specifies the time, in milliseconds, for which to suspend execution.
*	A value of zero causes the thread to relinquish the remainder of its time slice to any other
*	thread of equal priority that is ready to run. If there are no other threads of equal priority
*	ready to run, the function returns immediately, and the thread continues execution.
*	A value of INFINITE causes an infinite delay
*
FUNCTION Sleep
PARAMETERS tnMilliseconds
DECLARE Sleep IN WIN32API AS Sleep0  ;
	INTEGER
=Sleep0( m.tnMilliseconds )
RETURN .t.

************************ END SECTION: Functions needed only examples to work
