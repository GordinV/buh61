ALTER TABLE counter
   ADD COLUMN paevad integer DEFAULT 0;


update counter set paevad = 0 where ifnull(paevad,0) = 0;