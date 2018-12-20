Lparameters l_from, l_to, l_sbj, l_text, l_attachment, l_sendusing, l_smtp, l_ssl, l_port, l_auth, l_user, l_pass

Local l_test, loCdoMessage, loConfig
WAIT WINDOW 'Saadan email ...' nowait
If Empty(l_sendusing)
	l_sendusing = 2
Endif

If Empty(l_ssl)
	l_ssl = .F.
Endif

If Empty(l_port)
	l_port = 25
Endif

If Empty(l_auth)
	l_auth = 0
Endif

*

*l_test = .T.
If l_test
	l_from = "vladislav.gordin@gmail.com"
	l_to = "vladislav.gordin@bs2.ee"
	l_text = "test body meke"
	l_attachment = "c:\temp\arve_report1.pdf"
	l_sendusing = 2
	l_smtp = "smtp.gmail.com"
	l_ssl = .T.
	l_port = 465
	l_auth = 1
	l_user = "vladislav.gordin@gmail.com"
	l_pass = "Vlad490710A"
	l_sbj = 'subject'
Endif

*SET STEP ON 
loConfig = Createobject('CDO.Configuration')

loCdoMessage = Createobject("CDO.Message")

With loCdoMessage
	.Configuration = loConfig
	.From = l_from
	.To =  l_to
	.HtmlBody = l_text
	.Subject = l_sbj
	.Addattachment(l_attachment)
Endwith

With loConfig.Fields
	.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2

	.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = l_smtp

	.Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = l_ssl

	.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = l_port
	.Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = l_auth

	If Empty(l_user)
		.Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = "vladislav.gordin@gmail.com"
		.Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "Vlad490710A"
	ELSE
		.Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = l_user
		.Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = l_pass
	
	Endif

	.Item("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60

	.Update

Endwith


loCdoMessage.Send()
WAIT WINDOW  'Saadan email ...tehtud' nowait
RETURN .t.