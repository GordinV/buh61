IF USED ('curprinter')
	use in curPrinter
endif
use curprinter in 0

select curPrinter
locate for alltrim(objekt) = 'Projektid'
if !found()
	append blank
	replace id with 1,;
		objekt with 'Projektid',;
		Nimetus1 with 'Projetid',;
		nimetus2 with 'Projektid',;
		procfail with 'projekt_report1',;
		reportfail with 'projekt_report1',;
		reportvene with 'projekt_report1' in curprinter		
endif

IF USED ('curprinter')
	use in curPrinter
endif
use eelarve\curprinter in 0

select curPrinter
locate for alltrim(objekt) = 'Projektid'
if !found()
	append blank
	replace id with 1,;
		objekt with 'Projektid',;
		Nimetus1 with 'Projetid',;
		nimetus2 with 'Projektid',;
		procfail with 'projekt_report1',;
		reportfail with 'projekt_report1',;
		reportvene with 'projekt_report1' in curprinter		
endif
