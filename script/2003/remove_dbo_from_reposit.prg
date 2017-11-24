IF !USED('repositpg')
	USE repositpg IN 0
endif
SELECT repositpg
SET STEP ON on
SCAN FOR 'DBO' $ UPPER(repositpg.prop10)
	lcString = MLINE(repositpg.prop10,1)
	lcDbo = 'dbo.'
	lnStart = ATC(lcString,lcdbo)
	lcString = STUFFC(lcString, lnStart,4,'')
	REPLACE PROP10 WITH lcString IN repositpg
endscan
