gnHandle = SQLCONNECT('narvalvpg')

IF gnHandle < 1
	MESSAGEBOX('Viga, uhendus')
	return
ENDIF

tnRekvId = 29

lcString = "select * from tooleping where rekvid = "+STR(tnRekvId,9) + " order by parentid, lopp desc "

lError = SQLEXEC(gnHandle,lcString,'qryTooleping')
SELECT qryTooleping
brow
IF lError < 0 OR !USED('qryTooleping')
	MESSAGEBOX('error, qryTool')
	return
ENDIF

SELECT id, osakondid, ametid, parentid FROM qryTooleping WHERE EMPTY(lopp) OR ISNULL(lopp) INTO CURSOR uusleping 
SELECT uusleping
brow

SELECT qryTooleping
SCAN FOR !EMPTY(qryTooleping.lopp)
*	WAIT WINDOW 'Arvestan :'+ALLTRIM(STR(RECNO('qryTooleping')))+'/'+ALLTRIM(STR(RECCOUNT('qryTooleping'))) nowait
	* otsime uus leping
	SELECT uusleping
	LOCATE FOR osakondid = qryTooleping.osakondId AND ametId = qryTooleping.ametid AND parentid =qryTooleping.parentid  AND id <> qryTooleping.id
	IF FOUND()
		WAIT WINDOW 'Leidsin, parandan' nowait
		lnUusLepingId = uusleping.id
		lnVanaLepingId = qryTooleping.id
		
		lcString = "update palk_kaart set lepingid = "+ALLTRIM(STR(lnUusLepingId,9)) + " where lepingId = "+ALLTRIM(STR(lnVanaLepingId,9))
		_cliptext = lcString
		lError = SQLEXEC(gnHandle,lcString)
		IF lError < 0
			
			MESSAGEBOX('Viga,update')
			SET STEP on
			exit
		ENDIF
		
	ENDIF			
ENDSCAN

=SQLDISCONNECT(gnHandle)


