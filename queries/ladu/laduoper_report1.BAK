Parameter cWhere
IF EMPTY(cWhere)
	cWhere = ''
endif
tcKood = ''
tcNimetus = ''
With oDb
	tcKood = '%'+ltrim(rtrim(fltrGruppid.kood))+'%'
	tcNimetus = '%'+ltrim(rtrim(fltrGruppid.nimetus))+'%'
	.Use('curGruppid','varagrupp_report1',.T.)
	INDEX ON kood TAG kood
	SET ORDER TO kood
	If Isdigit(Alltrim(cWhere))
		tnid = Val(Alltrim(cWhere))
		.Use ('v_library','qryVaraGrupp')
		Select varaGrupp_report1
		Append From Dbf ('qryVaraGrupp')
		Use In qryVaragrupp
	Else
		If Used('fltrGruppid')
			tcKood = Upper(Ltrim(Rtrim(fltrGruppid.kood)))
			tcNimetus = Upper(Ltrim(Rtrim(fltrGruppid.nimetus)))
		Endif
		tcKood = '%'+tcKood+'%'
		tcNimetus = '%'+tcNimetus+'%'
		.dbreq('varagrupp_report1',gnHandle,'curGruppid')
	Endif
Endwith
Select varagrupp_report1
If Reccount('varagrupp_report1') < 1
	Append Blank
Endif
