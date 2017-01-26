lParameter lcFile, loObjekt
local lreturn, cReturnFile
if vartype (lcFile) <> 'C'
	lcFile = 'c:\temp\temp.aspx'
endif
if vartype (loObjekt) = 'O' and vartype (loObjekt.userid) = 'N' and;
		loObjekt.userid > 0

	&& success
	cReturnFile = 'c:\buh50\tmp\good.html'
else
	&& fail
	cReturnFile = 'c:\buh50\tmp\bad.html'
endif
if file(cReturnFile) and !empty (lcFile)
	copy file (cReturnFile) to (lcFile)
	lreturn = .t.
else
	lreturn = .f.
endif
*!*	save to abuh50mem
*!*	set step on
*!*	restore from abuh50mem
*!*	wait window
return lreturn