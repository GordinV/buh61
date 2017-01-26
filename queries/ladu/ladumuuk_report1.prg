LPARAMETERS tnId
LOCAL lcString, ldKpv1, ldKpv2, lcKpv1, lcKpv2
*SET STEP ON 
ldKpv1 = fltrladuArved.kpv1
ldKpv2 = fltrladuArved.kpv2
lcKpv1 = "DATE("+STR(YEAR(ldKpv1))+","+STR(MONTH(ldKpv1))+","+STR(DAY(ldKpv1))+")"
lcKpv2 = "DATE("+STR(YEAR(ldKpv2))+","+STR(MONTH(ldKpv2))+","+STR(DAY(ldKpv2))+")"

lcAsutus = ALLTRIM(fltrladuArved.asutus)
lcKood = ALLTRIM(fltrladuArved.kood)
lcArvNumber = ALLTRIM(fltrLaduArved.number)
lcNom =  ALLTRIM(fltrladuArved.kood)
lcOper = ALLTRIM(fltrladuArved.oper)
lnKogus1 = fltrladuArved.kogus1
lnKogus2 = fltrladuArved.kogus2
lnSumma1 = fltrladuArved.summa1
lnSumma2 = fltrladuArved.summa2

lcString = "select ifnull(loppjaak.kogus,0) as loppkogus, ifnull(algjaak.kogus,0) as algkogus, asutus.nimetus as asutus, arv.id, arv.kpv, arv.liik,"+;
	" arv1.id as dokitemid, nom.kood, nom.nimetus as vara, "+;
	" arv1.nomid, arv1.kogus, arv1.hind as vhind, arv1.kbm, arv1.kbmta, arv1.kbmta as summa, arv1.kbm, "+;
	"(select hind from arv1 arvv where arvv.id = arv1.isikid) as shind "+;
	" from arv inner join arv1 on arv.id = arv1.parentid "+;
		" inner join ladu_oper on arv.operId = ladu_oper.id"+;
		" inner join asutus on arv.asutusid = asutus.id "+;
		" inner join nomenklatuur nom on nom.id = arv1.nomid "+;
		" left outer join ( "+;
		" 	select sum(kogus) as kogus, nomid from ( "+;
				" select sum(arv1.kogus) as kogus, arv1.nomid   "+;
				"	from arv inner join arv1 on arv.id = arv1.parentid "+;
				"	inner join ladu_oper on arv.operId = ladu_oper.id "+;
				"	where arv.rekvid = "+ ALLTRIM(STR(gRekv))+" and arv.liik = 1 "+; 
				"	and arv.kpv < "+ALLTRIM(lcKpv1) +;
				"	group by nomid "+;
				"	union all "+;
				"	select sum(-1*arv1.kogus) as kogus, arv1.nomid  "+; 
				"	from arv inner join arv1 on arv.id = arv1.parentid "+;
				"	inner join ladu_oper on arv.operId = ladu_oper.id "+;
				"	where arv.rekvid = "+ ALLTRIM(STR(grekv))+" and arv.liik = 0 "+; 
				"	and arv.kpv < "+ALLTRIM(lcKpv1) +;
				"	group by nomid	) qry "+;
				"	group by nomid) algjaak on algjaak.nomid = arv1.nomid "+;
		" left outer join ( "+;
		" 	select sum(kogus) as kogus, nomid from ( "+;
				" select sum(arv1.kogus) as kogus, arv1.nomid   "+;
				"	from arv inner join arv1 on arv.id = arv1.parentid "+;
				"	inner join ladu_oper on arv.operId = ladu_oper.id "+;
				"	where arv.rekvid = "+ ALLTRIM(STR(gRekv))+" and arv.liik = 1 "+; 
				"	and arv.kpv <= "+ALLTRIM(lcKpv2) +;
				"	group by nomid "+;
				"	union all "+;
				"	select sum(-1*arv1.kogus) as kogus, arv1.nomid  "+; 
				"	from arv inner join arv1 on arv.id = arv1.parentid "+;
				"	inner join ladu_oper on arv.operId = ladu_oper.id "+;
				"	where arv.rekvid = "+ ALLTRIM(STR(grekv))+" and arv.liik = 0 "+; 
				"	and arv.kpv <= "+ALLTRIM(lcKpv2) +;
				"	group by nomid	) qry "+;
				"	group by nomid) loppjaak on loppjaak.nomid = arv1.nomid "+;
		" where arv.rekvid = " + STR(grekv)+" and arv.liik = 0 "+;
		" and arv.kpv >= " + ALLTRIM(lcKpv1) +;
		" and arv.kpv <= " + ALLTRIM(lcKpv2) +;
		" and UPPER(asutus.nimetus) like '%"+UPPER(lcAsutus)+"%'"+;
		" and UPPER(arv.number) like '%"+UPPER(lcArvnumber)+ "%'"+;
		" and UPPER(nom.kood) like '%"++UPPER(lcNom)+"%'"+;
		" and UPPER(ladu_oper.nimetus) like '%"+UPPER(lcOper)+"%'"+;
		" and arv1.kogus >= "+ALLTRIM(STR(lnKogus1))+;
		" and arv1.kogus <= "+ALLTRIM(STR(lnKogus2))+;
		" and arv1.kbmta >= "+ALLTRIM(STR(lnSumma1))+;
		" and arv1.kbmta <= "+ALLTRIM(STR(lnSumma2))+;
		" order by asutus.nimetus, arv.kpv, arv1.nomid "
		

*_cliptext = lcstring

lnError= SQLEXEC(gnHandle,lcString,'ladumuuk_report1')

SELECT ladumuuk_report1
