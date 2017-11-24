SET MEMOWIDTH TO 16000
lcFile = 'c:\avpsoft\njlv\dump2.backup'
IF !FILE(lcFile)
	MESSAGEBOX('Fail ei leidnud')
ENDIF

CREATE CURSOR tmpMemo(sql m)
APPEND BLANK

APPEND MEMO sql FROM (lcFile)

i = ATC('alter function',tmpMemo.sql)
IF i > 0
	lcString = MLINE(tmpMemo.sql,i) 
 	WAIT WINDOW STR(i,9) + '/'+STR(MEMLINES(tmpMemo.sql),9)+lcString 
	
ENDIF

text

FOR i = 1 TO MEMLINES(tmpMemo.sql)
	lcString = MLINE(tmpMemo.sql,i) 
 	WAIT WINDOW STR(i,9) + '/'+STR(MEMLINES(tmpMemo.sql),9)+lcString nowait
ENDFOR
endtext