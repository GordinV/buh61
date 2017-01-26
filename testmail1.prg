LOCAL loConfig AS CDO.Configuration, loFlds AS Object, loMsg AS CDO.Message

loConfig = CREATEOBJECT("CDO.Configuration")

loFlds = loConfig.Fields

WITH loFlds

*- Set the CDOSYS configuration fields to use port 25 on the SMTP server.

.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2

*- Enter name or IP address of remote SMTP server.

.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.gmail.com"

.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 465

*- Assign timeout in seconds

.Item("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 10

.Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = .t.

*- Commit changes to the object

.Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = "vladislav.gordin"

.Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "490710Vlad"

.Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 3

* .item("http://schemas.microsoft.com/cdo/configuration/cdoURLProxyServer") = "smtp.mail.yahoo.com"

.Update()

ENDWITH

*- Create and send the message.

loMsg = CREATEOBJECT("CDO.Message")

WITH loMsg

.Configuration = loConfig

.To = "vladislav@datel.ee"

.From = "vladislav.gordin@gmail.com"

.Subject = "This is a test of CDO sending e-mail"

.HTMLBody = "This is the HTML content of the mail message"

.AddAttachment("c:\temp\mailer.log")

*- Set priority to HIGH if needed

*!* IF tlUrgent

*!* .Fields("Priority").Value = 1 && -1=Low, 0=Normal, 1=High

*!* .Fields.Update()

*!* ENDIF

TRY

.Send()

CATCH TO oerr

MESSAGEBOX(oerr.message)

ENDTRY

ENDWITH