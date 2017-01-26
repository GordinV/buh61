Parameter cWhere
tcKood1 = rtrim(ltrim(fltrJournal.kood1))+'%'
tcKood2 = rtrim(ltrim(fltrJournal.kood2))+'%'
tcKood3 = rtrim(ltrim(fltrJournal.kood3))+'%'
tcKood4 = rtrim(ltrim(fltrJournal.kood4))+'%'
tcKood5 = rtrim(ltrim(fltrJournal.kood5))+'%'
cSelg = '%'+rtrim(ltrim(fltrJournal.selg))+'%'
cDeebet = rtrim(ltrim(fltrJournal.deebet))+'%'
cKreedit = rtrim(ltrim(fltrJournal.kreedit))+'%'
cAsutus = '%'+upper(rtrim(ltrim(fltrJournal.asutus)))+'%'
cDok = '%'+upper(ltrim(rtrim(fltrJournal.dok)))+'%'
tcTunnus = upper(ltrim(rtrim(fltrJournal.tunnus)))+'%'
dKpv1 = fltrJournal.kpv1
dKpv2 = iif(empty(fltrJournal.kpv2),date()+365*10,fltrJournal.kpv2)
nSumma1 = iif(empty(fltrJournal.Summa1),-999999999,fltrJournal.Summa1)
nSumma2 = iif(empty(fltrJournal.Summa2),999999999,fltrJournal.Summa2)
tcTpD = rtrim(ltrim(fltrJournal.tpD))+'%'
tcTpK = rtrim(ltrim(fltrJournal.tpK))+'%'
tcKasutaja = rtrim(ltrim(fltrJournal.ametnik))+'%'
tcMuud = '%'+rtrim(ltrim(fltrJournal.muud))+'%'
tcValuuta = rtrim(ltrim(fltrJournal.valuuta))+'%'
cQuery = 'curJournal'

oDb.use(cQuery,'journal_report1')
select journal_report1

	Index on id tag id
	Index on kpv tag kpv additive
	Index on number tag number additive
	Index on deebet tag deebet additive
	Index on kreedit tag kreedit additive
	Index on kood1 tag kood1 additive
	Index on kood2 tag kood2 additive
	Index on kood3 tag kood3 additive
	Index on kood4 tag kood4 additive
	Index on kood5 tag kood5 additive
	Index on lisa_d tag lisa_d additive
	Index on Lisa_k tag lisa_k additive
	Index on summa tag summa additive
	Index on left(upper(selg),40) tag selg additive
	Index on left(upper(dok),40) tag dok additive
	Index on left(upper(asutus),40) tag asutus additive
	Index on tunnus tag tunnus additive

IF USED('curJournal') 
	SELECT curJournal
	lcTag = TAG()
ELSE
	lctag = 'KPV'
ENDIF
SELECT journal_report1
IF !EMPTY(fltrJournal.objekt)
	DELETE FROM journal_report1 WHERE objekt <> fltrJournal.objekt
endif

SET ORDER TO (lctag)
