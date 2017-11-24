 LPARAMETER toObject, tcName, tvClass, tvClasslibrary
 LOCAL lcName, lcClass, lcClasslibrary, ooBject, lnCount
 LOCAL lnObjectrefindex, lnObjectrefcount, oeXistingobject
 IF TYPE("toObject")<>"O" .OR. ISNULL(toObject)
      RETURN .NULL.
 ENDIF
 lcName = IIF(TYPE("tcName")=="C", ALLTRIM(tcName), LOWER(SYS(2015)))
 oeXistingobject = .NULL.
 ooBject = .NULL.
 lcClasslibrary = ""
 DO CASE
      CASE TYPE("tvClass")=="O"
           ooBject = tvClass
           lcClass = LOWER(ooBject.clAss)
           lcClasslibrary = LOWER(ooBject.clAsslibrary)
           IF  .NOT. ISNULL(oeXistingobject) .AND.  ;
               LOWER(oeXistingobject.clAss)==lcClass .AND.  ;
               LOWER(oeXistingobject.clAsslibrary)==lcClasslibrary
                toObject.vrEsult = oeXistingobject
                RETURN toObject.vrEsult
           ENDIF
      CASE EMPTY(tvClass)
           ooBject = toObject
           lcClass = LOWER(ooBject.clAss)
           lcClasslibrary = LOWER(ooBject.clAsslibrary)
           IF  .NOT. ISNULL(oeXistingobject) .AND.  ;
               LOWER(oeXistingobject.clAss)==lcClass .AND.  ;
               LOWER(oeXistingobject.clAsslibrary)==lcClasslibrary
                toObject.vrEsult = oeXistingobject
                RETURN toObject.vrEsult
           ENDIF
      OTHERWISE
           lcClass = LOWER(ALLTRIM(tvClass))
           DO CASE
                CASE TYPE("tvClassLibrary")=="O"
                     lcClasslibrary = LOWER(tvClasslibrary.clAsslibrary)
                CASE TYPE("tvClassLibrary")=="C"
                     IF EMPTY(tvClasslibrary)
                          lcClasslibrary = LOWER(toObject.clAsslibrary)
                     ELSE
                          lcClasslibrary = LOWER(ALLTRIM(tvClasslibrary))
                          IF EMPTY(JUSTEXT(lcClasslibrary))
                               lcClasslibrary =  ;
                                LOWER(FORCEEXT(lcClasslibrary, "vcx"))
                          ENDIF
                          llClasslib = (JUSTEXT(lcClasslibrary)=="vcx")
                          IF  .NOT. "\"$lcClasslibrary
                               lcClasslibrary =  ;
                                LOWER(FORCEPATH(lcClasslibrary,  ;
                                JUSTPATH(toObject.clAsslibrary)))
                               IF  .NOT. FILE(lcClasslibrary) .AND.  ;
                                   VERSION(2)<>0
                                    lcClasslibrary =  ;
                                     LOWER(FORCEPATH(lcClasslibrary,  ;
                                     HOME()+"ffc\"))
                                    IF  .NOT. FILE(lcClasslibrary)
                                         lcClasslibrary =  ;
                                          LOWER(FULLPATH(JUSTFNAME(lcClasslibrary)))
                                    ENDIF
                               ENDIF
                          ENDIF
                          IF  .NOT. FILE(lcClasslibrary)
                               toObject.vrEsult = .NULL.
                               RETURN toObject.vrEsult
                          ENDIF
                     ENDIF
                OTHERWISE
                     lcClasslibrary = ""
           ENDCASE
           IF  .NOT. ISNULL(oeXistingobject) .AND.  ;
               LOWER(oeXistingobject.clAss)==lcClass .AND.  ;
               LOWER(oeXistingobject.clAsslibrary)==lcClasslibrary
                toObject.vrEsult = oeXistingobject
                RETURN toObject.vrEsult
           ENDIF
           ooBject = NEWOBJECT(lcClass, lcClasslibrary)
           IF TYPE("oObject")<>"O" .OR. ISNULL(ooBject)
                toObject.vrEsult = .NULL.
                RETURN toObject.vrEsult
           ENDIF
 ENDCASE
 DO CASE
      CASE EMPTY(lcName)
           toObject.vrEsult = ooBject
           RETURN toObject.vrEsult
      OTHERWISE
           IF  .NOT. toObject.adDproperty(lcName,ooBject)
                ooBject = .NULL.
           ENDIF
 ENDCASE
 IF ISNULL(ooBject)
      toObject.vrEsult = .NULL.
      RETURN toObject.vrEsult
 ENDIF
 IF PEMSTATUS(ooBject, "oHost", 5)
      ooBject.ohOst = toObject.ohOst
 ELSE
      ooBject.adDproperty("oHost",toObject.ohOst)
 ENDIF
 IF EMPTY(lcClasslibrary)
      lcClasslibrary = LOWER(ooBject.clAsslibrary)
 ENDIF
 lnObjectrefcount = toObject.noBjectrefcount
 lnObjectrefindex = lnObjectrefcount+1
 FOR lnCount = 1 TO lnObjectrefcount
      IF toObject.aoBjectrefs(lnCount,1)==LOWER(lcName)
           lnObjectrefindex = lnCount
           EXIT
      ENDIF
 ENDFOR
 IF lnObjectrefindex>lnObjectrefcount
      DIMENSION toObject.aoBjectrefs[lnObjectrefindex, 3]
 ENDIF
 toObject.aoBjectrefs[lnObjectrefindex, 1] = LOWER(lcName)
 toObject.aoBjectrefs[lnObjectrefindex, 2] = lcClass
 toObject.aoBjectrefs[lnObjectrefindex, 3] = lcClasslibrary
 toObject.vrEsult = ooBject
 RETURN toObject.vrEsult
ENDFUNC
*
