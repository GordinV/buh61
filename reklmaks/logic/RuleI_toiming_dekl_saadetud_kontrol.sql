alter table leping2 add column kbm int ;
update leping2 set kbm = 1;
alter table leping2 alter column kbm set default 1;
alter table leping2 alter column kbm set not null ;
