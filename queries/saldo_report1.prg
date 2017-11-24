Parameter tcWhere
*!*	if vartype(oDb) <> 'O'
*!*		set classlib to classes\classlib
*!*		oDb = createobject('db')
*!*	endif
*!*	if !used('fltrSaldo')
*!*		return .f.
*!*	endif
*!*	tcKonto = '%'+alltrim(fltrSaldo.konto)+'%'
*!*	tnSaldo1 = iif(empty(fltrSaldo.saldo1),-999999999,fltrSaldo.saldo1)
*!*	tnSaldo2 = iif(empty(fltrSaldo.saldo2),999999999,fltrSaldo.saldo2)
*!*	tnlSaldo1 = iif(empty(fltrSaldo.lsaldo1),-999999999,fltrSaldo.lsaldo1)
*!*	tnlSaldo2 = iif(empty(fltrSaldo.lsaldo2),999999999,fltrSaldo.lsaldo2)
*!*	tnDb1 = iif(empty(fltrSaldo.db1),-999999999,fltrSaldo.db1)
*!*	tnDb2 = iif(empty(fltrSaldo.db2),999999999,fltrSaldo.db2)
*!*	tnKr1 = iif(empty(fltrSaldo.kr1),-999999999,fltrSaldo.kr1)
*!*	tnKr2 = iif(empty(fltrSaldo.kr2),999999999,fltrSaldo.kr2)
*!*	dKpv1 = fltrSaldo.kpv1
*!*	dKpv2 = iif(empty(fltrSaldo.kpv2),date( year( date() ),month( date() ),;
*!*		viimane_paev( year( date() ),month( date() ))),fltrSaldo.kpv2)
select curSaldo
&&oDb.use('curSaldo','Saldo_report1')
select * from curSaldo into cursor Saldo_report1
