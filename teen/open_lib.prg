*!*	set data to omadb
If gversia = 'VFP'
	Set data to buhdata5
Endif
If vartype(odb) <> 'O'
	Set classlib to classes\classlib
	odb = createobject('db')
Endif
=openView('comaaRemote')
=openView('comallikadremote')
Index on id tag id
Index on kood tag kood
=openView('comartikkelremote')
Index on id tag id
Index on kood tag kood
=openView('comasutusRemote')
Index on id tag id
Index on regkood tag regkood
Index on left(upper(nimetus),40) tag nimetus
=openView('comdokRemote')
Index on id tag id
Index on kood tag kood
=openView('comdoklausremote')
=openView('comkassaRemote')
=openView('comkontodRemote')
Index on id tag id
Index on kood tag kood
=openView('comlausendRemote')
Index on id tag id
=openView('comlausheadremote')
=openView('comnomRemote')
Index on id tag id
Index on kood tag kood
=openView('comobjektRemote')
Index on id tag id
Index on kood tag kood
=openView('comrekvRemote')
=openView('comtegevremote')
Index on id tag id
Index on kood tag kood
=openView('comtunnusRemote')
Index on id tag id
Index on kood tag kood
=openView('comArvRemote')
=openView('comAuto')
=openView('comvastIsik')
Return


Function openView
	Lparameter tcView
	If vartype(odb) <> 'O'
		Set classlib to classlib
		odb = createobject('db')
	Endif
	With odb
		If !used(tcView)
			.use(tcView,tcView,.f.,gnHandle)
		Else
			.dbreq(tcView,gnHandle,tcView)
		Endif
		Select (tcView)
	Endwith
