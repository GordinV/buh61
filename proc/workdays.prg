 PARAMETER lnPaev, tnKuu, tnAasta, tnLopppaev, tnLepingid
 LOCAL lnMaxdays, lnHoliday, ldDate, lnReturn
 IF EMPTY(lnPaev)
      lnPaev = 1
 ENDIF
 IF EMPTY(tnLopppaev)
      tnLopppaev = 31
 ENDIF
 lnHoliday = 0
 IF EMPTY(tnKuu)
      tnKuu = gnKuu
 ENDIF
 IF EMPTY(tnAasta)
      tnAasta = gnAasta
 ENDIF
 lnReturn = 0
 WITH odB
      IF  .NOT. EMPTY(tnLepingid)
           .usE('qryToograf')
           IF RECCOUNT('qryToograf')>0 .AND.  .NOT. EMPTY(qrYtoograf.tuNd)
                IF  .NOT. USED('qryTooleping')
                     .usE('qryTooleping')
                ELSE
                     IF qrYtooleping.id<>tnLepingid
                          .dbReq('qryTooleping',gnHandle)
                     ENDIF
                ENDIF
                IF qrYtooleping.toOpaev>0
                     lnReturn = qrYtoograf.tuNd/qrYtooleping.toOpaev
                     RETURN lnReturn
                ENDIF
           ENDIF
           USE IN qrYtoograf
      ENDIF
      ldDate = DATE(tnAasta, tnKuu, lnPaev)
      lnMaxdays = DAY(GOMONTH(DATE(tnAasta, tnKuu, 1), 1)-1)
      IF lnMaxdays>tnLopppaev
           lnMaxdays = tnLopppaev
      ENDIF
      IF  .NOT. USED('qryHoliday')
           .usE('curHoliday','qryHoliday')
      ENDIF
      IF  .NOT. EMPTY(lnMaxdays)
           FOR i = lnPaev TO lnMaxdays
                IF DOW(ldDate, 2)=6 .OR. DOW(ldDate, 2)=7
                     lnHoliday = lnHoliday+1
                ELSE
                     SELECT qrYholiday
                     LOCATE FOR paEv=DAY(ldDate) .AND. kuU=MONTH(ldDate)
                     IF FOUND()
                          lnHoliday = lnHoliday+1
                     ENDIF
                ENDIF
                ldDate = ldDate+1
           ENDFOR
           lnReturn = lnMaxdays-lnHoliday-lnPaev+1
      ENDIF
 ENDWITH
 RETURN lnReturn
ENDFUNC
*
