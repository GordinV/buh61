 PARAMETER tnSumma, tcOpt, tnRound
 LOCAL lnSumma, lnDiffer, lnRound, lcLastdigit
 lnSumma = 0
 lnRound = 0
 tnSumma = ROUND(tnSumma, 2)
 IF EMPTY(tnRound)
      tnRound = 0.10
 ENDIF
 IF EMPTY(tcOpt)
      tcOpt = '-'
 ENDIF
 IF  .NOT. EMPTY(tnSumma)
      DO CASE
           CASE tnRound=0.01
                lnSumma = tnSumma
           CASE tnRound=0.05
                IF ROUND(tnSumma, 1)>tnSumma .AND. ROUND(tnSumma, 1)<>tnSumma
                     lnDiffer = ROUND(tnSumma, 1)-ROUND(tnSumma, 2)
                     lcLastdigit = RIGHT(ALLTRIM(STR(lnDiffer, 4, 2)), 1)
                     DO CASE
                          CASE VAL(lcLastdigit)>2
                               lnSumma = tnSumma-(5-VAL(lcLastdigit))*0.01
                          CASE VAL(lcLastdigit)<=2
                               lnSumma = tnSumma+VAL(lcLastdigit)*0.01
                     ENDCASE
                ENDIF
                IF ROUND(tnSumma, 1)<tnSumma .AND. ROUND(tnSumma, 1)<>tnSumma
                     lnDiffer = ROUND(tnSumma, 1)-ROUND(tnSumma, 2)
                     lcLastdigit = RIGHT(ALLTRIM(STR(lnDiffer, 4, 2)), 1)
                     IF lcLastdigit='5'
                          lnSumma = tnSumma
                     ELSE
                          DO CASE
                               CASE VAL(lcLastdigit)<3
                                    lnSumma = tnSumma-VAL(lcLastdigit)*0.01
                               CASE VAL(lcLastdigit)>=3
                                    lnSumma = tnSumma+(5-VAL(lcLastdigit))*0.01
                          ENDCASE
                     ENDIF
                ENDIF
                IF ROUND(tnSumma, 1)=tnSumma
                     lnSumma = tnSumma
                ENDIF
           CASE tnRound=0.10
                lnSumma = ROUND(tnSumma, 1)
           OTHERWISE
                lnSumma = ROUND(tnSumma, 0)
      ENDCASE
      IF tcOpt='+'
           IF  .NOT. USED('sentid')
                CREATE CURSOR sentid (isIkid INT, suMma Y)
           ENDIF
           SELECT seNtid
           LOCATE FOR seNtid.isIkid=v_Palk_kaart.paRentid
           IF FOUND()
                REPLACE seNtid.suMma WITH seNtid.suMma+(tnSumma-lnSumma)
           ELSE
                INSERT INTO sentid (isIkid, suMma) VALUES  ;
                       (v_Palk_kaart.paRentid, (tnSumma-lnSumma))
           ENDIF
      ENDIF
 ENDIF
 RETURN lnSumma
ENDFUNC
*
