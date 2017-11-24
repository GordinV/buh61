Parameter tcCursor, tcAlias, tlNodata, tlReadOnly
private all
if empty(tcAlias)
	tcAlias = tcCursor
endif
if !used('reposit')
	use reposit in 0
endif
select reposit
locate for upper(objekt) = upper(tcCursor) and;
	type = 'CURSOR'
if !found()
	return .f.
endif 
if used(tcAlias)
	use in (tcAlias)
endif
restore from memo reposit.prop1 additive
create cursor (tcAlias) from array aObjekt
release aObjekt
if empty(tlNodata)
	lErr = dbreq(tcAlias)
endif
return 