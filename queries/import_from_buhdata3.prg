gnHandle = 0
gRekv = 0
lresult = connect_to_data()
If lresult = .f. or empty(grekv)
	Messagebox('Viga, connect','Kontrol')
	Return
Endif
If !used('buhdata3')
	cData = 'C:\Documents and Settings\Vlad\BUH32\Dbase\buhdata3.dbc'
	Open data (cData)
Endif
=sqlexec(gnHandle,'begin transaction')
&&=import_kontoplaan()
&&=import_asutused()
&&=import_nom()
lnAnswer = messagebox('Kas salvesta',1+16+0,'Kontrol')
If lnAnswer = 1
	lError=sqlexec(gnHandle,'commit transaction')
Else
	lError=sqlexec(gnHandle,'rollback transaction')
Endif
If lError < 1
	Set step on
Endif
=sqldisconnect(gnHandle)
Set data to buhdata3
Close data
Clear all

Function import_nom
if !used('comNomRemote')
	use omadb!comNomRemote in 0
endif
	select left(nom,20) as nom,left(nimi,120) as nimi,hind,left(tukk,20) as tukk from buhdata3!arv_teenused ; 
	union all;
	select distinc left(nom,20) as nom,left(nimi,120) as nimi,price,left(tukk,20) as tukk from buhdata3!arv_main;
	into cursor vana_nom
	use in arv_teenused
	use in arv_main
	select vana_nom
	Scan
		wait window [Importeerin teenused:]+rtrim(vana_nom.nimi)+;
			ltrim(str(recno('vana_nom')))+'/'+ltrim(str(reccount('vana_nom'))) nowait
		Select comNomremote
		if empty(vana_nom.nom)
			locate for left(alltrim(upper(comNomremote.nimetus)),10) == left(alltrim(upper(vana_Nom.nimi)),10)
		else
			locate for left(alltrim(upper(comNomremote.kood)),7) == left(alltrim(upper(vana_Nom.nom)),7)
		endif
		if !found()
			use omadb!v_nomenklatuur in 0 nodata alias v_nom
			lnCurrent = cpDbf('vana_Nom')
			cKood = iif(empty(vana_nom.nom),left(vana_Nom.nimi,10),vana_nom.nom)
			cNimi = CPCONVERT(lnCurrent, 1250, vana_Nom.nimi)
			insert into v_nom (dok,doklausId,hind,kood,nimetus,rekvid,uhik);
				values ('ARV',0,vana_nom.hind,cKood,;
				cNimi, grekv, vana_nom.tukk)
			lresult = tableupdate(1,.t.)
			If lresult = .f.
				Messagebox('Viga','Kontrol')
				Set step on
				Select v_nom
				=tablerevert(.t.)
				Return .f.
			Endif
			use in v_nom
			=requery('comNomRemote')
		endif
	endscan
	select comNomRemote
	browse
return



Function import_asutused
if !used('comasutusRemote')
	use omadb!comasutusRemote in 0
endif
	select * from buhdata3!cl order by coode into cursor vana_asutused
	use in cl
	select vana_asutused
	Scan
		wait window [Importeerin asutus:]+rtrim(vana_asutused.client)+;
			ltrim(str(recno('vana_asutused')))+'/'+ltrim(str(reccount('vana_asutused'))) nowait
		Select comAsutusremote
		locate for alltrim(upper(comAsutusremote.nimetus)) = alltrim(upper(vana_asutused.client))
		if !found()
			use omadb!v_asutus in 0 nodata
			lnCurrent = cpDbf('vana_asutused')
			cClient = CPCONVERT(lnCurrent, 1250, vana_asutused.client)
			cKontakt = CPCONVERT(lnCurrent, 1250, vana_asutused.fam)
			cAadr = CPCONVERT(lnCurrent, 1250, vana_asutused.address)
			insert into v_asutus (aadress,email,faks,kontakt,nimetus,omvorm, regkood, rekvid, tel);
				values (caadr,vana_asutused.email,;
				vana_asutused.fax, cKontakt,;
				cclient,space(10), vana_asutused.regnumber, grekv, vana_asutused.phone)
			lresult = tableupdate(1,.t.)
			If lresult = .f.
				Messagebox('Viga','Kontrol')
				Set step on
				Select v_asutus
				=tablerevert(.t.)
				Return .f.
			Endif
			use in v_asutus
		endif
	endscan
	=requery('comasutusRemote')
	select comasutusRemote
	browse
return

Function import_kontoplaan
	If !used('comKontodremote')
		Use omadb!comKontodremote in 0
	Endif
	Select * from buhdata3!plan order by konto into cursor vana_kontod
	Use in plan
	Select vana_kontod
	Scan
		wait window [Importeerin konto:]+vana_kontod.konto+;
			ltrim(str(recno('vana_kontod')))+'/'+ltrim(str(reccount('vana_kontod'))) nowait
		Select comKontodremote
		Locate for alltrim(comKontodremote.kood) == alltrim(vana_kontod.konto)
		If !found()
			Use omadb!v_library in 0 nodata
			Use omadb!v_kontoinf in 0 nodata
			lnCurrent = cpDbf('vana_kontod')
			cNimi = CPCONVERT(lnCurrent, 1250, vana_kontod.nimi)
			Insert into v_library (kood, library, nimetus, rekvId);
				values (vana_kontod.konto, 'KONTOD',vana_kontod.nimi,gRekv)
			lresult = tableupdate(1,.t.)
			If lresult = .f.
				Messagebox('Viga','Kontrol')
				Set step on
				Select v_library
				=tablerevert(.t.)
				Return .f.
			Endif
			Use omadb!last_library in 0
			lnId = last_library.id
			Use in last_library
			Insert into v_kontoinf (parentid,aasta,algsaldo,formula, type);
				values (lnId,2000,vana_kontod.beg_saldo,vana_kontod.formula,vana_kontod.tyyp)
			lresult = tableupdate(1,.t.)
			If lresult = .f.
				Messagebox('Viga','Kontrol')
				Set step on
				Select v_kontoinf
				=tablerevert(.t.)
				Return .f.
			Endif
			Use in v_library
			Use in v_kontoinf
		Endif
	Endscan
	=requery('comKontodremote')
	Select comKontodremote
	Browse
	Return


Function connect_to_data
	gnHandle = SQLCONNECT('buhdata5')
	If empty(gnHandle) or gnHandle < 1
		Return .f.
	Else
		If !dbused('omadb')
			cData = 'C:\Documents and Settings\Vlad\files\buh52\dbase\omadb.dbc'
			Open data (cData)
		Endif
		Set data to omadb
		=sqlsetprop(gnHandle,'Transaction',2)
		cKasutaja = 'vlad'
		If !used('v_pass')
			Use v_pass in 0
		Endif
		tnid = v_pass.id
		gUserId = v_pass.id
		gRekv = v_pass.rekvId
		If !used('v_profill')
			Use v_profill noupdate excl in 0 alias v_account
		Endif
	Endif
	Return
