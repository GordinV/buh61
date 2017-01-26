**
** repenhance.fxp
**
*
FUNCTION RepEnhance
 LPARAMETER tcExcelfilein, tcExcelfileout, tcTypefileout, tnPlatform,  ;
            tlEnhcolumn, tlEnhheader, tlEnhtitle, tlEnhsummary, ar_detail,  ;
            ar_header, ar_title, ar_summary, tnRecords, tnPageorient,  ;
            tnPageleftmargin, tlNomessages
 EXTERNAL ARRAY ar_detail, ar_header, ar_title, ar_summary
 IF EMPTY(M.tnPageleftmargin)
      tnPageleftmargin = 0
 ENDIF
 IF  .NOT. M.tlEnhcolumn .AND.  .NOT. M.tlEnhheader .AND.  .NOT.  ;
     M.tlEnhtitle .AND.  .NOT. M.tlEnhsummary
      RETURN 0
 ENDIF
 IF  .NOT. FILE(M.tcExcelfilein)
      RETURN 1
 ENDIF
 LOCAL lnOldselect
 lnOldselect = SELECT()
 LOCAL oeXcel, lcOldonerror, lnEnherror, lcTitle
 lcTitle = "Report export - Formating"
 lnEnherror = 0
 lcOldonerror = onError()
 ON ERROR LNENHERROR=ERROR()
 oeXcel = CREATEOBJECT("Excel.Application")
 ON ERROR &lcOldOnError
 IF M.lnEnherror<>0
      IF  .NOT. M.tlNomessages
           = woRn_mesg("Can not open Excel, error "+as(M.lnEnherror),M.lcTitle)
      ENDIF
      RETURN M.lnEnherror
 ENDIF
 IF  .NOT. isObject(M.oeXcel)
      RETURN 2
 ENDIF
 owOrkbook = oeXcel.woRkbooks.opEn(M.tcExcelfilein)
 IF  .NOT. isObject(M.owOrkbook)
      oeXcel.quIt
      RETURN 3
 ENDIF
 owOrksheet1 = owOrkbook.woRksheets(1)
 IF  .NOT. isObject(M.owOrksheet1)
      oeXcel.quIt
      RETURN 4
 ENDIF
 IF  .NOT. M.tlNomessages
      WAIT WINDOW NOCLEAR NOWAIT 'Excel automotion, please wait'
 ENDIF
 LOCAL i, lnLastheadrow, lnRow, lnRowto, lnColumn, lnColumns, lnCharsize,  ;
       lnPointsperchar, leValue
 lnLastheadrow = 1
 lnColumns = ALEN(ar_detail, 1)
 WITH owOrksheet1
      IF M.tlEnhcolumn .AND. M.tnRecords>0
           lnRow = 1
           lnRowto = M.lnLastheadrow+M.tnRecords
           WITH .raNge(.ceLls(M.lnRow,1),.ceLls(M.lnRowto, ;
                M.lnColumns)).boRders(7)
                .liNestyle = 1
                .weIght = 2
                .coLorindex = -4105
           ENDWITH
           WITH .raNge(.ceLls(M.lnRow,1),.ceLls(M.lnRowto, ;
                M.lnColumns)).boRders(8)
                .liNestyle = 1
                .weIght = 2
                .coLorindex = -4105
           ENDWITH
           WITH .raNge(.ceLls(M.lnRow,1),.ceLls(M.lnRowto, ;
                M.lnColumns)).boRders(9)
                .liNestyle = 1
                .weIght = 2
                .coLorindex = -4105
           ENDWITH
           WITH .raNge(.ceLls(M.lnRow,1),.ceLls(M.lnRowto, ;
                M.lnColumns)).boRders(10)
                .liNestyle = 1
                .weIght = 2
                .coLorindex = -4105
           ENDWITH
           IF M.lnColumns>1
                WITH .raNge(.ceLls(M.lnRow,1),.ceLls(M.lnRowto, ;
                     M.lnColumns)).boRders(11)
                     .liNestyle = 1
                     .weIght = 2
                     .coLorindex = -4105
                ENDWITH
           ENDIF
           IF M.lnRowto>M.lnRow
                WITH .raNge(.ceLls(M.lnRow,1),.ceLls(M.lnRowto, ;
                     M.lnColumns)).boRders(12)
                     .liNestyle = 1
                     .weIght = 2
                     .coLorindex = -4105
                ENDWITH
           ENDIF
           lnRow = 2
           LOCAL lnPosstart, lnPosend, lcPict, lcNumbformat, lnDecimals
           FOR i = 1 TO M.lnColumns
                lnColumn = INT(VAL(woRdnum(ar_detail(M.i,1),2,"_")))
                WITH .raNge(.ceLls(M.lnRow,M.lnColumn),.ceLls(M.lnRowto, ;
                     M.lnColumn))
                     IF "9"$ar_detail(M.i,17)
                          lnPosstart = AT("9", ar_detail(M.i,17))
                          lnPosend = RAT("9", ar_detail(M.i,17))
                          IF M.lnPosstart>0 .AND. M.lnPosend>=M.lnPosstart
                               lcPict = SUBSTR(ar_detail(M.i,17),  ;
                                        lnPosstart, M.lnPosend-M.lnPosstart+1)
                               lcNumbformat = "0"
                               IF ","$M.lcPict
                                    lcNumbformat = "#,##"+M.lcNumbformat
                               ENDIF
                               lnPosstart = RAT(".", M.lcPict)
                               IF M.lnPosstart>0
                                    lnDecimals = LEN(M.lcPict)-M.lnPosstart
                                    IF M.lnDecimals>0
                                         lcNumbformat = M.lcNumbformat+ ;
                                          "."+REPLICATE("0", M.lnDecimals)
                                         .nuMberformat = M.lcNumbformat
                                    ENDIF
                               ENDIF
                          ENDIF
                     ENDIF
                     IF  .NOT. EMPTY(ar_detail(M.i,14))
                          .foNt.naMe = ar_detail(M.i,14)
                     ENDIF
                     IF  .NOT. EMPTY(ar_detail(M.i,15))
                          .foNt.siZe = ar_detail(M.i,15)
                     ENDIF
                     IF INLIST(ar_detail(M.i,16), 3, 1)
                          .foNt.boLd = .T.
                     ENDIF
                     IF INLIST(ar_detail(M.i,16), 3, 2)
                          .foNt.itAlic = .T.
                     ENDIF
                     IF M.tnPlatform="WIN"
                          .foNt.coLor = geTobjpencolor(ar_detail(M.i,18))
                          .inTerior.coLor = geTobjfillcolor(ar_detail(M.i, ;
                           18),ar_detail(M.i,3))
                     ENDIF
                     DO CASE
                          CASE "J"$ar_detail(M.i,17) .OR. ar_detail(M.i, ;
                               19)=1 .OR. INLIST(ar_detail(M.i,4), "N", "I")
                               .hoRizontalalignment = -4152
                          CASE "I"$ar_detail(M.i,17) .OR. ar_detail(M.i,19)=2
                               .hoRizontalalignment = -4108
                          OTHERWISE
                               .hoRizontalalignment = -4131
                     ENDCASE
                     .veRticalalignment = -4160
                ENDWITH
                IF M.tnPlatform="WIN"
                     lnPointsperchar = .coLumns(M.lnColumn).wiDth/ ;
                                       .coLumns(M.lnColumn).coLumnwidth
                     .coLumns(M.lnColumn).coLumnwidth =  ;
                             CEILING(oeXcel.inChestopoints(ar_detail(M.i, ;
                             12)/10000)/M.lnPointsperchar)
                ELSE
                     .coLumns(M.lnColumn).coLumnwidth = ar_detail(M.i,12)
                ENDIF
                IF ar_detail(M.i,13)
                     .raNge(.ceLls(M.lnRow,M.lnColumn), .ceLls(M.lnRowto, ;
                           M.lnColumn)).wrAptext = .T.
                ENDIF
           ENDFOR
      ENDIF
      LOCAL lnHpoz, j
      IF M.tlEnhheader .AND. ALEN(ar_header)>1
           FOR j = 1 TO M.lnColumns
                .raNge(.ceLls(1,M.j), .ceLls(1,M.j)).vaLue = ""
           ENDFOR
           LOCAL lnHeadobjects
           lnHeadobjects = ALEN(ar_header, 1)
           FOR i = 1 TO M.lnHeadobjects
                lnHpoz = ar_header(M.i,6)+ar_header(M.i,12)/2
                lnColumn = 0
                FOR j = 1 TO M.lnColumns
                     IF BETWEEN(M.lnHpoz, ar_detail(M.j,6), ar_detail(M.j, ;
                        6)+ar_detail(M.j,12))
                          lnColumn = INT(VAL(woRdnum(ar_detail(M.j,1),2,"_")))
                          EXIT
                     ENDIF
                ENDFOR
                IF M.lnColumn=0
                     FOR j = 1 TO M.lnColumns
                          IF BETWEEN(M.lnHpoz, ar_detail(M.j,6)- ;
                             ar_detail(M.j,12)/2, ar_detail(M.j,6)+ ;
                             ar_detail(M.j,12)*1.5)
                               lnColumn = INT(VAL(woRdnum(ar_detail(M.j, ;
                                1),2,"_")))
                               EXIT
                          ENDIF
                     ENDFOR
                ENDIF
                IF M.lnColumn>0
                     WITH .raNge(.ceLls(1,M.lnColumn),.ceLls(1,M.lnColumn))
                          leValue = .vaLue
                          IF EMPTY(M.leValue) .OR. ISNULL(M.leValue)
                               .vaLue = anYtoc(EVALUATE(ar_header(M.i,2)))
                          ELSE
                               .vaLue = anYtoc(M.leValue)+SPACE(1)+ ;
                                        anYtoc(EVALUATE(ar_header(M.i,2)))
                          ENDIF
                          IF  .NOT. EMPTY(ar_header(M.i,14))
                               .foNt.naMe = ar_header(M.i,14)
                          ENDIF
                          IF  .NOT. EMPTY(ar_header(M.i,15))
                               .foNt.siZe = ar_header(M.i,15)
                          ENDIF
                          IF INLIST(ar_header(M.i,16), 3, 1)
                               .foNt.boLd = .T.
                          ENDIF
                          IF INLIST(ar_header(M.i,16), 3, 2)
                               .foNt.itAlic = .T.
                          ENDIF
                          IF M.tnPlatform="WIN"
                               .foNt.coLor = geTobjpencolor(ar_header(M.i,18))
                               .inTerior.coLor =  ;
                                geTobjfillcolor(ar_header(M.i,18), ;
                                ar_header(M.i,3))
                          ENDIF
                          .hoRizontalalignment = -4108
                          .veRticalalignment = -4108
                          .wrAptext = .T.
                          .shRinktofit = .T.
                     ENDWITH
                ENDIF
           ENDFOR
      ENDIF
      IF M.tlEnhtitle .AND. ALEN(ar_title)>1
           LOCAL lnTitleobjects, arR_rows[1], lnVpoz, lnRows, lnRow
           lnRows = 0
           STORE 0 TO arR_rows
           lnTitleobjects = ALEN(ar_title, 1)
           FOR i = 1 TO M.lnTitleobjects
                lnVpoz = ROUND(ar_title(M.i,5), -2)
                IF M.lnRows=0 .OR. ASCAN(arR_rows, M.lnVpoz)=0
                     lnRows = M.lnRows+1
                     DIMENSION arR_rows[M.lnRows]
                     arR_rows[M.lnRows] = M.lnVpoz
                     .roWs(1).enTirerow.inSert
                ENDIF
                = ASORT(arR_rows)
           ENDFOR
           FOR i = 1 TO M.lnTitleobjects
                lnVpoz = ROUND(ar_title(M.i,5), -2)
                lnRow = ASCAN(arR_rows, M.lnVpoz)
                IF M.lnRow>0
                     WITH .ceLls(M.lnRow,1)
                          leValue = .vaLue
                          IF EMPTY(M.leValue) .OR. ISNULL(M.leValue)
                               .vaLue = anYtoc(EVALUATE(ar_title(M.i,2)))
                          ELSE
                               .vaLue = anYtoc(M.leValue)+SPACE(1)+ ;
                                        anYtoc(EVALUATE(ar_title(M.i,2)))
                          ENDIF
                          IF  .NOT. EMPTY(ar_title(M.i,14))
                               .foNt.naMe = ar_title(M.i,14)
                          ENDIF
                          IF  .NOT. EMPTY(ar_title(M.i,15))
                               .foNt.siZe = ar_title(M.i,15)
                          ENDIF
                          IF INLIST(ar_title(M.i,16), 3, 1)
                               .foNt.boLd = .T.
                          ENDIF
                          IF INLIST(ar_title(M.i,16), 3, 2)
                               .foNt.itAlic = .T.
                          ENDIF
                          IF M.tnPlatform="WIN"
                               .foNt.coLor = geTobjpencolor(ar_title(M.i,18))
                               .inTerior.coLor =  ;
                                geTobjfillcolor(ar_title(M.i,18), ;
                                ar_title(M.i,3))
                          ENDIF
                          .veRticalalignment = -4108
                          .shRinktofit = .T.
                     ENDWITH
                ENDIF
           ENDFOR
           FOR i = 1 TO M.lnRows
                WITH .raNge(.ceLls(M.i,1),.ceLls(M.i,M.lnColumns))
                     .meRgecells = .T.
                ENDWITH
           ENDFOR
      ENDIF
      WITH .paGesetup
           .leFtheader = ""
           .ceNterheader = ""
           .riGhtheader = ""
           .leFtfooter = ""
           .ceNterfooter = ""
           .riGhtfooter = ""
           .prIntheadings = .F.
           .prIntgridlines = .F.
           .prIntcomments = -4142
           .ceNterhorizontally = .F.
           .ceNtervertically = .F.
           .drAft = .F.
           .paPersize = 9
           .fiRstpagenumber = -4105
           .orDer = 1
           .blAckandwhite = .F.
           .zoOm = 100
           .boTtommargin = oeXcel.ceNtimeterstopoints(1.17)
           .toPmargin = oeXcel.ceNtimeterstopoints(1.17)
           .riGhtmargin = oeXcel.ceNtimeterstopoints(0.8)
           tnPageleftmargin = M.tnPageleftmargin/10000
           IF M.tnPageleftmargin<=(0.31496062992126)
                tnPageleftmargin = 40/127
           ENDIF
           .leFtmargin = oeXcel.inChestopoints(M.tnPageleftmargin)
           DO CASE
                CASE M.tnPageorient=1
                     .orIentation = 1
                CASE M.tnPageorient=2
                     .orIentation = 2
           ENDCASE
      ENDWITH
 ENDWITH
 lnEnherror = -1
 tcTypefileout = UPPER(M.tcTypefileout)
 DO CASE
      CASE INLIST(M.tcTypefileout, "HTML", "DOC")
           tcExcelfileout = FORCEEXT(M.tcExcelfileout, "htm")
           = deLfile(M.tcExcelfileout)
           owOrkbook.saVeas(M.tcExcelfileout,44)
           owOrkbook.clOse
           oeXcel.quIt
           IF FILE(M.tcExcelfileout)
                IF INLIST(M.tcTypefileout, "DOC")
                     LOCAL owOrd, odOcument, lcFileout, lnWorderror
                     lcFileout = FORCEEXT(M.tcExcelfileout, "doc")
                     lcOldonerror = onError()
                     lnWorderror = 0
                     ON ERROR LNWORDERROR=ERROR()
                     owOrd = CREATEOBJECT("Word.Application")
                     ON ERROR &lcOldOnError
                     IF M.lnWorderror<>0
                          lnEnherror = M.lnWorderror
                          IF  .NOT. M.tlNomessages
                               = woRn_mesg("Can not open Word, error "+ ;
                                 as(M.lnWorderror),M.lcTitle)
                          ENDIF
                     ENDIF
                     IF isObject(M.owOrd)
                          IF  .NOT. M.tlNomessages
                               WAIT WINDOW NOCLEAR NOWAIT  ;
                                    'Word automotion, please wait'
                          ENDIF
                          = deLfile(M.lcFileout)
                          odOcument = owOrd.doCuments.opEn(M.tcExcelfileout)
                          IF isObject(odOcument)
                               owOrd.acTivewindow.viEw.tyPe = 3
                               WITH odOcument
                                    WITH .paGesetup
                                         DO CASE
                                              CASE M.tnPageorient=1
                                                   .orIentation = 0
                                                   .paGewidth =  ;
                                                    owOrd.ceNtimeterstopoints(21)
                                                   .paGeheight =  ;
                                                    owOrd.ceNtimeterstopoints(29.7)
                                              CASE M.tnPageorient=2
                                                   .orIentation = 1
                                                   .paGewidth =  ;
                                                    owOrd.ceNtimeterstopoints(29.7)
                                                   .paGeheight =  ;
                                                    owOrd.ceNtimeterstopoints(21)
                                         ENDCASE
                                         .toPmargin =  ;
                                          owOrd.ceNtimeterstopoints(1.17)
                                         .boTtommargin =  ;
                                          owOrd.ceNtimeterstopoints(1.17)
                                         .riGhtmargin =  ;
                                          owOrd.ceNtimeterstopoints(0.8)
                                         .heAderdistance =  ;
                                          owOrd.ceNtimeterstopoints(0.8)
                                         .foOterdistance =  ;
                                          owOrd.ceNtimeterstopoints(0.8)
                                         .leFtmargin =  ;
                                          owOrd.inChestopoints(M.tnPageleftmargin)
                                    ENDWITH
                                    .saVeas(M.lcFileout,0)
                                    .clOse
                               ENDWITH
                          ENDIF
                          owOrd.quIt
                          IF FILE(M.lcFileout)
                               lnEnherror = 0
                               = deLfile(M.tcExcelfileout)
                               tcExcelfileout = M.lcFileout
                          ENDIF
                     ENDIF
                ELSE
                     lnEnherror = 0
                ENDIF
           ENDIF
      OTHERWISE
           tcExcelfileout = FORCEEXT(M.tcExcelfileout, "xls")
           owOrkbook.saVeas(M.tcExcelfileout,-4143)
           owOrkbook.clOse
           oeXcel.quIt
           IF FILE(M.tcExcelfileout)
                lnEnherror = 0
           ENDIF
 ENDCASE
 IF  .NOT. M.tlNomessages
      WAIT CLEAR
 ENDIF
 SELECT (M.lnOldselect)
 RETURN M.lnEnherror
ENDFUNC
*
FUNCTION GetObjPenColor
 LPARAMETER tcArrayelement
 LOCAL lnRed, lnGreen, lnBlue, lcSep
 lcSep = ","
 lnRed = INT(VAL(woRdnum(M.tcArrayelement,1,M.lcSep)))
 lnGreen = INT(VAL(woRdnum(M.tcArrayelement,2,M.lcSep)))
 lnBlue = INT(VAL(woRdnum(M.tcArrayelement,3,M.lcSep)))
 RETURN rgBspec(M.lnRed,M.lnGreen,M.lnBlue)
ENDFUNC
*
FUNCTION GetObjFillColor
 LPARAMETER tcArrayelement, tnObjtype
 LOCAL lnRed, lnGreen, lnBlue, lcSep
 lcSep = ","
 lnRed = INT(VAL(woRdnum(M.tcArrayelement,4,M.lcSep)))
 lnGreen = INT(VAL(woRdnum(M.tcArrayelement,5,M.lcSep)))
 lnBlue = INT(VAL(woRdnum(M.tcArrayelement,6,M.lcSep)))
 IF (M.lnRed=0 .AND. M.lnGreen=0 .AND. M.lnBlue=0 .AND. M.tnObjtype=5)  ;
    .OR. (M.lnRed=-1 .AND. M.lnGreen=-1 .AND. M.lnBlue=-1)
      RETURN RGB(255, 255, 255)
 ELSE
      RETURN rgBspec(M.lnRed,M.lnGreen,M.lnBlue)
 ENDIF
ENDFUNC
*
FUNCTION RGBspec
 LPARAMETER tnRed, tnGreen, tnBlue
 RETURN RGB(IIF(M.tnRed>=0, M.tnRed, 0), IIF(M.tnGreen>=0, M.tnGreen, 0),  ;
        IIF(M.tnBlue>=0, M.tnBlue, 0))
ENDFUNC
*
