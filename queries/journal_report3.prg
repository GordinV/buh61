**
** journal_report3.fxp
**
 PARAMETER cwHere
 tcKood1 = RTRIM(LTRIM(flTrjournal.koOd1))+'%'
 tcKood2 = RTRIM(LTRIM(flTrjournal.koOd2))+'%'
 tcKood3 = RTRIM(LTRIM(flTrjournal.koOd3))+'%'
 tcKood4 = RTRIM(LTRIM(flTrjournal.koOd4))+'%'
 tcKood5 = RTRIM(LTRIM(flTrjournal.koOd5))+'%'
 csElg = '%'+RTRIM(LTRIM(flTrjournal.seLg))+'%'
 cdEebet = RTRIM(LTRIM(flTrjournal.deEbet))+'%'
 ckReedit = RTRIM(LTRIM(flTrjournal.krEedit))+'%'
 caSutus = '%'+UPPER(RTRIM(LTRIM(flTrjournal.asUtus)))+'%'
 cdOk = '%'+UPPER(LTRIM(RTRIM(flTrjournal.doK)))+'%'
 tcTunnus = UPPER(LTRIM(RTRIM(flTrjournal.tuNnus)))+'%'
 dkPv1 = flTrjournal.kpV1
 dkPv2 = IIF(EMPTY(flTrjournal.kpV2), DATE()+003650, flTrjournal.kpV2)
 nsUmma1 = IIF(EMPTY(flTrjournal.suMma1), -999999999, flTrjournal.suMma1)
 nsUmma2 = IIF(EMPTY(flTrjournal.suMma2), 999999999, flTrjournal.suMma2)
 tcTpd = RTRIM(LTRIM(flTrjournal.tpD))+'%'
 tcTpk = RTRIM(LTRIM(flTrjournal.tpK))+'%'
 tcKasutaja = RTRIM(LTRIM(flTrjournal.amEtnik))+'%'
 tcMuud = '%'+RTRIM(LTRIM(flTrjournal.muUd))+'%'
 tnParentid = 3
 cqUery = 'curJournalSvod'
 odB.usE(cqUery,'journal_report1')
 SELECT joUrnal_report1
 INDEX ON id TAG id
 INDEX ON kpV TAG kpV ADDITIVE
 INDEX ON nuMber TAG nuMber ADDITIVE
 INDEX ON deEbet TAG deEbet ADDITIVE
 INDEX ON krEedit TAG krEedit ADDITIVE
 INDEX ON koOd1 TAG koOd1 ADDITIVE
 INDEX ON koOd2 TAG koOd2 ADDITIVE
 INDEX ON koOd3 TAG koOd3 ADDITIVE
 INDEX ON koOd4 TAG koOd4 ADDITIVE
 INDEX ON koOd5 TAG koOd5 ADDITIVE
 INDEX ON liSa_d TAG liSa_d ADDITIVE
 INDEX ON liSa_k TAG liSa_k ADDITIVE
 INDEX ON suMma TAG suMma ADDITIVE
 INDEX ON LEFT(UPPER(seLg), 40) TAG seLg ADDITIVE
 INDEX ON LEFT(UPPER(doK), 40) TAG doK ADDITIVE
 INDEX ON LEFT(UPPER(asUtus), 40) TAG asUtus ADDITIVE
 INDEX ON tuNnus TAG tuNnus ADDITIVE
 IF USED('curJournal')
      SELECT cuRjournal
      lcTag = TAG()
 ELSE
      lcTag = 'KPV'
 ENDIF
 SELECT joUrnal_report1
 SET ORDER TO (lcTag)
ENDPROC
*