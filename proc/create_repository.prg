gRekv = 0
cPath = getdir()
set path to (cPath)
Set memowidth to 254
cData = getfile('DBC')
If empty(cData)
	Return .f.
Endif
Open data (cData)
nObjekt = adbObjects(aViews,'VIEW')
If nObjekt < 1
	Messagebox('No objekt in database','Kontrol')
	Return .f.
Endif
For i = 1 to alen(aViews,1)
	lcObjekt = upper(aViews(i))
	if lcObjekt = upper('qryavans3')
		lError = fill_view (lcObjekt)
	endif
Endfor

Function fill_view
	Lparameter tcObjekt
	Local cSql, cParameter, lnFields, lnParent, lnId, nCount
	If !used('reposit')
		If !file('reposit.dbf')
			=create_repository()
		Else
			Use reposit in 0 
		Endif
	Endif
	Select reposit
	If order() <> 'OBJEKT'
		Set order to objekt
	Endif
	Locate for objekt = tcObjekt and type = 'CURSOR'
	If !found()
		if used('tblStruct')
			use in tblStruct
		endif
		Use (tcObjekt) in 0 alias tblStruct nodata
		if !used('tblStruct')
			return .f.
		endif
		select tblStruct
		lnFields = aFields(aObjekt)
		If lnFields < 1
			Return .f.
		Endif
		cSql = dbgetprop(tcObjekt,'VIEW','SQL')
		cParameter = dbgetprop(tcObjekt,'VIEW','ParameterList')
		lnId = get_last_id()
		Insert into reposit (id, objekt, type,Prop2, Prop3);
			values (lnId, upper(tcObjekt), 'CURSOR',cSql,cParameter)
		Save to memo reposit.prop1 all like aObjekt
		lnParent = lnId
		For nCount = 1 to lnFields
			cField = aObjekt(nCount,1)
			Select reposit
			Locate for objekt = cField and type = 'FIELD' and parentId = lnparent
			If !found()
				cUpdate = dbgetprop(RTRIM(tcObjekt)+'.'+cField,'FIELD','Updatable')		
				cUpdate = iif(cUpdate = .t.,'.T.','.F.')
				cKey = dbgetprop(RTRIM(tcObjekt)+'.'+cField,'FIELD','KeyField')		
				cKey = iif(cKey = .t.,'.T.','.F.')
				
				Insert into reposit (id, parentId, objekt, type, prop1, Prop2, Prop3, prop4, prop5, prop6,; 
					prop7,prop8, prop9, prop10);
					values (get_last_id(), lnParent, aObjekt(nCount,1),'FIELD',aObjekt(nCount,2),STR(aObjekt(nCount,3)),;
					STR(aObjekt(nCount,4)),IIF(aObjekt(nCount,5)=.T.,'.T.','.F.'), aObjekt(nCount,7),;
					aObjekt(nCount,8), aObjekt(nCount,9), cUpdate, cKey, dbgetprop(RTRIM(tcObjekt)+'.'+cField,;
					'FIELD','UpdateName'))
			Endif
		Endfor
	Endif
	If used('tblStruct')
		Use in ('tblStruct')
	Endif
	Return

Function get_last_id
	Local lnreturn
	lnreturn = 1
	Select top 1 id from reposit order by id desc into array alast
	If vartype(alast) <> 'U'
		lnreturn = alast(1,1) + 1
	Endif
	Release alast
	Return lnreturn

Function create_repository
	Create table reposit free (id int, parentId int, objekt c(50), type c(50),prop1 m, Prop2 m, Prop3 m, prop4 m,;
		prop5 m, prop6 m, prop7 m, prop8 m, prop9 m, prop10 m, prop11 m, prop12 m)
	Index on objekt tag objekt
	Index on parentId tag parentId
	Return
