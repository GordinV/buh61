If !used('reposit')
	Use reposit in 0
Endif
Select reposit
Set order to
Scan for type = 'CURSOR'
	Wait WINDOW reposit.OBJEKT NOWAIT
	If !EMPTY(reposit.PROP1)
		Restore FROM MEMO reposit.PROP1 ADDITIVE
		For I = 1 TO ALEN(aObjekt,1)
			If vartype(aObjekt(I,2)) = 'C' and aObjekt(I,2) = 'T'
				aObjekt (I,2) = 'D'
			Endif
		Endfor
		Save TO MEMO reposit.PROP1 ALL LIKE aObjekt
		RELEASE AOBJEKT
	Endif
Endscan
