Parameter cWhere
With oDb
	.use ('curlausendid','lausend_report1',.t.)
	If isdigit(alltrim(cWhere))
		tnid = val(alltrim(cWhere))
		.use ('v_lausend','qryLausend')
		Select lausend_report1
		Append from dbf ('qryLausend')
	Else
		tcDeebet = '%'+ltrim(rtrim(fltrlausendid.deebet))+'%'
		tcKreedit = '%'+ltrim(rtrim(fltrlausendid.kreedit))+'%'
		tcNimetus = '%'+ltrim(rtrim(fltrlausendid.nimetus))+'%'
		.use ('curlausendid','qryLausend')
	Endif
Endwith
Select lausend_report1
Append from dbf ('qryLausend')
Use in qryLausend
