Parameter cWhere

tcisikuKood = '%'+ltrim(rtrim(fltrlapsed.isikukood))+'%'
tcNimi = '%'+ltrim(rtrim(fltrLapsed.nimi))+'%'
tcTunnus = '%'+LTRIM(RTRIM(fltrLapsed.tunnus))+'%'
dAlgkpv1 = fltrLapsed.algkpv1
dAlgkpv2 = fltrLapsed.algkpv2
dLoppkpv1 = fltrLapsed.loppkpv1
dLoppkpv2 = fltrLapsed.loppkpv2
odb.use ('CURVANEMATEVOLG','lapsed_report1')



SELECT lapsed_report1
IF RECCOUNT()< 1
	APPEND BLANK
	
endif
