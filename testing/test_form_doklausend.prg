Close data all
set multiloc on
set safety off
grekv = 1
gReturn = .f.
oTools = .f.
gVersia = 'VFP'
gnhandle = 1
gcwindow = .f.
glError = .f.
cData = 'e:\files\buh52\dbase\buhdata5.dbc'
open data (cdata)
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
do FORM forms\doklausend with 'ADD',0 
