PARAMETERS tnId
LOCAL lError
SELECT curMenuRemote
IF ORDER()<> 'ID'
	SET ORDER TO id
ENDIF
LOCATE FOR id = tnId
 
IF FOUND() AND !EMPTY(curMenuRemote.proc_)
	lError =EXECSCRIPT(curMenuRemote.proc_)
ENDIF
RETURN lError