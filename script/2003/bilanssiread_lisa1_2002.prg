SET STEP ON 
Create cursor curKey (versia m)
Append blank
Replace versia with 'EELARVE' in curKey
Create cursor v_account (admin int default 1)
Append blank
*gnhandle = sqlconnect ('buhdata5')
gnhandle = sqlconnect ('narva','VLADISLAV','490710')
*!*	&&,'zinaida','159')
gversia = 'MSSQL'
grekv = 2
*!*	cdata = 'E:\FILES\BUH52\DBASE\BUHDATA5.DBC'
*!*	gnHandle = 1
*!*	gversia = 'VFP'
*!*	&&Open data (cdata)
*!*	grekv = 1
Local lError
If v_account.admin < 1
	Return .t.
Endif
CREATE cursor scrBilanss (nimetus c(254), rea c(20), konto c(254))
insert into scrBilanss (nimetus, rea, konto) values ('Kassa ja pangakontod','1','' )
insert into scrBilanss (nimetus, rea, konto) values ('Kassa','1.1','SD(191)')
insert into scrBilanss (nimetus, rea, konto) values ('Pank','1.2','SD(192)+SD(194)')
insert into scrBilanss (nimetus, rea, konto) values ('Postiziiro kontod','1.3','SD(197)')
insert into scrBilanss (nimetus, rea, konto) values ('Aktsiad ja muud v��rtpaberid','2','SD(181)')
insert into scrBilanss (nimetus, rea, konto) values ('N�uded ostjate vastu','3','')
insert into scrBilanss (nimetus, rea, konto) values ('Ostjatelt laekumata arved','3.1','SD(141)+SD(145)+SD(147)+SD(148)')
insert into scrBilanss (nimetus, rea, konto) values ('Ostjate vekslid','3.2','-1 * SD(149)')
insert into scrBilanss (nimetus, rea, konto) values ('Mitmesugused n�uded','4','')
insert into scrBilanss (nimetus, rea, konto) values ('N�uded t��tajatele','4.1','SD(151)')
insert into scrBilanss (nimetus, rea, konto) values ('Mitmesugused l�hiajalised n�uded','4.2','SD(154)+SD(155)+SD(156)+SD(158)')
insert into scrBilanss (nimetus, rea, konto) values ('Ebat�enaoliselt laekuvad  n�uded ostjatelt (miinus)','4.3','-1 * SD(159)')
insert into scrBilanss (nimetus, rea, konto) values ('Viitlaekumised ','5','')
insert into scrBilanss (nimetus, rea, konto) values ('Laekumata renditulud','5.1','SD(167)')
insert into scrBilanss (nimetus, rea, konto) values ('Laekumata intressitulud','5.2','SD(168)')
insert into scrBilanss (nimetus, rea, konto) values ('Muud viitlaekumised','5.3','SD(169)')
insert into scrBilanss (nimetus, rea, konto) values ('Ettemaksud tulevaste perioodide kulud','6','')
insert into scrBilanss (nimetus, rea, konto) values ('Ettemakstud rendi/��rikulud ','6.1','SD(161)')
insert into scrBilanss (nimetus, rea, konto) values ('Ettemakstud kapitalirent','6.2','SD(162)')
insert into scrBilanss (nimetus, rea, konto) values ('Ettemakstud kindlustuskulud','6.3','SD(163)')
insert into scrBilanss (nimetus, rea, konto) values ('Ettemakstud intressikulud','6.4','SD(164)')
insert into scrBilanss (nimetus, rea, konto) values ('Ettemakstud maksud','6.5','SD(165)')
insert into scrBilanss (nimetus, rea, konto) values ('Muud ettemaksed','6.6','SD(166)')
insert into scrBilanss (nimetus, rea, konto) values ('Varud, l�petamata toodang ja t��d, ettemaksed hankijatele','7','')
insert into scrBilanss (nimetus, rea, konto) values ('Tooraine ja materjali varu','7.1','SD(131)')
insert into scrBilanss (nimetus, rea, konto) values ('L�petamata toodangu varu','7.2','SD(134)')
insert into scrBilanss (nimetus, rea, konto) values ('Valmistoodang','7.3','SD(135)+SD(136)')
insert into scrBilanss (nimetus, rea, konto) values ('L�petamata t��','7.4','SD(137)')
insert into scrBilanss (nimetus, rea, konto) values ('Ettemaksed hankijatele','7.5','SD(138)')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised finantsinvesteeringud (finantsp�hivara)','8','')
insert into scrBilanss (nimetus, rea, konto) values ('Aktsiad ja osad','8.1','SD(121)')
insert into scrBilanss (nimetus, rea, konto) values ('V�lakirjad ja muud v��rtpaberid','8.2','SD(122)')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised n�uded','8.3','SD(123)+SD(124)')
insert into scrBilanss (nimetus, rea, konto) values ('Materiaalne p�hivara','9','')
insert into scrBilanss (nimetus, rea, konto) values ('Maa ja ehitised (soetusmaksumus)','9.1','SD(110)+SD(111)+SK(1119)')
insert into scrBilanss (nimetus, rea, konto) values ('Masinad ja seadmed (soetamismaksumus)','9.2','SD(112)+SK(1129)')
insert into scrBilanss (nimetus, rea, konto) values ('Muu inventar, t��riistad, sisseseade ja muud (soetusmaksumus)','9.3','SD(113)+SD(114)+SD(115)+SD(116)+SD(117)+SK(1139)+SK(1149)+SK(1159)+SK(1179)')
insert into scrBilanss (nimetus, rea, konto) values ('Pohivara kulum (miinusega)','9.4','SD(1119)+SD(1129)+SD(1139)+SD(1149)+SD(1159)+SD(1179)')
insert into scrBilanss (nimetus, rea, konto) values ('L�petamata ehitus','9.5', 'SD(118)')
insert into scrBilanss (nimetus, rea, konto) values ('Materiaalsete p�hivarade ettemaksed','9.6', 'SD(119)')
insert into scrBilanss (nimetus, rea, konto) values ('Immateriaalne p�hivara','10', '')
insert into scrBilanss (nimetus, rea, konto) values ('Asutamisv�ljaminekud','10.1', '')
insert into scrBilanss (nimetus, rea, konto) values ('Arenguv�ljaminekud','10.2', 'SD(102)')
insert into scrBilanss (nimetus, rea, konto) values ('Ostetud patendid, litsentsid, kontsessioonid, kaubam�rgid, rendi�igus jne.','10.3', 'SD(103)+SD(104)+SD(107)+SD(109)')
insert into scrBilanss (nimetus, rea, konto) values ('Immateriaalse pohivara ettemaksed','10.4', 'SD(108)')
insert into scrBilanss (nimetus, rea, konto) values ('L�hiajalised kohustused','11', '')
insert into scrBilanss (nimetus, rea, konto) values ('L�hiajalised laenud','11.1', 'SK(242)')
insert into scrBilanss (nimetus, rea, konto) values ('L�hiajalised kohustused asutustele','11.2', 'SK(244)')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajaliste kohustuste l�hiajaline osa','11.3', 'SK(243)')
insert into scrBilanss (nimetus, rea, konto) values ('L�hiajaline v�lakirjade emiteerimine','11.4', 'SK(245)')
insert into scrBilanss (nimetus, rea, konto) values ('V�lad tarnijatele','11.5', 'SK(247)+SK(248)')
insert into scrBilanss (nimetus, rea, konto) values ('Muud l�hiajalised kohustused','11.6', 'SK(240)+SK(241)+SK(249)+SK(281)+SK(289)')

insert into scrBilanss (nimetus, rea, konto) values ('Ostjate (tellijate) ettemaksed toodete ja kaupade eest','12', '')
insert into scrBilanss (nimetus, rea, konto) values ('Ostjate (tellijate) ettemaksed toodete ja kaupade eest','12.1', 'SK(246)')

insert into scrBilanss (nimetus, rea, konto) values ('Maksukohustused','13', '')
insert into scrBilanss (nimetus, rea, konto) values ('Maksukohustused','13.1', 'SK(256)+SK(257)+SK(258)+SK(259)+SK(262)')

insert into scrBilanss (nimetus, rea, konto) values ('Personali maksukohustused','14', '')
insert into scrBilanss (nimetus, rea, konto) values ('Personali maksukohustused','14.1', 'SK(271)+SK(272)+SK(275)')
insert into scrBilanss (nimetus, rea, konto) values ('Ettemakstud tulevaste perioodide tulud ja aruandeperioodil maksmata kulud','15', '')
insert into scrBilanss (nimetus, rea, konto) values ('Kohustused t��tajatele','15.1', 'SK(292)')
insert into scrBilanss (nimetus, rea, konto) values ('Intressiv�lad','15.2', 'SK(293)')
insert into scrBilanss (nimetus, rea, konto) values ('Muud viitv�lad','15.3', 'SK(297)')
insert into scrBilanss (nimetus, rea, konto) values ('Muud ettemakstud tulevaste perioodide tulud','15.4', 'SK(298)+SK(299)')
insert into scrBilanss (nimetus, rea, konto) values ('L�hiajalised eraldised','16', '')
insert into scrBilanss (nimetus, rea, konto) values ('L�hiajalised eraldised','16.1', 'SK(223)')
*!*	insert into scrBilanss (nimetus, rea, konto) values ('L�hiajalised kohustused kokku','17', '')
*!*	insert into scrBilanss (nimetus, rea, konto) values ('L�hiajalised kohustused kokku','17.1', 'REA')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised v�lakohustused','18', '')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised deposiidid','18.1', 'SK(231)')
insert into scrBilanss (nimetus, rea, konto) values ('V�lg liisingfirmadele','18.2', 'SK(234)')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised tarnijakrediidid','18.3', 'SK(235)')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajaliste v�lakirjade emiteerimine','18.4', 'SK(237)')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised laenud','18.5', 'SK(238)')
insert into scrBilanss (nimetus, rea, konto) values ('Muud pikaajalised kohustused','18.6', 'SK(236)+SK(239)')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised eraldised','19', '')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised eraldised','19.1', 'SK(221)')
*!*	insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised kohustused kokku','20', '')
insert into scrBilanss (nimetus, rea, konto) values ('Kapital','21', '')
insert into scrBilanss (nimetus, rea, konto) values ('Kapital','21.1', 'SK(201)')
insert into scrBilanss (nimetus, rea, konto) values ('Annetatud kapital','21.2', 'SK(204)')
insert into scrBilanss (nimetus, rea, konto) values ('Fondid ja reservid','21.3', 'SK(205)+SK(206)')
insert into scrBilanss (nimetus, rea, konto) values ('Eelmise aasta tulem','21.4', 'SK(208)')
insert into scrBilanss (nimetus, rea, konto) values ('Aruandeaasta tulem','21.5', 'SK(209)')
insert into scrBilanss (nimetus, rea, konto) values ('Bilansiv�lised kirjed','22', '')
insert into scrBilanss (nimetus, rea, konto) values ('Bilansiv�liselt arvestatava vara maksumus','22.1', '')
insert into scrBilanss (nimetus, rea, konto) values ('Erastamise v��rtpaberid ','22.2', '')
insert into scrBilanss (nimetus, rea, konto) values ('Bilansiv�lises arvestuses olevad lootusetud n�uded','22.3', '')
insert into scrBilanss (nimetus, rea, konto) values ('Muud asutuse eriparast tulenevad varad ja kohustused','22.4', '')
If !used ('key')
	Use key in 0
Endif
Select key
lnFields = afields (aObjekt)
Create cursor qryKey from array aObjekt
Select qryKey
Append from dbf ('key')
Use in key
=secure('OFF')


Do case
	Case gversia = 'VFP'
		Select qryKey
		Scan for mline(qryKey.connect,1) = 'FOX'
			lcdata = mline(qryKey.vfp,1)
			If file (lcdata)
				Open data (lcdata)
				lcdefault = sys(5)+sys(2003)
				Set DEFAULT TO justpath (lcdata)
				SET STEP ON
				lError =  _alter_vfp()
				Close data
				Set default to (lcdefault)
			Endif
		Endscan
		Use in qryKey
	Case gversia = 'MSSQL'
		=sqlexec (gnhandle,'begin transaction')
		lError = _alter_mssql ()
		If vartype (lError ) = 'N'
			lError = iif( lError = 1,.t.,.f.)
		Endif
		If lError = .f.
			=sqlexec (gnhandle,'rollback')
		Else
			=sqlexec (gnhandle,'commit')
		Endif
Endcase

*!*	If lError = .f.
*!*		Messagebox ('Viga')
*!*	Endif
If gversia <> 'VFP'
	=sqldisconnect (gnhandle)
Endif
Return lError

Function _alter_vfp
&& ������� ��������� ����.
select id from rekv into cursor qry_Rekv
&& ������� ��������� ����� �������
SELECT Library.kood, Library.nimetus, Library.library, Library.id,  Library.rekvid ;
 FROM Library WHERE Library.library LIKE 'BILANSS%' into cursor qry_bilanss

select qry_rekv
scan
	select scrBilanss
	scan
		select qry_bilanss
		locate for alltrim(kood) = alltrim(scrBilanss.rea) 
		if !found ()
			lcString = " insert into library (rekvid, kood, MUUD, nimetus, library ) values ("+;
				str (qry_rekv.id)+",'"+LTRIM(RTRIM(scrBilanss.rea))+"','"+ltrim(rtrim(scrBilanss.konto))+"','"+;
				ltrim(rtrim(scrBilanss.nimetus))+"','BILANSS')"
			&lcString
		endif 
	endscan
endscan
use in qry_rekv
use in qry_bilanss
if used ('library')
	use in library
endif
	Return

Function setpropview
	lnViews = adbobject (laView,'VIEW')
	For i = 1 to lnViews
		lError = dbsetprop(laView(i),'View','FetchAsNeeded',.t.)
	Endfor
	Return


Function _alter_mssql

&& ������� ��������� ����.
cstring = "select id from rekv "
lError = sqlexec (gnhandle,cString,'qry_rekv')

&& ������� ��������� ����� �������
cstring = " SELECT Library.kood, Library.nimetus, Library.library, Library.id,  Library.rekvid "+;
" FROM Library WHERE Library.library LIKE 'BILANSS%'" 
lError = sqlexec (gnhandle,cString,'qry_bilanss')

select qry_rekv
scan
	select scrBilanss
	scan
		select qry_bilanss
		locate for alltrim(kood) = alltrim(scrBilanss.rea)
		if !found ()
			lcString = " insert into library (rekvid, kood, MUUD, nimetus, library ) values ("+;
				str (qry_rekv.id)+",'"+LTRIM(RTRIM(scrBilanss.rea))+"','"+ltrim(rtrim(scrBilanss.konto))+"','"+;
				ltrim(rtrim(scrBilanss.nimetus))+"','BILANSS')"

				lError = sqlexec (gnhandle,lcString)
		endif 
	endscan
endscan
use in qry_rekv
use in qry_bilanss
	Return lError
Endproc




Function secure
	Lparameters LCENCR
	maxno=100
	LCENCR=UPPER(ALLT(LCENCR))
	If LCENCR<>'ON' AND LCENCR<>'OFF'
		Return MESSAGEBOX("Pass ON or OFF for encryption/decryption!")
	Endif
&&SET PROC TO securedata ADDI
* loop through all fields in a table
	lnFields=FCOUNT()
	For J = 1 TO lnFields
		LCFIELD=FIELD(J)
		Do CASE
			Case TYPE(LCFIELD) $ 'CM'
* replace the all the contents of this particular field
				Repl ALL &LCFIELD WITH CONVRT(LCENCR,&LCFIELD)
		Endcase
	Endfor



Procedure CONVRT
	Lparameters lcencrypt,lcString
	If parameters()<2
		Messagebox('Pass two arguments, [On Off] and string')
		Return
	Endif
	lcencrypt=upper(allt(lcencrypt))
* encrypt data
* take a string and shift the data to the right one place
	If lcencrypt='ON'
		lnlen=len(allt(lcString))
		lcnewstring=''
* convert the string to the value of the current string + the position
* number of the char in the string.  A string of "ABC" would be converted
* to "BDF"

		For i = 1 to lnlen
* asc(substring(lcstring,i,1)) for a "d" is 100
* so if the "d" were in the 1st position it would be converted
* to "e" via the following line
			If i<maxno
				lcchar=chr(asc(substr(lcString,i,1))+i)
			Else
				lcchar=chr(asc(substr(lcString,i,1))+1)
			Endif
*build new string from converted characters
			lcnewstring=lcnewstring+lcchar
		Endfor
		RETVAL=lcnewstring
	Else
		lnlen=len(allt(lcString))
		lcnewstring=''
		For i = 1 to lnlen
* asc(substring(lcstring,i,1)) for a "d" is 100
* so if the "d" were in the 1st position it would be converted
* to "e" via the following line
			If i<maxno
				lcchar=chr(asc(substr(lcString,i,1))-i)
			Else
				lcchar=chr(asc(substr(lcString,i,1))-1)
			Endif

*build new string from converted characters
			lcnewstring=lcnewstring+lcchar
		Endfor
		RETVAL=lcnewstring
	Endif
	Return (RETVAL)



