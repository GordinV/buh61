PARAMETERS tcNumber, tnAsutusId, tdKpvAlg
*!*	IF EMPTY(tcNumber) OR  EMPTY(tnAsutusId)
*!*		RETURN .f.
*!*	ENDIF
IF EMPTY(tdKpvAlg)
	IF USED('fltrArved')
		tdKpvAlg = fltrArved.kpv1
	ELSE
		tdKpvAlg = DATE(YEAR(DATE()), 1, 1)
	ENDIF
ENDIF
IF EMPTY(tcNumber)
	IF USED('fltrArved')
		tcNumber = '%'+LTRIM(RTRIM(fltrArved.number))+'%'
	ELSE
		tcNumber = '%'
	ENDIF
ENDIF
IF EMPTY(tnAsutusId)
	IF USED('fltrArved')
		cAsutus = '%'+rtrim(ltrim(fltrArved.asutus))+'%'
	else
		cAsutus = '%'
	ENDIF
ENDIF
SET Classlib To classes\tasudok
oTasudok = Createobject('tasudok')
WITH oTasudok
	if !empty ( tnAsutusId)
		SELECT comAsutusRemote
		SEEK tnAsutusId
		cAsutus = Upper(Rtrim(Ltrim(comAsutusRemote.nimetus)))+'%'
	endif
	tcAllikas = '%'
	tcArtikkel = '%'
	tcTegev = '%'
	tcObjekt = '%'
	tcEelAllikas = '%'
	cSelg = '%'
	cDeebet = '%'
	cKreedit = '%'
	IF EMPTY(tcNumber)
		cDok = '%'
	else
		cDok = '%'+Upper(Ltrim(Rtrim(tcNumber)))+'%'
	endif
	tcTunnus = '%'
	dKpv1 = tdKpvAlg
	dKpv2 = DATE()
	nSumma1 = -999999999
	nSumma2 = 999999999
	odb.use ('curJournal','curJournal_')
	SELECT curJournal_
	SCAN for !empty (curJournal_.dok)
		wait window [Kontrolin :]+str (recno('curJournal_'))+'/'+str (reccount('curJournal_')) nowait
		.kpv = curJournal_.kpv
		.asutusid = curJournal_.asutusid
		.Number = Ltrim(Rtrim(curJournal_.dok))
		.lausendid = curJournal_.lausendid
		.Summa = curJournal_.Summa
		lError = .arv_tasu_journalid_jargi()
	ENDSCAN
	use in curJournal_
ENDWITH
