 lnAnswer = MESSAGEBOX(IIF(coNfig.keEl=2, 'Kas teha koopia? ',  ;
            'Сделать резервную копию?'), 0036, "Kontrol")
 IF lnAnswer=6
      leRror = sp_backup()
 ENDIF
 DO CASE
      CASE gvErsia='VFP'
           lnError = ADBOBJECTS(atBl, 'TABLE')
           IF lnError<1
                RETURN .F.
           ENDIF
           SET DELETED off
           FOR i = 1 TO ALEN(atBl, 1)
                lcTable = atBl(i)
                WAIT WINDOW NOWAIT 'kontrolin :'+lcTable
                IF USED(lcTable)
                     USE IN (lcTable)
                ENDIF
                USE EXCLUSIVE (lcTable) ALIAS tbLkorrasta IN 0
                IF USED('tblKorrasta')
                     SELECT tbLkorrasta
                     REINDEX
                     PACK
                     IF lcTable<>'DBASE' .AND. lcTable<>'CURKUUD'
                          GOTO BOTTOM
                          lnId = tbLkorrasta.id
                          IF  .NOT. USED('dbase')
                               USE dbase IN 0
                          ENDIF
                          SELECT dbAse
                          SET ORDER TO alias
                          SEEK ALLTRIM(UPPER(lcTable))
                          IF FOUND()
                               REPLACE laStnum WITH lnId IN dbAse
                          ENDIF
                          USE IN dbAse
                     ENDIF
                     USE IN tbLkorrasta
                ELSE
                     cmEssage = 'Ei saa korrastada '+lcTable
                     MESSAGEBOX(cmEssage, 'Kontrol')
                ENDIF
           ENDFOR
			SET DELETED ON
           WAIT WINDOW NOWAIT ''
      CASE gvErsia='MSSQL'
           lcString = 'sp_updatestats '
           leRror = SQLEXEC(gnHandle, lcString)
 ENDCASE
ENDFUNC
*
