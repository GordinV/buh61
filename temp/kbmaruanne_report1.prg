**
** kbmaruanne_report1.fxp
**
 PARAMETER cwHere
 IF ISDIGIT(ALLTRIM(cwHere))
      cwHere = VAL(ALLTRIM(cwHere))
 ENDIF
 LOCAL lnDeebet, lnKreedit
 tcAllikas = '%'
 tcArtikkel = '%'
 tcTegev = '%'
 tcObjekt = '%'
 tcEelallikas = '%'
ÿ------------------- ... rest ignored ...
*
FUNCTION f_kbm_arve
 tnLiik = 0
 odB.usE('qryKbm2')
 IF  .NOT. USED('qryKbm2')
      RETURN .F.
 ENDIF
 SELECT qrYkbm2
 SCAN
      DO CASE
           CASE qrYkbm2.kbM=5 .AND. qrYkbm2.suMma>0
                REPLACE reA01 WITH qrYkbm2.suMma IN kbMandmik_report1
ÿ------------------- ... rest ignored ...
*
FUNCTION f_kbm_lausend
 tnId = grEkv
 WITH odB
      .usE('v_kbm','curLib')
      .usE('v_rekv')
      .usE('curJournal','cursor1',.T.)
 ENDWITH
 caAdress = ''
 FOR i = 1 TO MEMLINES(v_Rekv.aaDress)
      caAdress = RTRIM(caAdress)+SPACE(1)+RTRIM(MLINE(v_Rekv.aaDress, 1))
 ENDFOR
ÿ------------------- ... rest ignored ...
*
