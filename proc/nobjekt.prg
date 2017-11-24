 PARAMETER ckLass, cvAr, cpArameter, ccLasslib, ldAta
 IF EMPTY(cvAr)
      &cKlass
      RETURN
 ENDIF
 ccLasslib = IIF(EMPTY(ccLasslib), ckLass, ccLasslib)
 LOCAL ooBject
 IF  .NOT. EMPTY(ckLass)
      IF  .NOT. EMPTY(cvAr)
           crEsult = EVALUATE('vartype('+cvAr+')')
      ELSE
           crEsult = 'U'
      ENDIF
      IF crEsult<>'O'
           SET CLASSLIB TO (ccLasslib)
           IF EMPTY(cpArameter)
                ooBject = CREATEOBJECT(ckLass)
           ELSE
                ooBject = CREATEOBJECT(ckLass, cpArameter)
           ENDIF
           ooBject.trAnslate()
      ELSE
           cvAr = ALLTRIM(cvAr)
           oObject = &cVar
      ENDIF
      ooBject.shOw()
      IF  .NOT. ocOnnect.chKmenu(ckLass)
           ooBject = .NULL.
           RETURN .F.
      ENDIF
      IF EMPTY(ldAta)
           ooBject.reQuery()
      ENDIF
 ENDIF
 RETURN ooBject
ENDFUNC
*
