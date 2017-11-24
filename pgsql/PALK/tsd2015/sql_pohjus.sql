insert into library (rekvId, kood, nimetus, library) select 63, 'EV', 'Ekslik väljamakse', 'POHJUS' where not exists (select id from library where kood = 'EV' and library = 'POHJUS');
insert into library (rekvId, kood, nimetus, library) select 63, 'VR', 'Viga raamatupidamises', 'POHJUS' where not exists (select id from library where kood = 'VR' and library = 'POHJUS');
insert into library (rekvId, kood, nimetus, library) select 63, 'VI', 'Väljamakse valele isikule', 'POHJUS' where not exists (select id from library where kood = 'VI' and library = 'POHJUS');
insert into library (rekvId, kood, nimetus, library) select 63, 'MUU', 'Muu', 'POHJUS' where not exists (select id from library where kood = 'MUU' and library = 'POHJUS');

alter table palk_oper add column pohjus varchar(20) null;