Parameter cWhere
IF EMPTY(cWhere)
	cWhere = ''
endif
cDok = ''
cKood = ''
cNimetus = ''
With oDb
	.Use('curNomenklatuur','nomenklatuur_report1',.T.)
	INDEX ON kood TAG kood
	SET ORDER TO kood
	If Isdigit(Alltrim(cWhere))
		tnid = Val(Alltrim(cWhere))
		.Use ('v_nomenklatuur','qryNom')
		Select nomenklatuur_report1
		Append From Dbf ('qrynom')
		Use In qryNom
	Else
		If Used('fltrNomen')
			cDok = Upper(Ltrim(Rtrim(fltrNomen.dok)))
			cKood = Upper(Ltrim(Rtrim(fltrNomen.kood)))
			cNimetus = Upper(Ltrim(Rtrim(fltrNomen.nimetus)))
		Endif
		cDok = '%'+cDok+'%'
		cKood = '%'+cKood+'%'
		cNimetus = '%'+cNimetus+'%'
		.dbreq('nomenklatuur_report1',gnHandle,'curNomenklatuur')
	Endif
Endwith
Select nomenklatuur_report1
If Reccount('nomenklatuur_report1') < 1
	Append Blank
Endif
