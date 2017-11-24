set memowidth to 8000
Parameter tcAlias, gConnect, tcCursor
if empty(gConnect) 
	if vartype(gnHandle) = 'N' and gnHandle > 0
		gConnect = gnHandle
	else
		gConnect = 0
	endif
endif
if empty(tcAlias)
	tcAlias = alias()
endif
if empty(tcAlias)
	return .f.
endif
if !used('reposit')
	use reposit in 0
endif
select reposit
locate for upper(objekt) = upper(tcAlias) and;
	type = 'CURSOR'
if !found()
	return .f.
endif
cString = reposit.prop2
=insert_real_value()
*!*	nLines = memline(reposit.prop2)
*!*	for i = 1 to nLines
*!*		cString = cString + ltrim(rtrim(reposit.prop2))
*!*		if i < nLines
*!*			cString = cString + chr(13)
*!*		endif
*!*	endfor
if empty(cString)
	return .f.
endif
if empty(tcCursor)  
	if used(tcAlias)
		lcCursor = sys(2015)
	else
		lcCursor = tcAlias
	endif
else
	lcCursor = tcCursor
endif
if empty(gConnect)
	&& Локальный курсор
	lError = 1
	cString = cString + space(1) + ' into cursor '+lcCursor'
	&cString
else
	lError = sqlexec(gConnect,cString,lcCursor)
endif
if lError < 0 or !used(lcCursor)
	return .f.
endif
if lcCursor <> tcAlias
	select (tcAlias)
	if reccount(tcAlias) > 0
		zap
	endif
	append from dbf(lcCursor)
	use in (lcCursor)
endif
return 

Function insert_real_value
cparamlist = rtrim(reposit.prop3)
nCount = OCCURS(';', cParamList) + 1
if nCount > 0
	&&есть параметры
	dimension aParam((nCount),2)
	lnLeft = 1
	for i = 1 to (nCount)
		nWidth = atc(';',cParamlist,i) - lnLeft
		if nWidth <= 0
			if nWidth < 0
				nWidth = len(cParamList) + nWidth + 1
			else
				nWidth = len(cparamList)+1
			endif
		endif
		lcParamList = substr(cParamlist,lnLeft,nWidth)		
		lnWidth = atc(',',lcParamlist) -1 
		aParam(i,1) = left(lcParamList,lnWidth)
		lnLeft = lnLeft + nWidth + 1
		aParam(i,2) = right(lcParamList,len(lcParamList)-(lnWidth+1))
		if !empty(aParam(i,1))
			lValue = &aParam(i,1)
			lcType = &aParam(i,2)
			do case
				case lcType = 'I'
					lvalue = alltrim(str(lValue))
				case lcType = 'N'
					lvalue = alltrim(str(lValue,12,2))
				case lcType = 'F'
					lvalue = alltrim(str(lValue,16,6))
				case lcType = 'B'
					lvalue = alltrim(str(lValue,18,8))
				case lcType = 'Y'
					lvalue = alltrim(str(lValue,12,2))
				case lcType = 'C'
					lvalue = "'"+rtrim(ltrim(lValue))+"'"
				case lcType = 'D'
					lvalue = "'"+dtoc(lValue,1)+"'"					
				case lcType = 'T'
					lvalue = "'"+dtoc(lValue,1)+"'"					
				case lcType = 'L'
					lvalue = iif(lValue = .t.,'.T.','.F.')
			endcase
			lnStart = atc('?'+aParam(i,1),cString)
			lnWidth = len('?'+aParam(i,1))
			cString=STUFF(cString, lnStart, lnWidth, lValue) 
		endif	 
	endfor
endif 