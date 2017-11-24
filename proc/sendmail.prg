Lparameters tcSendTo, tcSendFrom, tcSubject, tcBody, tcAttachment
Local loConfig As CDO.Configuration, loFlds As Object, loMsg As CDO.Message
IF !USED('config')
	USE config IN 0
ENDIF

lcSmtp = 'smtp.gmail.com'
lcPort = '465'
lnLine = ATCLINE('smtp:',config.muud)
IF lnLine > 0 
	lcSmtp = ALLTRIM(substr(MLINE(config.muud,lnLine),6,254))
ENDIF
lnLine = ATCLINE('port:',config.muud)
IF lnLine > 0 
	lcPort = ALLTRIM(substr(MLINE(config.muud,lnLine),6,254))
ENDIF
lnLine = ATCLINE('user:',config.muud)
IF lnLine > 0 
	lcUser = ALLTRIM(substr(MLINE(config.muud,lnLine),6,254))
ENDIF
IF EMPTY(gMailParool) 
	gMailParool = INPUTBOX('Kasutaja'+ lcUser + ' parool:','mail',gMailParool,5000)	
	IF EMPTY(gMailParool) 
		gMailParool = 'puudub'
	ENDIF
ENDIF
IF gMailParool = 'puudub'
	RETURN .f.
ENDIF



loConfig = Createobject("CDO.Configuration")

loFlds = loConfig.Fields
With loFlds
	.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
	.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = lcSmtp
	.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = VAL(lcPort)
	.Item("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 10
	.Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = .T.
	.Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = lcUser 
	.Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = gMailParool
	.Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 3
	.Update()
ENDWITH
IF EMPTY(tcSendFrom)
	tcSendFrom = lcUser
ENDIF

IF EMPTY(tcSendTo)
	RETURN .f.
ENDIF



*- Create and send the message.
loMsg = Createobject("CDO.Message")

With loMsg
	.Configuration = loConfig
	.To = tcSendTo
	.From = tcSendFrom
	.Subject = tcSubject
	.HTMLBody = tcBody
	IF !EMPTY(tcAttachment) AND FILE(tcAttachment)
		.AddAttachment(tcAttachment)
	ENDIF	
	Try
		.Send()
	Catch To oerr
		Messagebox(oerr.Message)
	Endtry
Endwith
