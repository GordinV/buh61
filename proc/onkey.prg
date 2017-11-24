 PARAMETER tcKey
 DO CASE
      CASE tcKey='CTRL+A'
           IF otOols.btNadd.enAbled=.T. .AND. VARTYPE(gcWindow)='O' .AND.   ;
              .NOT. ISNULL(gcWindow) .AND. otOols.btNadd.viSible=.T.
                gcWindow.adD()
           ENDIF
      CASE tcKey='CTRL+S'
           IF otOols.btNsave.enAbled=.T. .AND. VARTYPE(gcWindow)='O'  ;
              .AND.  .NOT. ISNULL(gcWindow) .AND. otOols.btNsave.viSible=.T.
                gcWindow.saVe('OK')
           ENDIF
      CASE tcKey='CTRL+P'
           IF otOols.btNprint.enAbled=.T. .AND. VARTYPE(gcWindow)='O'  ;
              .AND.  .NOT. ISNULL(gcWindow) .AND. otOols.btNprint.viSible=.T.
                gcWindow.prInt()
           ENDIF
 ENDCASE
ENDPROC
*
