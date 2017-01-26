

	lcFile = 'eelarve\curprinter.dbf'
	Use (lcFile) In 0 Alias curPrinter

	Select curPrinter
	Locate For Id = 93
	IF FOUND()
		Replace procfail With 'varadearuanne_report3' In curPrinter
	endif

	Use In curPrinter
