If !used('cl1_')
	Return .f. && отказ от расчета
Endif
Select distinc coode, client from cl1_ into cursor Calc1_
Scan
	Wait window [Arvestan : ]+trim(Calc1_.client) nowait
	=DelOldcalc(Calc1_.coode)
	Select cl1_
	Scan for cl1_.coode = Calc1_.coode
		Select * from palkdata!palk_lib;
			where toimikId = cl1_.toimikId;
			into cursor Calc0_
		Scan
			=palkarv(Calc0_.code, cl1_.coode, cl1_.toimikId)
		Endscan
		=calcTulumaks(cl1_.coode, cl1_.toimikId)
		=calcSotsmaks(cl1_.coode,cl1_.toimikId)
	Endscan	
	=muudkinni(calc1_.coode)
Endscan
Wait window [Arvestamine on loppetatud] nowait
Use in cl1_
Use in Calc1_
If type('oPalgakaart') = 'O' .and. !isnull(oPalgakaart)
	lnCoode = oPalgakaart.lastnum
	oPalgakaart.requery(lnCoode)
Endif
If type('oArvestatud') = 'O' .and. !isnull(oArvestatud)
	oArvestatud.requery
Endif

Function saldo
lcProc = 'proc\mycalc.prg'
Set procedure to (lcProc)
=calc_tasumine(calc1_.Coode,gcPeriod)
set procedure to
return

Function muudkinni
lParamete tnIsik
lcProc = 'proc\mycalc.prg'
Set procedure to (lcProc)
=calc_muud_kinni(tnIsik, gcPeriod)
=calc_full_kinni(tnIsik, gcPeriod)
set procedure to
return

Function DelOldcalc
	Lparameter tnCoode
	Delete from palkdata!palk_arv where coode = tnCoode .and. period = gcPeriod .and. empty(palk_arv.tunnus)
	Use in palk_arv
	Return

Function palkarv
	Lparameter tcCode,tnCoode, tnToimikId
	nHours = 0
	nPalk = 0
	nTulu = 0
	lcProc = 'proc\mycalc.prg'
	Set procedure to (lcProc)
	nPalk=calc_baas(tnToimikId, gcPeriod)
	Select palk_lib.toimikId, palk_lib.artikkel,palk_lib.code, palk_lib.tyyp,;
		palk_lib.percent, palk_lib.tulumaks, palk_lib.summa, palk_lib.tulumaar, Cl.coode,;
		Cl.regnumber, Cl.client, Cl.puhkus;
		FROM  palkdata!Cl INNER JOIN palkdata!palk_lib;
		ON  Cl.coode = palk_lib.coode;
		Where palk_lib.toimikId = tnToimikId;
		and palk_lib.code = tcCode;
		INTO CURSOR Query1
	Use in palk_lib
	Use in Cl
	Select Query1
	Scan
		If Query1.tyyp = '+'
			=item_arvestamine(tnCoode,tnToimikId,Query1.summa,tcCode,Query1.tyyp,Query1.percent,Query1.tulumaks,Query1.artikkel,0)
		Endif
		
		If Query1.tyyp = '-' .and. empty(Query1.tulumaks)
			=item_kinnipidamine(tnCoode,tnToimikId,Query1.summa,Query1.code,Query1.tyyp,Query1.percent,Query1.tulumaks,Query1.artikkel)
		Endif
	Endscan
	Set procedure to
	Return

Function calcTulumaks
	Lparameter tnCoode, tToimikId
	set proc to ('proc/mycalc.prg')
	Do calc_tulumaks with tnCoode, tToimikId 
	If used('calc_andmed') .and. calc_andmed.summa > 0
		Insert into palkdata!palk_arv (coode,toimikId,code,period,summa,baas,tund,tyyp,artikkel);
			values (tnCoode,tToimikId,'TULUMAKS',gcPeriod,calc_andmed.summa,calc_andmed.baas,calc_andmed.tund,calc_andmed.tyyp,calc_andmed.artikkel)
		Use in palk_arv
		Use in calc_andmed
	Endif
	Return

Function calcSotsmaks
	Lparameter tnCoode, tToimikId
	Do calc_sotsmaks with tnCoode, tToimikId 
	If used('calc_andmed') .and. calc_andmed.summa > 0
		Insert into palkdata!palk_arv (coode,toimikId,code,period,summa,baas,tund,tyyp,artikkel);
			values (tnCoode,tToimikId,'SOTSMAKS',gcPeriod,calc_andmed.summa,calc_andmed.baas,calc_andmed.tund,calc_andmed.tyyp,calc_andmed.artikkel)
		Use in palk_arv
		Use in calc_andmed
	Endif
	Return
