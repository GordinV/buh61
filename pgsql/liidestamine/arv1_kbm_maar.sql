ALTER TABLE arv1 ADD COLUMN kbm_maar character varying(20);

alter table arv1 disable trigger all;
update arv1 set kbm_maar = '20' where kbm_maar is null ;
alter table arv1 enable trigger all;

