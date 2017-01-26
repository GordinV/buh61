Parameter cWhere
tcNumber = '%'+ltrim(rtrim(fltrLepingud.number))+'%'
tcSelgitus = '%'+ltrim(rtrim(fltrLepingud.selgitus))+'%'
tcAsutus = '%'+ltrim(rtrim(fltrLepingud.asutus))+'%'
dKpv1 = iif(empty(fltrLepingud.kpv1),date(year(date()),1,1),fltrLepingud.kpv1)
dKpv2 = iif(empty(fltrLepingud.kpv2),date(year(date()),12,31),fltrLepingud.kpv2)
tcObjKood = '%'+ALLTRIM(fltrLepingud.objkood)+'%'
tcPakett = '%'+ALLTRIM(fltrLepingud.pakett)+'%'
tcObjNimi = '%'+ALLTRIM(fltrLepingud.objNimetus)+'%'

lcString = " SELECT leping1.id, leping1.Number, leping1.selgitus::varchar(120), "+;
 " asutus.nimetus as asutus,  leping1.asutusid, "+;
 " ifnull(objekt.kood, space(20))::character varying AS objkood, ifnull(objekt.nimetus, space(254))::character varying as  objnimi, "+;
 " nom.kood, nom.nimetus as teenus, leping2.hind,leping2.kogus, leping2.status, leping2.kbm, "+;
" ifnull(pakett.kood, space(20))::character varying AS pakett , ifnull(leping2.formula,SPACE(120))::text as formula "+;
 " FROM leping1 inner join leping2 on leping1.id = leping2.parentid "+;
"  inner join nomenklatuur nom on leping2.nomid = nom.id "+;
"   JOIN asutus ON leping1.asutusid = asutus.id "+;
"  LEFT JOIN library objekt ON objekt.id = leping1.objektid "+;
"   LEFT JOIN objekt obj ON objekt.id = obj.libid "+;
"   LEFT JOIN library pakett ON pakett.id = leping1.pakettid "+;
" WHERE leping1.rekvid = "+STR(gRekv) + " AND number LIKE '"+tcNumber + "' AND upper(asutus.nimetus) LIKE upper( '"+tcAsutus + "') "+;  
"  AND upper(leping1.selgitus) LIKE upper('" + tcSelgitus + "') and upper(objekt.kood) like upper( '"+tcObjKood +"')"+; 
"  and upper(objekt.nimetus) like upper( '"+ tcObjNimi+"') and upper(pakett.kood) like upper('"+tcPakett + "')"+; 
"  order by left(objekt.kood,5),obj.nait14,obj.nait15 "

lError = SQLEXEC(gnHandle,lcString,'Leping_report1')
IF lError < 1
	_cliptext = lcString
	SET STEP ON 
	SELECT 0
	RETURN .f.
ENDIF

select Leping_report1
