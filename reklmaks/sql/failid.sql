-- Function: public.trigu_library_before()

-- DROP FUNCTION public.trigu_library_before();

CREATE OR REPLACE FUNCTION public.trigiu_userid_after()
  RETURNS opaque AS
'
declare 
	v_userid record;
	lresult int;
	lcNotice varchar;
begin
	perform sp_register_oper(new.rekvId,new.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR, sp_currentuser(CURRENT_USER::varchar, new.rekvid));
	return null;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;



CREATE TRIGGER trigiu_userid_after
  AFTER UPDATE OR INSERT
  ON public.userid
  FOR EACH ROW
  EXECUTE PROCEDURE public.trigiu_userid_after();

