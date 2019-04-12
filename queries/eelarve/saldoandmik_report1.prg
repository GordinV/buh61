PARAMETERS tcParam

 
CREATE CURSOR saldoaruanne_report1 (konto c(20), tp c(20), tegev c(20), allikas c(20), rahavoo c(20), db n(18,6), kr n(18,6), nimetus c(254),;
	dbKokku n(18,6), krKokku n(18,6))
 
lnKuurs = 1
lnKuurs = fnc_currentvaluuta('KUURS',fltrAruanne.kpv2)
 
 IF USED('fltrPrinter') 
	lnKuurs = fltrPrinter.kuurs
 ENDIF

 IF gvErsia='PG'
    *   SET STEP ON 
      lcString = "select count(*) as count from pg_proc where proname = 'sp_saldoandmik_report'"
      leRror = odB.exEcsql(lcString,'tmpProc')
      IF  .NOT. EMPTY(leRror) .AND. USED('tmpProc') .AND.  .NOT. EMPTY(tmPproc.coUnt)
           leRror = odB.exEc("sp_saldoandmik_report ",STR(grEkv)+", DATE("+STR(YEAR(flTraruanne.kpV2), 4)+","+STR(MONTH(flTraruanne.kpV2), 2)+","+STR(DAY(flTraruanne.kpV2), 2)+"),2,"+;
           	ALLTRIM(STR(flTraruanne.kond,9))+",0","qrySaldoandmik")
           IF USED('qrySaldoandmik')
                tcTimestamp = ALLTRIM(qrYsaldoandmik.sp_saldoandmik_report)
                lcString = "select LEFT(konto,6)::varchar as konto, tp::varchar, tegev::varchar, allikas::varchar, rahavoo::varchar, sum(db) as db, sum(kr) as kr, nimetus::varchar "+;
                	" from tmp_saldoandmik where rekvid = "+STR(grEkv)+" and timestamp = '"+tcTimestamp+"'"+;
                	" and tegev like '"+ALLTRIM(fltrAruanne.kood1)+"%' and allikas like '"+ALLTRIM(fltrAruanne.kood2)+"%'"+;
                	" and rahavoo like '"+ALLTRIM(fltrAruanne.kood3)+"%' and konto like '"+ALLTRIM(fltrAruanne.kood4)+"%'"+;
                	" and tp like '"+ALLTRIM(fltrAruanne.tp)+"%'" +;
                	" group by konto, tp, tegev, allikas, rahavoo, nimetus order by konto, tp, tegev, allikas, rahavoo  "
                	
                leRror = odB.exEcsql(lcString,'saldoaruanne_report')
                IF  .NOT. EMPTY(leRror) .AND. USED('saldoaruanne_report')
                	SELECT konto, tp, tegev, allikas, rahavoo, sum(db) as db, sum(kr) as kr;
                		FROM saldoaruanne_report  ;
                		group BY konto, tp, tegev, allikas, rahavoo ;     		
                		ORDER BY konto, tp, tegev, allikas, rahavoo ;
                		INTO CURSOR saldoaruanne_report0
                
                	USE IN saldoaruanne_report
                
                     SELECT saLdoaruanne_report0
                     SCAN
                     	
                     	SELECT comKontodRemote
                     	LOCATE FOR kood = saldoaruanne_report0.konto
                     	
                     	SELECT saldoaruanne_report1  	
                     	INSERT INTO saldoaruanne_report1 (konto, tp, tegev, allikas, rahavoo, db, kr, nimetus);
                     	VALUES (saldoaruanne_report0.konto, saldoaruanne_report0.tp, saldoaruanne_report0.tegev, ;
                     		saldoaruanne_report0.allikas, saldoaruanne_report0.rahavoo, round(saldoaruanne_report0.db/lnKuurs,2),;
                     		ROUND(saldoaruanne_report0.kr/lnKuurs,2), IIF(!ISNULL(comKontodRemote.nimetus),comKontodRemote.nimetus,''))
                     ENDSCAN
                     USE IN saldoaruanne_report0
                     SELECT saldoaruanne_report1  
                     SELECT sum(db) as dbkokku, sum(kr) as krkokku FROM saldoaruanne_report1 WHERE LEFT(konto,1) NOT in  ('8','9') into cursor tmpSKokku
                     
                     UPDATE saldoaruanne_report1 SET dbKokku = tmpSKokku.dbKokku, krKokku = tmpSKokku.krkokku 
                     USE IN tmpSKokku
                     SELECT saldoaruanne_report1
                     GO top
                     RETURN
                ENDIF
           ELSE
                SELECT 0
                RETURN .F.
           ENDIF
      ENDIF
 ENDIF
*!*	 SELECT tmPvanemtasu_aruanne1
*!*	 tcKonto = LTRIM(TRIM(flTraruanne.koOd4))+'%'
*!*	 tcTp = LTRIM(TRIM(flTraruanne.tp))+'%'
*!*	 tcTegev = LTRIM(TRIM(flTraruanne.koOd1))+'%'
*!*	 tcAllikas = LTRIM(TRIM(flTraruanne.koOd2))+'%'
*!*	 tcTunnus = LTRIM(TRIM(flTraruanne.tuNnus))+'%'
*!*	 tnAsutusid1 = 0
*!*	 tnAsutusid2 = 99999999
*!*	 tnTunnusid1 = 0
*!*	 tnTunnusid2 = 99999999
*!*	 tdKpv1 = DATE(1900, 1, 1)
*!*	 tdKpv2 = DATE(YEAR(flTraruanne.kpV2), 01, 01)-1
*!*	 WITH odB
*!*	      .usE('qrySubkonto')
*!*	      .usE('qrySaldo1','CursorAlgSaldo')
*!*	      .usE('QRYEELARVESALDO')
*!*	      tdKpv1 = tdKpv2+1
*!*	      tdKpv2 = flTraruanne.kpV2
*!*	      leRror = .usE('qrySaldoAr','Saldoaruanne_report',.T.)
*!*	      INDEX ON koNto+'-'+tp+'-'+teGev+'-'+alLikas+'-'+raHavoo TAG koOd
*!*	      SET ORDER TO kood
*!*	      leRror = .usE('qrySaldoAr','qrySaldoar')
*!*	      INSERT INTO qrySaldoar (koNto, raHavoo, db, tp) !_ERR=0X6F_?-[72 BC 03 6F]  FROM 'comKontodremote' !_ERR=0XD4_?-[72 BC 15 D4]  !_ERR=0XD2_?-[72 BC D4 D2]  'qrySubkonto' ON coMkontodremote.id=qrYsubkonto.koNtoid LEFT(ALLTRIM(coMkontodremote.koOd), 6), '00', qrYsubkonto.alGsaldo, qrYsubkonto.tp POPUP LEN(ALLTRIM(coMkontodremote.koOd))>=6
*!*	      DELETE FROM CursorAlgSaldo WHERE LEFT(ALLTRIM(koNto), 6)?IN(SELECT LEFT(ALLTRIM(coMkontodremote.koOd), 6) FROM comKontodremote INNER JOIN qrySubkonto ON coMkontodremote.id=qrYsubkonto.koNtoid)
*!*	      USE IN qrYsubkonto
*!*	      SELECT qrYsaldoar
*!*	      INSERT INTO qrySaldoar (koNto, raHavoo, db) !_ERR=0X6F_?-[72 BC 03 6F]  FROM 'CursorAlgSaldo' LEFT(ALLTRIM(cuRsoralgsaldo.koNto), 6), '00', cuRsoralgsaldo.deEbet-cuRsoralgsaldo.krEedit POPUP LEFT(ALLTRIM(koNto), 6)? .NOT. IN(SELECT LEFT(ALLTRIM(coMkontodremote.koOd), 6) FROM comKontodremote INNER JOIN QRYEELARVESALDO ON coMkontodremote.id=qrYeelarvesaldo.koNtoid) .AND. (cuRsoralgsaldo.deEbet<>0 .OR. cuRsoralgsaldo.krEedit<>0) .AND. LEN(ALLTRIM(cuRsoralgsaldo.koNto))>=6
*!*	      USE IN cuRsoralgsaldo
*!*	      INSERT INTO qrySaldoar (koNto, alLikas, db) !_ERR=0X6F_?-[72 BC 03 6F]  FROM 'QRYEELARVESALDO' !_ERR=0XD4_?-[72 BC 15 D4]  !_ERR=0XD2_?-[72 BC D4 D2]  'comKontodremote' ON qrYeelarvesaldo.koNtoid=coMkontodremote.id !_ERR=0XD4_?-[72 BC 20 D4]  !_ERR=0XD2_?-[72 BC D4 D2]  'comAllikadremote' ON qrYeelarvesaldo.alLikadid=coMallikadremote.id LEFT(ALLTRIM(coMkontodremote.koOd), 6), coMallikadremote.koOd, qrYeelarvesaldo.alGsaldo POPUP LEN(ALLTRIM(coMkontodremote.koOd))>=6
*!*	      INSERT INTO qrySaldoar (koNto, raHavoo, db) !_ERR=0X6F_?-[72 BC 03 6F]  FROM 'QRYEELARVESALDO' !_ERR=0XD4_?-[72 BC 15 D4]  !_ERR=0XD2_?-[72 BC D4 D2]  'comKontodremote' ON qrYeelarvesaldo.koNtoid=coMkontodremote.id !_ERR=0XD4_?-[72 BC 20 D4]  !_ERR=0XD2_?-[72 BC D4 D2]  'comRaharemote' ON qrYeelarvesaldo.raHavooid=coMraharemote.id LEFT(ALLTRIM(coMkontodremote.koOd), 6), coMraharemote.koOd, qrYeelarvesaldo.alGsaldo POPUP LEN(ALLTRIM(coMkontodremote.koOd))>=6
*!*	      USE IN qrYeelarvesaldo
*!*	 ENDWITH
*!*	 lcKulumkontostring = '155110,155111,155116,155119,155310,155410,155415,155510,155610'
*!*	 SELECT coMkassaremote
*!*	 IF RECCOUNT()>1
*!*	      LOCATE FOR deFault_=1
*!*	 ENDIF
*!*	 lcOmatp = coMkassaremote.tp
*!*	 SELECT qrYsaldoar
*!*	 DELETE FROM qrySaldoar WHERE koNto='999999'
*!*	 SCAN
*!*	      lnTun = 1
*!*	      lnKoef = 1
*!*	      SCATTER MEMVAR
*!*	      SELECT coMkontodremote
*!*	      IF TAG()<>'KOOD'
*!*	           SET ORDER TO kood
*!*	      ENDIF
*!*	      LOCATE FOR LEFT(ALLTRIM(koOd), 6)=LEFT(ALLTRIM(qrYsaldoar.koNto), 6)
*!*	      lnTun = coMkontodremote.tuN5
*!*	      IF lnTun=1 .OR. lnTun=3
*!*	           M.deEbet = lnKoef*(qrYsaldoar.db-qrYsaldoar.kr)
*!*	           M.krEedit = 0
*!*	      ELSE
*!*	           M.krEedit = lnKoef*(qrYsaldoar.kr-qrYsaldoar.db)
*!*	           M.deEbet = 0
*!*	      ENDIF
*!*	      IF EMPTY(coMkontodremote.tuN1)
*!*	           M.tp = ''
*!*	      ENDIF
*!*	      IF EMPTY(coMkontodremote.tuN2)
*!*	           M.teGev = ''
*!*	      ENDIF
*!*	      IF EMPTY(coMkontodremote.tuN3)
*!*	           M.alLikas = ''
*!*	      ENDIF
*!*	      IF EMPTY(coMkontodremote.tuN4)
*!*	           M.raHavoo = ''
*!*	      ENDIF
*!*	      M.koNto = LEFT(M.koNto, 6)
*!*	      DO CASE
*!*	           CASE M.koNto='100101' .OR. M.koNto='100102' .OR. M.koNto='100103' .OR. M.koNto='100104' .OR. M.koNto='100105'
*!*	                M.koNto = '100100'
*!*	           CASE M.koNto='103001'
*!*	                M.koNto = '103000'
*!*	           CASE M.koNto='155401'
*!*	                M.koNto = '155400'
*!*	           CASE M.koNto='155402'
*!*	                M.koNto = '155400'
*!*	           CASE M.koNto='201001'
*!*	                M.koNto = '201000'
*!*	           CASE M.koNto='202091'
*!*	                M.koNto = '202090'
*!*	           CASE M.koNto='551501' .OR. M.koNto='551502' .OR. M.koNto='551503' .OR. M.koNto='551504'
*!*	                M.koNto = '551500'
*!*	           CASE LEFT(M.koNto, 3)='155' .AND. M.raHavoo<>'01' .AND.  .NOT. EMPTY(M.raHavoo)
*!*	                M.tp = ''
*!*	      ENDCASE
*!*	      IF M.deEbet<>0 .OR. M.krEedit<>0
*!*	           SELECT saLdoaruanne_report
*!*	           APPEND BLANK
*!*	           REPLACE db WITH M.deEbet, kr WITH M.krEedit, koNto WITH M.koNto, teGev WITH M.teGev, tp WITH M.tp, alLikas WITH M.alLikas, raHavoo WITH M.raHavoo IN saLdoaruanne_report
*!*	      ENDIF
*!*	 ENDSCAN
*!*	 SELECT SUM(db) AS db, SUM(kr) AS kr, koNto, teGev, tp, alLikas, raHavoo FROM Saldoaruanne_report GROUP BY koNto, tp, teGev, alLikas, raHavoo ORDER BY koNto, tp, teGev, alLikas, raHavoo INTO CURSOR Saldoaruanne_report_
*!*	 SELECT saLdoaruanne_report_.*, coMkontodremote.niMetus FROM Saldoaruanne_report_ INNER JOIN comKontodremote ON saLdoaruanne_report_.koNto=coMkontodremote.koOd WHERE db<>0 OR kr<>0 ORDER BY saLdoaruanne_report_.koNto, saLdoaruanne_report_.tp, saLdoaruanne_report_.teGev, saLdoaruanne_report_.alLikas, saLdoaruanne_report_.raHavoo INTO CURSOR saldoaruanne_report1
*!*	 USE IN saLdoaruanne_report
*!*	 USE IN saLdoaruanne_report_
*!*	 IF  .NOT. USED('saldoaruanne_report1')
*!*	      glError = .T.
*!*	      SELECT 0
*!*	      RETURN
*!*	 ENDIF
*!*	 SELECT saLdoaruanne_report1
ENDFUNC
*
