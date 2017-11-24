Parameter tKpv1, tKpv2, tIsik1, tIsik2
oDb.opentransaction()
If gVersia = 'VFP'
	cString = "do sp_calc_palgajaak with "+alltrim(str(gRekv))+", '"+;
		dtoc(tKpv1)+"', '"+dtoc(tKpv2)+"', "+str (tIsik1)+", " + str (tIsik2)
	&cString
	lError = 1
Else
	cString = "sp_calc_palgajaak "+alltrim(str(gRekv))+",'"+dtoc(tKpv1,1)+"','"+;
		dtoc(tKpv2,1)+"', "+str (tIsik1)+"," + str (tIsik2)
	lError = odb.exec (gnhandle,cstring)	
Endif

If lError = .t.
	oDb.commit()
	Messagebox ('Operatsioon on edukalt','Kontrol')
	If vartype (oPalkJaak) = 'O'
		oPalkJaak.requery()
	Endif
Else
	oDb.rollback()
	Messagebox ('Viga','Kontrol')
Endif
