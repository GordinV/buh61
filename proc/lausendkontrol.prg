**
** lausendkontrol.fxp
**
 LPARAMETER tcAlias
 LOCAL lnRecno, llKassadb, llKassakr, llKassakulud, llKassatulud,  ;
       llTulukontod, llKulukontod, llReturn, lcmessage 
 llReturn = .T.
lcmessage = ''
	&& TP
	IF UPPER(tcAlias) = 'V_JOURNAL1'
		SELECT comKontodRemote
		lcKonto = v_journal1.deebet
		LOCATE FOR kood = lcKonto
		
		IF FOUND()
			DO case
				CASE EMPTY(comKontodremote.tun1) AND !EMPTY(v_journal1.lisa_d)
					lcmessage = IIF(!EMPTY(lcmessage),",",'Konto '+lcKonto)+': TP kood peaks olla tühiline'
					llreturn = .f.	
				CASE !EMPTY(comKontodremote.tun1) AND EMPTY(v_journal1.lisa_d)
					lcmessage = IIF(!EMPTY(lcmessage),",",'Konto '+lcKonto)+': puudub TP kood'
					llreturn = .f.	
				CASE !EMPTY(comKontodremote.tun2) AND EMPTY(v_journal1.kood1)
					lcmessage = IIF(!EMPTY(lcmessage),",",'Konto '+lcKonto)+': puudub TT kood'
					llreturn = .f.	
				CASE !EMPTY(comKontodremote.tun3) AND EMPTY(v_journal1.kood2)
					lcmessage = IIF(!EMPTY(lcmessage),",",'Konto '+lcKonto)+': puudub Allika kood'
					llreturn = .f.	
				CASE !EMPTY(comKontodremote.tun4) AND EMPTY(v_journal1.kood3)
					lcmessage = IIF(!EMPTY(lcmessage),",",'Konto '+lcKonto)+': puudub Rahavoo kood'
					llreturn = .f.	
			ENDCASE
	ENDIF
			IF 	llreturn = .f. and !EMPTY(lcMessage)
				MESSAGEBOX(lcMessage,'Lausendi kontrol')
			endif
	
ENDIF
RETURN llReturn


*!*	 CREATE CURSOR qryAnalus (reCno INT, kaSsa INT, tuLu INT, kuLu INT, kuLud  ;
*!*	        INT, tuLud INT, teGev INT, alLikas INT, fiN INT, tuLemus INT DEFAULT 1)
*!*	 lnRecno = RECNO(tcAlias)
*!*	 WITH odB
*!*	      IF  .NOT. USED('v_eel_config')
*!*	           .usE('v_eel_config')
*!*	      ENDIF
*!*	      IF v_Eel_config.vaLklassif=0
*!*	           RETURN .T.
*!*	      ENDIF
*!*	      IF  .NOT. USED('comKassaKontod')
*!*	           .usE('v_kassakontod','comKassaKontod')
*!*	      ENDIF
*!*	      IF  .NOT. USED('comKassaKulud')
*!*	           .usE('v_kassakulud','comKassaKulud')
*!*	      ENDIF
*!*	      IF  .NOT. USED('comKassatulud')
*!*	           .usE('v_kassatulud','comKassaTulud')
*!*	      ENDIF
*!*	      IF  .NOT. USED('comKuluKontod')
*!*	           .usE('v_kuluKontod','comKuluKontod')
*!*	      ENDIF
*!*	      IF  .NOT. USED('comTuluKontod')
*!*	           .usE('v_TuluKontod','comTuluKontod')
*!*	      ENDIF
*!*	      SELECT (tcAlias)
*!*	      SCAN
*!*	           lcDeebet = deEbet
*!*	           lcKreedit = krEedit
*!*	           lcFin = obJekt
*!*	           lcTulu = alLikas
*!*	           lcKulu = arTikkel
*!*	           lcTegev = teGev
*!*	           lcAllikas = eeLallikas
*!*	           SELECT coMkassakontod
*!*	           LOCATE FOR ALLTRIM(koOd)=LEFT(ALLTRIM(lcDeebet),  ;
*!*	                  LEN(ALLTRIM(coMkassakontod.koOd)))
*!*	           IF FOUND()
*!*	                llKassadb = .T.
*!*	           ELSE
*!*	                LOCATE FOR ALLTRIM(koOd)=LEFT(ALLTRIM(lcKreedit),  ;
*!*	                       LEN(ALLTRIM(coMkassakontod.koOd)))
*!*	                IF FOUND()
*!*	                     llKassakr = .T.
*!*	                ENDIF
*!*	           ENDIF
*!*	           SELECT coMkassakulud
*!*	           LOCATE FOR ALLTRIM(koOd)=LEFT(ALLTRIM(lcDeebet),  ;
*!*	                  LEN(ALLTRIM(coMkassakulud.koOd)))
*!*	           IF FOUND()
*!*	                llKassakulud = .T.
*!*	           ENDIF
*!*	           SELECT coMkassatulud
*!*	           LOCATE FOR ALLTRIM(koOd)=LEFT(ALLTRIM(lcKreedit),  ;
*!*	                  LEN(ALLTRIM(coMkassatulud.koOd)))
*!*	           IF FOUND()
*!*	                llKassatulud = .T.
*!*	           ENDIF
*!*	           SELECT coMtulukontod
*!*	           LOCATE FOR ALLTRIM(koOd)=LEFT(ALLTRIM(lcKreedit),  ;
*!*	                  LEN(ALLTRIM(coMtulukontod.koOd)))
*!*	           IF FOUND()
*!*	                llTulukontod = .T.
*!*	           ENDIF
*!*	           SELECT coMkulukontod
*!*	           LOCATE FOR ALLTRIM(koOd)=LEFT(ALLTRIM(lcDeebet),  ;
*!*	                  LEN(ALLTRIM(coMkulukontod.koOd)))
*!*	           IF FOUND()
*!*	                llKulukontod = .T.
*!*	           ENDIF
*!*	           DO CASE
*!*	                CASE llKassadb=.T. .AND. llKassatulud=.T. .AND. EMPTY(lcFin)
*!*	                     INSERT INTO qryAnalus (reCno, kaSsa, tuLu, kuLu,  ;
*!*	                            kuLud, tuLud, teGev, alLikas, fiN) VALUES  ;
*!*	                            (RECNO(tcAlias), 1, 1, 0, IIF( .NOT.  ;
*!*	                            EMPTY(lcKulu), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcTulu), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcTegev), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcAllikas), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcFin), 1, 0))
*!*	                     IF  .NOT. EMPTY(qrYanalus.kaSsa) .AND.  .NOT.  ;
*!*	                         EMPTY(qrYanalus.tuLu) .AND.  .NOT.  ;
*!*	                         EMPTY(qrYanalus.tuLud) .AND.  .NOT.  ;
*!*	                         EMPTY(qrYanalus.alLikas) .AND.  ;
*!*	                         EMPTY(qrYanalus.kuLud) .AND. EMPTY(qrYanalus.teGev)
*!*	                          REPLACE tuLemus WITH 1 IN qrYanalus
*!*	                     ELSE
*!*	                          REPLACE tuLemus WITH 0 IN qrYanalus
*!*	                     ENDIF
*!*	                CASE llTulukontod=.T. .AND. EMPTY(lcFin)
*!*	                     INSERT INTO qryAnalus (reCno, kaSsa, tuLu, kuLu,  ;
*!*	                            kuLud, tuLud, teGev, alLikas, fiN) VALUES  ;
*!*	                            (RECNO(tcAlias), 0, 1, 0, IIF( .NOT.  ;
*!*	                            EMPTY(lcKulu), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcTulu), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcTegev), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcAllikas), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcFin), 1, 0))
*!*	                     IF  .NOT. EMPTY(qrYanalus.tuLu) .AND.  .NOT.  ;
*!*	                         EMPTY(qrYanalus.tuLud) .AND.  .NOT.  ;
*!*	                         EMPTY(qrYanalus.alLikas) .AND.  ;
*!*	                         EMPTY(qrYanalus.kuLud) .AND. EMPTY(qrYanalus.teGev)
*!*	                          REPLACE tuLemus WITH 1 IN qrYanalus
*!*	                     ELSE
*!*	                          REPLACE tuLemus WITH 0 IN qrYanalus
*!*	                     ENDIF
*!*	                CASE llKassakr=.T. .AND. llKassakulud=.T. .AND. EMPTY(lcFin)
*!*	                     INSERT INTO qryAnalus (reCno, kaSsa, tuLu, kuLu,  ;
*!*	                            kuLud, tuLud, teGev, alLikas, fiN) VALUES  ;
*!*	                            (RECNO(tcAlias), 1, 0, 1, IIF( .NOT.  ;
*!*	                            EMPTY(lcKulu), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcTulu), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcTegev), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcAllikas), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcFin), 1, 0))
*!*	                     IF  .NOT. EMPTY(qrYanalus.kaSsa) .AND.  ;
*!*	                         EMPTY(qrYanalus.tuLu) .AND.  ;
*!*	                         EMPTY(qrYanalus.tuLud) .AND.  .NOT.  ;
*!*	                         EMPTY(qrYanalus.alLikas) .AND.  .NOT.  ;
*!*	                         EMPTY(qrYanalus.kuLud) .AND.  .NOT.  ;
*!*	                         EMPTY(qrYanalus.teGev)
*!*	                          REPLACE tuLemus WITH 1 IN qrYanalus
*!*	                     ELSE
*!*	                          REPLACE tuLemus WITH 0 IN qrYanalus
*!*	                     ENDIF
*!*	                CASE llKulukontod=.T. .AND. EMPTY(lcFin)
*!*	                     INSERT INTO qryAnalus (reCno, kaSsa, tuLu, kuLu,  ;
*!*	                            kuLud, tuLud, teGev, alLikas, fiN) VALUES  ;
*!*	                            (RECNO(tcAlias), 0, 0, 1, IIF( .NOT.  ;
*!*	                            EMPTY(lcKulu), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcTulu), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcTegev), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcAllikas), 1, 0), IIF( .NOT.  ;
*!*	                            EMPTY(lcFin), 1, 0))
*!*	                     IF EMPTY(qrYanalus.tuLu) .AND.  ;
*!*	                        EMPTY(qrYanalus.tuLud) .AND.  .NOT.  ;
*!*	                        EMPTY(qrYanalus.alLikas) .AND.  .NOT.  ;
*!*	                        EMPTY(qrYanalus.kuLud) .AND.  .NOT.  ;
*!*	                        EMPTY(qrYanalus.teGev)
*!*	                          REPLACE tuLemus WITH 1 IN qrYanalus
*!*	                     ELSE
*!*	                          REPLACE tuLemus WITH 0 IN qrYanalus
*!*	                     ENDIF
*!*	                CASE  .NOT. EMPTY(lcFin) .AND.  .NOT. EMPTY(lcAllikas)
*!*	                     INSERT INTO qryAnalus (reCno, kaSsa, tuLu, kuLu,  ;
*!*	                            kuLud, tuLud, teGev, alLikas, fiN, tuLemus)  ;
*!*	                            VALUES (RECNO(tcAlias), 0, 0, 0, 0, 0, 0, 1, 1, 1)
*!*	                OTHERWISE
*!*	                     INSERT INTO qryAnalus (reCno, kaSsa, tuLu, kuLu,  ;
*!*	                            kuLud, tuLud, teGev, alLikas, fiN, tuLemus)  ;
*!*	                            VALUES (RECNO(tcAlias), 0, 0, 0, 0, 0, 0, 0, 0, 1)
*!*	           ENDCASE
*!*	           IF qrYanalus.tuLemus=0
*!*	                EXIT
*!*	           ENDIF
*!*	      ENDSCAN
*!*	      IF qrYanalus.tuLemus=0
*!*	           llReturn = .F.
*!*	      ENDIF
*!*	      USE IN qrYanalus
*!*	 ENDWITH
 RETURN llReturn
ENDFUNC
*
