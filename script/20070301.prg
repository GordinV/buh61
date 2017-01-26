

	lcFile = 'eelarve\curprinter.dbf'
	Use (lcFile) In 0 Alias curPrinter

	Select curPrinter
	Locate For ALLTRIM(objekt) = 'Arved' AND Id = 5
	IF !FOUND()
		INSERT INTO curPrinter (id, objekt, Nimetus1,nimetus2,procfail, reportfail,reportvene);
			VALUES (5, 'Arved','Оборотно-сальдовая ведомость','Kaibeandmik','eelarve\kaibesaldo_report1',;
			'eelarve\kaibesaldo_report1','eelarve\kaibesaldo_report1')
	endif

	Use In curPrinter
