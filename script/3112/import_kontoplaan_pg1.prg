Create Cursor m_kontoplaan (txt m)
Append Blank
lcFile = Getfile()

If Empty(lcFile)
	Return
Endif
gnhandle = SQLConnect('pg60')
If gnhandle < 0
	Messagebox('Viga')
	Return
Endif
=SQLEXEC(gnhandle, 'begin work')
Append Memo m_kontoplaan.txt From (lcFile)
For i = 1 To Memlines(m_kontoplaan.txt)
	lcString = Mline(m_kontoplaan.txt,i)
	If Left(Alltrim(lcString),1) <> '*' AND 'TP' $ lcString 
		If !Empty(lcString)
			lError = SQLEXEC(gnhandle,lcString)
			If lError < 1
				Set Step On
				Exit
			Endif
		Endif
	Endif
Endfor
If lError < 1
	=SQLEXEC(gnhandle,'rollback work')
	Messagebox('Viga')
Else
	=SQLEXEC(gnhandle,'commit work')
	Messagebox('Ok')
Endif
=SQLDISCONNECT(gnhandle)