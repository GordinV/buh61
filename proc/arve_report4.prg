 PARAMETER tnId
 cqUery = 'queries\'+TRIM(qrYprint1.prOcfail)
 DO (cqUery) WITH ALLTRIM(STR(tnId))
 FOR i = 1 TO cuRprintresult.koGus
      crEport = 'reports\'+TRIM(qrYprint1.rePortfail)
      report form &cReport to print	
 ENDFOR
ENDPROC
