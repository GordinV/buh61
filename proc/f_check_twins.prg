**
** f_check_twins.fxp
**
 LOCAL leRror
 IF  .NOT. USED('v_palk_kaart')
      RETURN leRror
 ENDIF
 leRror = .T.
 tnLibid = v_Palk_kaart.liBid
 tnLepingid = v_Palk_kaart.lePingid
 tdKpv1 = DATE(gnAasta, gnKuu, 1)
 tdKpv2 = GOMONTH(tdKpv1, 1)-1
 odB.usE('delete_twins')
 SELECT deLete_twins
 SCAN
      = sp_delete_palkoper(deLete_twins.id)
 ENDSCAN
 USE IN deLete_twins
 RETURN leRror
ENDFUNC
*
