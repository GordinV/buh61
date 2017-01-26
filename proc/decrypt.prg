 PARAMETER tcKey, tcPass
 IF  .NOT. USED('config')
      USE config IN 0
 ENDIF
 IF coNfig.enCr=0
      RETURN tcPass
 ENDIF
 LOCAL lhKeyhandle, lhExchangekeyhandle
 LOCAL lcSavetext
 LOCAL lpRoviderhandle, lcProvidername, lcContainername
 SET CLASSLIB TO classes\crypapi
 ocRypt = CREATEOBJECT('crypapi')
 WITH ocRypt
      lcProvidername = ''
      lcContainername = ''
      lhProviderhandle = 0
      .crEatecryptkeys(lcContainername,lcProvidername,1)
      IF .geTlastapierror()<>0
           MESSAGEBOX('CSP could not be found or'+CHR(13)+CHR(10)+ ;
                     'Failed to Create Key Container or'+CHR(13)+CHR(10)+ ;
                     'Failed to Create Keys in CSP Container',  ;
                     mb_applmodal+mb_iconexclamation+mb_ok, 'Error')
           RETURN .F.
      ENDIF
      .crYptacquirecontext(@lhProviderhandle,lcContainername, ;
                          lcProvidername,1,0)
      lhKeyhandle = 0
      lhExchangekeyhandle = 0
      lcSavetext = ''
      .geTcryptsessionkeyhandle(lhProviderhandle,@lhKeyhandle,'S',RTRIM(tcKey))
      IF lhKeyhandle<>0
           lcSavetext = .deCryptstr(tcPass,lhKeyhandle,.T.)
           IF .geTlastapierror()=0
                lcSavetext = STRTRAN(lcSavetext, CHR(0), 'CHR(0)')
           ENDIF
           .reLeasecryptkeyhandle(lhKeyhandle)
      ENDIF
 ENDWITH
 RELEASE ocRypt
 RETURN lcSavetext
ENDFUNC
*
