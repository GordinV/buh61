**
** checkuuendused.fxp
**
 PARAMETER urLname
 IF coNfig.uuEnda=0
      RETURN .F.
 ENDIF
 IF FILE('ajalugu.dbf')
      USE ajalugu IN 0
      GOTO BOTTOM
      IF ajAlugu.kpV=DATE()
           RETURN .F.
      ENDIF
 ENDIF
 DECLARE INTEGER InternetOpen IN wininet.DLL STRING, INTEGER, STRING,  ;
         STRING, INTEGER
 DECLARE INTEGER InternetOpenUrl IN wininet.DLL INTEGER, STRING, STRING,  ;
         INTEGER, INTEGER, INTEGER
 DECLARE INTEGER InternetReadFile IN wininet.DLL INTEGER, STRING @,  ;
         INTEGER, INTEGER @
 DECLARE SHORT InternetCloseHandle IN wininet.DLL INTEGER
 saGent = "VFP 6.0"
 hiNternetsession = inTernetopen(saGent,0,'','',0)
 IF hiNternetsession=0
      RETURN .F.
 ENDIF
 huRlfile = inTernetopenurl(hiNternetsession,urLname,'',0,2147483648,0)
 IF huRlfile=0
      RETURN .F.
 ENDIF
 lcFile = SYS(5)+SYS(2003)+'\'+JUSTFNAME(urLname)
 gnErrfile = FCREATE(lcFile)
 IF gnErrfile<0
      RETURN .F.
 ENDIF
 lnKokku = 0
 ltStart = DATETIME()
 DO WHILE .T.
      srEadbuffer = SPACE(32117)
      lbYtesread = 0
      M.ok = inTernetreadfile(huRlfile,@srEadbuffer,LEN(srEadbuffer), ;
             @lbYtesread)
      lnKokku = lbYtesread+lnKokku
      IF lbYtesread>0
           = FWRITE(gnErrfile, LEFT(srEadbuffer, lbYtesread))
      ENDIF
      IF M.ok=0 .OR. lbYtesread=0
           EXIT
      ENDIF
 ENDDO
 = FCLOSE(gnErrfile)
 = inTernetclosehandle(huRlfile)
 = inTernetclosehandle(hiNternetsession)
 IF  .NOT. FILE(lcFile)
      RETURN .F.
 ENDIF
 USE (lcFile) IN 0
 IF  .NOT. USED('uuendus')
      RETURN .F.
 ENDIF
 IF  .NOT. USED('ajalugu')
      RETURN .T.
 ENDIF
 SELECT kpV FROM uuendus ORDER BY kpV DESC TOP 1 INTO CURSOR qryUuendus
 SELECT veRsia FROM ajalugu ORDER BY veRsia DESC TOP 1 INTO CURSOR qryAjalugu
 IF qrYuuendus.kpV>qrYajalugu.veRsia
      RETURN .T.
 ELSE
      RETURN .F.
 ENDIF
ENDFUNC
*
PROCEDURE uuenda_updater
 lcFileuus = SYS(5)+SYS(2003)+'\tmp\updater.exe'
 lcFilevana = SYS(5)+SYS(2003)+'\updater.exe'
 IF FILE(lcFile)
      COPY FILE (lcFileuus) TO (lcFilevana)
      ERASE (lcFileuus)
 ENDIF
 RETURN
ENDPROC
*
