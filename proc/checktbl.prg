USE buh60.pjx ALIAS tmpProj IN 0
SELECT tmpProj
SCAN 
	IF tmpProj.type = 'V' OR tmpProj.type = 'D' OR tmpProj.type = 'K' OR tmpProj.type = 'R'
		lcFile = ALLTRIM(MLINE(tmpProj.name,1))
		WAIT WINDOW lcFile nowait
		IF FILE(lcFile)
			USE (lcFile) IN 0 ALIAS tmp
			IF USED('tmp')
				WAIT WINDOW lcFile+': ok' nowait
			ELSE
				WAIT WINDOW lcFile+': not a table' TIMEOUT 20

			ENDIF
			USE IN tmp
		else
			WAIT WINDOW lcFile+': not found' TIMEOUT 10
		
		ENDIF
		
	endif

ENDSCAN

USE IN tmpProj