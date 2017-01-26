ALTER TABLE journal
   ADD COLUMN objekt character varying(20);

update journal set objekt = space(20) where ifnull(objekt,'null') = 'null';

ALTER TABLE journal
   ALTER COLUMN objekt SET DEFAULT space(20);
ALTER TABLE journal
   ALTER COLUMN objekt SET NOT NULL;
