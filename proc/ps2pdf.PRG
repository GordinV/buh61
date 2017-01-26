*:******************************************************************************
*:
*: Procedure File PS2PDF.PRG
*:
*: Documented using Visual FoxPro Formatting wizard version  .05
*:******************************************************************************
*:   PS2PDF
*:   clnpsfiles
*:   runme
*:   long2str
*:   str2long
*:   getStartupInfo
*:   num2dword
*:   num2word
*:   buf2dword
*:   Decl
Parameters m_ifilename   && checking this has to be a ps file.
If m_ifilename =="" Or Not File(m_ifilename)
        Return
Endif
Do clnpsfiles
m_safety  = Set("safety")
Set Safety Off
If Not Directory("psfiles")
        Mkdir psfiles
Endif
If Not Directory("pdffiles")
        Mkdir pdffiles
Endif
m_psfile= "psfiles\"+Juststem(m_ifilename)+".ps"
If File(m_psfile)
        Erase (m_psfile)
Endif
If Justext(m_ifilename) == ""
        m_ifilename = Juststem(m_ifilename)+".TXT"
        m_psfile=Juststem(m_ifilename)+".ps"
        If File(m_psfile)
                Erase (m_psfile)
        Endif
        Rename (m_ifilename) To "psfiles\"+Juststem(m_ifilename)+".ps"
        m_ifilename = "psfiles\"+Juststem(m_ifilename)+".ps"
Endif
If Justext(m_ifilename)="TXT"
        Rename (m_ifilename) To "psfiles\"+Juststem(m_ifilename)+".ps"
        m_ifilename = "psfiles\"+Juststem(m_ifilename)+".ps"
Endif
If Justext(m_ifilename)="ps" Or Justext(m_ifilename)="PS"
        Rename (m_ifilename) To "psfiles\"+Juststem(m_ifilename)+".ps"
        m_ifilename = "psfiles\"+Juststem(m_ifilename)+".ps"
Endif
gs = Filetostr("LocationOfgs.ini")
m_outfile = "pdffiles\"+Juststem(m_ifilename) +".pdf"
m_cmd = [ -q -dSAFER -dNOPAUSE -dBATCH -sDEVICE#pdfwrite -sOutputFile#]+m_outfile +[ -dnodisplay -dCompatibilityLevel#1.2 -c .setpdfwrite -f ] +m_ifilename
m_cmd = (gs)+ m_cmd +Chr(0)
** this is the actual ps2pdf command sent to ghostscript
Do runme With m_cmd
Set Safety &m_safety

*!******************************************************************************
*!
*! Procedure CLNPSFILES
*!
*!  Calls
*!      clnpsfiles
*!      runme
*!
*!******************************************************************************
Procedure clnpsfiles
        ** proceedure for clearing out the last ps file to be converted.
        ** general housekeeping
        m_num = Adir(m_files,"psfiles\*.ps")
        If m_num  > 0
                m_dir = "psfiles\"
                For i=1 To m_num
                        m_filetoerase =(m_dir)+m_files[i,1]
                        Erase (m_filetoerase)
                Next i
        Endif
Endproc



*!******************************************************************************
*!
*! Procedure RUNME
*!
*!  Calls
*!      clnpsfiles
*!      runme
*!
*!******************************************************************************
Proc runme
        Para m_cmd
        #Define NORMAL_PRIORITY_CLASS 32
        #Define IDLE_PRIORITY_CLASS 64
        #Define HIGH_PRIORITY_CLASS 128
        #Define REALTIME_PRIORITY_CLASS 1600

        * Return code from WaitForSingleObject() if
        * it timed out.
        #Define WAIT_TIMEOUT 0x00000102

        * This controls how long, in milli secconds, WaitForSingleObject()
        * waits before it times out. Change this to suit your preferences.
        #Define WAIT_INTERVAL 200

        Declare Integer CreateProcess In kernel32.Dll ;
                INTEGER lpApplicationName, ;
                STRING lpCommandLine, ;
                INTEGER lpProcessAttributes, ;
                INTEGER lpThreadAttributes, ;
                INTEGER bInheritHandles, ;
                INTEGER dwCreationFlags, ;
                INTEGER lpEnvironment, ;
                INTEGER lpCurrentDirectory, ;
                STRING @lpStartupInfo, ;
                STRING @lpProcessInformation

        Declare Integer WaitForSingleObject In kernel32.Dll ;
                INTEGER hHandle, Integer dwMilliseconds

        Declare Integer CloseHandle In kernel32.Dll ;
                INTEGER hObject

        Declare Integer GetLastError In kernel32.Dll

        * STARTUPINFO is 68 bytes, of which we need to
        * initially populate the 'cb' or Count of Bytes member
        * with the overall length of the structure.
        * The remainder should be 0-filled
        Start = long2str(68) + Replicate(Chr(0), 64)

        * PROCESS_INFORMATION structure is 4 longs,
        * or 4*4 bytes = 16 bytes, which we'll fill with nulls.
        process_info = Replicate(Chr(0), 16)
        * Start a copy of gs (EXE name must be null-terminated)
        File2Run = m_cmd     

        * Call CreateProcess, obtain a process handle. Treat the
        * application to run as the 'command line' argument, accept
        * all other defaults. Important to pass the start and
        * process_info by reference.
        lcStartupInfo = getStartupInfo()
        ** the older startup
        * I didn't want ghostscript to show, so I changed the startup
        * of create process to run without a visual element. 
        * to have GS start visually, change @lcStartupInfo, below to be @start
        RetCode = CreateProcess(0, File2Run, 0, 0, 1, ;
                NORMAL_PRIORITY_CLASS , 0, 0, @lcStartupInfo, @process_info)

        * Unable to run, exit now.
        If RetCode = 0
                =Messagebox("Error occurred. Error code: ", GetLastError())
                Return
        Endif

        * Extract the process handle from the
        * PROCESS_INFORMATION structure.
        hProcess = str2long(Substr(process_info, 1, 4))

        Do While .T.
                * Use timeout of TIMEOUT_INTERVAL msec so the display
                * will be updated. Otherwise, the VFP window never repaints until
                * the loop is exited.
                If WaitForSingleObject(hProcess, WAIT_INTERVAL) != WAIT_TIMEOUT
                        Exit
                Else
                        DoEvents
                Endif
        Enddo

        * Show a message box when we're done.
        *This was removed to enable it run without user intervention. 
        * ie. a web web server 
        *      =MESSAGEBOX ("Process completed")
        * Close the process handle afterwards.
        RetCode = CloseHandle(hProcess)
        Return


        ********************
*!******************************************************************************
*!
*! Procedure LONG2STR
*!
*!  Calls
*!      clnpsfiles
*!      runme
*!
*!******************************************************************************
Function long2str
        ********************
        * Passed : 32-bit non-negative numeric value (m.longval)
        * Returns : ASCII character representation of passed
        *           value in low-high format (m.retstr)
        * Example :
        *    m.long = 999999
        *    m.longstr = long2str(m.long)

        Parameters m.longval

        Private i, m.retstr

        m.retstr = ""
        For i = 24 To 0 Step -8
                m.retstr = Chr(Int(m.longval/(2^i))) + m.retstr
                m.longval = Mod(m.longval, (2^i))
        Next
        Return m.retstr


        *******************
*!******************************************************************************
*!
*! Procedure STR2LONG
*!
*!  Calls
*!      clnpsfiles
*!      runme
*!
*!******************************************************************************
Function str2long
        *******************
        * Passed:  4-byte character string (m.longstr)
        *   in low-high ASCII format
        * returns:  long integer value
        * example:
        *   m.longstr = "1111"
        *   m.longval = str2long(m.longstr)

        Parameters m.longstr

        Private i, m.retval

        m.retval = 0
        For i = 0 To 24 Step 8
                m.retval = m.retval + (Asc(m.longstr) * (2^i))
                m.longstr = Right(m.longstr, Len(m.longstr) - 1)
        Next
        Return m.retval

Endpro


*!******************************************************************************
*!
*! Procedure GETSTARTUPINFO
*!
*!  Calls
*!      clnpsfiles
*!      runme
*!
*!******************************************************************************
Procedure  getStartupInfo
        * creates the STARTUP structure to specify main window
        * properties if a new window is created for a new process

        *| typedef struct _STARTUPINFO {
        *|     DWORD   cb;                4
        *|     LPTSTR  lpReserved;        4
        *|     LPTSTR  lpDesktop;         4
        *|     LPTSTR  lpTitle;           4
        *|     DWORD   dwX;               4
        *|     DWORD   dwY;               4
        *|     DWORD   dwXSize;           4
        *|     DWORD   dwYSize;           4
        *|     DWORD   dwXCountChars;     4
        *|     DWORD   dwYCountChars;     4
        *|     DWORD   dwFillAttribute;   4
        *|     DWORD   dwFlags;           4
        *|     WORD    wShowWindow;       4
        *|     WORD    cbReserved2;       2
        *|     LPBYTE  lpReserved2;       4
        *|     HANDLE  hStdInput;         4
        *|     HANDLE  hStdOutput;        4
        *|     HANDLE  hStdError;         4
        *| } STARTUPINFO, *LPSTARTUPINFO; total: 68 bytes

        #Define STARTF_USESHOWWINDOW   1
        #Define SW_SHOWMAXIMIZED       2

        Return  num2dword(68) +;
                num2dword(0) + num2dword(0) + num2dword(0) +;
                num2dword(0) + num2dword(0) + num2dword(0) + num2dword(0) +;
                num2dword(0) + num2dword(0) + num2dword(0) +;
                num2dword(STARTF_USESHOWWINDOW) +;
                num2word(SW_SHOWMAXIMIZED) +;
                num2word(0) + num2dword(0) +;
                num2dword(0) + num2dword(0) + num2dword(0)

*!******************************************************************************
*!
*! Procedure NUM2DWORD
*!
*!  Calls
*!      clnpsfiles
*!      runme
*!
*!******************************************************************************
Function  num2dword (lnValue)
        #Define m0       256
        #Define m1     65536
        #Define m2  16777216
        Local b0, b1, b2, b3
        b3 = Int(lnValue/m2)
        b2 = Int((lnValue - b3 * m2)/m1)
        b1 = Int((lnValue - b3*m2 - b2*m1)/m0)
        b0 = Mod(lnValue, m0)
        Return Chr(b0)+Chr(b1)+Chr(b2)+Chr(b3)

*!******************************************************************************
*!
*! Procedure NUM2WORD
*!
*!  Calls
*!      clnpsfiles
*!      runme
*!
*!******************************************************************************
Function  num2word (lnValue)
        Return Chr(Mod(m.lnValue,256)) + Chr(Int(m.lnValue/256))

*!******************************************************************************
*!
*! Procedure BUF2DWORD
*!
*!  Calls
*!      clnpsfiles
*!      runme
*!
*!******************************************************************************
Function  buf2dword (lcBuffer)
        Return Asc(Substr(lcBuffer, 1,1)) + ;
                Asc(Substr(lcBuffer, 2,1)) * 256 +;
                Asc(Substr(lcBuffer, 3,1)) * 65536 +;
                Asc(Substr(lcBuffer, 4,1)) * 16777216

*!******************************************************************************
*!
*! Procedure DECL
*!
*!  Calls
*!      clnpsfiles
*!      runme
*!
*!******************************************************************************
Procedure  Decl
        Declare Integer GetLastError In kernel32

        Declare Integer CreateProcess In kernel32;
                STRING lpApplicationName, String lpCommandLine,;
                INTEGER lpProcessAttributes,;
                INTEGER lpThreadAttributes,;
                INTEGER bInheritHandles, Integer dwCreationFlags,;
                INTEGER @ lpEnvironment, String lpCurrentDirectory,;
                STRING lpStartupInfo, String @ lpProcessInformation

        Declare Integer GetModuleHandle In kernel32 Integer lpModuleName
        Declare Integer GetCurrentProcessId In kernel32
        Declare Integer GetCurrentThreadId In kernel32
        Declare Integer GetCurrentProcess In kernel32
        Declare Integer GetCurrentThread In kernel32

        Declare Integer TerminateProcess In kernel32;
                INTEGER hProcess, Integer uExitCode
endpro