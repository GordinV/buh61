-- View: "comautod"

-- DROP VIEW comautod;

--CREATE OR REPLACE VIEW comautod AS 
 SELECT fnc_get_asutuse_staatus(rekv.id, 64), rekv.id, rekv.parentid, case when id = parentid then 0 when id <> parentid and parentid = 0 then 1 else 2 end as tase, nimetus 
   FROM rekv
order by id
/*
ALTER TABLE comautod OWNER TO vlad;
GRANT ALL ON TABLE comautod TO vlad;
GRANT SELECT ON TABLE comautod TO dbpeakasutaja;
GRANT SELECT ON TABLE comautod TO dbkasutaja;
GRANT SELECT ON TABLE comautod TO dbadmin;
GRANT SELECT ON TABLE comautod TO dbvaatleja;
GRANT ALL ON TABLE comautod TO taabel;


select fnc_get_asutuse_staatus(integer, integer)

update rekv set parentid = 0 where id = 63

select * from rekv where id = 119

*/