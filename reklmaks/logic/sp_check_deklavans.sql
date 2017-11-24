alter table palk_lib add column tululiik varchar(6) ;
update palk_lib set tululiik = space(1);
alter table palk_lib alter column tululiik set default space(1);
alter table palk_lib alter column tululiik set not null ;
