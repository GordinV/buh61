alter table eelarve add COLUMN summa_k NUMERIC(14,2) not null default 0;

update eelarve set summa_k = summa;
