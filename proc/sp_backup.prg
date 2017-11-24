**
** sp_backup.fxp
**
 PARAMETER tcDbc, tcFail
 LOCAL leRror, lcData, lcString, lcZipfail
 IF EMPTY(tcFail)
      lcZipfail = ALLTRIM(STR(grEkv))+RIGHT(DTOC(DATE(), 1), 6)+'.zip'
      tcFail = SYS(5)+SYS(2003)+'\backup\'+lcZipfail
 ELSE
      lcZipfail = JUSTFNAME(tcDbc)
 ENDIF
 DO CASE
      CASE gvErsia='VFP'
           IF EMPTY(tcDbc)
                tcDbc = JUSTPATH(SYS(2014, DBC()))
           ENDIF
           lcData = DBC()
           IF  .NOT. FILE('7za.exe')
                RETURN .F.
           ENDIF
           CLOSE DATABASES
           lcString = '! 7za a -tzip "'+lcZipfail+'"'+SPACE(1)+'"'+tcDbc+'\*"'
           &lcString
           OPEN DATABASE (lcData)
           lcZipfail = SYS(5)+SYS(2003)+'\'+lcZipfail
           IF FILE(lcZipfail)
                IF lcZipfail<>tcFail
                     RENAME (lcZipfail) TO (tcFail)
                ENDIF
                leRror = .T.
           ENDIF
      CASE gvErsia='MSSQL'
           lcString = "sp_helpdevice 'backupdb'"
           leRror = SQLEXEC(gnHandle, lcString)
           IF leRror<1
                lcString = " sp_addumpdevice 'disk','backupdb','"+ ;
                           JUSTPATH(tcFail)+'\'+ALLTRIM(STR(grEkv))+ ;
                           "buhdata5.bak'"
                leRror = SQLEXEC(gnHandle, lcString)
           ENDIF
           IF leRror>0
                lcString = 'backup database buhdata5 to backupdb'
                leRror = SQLEXEC(gnHandle, lcString)
           ENDIF
           IF leRror<1
                RETURN .F.
           ENDIF
 ENDCASE
 RETURN leRror
ENDFUNC
*
