	set step on
*!*	set default to e:\files\buh52
*!*	set classlib to classes\connect
*!*	oRaama = createobject ('connect')
oRaama = createobject ('buh50.connect')
oRaama.workdir = "c:\buh50"
oRaama.odb('20935','vlad','')
if vartype (oRaama.db)='O'
	oRaama.html()
endif
release oRaama
