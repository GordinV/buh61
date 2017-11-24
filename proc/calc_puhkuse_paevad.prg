**
** calc_puhkuse_paevad.fxp
**
 PARAMETER tnId, tdKpv1, tnTunnus, tnTyyp
 LOCAL lnPaevad, lnSunniaasta
 lnPaevad = 0
 IF tnTunnus=1
      odB.usE('qryTooleping','tmpleping')
      SELECT coMasutusremote
      LOCATE FOR coMasutusremote.id=tmPleping.paRentid
      IF  .NOT. FOUND() .OR. RECCOUNT('tmpleping')=0
           RETURN 0
      ENDIF
      lnSunniaasta = VAL('19'+SUBSTR(coMasutusremote.reGkood, 2, 2))
      lnSunnikuu = VAL(SUBSTR(coMasutusremote.reGkood, 4, 2))
      lnSunnipaev = VAL(SUBSTR(coMasutusremote.reGkood, 6, 2))
      IF (lnSunnikuu>0 .AND. lnSunnikuu<=12) .AND. (lnSunnipaev>0 .AND.  ;
         lnSunnipaev<31) .AND. (lnSunniaasta>YEAR(DATE())-85 .AND.  ;
         lnSunniaasta<YEAR(DATE())-10)
           lnAasta = (DATE()-DATE(lnSunniaasta, lnSunnikuu, lnSunnipaev))/365
      ELSE
           lnAasta = 18
      ENDIF
      DO CASE
           CASE tmPleping.amEtnik=1 .AND. tnTyyp=1
                lnPaevad = 35-puHkus_used()
           CASE tmPleping.amEtnik=0 .AND. lnAasta>=18 .AND. tnTyyp=1
                lnPaevad = 28-puHkus_used()
           CASE tmPleping.amEtnik=0 .AND. lnAasta<18 .AND. tnTyyp=1
                lnPaevad = 35-puHkus_used()
           CASE tnTyyp=3
                lnPaevad = 3-puHkus_used()
      ENDCASE
      IF (DATE()-TTOD(tmPleping.alGab))<365 .AND. tnTyyp=1
           lnKuu1 = MONTH(TTOD(tmPleping.alGab))
           lnKuu2 = MONTH(DATE())
           IF lnKuu1>lnKuu2
                lnKuu2 = lnKuu2+12
           ENDIF
           lnKuud = lnKuu2-lnKuu1
           lnPaevad = CEILING(lnPaevad/12*lnKuud)
      ENDIF
      IF USED('tmpleping')
           USE IN tmPleping
      ENDIF
      lnPaevad = IIF(lnPaevad<0, 0, lnPaevad)
 ENDIF
 RETURN lnPaevad
ENDFUNC
*
FUNCTION puhkus_used
 LOCAL lnPaevad
 lnPaevad = 0
 tnLeping1 = tnId
 tnLeping2 = tnId
 ldKpv = tdKpv1
 tdKpv1 = DATE(YEAR(ldKpv), 1, 1)
 tdKpv2 = ldKpv
 odB.usE('qryPuudumine','tmpPuhkus')
 SELECT tmPpuhkus
 LOCATE FOR tuNnus=tnTunnus .AND. tyYp=tnTyyp
 IF FOUND()
      lnPaevad = tmPpuhkus.paEvad
 ENDIF
 USE IN tmPpuhkus
 RETURN lnPaevad
ENDFUNC
*
