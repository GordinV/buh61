**
** del_pvoper_twin.fxp
**
 PARAMETER tnParentid, tnNomid, tdKpv
 LOCAL lnLausid, leRror
 leRror = .T.
 lnLausid = 0
 tnKuu = MONTH(tdKpv)
 tnAasta = YEAR(tdKpv)
 WITH odB
      .usE('del_pv_oper','qryKulum1')
      .opEntransaction()
      SELECT qrYkulum1
      SCAN
           lnLausid = qrYkulum1.joUrnalid
           SELECT qrYkulum1
           DELETE NEXT 1
           leRror = .cuRsorupdate('qryKulum1','v_pv_oper')
           IF VARTYPE(lnLausid)='N' .AND.  .NOT. EMPTY(lnLausid) .AND.  ;
              leRror=.T.
                = sp_delete_journal(lnLausid,1)
           ENDIF
           IF leRror=.F.
                IF coNfig.deBug=1
                     SET STEP ON
                ENDIF
                EXIT
           ENDIF
      ENDSCAN
      IF leRror=.T.
           .coMmit()
      ELSE
           .roLlback
      ENDIF
 ENDWITH
 RETURN leRror
ENDFUNC
*
