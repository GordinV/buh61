-- View: curlepingud

-- DROP VIEW curlepingud;

CREATE OR REPLACE VIEW curlepingud AS 
 SELECT leping1.id, leping1.rekvid, leping1.number, leping1.kpv, ifnull(dtoc(leping1.tahtaeg)::bpchar, space(20)) AS tahtaeg, leping1.selgitus::bpchar AS selgitus, ltrim(rtrim(asutus.nimetus::text))::bpchar + space(1) + ltrim(rtrim(asutus.omvorm::text))::bpchar AS asutus, asutus.id AS asutusid, ifnull(objekt.kood, space(20))::character varying AS objkood, ifnull(objekt.nimetus, space(254))::character varying AS objnimi, ifnull(obj.nait14, 0::numeric) AS maja, ifnull(obj.nait15, 0::numeric) AS korter, ifnull(pakett.kood, space(20))::character varying AS pakett
   FROM leping1
   JOIN asutus ON leping1.asutusid = asutus.id
   LEFT JOIN library objekt ON objekt.id = leping1.objektid
   LEFT JOIN objekt obj ON objekt.id = obj.libid
   LEFT JOIN library pakett ON pakett.id = leping1.pakettid;

ALTER TABLE curlepingud OWNER TO vlad;
GRANT ALL ON TABLE curlepingud TO vlad;
GRANT SELECT ON TABLE curlepingud TO dbpeakasutaja;
GRANT SELECT ON TABLE curlepingud TO dbkasutaja;
GRANT SELECT ON TABLE curlepingud TO dbadmin;
GRANT SELECT ON TABLE curlepingud TO dbvaatleja;

