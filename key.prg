Parameter tckey
If vartype(tckey) <> 'C' or;
		tckey <> f_key()
	Return
Endif
If !used ('key')
	If !file ('key.dbf')
		Create table key free(tyyp m, algus m, lopp m, uhenda m, versia m, omanik m, connect m, vfp m)
	Else
		Use key in 0
	Endif
Endif
Select key
cString = 'RAAMATUPIDAMINE'+';'+;
	'LADU'+';'+;
	'POHIVARA'+';'+;
	'LADU'
cConnect = 'ODBC'
Append blank

Replace versia with encrypt(f_key(),cString),;
	algus with encrypt(f_key(),dtoc(date(),1)),;
	lopp with encrypt(f_key(),dtoc(gomonth(date(),12*25),1)),;
	connect with encrypt(f_key(),cConnect),;
	uhenda with encrypt(f_key(),'BUHDATA5'),;
	tyyp with encrypt(f_key(),'MEDIUM'),;
	omanik with encrypt(f_key(),'ZUR AS') in key
