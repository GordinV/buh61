ALTER TABLE ladu_grupp ADD COLUMN kalor integer;
update ladu_grupp set kalor = 0;
ALTER TABLE ladu_grupp ALTER COLUMN kalor SET NOT NULL;
ALTER TABLE ladu_grupp ALTER COLUMN kalor SET DEFAULT 0;


ALTER TABLE ladu_grupp ADD COLUMN valid date;


ALTER TABLE ladu_grupp ADD COLUMN sahharid integer;
update ladu_grupp set sahharid = 0;
ALTER TABLE ladu_grupp ALTER COLUMN sahharid SET NOT NULL;
ALTER TABLE ladu_grupp ALTER COLUMN sahharid SET DEFAULT 0;

ALTER TABLE ladu_grupp ADD COLUMN rasv integer;
update ladu_grupp set rasv = 0;
ALTER TABLE ladu_grupp ALTER COLUMN rasv SET NOT NULL;
ALTER TABLE ladu_grupp ALTER COLUMN rasv SET DEFAULT 0;

ALTER TABLE ladu_grupp ADD COLUMN vailkaine integer;
update ladu_grupp set vailkaine = 0;
ALTER TABLE ladu_grupp ALTER COLUMN vailkaine SET NOT NULL;
ALTER TABLE ladu_grupp ALTER COLUMN vailkaine SET DEFAULT 0;

ALTER TABLE ladu_grupp ADD COLUMN staatus integer;
update ladu_grupp set staatus = 0;
ALTER TABLE ladu_grupp ALTER COLUMN staatus SET NOT NULL;
ALTER TABLE ladu_grupp ALTER COLUMN staatus SET DEFAULT 0;

