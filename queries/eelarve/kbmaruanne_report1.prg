Parameter cWhere
If Isdigit(Alltrim(cWhere))
	cWhere = Val(Alltrim(cWhere))
Endif
Local lnDeebet, lnKreedit
tcAllikas = '%'
tcArtikkel = '%'
tcTegev = '%'
tcObjekt = '%'
tcEelAllikas = '%'
lnDeebet = 0
lnKreedit = 0
tcTpD = '%'
tcTpK = '%'
tcKasutaja = '%'
tcMuud = '%'
tnKond = 0

dKpv1 = Iif(!Empty(fltrAruanne.kpv1), fltrAruanne.kpv1,Date(Year(Date()),1,1))
dKpv2 = Iif(!Empty(fltrAruanne.kpv2), fltrAruanne.kpv2,Date())
Replace fltrAruanne.kpv1 With dKpv1,;
	fltrAruanne.kpv2 With dKpv2 In fltrAruanne
dKpv = Date(Year(fltrAruanne.kpv1), Month(fltrAruanne.kpv1),1)
&&Use v_kaibemaks in 0 alias cursor2
oDb.Use('v_kaibemaks','cursor2')
If Reccount('cursor2') = 0 Or;
		empty(cursor2.kood)
	Messagebox('Viga: kaibemaksu kood ei leidnud','Kontrol')
	Select 0
	Return .F.
Endif
&&Use curJournal in 0 alias cursor1 nodata
Create Cursor kbmandmik_report1 (Nimetus c(120), regkood c(11), aadress c(120), kbmkood c(11),;
	tel c(60), email c(120), raama c(120), rea01 N(14,2),rea011 N(14,2),rea012 N(14,2),	rea02 N(14,2),rea021 N(14,2),;
	rea03 N(14,2), rea031 N(14,2), rea0311 N(14,2), rea032 N(14,2) , rea0321 N(14,2), rea04 N(14,2), rea041 N(14,2), rea05 N(14,2),;
	rea051 N(14,2), rea052 N(14,2), rea06 N(14,2), rea061 N(14,2),;
	rea062 N(14,2), rea07 N(14,2),rea071 N(14,2), rea08 N(14,2), rea09 N(14,2), rea10 N(14,2), rea11 N(14,2),;
	rea12 N(14,2), rea13 N(14,2))
Select kbmandmik_report1
Append Blank


TEXT TO lcString noshow
	SELECT * from kbm_report1(?gRekv::integer, ?dKpv1::date, ?dKpv2::date)
ENDTEXT

lnError = SQLEXEC(gnHandle, lcString, 'qryKbm')
If lnError < 0
	Messagebox('Tekkis viga',0,'Viga')
	Select 0
	Return
Endif


Select kbmandmik_report1
Replace rea01 With qryKbm.rea01, ;
	rea011 With qryKbm.rea011, ;
	rea02 With qryKbm.rea02, ;
	rea021 With qryKbm.rea021, ;
	rea03 With qryKbm.rea03, ;
	rea031 With qryKbm.rea031, ;
	rea0311 With qryKbm.rea0311, ;
	rea04 With qryKbm.rea04, ;
	rea041 With qryKbm.rea041, ;
	rea051 With qryKbm.rea051, ;
	rea052 With qryKbm.rea052, ;
	rea05 With qryKbm.rea051 + qryKbm.rea052, ;
	rea12 With rea04 - rea05 In kbmandmik_report1

Use In qryKbm
SELECT kbmandmik_report1
RETURN .t.


If 'EELARVE' $ curkey.versia
* arvede alusel (eelarve)
	= f_kbm_arve()
Else
* lausendide alusel
	= f_kbm_lausend()
Endif

Select kbmandmik_report1


Function get_rea_nr4
	Local lnSumma
	lnSumma = 0
TEXT TO lcSql TEXTMERGE noshow
	select sum(summa) as summa from curJournal
	where kreedit in ('203000', '203001')
	and rekvid = ?gRekv
	and kpv >= ?fltrAruanne.kpv1
	and kpv <= ?fltrAruanne.kpv2
ENDTEXT

	lnError = SQLEXEC(gnHandle,lcSql,'tmpRea')
	If Used('tmpRea') And Reccount('tmpRea') > 0
		Select tmpRea
		Go Top
		lnSumma = tmpRea.Summa
	Endif

	If Used('tmpRea')
		Use In tmpRea
	Endif

	Return lnSumma

Endfunc

Function get_rea_nr5
	Local lnSumma
	lnSumma = 0
TEXT TO lcSql TEXTMERGE noshow
	select sum(summa) as summa
		from curJournal
	where rekvid = ?gRekv
	and deebet like '103701%'
	and kpv >= ?fltrAruanne.kpv1
	and kpv <= ?fltrAruanne.kpv2
ENDTEXT

	lnError = SQLEXEC(gnHandle,lcSql,'tmpRea')
	If Used('tmpRea') And Reccount('tmpRea') > 0
		Select tmpRea
		Go Top
		lnSumma = tmpRea.Summa
	Endif

	If Used('tmpRea')
		Use In tmpRea
	Endif

	Return lnSumma

Endfunc

Function f_kbm_arve
	tnLiik = 0
	oDb.Use('qryKbm2')
	If !Used('qryKbm2')
		Return .F.
	Endif

	Select qryKbm2
	Scan
*		SET STEP on
		Do Case
			Case qryKbm2.kbm = 5 And qryKbm2.Summa > 0
				Replace rea01 With qryKbm2.Summa In kbmandmik_report1
			Case qryKbm2.kbm = 1 And Summa > 0
				Replace rea03 With qryKbm2.Summa In kbmandmik_report1
*			CASE qryKbm2.kbm = 2 AND summa > 0
*				replace rea03 WITH qryKbm2.summa IN kbmandmik_report1
			Case qryKbm2.kbm = 3 And Summa > 0
				Replace rea08 With qryKbm2.Summa In kbmandmik_report1
			Case qryKbm2.kbm = 4 And Summa > 0
				Replace rea02 With qryKbm2.Summa In kbmandmik_report1

		Endcase
	Endscan

	lcKpv1 = "date("+Str(Year(fltrAruanne.kpv1),4)+","+Str(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+")"
	lcKpv2 = "date("+Str(Year(fltrAruanne.kpv2),4)+","+Str(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+")"
SET STEP ON 
	Select kbmandmik_report1
	If qryRekv.regkood = '90003812'
* SA Linna Arendus
		lnRea04Summa = get_rea_nr4()
		Replace rea04 With 0.20 * lnRea04Summa + 0.09* rea02 In kbmandmik_report1
	Else
		Replace rea04 With 0.20 * rea01 + 0.09* rea02 In kbmandmik_report1
	Endif

	lcString = "select sum(summa) as summa from curJournal where deebet like '103756%' and rekvid = "+Str(gRekv)+ " and  kpv >= "+lcKpv1 + " and kpv <= "+lcKpv2

	lnError = SQLEXEC(gnHandle,lcString,'qryTmp')
	lnSumma = Iif(Isnull(qryTmp.Summa),0,qryTmp.Summa)
*		lnSumma = analise_formula('DK(103756)',fltrAruanne.kpv1)

	Replace rea051 With Round(lnSumma,2)  In kbmandmik_report1
*		lnSumma = analise_formula('DK(103701)',fltrAruanne.kpv1)

	lnSumma = get_rea_nr5()
	Replace rea05 With Round(lnSumma,2) + rea051 In kbmandmik_report1
*		lnSumma = analise_formula('DK(1084)',fltrAruanne.kpv1)
	lcString = "select sum(summa) as summa from curJournal where deebet like '1084%' and rekvid = "+Str(gRekv)+ " and kpv >= "+lcKpv1 + " and kpv <= "+lcKpv2
	lnError = SQLEXEC(gnHandle,lcString,'qryTmp')
	lnSumma = Iif(Isnull(qryTmp.Summa),0,qryTmp.Summa)


	Replace rea06 With Round(lnSumma,2) In kbmandmik_report1
*		lnSumma = analise_formula('DK(103000)',fltrAruanne.kpv1)
	lcString = "select sum(summa) as summa from curJournal where deebet like '103000%' and rekvid = "+Str(gRekv)+ " and kpv >= "+lcKpv1 + " and kpv <= "+lcKpv2
	lnError = SQLEXEC(gnHandle,lcString,'qryTmp')
	lnSumma = Iif(Isnull(qryTmp.Summa),0,qryTmp.Summa)

	Replace rea07 With Round(lnSumma ,2) In kbmandmik_report1

	If (rea04+ rea05 +rea10 - rea11) > 0
		Replace rea12 With rea04 - rea05 +rea10 - rea11 In kbmandmik_report1
	Else
		Replace rea13 With (rea04 - rea05 + rea10 - rea11) * - 1 In kbmandmik_report1
	Endif

*!*
*!*		SELECT kbmandmik_report1
*!*	*		replace rea04 WITH 0.18 * rea01 + 0.05* rea02 IN kbmandmik_report1
*!*			lnSumma = analise_formula('KK(203001)',fltrAruanne.kpv1)
*!*			replace rea04 WITH lnSumma IN kbmandmik_report1
*!*			lnSumma = analise_formula('DK(103756)',fltrAruanne.kpv1)
*!*			replace rea051 WITH lnSumma IN kbmandmik_report1
*!*			lnSumma = analise_formula('DK(103701)',fltrAruanne.kpv1)
*!*			replace rea05 WITH lnSumma + rea051 IN kbmandmik_report1
*!*			lnSumma = analise_formula('DK(1084)',fltrAruanne.kpv1)
*!*			replace rea06 WITH lnSumma IN kbmandmik_report1
*!*			lnSumma = analise_formula('DK(103000)',fltrAruanne.kpv1)
*!*			replace rea07 WITH lnSumma IN kbmandmik_report1
*!*
*!*			IF (rea04+ rea05 +rea10 - rea11) > 0
*!*				replace rea12 WITH rea04 - rea05 +rea10 - rea11 IN kbmandmik_report1
*!*			ELSE
*!*				replace rea13 WITH (rea04 - rea05 + rea10 - rea11) * - 1 IN kbmandmik_report1
*!*			ENDIF
*!*
	Return .T.


TEXT

Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif
Local lnDeebet, lnKreedit
tcAllikas = '%'
tcArtikkel = '%'
tcTegev = '%'
tcObjekt = '%'
tcEelAllikas = '%'
lnDeebet = 0
lnKreedit = 0
tcTpD = '%'
tcTpK = '%'
tcKasutaja = '%'
tcMuud = '%'
tnKond = 0

dKpv1 = iif(!empty(fltrAruanne.kpv1), fltrAruanne.kpv1,date(year(date()),1,1))
dKpv2 = iif(!empty(fltrAruanne.kpv2), fltrAruanne.kpv2,date())
Replace fltrAruanne.kpv1 with dKpv1,;
	fltrAruanne.kpv2 with dKpv2 in fltrAruanne
dKpv = date(year(fltrAruanne.kpv1), month(fltrAruanne.kpv1),1)
&&Use v_kaibemaks in 0 alias cursor2
oDb.use('v_kaibemaks','cursor2')
If reccount('cursor2') = 0 or;
		empty(cursor2.kood)
	Messagebox('Viga: kaibemaksu kood ei leidnud','Kontrol')
	Select 0
	Return .f.
Endif
&&Use curJournal in 0 alias cursor1 nodata
Create cursor kbmandmik_report1 (Nimetus c(120), regkood c(11), aadress c(120), kbmkood c(11),;
	tel c(60), email c(120), raama c(120), rea01 n(14,2),rea011 n(14,2),rea012 n(14,2),	rea02 n(14,2),;
	rea03 n(14,2), rea031 n(14,2), rea0311 n(14,2), rea032 n(14,2) , rea0321 n(14,2), rea04 n(14,2), rea05 n(14,2),;
	 rea051 n(14,2), rea052 n(14,2), rea06 n(14,2), rea061 n(14,2),;
	rea062 n(14,2), rea07 n(14,2),rea071 n(14,2), rea08 n(14,2), rea09 n(14,2), rea10 n(14,2), rea11 n(14,2),;
	rea12 n(14,2), rea13 n(14,2))

Select kbmandmik_report1
Append blank
brow

IF 'EELARVE' $ curkey.versia
	* arvede alusel (eelarve)
	= f_kbm_arve()
ELSE
	* lausendide alusel
	= f_kbm_lausend()
ENDIF

select kbmandmik_report1

FUNCTION f_kbm_arve
	tnLiik = 0
	odb.use('qryKbm2')
	IF !USED('qryKbm2')
	SELECT qryKbm2
	SCAN
		DO case
			CASE qryKbm2.kbm = 0 AND qryKbm2.summa > 0
				replace rea01 WITH qryKbm2.summa IN kbmandmik_report1
			CASE qryKbm2.kbm = 1 AND summa > 0
				replace rea02 WITH qryKbm2.summa IN kbmandmik_report1
			CASE qryKbm2.kbm = 2 AND summa > 0
				replace rea03 WITH qryKbm2.summa IN kbmandmik_report1
			CASE qryKbm2.kbm = 3 AND summa > 0
				replace rea08 WITH qryKbm2.summa IN kbmandmik_report1

		ENDCASE
	ENDSCAN
	SELECT kbmandmik_report1
		replace rea04 WITH 0.20 * rea01 + 0.09* rea02 IN kbmandmik_report1
		lnSumma = analise_formula('DK(103756)',fltrAruanne.kpv1)
		replace rea051 WITH lnSumma IN kbmandmik_report1
		lnSumma = analise_formula('DK(103701)',fltrAruanne.kpv1)
		replace rea05 WITH lnSumma + rea051 IN kbmandmik_report1
		lnSumma = analise_formula('DK(1084)',fltrAruanne.kpv1)
		replace rea06 WITH lnSumma IN kbmandmik_report1
		lnSumma = analise_formula('DK(103000)',fltrAruanne.kpv1)
		replace rea07 WITH lnSumma IN kbmandmik_report1

		IF (rea04+ rea05 +rea10 - rea11) > 0
			replace rea12 WITH rea04 - rea05 +rea10 - rea11 IN kbmandmik_report1
		ELSE
			replace rea13 WITH (rea04 - rea05 + rea10 - rea11) * - 1 IN kbmandmik_report1
		ENDIF


	ENDIF

	RETURN .t.




FUNCTION f_kbm_lausend
&&use v_rekv in 0
tnid = grekv
WITH odb
	.use('v_kbm','curLib')
	.use('v_rekv')
	.use('curJournal','cursor1',.t.)
ENDWITH


cAadress = ''
for i = 1 to memlines(v_rekv.aadress)
	cAadress = rtrim(cAadress) + space(1)+rtrim(mline(v_rekv.aadress,1))
endfor
replace nimetus with v_rekv.nimetus,;
	regkood with v_rekv.regkood,;
	kbmkood with v_rekv.kbmkood,;
	aadress with cAadress,;
	tel with v_rekv.tel,;
	email with v_rekv.email,;
	raama with v_rekv.raama in kbmandmik_report1
use in v_rekv
&&Use v_kbm in 0 alias curLib
Select curLib
Index on library tag library
Set order to library
cDeebet = '%%'
cKreedit = '%%'
cAsutus = '%%'
cDok = '%%'
cSelg = '%%'
tcKood1 = '%'
tcKood2 = '%'
tcKood3 = '%'
tcKood4 = '%'
tcKood5 = '%'
nSumma1 = -99999999
nSumma2 = 999999999
Scan for !empty(curLib.kood)
	Do case
		Case alltrim(curLib.library) == 'KBM1'
			cDeebet = '%%'
			cKreedit = alltrim(curLib.kood)+'%'

			oDb.dbreq('cursor1',gnHandle,'curJournal')
&&			=requery('cursor1')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea01 with rea01 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM1.1'
			cDeebet = '%%'
			cKreedit = alltrim(curLib.kood)+'%'
			oDb.dbreq('cursor1',gnHandle,'curJournal')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea011 with rea011 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM1.2'
			cDeebet = '%%'
			cKreedit = alltrim(curLib.kood)+'%'
			oDb.dbreq('cursor1',gnhandle,'curJournal')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea012 with rea012 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM2'
			cDeebet = '%%'
			cKreedit = alltrim(curLib.kood)+'%'
			oDb.dbreq('cursor1',gnHandle,'curJournal')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea02 with rea02 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM3'
			cDeebet = '%%'
			cKreedit = alltrim(curLib.kood)+'%'
			odb.dbreq('cursor1',gnHandle,'curJournal')
&&			=requery('cursor1')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea03 with rea03 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM4'
			cDeebet = '%%'
			cKreedit = alltrim(curLib.kood)+'%'
&&			=requery('cursor1')
			odb.dbreq('cursor1',gnHandle,'curJournal')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea04 with rea04 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM6'
			cKreedit = alltrim(curLib.kood)+'%'
			if !used ('v_kaibemaks')
				oDb.use ('v_kaibemaks')
			endif
			cDeebet = ltrim(rtrim(v_kaibemaks.kood))+'%'
&&			cDeebet = '2241%'
&&			=requery('cursor1')
			odb.dbreq('cursor1',gnHandle,'curJournal')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea06 with rea06 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM6.1'
			cDeebet = alltrim(curLib.kood)+'%'
			cKreedit = '%%'
&&			=requery('cursor1')
			odb.dbreq('cursor1',gnHandle,'curJournal')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea061 with rea061 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM6.2'
			cDeebet = alltrim(curLib.kood)+'%'
			cKreedit = '%%'
&&			=requery('cursor1')
			odb.dbreq('cursor1',gnHandle,'curJournal')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea062 with rea062 + lnSumma in kbmandmik_report1
	Endcase
Endscan
if used('curLib')
	use in curLib
endif
Replace rea05 with rea01 * 0.18 + rea02 * 0.05 in kbmandmik_report1
*!*	&& arvesta kbm summa mahaarvestamise
*!*	oDb.use('comaa','cursor3')
*!*	&&Use comAa in 0 alias cursor3
*!*	select cursor3
*!*	Index on konto tag konto
*!*	Set order to konto
*!*	cDeebet = alltrim(cursor2.kood)+'%'
*!*	cKreedit = '%%'
*!*	&&=requery('cursor1')
*!*	oDb.dbreq('cursor1',gnHandle,'curJournal')
*!*	Select cursor1
*!*	lnSumma = 0
*!*	Scan
*!*		Select cursor3
*!*		Seek cursor1.deebet
*!*		If !found()
*!*			lnSumma = lnSumma + cursor1.summa
*!*		Endif
*!*	Endscan
*!*	Replace rea06 with lnSumma in kbmandmik_report1
ln09 = kbmandmik_report1.rea05 - kbmandmik_report1.rea06 + kbmandmik_report1.rea07 - kbmandmik_report1.rea08
if ln09 > 0
	replace kbmandmik_report1.rea09 with ln09,;
		rea10 with 0 in kbmandmik_report1
else
	replace kbmandmik_report1.rea09 with 0,;
		rea10 with ln09 in kbmandmik_report1
endif
if used('cursor1')
	use in cursor1
endif
if used('cursor2')
	use in cursor2
endif
if used('cursor3')
	use in cursor3
ENDIF

RETURN .t.





FUNCTION f_kbm_lausend
&&use v_rekv in 0
tnid = grekv
WITH odb
	.use('v_kbm','curLib')
	.use('v_rekv')
	.use('curJournal','cursor1',.t.)
ENDWITH


cAadress = ''
for i = 1 to memlines(v_rekv.aadress)
	cAadress = rtrim(cAadress) + space(1)+rtrim(mline(v_rekv.aadress,1))
endfor
replace nimetus with v_rekv.nimetus,;
	regkood with v_rekv.regkood,;
	kbmkood with v_rekv.kbmkood,;
	aadress with cAadress,;
	tel with v_rekv.tel,;
	email with v_rekv.email,;
	raama with v_rekv.raama in kbmandmik_report1
use in v_rekv
&&Use v_kbm in 0 alias curLib
Select curLib
Index on library tag library
Set order to library
cDeebet = '%%'
cKreedit = '%%'
cAsutus = '%%'
cDok = '%%'
cSelg = '%%'
tcKood1 = '%'
tcKood2 = '%'
tcKood3 = '%'
tcKood4 = '%'
tcKood5 = '%'
nSumma1 = -99999999
nSumma2 = 999999999
Scan for !empty(curLib.kood)
	Do case
		Case alltrim(curLib.library) == 'KBM1'
			cDeebet = '%%'
			cKreedit = alltrim(curLib.kood)+'%'

			oDb.dbreq('cursor1',gnHandle,'curJournal')
&&			=requery('cursor1')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea01 with rea01 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM1.1'
			cDeebet = '%%'
			cKreedit = alltrim(curLib.kood)+'%'
			oDb.dbreq('cursor1',gnHandle,'curJournal')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea011 with rea011 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM1.2'
			cDeebet = '%%'
			cKreedit = alltrim(curLib.kood)+'%'
			oDb.dbreq('cursor1',gnhandle,'curJournal')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea012 with rea012 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM2'
			cDeebet = '%%'
			cKreedit = alltrim(curLib.kood)+'%'
			oDb.dbreq('cursor1',gnHandle,'curJournal')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea02 with rea02 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM3'
			cDeebet = '%%'
			cKreedit = alltrim(curLib.kood)+'%'
			odb.dbreq('cursor1',gnHandle,'curJournal')
&&			=requery('cursor1')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea03 with rea03 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM4'
			cDeebet = '%%'
			cKreedit = alltrim(curLib.kood)+'%'
&&			=requery('cursor1')
			odb.dbreq('cursor1',gnHandle,'curJournal')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea04 with rea04 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM6'
			cKreedit = alltrim(curLib.kood)+'%'
			if !used ('v_kaibemaks')
				oDb.use ('v_kaibemaks')
			endif
			cDeebet = ltrim(rtrim(v_kaibemaks.kood))+'%'
&&			cDeebet = '2241%'
&&			=requery('cursor1')
			odb.dbreq('cursor1',gnHandle,'curJournal')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea06 with rea06 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM6.1'
			cDeebet = alltrim(curLib.kood)+'%'
			cKreedit = '%%'
&&			=requery('cursor1')
			odb.dbreq('cursor1',gnHandle,'curJournal')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea061 with rea061 + lnSumma in kbmandmik_report1
		Case alltrim(curLib.library) == 'KBM6.2'
			cDeebet = alltrim(curLib.kood)+'%'
			cKreedit = '%%'
&&			=requery('cursor1')
			odb.dbreq('cursor1',gnHandle,'curJournal')
			Select cursor1
			Sum summa to lnSumma
			Replace kbmandmik_report1.rea062 with rea062 + lnSumma in kbmandmik_report1
	Endcase
Endscan
if used('curLib')
	use in curLib
endif
Replace rea05 with rea01 * 0.18 + rea02 * 0.05 in kbmandmik_report1
*!*	&& arvesta kbm summa mahaarvestamise
*!*	oDb.use('comaa','cursor3')
*!*	&&Use comAa in 0 alias cursor3
*!*	select cursor3
*!*	Index on konto tag konto
*!*	Set order to konto
*!*	cDeebet = alltrim(cursor2.kood)+'%'
*!*	cKreedit = '%%'
*!*	&&=requery('cursor1')
*!*	oDb.dbreq('cursor1',gnHandle,'curJournal')
*!*	Select cursor1
*!*	lnSumma = 0
*!*	Scan
*!*		Select cursor3
*!*		Seek cursor1.deebet
*!*		If !found()
*!*			lnSumma = lnSumma + cursor1.summa
*!*		Endif
*!*	Endscan
*!*	Replace rea06 with lnSumma in kbmandmik_report1
ln09 = kbmandmik_report1.rea05 - kbmandmik_report1.rea06 + kbmandmik_report1.rea07 - kbmandmik_report1.rea08
if ln09 > 0
	replace kbmandmik_report1.rea09 with ln09,;
		rea10 with 0 in kbmandmik_report1
else
	replace kbmandmik_report1.rea09 with 0,;
		rea10 with ln09 in kbmandmik_report1
endif
if used('cursor1')
	use in cursor1
endif
if used('cursor2')
	use in cursor2
endif
if used('cursor3')
	use in cursor3
ENDIF

RETURN .t.



ENDTEXT
