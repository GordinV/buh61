Parameter tcFolder, tcFile, tcArhiiv, tcBackup
if empty (tcFolder) and gVersia = 'VFP' 
	tcFolder = justpath(ltrim(rtrim(curkey.vfp)))
endif
if empty (tcFolder)
	return .f.
endif
if empty (tcFile)
	tcFile = '*.*'
endif
tcArhiiv = iif (empty (tcArhiiv),'arhiiv'+alltrim(str(curkey.id))+'zip',tcArhiiv)
if empty (tcbackup)
	tcbackUp = 'BACKUP'
endif
if !directory (tcbackUp)
	mkdir (tcbackup)
endif
! /N 7z a -tzip &tcArhiiv &tcBackup
lcFile = ltrim(rtrim(tcBackUp))+'.'+ltrim(rtrim(tcArhiiv))
if file (lcFile)
	return .t.
else
	return .f.
endif

