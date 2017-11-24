-- Column: dokprop1

-- ALTER TABLE config_ DROP COLUMN dokprop1;

ALTER TABLE config_ ADD COLUMN dokprop1 integer;
ALTER TABLE config_ ALTER COLUMN dokprop1 SET STORAGE PLAIN;
update config_ set dokprop1 = 0;
ALTER TABLE config_ ALTER COLUMN dokprop1 SET DEFAULT 0;

ALTER TABLE config_ ADD COLUMN dokprop2 integer;
ALTER TABLE config_ ALTER COLUMN dokprop2 SET STORAGE PLAIN;
update config_ set dokprop2 = 0;
ALTER TABLE config_ ALTER COLUMN dokprop2 SET DEFAULT 0;
