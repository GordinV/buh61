lnParentid = journal1.parentid
set step on
select asutusid,  year(journal.kpv) as aasta, journal.rekvid from journal where journal.id = lnparentid into array aParent
if vartype (aParent) = 'U' or alen(aParent,1) < 1
	glError = .t.
	return .t.
endif
if aParent(1,1) > 0
	select comLausendRemote
	lcOrder = order()
	set order to id
	seek journal1.lausendId
	if !empty (lcOrder)
		set order to (lcOrder)
	endif
	select comKontodRemote
	lcOrder = order()
 	set order to kood
 	seek comLausendRemote.deebet
	lnKontoId = comKontodRemote.id
	select id from subkonto where kontoid = lnKontoid and asutusId = aParent(1,1) and rekvid = gRekv into array aSubkonto
	if vartype (aSubkonto) = 'U' or alen(aSubkonto,1) < 1
		select subkonto
		append blank
		replace algsaldo with 0,;
			rekvid with grekv,;
			aasta with aParent(1,2),;
			kontoid with lnKontoId,;
			asutusid with aParent(1,1) in subkonto
*!*			insert into subkonto (algsaldo, rekvid, aasta, kontoid, asutusid) values (0, gRekv, aParent(1,2),;
*!*				 lnkontoid, aParent(1,1))
	endif
	select comKontodRemote
 	seek comLausendRemote.kreedit
	lnKontoId = comKontodRemote.id
	select id from subkonto where kontoid = lnKontoid and asutusId = aParent(1,1) and rekvid = gRekv into array aSubkonto
	if vartype (aSubkonto) = 'U' or alen(aSubkonto,1) < 1
		insert into subkonto (algsaldo, rekvid, aasta, kontoid, asutusid) values (0, gRekv, aParent(1,2),;
			 lnkontoid, aParent(1,1))
	endif
	if !empty (lcOrder)
		select comKontodRemote
		set order to (lcOrder)
	endif
	if used ('subkonto')
		use in subkonto
	endif
	release aParent
	release aSubkonto
endif
endproc
