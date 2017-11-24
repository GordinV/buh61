*
DEFINE CLASS heap AS custom
 PROTECTED inHandle, inNumallocsactive, iaAllocs[1, 3]
 inHandle = .NULL.
 inNumallocsactive = 0
 iaAllocs = .NULL.
 naMe = "heap"
*
     FUNCTION Alloc
      LPARAMETER nsIze
      DECLARE INTEGER HeapAlloc IN WIN32API AS HAlloc INTEGER, INTEGER, INTEGER
      DECLARE INTEGER HeapSize IN WIN32API AS HSize INTEGER, INTEGER, INTEGER
      LOCAL npTr
      WITH thIs
           npTr = haLloc(.inHandle,0,@nsIze)
           IF npTr<>0
                .inNumallocsactive = .inNumallocsactive+1
                DIMENSION .iaAllocs[.inNumallocsactive, 3]
                .iaAllocs[.inNumallocsactive, 1] = npTr
                .iaAllocs[.inNumallocsactive, 2] = hsIze(.inHandle,0,npTr)
                .iaAllocs[.inNumallocsactive, 3] = .T.
           ELSE
                npTr = .NULL.
           ENDIF
      ENDWITH
      RETURN npTr
     ENDFUNC
*
     FUNCTION AllocBLOB
      LPARAMETER cbStringtocopy
      LOCAL naLlocptr
      WITH thIs
           naLlocptr = .alLoc(LEN(cbStringtocopy))
           IF  .NOT. ISNULL(naLlocptr)
                .coPyto(naLlocptr,cbStringtocopy)
           ENDIF
      ENDWITH
      RETURN naLlocptr
     ENDFUNC
*
     FUNCTION AllocString
      LPARAMETER csTring
      RETURN thIs.alLocblob(csTring+CHR(0))
     ENDFUNC
*
     FUNCTION AllocInitAs
      LPARAMETER nsIzeofbuffer, nbYtevalue
      IF TYPE('nByteValue')<>'N' .OR.  .NOT. BETWEEN(nbYtevalue, 0, 255)
           nbYtevalue = 0
      ENDIF
      RETURN thIs.alLocblob(REPLICATE(CHR(nbYtevalue), nsIzeofbuffer))
     ENDFUNC
*
     FUNCTION DeAlloc
      LPARAMETER npTr
      DECLARE INTEGER HeapFree IN WIN32API AS HFree INTEGER, INTEGER, INTEGER
      LOCAL ncTr
      ncTr = .NULL.
      WITH thIs
           ncTr = .fiNdallocid(npTr)
           IF  .NOT. ISNULL(ncTr)
                = hfRee(.inHandle,0,npTr)
                .iaAllocs[ncTr, 3] = .F.
           ENDIF
      ENDWITH
      RETURN  .NOT. ISNULL(ncTr)
     ENDFUNC
*
     FUNCTION CopyTo
      LPARAMETER npTr, csOurce
      DECLARE RtlMoveMemory IN WIN32API AS RtlCopy INTEGER, STRING @, INTEGER
      LOCAL ncTr
      ncTr = .NULL.
      IF TYPE('nPtr')='N' .AND. TYPE('cSource')$'CM' .AND.  .NOT.  ;
         (ISNULL(npTr) .OR. ISNULL(csOurce))
           WITH thIs
                ncTr = .fiNdallocid(npTr)
                IF  .NOT. ISNULL(ncTr)
                     = rtLcopy((.iaAllocs(ncTr,1)),csOurce, ;
                       MIN(LEN(csOurce), .iaAllocs(ncTr,2)))
                ENDIF
           ENDWITH
      ENDIF
      RETURN  .NOT. ISNULL(ncTr)
     ENDFUNC
*
     FUNCTION CopyFrom
      LPARAMETER npTr
      DECLARE RtlMoveMemory IN WIN32API AS RtlCopy STRING @, INTEGER, INTEGER
      LOCAL ncTr, ubUffer
      ubUffer = .NULL.
      ncTr = .NULL.
      IF TYPE('nPtr')='N' .AND.  .NOT. ISNULL(npTr)
           WITH thIs
                ncTr = .fiNdallocid(npTr)
                IF  .NOT. ISNULL(ncTr)
                     ubUffer = REPLICATE(CHR(0), .iaAllocs(ncTr,2))
                     = rtLcopy(@ubUffer,(.iaAllocs(ncTr,1)), ;
                       (.iaAllocs(ncTr,2)))
                ENDIF
           ENDWITH
      ENDIF
      RETURN ubUffer
     ENDFUNC
*
     PROTECTED FUNCTION FindAllocID
      LPARAMETER npTr
      LOCAL ncTr
      WITH thIs
           FOR ncTr = 1 TO .inNumallocsactive
                IF .iaAllocs(ncTr,1)=npTr .AND. .iaAllocs(ncTr,3)
                     EXIT
                ENDIF
           ENDFOR
           RETURN IIF(ncTr<=.inNumallocsactive, ncTr, .NULL.)
      ENDWITH
     ENDFUNC
*
     FUNCTION SizeOfBlock
      LPARAMETER npTr
      LOCAL ncTr, nsIzeofblock
      nsIzeofblock = .NULL.
      WITH thIs
           ncTr = .fiNdallocid(npTr)
           RETURN IIF(ISNULL(ncTr), .NULL., .iaAllocs(ncTr,2))
      ENDWITH
     ENDFUNC
*
     PROCEDURE Destroy
      DECLARE HeapDestroy IN WIN32API AS HDestroy INTEGER
      LOCAL ncTr
      WITH thIs
           FOR ncTr = 1 TO .inNumallocsactive
                IF .iaAllocs(ncTr,3)
                     .deAlloc(.iaAllocs(ncTr,1))
                ENDIF
           ENDFOR
           hdEstroy(.inHandle)
      ENDWITH
      DODEFAULT()
     ENDPROC
*
     FUNCTION Init
      DECLARE INTEGER HeapCreate IN WIN32API AS HCreate INTEGER, INTEGER,  ;
              INTEGER
      WITH thIs
           .inHandle = hcReate(0,008192,0)
           DIMENSION .iaAllocs[1, 3]
           .iaAllocs[1, 1] = 0
           .iaAllocs[1, 2] = 0
           .iaAllocs[1, 3] = .F.
           .inNumallocsactive = 0
      ENDWITH
      RETURN (thIs.inHandle<>0)
     ENDFUNC
*
ENDDEFINE
*
FUNCTION SetMem
 LPARAMETER npTr, csOurce
 DECLARE RtlMoveMemory IN WIN32API AS RtlCopy INTEGER, STRING @, INTEGER
 rtLcopy(npTr,csOurce,LEN(csOurce))
 RETURN .T.
ENDFUNC
*
FUNCTION GetMem
 LPARAMETER npTr, nlEn
 DECLARE RtlMoveMemory IN WIN32API AS RtlCopy STRING @, INTEGER, INTEGER
 LOCAL ubUffer
 ubUffer = REPLICATE(CHR(0), nlEn)
 = rtLcopy(@ubUffer,npTr,nlEn)
 RETURN ubUffer
ENDFUNC
*
FUNCTION GetMemString
 LPARAMETER npTr, nsIze
 DECLARE INTEGER lstrcpyn IN WIN32API AS StrCpyN STRING @, INTEGER, INTEGER
 LOCAL ubUffer
 IF TYPE('nSize')<>'N' .OR. ISNULL(nsIze)
      nsIze = 512
 ENDIF
 ubUffer = REPLICATE(CHR(0), nsIze)
 IF stRcpyn(@ubUffer,npTr,nsIze-1)<>0
      ubUffer = LEFT(ubUffer, MAX(0, AT(CHR(0), ubUffer)-1))
 ELSE
      ubUffer = .NULL.
 ENDIF
 RETURN ubUffer
ENDFUNC
*
FUNCTION SHORTToNum
 LPARAMETER tcInt
 LOCAL b0, b1, nrEtval
 b0 = ASC(tcInt)
 b1 = ASC(SUBSTR(tcInt, 2, 1))
 IF b1<128
      nrEtval = b1*256+b0
 ELSE
      b1 = 255-b1
      b0 = 256-b0
      nrEtval = -((b1*256)+b0)
 ENDIF
 RETURN nrEtval
ENDFUNC
*
FUNCTION NumToSHORT
 LPARAMETER tnNum
 LOCAL b0, b1, x
 IF tnNum>=0
      x = INT(tnNum)
      b1 = INT(x/256)
      b0 = MOD(x, 256)
 ELSE
      x = INT(-tnNum)
      b1 = 255-INT(x/256)
      b0 = 256-MOD(x, 256)
      IF b0=256
           b0 = 0
           b1 = b1+1
      ENDIF
 ENDIF
 RETURN CHR(b0)+CHR(b1)
ENDFUNC
*
FUNCTION DWORDToNum
 LPARAMETER tcDword
 LOCAL b0, b1, b2, b3
 b0 = ASC(tcDword)
 b1 = ASC(SUBSTR(tcDword, 2, 1))
 b2 = ASC(SUBSTR(tcDword, 3, 1))
 b3 = ASC(SUBSTR(tcDword, 4, 1))
 RETURN (((b3*256+b2)*256+b1)*256+b0)
ENDFUNC
*
FUNCTION NumToDWORD
 LPARAMETER tnNum
 RETURN nuMtolong(tnNum)
ENDFUNC
*
FUNCTION WORDToNum
 LPARAMETER tcWord
 RETURN (256*ASC(SUBSTR(tcWord, 2, 1)))+ASC(tcWord)
ENDFUNC
*
FUNCTION NumToWORD
 LPARAMETER tnNum
 LOCAL x
 x = INT(tnNum)
 RETURN CHR(MOD(x, 256))+CHR(INT(x/256))
ENDFUNC
*
FUNCTION NumToLong
 LPARAMETER tnNum
 DECLARE RtlMoveMemory IN WIN32API AS RtlCopyLong STRING @, INTEGER @, INTEGER
 LOCAL csTring
 csTring = SPACE(4)
 = rtLcopylong(@csTring,BITOR(tnNum, 0),4)
 RETURN csTring
ENDFUNC
*
FUNCTION LongToNum
 LPARAMETER tcLong
 DECLARE RtlMoveMemory IN WIN32API AS RtlCopyLong INTEGER @, STRING @, INTEGER
 LOCAL nnUm
 nnUm = 0
 = rtLcopylong(@nnUm,tcLong,4)
 RETURN nnUm
ENDFUNC
*
FUNCTION AllocNetAPIBuffer
 LPARAMETER nsIze
 IF TYPE('nSize')<>'N' .OR. nsIze<=0
      RETURN .NULL.
 ENDIF
 IF  .NOT. 'NT'$OS()
      RETURN .NULL.
 ENDIF
 DECLARE INTEGER NetApiBufferAllocate IN NETAPI32.DLL INTEGER, INTEGER
 LOCAL nbUfferpointer
 nbUfferpointer = 0
 IF neTapibufferallocate(INT(nsIze),@nbUfferpointer)<>0
      nbUfferpointer = .NULL.
 ENDIF
 RETURN nbUfferpointer
ENDFUNC
*
FUNCTION DeAllocNetAPIBuffer
 LPARAMETER npTr
 IF TYPE('nPtr')<>'N'
      RETURN .F.
 ENDIF
 IF  .NOT. 'NT'$OS()
      RETURN .F.
 ENDIF
 DECLARE INTEGER NetApiBufferFree IN NETAPI32.DLL INTEGER
 RETURN (neTapibufferfree(INT(npTr))=0)
ENDFUNC
*
FUNCTION CopyDoubleToString
 LPARAMETER ndOubletocopy
 DECLARE RtlMoveMemory IN WIN32API AS RtlCopyDbl STRING @, DOUBLE @, INTEGER
 LOCAL csTring
 csTring = SPACE(8)
 = rtLcopydbl(@csTring,ndOubletocopy,8)
 RETURN csTring
ENDFUNC
*
FUNCTION DoubleToNum
 LPARAMETER cdOubleinstring
 DECLARE RtlMoveMemory IN WIN32API AS RtlCopyDbl DOUBLE @, STRING @, INTEGER
 LOCAL nnUm
 nnUm = 0.000000000000000000
 = rtLcopydbl(@nnUm,cdOubleinstring,8)
 RETURN nnUm
ENDFUNC
*
