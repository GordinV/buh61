Parameter tnId
* Vara kaart

If Vartype (tnId) = 'C'
	tnId = Val(tnId)
Endif
If Empty (tnId) And Used ('curVara')
	tnId = curVara.Id
Endif


* vara detailt

lcString = " select n.kood, n.nimetus, n.uhik, n.muud, g.valid, g.sahharid, g.rasv, g.vailkaine "+;
" from nomenklatuur n inner join varaitem v on n.id = v.nomid "+;
" inner join LADU_GRUPP g on n.id = g.nomid "+;
" where n.rekvid = "+ str(gRekv) + " and n.dok = 'LADU' and g.parentid = " + str(tnId)

lError = odb.execsql(lcString, 'tmpVara')

if !empty (lError)
	lcString = " select n.id,l.kood as gruppikood, l.nimetus as grupp, n.kood, n.nimetus, n.uhik, n.muud, g.valid, g.sahharid, g.rasv, g.vailkaine "+;
		" from nomenklatuur n inner join LADU_GRUPP g on n.id = g.nomid inner join library l on l.id = g.parentid "+;
		" where n.rekvid = "+ str(gRekv) + " and n.dok = 'LADU' and n.id = " + str(tnId)

	lError = odb.execsql(lcString, 'tmpVaraKond')

endif


if !empty (lError) and used('tmpVara') and used('tmpVaraKond')
	create cursor varade_report1 (gruppikood c(20), grupp c(254), kood c(20), nimetus c(254), uhik c(20), kogus y, muud m,kalor y,sahharid y, rasv y, vailkaine y,;
		grupp c(254), kondkood c(20), kondnimetus c(254), kondkogus y, kondmuud m) 

	if reccount('tmpVara') = 0
		* on ingrediented
		select tmpVara
		scan
			insert into varade_report1 (gruppikood, grupp, kood, nimetus, uhik, kogus, muud,kalor, sahharid, rasv, vailkaine,;
				kondkood, kondnimetus, kondkogus, kondmuud ) values ;
				(tmpVaraKond.gruppikood, tmpVaraKond.grupp, tmpVara.kood, tmpVara.nimetus, tmpVara.uhik, tmpVara.kogus, tmpVara.muud, tmpVara.kalor,;
				tmpVara.sahharid, tmpVara.rasv, tmpVara.vailkaine, ;
				tmpVaraKond.kood, tmpVaraKond.nimetus, tmpVaraKond.kogus, tmpVaraKond.muud) 

		endscan
	else
		insert into varade_report1 (gruppikood, grupp, kalor, sahharid, rasv, vailkaine,kondkood, kondnimetus, kondkogus, kondmuud ) values ;
			(tmpVaraKond.gruppikood, tmpVaraKond.grupp, tmpVaraKond.kalor,tmpVaraKond.sahharid, tmpVaraKond.rasv, tmpVaraKond.vailkaine, ;
			tmpVaraKond.kood, tmpVaraKond.nimetus, tmpVaraKond.kogus, tmpVaraKond.muud) 
	
	endif
	
else
	select 0
	return .f.
endif



