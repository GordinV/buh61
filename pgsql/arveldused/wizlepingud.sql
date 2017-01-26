-- View: wizlepingud


/*

select * from leping1 order by objektid desc 
*/
 DROP VIEW wizlepingud;

CREATE OR REPLACE VIEW wizlepingud AS 
 SELECT leping1.id, leping1.objektid, pakettid, leping1.rekvid, leping1.number AS kood, ifnull(leping2.nomid,0)::integer as nomid , leping1.selgitus::character(120) AS nimetus, 
 asutus.nimetus AS asutus, leping1.tahtaeg
   FROM leping1
   LEFT OUTER JOIN leping2 ON leping1.id = leping2.parentid
   JOIN asutus ON asutus.id = leping1.asutusid;

ALTER TABLE wizlepingud OWNER TO vlad;
GRANT ALL ON TABLE wizlepingud TO vlad;
GRANT SELECT ON TABLE wizlepingud TO dbpeakasutaja;
GRANT SELECT ON TABLE wizlepingud TO dbkasutaja;
GRANT SELECT ON TABLE wizlepingud TO dbadmin;
GRANT SELECT ON TABLE wizlepingud TO dbvaatleja;

