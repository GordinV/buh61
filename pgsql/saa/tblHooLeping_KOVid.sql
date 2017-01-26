ALTER TABLE hooleping
   ADD COLUMN omavalitsusid integer DEFAULT 0;

ALTER TABLE hootaabel
   ADD COLUMN "tuluarvId" integer DEFAULT 0;

ALTER TABLE hooleping
   ADD COLUMN kovjaak numeric(18,6) DEFAULT 0;
