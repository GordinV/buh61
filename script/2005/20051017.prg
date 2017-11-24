=update_curprinter()

RETURN


Function update_curprinter

	lcFile = 'eelarve\curprinter.dbf'
	Use (lcFile) In 0 Alias curPrinter

	Select curPrinter
	LOCATE FOR UPPER(objekt) = UPPER('Uritused') AND id = 1
	IF !FOUND()
		APPEND BLANK
		Replace ID WITH 1, OBJEKT WITH 'Uritused', ;
			nimetus1 WITH 'Uritused ',;
			nimetus2 WITH 'Üritused ', ;
			procfail With 'uritused_report1',;
			reportfail With 'uritused_report1',;
			reportvene With 'uritused_report1' In curPrinter
		
	ENDIF
	 


	Use In curPrinter
	

	lcFile = 'curprinter.dbf'
		Use (lcFile) In 0 Alias curPrinter

	LOCATE FOR UPPER(objekt) = UPPER('Uritused') AND id = 1
	IF !FOUND()
		APPEND BLANK
		Replace ID WITH 1, OBJEKT WITH 'Uritused', ;
			nimetus1 WITH 'Uritused ',;
			nimetus2 WITH 'Üritused ', ;
			procfail With 'uritused_report1',;
			reportfail With 'uritused_report1',;
			reportvene With 'uritused_report1' In curPrinter
		
	ENDIF


	Use In curPrinter


Endfunc

