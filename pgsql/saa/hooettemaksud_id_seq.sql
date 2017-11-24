-- Sequence: hooettemaksud_id_seq

-- DROP SEQUENCE hooettemaksud_id_seq;

CREATE SEQUENCE hooettemaksud_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE hooettemaksud_id_seq OWNER TO postgres;
GRANT ALL ON TABLE hooettemaksud_id_seq TO postgres;
GRANT ALL ON TABLE hooettemaksud_id_seq TO public;
