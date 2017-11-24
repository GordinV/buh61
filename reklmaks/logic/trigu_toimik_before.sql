alter table palk_taabel1 add column uleajatoo int;
update palk_taabel1 set uleajatoo = 0;
alter table palk_taabel1 alter column uleajatoo set default 0;
alter table palk_taabel1 alter column uleajatoo set not null ;
