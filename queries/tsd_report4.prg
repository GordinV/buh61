Parameter tcWhere
If !empty (fltrAruanne.asutusId)
	Select comAsutusRemote
	Locate for id = fltrAruanne.asutusId
	tcIsik = rtrim(comAsutusRemote.nimetus)+'%'
Else
	tcIsik = '%%'
Endif
tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2
tnOsakondId1 = fltrAruanne.osakondId
tnOsakondId2 = iif (empty (fltrAruanne.osakondId),999999999,fltrAruanne.osakondId)
tnParentRekvId = grekv
tnId = gRekv

tnParent = iif(empty(fltrAruanne.kond),4,3)

oDb.use ('printTSD4')
SELECT printtsd4
Create cursor ftsd_report (asutus c(254) default qryrekv.nimetus, regnum c(20) default qryrekv.regkood,;
	aadress c(254) default qryrekv.aadress, AASTA int default year(fltrAruanne.kpv1),;
	kuu int default month (fltrAruanne.kpv1),;
	juhataja c(120) default qryrekv.juht, pearaama c(120) default qryrekv.raama, tel c(40) default qryrekv.tel,;
	summa01 n(14,4), summa02 n(14,4), summa03 n(14,4), summa04 n(14,4), summa05 n(14,4), summa06 n(14,4),;
	summa07 n(14,4), summa08 n(14,4), summa09 n(14,4), summa10 n(14,4), summa11 n(14,4), summa12 n(14,4),;
	summa13 n(14,4), summa14 n(14,4), summa15 n(14,4), summa16 n(14,4), summa17 n(14,4), summa18 n(14,4),;
	summa19 n(14,4), summa20 n(14,4), summa21 n(14,4), summa22 n(14,4), summa23 n(14,4), summa24 n(14,4) )
Append BLANK

replace ftsd_report.asutus with qryrekv.nimetus,;
	 	regnum with qryrekv.regkood,;
		aadress with qryrekv.aadress,;
		AASTA with year(fltrAruanne.kpv1),;
		kuu with month (fltrAruanne.kpv1),;
		juhataja with qryrekv.juht,;
		pearaama with qryrekv.raama,;
		tel with qryrekv.tel,;
		summa01 WITH  (printTsd4.eris0100+printTsd4.eris0101+printTsd4.eris0110+printTsd4.eris0111),;
		summa02 WITH  (printTsd4.eris0200+printTsd4.eris0201+printTsd4.eris0210+printTsd4.eris0211),;
		summa03 WITH  (printTsd4.eris0300+printTsd4.eris0301+printTsd4.eris0310+printTsd4.eris0311),; 
		summa04 WITH  (printTsd4.eris0400+printTsd4.eris0401+printTsd4.eris0410+printTsd4.eris0411),; 
		summa05 WITH  (printTsd4.eris0500+printTsd4.eris0501+printTsd4.eris0510+printTsd4.eris0511),; 
		summa06 WITH  (printTsd4.eris0600+printTsd4.eris0601+printTsd4.eris0610+printTsd4.eris0611),;
		summa07 WITH  (printTsd4.eris0700+printTsd4.eris0701+printTsd4.eris0710+printTsd4.eris0711),; 
		summa08 WITH  (printTsd4.eris0800+printTsd4.eris0801+printTsd4.eris0810+printTsd4.eris0811),; 
		summa09 WITH  (printTsd4.eris0900+printTsd4.eris0901+printTsd4.eris0910+printTsd4.eris0911),; 
		summa10 WITH  (printTsd4.eris1000+printTsd4.eris1001+printTsd4.eris1010+printTsd4.eris1011),; 
		summa11 WITH  (printTsd4.eris1100+printTsd4.eris1101+printTsd4.eris1110+printTsd4.eris1111),; 
		summa15 WITH (summa01+summa02+summa03+summa04+summa05+summa06+summa07+summa08+summa09+summa10+summa11),;
		summa17 WITH (printTsd4.eris0101+printTsd4.eris0201+printTsd4.eris0301+printTsd4.eris0401+printTsd4.eris0501+printTsd4.eris0601+printTsd4.eris0701+;
			printTsd4.eris0801+printTsd4.eris0901+printTsd4.eris1001+printTsd4.eris1101),;
		summa16 WITH (printTsd4.eris0110+printTsd4.eris0210+printTsd4.eris0310+printTsd4.eris0410+printTsd4.eris0510+printTsd4.eris0610+printTsd4.eris0710+;
			printTsd4.eris0810+printTsd4.eris0910+printTsd4.eris1010+printTsd4.eris1110),;
		summa18 WITH (SUMMA15-summa16) * 21/79,;
		summa19 WITH  summa15 - summa17 + summa18 - (summa17*21/79),; 
		summa20 WITH summa19 * 33 / 100,; 
		summa21 WITH 0, summa22 WITH 0 , summa23 WITH 0, summa24 WITH 0 IN ftsd_report

Use in printTsd4
Select ftsd_report