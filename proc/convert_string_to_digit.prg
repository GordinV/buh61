PARAMETERS tcParams
LOCAL lcValue 
l_value = ''
l_letter = ''
FOR i = 1 TO LEN(tcParams)
	l_letter = SUBSTR(tcParams,i,1)
	IF ISDIGIT(l_letter)
		l_value = l_value + l_letter
	endif 
ENDFOR
RETURN l_value