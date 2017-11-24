**
** sp_delete_nomenklatuur.fxp
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
      leRror = .usE('CHKNOMID')
      IF RECCOUNT('CHKNOMID')>0
           USE IN chKnomid
           MESSAGEBOX(IIF(coNfig.keEl=2, 'Ei saa kustuta kiri',  ;
                     'Удаление записи не разрешено'), 'kontrol')
           RETURN .F.
      ENDIF
      IF USED('CHKNOMID')
           USE IN chKnomid
      ENDIF
      .usE('v_nomenklatuur','cursor1')
      SELECT cuRsor1
      DELETE NEXT 1
      .cuRsorupdate('cursor1','v_nomenklatuur')
 ENDWITH
 USE IN cuRsor1
 RETURN .T.
ENDFUNC
*
