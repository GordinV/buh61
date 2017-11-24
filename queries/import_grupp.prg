set step on
gnHandle = sqlconnect('buhdata5','zinaida','159')
if gnHandle < 0
	set step on
	return
endif
select distinc group, name from as_goods wher type = "!'" and empty (code) into cursor qryGroups
scan FOR !EMPTY (GROUP)
	cString = "insert into library (rekvId, kood, nimetus,library ) values (1,'"+;
		left(alltrim(upper(qryGroups.name)),20)+"','"+rtrim(qryGroups.name)+"','PVGRUPP')"
	lError = sqlexec(gnHandle,cString)
	if lError < 1
		_cliptext = cString
		set step on
		exit
	endif
endscan
=sqldisconnect(gnHandle)