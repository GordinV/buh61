Close data all
set multiloc on
set safety off
grekv = 1
gReturn = .f.
oTools = .f.
gVersia = 'VFP'
gUserid = 1
gnhandle = 1
gcwindow = .f.
glError = .f.
&&cData = 'e:\files\buh52\dbase\buhdata5.dbc'
&&open data (cdata)
Use menuitem IN 0
Use menubar IN 0
Use config IN 0

Set classlib to classes\classlib
oDb = createobject('db')
oDb.login = 'VLAD'
oDb.pass = ''

Create cursor curKey (versia m)
Append blank
Replace versia with 'RAAMA' in curKey
Create cursor v_account (admin int default 1)
append blank
lcDir = curdir ()
DO PROC\open_lib
&&do FORM forms\doklausend with 'ADD',0 

otasudok = newobject('tasudok','tasudok')
tnid = 64
set procedure to proc
odb.use ('v_palk_oper')
With otasudok
	lnKassaPank = .kassapank
	If 	.kassapank = 2 && не определено куда идет выплата
		lnKassaPank = .isKassa (v_palk_oper.journalId,8)
	Endif
	.arvid = v_palk_oper.id
	If 	lnkassapank = 2 
		do form forms\valiTasuLiik to lnKassaPank
		do case
			case lnKassaPank = 1 && mk
				.kassaPank = 1
				if v_palk_oper.summa > 0
					.uusMkPalk(.t.)
				endif
			case lnKassaPank = 2 && kassa
				.kassaPank = 0				
				if v_palk_oper.summa > 0
					.uusVorderpalk(.t.)
				endif
			otherwise
				.kassaPank = 2
				return
		endcase
	endif
	
Endwith
