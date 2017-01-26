

CREATE TABLE pakett
(
  id serial NOT NULL,
  libid integer NOT NULL,
  nomid integer NOT NULL,
  hind numeric(14,4) NOT NULL DEFAULT 0,
  status integer DEFAULT 1 NOT NULL,
  formula text,
  CONSTRAINT pakett_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE pakett OWNER TO vlad;
GRANT ALL ON TABLE pakett TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE pakett TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE pakett TO dbkasutaja;
GRANT SELECT ON TABLE pakett TO dbadmin;
GRANT SELECT ON TABLE pakett TO dbvaatleja;


CREATE INDEX pakett_nomid
  ON pakett
  USING btree
  (nomid);

CREATE INDEX pakett_libid
  ON pakett
  USING btree
  (libid);


GRANT ALL ON TABLE pakett_id_seq TO GROUP dbkasutaja;
GRANT ALL ON TABLE pakett_id_seq TO GROUP dbpeakasutaja;


--ALTER TABLE leping3
--   ADD COLUMN libid integer DEFAULT 0;

ALTER TABLE leping1
   ADD COLUMN pakettId integer DEFAULT 0;

update leping1 set pakettId = 0;

ALTER TABLE leping1
   ALTER COLUMN pakettid SET NOT NULL;


ALTER TABLE leping1
   ADD COLUMN objektId integer DEFAULT 0;

update leping1 set objektId = 0;

ALTER TABLE leping1
   ALTER COLUMN objektid SET NOT NULL;



ALTER TABLE pakett ADD COLUMN kogus numeric(14,4);

update pakett set kogus = 0;

ALTER TABLE pakett ALTER COLUMN kogus SET DEFAULT 0;

ALTER TABLE pakett ALTER COLUMN kogus SET NOT NULL;

--drop table counter cascade;


CREATE TABLE counter
(
  id serial NOT NULL,
  parentid integer NOT NULL,
  kpv date NOT NULL default date(),
  algkogus numeric(14,4) NOT NULL DEFAULT 0,
  loppkogus numeric(14,4) NOT NULL DEFAULT 0,
  muud text,
  CONSTRAINT counter_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE counter OWNER TO vlad;
GRANT ALL ON TABLE counter TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE counter TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE counter TO dbkasutaja;
GRANT SELECT ON TABLE counter TO dbadmin;
GRANT SELECT ON TABLE counter TO dbvaatleja;



CREATE INDEX counter_parentid
  ON counter
  USING btree
  (parentid);


GRANT ALL ON TABLE counter_id_seq TO GROUP dbkasutaja;
GRANT ALL ON TABLE counter_id_seq TO GROUP dbpeakasutaja;

ALTER TABLE journal
   ADD COLUMN objekt character varying(20);

--update journal set objekt = space(20) where ifnull(objekt,'null') = 'null';

ALTER TABLE journal
   ALTER COLUMN objekt SET DEFAULT space(20);
--ALTER TABLE journal
--  ALTER COLUMN objekt SET NOT NULL;


CREATE TABLE objekt
(
  id serial NOT NULL,
  libid integer NOT NULL,
  asutusid integer NOT NULL,
  parentid integer NOT NULL,
  nait01 numeric(14,4) NOT NULL DEFAULT 0,
  nait02 numeric(14,4) NOT NULL DEFAULT 0,
  nait03 numeric(14,4) NOT NULL DEFAULT 0,
  nait04 numeric(14,4) NOT NULL DEFAULT 0,
  nait05 numeric(14,4) NOT NULL DEFAULT 0,
  nait06 numeric(14,4) NOT NULL DEFAULT 0,
  nait07 numeric(14,4) NOT NULL DEFAULT 0,
  nait08 numeric(14,4) NOT NULL DEFAULT 0,
  nait09 numeric(14,4) NOT NULL DEFAULT 0,
  nait10 numeric(14,4) NOT NULL DEFAULT 0,
  nait11 numeric(14,4) NOT NULL DEFAULT 0,
  nait12 numeric(14,4) NOT NULL DEFAULT 0,
  nait13 numeric(14,4) NOT NULL DEFAULT 0,
  nait14 numeric(14,4) NOT NULL DEFAULT 0,
  nait15 numeric(14,4) NOT NULL DEFAULT 0,
  muud text,
  CONSTRAINT objekt_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE objekt OWNER TO vlad;
GRANT ALL ON TABLE objekt TO vlad;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE objekt TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE objekt TO dbkasutaja;
GRANT SELECT ON TABLE objekt TO dbadmin;
GRANT SELECT ON TABLE objekt TO dbvaatleja;


CREATE INDEX objekt_parentid
  ON objekt
  USING btree
  (parentid);

CREATE INDEX objekt_libid
  ON objekt
  USING btree
  (libid);

CREATE INDEX objekt_asutusid
  ON objekt
  USING btree
  (asutusid);


GRANT ALL ON TABLE objekt_id_seq TO GROUP dbkasutaja;
GRANT ALL ON TABLE objekt_id_seq TO GROUP dbpeakasutaja;


-- View: wizlepingud
dROP VIEW wizlepingud;

CREATE OR REPLACE VIEW wizlepingud AS 
 SELECT leping1.id, leping1.objektid, leping1.rekvid, leping1.number AS kood, leping2.nomid, leping1.selgitus::character(120) AS nimetus, asutus.nimetus AS asutus, 
	leping1.tahtaeg
   FROM leping1
   JOIN leping2 ON leping1.id = leping2.parentid
   JOIN asutus ON asutus.id = leping1.asutusid
  WHERE leping2.status = 1;

ALTER TABLE wizlepingud OWNER TO vlad;
GRANT SELECT ON TABLE wizlepingud TO dbpeakasutaja;
GRANT SELECT ON TABLE wizlepingud TO dbkasutaja;
GRANT SELECT ON TABLE wizlepingud TO dbadmin;
GRANT SELECT ON TABLE wizlepingud TO dbvaatleja;

ALTER TABLE arv
   ADD COLUMN objekt character varying(20);

--drop view curArved;



CREATE OR REPLACE VIEW curArved AS 
SELECT Arv.id, arv.rekvid, Arv.number, Arv.kpv as kpv, Arv.tahtaeg, Arv.summa, Arv.tasud,  Arv.tasudok,  ARV.USERID, Asutus.nimetus AS asutus,  arv.asutusid, Arv.journalid, arv.liik, arv.operId, arv.jaak, arv.objektId, ARV.DOKLAUSID, ifnull(dokprop.konto,space(20)) as konto, arv.muud,ifnull(dokvaluuta1.valuuta,'EEK')::VARCHAR as valuuta, 
ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, ifnull(arv.objekt,space(20))::varchar as objekt, userid.ametnik FROM  Arv INNER join  asutus Asutus on asutus.id = ARV.asutusId 
inner join userid on arv.userid = userid.id left outer join dokprop on dokprop.id = arv.doklausId left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokliik = 3)  ;

GRANT SELECT ON TABLE curArved TO dbpeakasutaja;
GRANT SELECT ON TABLE curArved TO dbkasutaja;
GRANT SELECT ON TABLE curArved TO dbvaatleja;


--	DROP VIEW curarvtasud;



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


DROP VIEW curlepingud;


CREATE OR REPLACE VIEW curlepingud AS 
 SELECT leping1.id, leping1.rekvid, leping1.number, leping1.kpv, ifnull(dtoc(leping1.tahtaeg)::bpchar, space(20)) AS tahtaeg, leping1.selgitus::bpchar AS selgitus, 
	ltrim(rtrim(asutus.nimetus::text))::bpchar + space(1) + ltrim(rtrim(asutus.omvorm::text))::bpchar AS asutus, asutus.id AS asutusid,	
	ifnull(objekt.kood,space(20))::varchar as objkood, ifnull(objekt.nimetus,space(254))::varchar as objnimi,
	ifnull(pakett.kood,space(20))::varchar as pakett
   FROM leping1
   JOIN asutus ON leping1.asutusid = asutus.id
   left outer join library objekt on objekt.id = leping1.objektid
   left outer join library pakett on pakett.id = leping1.pakettid;

ALTER TABLE curlepingud OWNER TO vlad;
GRANT SELECT ON TABLE curlepingud TO dbpeakasutaja;
GRANT SELECT ON TABLE curlepingud TO dbkasutaja;
GRANT SELECT ON TABLE curlepingud TO dbadmin;
GRANT SELECT ON TABLE curlepingud TO dbvaatleja;

drop view curTeenused;



CREATE OR REPLACE VIEW curTeenused AS 
SELECT  arv.id, arv.rekvid, arv.journalid, arv.liik, arv.number, arv.kpv, arv1.kogus, arv1.summa, asutus.regkood, asutus.nimetus AS asutus, nomenklatuur.kood, 
nomenklatuur.nimetus, nomenklatuur.uhik, arv1.hind, arv1.kbm, asutus.omvorm,  arv1.summa-arv1.kbm as kbmta,   
CASE  WHEN  nomenklatuur.doklausid = 0  THEN 18  ELSE case WHEN  (nomenklatuur.doklausid = 1 or nomenklatuur.doklausid = 3) 
THEN 0  ELSE case WHEN  nomenklatuur.doklausid = 2 then 5  ELSE case WHEN  nomenklatuur.doklausid = 5 THEN 20  end end end  end::int as kaibemaks , 
ARV1.KOOD4 AS URITUS, Proj,ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs,
 ifnull(arv.objekt,space(20))::varchar as objekt   
 FROM arv  JOIN arv1 ON arv.id = arv1.parentid JOIN asutus ON arv.asutusid = asutus.id  
 JOIN nomenklatuur ON arv1.nomid = nomenklatuur.id  left outer join dokvaluuta1 on (arv1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 2) ;

ALTER TABLE curTeenused OWNER TO vlad;
GRANT SELECT ON TABLE curTeenused TO dbpeakasutaja;
GRANT SELECT ON TABLE curTeenused TO dbkasutaja;
GRANT SELECT ON TABLE curTeenused TO dbvaatleja;

