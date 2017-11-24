**
** calc_taabel1.fxp
**
 PARAMETER tnId, tnKuu, tnAasta
 LOCAL lnHours
 IF EMPTY(tnId) .AND. USED('v_taabel1')
      tnId = v_Taabel1.toOleping
 ENDIF
 IF EMPTY(tnKuu)
      IF EMPTY(gnKuu)
           DO FORM period
      ENDIF
      IF EMPTY(gnKuu)
           RETURN .F.
      ENDIF
      tnKuu = gnKuu
 ENDIF
 IF EMPTY(tnAasta) .AND. USED('v_taabel1')
      tnAasta = gnAasta
 ENDIF
 lnHours = 0
 lnReturn = 0
 lnHoliday = 0
 lnId = tnId
 WITH odB
      IF  .NOT. USED('qryTooleping')
           .usE('qryTooleping','qryTooleping')
      ELSE
           .dbReq('qryTooleping',gnHandle,'qryTooleping')
      ENDIF
      IF MONTH(qrYtooleping.alGab)=gnKuu .AND. YEAR(qrYtooleping.alGab)=gnAasta
           npAev = DAY(qrYtooleping.alGab)
      ELSE
           npAev = 1
      ENDIF
 ENDWITH
 lnPuhkus = chEck_puhkus()
 lnHaigus = chEck_haigus()
 lnWorkdays = woRkdays(npAev,gnKuu,gnAasta,31,tnId)
 lnHours = (lnWorkdays-(lnPuhkus+lnHaigus))*qrYtooleping.toOpaev
 IF USED('v_taabel1')
      REPLACE paEv WITH lnHours, koKku WITH lnHours, toO WITH lnHours IN  ;
              v_Taabel1
 ENDIF
 IF USED('qryTooleping')
      USE IN qrYtooleping
 ENDIF
 RETURN lnHours
ENDFUNC
*
FUNCTION check_puhkus
 LOCAL lnStartkpv, lnLoppkpv, lrEsult
 lrEsult = 0
 IF  .NOT. USED('qryPuhkused')
      tdKpv1_1 = GOMONTH(DATE(tnAasta, tnKuu, 1), -3)
      tdKpv1_2 = GOMONTH(DATE(tnAasta, tnKuu, 1), 3)
      tdKpv2_1 = tdKpv1_1
      tdKpv2_2 = tdKpv1_2
      tnPaevad1 = 0
      tnPaevad2 = 9999
      tcAmet = '%'
      tcIsik = '%'
      tcPohjus = 'PUHKUS%'
      tcLiik = '%'
      odB.usE('curPuudumine','qryPuhkused')
      IF USED('curPuudumine_')
           USE IN cuRpuudumine_
      ENDIF
 ENDIF
 SELECT qrYpuhkused
 SCAN FOR lePingid=tnId .AND. ((MONTH(kpV1)=tnKuu .AND. YEAR(kpV1)= ;
      tnAasta) .OR. (MONTH(kpV2)=tnKuu .AND. YEAR(kpV2)=tnAasta))
      IF MONTH(qrYpuhkused.kpV1)=tnKuu .AND. YEAR(qrYpuhkused.kpV1)=tnAasta
           lnStartkpv = DAY(qrYpuhkused.kpV1)
      ELSE
           lnStartkpv = 1
      ENDIF
      IF MONTH(qrYpuhkused.kpV2)=tnKuu .AND. YEAR(qrYpuhkused.kpV2)=tnAasta
           lnLoppkpv = DAY(qrYpuhkused.kpV2)
      ELSE
           lnLoppkpv = GOMONTH(DATE(tnAasta, tnKuu, 1), 1)-1
      ENDIF
      lrEsult = lrEsult+woRkdays(lnStartkpv,tnKuu,tnAasta,lnLoppkpv)
 ENDSCAN
 IF USED('qryPuhkused')
      USE IN qrYpuhkused
 ENDIF
 RETURN lrEsult
ENDFUNC
*
FUNCTION check_haigus
 LOCAL lnStartkpv, lnLoppkpv, lrEsult
 lrEsult = 0
 IF  .NOT. USED('qryPuhkused')
      tdKpv1_1 = GOMONTH(DATE(tnAasta, tnKuu, 1), -3)
      tdKpv1_2 = GOMONTH(DATE(tnAasta, tnKuu, 1), 3)
      tdKpv2_1 = tdKpv1_1
      tdKpv2_2 = tdKpv1_2
      tnPaevad1 = 0
      tnPaevad2 = 9999
      tcAmet = '%'
      tcIsik = '%'
      tcPohjus = 'HAIGUS%'
      tcLiik = '%'
      odB.usE('curPuudumine','qryPuhkused')
      IF USED('curPuudumine_')
           USE IN cuRpuudumine_
      ENDIF
 ENDIF
 SELECT qrYpuhkused
 SCAN FOR lePingid=tnId .AND. ((MONTH(kpV1)=tnKuu .AND. YEAR(kpV1)= ;
      tnAasta) .OR. (MONTH(kpV2)=tnKuu .AND. YEAR(kpV2)=tnAasta))
      IF MONTH(qrYpuhkused.kpV1)=tnKuu .AND. YEAR(qrYpuhkused.kpV1)=tnAasta
           lnStartkpv = DAY(qrYpuhkused.kpV1)
      ELSE
           lnStartkpv = 1
      ENDIF
      IF MONTH(qrYpuhkused.kpV2)=tnKuu .AND. YEAR(qrYpuhkused.kpV2)=tnAasta
           lnLoppkpv = DAY(qrYpuhkused.kpV2)
      ELSE
           lnLoppkpv = DAY(GOMONTH(DATE(tnAasta, tnKuu, 1), 1)-1)
      ENDIF
      lrEsult = lrEsult+woRkdays(lnStartkpv,tnKuu,tnAasta,lnLoppkpv)
 ENDSCAN
 IF USED('qryPuhkused')
      USE IN qrYpuhkused
 ENDIF
 RETURN lrEsult
ENDFUNC
*
