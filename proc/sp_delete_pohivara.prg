**
** sp_delete_pohivara.fxp
**
 PARAMETER tnId
 IF EMPTY(tnId)
      RETURN .F.
 ENDIF
 leRror = .T.
 WITH odB
      .usE('v_library','cursor1')
      .usE('v_pv_kaart','cursor2')
      tnLiik = 1
      .usE('v_pv_oper','cursor31')
      tnLiik = 2
      .usE('v_pv_oper','cursor32')
      tnLiik = 3
      .usE('v_pv_oper','cursor33')
      tnLiik = 4
      .usE('v_pv_oper','cursor34')
      tnLiik = 5
      .usE('v_pv_oper','cursor35')
      SELECT cuRsor1
      DELETE NEXT 1
      SELECT cuRsor2
      DELETE ALL
      SELECT cuRsor31
      DELETE ALL
      SELECT cuRsor32
      DELETE ALL
      SELECT cuRsor33
      DELETE ALL
      SELECT cuRsor34
      DELETE ALL
      SELECT cuRsor35
      DELETE ALL
      .opEntransaction()
      IF RECCOUNT('cursor1')>0
           leRror = .cuRsorupdate('cursor1','v_library')
      ENDIF
      IF leRror=.T. .AND. RECCOUNT('cursor2')>0
           leRror = .cuRsorupdate('cursor2','v_pv_kaart')
      ENDIF
      IF leRror=.T. .AND. RECCOUNT('cursor31')>0
           leRror = .cuRsorupdate('cursor31','v_pv_oper')
      ENDIF
      IF leRror=.T. .AND. RECCOUNT('cursor32')>0
           leRror = .cuRsorupdate('cursor32','v_pv_oper')
      ENDIF
      IF leRror=.T. .AND. RECCOUNT('cursor33')>0
           leRror = .cuRsorupdate('cursor33','v_pv_oper')
      ENDIF
      IF leRror=.T. .AND. RECCOUNT('cursor34')>0
           leRror = .cuRsorupdate('cursor34','v_pv_oper')
      ENDIF
      IF leRror=.T. .AND. RECCOUNT('cursor35')>0
           leRror = .cuRsorupdate('cursor35','v_pv_oper')
      ENDIF
      IF leRror=.F.
           .roLlback()
      ELSE
           .coMmit
      ENDIF
 ENDWITH
 IF USED('cursor1')
      USE IN cuRsor1
 ENDIF
 IF USED('cursor2')
      USE IN cuRsor2
 ENDIF
 IF USED('cursor32')
      USE IN cuRsor32
 ENDIF
 IF USED('cursor31')
      USE IN cuRsor31
 ENDIF
 IF USED('cursor33')
      USE IN cuRsor33
 ENDIF
 IF USED('cursor34')
      USE IN cuRsor34
 ENDIF
 IF USED('cursor35')
      USE IN cuRsor35
 ENDIF
 RETURN .T.
ENDFUNC
*
