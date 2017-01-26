alter table palk_lib add column elatis int ;
update palk_lib set elatis = 0;
alter table palk_lib alter column elatis set default 0;
alter table palk_lib alter column elatis set not null ;
