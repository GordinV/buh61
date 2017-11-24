ALTER TABLE leping3
   ADD COLUMN libid integer DEFAULT 0;

ALTER TABLE leping1
   ADD COLUMN pakettId integer DEFAULT 0;

update leping1 set pakettId = 0;

ALTER TABLE leping1
   ALTER COLUMN pakettid SET NOT NULL;


ALTER TABLE leping1
   ADD COLUMN objektId integer DEFAULT 0;

update leping1 set objektId = 0;

ALTER TABLE leping1
   ALTER COLUMN objektid SET NOT NULL;

