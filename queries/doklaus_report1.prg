Parameter cWhere
With oDb
	.Use ('curdoklausend','doklausend_report1',.T.)
	INDEX ON id TAG id
	SET ORDER TO id
	If Isdigit(Alltrim(cWhere))
		tnid = Val(Alltrim(cWhere))
		.Use ('v_doklausheader','qryDokLausHeader')
		.Use ('v_doklausend','qryDokLausend')
		Select qryDokLausend
		Scan
			Select doklausend_report1
			Append Blank
			Replace id WITH qryDokLausHeader.id,;
				deebet With qryDokLausend.deebet,;
				kreedit With qryDokLausend.kreedit,;
				dok With qryDokLausHeader.dok,;
				summa With qryDokLausend.Summa,;
				lisa_d WITH qryDokLausend.lisa_d,;
				lisa_k WITH qryDokLausend.lisa_k,;
				kood1 WITH qryDokLausend.kood1,;
				kood2 WITH qryDokLausend.kood2,;
				kood3 WITH qryDokLausend.kood3,;
				kood4 WITH qryDokLausend.kood4,;
				kood5 WITH qryDokLausend.kood5,;				
				selg With qryDokLausHeader.selg In doklausend_report1
		Endscan
		Use In qryDokLausend
		Use In qryDokLausHeader
	Else
		tcSelg = '%'+Upper(Rtrim(Ltrim(fltrlausend.selg)))+'%'
		tcDeebet = '%'+Rtrim(Ltrim(fltrlausend.deebet))+'%'
		tcKreedit = '%'+Rtrim(Ltrim(fltrlausend.kreedit))+'%'
		tcKood1 = Rtrim(Ltrim(fltrlausend.kood1))+'%'
		tcKood2 = Rtrim(Ltrim(fltrlausend.kood2))+'%'
		tcKood3 = Rtrim(Ltrim(fltrlausend.kood3))+'%'
		tcKood4 = Rtrim(Ltrim(fltrlausend.kood4))+'%'
		tcKood5 = Rtrim(Ltrim(fltrlausend.kood5))+'%'
		tcDok = '%'+Upper(Ltrim(Rtrim(fltrlausend.dok)))+'%'
		tnSumma1 = fltrlausend.Summa1
		tnSumma2 = Iif(Empty(fltrlausend.Summa2),999999999,fltrlausend.Summa2)
		.Use ('curdoklausend','qryDokLausend')
		Select doklausend_report1
		Append From Dbf ('qryDokLausend')
		Use In qryDokLausend
	Endif
Endwith
Select doklausend_report1