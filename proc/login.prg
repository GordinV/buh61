**
** login.fxp
**
*
DEFINE CLASS login AS dokument
 naMe = "login"
 asUtusid = 0
 usErid = 0
 wiDth = 640
 caPtion = 'Login'
 heIght = 100
 auTocenter = .T.
 shOwwindow = 2
 wiNdowtype = 1
 keY = ''
 meSsage = ''
 ADD OBJECT coMrekv AS myCombo WITH toP = 5, leFt = 100, wiDth = 400,  ;
     naMe = "comrekv", boUndcolumn = 1, boUndto = .T., roWsourcetype = 6,  ;
     roWsource = "comkey.omanik, id", coLumncount = 2, coLumnwidths =  ;
     "400,0", coLumnlines = 0, vaLue = 0, style = 2
 ADD OBJECT txTkasutaja AS myTxt WITH toP = 35, leFt = 100, wiDth = 200,  ;
     naMe = "txtKasutaja"
 ADD OBJECT txTparool AS myTxt WITH toP = 70, leFt = 100, wiDth = 200,  ;
     naMe = "txtParool", paSswordchar = '*'
 ADD OBJECT btNok AS myBtn WITH caPtion = '', toP = 5, leFt = 525, wiDth =  ;
     100, naMe = "btnOk", piCture = "pictures\btok.bmp"
 ADD OBJECT btNcancel AS myBtn WITH caPtion = '', toP = 40, leFt = 525,  ;
     wiDth = 100, naMe = "btnCancel", piCture = "pictures\btExit.bmp"
 ADD OBJECT lbLasutus AS myLbl WITH toP = 5, leFt = 5, naMe = "lblAsutus",  ;
     caPtion = "Database:"
 ADD OBJECT lbLkasutaja AS myLbl WITH toP = 35, leFt = 5, naMe =  ;
     "lblKasutaja", caPtion = "Kasutaja nimi:"
 ADD OBJECT lbLparool AS myLbl WITH toP = 70, leFt = 5, naMe =  ;
     "lblParool", caPtion = "Parool:"
*
     PROCEDURE btNok.click
      SET CLASSLIB TO logo
      olOgo = CREATEOBJECT('logo')
      olOgo.shOw()
      WITH thIsform
           ocOnnect = NEWOBJECT('connect', 'connect')
           SELECT coMkey
           leRror = ocOnnect.odB(SYS(2007, ALLTRIM(coMkey.omAnik)), ;
                    ALLTRIM(.txTkasutaja.vaLue), ;
                    RTRIM(LTRIM(.txTparool.vaLue)),thIsform.keY,.T.)
                   
           IF leRror=.T.
                IF UPPER(.keY)='-K'
                     DO FORM key WITH 'EDIT', cuRkey.id
                     CLEAR EVENTS
                ELSE
                     ON KEY LABEL CTRL+A DO ONKEY WITH ('CTRL+A')
                     ON KEY LABEL CTRL+S DO ONKEY WITH ('CTRL+S')
                     ON KEY LABEL CTRL+P DO ONKEY WITH ('CTRL+P')
                     _SCREEN.viSible = .T.
                ENDIF
           ELSE
                thIsform.viGa
                CLEAR EVENTS
           ENDIF
           RELEASE olOgo
      ENDWITH
      RELEASE thIsform
     ENDPROC
*
     PROCEDURE btNcancel.click
      CLEAR EVENTS
      RELEASE thIsform
     ENDPROC
*
     PROCEDURE coMrekv.init
      thIs.vaLue = coMkey.id
     ENDPROC
*
     PROCEDURE init
      PARAMETER tkEy
      IF EMPTY(tkEy)
           tkEy = ''
      ENDIF
      thIs.keY = tkEy
      DO CASE
           CASE UPPER(tkEy)='-D'
                ON ERROR
           CASE UPPER(tkEy)='-E'
                ON ERROR DO FERR
           OTHERWISE
                ON ERROR DO ERR WITH PROGRAM(), LINENO(1)				
      ENDCASE
     ENDPROC
*
     PROCEDURE unload
      WITH thIs
           IF EMPTY(grEkv)
                CLEAR EVENTS
           ENDIF
      ENDWITH
     ENDPROC
*
     FUNCTION encryptpass
      LPARAMETER tcPass
      lcCryptpath = enCrypt(f_Key(),tcPass)
      REPLACE v_Pass.paRool WITH lcCryptpath IN v_Pass
      odB.cuRsorupdate('v_pass')
      RETURN lcCryptpath
     ENDFUNC
*
     FUNCTION decryptpass
      LPARAMETER tcPass
      lcDecryptpath = deCrypt(f_Key(),tcPass)
      RETURN lcDecryptpath
     ENDFUNC
*
     PROCEDURE AvadaAruanned
     ENDPROC
*
     PROCEDURE viGa
      LOCAL lcString
      thIs.meSsage = "Login ebaonestus"
      lcString = "messagebox('"+thIs.meSsage+"','Viga')"
      &lcString
      RELEASE thIsform
     ENDPROC
*
ENDDEFINE
*