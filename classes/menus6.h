*//--------------------------------------------
*//	Title   : Constant definition file
*// Article : Object Oriented Menu Wrapper classes for VFP 6.0
*//	Author  : Colin Nicholls
*// Email   : colin@spacefold.com
*//
*//	Revision History
*//	----------------
*//	16.Jan.1998	CMN		Revised for VFP5/Fuchs article
*//	20.May.1998	CMN		Added Top form support at John Davy's request
*//	07.Sep.1998	CMN		Revised for VFP6/dFPug98
*//--------------------------------------------

*#define l_DEBUG 
#define n_WAITTIME 0.8

#define c_MENUCLASSLIB	menus6.vcx	


*//-----------------------
*// Helper constants:

#define c_CR            chr(13)
#define c_SINGLEQUOTE 	chr(39)
#define c_DOUBLEQUOTE	chr(34)
#define method procedure
#define TRUE  	.T.
#define FALSE 	.F.
#define YES		.T.
#define NO		.F.

*//-----------------------
*// Variable types:

#define c_OBJECT	'O'
#define c_CHARACTER	'C'
#define c_DATE		'D'
#define c_DATETIME	'T'
#define c_NUMERIC	'N'

*//-----------------------
*// Menubar Style:

#define n_MNU_NORMAL	0
#define n_MNU_REPLACE	1
#define n_MNU_INWINDOW	2
#define n_MNU_APPEND	3
#define n_MNU_INTOPFORM 4

*//------------------------
*// Values of OBJTYPE field in MNX table:

#define n_GLOBAL	1		&&  Menu File default
#define n_CONTAINER	2		&&	Menu Bar or Popup
#define n_CONTROL	3		&&	Option

*//------------------------
*//	Values of OBJCODE field in MNX table:

#define n_MENUPAD		 0
#define n_MENUBAR		 1
#define n_DEFAULT		22
#define n_COMMAND		67
#define n_SUBMENU		77
#define n_BARNUMBER		78
#define n_PROCEDURE     80

*//------------------------
*//		Menu / pad location

#define n_REPLACE		0
#define n_APPEND		1
#define n_BEFORE		2
#define n_AFTER			3

*//------------------------
*//	Characters that are removed from 
*// prompts when constructing object names:

#define c_BAD_CHARACTERS	' .,!@#$%&*()[]{}+=\/<>;:-'

*//------------------------
*// MessageBox() flags:

#DEFINE MB_OK                   0       && OK button only
#DEFINE MB_OKCANCEL             1       && OK and Cancel buttons
#DEFINE MB_ABORTRETRYIGNORE     2       && Abort, Retry, and Ignore buttons
#DEFINE MB_YESNOCANCEL          3       && Yes, No, and Cancel buttons
#DEFINE MB_YESNO                4       && Yes and No buttons
#DEFINE MB_RETRYCANCEL          5       && Retry and Cancel buttons

#DEFINE MB_ICONSTOP             16      && Critical message
#DEFINE MB_ICONQUESTION         32      && Warning query
#DEFINE MB_ICONEXCLAMATION      48      && Warning message
#DEFINE MB_ICONINFORMATION      64      && Information message

#DEFINE MB_APPLMODAL            0       && Application modal message box
#DEFINE MB_DEFBUTTON1           0       && First button is default
#DEFINE MB_DEFBUTTON2           256     && Second button is default
#DEFINE MB_DEFBUTTON3           512     && Third button is default
#DEFINE MB_SYSTEMMODAL          4096    && System Modal

*-- MsgBox return values
#DEFINE IDOK            1       && OK button pressed
#DEFINE IDCANCEL        2       && Cancel button pressed
#DEFINE IDABORT         3       && Abort button pressed
#DEFINE IDRETRY         4       && Retry button pressed
#DEFINE IDIGNORE        5       && Ignore button pressed
#DEFINE IDYES           6       && Yes button pressed
#DEFINE IDNO            7       && No button pressed

*//--------------------------
*// Localisation strings:

#define LOC_ERROR_MESSAGE	 "An error has occurred somewhere in the menu object hierarchy."
#define LOC_ERROR_LINE       "Error "+alltr(str(nError))+" in "+cMethod+"() at line "+alltr(str(nLine))
#define LOC_ERROR_TITLE      "A very bad thing has happened"
#define LOC_ERROR_LOADSTRUC1 "wait window '.LoadMenuStructure: specified MNX file not found.'"
#define LOC_ERROR_LOADSTRUC2 ".LoadMenuStructure(): Menu structure possibly corrupt! No header record found." 