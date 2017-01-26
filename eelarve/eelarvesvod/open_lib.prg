*!*	set data to omadb
if gversia = 'VFP'
	set data to buhdata5
endif
if vartype(odb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
=openView('comallikadremote')
=openView('comartikkelremote')
=openView('comobjektRemote')
=openView('comrekvRemote')
=openView('comtegevremote')
return


Function openView
lParameter tcView
if vartype(oDb) <> 'O'
	set classlib to classlib
	oDb = createobject('db')
endif
if !used(tcView)
	oDb.use(tcView,tcView,.f.,gnHandle)
else
	oDb.dbreq(tcView,gnHandle,tcView)
endif