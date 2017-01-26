_Screen.windowstate = 2
public  gcWindow, glError, lcPath
lcPath = sys(2003)
cKasutaja = ''
Close data all
on error do err
Set UDFPARMS TO VALUE
On SHUTDOWN quit
Set resource off
Set HOURS TO 24
Set compatible off
Set null off
SET AUTOSAVE ON 
set point to '.'
Set help on
Set lock on
Set exclusive off
Set multilock on
Set century on
Set talk off
Set console off
Set notify off
Set safety off
Set delete on
Set date to german
set memowidth to 8000
&&SET HELP TO lepingud.CHM
Use teen_config in 0
if !dbused ('Teendata')
	 =open_data()
endif

do form autoexp_arved to lcReturn
if vartype (lcReturn) = 'C'
	do export_arved with lcReturn
endif
clear events

Function export_arved
Parameter tcWhere
local lResult, lcError
lResult = .t.
lcError = ""
if !dbused ('Teendata')
	lResult = open_data()
endif
if lResult = .f.
	lcError = " ei saa avada andmebaas"
endif
if lResult = .t.
	lResult = arvede_ettevalmistamine()
else
	lcError = " ei saa tabelite ettevalmistada"
endif
if lResult = .t.
	lResult = sendemail_tmp_table_to_buh52()
else
	lcError = " ei saa saada tabelite emailiga"
endif
if used ('tmparv1')
	=kustuta_tmp_table(justpath(dbf('tmparv1')))
endif
if lResult = .t.
	messagebox ('Ok')
else
	messagebox ('Viga '+lcError)
endif
endproc

Procedure err
cError = 'error'
endproc

Function sendemail_tmp_table_to_buh52
local lError
	set classlib to email
	oEmail = createobject('email')
	if !used ('mail')
		release oEmail
		return lError
	endif
	with oEmail
		.SmtpServer = alltrim(teen_config.reserved1)
		.SmtpFrom = alltrim(.checkaddress(alltrim(teen_config.reserved3)))
		.SmtpReply = alltrim(.checkaddress(alltrim(teen_config.reserved3)))
		select mail
		replace smtpto with rtrim(teen_config.reserved2),;
			subject with dtoc(date())+" arved ",;
			attachment with lcPath+'\tmparv1.dbf'+","+lcPath+'\tmparv1.fpt'+","+;
			lcPath+'\tmparv2.dbf'+","+lcPath+'\tmparv2.fpt'+","+lcPath+'\tmparv3.dbf'+","+lcPath+'\tmparv3.fpt'+","+;
			lcPath+'\tmparv4.dbf'+","+lcPath+'\tmparv4.fpt'+","+lcPath+'\tmparv5.dbf'+","+lcPath+'\tmparv5.fpt' in mail
		lError = .send("autoservis")	
		if lError = .f. and !empty (.errmessage)
			lcError = .errmessage
		endif
	endwith	
	use in mail
	release oEmail
	return lError
endproc

Function kustuta_tmp_table
lParameter tcPath
if used ('tmparv1')
	use in tmparv1
endif
lcFile = tcPath+"\tmparv1.*"
if file (lcFile)
	erase (lcFile)
endif
if used ('tmparv2')
	use in tmparv2
endif
lcFile = tcPath+"\tmparv2.*"
if file (lcFile)
	erase (lcFile)
endif
if used ('tmparv3')
	use in tmparv3
endif
lcFile = tcPath+"\tmparv3.*"
if file (lcFile)
	erase (lcFile)
endif
if used ('tmparv4')
	use in tmparv4
endif
lcFile = tcPath+"\tmparv4.*"
if file (lcFile)
	erase (lcFile)
endif
if used ('tmparv5')
	use in tmparv5
endif
lcFile = tcPath+"\tmparv5.*"
if file (lcFile)
	erase (lcFile)
endif
endproc

Function arvede_ettevalmistamine
local lError
	If empty (tcWhere)
		tcWhere = ''
	Endif
	cString = "select * from teendata!arved "+;
		iif (!empty(tcWhere)," where "+tcWhere,"")+;
		" into table tmparv1 "
	&cString
	select * from teendata!arvedlisa;
		where arveId in (select num from tmparv1);
		into table tmparv2 
	select * from teendata!teenus where num in (select teenusid from tmparv2);
	into table tmparv3
	select * from teendata!tasumine where arvedId in (select num from tmparv1);
	into table tmparv4
	select * from teendata!teelja where num in (select teeljaId from tmparv1);
	into table tmparv5
	
	if used ('arved')
		use in arved
	endif
	if used ('arvelisa')
		use in arvedlisa
	endif
	if used ('teenus')
		use in teenus
	endif
	if used ('tasumine')
		use in tasumine
	endif
	if used ('teelja')
		use in teelja
	endif
	lcPath = justpath(dbf('tmparv1'))
	use in tmparv1
	use in tmparv2
	use in tmparv3
	use in tmparv4
	use in tmparv5
	if file ('tmparv1.dbf')
		lError = .t.
	endif
	Return lError
endproc

Function open_data
	Local cData, lError
	If !used('dblist')
		Use dblist in 0 shared
	Endif
	Select dblist
	Locate for not empty (dblist.default) .and.;
		'TEENDATA' $ dblist.address
	If found()
		lcData = rtrim(dblist.address)
		If file (lcData)
			If dbused('TEENDATA')
				Set database to teendata
				Close databases
			Endif
			ldblist = dbf('dblist')
			Open database (lcData) shared validate
			Set database to (lcData)
			lError = .t.
		endif
	endif
	Return lError
endproc

