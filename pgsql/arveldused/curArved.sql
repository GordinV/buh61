ALTER TABLE arv
   ADD COLUMN objekt character varying(20);


drop view curArved;


CREATE OR REPLACE VIEW curArved AS 
SELECT Arv.id, arv.rekvid, Arv.number, Arv.kpv as kpv, Arv.tahtaeg, Arv.summa, Arv.tasud,  Arv.tasudok,  ARV.USERID, Asutus.nimetus AS asutus,  arv.asutusid, Arv.journalid, arv.liik, arv.operId, arv.jaak, arv.objektId, ARV.DOKLAUSID, ifnull(dokprop.konto,space(20)) as konto, arv.muud,ifnull(dokvaluuta1.valuuta,'EEK')::VARCHAR as valuuta, 
ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, ifnull(arv.objekt,space(20))::varchar as objekt, userid.ametnik FROM  Arv INNER join  asutus Asutus on asutus.id = ARV.asutusId 
inner join userid on arv.userid = userid.id left outer join dokprop on dokprop.id = arv.doklausId left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokliik = 3)  ;

ALTER TABLE curArved OWNER TO vlad;
GRANT SELECT ON TABLE curArved TO dbpeakasutaja;
GRANT SELECT ON TABLE curArved TO dbkasutaja;
GRANT SELECT ON TABLE curArved TO dbvaatleja;

--select * from curarved where objekt like '002%'