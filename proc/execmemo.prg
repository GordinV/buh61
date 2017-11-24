 PARAMETER tcMemo, tcFilename
 IF EMPTY(tcMemo)
      RETURN .F.
 ENDIF
 IF EMPTY(tcFilename)
      tcFilename = SYS(2015)
 ENDIF
 COPY MEMO (tcMemo) TO tcFilename
 IF  .NOT. FILE(tcFilename)
      RETURN .F.
 ENDIF
 COMPILE (tcFilename)
 DO (tcFilename)
ENDFUNC
*
