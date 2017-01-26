 PARAMETER diG,tcValuuta, tcCent
 LOCAL msUmma, m_Summa1, m_Summa2, m_Summa3, lcMark
 IF diG<0
      diG = diG*-1
      lcMark = 'Miinus '
 ELSE
      lcMark = ''
 ENDIF
 tcValuuta = IIF(ISNULL(tcValuuta),'EEK',tcValuuta)
 IF EMPTY(tcCent)
	 tcCent = 'centi'
 ENDIF
 
 cuR = tcValuuta
 msUmma = ' '
 m_Summa2 = ' '
 m_Summa3 = ' '
 fsT = 0
 snD = 0
 thRd = 0
 frS = 0
 fvS = 0
 thIrd = ' '
 foUrs = ' '
 fiVes = ' '
 siXs = ' '
 sxS = 0
 seVen = ' '
 svN = 0
 eiGht = ' '
 egT = 0
 msD = 0
 m_Summa1 = ' '
 diGit = ' '
 fiRst = ' '
 seCond = ' '
 zeRro = ' '
 mz = 0
 mzErro = ' '
 msZerro = ' '
 meZerro = ' '
 meZ = 0
 msZ = 0
 IF diG=0
      msUmma = 'null'
 ELSE
      DIMENSION ed(20)
      DIMENSION dd(10)
      DIMENSION sd(4)
      ed(1) = IIF(config.keel = 2,'üks','uks')
      ed(2) = 'kaks'
      ed(3) = 'kolm'
      ed(4) = 'neli'
      ed(5) = 'viis'
      ed(6) = 'kuus'
      ed(7) = 'seitse'
      ed(8) = 'kaheksa'
      ed(9) = IIF(config.keel = 2,'üheksa','uheksa')
      ed(10) = IIF(config.keel = 2,'kümme','kumme')
      ed(11) = IIF(config.keel = 2,'üksteist','uksteist')
      ed(12) = 'kaksteist'
      ed(13) = 'kolmteist'
      ed(14) = 'neliteist'
      ed(15) = 'viisteist'
      ed(16) = 'kuusteist'
      ed(17) = 'seitseteist'
      ed(18) = 'kaheksateist'
      ed(19) = IIF(config.keel = 2,'üheksateist','uheksateist')
      ed(20) = ''
      dd(2) = IIF(config.keel = 2,'kakskümmend','kakskummend')
      dd(3) = IIF(config.keel = 2,'kolmkümmend','kolmkummend')
      dd(4) = IIF(config.keel = 2,'nelikümmend','nelikummend')
      dd(5) = IIF(config.keel = 2,'viiskümmend','viiskummend')
      dd(6) = IIF(config.keel = 2,'kuuskümmend','kuuskummend')
      dd(7) = IIF(config.keel = 2,'seitsekümmend','seitsekummend')
      dd(8) = IIF(config.keel = 2,'kaheksakümmend','kaheksakummend')
      dd(9) = IIF(config.keel = 2,'uheksakümmend','uheksakummend')
      sd(1) = 'sada'
      sd(2) = 'tuhat'
      sd(3) = 'miljon'
      sd(4) = ''
      DO CASE
           CASE diG<20
                fiRst = ALLTRIM(STR(diG, 5, 2))
                fsT = VAL(fiRst)
                msUmma = ed(fsT)
           CASE diG>=20 .AND. diG<100
                diGit = ALLTRIM(STR(diG, 5, 2))
                fiRst = LEFT(diGit, 1)
                seCond = SUBSTR(diGit, 2, 1)
                fsT = VAL(fiRst)
                snD = VAL(seCond)
                IF snD=0
                     msUmma = dd(fsT)
                ELSE
                     msUmma = dd(fsT)+' '+ed(snD)
                ENDIF
           CASE diG>=100 .AND. diG<1000
                diGit = STR(diG, 6, 2)
                fiRst = LEFT(diGit, 1)
                seCond = SUBSTR(diGit, 2, 1)
                thIrd = SUBSTR(diGit, 3, 1)
                fsT = VAL(fiRst)
                snD = VAL(seCond)
                thRd = VAL(thIrd)
                DO CASE
                     CASE snD=0 .AND. thRd<>0
                          msUmma = ed(fsT)+sd(1)+' '+ed(thRd)
                     CASE snD=0 .AND. thRd=0
                          msUmma = ed(fsT)+sd(1)
                     CASE thRd=0 .AND. snD>1
                          msUmma = ed(fsT)+sd(1)+' '+dd(snD)
                     CASE snD=1 .AND. thRd=0
                          msUmma = ed(fsT)+sd(1)+' '+ed(10)
                     CASE snD=1 .AND. thRd>0
                          foUrs = '1'+thIrd
                          frS = VAL(foUrs)
                          msUmma = ed(fsT)+sd(1)+' '+ed(frS)
                     OTHERWISE
                          msUmma = ed(fsT)+sd(1)+' '+dd(snD)+' '+ed(thRd)
                ENDCASE
           CASE diG>=1000 .AND. diG<20000
                diGit = STR(diG, 8, 2)
                diGital = LEFT(diGit, 5)
                seVen = SUBSTR(diGital, 4, 2)
                svN = VAL(seVen)
                DO CASE
                     CASE svN>=0 .AND. svN<20
                          fiRst = LEFT(diGital, 2)
                          seCond = SUBSTR(diGital, 3, 1)
                          thIrd = SUBSTR(diGital, 4, 2)
                          fsT = VAL(fiRst)
                          snD = VAL(seCond)
                          thRd = VAL(thIrd)
                          msD = 1
                          msT = 2
                          IF thRd=0
                               thRd = 20
                          ENDIF
                          IF snD=0
                               snD = 20
                               msD = 4
                          ENDIF
                          IF thRd=0
                               thRd = 20
                          ENDIF
                          msUmma = ed(fsT)+' '+sd(msT)+' '+ed(snD)+ ;
                                   sd(msD)+' '+ed(thRd)
                     CASE svN>=20
                          fiRst = LEFT(diGital, 2)
                          seCond = SUBSTR(diGital, 3, 1)
                          thIrd = SUBSTR(diGital, 4, 1)
                          foUrs = SUBSTR(diGital, 5, 1)
                          fsT = VAL(fiRst)
                          snD = VAL(seCond)
                          thRd = VAL(thIrd)
                          frS = VAL(foUrs)
                          msD = 1
                          msT = 2
                          IF thRd=0
                               thRd = 20
                          ENDIF
                          IF frS=0
                               frS = 20
                          ENDIF
                          IF snD=0
                               snD = 20
                               msD = 4
                          ENDIF
                          msUmma = ed(fsT)+' '+sd(msT)+' '+ed(snD)+ ;
                                   sd(msD)+' '+dd(thRd)+' '+ed(frS)
                ENDCASE
           CASE diG>=20000 .AND. diG<100000
                diGit = STR(diG, 8, 2)
                fiRst = LEFT(diGit, 1)
                seCond = SUBSTR(diGit, 2, 1)
                thIrd = SUBSTR(diGit, 3, 1)
                foUrs = SUBSTR(diGit, 4, 1)
                siXs = SUBSTR(diGit, 5, 1)
                fsT = VAL(fiRst)
                snD = VAL(seCond)
                thRd = VAL(thIrd)
                frS = VAL(foUrs)
                sxS = VAL(siXs)
                DO CASE
                     CASE snD=0 .AND. thRd>0 .AND. frS>1 .AND. sxS>0
                          msUmma = dd(fsT)+' '+sd(2)+' '+ed(thRd)+sd(1)+ ;
                                   ' '+dd(frS)+' '+ed(sxS)
                     CASE snD=0 .AND. thRd>0 .AND. frS=0 .AND. sxS=0
                          msUmma = dd(fsT)+' '+sd(2)+' '+ed(thRd)+sd(1)
                     CASE snD=0 .AND. thRd>0 .AND. frS=0 .AND. sxS>0
                          msUmma = dd(fsT)+' '+sd(2)+' '+ed(thRd)+sd(1)+ ;
                                   ' '+ed(sxS)
                     CASE snD=0 .AND. thRd=0 .AND. frS>1 .AND. sxS>0
                          msUmma = dd(fsT)+' '+sd(2)+' '+dd(frS)+' '+ed(sxS)
                     CASE snD=0 .AND. thRd=0 .AND. frS=0 .AND. sxS>0
                          msUmma = dd(fsT)+' '+sd(2)+' '+ed(sxS)
                     CASE snD=0 .AND. thRd=0 .AND. frS=0 .AND. sxS=0
                          msUmma = dd(fsT)+' '+sd(2)
                     CASE snD>0 .AND. thRd>0 .AND. frS>1 .AND. sxS=0
                          msUmma = dd(fsT)+' '+ed(snD)+' '+sd(2)+' '+ ;
                                   ed(thRd)+sd(1)+' '+dd(frS)
                     CASE snD>0 .AND. thRd>0 .AND. frS=0 .AND. sxS>0
                          msUmma = dd(fsT)+' '+ed(snD)+' '+sd(2)+' '+ ;
                                   ed(thRd)+sd(1)+' '+ed(sxS)
                     CASE snD>0 .AND. thRd=0 .AND. frS>1 .AND. sxS>0
                          msUmma = dd(fsT)+' '+ed(snD)+' '+sd(2)+' '+ ;
                                   dd(frS)+' '+ed(sxS)
                     CASE snD>0 .AND. thRd=0 .AND. frS>0 .AND. sxS>0
                          neD = VAL(STR(frS, 1)+STR(sxS, 1))
                          msUmma = dd(fsT)+SPACE(1)+ed(snD)+SPACE(1)+ ;
                                   sd(2)+SPACE(1)+ed(neD)
                     CASE snD>0 .AND. thRd=0 .AND. frS>1 .AND. sxS=0
                          msUmma = dd(fsT)+' '+ed(snD)+' '+sd(2)+' '+ ;
                                   sd(1)+' '+dd(frS)
                     CASE snD>0 .AND. thRd>0 .AND. frS=0 .AND. sxS=0
                          msUmma = dd(fsT)+' '+ed(snD)+' '+sd(2)+' '+ ;
                                   ed(thRd)+sd(1)
                     CASE snD>0 .AND. thRd=0 .AND. frS=0 .AND. sxS=0
                          msUmma = dd(fsT)+' '+ed(snD)+' '+sd(2)
                     CASE snD<>0 .AND. thRd>0 .AND. frS=1 .AND. sxS=0
                          msUmma = dd(fsT)+' '+ed(snD)+' '+sd(2)+' '+ ;
                                   ed(thRd)+sd(1)+' '+ed(10)
                     CASE snD=0 .AND. thRd>0 .AND. frS=1 .AND. sxS=0
                          msUmma = dd(fsT)+' '+sd(2)+' '+ed(thRd)+sd(1)+ ;
                                   ' '+ed(10)
                     CASE snD<>0 .AND. thRd>0 .AND. frS=1 .AND. sxS>0
                          fiVes = '1'+siXs
                          fvS = VAL(fiVes)
                          msUmma = dd(fsT)+' '+ed(snD)+' '+sd(2)+' '+ ;
                                   ed(thRd)+sd(1)+' '+ed(fvS)
                     CASE snD=0 .AND. thRd>0 .AND. frS=1 .AND. sxS>0
                          fiVes = '1'+siXs
                          fvS = VAL(fiVes)
                          msUmma = dd(fsT)+' '+sd(2)+' '+ed(thRd)+sd(1)+ ;
                                   ' '+ed(fvS)
                     CASE snD<>0 .AND. thRd=0 .AND. frS=1 .AND. sxS=0
                          msUmma = dd(fsT)+' '+ed(snD)+' '+sd(2)+' '+ed(10)
                     CASE snD<>0 .AND. thRd=0 .AND. frS=1 .AND. sxS>0
                          fiVes = '1'+siXs
                          fvS = VAL(fiVes)
                          msUmma = dd(fsT)+' '+ed(snD)+' '+sd(2)+' '+ed(fvS)
                     CASE snD=0 .AND. thRd=0 .AND. frS=1 .AND. sxS=0
                          msUmma = dd(fsT)+' '+sd(2)+' '+ed(10)
                     CASE snD=0 .AND. thRd=0 .AND. frS=1 .AND. sxS>0
                          fiVes = '1'+siXs
                          fvS = VAL(fiVes)
                          msUmma = dd(fsT)+' '+sd(2)+' '+ed(fvS)
                     CASE snD=0 .AND. thRd>0 .AND. frS>1 .AND. sxS=0
                          fiVes = '1'+siXs
                          fvS = VAL(fiVes)
*                          msUmma = dd(fsT)+' '+sd(2)+' '+ed(fvS)
                           msUmma = dd(fsT)+' '+sd(2)+' '+ ;
                                   ed(thRd)+sd(1)+' '+dd(frS)+' '
                    OTHERWISE
*                     SET STEP ON 
                          msUmma = dd(fsT)+' '+ed(snD)+' '+sd(2)+' '+ ;
                                   ed(thRd)+sd(1)+' '+dd(frS)+' '+ed(sxS)
                ENDCASE
           CASE diG>=100000 .AND. diG<1000000
                diGit = STR(diG, 8, 2)
                seVen = SUBSTR(diGit, 5, 2)
                svN = VAL(seVen)
                siXs = SUBSTR(diGit, 2, 2)
                sxS = VAL(siXs)
                DO CASE
                     CASE svN>=0 .AND. svN<20 .AND. sxS>=20
                          fiRst = LEFT(diGit, 1)
                          seCond = SUBSTR(diGit, 2, 1)
                          thIrd = SUBSTR(diGit, 3, 1)
                          foUrs = SUBSTR(diGit, 4, 1)
                          fsT = VAL(fiRst)
                          snD = VAL(seCond)
                          thRd = VAL(thIrd)
                          frS = VAL(foUrs)
                          fvS = VAL(fiVes)
                          egT = VAL(eiGht)
                          msD = 1
                          msT = 2
                          IF thRd=0
                               thRd = 20
                          ENDIF
                          IF frS=0
                               frS = 20
                               msD = 4
                          ENDIF
                          IF svN=0
                               svN = 20
                          ENDIF
                          IF fsT=0 .AND. snD=0 .AND. thRd=0
                               msT = 4
                          ENDIF
                          msUmma = ed(fsT)+sd(1)+' '+dd(snD)+' '+ed(thRd)+ ;
                                   ' '+sd(msT)+' '+ed(frS)+sd(msD)+' '+ed(svN)
                     CASE svN>=0 .AND. svN<20 .AND. sxS>=0 .AND. sxS<=20
                          fiRst = LEFT(diGit, 1)
                          seCond = SUBSTR(diGit, 2, 2)
                          foUrs = SUBSTR(diGit, 4, 1)
                          fsT = VAL(fiRst)
                          snD = VAL(seCond)
                          thRd = VAL(thIrd)
                          frS = VAL(foUrs)
                          fvS = VAL(fiVes)
                          egT = VAL(eiGht)
                          msD = 1
                          msT = 2
                          IF snD=0
                               snD = 20
                          ENDIF
                          IF frS=0
                               frS = 20
                               msD = 4
                          ENDIF
                          IF svN=0
                               svN = 20
                          ENDIF
                          IF fsT=0 .AND. snD=0
                               msT = 4
                          ENDIF
                          msUmma = ed(fsT)+sd(1)+' '+ed(snD)+' '+sd(msT)+ ;
                                   ' '+ed(frS)+sd(msD)+' '+ed(svN)
                     CASE svN>=20 .AND. sxS>=20
                          fiRst = LEFT(diGit, 1)
                          seCond = SUBSTR(diGit, 2, 1)
                          thIrd = SUBSTR(diGit, 3, 1)
                          foUrs = SUBSTR(diGit, 4, 1)
                          fiVes = SUBSTR(diGit, 5, 1)
                          eiGht = SUBSTR(diGit, 6, 1)
                          fsT = VAL(fiRst)
                          snD = VAL(seCond)
                          thRd = VAL(thIrd)
                          frS = VAL(foUrs)
                          fvS = VAL(fiVes)
                          egT = VAL(eiGht)
                          msD = 1
                          IF thRd=0
                               thRd = 20
                          ENDIF
                          IF frS=0
                               frS = 20
                               msD = 4
                          ENDIF
                          IF egT=0
                               egT = 20
                          ENDIF
                          msUmma = ed(fsT)+sd(1)+' '+dd(snD)+' '+ed(thRd)+ ;
                                   ' '+sd(2)+' '+ed(frS)+sd(msD)+' '+ ;
                                   dd(fvS)+' '+ed(egT)
                     CASE svN>=20 .AND. sxS>=0 .AND. sxS<20
                          fiRst = LEFT(diGit, 1)
                          seCond = SUBSTR(diGit, 2, 2)
                          foUrs = SUBSTR(diGit, 4, 1)
                          fiVes = SUBSTR(diGit, 5, 1)
                          eiGht = SUBSTR(diGit, 6, 1)
                          fsT = VAL(fiRst)
                          snD = VAL(seCond)
                          thRd = VAL(thIrd)
                          frS = VAL(foUrs)
                          fvS = VAL(fiVes)
                          egT = VAL(eiGht)
                          IF snD=0
                               snD = 20
                          ENDIF
                          IF frS=0
                               frS = 20
                               msD = 4
                          ENDIF
                          IF egT=0
                               egT = 20
                          ENDIF
                          msUmma = ed(fsT)+sd(1)+' '+ed(snD)+' '+sd(2)+ ;
                                   ' '+ed(frS)+sd(msD)+' '+dd(fvS)+' '+ed(egT)
                ENDCASE
           CASE diG>=1000000 .AND. diG<100000000
                diGit = STR(diG, 10, 2)
                zeRro = LEFT(diGit, 8)
                mzErro = LEFT(zeRro, 2)
                msZerro = SUBSTR(zeRro, 4, 2)
                msZ = VAL(msZerro)
                meZerro = SUBSTR(zeRro, 7, 2)
                meZ = VAL(meZerro)
                mz = VAL(mzErro)
                msD = 1
                DO CASE
                     CASE mz>0 .AND. mz<20
                          fiRst = LEFT(zeRro, 2)
                          fsT = VAL(fiRst)
                          m_Summa1 = ed(fsT)+' '+sd(3)
                     CASE mz>20
                          fiRst = LEFT(zeRro, 1)
                          fsT = VAL(fiRst)
                          seCond = SUBSTR(zeRro, 2, 1)
                          snD = VAL(seCond)
                          m_Summa1 = dd(fsT)+ed(snD)+' '+sd(3)
                ENDCASE
                DO CASE
                     CASE msZ>=0 .AND. msZ<20 .AND. meZ>=0 .AND. meZ<20
                          thIrd = SUBSTR(zeRro, 3, 1)
                          foUrs = SUBSTR(zeRro, 4, 2)
                          fiVes = SUBSTR(zeRro, 6, 1)
                          siXs = SUBSTR(zeRro, 7, 2)
                          thRd = VAL(thIrd)
                          frS = VAL(foUrs)
                          fvS = VAL(fiVes)
                          sxS = VAL(siXs)
                          svN = VAL(seVen)
                          egT = VAL(eiGht)
                          msD = 1
                          msT = 2
                          IF thRd=0
                               thRd = 20
                               msD = 4
                          ENDIF
                          IF frS=0
                               frS = 20
                          ENDIF
                          IF fvS=0
                               fvS = 20
                               msD = 4
                          ENDIF
                          IF sxS=0
                               sxS = 20
                          ENDIF
                          IF thRd<>20 .OR. frS<>20
                               msT = 2
                          ELSE
                               msT = 4
                          ENDIF
                          msUmma = m_Summa1+' '+ed(thRd)+sd(msD)+' '+ ;
                                   ed(frS)+' '+sd(msT)+' '+ed(fvS)+ ;
                                   sd(msD)+' '+ed(sxS)
                     CASE msZ>0 .AND. msZ<20 .AND. meZ>20
                          thIrd = SUBSTR(zeRro, 3, 1)
                          foUrs = SUBSTR(zeRro, 4, 2)
                          fiVes = SUBSTR(zeRro, 6, 1)
                          siXs = SUBSTR(zeRro, 7, 1)
                          seVen = SUBSTR(zeRro, 8, 1)
                          thRd = VAL(thIrd)
                          frS = VAL(foUrs)
                          fvS = VAL(fiVes)
                          sxS = VAL(siXs)
                          svN = VAL(seVen)
                          egT = VAL(eiGht)
                          msD = 1
                          msT = 2
                          IF thRd=0
                               thRd = 20
                               msD = 4
                          ENDIF
                          IF frS=0
                               frS = 20
                          ENDIF
                          IF fvS=0
                               fvS = 20
                               msD = 4
                          ENDIF
                          IF svN=0
                               svN = 20
                          ENDIF
                          IF thRd<>20 .OR. frS<>20
                               msT = 2
                          ELSE
                               msT = 4
                          ENDIF
                          msUmma = m_Summa1+' '+ed(thRd)+sd(msD)+' '+ ;
                                   ed(frS)+' '+sd(msT)+' '+ed(fvS)+ ;
                                   sd(msD)+' '+dd(sxS)+' '+ed(svN)
                     CASE msZ>20 .AND. meZ>0 .AND. meZ<20
                          thIrd = SUBSTR(zeRro, 3, 1)
                          foUrs = SUBSTR(zeRro, 4, 1)
                          fiVes = SUBSTR(zeRro, 5, 1)
                          siXs = SUBSTR(zeRro, 6, 1)
                          seVen = SUBSTR(zeRro, 7, 2)
                          thRd = VAL(thIrd)
                          frS = VAL(foUrs)
                          fvS = VAL(fiVes)
                          sxS = VAL(siXs)
                          svN = VAL(seVen)
                          egT = VAL(eiGht)
                          msD = 1
                          msT = 2
                          IF thRd=0
                               thRd = 20
                               msD = 4
                          ENDIF
                          IF fvS=0
                               fvS = 20
                          ENDIF
                          IF sxS=0
                               sxS = 20
                               msD = 4
                          ENDIF
                          IF svN=0
                               svN = 20
                          ENDIF
                          IF thRd<>20 .OR. frS<>20 .OR. fvS<>20
                               msT = 2
                          ELSE
                               msT = 4
                          ENDIF
                          msUmma = m_Summa1+' '+ed(thRd)+sd(msD)+' '+ ;
                                   dd(frS)+' '+ed(fvS)+' '+sd(msT)+' '+ ;
                                   ed(sxS)+sd(msD)+' '+ed(svN)
                     CASE msZ>20 .AND. meZ>20
                          thIrd = SUBSTR(zeRro, 3, 1)
                          foUrs = SUBSTR(zeRro, 4, 1)
                          fiVes = SUBSTR(zeRro, 5, 1)
                          siXs = SUBSTR(zeRro, 6, 1)
                          seVen = SUBSTR(zeRro, 7, 1)
                          eiGht = SUBSTR(zeRro, 8, 1)
                          thRd = VAL(thIrd)
                          frS = VAL(foUrs)
                          fvS = VAL(fiVes)
                          sxS = VAL(siXs)
                          svN = VAL(seVen)
                          egT = VAL(eiGht)
                          msD = 1
                          msT = 2
                          IF thRd=0
                               thRd = 20
                               msD = 4
                          ENDIF
                          IF fvS=0
                               fvS = 20
                          ENDIF
                          IF sxS=0
                               sxS = 20
                               msD = 4
                          ENDIF
                          IF egT=0
                               egT = 20
                          ENDIF
                          IF thRd<>20 .OR. frS<>20 .OR. fvS<>20
                               msT = 2
                          ELSE
                               msT = 4
                          ENDIF
                          msUmma = m_Summa1+' '+ed(thRd)+sd(msD)+' '+ ;
                                   dd(frS)+' '+ed(fvS)+' '+sd(msT)+' '+ ;
                                   ed(sxS)+sd(msD)+' '+dd(svN)+' '+ed(egT)
                ENDCASE
      ENDCASE
      m_Summa2 = STR(diG, 15, 2)
      m_Summa3 = RIGHT(m_Summa2, 2)
 ENDIF
* SET STEP ON 
 usD = cuR
 lcceNt = tcCent
 msUmma = msUmma+' '+usD+' '+rtrim(m_Summa3)+' '+lcceNt
 msUmma = lcMark+STUFF(msUmma, 1, 1, LEFT(UPPER(msUmma), 1))
 RETURN msUmma
ENDFUNC
*
