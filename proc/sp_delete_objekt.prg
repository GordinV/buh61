**
** sp_delete_objekt.fxp
**
 PARAMETER tnId
 IF EMPTY(tnId)
      RETURN .F.
 ENDIF
 IF VARTYPE(odB)<>'O'
      SET CLASSLIB TO classes\classlib
      odB = CREATEOBJECT('db')
 ENDIF
 WITH odB
      .usE('qryCheckPalkLib')
      IF RECCOUNT('qryCheckPalkLib')>0
           = MESSAGEBOX(IIF(coNfig.keEl=2, 'Ei saa kustuta kiri',  ;
             'Удаление записи не разрешено'), 'Kontrol')
           RETURN .F.
      ENDIF
      .opEntransaction()
      .usE('v_library','cursor1')
      .usE('v_palk_lib','cursor2')
      SELECT cuRsor1
      DELETE NEXT 1
      SELECT cuRsor2
      DELETE ALL
      leRror = .cuRsorupdate('cursor1','v_library')
      IF leRror=.T.
           leRror = .cuRsorupdate('cursor2','v_palk_lib')
      ENDIF
      IF leRror=.T.
           .coMmit()
      ELSE
           .roLlback()
           = MESSAGEBOX(IIF(coNfig.keEl=2, 'Viga: ei saa kustuta kiri',  ;
             'Ошибка при удаление записи'), 'Kontrol')
      ENDIF
 ENDWITH
 USE IN cuRsor1
 USE IN cuRsor2
 RETURN .T.
ENDFUNC
*
