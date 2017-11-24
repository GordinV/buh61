*!*	text
*!*	create cursor curImport (fail m)

*!*	cFile = getfile ('TXT')
*!*		select curImport
*!*		append blank

*!*		append memo curImport.fail from (cFile)
*!*	end text

*modi memo curImport.fail
for i = 1 to memlines(curImport.fail)
	lcString = Mline(curImport.fail,i)
	for lnOccurs = 1 to 10 
		if atc("'",lcString,lnOccurs) > 0 
			wait window 'found'+str(atc("'",lcString,lnOccurs))+str(len(lcString))
			lcString = stuffc(lcString,atc("'",lcString,lnOccurs),1,space(1))
		else
			exit
		endif
	endfor
endfor