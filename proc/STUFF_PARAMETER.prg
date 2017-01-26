set step on
cString = reposit.prop2
cparamlist = reposit.prop3
nCount = OCCURS(',', cParamList)
if nCount > 0
	&&есть параметры
	dimension aParam((nCount+1)/2,2)
	lnLeft = 1
	for i = 1 to (nCount)
		lnWidth = at(',',cParamlist,i) - lnLeft
		aParam(i,1) = substr(cParamList,lnLeft,lnWidth)
		lnLeft = lnWidth + 2
		lnWidth = at(',',cParamlist,i+1) - lnLeft
		if lnWidth =< 0
			lnWidth = len(cParamList)
		endif
		aParam(i,2) = substr(cParamList,lnLeft,lnWidth)
		if !empty(aParam(i,1))
			lValue = &aParam(i,1)
		endif	 
	endfor
endif 