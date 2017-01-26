Parameter tcwhere
Create cursor tellimus_report1 (id int, kood c(20), nimetus c(254),;
	uhik c(20), kogus y, asutus c(254), tel c(40), faks c(40),;
	email c(120), aadress m)
*!*	if config.debug = 1
*!*		set step on
*!*	endif
With oDb
	.use ('curNomCritical')
	If reccount ('curNomCritical') < 1
		Use in curNomCritical
		Select tellimus_report1
		Append blank
		Return
	Endif
	.use ('curvaravendor')
	Select curNomCritical
	Scan
		Select comNomremote
		Locate for id = curNomCritical.nomid
		If found ()
			Insert into tellimus_report1 (id, kood, nimetus, uhik, kogus);
				values (comNomremote.id, comNomremote.kood, comNomremote.nimetus,;
				comNomremote.uhik, curNomCritical.MINKOGUS - curNomCritical.kogus)
			Select curvaravendor
			Locate for curvaravendor.nomid = curNomCritical.nomid
			If found ()
				Update tellimus_report1 set ;
					asutus =  curvaravendor.nimetus,;
					tel = curvaravendor.tel,;
					faks = curvaravendor.faks,;
					aadress = curvaravendor.aadress,;
					email = curvaravendor.email ;
					where tellimus_report1.id =curvaravendor.nomid
			Endif
		Endif
	Endscan
	use in curvaraVendor
	Use in curNomCritical
Endwith
Select tellimus_report1
