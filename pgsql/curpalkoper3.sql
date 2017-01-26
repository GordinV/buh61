-- View: curpalkoper3

DROP VIEW curpalkoper3;

CREATE OR REPLACE VIEW curpalkoper3 AS 
 SELECT palk_oper.summa, palk_oper.kpv, palk_oper.rekvid, asutus.nimetus AS isik, asutus.id AS isikid, asutus.regkood AS isikukood, palk_lib.liik, 
	palk_lib.asutusest, osakond.kood AS okood, amet.kood AS akood, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta
   FROM palk_oper
   JOIN palk_lib ON palk_oper.libid = palk_lib.parentid
   JOIN library lib ON lib.id = palk_lib.parentid
   JOIN tooleping ON palk_oper.lepingid = tooleping.id
   JOIN asutus ON tooleping.parentid = asutus.id
   JOIN library osakond ON osakond.id = tooleping.osakondid
   JOIN library amet ON amet.id = tooleping.ametid
left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 12)
   ;

ALTER TABLE curpalkoper3 OWNER TO vlad;
GRANT SELECT ON TABLE curpalkoper3 TO dbkasutaja;
GRANT SELECT ON TABLE curpalkoper3 TO dbvaatleja;
GRANT SELECT ON TABLE curpalkoper3 TO dbpeakasutaja;

