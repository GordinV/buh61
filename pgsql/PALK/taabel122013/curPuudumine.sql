-- View: curpuudumine

-- DROP VIEW curpuudumine;

CREATE OR REPLACE VIEW curpuudumine AS 
 SELECT puudumine.id, puudumine.lepingid, puudumine.kpv1, puudumine.kpv2, puudumine.paevad, puudumine.summa, puudumine.tunnus, puudumine.tyyp, amet.nimetus AS amet, amet.rekvid, asutus.regkood AS isikukood, asutus.nimetus AS isik, 
        CASE
            WHEN puudumine.tunnus = 1 THEN 'PUHKUS'::character varying
            WHEN puudumine.tunnus = 4 THEN 'MUUD'::character varying
            WHEN puudumine.tunnus = 3 THEN 'KOMANDEERING'::character varying
            ELSE 'HAIGUS'::character varying
        END AS pohjus, 
        CASE
            WHEN (alltrim(str(puudumine.tunnus)) + '-'::bpchar + alltrim(str(puudumine.tyyp))) = '1-1'::bpchar THEN 'PEAPUHKUS'::character varying
            WHEN (alltrim(str(puudumine.tunnus)) + '-'::bpchar + alltrim(str(puudumine.tyyp))) = '1-2'::bpchar THEN 'STAAZ'::character varying
            WHEN (alltrim(str(puudumine.tunnus)) + '-'::bpchar + alltrim(str(puudumine.tyyp))) = '1-3'::bpchar THEN 'LASTEPUHKUS'::character varying
            WHEN (alltrim(str(puudumine.tunnus)) + '-'::bpchar + alltrim(str(puudumine.tyyp))) = '1-4'::bpchar THEN 'OMAARVEL'::character varying
            WHEN (alltrim(str(puudumine.tunnus)) + '-'::bpchar + alltrim(str(puudumine.tyyp))) = '1-5'::bpchar THEN 'ÕPPEPUHKUS'::character varying
            WHEN (alltrim(str(puudumine.tunnus)) + '-'::bpchar + alltrim(str(puudumine.tyyp))) = '1-6'::bpchar THEN 'LISAPUHKUS'::character varying
            WHEN (alltrim(str(puudumine.tunnus)) + '-'::bpchar + alltrim(str(puudumine.tyyp))) = '2-1'::bpchar THEN 'HAIGUS'::character varying
            WHEN (alltrim(str(puudumine.tunnus)) + '-'::bpchar + alltrim(str(puudumine.tyyp))) = '2-2'::bpchar THEN 'HOOLDUS'::character varying
            WHEN (alltrim(str(puudumine.tunnus)) + '-'::bpchar + alltrim(str(puudumine.tyyp))) = '3-1'::bpchar THEN 'KOMANDEERING'::character varying
            WHEN (alltrim(str(puudumine.tunnus)) + '-'::bpchar + alltrim(str(puudumine.tyyp))) = '4-1'::bpchar THEN 'MUUD'::character varying
            WHEN (alltrim(str(puudumine.tunnus)) + '-'::bpchar + alltrim(str(puudumine.tyyp))) = '4-2'::bpchar THEN 'VABA PÄEV'::character varying
            WHEN (alltrim(str(puudumine.tunnus)) + '-'::bpchar + alltrim(str(puudumine.tyyp))) = '4-3'::bpchar THEN upper('popitegemine')::character varying
            ELSE NULL::character varying
        END AS liik
   FROM puudumine
   JOIN tooleping ON puudumine.lepingid = tooleping.id
   JOIN library amet ON tooleping.ametid = amet.id
   JOIN asutus ON tooleping.parentid = asutus.id;

ALTER TABLE curpuudumine
  OWNER TO vlad;
GRANT ALL ON TABLE curpuudumine TO vlad;
GRANT SELECT ON TABLE curpuudumine TO dbpeakasutaja;
GRANT SELECT ON TABLE curpuudumine TO dbkasutaja;
GRANT SELECT ON TABLE curpuudumine TO dbadmin;
GRANT SELECT ON TABLE curpuudumine TO dbvaatleja;
GRANT ALL ON TABLE curpuudumine TO taabel;

