alter table tooleping add column riik varchar(3);
alter table tooleping add column toend date;
update tooleping set riik = space(1);
alter table tooleping alter column riik set default space(1);
alter table tooleping alter column riik set not null ;
