*Parameters UrlName
UrlName = 'ftp.avpsoft.ee/temp'
lcUser = 'webmaster'
lcparool = '654'

*!*		Declare INTEGER InternetOpenUrl IN wininet.DLL ;
*!*			INTEGER hInternetSession, STRING sUrl, STRING sHeaders, ;
*!*			INTEGER lHeadersLength, INTEGER lFlags, INTEGER lContext

*!*		Declare INTEGER InternetReadFile IN wininet.DLL INTEGER hfile, ;
*!*			STRING @sBuffer, INTEGER lNumberofBytesToRead, INTEGER @lBytesRead

Declare Integer InternetOpen In wininet.Dll String sAgent, ;
	INTEGER lAccessType, String sProxyName, ;
	STRING sProxyBypass, Integer lFlags

Declare Integer InternetConnect In wininet.Dll Long  hInternetSession ,;
	string sServerName, Integer nServerPort,   String sUserName,;
	string sPassword,  Long nService,  Long dwFlags,  Long dwContext


 Declare integer FtpPutFile in wininet.dll long hFtpSession, string lpszLocalFile,;
   string lpszRemoteFile , long dwFlags, long dwContext


 Declare integer FtpDeleteFile in wininet.dll long hFtpSession, string lpszFileName 



Declare short InternetCloseHandle In wininet.Dll Integer hInst

#Define INTERNET_OPEN_TYPE_PRECONFIG 0
#Define INTERNET_OPEN_TYPE_DIRECT 1
#Define INTERNET_OPEN_TYPE_PROXY 3
#Define SYNCHRONOUS 0
#Define INTERNET_FLAG_RELOAD 2147483648
#Define CR Chr(13)
#Define INTERNET_SERVICE_FTP = 1


hInternetSession = InternetOpen("ReklmaksFTP", INTERNET_OPEN_TYPE_PRECONFIG,'', '', SYNCHRONOUS)

hSession = InternetConnect(hInternetSession, "ftp.avpsoft.ee", 21, "webmaster", "654", 1,  0, 0)
Set Step On

lResult =  FtpPutFile(hSession, "c:\temp\test.sql", "temp/temp.sql", 2, 0) 

WAIT WINDOW 'Ok'

lResult =  FtpDeleteFile(hSession, "temp/sp_calc_dekl.sql") 


* close all the handles we opened
=InternetCloseHandle(hSession)
=InternetCloseHandle(hInternetSession)
