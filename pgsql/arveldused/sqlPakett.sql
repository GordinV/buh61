-- Column: kogus

-- ALTER TABLE pakett DROP COLUMN kogus;

ALTER TABLE pakett ADD COLUMN kogus numeric(14,4);

update pakett set kogus = 0;

ALTER TABLE pakett ALTER COLUMN kogus SET DEFAULT 0;

ALTER TABLE pakett ALTER COLUMN kogus SET NOT NULL;
