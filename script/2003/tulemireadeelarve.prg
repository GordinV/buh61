Set step on
Create cursor curKey (versia m)
Append blank
Replace versia with 'EELARVE' in curKey
Create cursor v_account (admin int default 1)
Append blank
gnhandle = sqlconnect ('narva','vladislav','490710')
*!*	&&,'zinaida','159')
gversia = 'MSSQL'
*!*	grekv = 2
&&cdata = 'c:\buh50\dbase\buhdata5.dbc'
*!*	cdata = 'e:\files\buh52\dbase\buhdata5.dbc'
*!*	gnHandle = 2
*!*	gversia = 'VFP'
*!*	Open data (cdata)
grekv = 1
Local lError
If v_account.admin < 1
	Return .t.
Endif
CREATE cursor scrBilanss (nimetus c(254), rea c(20), konto c(254))
insert into scrBilanss (nimetus, rea, konto) values ('Tegevustulud ','1','' )
insert into scrBilanss (nimetus, rea, konto) values ('Tulud eelarvest','1.1','SK(341)')
insert into scrBilanss (nimetus, rea, konto) values ('Tulud majandustegevusest','1.2','SK(312)+SK(313)')
insert into scrBilanss (nimetus, rea, konto) values ('Tulud asutustelt','1.3','SK(321)+SK(322)')
insert into scrBilanss (nimetus, rea, konto) values ('Toetused asutustelt','1.4','SK(351) +SK(352) ')
insert into scrBilanss (nimetus, rea, konto) values ('Toetused juriidilistelt ja fььsilistelt isikutelt','1.5','SK(37)')
insert into scrBilanss (nimetus, rea, konto) values ('Muud tulud tegevusest','1.6','SK(38)')
insert into scrBilanss (nimetus, rea, konto) values ('Tulude korrigeerimine','1.7','SK(39)')
insert into scrBilanss (nimetus, rea, konto) values ('Tegevuskulud','2','')
insert into scrBilanss (nimetus, rea, konto) values ('Palgad ja tasud','2.1','SD(60)')
insert into scrBilanss (nimetus, rea, konto) values ('Sotsiaalmaksukulu','2.2','SD(661)+SD(662)')
insert into scrBilanss (nimetus, rea, konto) values ('Vдljamaksmata puhkusetasu','2.3','SD(6110)')
insert into scrBilanss (nimetus, rea, konto) values ('Muud personalikulud','2.4','SD(62)+SD(63)+SD(64)+SD(65)+SD(67)+SD(68)+SD(6630)')
insert into scrBilanss (nimetus, rea, konto) values ('Majanduskulud','2.5','SD(4)+SD(5)+SK(59)')
insert into scrBilanss (nimetus, rea, konto) values ('Muud tegevuskulud','2.6','SD(591)+SD(592)+SD(593)')
insert into scrBilanss (nimetus, rea, konto) values ('Ьlekanded ja toetused','2.7','SD(75)+SD(77)+SD(7611)+SD(7615)')
insert into scrBilanss (nimetus, rea, konto) values ('PХhivara kulum','3','')
insert into scrBilanss (nimetus, rea, konto) values ('PХhivara kulum','3.1','SD(594)+SD(595) ')
insert into scrBilanss (nimetus, rea, konto) values ('Tegevustulem','4','')
insert into scrBilanss (nimetus, rea, konto) values ('Intressikulu','4.1','REA(1)-REA(2)-REA(3)')
insert into scrBilanss (nimetus, rea, konto) values ('Finantstulud ja -kulud','5','')
insert into scrBilanss (nimetus, rea, konto) values ('Finantstulud','5.1','SK(80)')
insert into scrBilanss (nimetus, rea, konto) values ('Finantskulud','5.2','SD(81)')
insert into scrBilanss (nimetus, rea, konto) values ('Maksude, maksete, loivude ja tasude kogumine','6','')
insert into scrBilanss (nimetus, rea, konto) values ('Tulud maksude kogumisest','6.1','SK(7011)+SK(7111)')
insert into scrBilanss (nimetus, rea, konto) values ('Maksude, maksete, loivude ja tasude ulakandmine','6.2','SK(7019)+SK(7119) ')
insert into scrBilanss (nimetus, rea, konto) values ('Ettevхtte tulumaks','7','')
insert into scrBilanss (nimetus, rea, konto) values ('Ettevхtte tulumaks','7.1','SK(8810)')
insert into scrBilanss (nimetus, rea, konto) values ('Arvestatud tulem','8','')
insert into scrBilanss (nimetus, rea, konto) values ('Arvestatud tulem','8.1','REA(1)+REA(5.1)+REA(6.1)-REA(2)-REA(3)-REA(5.2)-REA(6.2)-REA(7)')

*!*	lError =  _alter_vfp()


Do case
	Case gversia = 'VFP'
*!*			Select qryKey
*!*			Scan for mline(qryKey.connect,1) = 'FOX'
*!*				lcdata = mline(qryKey.vfp,1)
*!*				If file (lcdata)
*!*					Open data (lcdata)
*!*					lcdefault = sys(5)+sys(2003)
*!*					Set DEFAULT TO justpath (lcdata)
				lError =  _alter_vfp()
*!*					Close data
*!*					Set default to (lcdefault)
*!*				Endif
*!*			Endscan
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
&& выборка имеющихся рекв.
select id from rekv into cursor qry_Rekv
&& выборка имеющихся строк баланса
SELECT Library.kood, Library.nimetus, Library.library, Library.id,  Library.rekvid ;
 FROM Library WHERE Library.library LIKE 'TULEM%' into cursor qry_bilanss

select qry_rekv
scan
	select scrBilanss
	scan
		wait window [kontroling..]+scrBilanss.rea timeout 1
		select qry_bilanss
		locate for alltrim(kood) = alltrim(qry_bilanss.kood) and;
			alltrim(upper(nimetus)) = alltrim(upper(qry_bilanss.nimetus))
		if !found ()
			wait window [inserting...]+scrBilanss.rea timeout 1
			
			lcString = " insert into library (rekvid, kood, nimetus, library, MUUD ) values ("+;
				str (qry_rekv.id)+",'"+ ltrim(rtrim(scrBilanss.REA))+"','"+;
				ltrim(rtrim(scrBilanss.nimetus))+"','"+;
				"TULEM','"+ltrim(rtrim(scrBilanss.KONTO)) +"')"
			&lcString
		endif 
	endscan
endscan
use in qry_rekv
use in qry_bilanss
if used ('library')
	use in library
endif
=SETPROPVIEW()
Return

Function setpropview
	lnViews = adbobject (laView,'VIEW')
	For i = 1 to lnViews
		lError = dbsetprop(laView(i),'View','FetchAsNeeded',.t.)
	Endfor
	Return
ENDPROC

Function _alter_mssql

&& выборка имеющихся рекв.
cstring = "select id from rekv "
lError = sqlexec (gnhandle,cString,'qry_rekv')

&& выборка имеющихся строк баланса
cstring = " SELECT Library.kood, Library.nimetus, Library.library, Library.id,  Library.rekvid "+;
" FROM Library WHERE Library.library LIKE 'TULEM%'" 
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
				ltrim(rtrim(scrBilanss.nimetus))+"','TULEM')"

				lError = sqlexec (gnhandle,lcString)
		endif 
	endscan
endscan
use in qry_rekv
use in qry_bilanss
	Return lError
Endproc



