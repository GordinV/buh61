Parameter cWhere
LOCAL lcString, lcKpv, lcKpv2, lcWhere

CREATE CURSOR muugiarvete_report1 (regkood c(20), asutus c(254), number c(20), kpv d, summa n(18,2), kbm_summa n(18,2), kbm_maar c(254),erikord c(254) null, liik int )


lcKpv1 = 'date( '+  STR(YEAR(fltrAruanne.kpv1),4)+','+STR(MONTH(fltrAruanne.kpv1),2)+','+STR(DAY(fltrAruanne.kpv1),2)+')'
lcKpv2 = 'date( '+  STR(YEAR(fltrAruanne.kpv2),4)+','+STR(MONTH(fltrAruanne.kpv2),2)+','+STR(DAY(fltrAruanne.kpv2),2)+')'

SET TALK OFF
SET NOTIFY off
SET CURSOR OFF
SET TEXT ON NOSHOW



TEXT TO lcString
	SELECT rekvid, asutusid, regkood, asutus, number, kpv, summa, kbm_summa, regexp_replace(kbm_maar::text,'[{}]','','g')::varchar(254) as kbm_maar, liik,
	case 
			when kbm_maar @> array[0,20] then '20erikord'   
			when kbm_maar @> array[0,9] then '9erikord' end::varchar(254) as erikord  
	from (
	select  arv.rekvid, arv.asutusid, asutus.regkood, asutus.nimetus as asutus,arv.number, arv.kpv, arv.kbmta as summa, arv.kbm as kbm_summa, 	
		array(select distinct
			case 
				when n.doklausid = 0 then 18 
				when (n.doklausid = 1 or n.doklausid = 3) then 0 
				when n.doklausid = 2 then 5 
				when n.doklausid = 4 then 9
				when n.doklausid = 5 then 20
				ELSE 0
			end::integer 
			from arv1 			
				inner join nomenklatuur n on n.id = arv1.nomid 
				where arv1.parentid = arv.id) as kbm_maar, arv.liik 
			 from arv 
			 inner join asutus on arv.asutusid = asutus.Id and ALLTRIM(LOWER(asutus.nimetus)) <> LOWER('Muud fuusilised isikud')
			 where arv.liik = 0 
	union all
	select  arv.rekvid,arv.asutusid, asutus.regkood, asutus.nimetus as asutus,arv.number, arv.kpv, arv.kbmta as summa, arv.kbm as kbm_summa, 
		array(select distinct
			case 
				when n.doklausid = 0 then 18 
				when (n.doklausid = 1 or n.doklausid = 3) then 0 
				when n.doklausid = 2 then 5 
				when n.doklausid = 4 then 9
				when n.doklausid = 5 then 20
				ELSE 0
			end::integer 
			from arv1 			
				inner join nomenklatuur n on n.id = arv1.nomid 
				where arv1.parentid = arv.id) as kbm_maar, arv.liik 			 
				from arv 
			 inner join asutus on arv.asutusid = asutus.Id and ALLTRIM(LOWER(asutus.nimetus)) <> LOWER('Muud fuusilised isikud') 
			 where arv.liik = 1 ) qry	
ENDTEXT
 lcWhere = ' where qry.rekvid = ' + STR(gRekv) +;
			' and qry.kbm_summa > 0 '+;
			' and qry.kpv >= ' + lcKpv1 +;
			' and qry.kpv <= ' + lcKpv2 + ;
			' and qry.asutusid in (	select distinct asutusid '+;
			'		from arv '+;			 
			'		where arv.kpv >= ' + lcKpv1 +;
			' 		and arv.kpv <= ' + lcKpv2 + ;
			'		and arv.kbm > 0 '+;
			' 		and arv.rekvid = ' + STR(gRekv) +;
			'		group by arv.asutusid, arv.liik '+;
			'		having sum(arv.kbmta) >= ' + STR(fltrAruanne.summa1,14,2) +')' +;		
			' order by qry.liik, asutus, kpv '
			

lcString = 	lcString + lcWhere
			
lError = SQLEXEC(gnHandle,lcString,'qry')
IF lError > 0 AND USED('qry')
	SELECT muugiarvete_report1 
	APPEND  FROM DBF('qry')
ELSE
	SELECT 0
ENDIF

