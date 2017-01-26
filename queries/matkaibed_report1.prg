Parameter cWhere
Create Cursor matkaibed_report1 (grupp c(254), kood c(20) Default COMNOMREMOTE.kood, ;
	nimetus c(254) Default COMNOMREMOTE.nimetus, uhik c(20) Default COMNOMREMOTE.uhik, algkogus Y,;
	algsumma Y, dbkogus Y, dbsumma Y, krkogus Y, krsumma Y, loppkogus Y, loppsumma Y, nomId Int Default COMNOMREMOTE.Id)
Index On Left(Trim(Upper(grupp)),40)+'-'+Trim(kood) Tag kood
Set Order To kood
With odb
	If Empty(fltrAruanne.kood3)
		tnNomid1 = 0
		tnNomid2 = 999999999
	Else
		tnNomid1 = fltrAruanne.kood3
		tnNomid2 = fltrAruanne.kood3
	Endif
	If Empty(fltrAruanne.kood1)
		tcGrupp = '%'
	Else

		Select comVaraGruppAruanne
		Locate For Id = fltrAruanne.kood1
		tcGrupp = Trim(comVaraGruppAruanne.nimetus)+'%'
	Endif
	tdKpv1 = Date(1900,01,01)
	tdKpv2 = fltrAruanne.kpv1 - 1
	tnLiik = 1
	.Use ('CURMATKAIBED','qryAlgMatS')
	Index On nomId Tag nomId
	Set Order To nomId
	tnLiik = 2
	.Use ('CURMATKAIBED','qryAlgMatV')
	Index On nomId Tag nomId
	Set Order To nomId
	tdKpv1 = fltrAruanne.kpv1
	tdKpv2 = fltrAruanne.kpv2
	tnLiik = 1

	.Use ('CURMATKAIBED','qryKbMatDb')
	Index On nomId Tag nomId
	Set Order To nomId
	tnLiik = 2
	.Use ('CURMATKAIBED','qryKbMatKr')
	Index On nomId Tag nomId
	Set Order To nomId
Endwith
Select COMNOMREMOTE
Scan For DOK = 'LADU' And tyyp = 1

	lnAlgDbKogus = 0
	lnAlgDbSumma = 0
	lnAlgKrKogus = 0
	lnAlgKrSumma = 0
	lnDbKogus = 0
	lnDbSumma = 0
	lnKrKogus = 0
	lnKrSumma = 0
	Select matkaibed_report1
	Append Blank
	Select qryAlgMatS
	Seek COMNOMREMOTE.Id
	If Found()
		lnAlgDbKogus = qryAlgMatS.kogus
		lnAlgDbSumma = qryAlgMatS.Summa
	Endif
	Select qryAlgMatV
	Seek COMNOMREMOTE.Id
	If Found()
		lnAlgKrKogus = qryAlgMatV.kogus
		lnAlgKrSumma = qryAlgMatV.Summa
	Endif
	Select qryKbMatDb
	Seek COMNOMREMOTE.Id
	If Found()
		lnDbKogus = qryKbMatDb.kogus
		lnDbSumma = qryKbMatDb.Summa
	Endif
	Select qryKbMatKr
	Seek COMNOMREMOTE.Id
	If Found()
		lnKrKogus = qryKbMatKr.kogus
		lnKrSumma = qryKbMatKr.Summa
	Endif
*!*		SELECT comVaraGruppAruanne
*!*		LOCATE FOR id = comvaraAruanne.PARENTid

	Replace algkogus With lnAlgDbKogus - lnAlgKrKogus,;
		algsumma With lnAlgDbSumma - lnAlgKrSumma,;
		dbkogus  With lnDbKogus ,;
		dbsumma With lnDbSumma ,;
		krkogus With lnKrKogus,;
		krsumma With lnKrSumma, ;
		loppkogus With algkogus + dbkogus - krkogus,;
		loppsumma With algsumma + dbsumma - krsumma In matkaibed_report1
Endscan



Use In qryKbMatKr
Use In qryKbMatDb
Use In qryAlgMatS
Use In qryAlgMatV

Select matkaibed_report1
Delete For Empty(algkogus) And Empty(dbkogus) And Empty(krkogus)

