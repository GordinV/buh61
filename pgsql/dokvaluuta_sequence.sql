﻿
CREATE SEQUENCE dokvaluuta1_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 130
  CACHE 1;
ALTER TABLE dokvaluuta1_id_seq OWNER TO vlad;
GRANT ALL ON TABLE dokvaluuta1_id_seq TO vlad;
GRANT ALL ON TABLE dokvaluuta1_id_seq TO public;


CREATE SEQUENCE valuuta1_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 2
  CACHE 1;
ALTER TABLE valuuta1_id_seq OWNER TO vlad;
GRANT ALL ON TABLE valuuta1_id_seq TO vlad;
GRANT ALL ON TABLE valuuta1_id_seq TO public;
