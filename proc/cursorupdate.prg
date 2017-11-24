Set step on

*!*	lError = use('v_journal','v_journal',.T.)
gnHandle = sqlconnect('buhdata5')
select v_journal
Browse
=cursorupdate('v_journal')
=sqldisconnect(gnHandle)


Function cursorupdate
	Parameter tcAlias, tcCursor, gConnect
&&	Private all
	If empty(tcAlias)
		tcAlias = alias()
	Endif
	If empty(tcCursor)
		tcCursor = tcAlias
	Endif
	if empty(gConnect)
		if !empty(gnHandle)
			gConnect = gnHandle
		else
			return .f.
		endif
	endif
	If !used(tcAlias)
		Return .f.
	Endif
	If !used('reposit')
		Use reposit in 0
	Endif
	Select reposit
	Locate for upper(objekt) = upper(tcCursor) and;
		type = 'CURSOR'
	If !found()
		Return .f.
	Endif
	lnParent = reposit.id
	cKey = ''
	Locate for parentId = lnParent and;
		mline(reposit.prop9,1) = '.T.'
	If found()
		cString = ''
		cKey = ltrim(rtrim(tcCursor))+'.'+ltrim(rtrim(reposit.objekt))
		lnKeyId = reposit.id
		lValue = &cKey
		cKey = rtrim(mline(reposit.prop10,1))
		If !empty(lValue)
			cKeyValue = get_value()
&& update
			cString = 'UPDATE '+juststem(cKey)+' SET '
			lcField = ''
			Select reposit
			Scan for parentId = lnParent and ;
					mline(reposit.prop9,1) <> '.T.' and;
					mline(reposit.prop8,1) = '.T.'
				lcField = iif(!empty(lcField),",",'')+mline(reposit.prop10,1)
				If !empty(lcField)
					cString = cString + lcField + '='+get_value()
				Endif
			Endscan
			cString = cString + ' WHERE '+cKey +'='+cKeyValue
		Else
&& insert
			cString = 'INSERT INTO '+juststem(cKey)+' ('
			Select reposit
			lcField = ''
			cInsert = ''
			cValues = ''
			Scan for parentId = lnParent and ;
					mline(reposit.prop9,1) <> '.T.' and;
					mline(reposit.prop8,1) = '.T.' and;
					!empty(mline(reposit.prop10,1))
					lcField = mline(reposit.prop10,1)
				If !empty(lcField)
					cInsert = cInsert + iif(!empty(cInsert),",",'')+lcField 
					cValues = cValues + iif(!empty(cValues),",",'')+get_value()
				Endif
			Endscan
			cInsert = cInsert + ')'
			cValues = cValues + ')'
			cString = cString + cInsert +' VALUES ('+ cValues 
		Endif
	Endif
*!*		CREATE cursor test (test m)
*!*		insert into test (test) values (cString)
*!*		modi memo test
*!*		use in test
	lError = sqlexec(gConnect,cString)
	if lError < 1
		_cliptext = cString
		set step on
	endif
	Select (tcAlias)
	return lError
	endproc
	


Function get_value
	Parameter tnId
	if !empty(tnid)
		select reposit
		locate for id = reposit.id
	endif
	cType = mline(reposit.Prop1,1)
	lcValue = ltrim(rtrim(tcCursor))+'.'+ltrim(rtrim(reposit.objekt))
	lcValue = &lcValue
	Do case
		Case cType = 'I'
			lcValue = ltrim(str(lcValue))
		Case cType = 'N'
			lnWidth = val(alltrim(mline(reposit.prop2,1))
			lnDec = val(alltrim(mline(reposit.prop3,1))
			lcValue = ltrim(str(lcValue,lnWidth,lnDec))
		Case cType = 'F'
			lnWidth = val(alltrim(mline(reposit.prop2,1))
			lnDec = val(alltrim(mline(reposit.prop3,1))
			lcValue = ltrim(str(lcValue,lnWidth,lnDec))
		Case cType = 'B'
			lnWidth = val(alltrim(mline(reposit.prop2,1))
			lnDec = val(alltrim(mline(reposit.prop3,1))
			lcValue = ltrim(str(lcValue,lnWidth,lnDec))
		Case cType = 'Y'
			lnWidth = val(alltrim(mline(reposit.prop2,1))
			lnDec = val(alltrim(mline(reposit.prop3,1))
			lcValue = ltrim(str(lcValue,lnWidth,lnDec))
		Case cType = 'C'
			lcValue = "'"+ltrim(rtrim(lcValue))+"'"
		Case cType = 'M'
			lcValue = "'"+ltrim(rtrim(lcValue))+"'"
		Case cType = 'L'
			lcValue = iif(lcValue = .t.,'.T.','.F.')
		Case cType = 'D'
			lcValue = "'"+dtoc(lcValue,1)+"'"
		Case cType = 'G'
		Case cType = 'T'
			lcValue = "'"+ttoc(lcValue,1)+"'"
		Otherwise
			lcValue = ''
	Endcase

	Return lcValue

Function use
	Parameter tcCursor, tcAlias, tlNodata, tlReadOnly
	Private all
	If empty(tcAlias)
		tcAlias = tcCursor
	Endif
	If !used('reposit')
		Use reposit in 0
	Endif
	Select reposit
	Locate for upper(objekt) = upper(tcCursor) and;
		type = 'CURSOR'
	If !found()
		Return .f.
	Endif
	If used(tcAlias)
		Use in (tcAlias)
	Endif
	Restore from memo reposit.Prop1 additive
	Create cursor (tcAlias) from array aObjekt
	Release aObjekt
	If empty(tlNodata)
		lErr = dbreq(tcAlias)
	Endif
	Return
