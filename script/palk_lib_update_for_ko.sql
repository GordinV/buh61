
drop table if exists all_asutused;

CREATE TABLE all_asutused
(
  id serial NOT NULL,
  parentid integer NOT NULL,
  childid integer NOT NULL
)
WITH (OIDS=TRUE);
ALTER TABLE all_asutused OWNER TO vlad;

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE all_asutused TO dbpeakasutaja;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE all_asutused TO dbkasutaja;


insert into all_asutused (parentid, childid) values (125, 66);
insert into all_asutused (parentid, childid) values (125, 67);
insert into all_asutused (parentid, childid) select 80, id from rekv where id in (81,89, 102, 103, 99, 91, 96, 98, 82, 95, 87, 101, 92, 86, 97, 100, 84, 88, 90, 93, 83, 85, 94);
insert into all_asutused (parentid, childid) select 104, id from rekv where id in (105,109 );
insert into all_asutused (parentid, childid) select 106, id from rekv where id in (107, 108,111, 113,121, 112 );
insert into all_asutused (parentid, childid) select 68, id from rekv where id in (69,70,71,72,73 );


/*
select * from rekv where nimetus ilike '0951006%'

select * from all_asutused

select id, nimetus from rekv where id in (select childId from all_asutused where parentid = 125)  and id <> 125 

select * from library where rekvid = 125 and library = 'PALK' order by id desc limit 1
select * from library where rekvid in (66, 67) and kood = 'PREEMIA-TOOL-08102-6' and library = 'PALK' order by id desc limit 10

select * from palk_lib where parentid = 672691
update palk_lib set muud = '' where id = 83827

update library set muud = '' where id = 672691
*/


