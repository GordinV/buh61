LOCAL lnRekvid
lnRekvid = 0
*SET STEP ON 
DO FORM valirekv TO lnRekvid
IF !EMPTY(lnRekvid)
	SELECT comrekvremote
	LOCATE FOR id = lnRekvId
	WAIT WINDOW ' Oodake, käivitan '+ LEFT(ALLTRIM(comRekvremote.nimetus),40) nowait
* vahetan rekvid
	oConnect.rekvAndmed(UPPER(ALLTRIM(comRekvremote.nimetus)),lnRekvid) 
	DO open_lib WITH 1
	MESSAGEBOX('Ok',0,'Vali asutus')
ENDIF
