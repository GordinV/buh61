 LPARAMETER cfIle, csTartpath
 LOCAL nwHnd, nrEsult, cmSg
 DECLARE INTEGER ShellExecute IN SHELL32 INTEGER, STRING, STRING, STRING,  ;
         STRING, INTEGER
 DECLARE INTEGER GetDesktopWindow IN User32
 nwHnd = geTdesktopwindow()
 nrEsult = shEllexecute(nwHnd,'Open',cfIle,'',csTartpath,1)
 cmSg = ''
 IF nrEsult>1
      DO CASE
           CASE nrEsult=2
                cmSg = 'File not found'
           CASE nrEsult=3
                cmSg = 'Path not found'
           CASE nrEsult=5
                cmSg = 'Access denied'
           CASE nrEsult=8
                cmSg = 'Not enough memory to run'
           CASE nrEsult=050
                cmSg = 'DLL missing'
           CASE nrEsult=038
                cmSg = 'Sharing violation'
           CASE nrEsult=039
                cmSg = 'Invalid file'
           CASE nrEsult=040
                cmSg = 'DDE Timeout'
           CASE nrEsult=041
                cmSg = 'DDE Fail'
           CASE nrEsult=048
                cmSg = 'DDE Busy'
           CASE nrEsult=049
                cmSg = 'No application is associated with this file'
           CASE nrEsult=017
                cmSg = 'Invalid EXE format'
           OTHERWISE
                cmSg = ''
      ENDCASE
      IF  .NOT. EMPTY(cmSg)
           MESSAGEBOX(cmSg, 'Kontrol')
      ENDIF
 ENDIF
 RETURN cmSg
ENDFUNC
*
