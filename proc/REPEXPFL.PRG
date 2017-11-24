**
** repexpfl.fxp
**
*
FUNCTION RepExpFl
 PARAMETER tcRepfile, tcClauses, tcTofile, tcTofiletype, tlSummary,  ;
           tnGroupsummary, tlForcedospart, tlEnhcolumn, tlEnhheader,  ;
           tlEnhtitle, tlEnhsummary, tlNomessages, tcProgressfuncs,  ;
           tcProgrtitle, tnProgrincrement
 IF EMPTY(M.tnGroupsummary)
      tnGroupsummary = 0
 ENDIF
 PRIVATE lnOldrecmain, lnMainalias, lnRepalias
 lnMainalias = SELECT()
 lnOldrecmain = reCno1()
 lnRepalias = SYS(2015)
 SELECT 0
 USE NOUPDATE (M.tcRepfile) AGAIN ALIAS (M.lnRepalias)
 IF  .NOT. USED()
      SELECT (M.lnMainalias)
      RETURN 2
 ENDIF
 IF _DOS .OR. M.tlForcedospart
      SET FILTER TO plAtform='DOS'
 ELSE
      SET FILTER TO plAtform='WINDOWS'
 ENDIF
 GOTO TOP
 IF EOF()
      SET FILTER TO plAtform='DOS'
      GOTO TOP
 ENDIF
 PRIVATE pcPlatform
 pcPlatform = PADR(plAtform, 3)
 PRIVATE pnMaxdisplrow
 pnMaxdisplrow = 6
 PRIVATE lnPageorient, lnLeftmargin
 lnPageorient = 0
 lnLeftmargin = 0
 LOCATE FOR obJtype=1 .AND. obJcode=53
 IF FOUND() .AND. LEN(taG2)>45
      lnPageorient = ASC(SUBSTR(taG2, 45, 1))
      lnLeftmargin = hpOs
 ENDIF
 PRIVATE plReplacevalues
 plReplacevalues = .T.
 PRIVATE pnBandobjtype
 pnBandobjtype = 9
 PRIVATE lnVarobjtype
 lnVarobjtype = 18
 PRIVATE pnDetailband, pnHeaderband, pnTitleband, pnFooterband
 pnTitleband = 0
 pnHeaderband = 1
 pnGrheaderband = 3
 pnDetailband = 4
 pnGrfooterband = 5
 pnFooterband = 7
 pnSummaryband = 8
 PRIVATE pnDettype1, pnDettype2
 pnDettype1 = 5
 pnDettype2 = 8
 PRIVATE pnRestot1gr
 IF M.pcPlatform="DOS"
      pnRestot1gr = 3
 ELSE
      pnRestot1gr = 6
 ENDIF
 PRIVATE lcVarname, lnRepvars, ar_vars
 lnRepvars = 0
 SELECT (M.lnRepalias)
 SCAN FOR obJtype=M.lnVarobjtype
      lnRepvars = M.lnRepvars+1
      lcVarname = ALLTRIM(naMe)
      IF "m."=LOWER(PADR(M.lcVarname, 2)) .AND. LEN(M.lcVarname)>2
           lcVarname = SUBSTR(M.lcVarname, 3)
      ENDIF
      IF  .NOT. EMPTY(M.lcVarname)
           DIMENSION ar_vars[M.lnRepvars, 7]
           PRIVATE &lcVarName
           SELECT (M.lnMainalias)
           &lcVarName = EVALUATE( &lnRepAlias..Tag )	
           ar_vars[M.lnRepvars, 1] = M.lcVarname
           ar_Vars[m.lnRepVars,2] = ALLTRIM(&lnRepAlias..Expr)	
           ar_Vars[m.lnRepVars,3] = &lnRepAlias..TotalType		
           ar_Vars[m.lnRepVars,4] = &lnRepAlias..ResetTotal	
           ar_vars[M.lnRepvars, 5] = 0
           ar_vars[M.lnRepvars, 6] = 0
           ar_vars[M.lnRepvars, 7] = 0
      ENDIF
      SELECT (M.lnRepalias)
 ENDSCAN
 PRIVATE lnDetobjects, ar_detail, ar_detstruct, lnVposmin, lnVposmax, i
 DIMENSION ar_detail[1], ar_detstruct[1]
 STORE 0 TO lnVposmin, lnVposmax
 = geTvdiapason(M.lnRepalias,M.pnDetailband,@M.lnVposmin,@M.lnVposmax,0)
 lnDetobjects = geTbandobjects(M.lnRepalias,M.lnVposmin,M.lnVposmax,@ar_detail)
 = crEstructarray(M.lnDetobjects,@ar_detail,@ar_detstruct,'Col_')
 FOR i = 1 TO M.lnDetobjects
      PRIVATE &ar_Detail[m.i,1]
      &ar_Detail[m.i,1] = ""
 ENDFOR
 PRIVATE lnSummobjects, ar_summary, ar_summstruct
 DIMENSION ar_summary[1], ar_summstruct[1]
 = geTvdiapason(M.lnRepalias,M.pnSummaryband,@M.lnVposmin,@M.lnVposmax,0)
 lnSummobjects = geTbandobjects(M.lnRepalias,M.lnVposmin,M.lnVposmax, ;
                 @ar_summary)
 = crEstructarray(M.lnSummobjects,@ar_summary,@ar_summstruct,'Summ_')
 FOR i = 1 TO M.lnSummobjects
      PRIVATE &ar_Summary[m.i,1]
      &ar_Summary[m.i,1] = ""
 ENDFOR
 PRIVATE ar_header
 DIMENSION ar_header[1]
 IF M.tlEnhheader
      PRIVATE lnHeadobjects, ar_headstruct, lnVminheader, lnVmaxheader
      STORE 0 TO lnVminheader, lnVmaxheader
      DIMENSION ar_headstruct[1]
      = geTvdiapason(M.lnRepalias,M.pnHeaderband,@M.lnVminheader, ;
        @M.lnVmaxheader,0)
      lnHeadobjects = geTbandobjects(M.lnRepalias,M.lnVminheader, ;
                      M.lnVmaxheader,@ar_header)
      = crEstructarray(M.lnHeadobjects,@ar_header,@ar_headstruct,'Head_')
      FOR i = 1 TO M.lnHeadobjects
           PRIVATE &ar_Header[m.i,1]
           &ar_Header[m.i,1] = ""
      ENDFOR
 ENDIF
 PRIVATE ar_title
 DIMENSION ar_title[1]
 IF M.tlEnhtitle
      PRIVATE lnTitlobjects, ar_titlstruct, lnVmintitle, lnVmaxtitle
      STORE 0 TO lnVmintitle, lnVmaxtitle
      DIMENSION ar_titlstruct[1]
      = geTvdiapason(M.lnRepalias,M.pnTitleband,@M.lnVmintitle, ;
        @M.lnVmaxtitle,0)
      lnTitlobjects = geTbandobjects(M.lnRepalias,M.lnVmintitle, ;
                      M.lnVmaxtitle,@ar_title)
      = crEstructarray(M.lnTitlobjects,@ar_title,@ar_titlstruct,'Titl_')
      FOR i = 1 TO M.lnTitlobjects
           PRIVATE &ar_Title[m.i,1]
           &ar_Title[m.i,1] = ""
      ENDFOR
 ENDIF
 PRIVATE pnGroups, ar_groups
 pnGroups = 0
 SELECT (M.lnRepalias)
 SCAN FOR obJtype=M.pnBandobjtype .AND. obJcode=M.pnGrheaderband .AND.   ;
      .NOT. EMPTY(exPr)
      pnGroups = M.pnGroups+1
      DIMENSION ar_groups[M.pnGroups, 5]
      ar_groups[M.pnGroups, 1] = ALLTRIM(exPr)
      SELECT (M.lnMainalias)
      ar_groups[M.pnGroups, 4] = nuLlinit(EVALUATE(ar_groups(M.pnGroups,1)))
      SELECT (M.lnRepalias)
      ar_groups[M.pnGroups, 5] = .F.
 ENDSCAN
 PRIVATE lcGrp, j, lcTemp
 FOR j = 1 TO M.pnGroups
      lcGrp = as(M.j)
      PRIVATE ar_GrH&lcGrp, ar_GrHs&lcGrp
      DIMENSION ar_GrH&lcGrp[1], ar_GrHs&lcGrp[1]
      = geTvdiapason(M.lnRepalias,M.pnGrheaderband,@M.lnVposmin, ;
        @M.lnVposmax,M.j)
      ar_Groups[m.j,2] = GetBandObjects( m.lnRepAlias, m.lnVposMin, m.lnVposMax, @ar_GrH&lcGrp )
      =CreStructArray( ar_Groups[m.j,2], @ar_GrH&lcGrp, @ar_GrHs&lcGrp, "Gh"+m.lcGrp+"_" )
      FOR i = 1 TO ar_groups(M.j,2)
           lcTemp = ar_GrH&lcGrp[m.i,1]
           PRIVATE &lcTemp
           &lcTemp = ""
      ENDFOR
      PRIVATE ar_GrF&lcGrp, ar_GrFs&lcGrp
      DIMENSION ar_GrF&lcGrp[1], ar_GrFs&lcGrp[1]
      = geTvdiapason(M.lnRepalias,M.pnGrfooterband,@M.lnVposmin, ;
        @M.lnVposmax,M.j)
      ar_Groups[m.j,3] = GetBandObjects( m.lnRepAlias, m.lnVposMin, m.lnVposMax, @ar_GrF&lcGrp )
      =CreStructArray( ar_Groups[m.j,3], @ar_GrF&lcGrp, @ar_GrFs&lcGrp, "Gf"+m.lcGrp+"_" )
      FOR i = 1 TO ar_groups(M.j,3)
           lcTemp = ar_GrF&lcGrp[m.i,1]
           PRIVATE &lcTemp
           &lcTemp = ""
      ENDFOR
 ENDFOR
 SELECT (M.lnRepalias)
 USE
 IF M.lnDetobjects=0
      IF  .NOT. M.tlSummary .AND. M.tnGroupsummary=0
           tnGroupsummary = M.pnGroups
      ENDIF
      tlSummary = .T.
 ENDIF
 PRIVATE lcGroupsummary
 IF M.tlSummary .AND. M.pnGroups>0 .AND. M.tnGroupsummary>0 .AND.  .NOT.  ;
    BETWEEN(M.tnGroupsummary, 1, M.pnGroups)
      tnGroupsummary = M.pnGroups
 ENDIF
 IF M.tlSummary .AND. M.pnGroups=0 .AND. M.tnGroupsummary>0
      tnGroupsummary = 0
 ENDIF
 lcGroupsummary = as(M.tnGroupsummary)
 PRIVATE pcCursname, lnCurscreerror, pcArractstr, pcArract
 pcCursname = SYS(2015)
 lnCurscreerror = 1
 pcArractstr = ""
 DO CASE
      CASE M.lnDetobjects>0 .AND.  .NOT. M.tlSummary
           pcArractstr = 'ar_DetStruct'
           pcArract = 'ar_Detail'
      CASE M.lnSummobjects>0 .AND. M.tnGroupsummary=0 .AND. M.tlSummary
           pcArractstr = 'ar_SummStruct'
           pcArract = 'ar_Summary'
      CASE M.pnGroups>0 .AND. M.tnGroupsummary>0 .AND.  ;
           ar_groups(M.tnGroupsummary,3)>0
           pcArractstr = 'ar_GrFs'+M.lcGroupsummary
           pcArract = 'ar_GrF'+M.lcGroupsummary
      CASE M.pnGroups>0 .AND. M.tnGroupsummary>0 .AND.  ;
           ar_groups(M.tnGroupsummary,2)>0
           pcArractstr = 'ar_GrHs'+M.lcGroupsummary
           pcArract = 'ar_GrH'+M.lcGroupsummary
 ENDCASE
 IF  .NOT. EMPTY(M.pcArractstr)
      lnCursCreError = CreTabl1( '', @&pcArrActStr, 0, m.pcCursName )
 ENDIF
 IF M.lnCurscreerror<>0
      SELECT (M.lnMainalias)
      RETURN M.lnCurscreerror
 ENDIF
 PRIVATE n1, llAppend, leGroupvalue, lnRecsprocessed, lnRecsadded,  ;
         lnResettotal, lnGroupreset, leValue, lnAverage
 STORE 0 TO lnRecsprocessed, lnRecsadded
 SELECT (M.lnMainalias)
 PRIVATE lnRecstotal, lnRecordoriginal
 lnRecordoriginal = reCno1()
 COUNT &tcClauses TO lnRecsTotal
 PRIVATE llUseprogress, lnError, lcOldonerr
 lcOldonerr = onError()
 llUseprogress = .F.
 IF  .NOT. EMPTY(M.tcProgressfuncs)
      PRIVATE lcSep, lcProgresskey
      lcSep = ","
      IF woRds(M.tcProgressfuncs,M.lcSep)=3
           PRIVATE lcProgrinitfunc, lcProgrupdatefunc, lcProgrreleasefunc
           lcProgrinitfunc = woRdnum(M.tcProgressfuncs,1,M.lcSep)
           lcProgrupdatefunc = woRdnum(M.tcProgressfuncs,2,M.lcSep)
           lcProgrreleasefunc = woRdnum(M.tcProgressfuncs,3,M.lcSep)
           lcProgresskey = "RepExp"
           lnError = 0
           ON ERROR LNERROR=ERROR()
           =&lcProgrInitFunc( m.lcProgressKey, m.tcProgrTitle, "Scanning", 0, m.lnRecsTotal, m.tnProgrIncrement, .f.)
           ON ERROR &lcOldOnERR
           llUseprogress = (M.lnError=0)
      ENDIF
 ENDIF
 = go1(M.lnRecordoriginal)
 SCAN &tcClauses
      lnRecsprocessed = M.lnRecsprocessed+1
      IF M.llUseprogress
           =&lcProgrUpdateFunc( m.lcProgressKey, m.lnRecsProcessed, .t., "" )
      ENDIF
      FOR i = 1 TO M.pnGroups
           leGroupvalue = EVALUATE(ar_groups(M.i,1))
           ar_groups[M.i, 5] = ar_groups(M.i,4)<>M.leGroupvalue
           ar_groups[M.i, 4] = M.leGroupvalue
      ENDFOR
      IF M.lnRecsprocessed>1 .AND.  .NOT. (M.lnDetobjects>0 .AND.  .NOT.  ;
         M.tlSummary) .AND. (M.pnGroups>0 .AND. M.tnGroupsummary>0 .AND.  ;
         ar_groups(M.tnGroupsummary,3)>0)
           IF ar_groups(M.tnGroupsummary,5)
                IF apP_onerecord()=0
                     lnRecsadded = M.lnRecsadded+1
                ENDIF
           ENDIF
      ENDIF
      FOR M.n1 = 1 TO M.lnRepvars
           lcTemp = ar_vars(M.n1,1)
           lnResettotal = ar_vars(M.n1,4)
           IF M.lnResettotal>=M.pnRestot1gr
                lnGroupreset = M.lnResettotal-M.pnRestot1gr+1
                IF ar_groups(M.lnGroupreset,5)
                     ar_vars[M.n1, 5] = 0
                     ar_vars[M.n1, 6] = 0
                     ar_vars[M.n1, 7] = 0
                     &lcTemp = 0
                ENDIF
           ENDIF
           ar_vars[M.n1, 6] = ar_vars(M.n1,6)+1
           DO CASE
                CASE ar_vars(M.n1,3)=1
                     &lcTemp = m.&lcTemp + 1
                CASE ar_vars(M.n1,3)=2
                     &lcTemp = m.&lcTemp + EVALUATE(ar_Vars[m.n1,2])
                CASE ar_vars(M.n1,3)=3
                     ar_vars[M.n1, 5] = ar_vars(M.n1,5)+ ;
                            EVALUATE(ar_vars(M.n1,2))
                     &lcTemp = ar_Vars[m.n1,5] / ar_Vars[m.n1,6]
                CASE ar_vars(M.n1,3)=4
                     leValue = EVALUATE(ar_vars(M.n1,2))
                     IF ar_vars(M.n1,6)=1
                          &lcTemp = m.leValue
                     ELSE
                          IF m.leValue < m.&lcTemp
                               &lcTemp = m.leValue
                          ENDIF
                     ENDIF
                CASE ar_vars(M.n1,3)=5
                     leValue = EVALUATE(ar_vars(M.n1,2))
                     IF ar_vars(M.n1,6)=1
                          &lcTemp = m.leValue
                     ELSE
                          IF m.leValue > m.&lcTemp
                               &lcTemp = m.leValue
                          ENDIF
                     ENDIF
                CASE INLIST(ar_vars(M.n1,3), 6, 7)
                     leValue = EVALUATE(ar_vars(M.n1,2))
                     ar_vars[M.n1, 5] = ar_vars(M.n1,5)+M.leValue
                     ar_vars[M.n1, 7] = ar_vars(M.n1,7)+M.leValue*M.leValue
                     lnAverage = ar_vars(M.n1,5)/ar_vars(M.n1,6)
                     &lcTemp = ( ar_Vars[m.n1,7] - ar_Vars[m.n1,5]*m.lnAverage*2 ) / ar_Vars[m.n1,6] + m.lnAverage*m.lnAverage	
                     IF ar_vars(M.n1,3)=6
                          &lcTemp = SQRT( m.&lcTemp )	
                     ENDIF
                OTHERWISE
                     &lcTemp = EVALUATE(ar_Vars[m.n1,2])
           ENDCASE
      ENDFOR
      llAppend = .F.
      DO CASE
           CASE M.lnDetobjects>0 .AND.  .NOT. M.tlSummary
                llAppend = rpProcessojects(M.lnDetobjects,@ar_detail,0)
           CASE M.pnGroups>0 .AND. M.tnGroupsummary>0 .AND.  ;
                ar_groups(M.tnGroupsummary,3)>0
                =RpProcessOjects( ar_Groups[m.tnGroupSummary,3], @ar_GrF&lcGroupSummary, 0 )
           CASE M.pnGroups>0 .AND. M.tnGroupsummary>0 .AND.  ;
                ar_groups(M.tnGroupsummary,2)>0
                llAppend = RpProcessOjects( ar_Groups[m.tnGroupSummary,2], @ar_GrH&lcGroupSummary, 0 )
                IF M.llAppend .AND.  .NOT. ar_groups(M.tnGroupsummary,5)
                     llAppend = .F.
                ENDIF
      ENDCASE
      = rpProcessojects(M.lnSummobjects,@ar_summary,1)
      IF M.llAppend
           IF apP_onerecord()=0
                lnRecsadded = M.lnRecsadded+1
           ENDIF
      ENDIF
      SELECT (M.lnMainalias)
 ENDSCAN
 = rpProcessojects(M.lnSummobjects,@ar_summary,2)
 IF  .NOT. (M.lnDetobjects>0 .AND.  .NOT. M.tlSummary) .AND. ((M.pnGroups> ;
     0 .AND. M.tnGroupsummary>0 .AND. ar_groups(M.tnGroupsummary,3)>0)  ;
     .OR. (M.tnGroupsummary=0 .AND. M.tlSummary))
      IF apP_onerecord()=0
           lnRecsadded = M.lnRecsadded+1
      ENDIF
 ENDIF
 IF M.llUseprogress
      =&lcProgrReleaseFunc( m.lcProgressKey )
 ENDIF
 PRIVATE lcToclause
 lcToclause = woRdnum(M.tcTofiletype,1,"_")
 SELECT (M.pcCursname)
 lnError = 0
 ON ERROR LNERROR=ERROR()
 IF UPPER(PADR(M.tcTofiletype, 2))="XL"
      tcTofile = FORCEEXT(M.tcTofile, "xls")
 ENDIF
 COPY TO (m.tcToFile) &lcToClause
 ON ERROR &lcOldOnERR
 = clOse1(M.pcCursname)
 IF M.lnError=0 .AND. foXversion()>3
      PRIVATE lcFunc, tcTofile0, lcTypefileout
      lcTypefileout = woRdnum(M.tcTofiletype,2,"_")
      IF  .NOT. EMPTY(M.lcTypefileout)
           lcFunc = "RepEnhance"
           tcTofile0 = FORCEEXT(ADDBS(JUSTPATH(M.tcTofile))+ ;
                       JUSTSTEM(M.tcTofile)+"_tmp", JUSTEXT(M.tcTofile))
           IF reNfile(M.tcTofile,M.tcTofile0)
                IF &lcFunc( m.tcToFile0, @m.tcToFile, m.lcTypeFileOut, m.pcPlatform, m.tlEnhColumn, m.tlEnhHeader, m.tlEnhTitle, tlEnhSummary,  @&pcArrAct, @ar_Header, @ar_Title, @ar_Summary, m.lnRecsAdded, m.lnPageOrient, m.lnLeftMargin, m.tlNoMessages ) = 0
                     = deLfile(M.tcTofile0)
                ELSE
                     = reNfile(M.tcTofile0,M.tcTofile)
                ENDIF
           ENDIF
      ENDIF
 ENDIF
 SELECT (M.lnMainalias)
 = go1(M.lnOldrecmain)
 RETURN M.lnError
ENDFUNC
*
FUNCTION GetVdiapason
 PARAMETER tnRepalias, tnBand, tnVposmin, tnVposmax, tnGroup
 PRIVATE lnOldselect, llOk
 llOk = .T.
 lnOldselect = SELECT()
 SELECT (M.tnRepalias)
 PRIVATE lnDesignheight
 IF M.pcPlatform='DOS'
      lnDesignheight = 0
 ELSE
      lnDesignheight = 2083.333
 ENDIF
 STORE 0 TO tnVposmin, tnVposmax
 PRIVATE lnGroupcount, lnLastheightadded
 lnLastheightadded = 0
 lnGroupcount = 0
 IF M.tnBand=M.pnGrfooterband
      lnGroupcount = M.pnGroups+1
 ENDIF
 SCAN FOR obJtype=M.pnBandobjtype .AND. obJcode<=M.tnBand
      IF M.tnBand=M.pnGrheaderband .AND. obJcode=M.pnGrheaderband
           lnGroupcount = M.lnGroupcount+1
           IF M.lnGroupcount>M.tnGroup
                EXIT
           ENDIF
      ENDIF
      lnLastheightadded = heIght+M.lnDesignheight
      tnVposmax = M.tnVposmax+M.lnLastheightadded
      IF M.tnBand=M.pnGrfooterband .AND. obJcode=M.pnGrfooterband
           lnGroupcount = M.lnGroupcount-1
           IF M.lnGroupcount=M.tnGroup
                EXIT
           ENDIF
      ENDIF
 ENDSCAN
 tnVposmin = M.tnVposmax-M.lnLastheightadded
 tnVposmax = M.tnVposmax-1
 IF M.tnVposmin>=M.lnDesignheight
      tnVposmin = M.tnVposmin-M.lnDesignheight
      tnVposmax = M.tnVposmax-M.lnDesignheight
 ENDIF
 SELECT (M.lnOldselect)
 RETURN M.llOk
ENDFUNC
*
FUNCTION GetBandObjects
 PARAMETER tnRepalias, tnVposmin, tnVposmax, ar_detail
 PRIVATE lnOldselect
 lnOldselect = SELECT()
 SELECT (M.tnRepalias)
 PRIVATE lnDetobjects, leValue, lcExpr
 lnDetobjects = 0
 SCAN FOR INLIST(obJtype, M.pnDettype1, M.pnDettype2) .AND. BETWEEN(vpOs,  ;
      M.tnVposmin, M.tnVposmax)
      lcExpr = ALLTRIM(exPr)
      IF M.pcPlatform="DOS" .AND. obJtype=5 .AND. LEN(M.lcExpr)=3 .AND.  ;
         EVALUATE(M.lcExpr)$M.dw_dosgrph+"+-_|"
           LOOP
      ENDIF
      lnDetobjects = M.lnDetobjects+1
      DIMENSION ar_detail[M.lnDetobjects, 19]
      ar_detail[M.lnDetobjects, 1] = ""
      ar_detail[M.lnDetobjects, 2] = M.lcExpr
      ar_detail[M.lnDetobjects, 3] = obJtype
      IF obJtype=M.pnDettype2
           SELECT (M.lnMainalias)
           leValue = EVALUATE(ar_detail(M.lnDetobjects,2))
           ar_detail[M.lnDetobjects, 4] = VARTYPE(M.leValue)
           SELECT (M.tnRepalias)
      ELSE
           ar_detail[M.lnDetobjects, 4] = 'C'
      ENDIF
      ar_detail[M.lnDetobjects, 5] = vpOs
      ar_detail[M.lnDetobjects, 6] = hpOs
      ar_detail[M.lnDetobjects, 7] = toTaltype
      ar_detail[M.lnDetobjects, 8] = reSettotal
      ar_detail[M.lnDetobjects, 9] = 0
      ar_detail[M.lnDetobjects, 10] = 0
      ar_detail[M.lnDetobjects, 11] = 0
      ar_detail[M.lnDetobjects, 12] = wiDth
      ar_detail[M.lnDetobjects, 13] = stRetch
      ar_detail[M.lnDetobjects, 14] = foNtface
      ar_detail[M.lnDetobjects, 15] = foNtsize
      ar_detail[M.lnDetobjects, 16] = foNtstyle
      ar_detail[M.lnDetobjects, 17] = piCture
      ar_detail[M.lnDetobjects, 18] = as(peNred)+","+as(peNgreen)+","+ ;
               as(peNblue)+","+as(fiLlred)+","+as(fiLlgreen)+","+as(fiLlblue)
      ar_detail[M.lnDetobjects, 19] = ofFset
 ENDSCAN
 SELECT (M.lnOldselect)
 RETURN M.lnDetobjects
ENDFUNC
*
FUNCTION RpProcessOjects
 PARAMETER tnObjects, ar_band, tnTypecalc
 EXTERNAL ARRAY ar_band
 PRIVATE llOk, lcTemp, k1, lnTotaltype, lnResettotal, lnGroupreset,  ;
         leValue, lnAverage
 llOk = .T.
 FOR M.k1 = 1 TO M.tnObjects
      lcTemp = ar_band(M.k1,1)
      lnTotaltype = ar_band(M.k1,7)
      DO CASE
           CASE M.tnTypecalc=1 .AND. M.lnTotaltype=0
                LOOP
           CASE M.tnTypecalc=2 .AND. M.lnTotaltype>0
                LOOP
      ENDCASE
      lnResettotal = ar_band(M.k1,8)
      IF INLIST(ar_band(M.k1,3), M.pnDettype1, M.pnDettype2)
           IF M.lnResettotal>=M.pnRestot1gr
                lnGroupreset = M.lnResettotal-M.pnRestot1gr+1
                IF ar_groups(M.lnGroupreset,5)
                     ar_band[M.k1, 9] = 0
                     ar_band[M.k1, 10] = 0
                     ar_band[M.k1, 11] = 0
                     &lcTemp = 0
                ENDIF
           ENDIF
           ar_band[M.k1, 10] = ar_band(M.k1,10)+1
           DO CASE
                CASE M.lnTotaltype=1
                     IF TYPE(M.lcTemp)<>'N'
                          &lcTemp = 0
                     ENDIF
                     &lcTemp = m.&lcTemp + 1
                CASE M.lnTotaltype=2
                     IF TYPE(M.lcTemp)<>'N'
                          &lcTemp = 0
                     ENDIF
                     &lcTemp = m.&lcTemp + EVALUATE(ar_Band[m.k1,2])
                CASE M.lnTotaltype=3
                     ar_band[M.k1, 9] = ar_band(M.k1,9)+ ;
                            EVALUATE(ar_band(M.k1,2))
                     &lcTemp = ar_Band[m.k1,9] / ar_Band[m.k1,10]					
                CASE M.lnTotaltype=4
                     leValue = EVALUATE(ar_band(M.k1,2))
                     IF ar_band(M.k1,10)=1
                          &lcTemp = m.leValue
                     ELSE
                          IF m.leValue < m.&lcTemp
                               &lcTemp = m.leValue
                          ENDIF
                     ENDIF
                CASE M.lnTotaltype=5
                     leValue = EVALUATE(ar_band(M.k1,2))
                     IF ar_band(M.k1,10)=1
                          &lcTemp = m.leValue
                     ELSE
                          IF m.leValue > m.&lcTemp
                               &lcTemp = m.leValue
                          ENDIF
                     ENDIF
                CASE INLIST(M.lnTotaltype, 6, 7)
                     leValue = EVALUATE(ar_band(M.k1,2))
                     ar_band[M.k1, 9] = ar_band(M.k1,9)+M.leValue
                     ar_band[M.k1, 11] = ar_band(M.k1,11)+M.leValue*M.leValue
                     lnAverage = ar_band(M.k1,9)/ar_band(M.k1,10)
                     &lcTemp = ( ar_Band[m.k1,11] - ar_Band[m.k1,9]*m.lnAverage*2 ) / ar_Band[m.k1,10] + m.lnAverage*m.lnAverage	
                     IF M.lnTotaltype=6
                          &lcTemp = SQRT( m.&lcTemp )	
                     ENDIF
                OTHERWISE
                     &lcTemp = EVALUATE(ar_Band[m.k1,2])
           ENDCASE
           IF TYPE(M.lcTemp)='C' .AND. M.pcPlatform='DOS'
                &lcTemp = Dos_Win( m.&lcTemp )
           ENDIF
      ENDIF
 ENDFOR
 RETURN M.llOk
ENDFUNC
*
FUNCTION CreStructArray
 PARAMETER tnObjects, ar_band, ar_struct, tcNameprefix
 EXTERNAL ARRAY ar_band
 IF M.tnObjects<=0
      RETURN .F.
 ENDIF
 PRIVATE lnOldselect
 lnOldselect = SELECT()
 PRIVATE lcAliascurs, a_Cursstruct, i
 DIMENSION a_Cursstruct[2, 4]
 a_Cursstruct[1, 1] = 'Vpos'
 a_Cursstruct[1, 2] = 'N'
 a_Cursstruct[1, 3] = 9
 a_Cursstruct[1, 4] = 3
 a_Cursstruct[2, 1] = 'Hpos'
 a_Cursstruct[2, 2] = 'N'
 a_Cursstruct[2, 3] = 9
 a_Cursstruct[2, 4] = 3
 lcAliascurs = SYS(2015)
 IF crEtabl1('',@a_Cursstruct,0,M.lcAliascurs)<>0
      SELECT (M.lnOldselect)
      RETURN .F.
 ENDIF
 SELECT (M.lcAliascurs)
 INDEX ON STR(vpOs, 9, 3)+STR(hpOs, 9, 3) TAG cuRc1
 FOR M.i = 1 TO M.tnObjects
      APPEND BLANK
      REPLACE vpOs WITH ar_band(M.i,5)
      REPLACE hpOs WITH ar_band(M.i,6)
 ENDFOR
 PRIVATE k, lnDecimals, lnDigits, lnWidth
 DIMENSION ar_struct[M.tnObjects, 4]
 PRIVATE lnRepcharsize
 i = 0
 SCAN
      k = RECNO()
      i = M.i+1
      ar_band[M.k, 1] = M.tcNameprefix+as(M.i)
      ar_struct[M.i, 1] = ar_band(M.k,1)
      ar_struct[M.i, 2] = ar_band(M.k,4)
      IF M.pcPlatform='WIN'
           lnRepcharsize = (FONTMETRIC(6, ar_band(M.k,14), ar_band(M.k, ;
                           15), foNtstylen(ar_band(M.k,16)))/96)*10000
           lnWidth = CEILING(ar_band(M.k,12)/M.lnRepcharsize)
      ELSE
           lnWidth = ar_band(M.k,12)
      ENDIF
      ar_struct[M.i, 3] = 10
      ar_struct[M.i, 4] = 0
      lnWidth = INT(M.lnWidth)
      DO CASE
           CASE INLIST(ar_struct(M.i,2), 'D', 'T')
                ar_struct[M.i, 3] = 8
           CASE INLIST(ar_struct(M.i,2), 'C', 'M')
                ar_struct[M.i, 2] = 'C'
                IF  .NOT. ar_band(M.k,13)
                     ar_struct[M.i, 3] = M.lnWidth
                ELSE
                     ar_struct[M.i, 3] = MIN(254, INT(M.lnWidth* ;
                              M.pnMaxdisplrow))
                ENDIF
           CASE ar_struct(M.i,2)='N'
                lnDigits = 20
                lnDecimals = 6
                IF M.lnWidth+M.lnDecimals+IIF(M.lnDecimals=0, 0, 1)<=M.lnDigits
                     ar_struct[M.i, 3] = M.lnWidth+M.lnDecimals+ ;
                              IIF(M.lnDecimals=0, 0, 1)
                     ar_struct[M.i, 4] = M.lnDecimals
                ELSE
                     ar_struct[M.i, 3] = M.lnDigits
                     IF M.lnWidth>17
                          ar_struct[M.i, 4] = 2
                     ELSE
                          ar_struct[M.i, 4] = M.lnDigits-M.lnWidth-1
                     ENDIF
                ENDIF
      ENDCASE
 ENDSCAN
 USE
 SELECT (M.lnOldselect)
 RETURN .T.
ENDFUNC
*
FUNCTION App_OneRecord
 PRIVATE lnOldselect, lnError
 lnError = 0
 lnOldselect = SELECT()
 SELECT (M.pcCursname)
 APPEND BLANK
 IF M.plReplacevalues
      PRIVATE lnColumns, i, lcColvarname
      lnColumns = ALEN( &pcArrActStr, 1 )
      FOR i = 1 TO M.lnColumns
           lcColVarName = &pcArrActStr[m.i,1]
           REPLACE &lcColVarName WITH m.&lcColVarName
      ENDFOR
 ELSE
      GATHER MEMVAR
 ENDIF
 SELECT (M.lnOldselect)
 RETURN M.lnError
ENDFUNC
*
