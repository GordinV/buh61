Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif

if used ('v_eelproj')
	select *, left(IIF(staatus = 0,'Anulleritud',iif(staatus = 1,'Aktiivne','Kinnitatud')),20) as status from  v_eelproj into cursor eelproj_report1
	
	select eelproj_report1
	
endif
