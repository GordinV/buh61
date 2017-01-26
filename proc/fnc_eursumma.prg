Lparameters tnSumma, tcValuuta, tnOpt
Local lnEURkuurs, lnVALkuurs, lcAlias, lnReturn
lnReturn = 0
lnEURkuurs = 15.6466
lcAlias = Alias()
If Empty(tnOpt)
	tnOpt = 0
Endif


If Empty(tcValuuta)
	tcValuuta = 'EEK'
Endif

If Empty(tnSumma)
	tnSumma = 0
Endif

If !Used('comValuutaRemote')
	odb.Use('comValuutaRemote')
Endif
* otsin EUR tase, kui kuurs erinev, siis kasutame kuurs salvestatud taabels.

IF tcValuuta = 'EEK'
	Select comValuutaRemote
	Locate For kood = 'EUR'
ELSE
	Select comValuutaRemote
	Locate For kood = 'EEK'
endif

If Found() And !Empty(comValuutaRemote.kuurs)
	lnEURkuurs = comValuutaRemote.kuurs
	lcValuuta = ALLTRIM(comValuutaRemote.kood)
Endif


* otsin teine valuuta kuurs

*If tcValuuta = 'EUR'
* esitluse valuuta ja arvelduse valuuta võrdelv
	lnReturn = tnSumma

*Else

	Select comValuutaRemote
	Locate For kood = tcValuuta
	If Found() And !Empty(comValuutaRemote.kuurs)
		lnVALkuurs = comValuutaRemote.kuurs
	Else
		Return lnReturn
	Endif
* arvestame läbi EEK

* summa EEK
	lnReturn =  tnSumma * lnVALkuurs

* summa EUR
	lnReturn = ROUND(lnReturn / lnEURkuurs,2)

*Endif
If tnOpt = 1
* tagastame string
	lnReturn = '('+ALLTRIM(lcValuuta)+':'+Alltrim(Str(lnReturn,14,2))+')'

Endif


Select (lcAlias)
*!*	IF tcValuuta = 'EUR' AND fnc_currentValuuta('VAL',DATE()) = 'EUR' AND tnOpt = 1
*!*		lnreturn = ''
*!*	ENDIF

IF DATE() > DATE(2011,06,30) AND lcValuuta = 'EEK' AND tnOpt = 1
	lnReturn = ''
ENDIF


Return lnReturn




