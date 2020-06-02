IF !USED('key_')
	USE key_ IN 0
ENDIF

CREATE CURSOR tmpkey (id int, tyyp m, algus m, lopp m, uhenda m, versia m, omanik m, connect m, vfp m)


l_asutus = 'RAHANDUS 2019'

l_encripted = encrypt(f_key(), l_asutus)
WAIT WINDOW l_encripted      

_clptext = l_encripted 
INSERT INTO tmpkey (id, tyyp, algus, lopp, uhenda, versia, omanik, connect, vfp);
	values (key_.id, key_.tyyp, key_.algus, key_.lopp, key_.uhenda, key_.versia, key_.omanik, key_.connect, key_.vfp)

USE IN key_
* asutus



USE IN tmpkey

FUNCTION f_key
 LOCAL csTring
 csTring = CHR(107)+CHR(97)+CHR(116)+CHR(97)+CHR(109)+CHR(97)+CHR(114)+ ;
           CHR(97)+CHR(110)+CHR(32)+CHR(116)+CHR(105)+CHR(107)+CHR(105)+ ;
           CHR(50)+CHR(54)
 RETURN csTring
ENDFUNC
*
FUNCTION decrypt
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
