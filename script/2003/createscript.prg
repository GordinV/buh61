lcFile = 'e:\files\buh60\dok\eelarve2003\Yldeeskirja lisa 1 Kontoplaan.xls'
Import from  (lcFile) type XL8 sheet kontoplaan as 1252
lnEsimine = 7
* ��������� ������
*1- konto liik, 2 - kontoklass, 3 - kontor�hm, 4 - kontogrupp, 5- kontogrupi alamgrupp, 6- konto
lcAlias = alias()
Create cursor tmpKontoplaan (script m)
Append blank
Replace script with '* kontoplaan'+chr(13) in tmpKontoplaan
Select (lcAlias)
Scan for recno(lcAlias) > lnEsimine
	Select (lcAlias)
	Wait window str (recno(lcAlias))+'/'+str (reccount(lcAlias)) nowait
	Do case
		Case !empty (a)
			lcKood = ltrim(rtrim(evaluate (lcAlias+'.a')))
		Case !empty (b)
			lcKood = ltrim(rtrim(str(evaluate (lcAlias+'.b'))))
		Case !empty (c)
			lcKood = ltrim(rtrim(str(evaluate (lcAlias+'.c'))))
		Case !empty (d)
			lcKood = ltrim(rtrim(str(evaluate (lcAlias+'.d'))))
		Case !empty (e)
			lcKood = ltrim(rtrim(str(evaluate (lcAlias+'.e'))))
		Case !empty (f)
			lcKood = ltrim(rtrim(str(evaluate (lcAlias+'.f'))))
	Endcase
	lcNimetus = ltrim(rtrim(evaluate (lcAlias+'.i')))
	lcTun1 = iif (!empty (j),'1','0') && TP
	lcTun2 = iif (!empty (k),'1','0') && TT
	lcTun3 = iif (!empty (l),'1','0') && A
	lcTun4 = iif (!empty (m),'1','0') && R
	lcTun5 = '0' && Reserv
	lcRekv = '1'
	If !empty (lcKood) and !empty (lcNimetus)
		lcString = "insert into library (kood, nimetus, library, rekvId,tun1,tun2,tun3,tun4,tun5) values ('"+;
			lcKood+"','"+lcNimetus+"','KONTOD',"+lcRekv+","+lcTun1+","+lcTun2+","+lcTun3+","+lcTun4+","+lcTun5+")"+chr(13)
		Replace script with lcString additive in tmpKontoplaan
	Endif
Endscan
Select tmpKontoplaan
if file('scriptLib.prn')
	copy memo tmpKontoplaan.script to scriptLib.prn additive as 1252
else
	copy memo tmpKontoplaan.script to scriptLib.prn  as 1252
endif