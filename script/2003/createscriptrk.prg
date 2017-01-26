lcFile = 'e:\files\buh60\dok\eelarve2003\Yldeeskirja lisa 1 Kontoplaan.xls'
*Import From  (lcFile) Type Xl8 Sheet tehingupartnerid As 1252
IF !USED('rk')
	USE ?
endif
lnEsimine = 6
* íà÷àëüíàÿ ñòðîêà
*1- konto liik, 2 - kontoklass, 3 - kontorühm, 4 - kontogrupp, 5- kontogrupi alamgrupp, 6- konto
lcAlias = Alias()
Create Cursor tmpRk (script m)
Append Blank
Replace script With '* rahavoodi kood'+Chr(13) In tmpRk
Select (lcAlias)
Scan For Recno(lcAlias) > lnEsimine AND RECNO(lcAlias) < 12
	Select (lcAlias)
	Wait Window Str (Recno(lcAlias))+'/'+Str (Reccount(lcAlias)) Nowait
	If !Empty(n1)
		lcKood = Ltrim(Rtrim(Evaluate (lcAlias+'.n1')))
		lcNimetus = Ltrim(Rtrim(Evaluate (lcAlias+'.n2')))
		lcTun1 = '0'
		lcTun2 = '0'
		lcTun3 = '0'
		lcTun4 = '0'
		lcTun5 = '0'
		lcRekv = '1'
		If !Empty (lcKood) And !Empty (lcNimetus)
			lcString = "insert into library (kood, nimetus, library, rekvId,tun1,tun2,tun3,tun4,tun5) values ('"+;
				lcKood+"','"+lcNimetus+"','RAHA',"+lcRekv+","+lcTun1+","+lcTun2+","+lcTun3+","+lcTun4+","+lcTun5+")"+Chr(13)
			Replace script With lcString Additive In tmpRk
			&lcString
		Endif
	Endif
Endscan
Select tmpRk
If File('scriptLibRk.prn')
	Copy Memo tmpRk.script To scriptLibRk.prn Additive As 1252
Else
	Copy Memo tmpRk.script To scriptLibRk.prn  As 1252
Endif
