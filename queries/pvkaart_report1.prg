Parameter cWhere
If Vartype(cWhere) = 'C'
	tnId = Val(Alltrim(cWhere))
Else
	tnId = cWhere
Endif
If Empty (tnId)
	Return .F.
ENDIF
	With odb
		.Use('v_library','tmpLib')
		.Use('CURPVUUSJAAK','tmpPvUusJaak')
		.Use('v_pv_kaart','tmpPvKaart')
	Endwith



IF !USED('comGrupp')
	oDb.use('comGrupp')
ENDIF

Select comGrupp
Locate For Id = tmpPvKaart.gruppid
cGrupp = comGrupp.nimetus
*SET STEP ON 
lnKulum = IIF(ISNULL(tmpPvUusJaak.algkulum),0,tmpPvUusJaak.algkulum)  + IIF(ISNULL(tmpPvUusJaak.kulum),0,tmpPvUusJaak.kulum)
lnParandus = IIF(ISNULL(tmpPvUusJaak.parandus),0,tmpPvUusJaak.parandus)
lnHind = IIF(IIF(ISNULL(tmpPvUusJaak.umberhind),0,tmpPvUusJaak.umberhind) > 0, tmpPvUusJaak.umberhind, IIF(ISNULL(tmpPvUusJaak.soetmaks),0,tmpPvUusJaak.soetmaks))
*lnJaak = lnHind + lnParandus - lnKulum

*!*	lnJaak = Iif(Isnull(tmpPvUusJaak.soetmaks),0,tmpPvUusJaak.soetmaks) + ;
*!*		IIF(Isnull(tmpPvUusJaak.parandus),0,tmpPvUusJaak.parandus) - ;
*!*		IIF(Isnull(tmpPvUusJaak.algkulum),0,tmpPvUusJaak.algkulum) - ;
*!*		IIF(Isnull(tmpPvUusJaak.kulum),0,tmpPvUusJaak.kulum)

Select comAsutusremote
Locate For Id = tmpPvKaart.vastisikId

Create Cursor pvkaart_report1 (kood c(20), nimetus c(254), soetmaks n(18,8), hind n(18,8), soetkpv d, algkulum n(18,8), kulum n(18,8),;
	konto c(20), grupp c(120), mahakantud d, muud m, vastisik c(120), kulumKokku n(18,8), Jaak n(18,8), rentnik m, valuuta c(20), kuurs y)

Select pvkaart_report1
Append Blank
Replace kood With tmpLib.kood,;
	nimetus With tmpLib.nimetus,;
	soetmaks With Iif(Isnull(tmpPvUusJaak.soetmaks),0,tmpPvUusJaak.soetmaks),;
	hind with lnHind,;
	soetkpv With tmpPvKaart.soetkpv,;
	konto With tmpPvKaart.konto,;
	kulum With tmpPvKaart.kulum,;
	algkulum With Iif(Isnull(tmpPvUusJaak.algkulum),0,tmpPvUusJaak.algkulum),;
	grupp With cGrupp,;
	mahakantud With Iif(Isnull(tmpPvKaart.mahakantud) Or;
	year(tmpPvKaart.mahakantud) = 1900,{},tmpPvKaart.mahakantud),;
	vastisik With comAsutusremote.nimetus,;
	kulumKokku With Iif(Isnull(tmpPvUusJaak.kulum),0,tmpPvUusJaak.kulum) + Iif(Isnull(tmpPvUusJaak.algkulum),0,tmpPvUusJaak.algkulum),;
	Jaak With tmpPvKaart.jaak,;
	rentnik With tmpPvKaart.muud,;
	valuuta WITH tmpPvKaart.valuuta,;
	kuurs WITH tmpPvKaart.kuurs,;
	muud With tmpLib.muud In pvkaart_report1

IF USED('tmpPvKaart')
	USE IN tmpPvKaart
ENDIF
IF USED('tmpPvUusJaak')
	USE IN tmpPvUusJaak
ENDIF
IF USED('tmpLib')
	USE IN tmpLib
ENDIF 

Select pvkaart_report1

