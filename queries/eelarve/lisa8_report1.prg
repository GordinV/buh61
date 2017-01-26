Parameter tcWhere
Create Cursor lisa8_report1 (konto c(20),objekt c(20), tegev c(20), allikas c(20), artikkel c(20), deebet N(12,2), kreedit N(12,2))
Index On konto+'-'+tegev+'-'+allikas+'-'+artikkel Tag indx
Set Order To indx

dKpv1 = Date(Year(fltrAruanne.kpv1),1,1)
dKpv2 = fltrAruanne.kpv2
tcAllikas = Rtrim(Ltrim(fltrAruanne.kood2))+'%'
tcArtikkel = Rtrim(Ltrim(fltrAruanne.kood3))+'%'
tcTegev = Rtrim(Ltrim(fltrAruanne.kood4))+'%'
tcObjekt = Rtrim(Ltrim(fltrAruanne.kood1))+'%'
tcEelAllikas = Rtrim(Ltrim(fltrAruanne.eelallikas))+'%'
cSelg = '%'
cDeebet = '%'
cKreedit = '%'
cAsutus = '%'
cDok = '%'
tcTunnus = Upper(Ltrim(Rtrim(fltrAruanne.tunnus)))+'%'
nSumma1 = -999999999
nSumma2 = 999999999

With oDb
	.Use('qryLisa8tulud','qryTulud')
	.Use('qryLisa8tuluMiinus','qryTuluMiinus')
	.Use('qryLisa8Kulud','qryKulud')
	.Use('qryLisa8KuluMiinus','qryKuluMiinus')
Endwith
Select qryTulud
Append From Dbf('qryTuluMiinus')
Select Sum(Summa) As kreedit, allikas, konto;
	FROM qryTulud ;
	order By konto,allikas;
	group By konto,allikas;
	INTO Cursor qryTulu

Use In qryTulud
Use In qryTuluMiinus


Select qryKulud
Append From Dbf('qryKuluMiinus')

Select Sum(Summa) As deebet, artikkel, tegev, konto;
	FROM qryKulud ;
	order By konto, tegev, artikkel;
	group By konto, tegev, artikkel;
	INTO Cursor qryKulu

Use In qryKulud
Use In qryKuluMiinus

Select lisa8_report1
Append From Dbf('qryTulu')
Append From Dbf('qryKulu')
Use In qryTulu
Use In qryKulu

&& kulud

Select lisa8_report1
Delete For Empty (deebet) And Empty (kreedit)
Scan
	Do Case
		Case kreedit < 0 And deebet > 0
			Replace deebet With deebet + kreedit * -1,;
				kreedit WITH 0 In lisa8_report1
		Case deebet < 0 And kreedit > 0
			Replace kreedit With kreedit + deebet * -1,; 
				deebet with 0	 In lisa8_report1
		Case deebet < 0 And kreedit = 0
			Replace kreedit With deebet * -1,;
				deebet with 0	 In lisa8_report1
		Case kreedit < 0 And deebet = 0
			Replace deebet With kreedit * -1,;
				kreedit WITH 0 In lisa8_report1
	Endcase
Endscan
