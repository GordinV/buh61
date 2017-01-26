/*
select * from curarvtasud

update journal set muud = '' where left(muud,1) = '2'

select * from asutus where id in (575,2)

select * from curjournal order by id desc
limit 10
select *from journal order by id desc limit 3

SELECT arvid, number, arvkpv, arvsumma, tahtaeg, liik, asutus, kpv, summa, dok, id, journalid, pankkassa, sorderId, objekt , tasuliik, valuuta, kuurs 
FROM curarvtasud  WHERE rekvid = 1   AND number LIKE '%'   AND Asutus LIKE '%%'   AND kpv >= date(2010,12, 1)   AND kpv <= date(2010,12,17)  
 AND summa >= -999999999.0   AND summa <= 999999999.00   AND dok LIKE '%%'  
 and upper(objekt) like upper('%') 
 and upper(valuuta) like upper('%') 
 and upper(tasuliik) like upper('%' ) 
 ORDER BY number, kpv

select * from config
*/

--DROP VIEW curarvtasud;


CREATE OR REPLACE VIEW curarvtasud AS 
SELECT arv.id as arvid, arv.rekvid, Arv.number, arv.kpv as arvkpv, arv.summa as arvsumma, arv.tahtaeg, arv.liik, Asutus.nimetus AS asutus, Arvtasu.kpv as kpv, Arvtasu.summa, 
Arvtasu.dok, Arvtasu.id, arvtasu.journalid, arvtasu.pankkassa, arvtasu.sorderId, ifnull(arv.objekt,space(20))::varchar as objekt ,
CASE
	WHEN  arvtasu.pankkassa = 1 THEN 'MK'::varchar
	WHEN  arvtasu.pankkassa = 2 THEN 'KASSA'::varchar
	WHEN  arvtasu.pankkassa = 3 THEN 'RAAMAT'::varchar
        ELSE 'MUUD'::varchar
END AS tasuliik, ifnull(dokvaluuta1.valuuta,'EEK')::varchar(20) as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs

FROM arvtasu Arvtasu INNER JOIN  Arv ON  ARVTASU.ARVID = ARV.ID  INNER JOIN Asutus ON ASUTUS.ID = ARV.ASUTUSID
LEFT OUTER JOIN dokvaluuta1 on (Arvtasu.id = dokvaluuta1.dokid and dokliik = 10);
ALTER TABLE curarvtasud OWNER TO vlad;
GRANT SELECT ON TABLE curarvtasud TO dbpeakasutaja;
GRANT SELECT ON TABLE curarvtasud TO dbkasutaja;
GRANT SELECT ON TABLE curarvtasud TO dbvaatleja;


