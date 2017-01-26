-- Column: tulumaks

-- ALTER TABLE palk_config DROP COLUMN tulumaks;

ALTER TABLE palk_config ADD COLUMN tm numeric(14,2);
ALTER TABLE palk_config ADD COLUMN pm numeric(14,2);
ALTER TABLE palk_config ADD COLUMN tka numeric(14,2);
ALTER TABLE palk_config ADD COLUMN tki numeric(14,2);
ALTER TABLE palk_config ADD COLUMN sm numeric(14,2);
ALTER TABLE palk_config ADD COLUMN muud1 numeric(14,2);
ALTER TABLE palk_config ADD COLUMN muud2 numeric(14,2);
update palk_config set tm = 21, pm = 2, tka = 1.4, tki = 2.8, sm = 33, muud1 = 0, muud2 = 0 
