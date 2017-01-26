 LPARAMETER tnRekvid, tnKuu, tnAasta, tcKonto
 IF gvErsia<>'VFP'
      RETURN .F.
 ENDIF
 SELECT aaSta, kuU AS alGkuu FROM aasta WHERE kiNni=1 ORDER BY kiNni DESC,  ;
        aaSta DESC, kuU DESC TOP 1 INTO CURSOR Algkuu
 IF RECCOUNT('algkuu')<1
      SELECT aaSta, 1 AS alGkuu FROM aasta ORDER BY aaSta, kuU TOP 1 INTO  ;
             CURSOR Algkuu
 ENDIF
 USE IN aaSta
 lnAlgkuu = alGkuu.alGkuu
 lnAasta = alGkuu.aaSta
 IF alGkuu.alGkuu<=1 .AND. alGkuu.aaSta<>tnAasta
      SELECT koNtoinf.reKvid, tnKuu AS kuU, tnAasta AS aaSta,  ;
             liBrary.koOd AS koNto, IIF(koNtoinf.alGsaldo>=0,  ;
             VAL(STR(koNtoinf.alGsaldo, 12, 2)), VAL(STR(000000000.00, 12,  ;
             2))) AS deEbet, IIF(koNtoinf.alGsaldo<0, -1* ;
             VAL(STR(koNtoinf.alGsaldo, 12, 2)), VAL(STR(000000000.00, 12,  ;
             2))) AS krEedit FROM library INNER JOIN kontoinf ON  ;
             liBrary.id=koNtoinf.paRentid WHERE koNtoinf.aaSta= ;
             alGkuu.aaSta AND koNtoinf.reKvid=tnRekvid AND koOd LIKE  ;
             tcKonto  INTO CURSOR tmpSaldo UNION ALL SELECT  ;
             cuRkaibed.reKvid AS reKvid, tnKuu AS kuU, tnAasta AS aaSta,  ;
             cuRkaibed.koNto AS koNto, VAL(STR(cuRkaibed.deEbet, 12, 2))  ;
             AS deEbet, VAL(STR(cuRkaibed.krEedit, 12, 2)) AS krEedit  ;
             FROM curkaibed_ cuRkaibed WHERE STR(aaSta, 4)+STR(kuU, 2)< ;
             STR(tnAasta, 4)+STR(tnKuu, 2) AND cuRkaibed.aaSta>= ;
             alGkuu.aaSta AND reKvid=tnRekvid AND koNto LIKE tcKonto 
      SELECT reKvid, koNto, SUM(deEbet) AS deEbet, SUM(krEedit) AS  ;
             krEedit FROM tmpSaldo GROUP BY reKvid, kuU, aaSta, koNto  ;
             ORDER BY reKvid, kuU, aaSta, koNto INTO CURSOR sqlresult
 ENDIF
 IF lnAlgkuu<tnKuu .AND. lnAlgkuu>1 .AND. tnAasta>lnAasta
      SELECT reKvid, tnKuu AS kuU, tnAasta AS aaSta, koNto, VAL(STR(saLdo+ ;
             dbKaibed-krKaibed, 12, 2)) AS deEbet, VAL(STR(000000000.00,  ;
             12, 2)) AS krEedit FROM saldo WHERE koNto LIKE tcKonto  AND  ;
             reKvid=tnRekvid AND MONTH(peRiod)=lnAlgkuu AND YEAR(peRiod)= ;
             lnAasta INTO CURSOR tmpSaldo UNION ALL SELECT  ;
             cuRkaibed.reKvid AS reKvid, tnKuu AS kuU, tnAasta AS aaSta,  ;
             cuRkaibed.koNto AS koNto, VAL(STR(cuRkaibed.deEbet, 12, 2))  ;
             AS deEbet, VAL(STR(cuRkaibed.krEedit, 12, 2)) AS krEedit  ;
             FROM curkaibed_ cuRkaibed WHERE STR(aaSta, 4)+STR(kuU, 2)> ;
             STR(lnAasta, 4)+STR(lnAlgkuu, 2) AND STR(aaSta, 4)+STR(kuU,  ;
             2)<STR(tnAasta, 4)+STR(tnKuu, 2) AND reKvid=tnRekvid AND  ;
             koNto LIKE tcKonto 
      SELECT reKvid, kuU, aaSta, koNto, SUM(deEbet) AS deEbet,  ;
             SUM(krEedit) AS krEedit FROM tmpSaldo WHERE koNto LIKE  ;
             tcKonto  GROUP BY reKvid, kuU, aaSta, koNto ORDER BY reKvid,  ;
             kuU, aaSta, koNto INTO CURSOR sqlresult
 ENDIF
 IF alGkuu.alGkuu<tnKuu .AND. alGkuu.alGkuu>0 .AND. alGkuu.aaSta=tnAasta
      SELECT reKvid, tnKuu AS kuU, tnAasta AS aaSta, koNto, VAL(STR(saLdo+ ;
             dbKaibed-krKaibed, 12, 2)) AS deEbet, VAL(STR(000000000.00,  ;
             12, 2)) AS krEedit FROM saldo WHERE koNto LIKE tcKonto  AND  ;
             reKvid=tnRekvid AND MONTH(peRiod)=alGkuu.alGkuu AND  ;
             YEAR(peRiod)=tnAasta INTO CURSOR tmpSaldo UNION ALL SELECT  ;
             cuRkaibed.reKvid AS reKvid, tnKuu AS kuU, tnAasta AS aaSta,  ;
             cuRkaibed.koNto AS koNto, VAL(STR(cuRkaibed.deEbet, 12, 2))  ;
             AS deEbet, VAL(STR(cuRkaibed.krEedit, 12, 2)) AS krEedit  ;
             FROM curkaibed_ cuRkaibed WHERE kuU>alGkuu.alGkuu AND kuU< ;
             tnKuu AND aaSta=tnAasta AND reKvid=tnRekvid AND koNto LIKE  ;
             tcKonto 
      SELECT reKvid, kuU, aaSta, koNto, SUM(deEbet) AS deEbet,  ;
             SUM(krEedit) AS krEedit FROM tmpSaldo WHERE koNto LIKE  ;
             tcKonto  GROUP BY reKvid, kuU, aaSta, koNto INTO CURSOR sqlresult
 ENDIF
 IF tnKuu=1 .AND. alGkuu.aaSta=tnAasta
      SELECT koNtoinf.reKvid, 0 AS kuU, koNtoinf.aaSta, liBrary.koOd AS  ;
             koNto, IIF(koNtoinf.alGsaldo>=0, koNtoinf.alGsaldo,  ;
             000000000.00) AS deEbet, IIF(koNtoinf.alGsaldo<0, -1* ;
             koNtoinf.alGsaldo, 000000000.00) AS krEedit FROM library  ;
             INNER JOIN kontoinf ON liBrary.id=koNtoinf.paRentid WHERE  ;
             koNtoinf.aaSta=tnAasta AND koNtoinf.reKvid=tnRekvid AND koOd  ;
             LIKE tcKonto  INTO CURSOR tmpSaldo
      SELECT reKvid, koNto, SUM(deEbet) AS deEbet, SUM(krEedit) AS  ;
             krEedit FROM tmpSaldo GROUP BY reKvid, kuU, aaSta, koNto  ;
             INTO CURSOR sqlresult
 ENDIF
 IF alGkuu.alGkuu>tnKuu .AND. alGkuu.alGkuu>1 .AND. tnKuu>1 .AND.  ;
    alGkuu.aaSta=tnAasta
      lnAlgkuu = tnKuu-1
      SELECT reKvid, koNto, MONTH(peRiod) AS kuU, YEAR(peRiod) AS aaSta,  ;
             IIF(saLdo+dbKaibed-krKaibed>=0, saLdo+dbKaibed-krKaibed,  ;
             000000000.00) AS deEbet, IIF(saLdo+dbKaibed-krKaibed<0,  ;
             krKaibed-(saLdo+dbKaibed), 000000000.00) AS krEedit FROM  ;
             saldo WHERE reKvid=tnRekvid AND koNto LIKE tcKonto  AND  ;
             MONTH(peRiod)=lnAlgkuu AND YEAR(peRiod)=tnAasta INTO CURSOR  ;
             sqlresult
 ENDIF
 IF alGkuu.alGkuu=tnKuu .AND. alGkuu.alGkuu>0 .AND. alGkuu.aaSta=tnAasta
      lnAlgkuu = tnKuu-1
      SELECT reKvid, tnKuu AS kuU, tnAasta AS aaSta, LEFT(koNto, 20) AS  ;
             koNto, STR(saLdo+dbKaibed-krKaibed, 12, 2) AS deEbet,  ;
             STR(000000000000.00, 12, 2) AS krEedit FROM saldo WHERE  ;
             koNto LIKE tcKonto  AND reKvid=tnRekvid AND MONTH(peRiod)= ;
             lnAlgkuu AND YEAR(peRiod)=tnAasta INTO CURSOR tmpSaldo UNION  ;
             SELECT cuRkaibed.reKvid AS reKvid, tnKuu AS kuU, tnAasta AS  ;
             aaSta, LEFT(cuRkaibed.koNto, 20) AS koNto,  ;
             STR(cuRkaibed.deEbet, 12, 2) AS deEbet,  ;
             STR(cuRkaibed.krEedit, 12, 2) AS krEedit FROM curkaibed_  ;
             cuRkaibed WHERE kuU>lnAlgkuu AND kuU<tnKuu AND aaSta=tnAasta  ;
             AND reKvid=tnRekvid AND koNto LIKE tcKonto 
      SELECT reKvid, kuU, aaSta, koNto, SUM(VAL(deEbet)) AS deEbet,  ;
             SUM(VAL(krEedit)) AS krEedit FROM tmpSaldo WHERE koNto LIKE  ;
             tcKonto  GROUP BY reKvid, kuU, aaSta, koNto INTO CURSOR sqlresult
 ENDIF
 IF tnKuu>1 .AND. alGkuu.alGkuu=0 .AND. alGkuu.aaSta=tnAasta
      SELECT koNtoinf.reKvid, tnKuu AS kuU, tnAasta AS aaSta,  ;
             LEFT(liBrary.koOd, 20) AS koNto, STR(IIF(koNtoinf.alGsaldo>= ;
             0, koNtoinf.alGsaldo, 000000000.00), 12, 2) AS deEbet,  ;
             STR(IIF(koNtoinf.alGsaldo<0, -1*koNtoinf.alGsaldo,  ;
             000000000.00), 12, 2) AS krEedit FROM library INNER JOIN  ;
             kontoinf ON liBrary.id=koNtoinf.paRentid WHERE  ;
             koNtoinf.aaSta=tnAasta AND koNtoinf.reKvid=tnRekvid AND koOd  ;
             LIKE tcKonto  INTO CURSOR tmpSaldo UNION ALL SELECT  ;
             cuRkaibed.reKvid AS reKvid, tnKuu AS kuU, tnAasta AS aaSta,  ;
             LEFT(cuRkaibed.koNto, 20) AS koNto, STR(cuRkaibed.deEbet, 12,  ;
             2) AS deEbet, STR(cuRkaibed.krEedit, 12, 2) AS krEedit FROM  ;
             curkaibed_ cuRkaibed WHERE kuU<tnKuu AND aaSta=tnAasta AND  ;
             reKvid=tnRekvid AND koNto LIKE tcKonto 
      SELECT reKvid, koNto, SUM(VAL(deEbet)) AS deEbet, SUM(VAL(krEedit))  ;
             AS krEedit FROM tmpSaldo GROUP BY reKvid, kuU, aaSta, koNto  ;
             INTO CURSOR sqlResult
 ENDIF
 IF USED('tmpSaldo')
      USE IN tmPsaldo
 ENDIF
 IF USED('kontoinf')
      USE IN koNtoinf
 ENDIF
 IF USED('library')
      USE IN liBrary
 ENDIF
 IF USED('curkaibed')
      USE IN cuRkaibed
 ENDIF
 IF USED('saldo')
      USE IN saLdo
 ENDIF
 RETURN .T.
ENDFUNC
*
