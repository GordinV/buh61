 PARAMETER tnSumma
 IF EMPTY(tnSumma) .OR.  .NOT. USED('v_arv')
      RETURN .F.
 ENDIF
 IF  .NOT. USED('v_arvjournal1')
      RETURN .F.
 ENDIF
 IF  .NOT. USED('v_dokprop') .OR. v_Dokprop.kbMumard=0 .OR.  ;
     v_Dokprop.suMmaumard=0
      RETURN .F.
 ENDIF
 lnKbmta = tnSumma/1.18
 lnKbm = tnSumma-lnKbmta
 lnKbmumard = v_Arv.kbM-lnKbm
 lnSummaumard = v_Arv.kbMta-lnKbmta
 INSERT INTO v_arvjournal1 (laUsendid, deEbet, krEedit, niMetus, suMma)  ;
        VALUES (v_Dokprop.kbMumard, coMlausendremote.deEbet,  ;
        coMlausendremote.krEedit, coMlausendremote.niMetus, lnKbmumard)
 INSERT INTO v_arvjournal1 (laUsendid, deEbet, krEedit, niMetus, suMma)  ;
        VALUES (v_Dokprop.suMmaumard, coMlausendremote.deEbet,  ;
        coMlausendremote.krEedit, coMlausendremote.niMetus, lnSummaumard)
ENDFUNC
*
